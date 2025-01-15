//
//  BarCodeViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.12.24.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation
import CoreData

class BarCodeViewModel: ObservableObject {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Published var scannedBarcode: String? = nil
    @Published var product: FoodItem? = nil
    @Published var isSessionRunning: Bool = false
    
    private let context: NSManagedObjectContext
    
    private let cameraManager = CameraManager()
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        // CoraData
        self.context = context
        
        // Observe CameraManager Output for scanned Barcode
        cameraManager.$scannedCode
            .compactMap { $0 }  // Ignore Nil Values
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] barcode in
                DispatchQueue.main.async {
                    self?.scannedBarcode = barcode
                    print("Erkannter Barcode im ViewModel: \(barcode)")
                    
                }
            }
            .store(in: &cancellables)
    }
    
    func startScanning() {
        cameraManager.configureSession { [weak self] success in
            guard success else {
                print("Kamera-Konfiguration fehlgeschlagen.")
                return
            }
            self?.cameraManager.startSession()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }
    
    func stopScanning() {
        guard cameraManager.isSessionRunning() else {
            //print("Session ist bereits gestoppt.")
            return
        }
        cameraManager.stopSession()
        isSessionRunning = false
        clearPreviewLayer()
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return cameraManager.getPreviewLayer()
    }
    
    func clearPreviewLayer() {
        cameraManager.resetSession()
        isSessionRunning = false
    }
    
    func searchProductByBarcode(barcode: String, completion: @escaping (FoodItem?) -> Void) {
        print("Searching product for barcode: \(barcode)")
        
        let baseUrl = "https://de.openfoodfacts.org"
        let urlString = "\(baseUrl)/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil) // Rückgabe von nil bei ungültiger URL
            return
        }
        
        print("Requesting URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil) // Rückgabe von nil bei einem Netzwerkfehler
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil) // Rückgabe von nil, wenn keine Daten empfangen wurden
                return
            }
            
            do {
                // Parse Data
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let productData = jsonResponse["product"] as? [String: Any] else {
                    print("Invalid JSON structure or product not found")
                    completion(nil) // Rückgabe von nil bei ungültigem JSON
                    return
                }
                
                // Extract the product and convert it to FoodItem
                let brand = productData["brands"] as? String ?? "Unbekannte Marke"
                let name = productData["product_name"] as? String ?? "Unbekanntes Produkt"
                let unit = (productData["nutriments_unit"] as? String) ?? "g"
                let kcal = (productData["nutriments"] as? [String: Any])?["energy-kcal_100g"] as? Int16 ?? 10
                let fat = (productData["nutriments"] as? [String: Any])?["fat_100g"] as? Double ?? 0.0
                let carbohydrate = (productData["nutriments"] as? [String: Any])?["carbohydrates_100g"] as? Double ?? 0.0
                let protein = (productData["nutriments"] as? [String: Any])?["proteins_100g"] as? Double ?? 0.0
                
                // Create FoodItem
                let foodItem = FoodItem(
                    name: "\(brand) \(name)",
                    unit: unit,
                    defaultQuantity: 100,
                    kcal: kcal,
                    fat: Float(fat),
                    carbohydrate: Float(carbohydrate),
                    protein: Float(protein)
                )
                
                print("Product found: \(foodItem.name)")
                completion(foodItem) // Rückgabe des FoodItem über den Completion-Handler
            } catch {
                print("JSON Parsing error: \(error.localizedDescription)")
                completion(nil) // Rückgabe von nil bei einem Parsing-Fehler
            }
        }
        
        task.resume()
    }
    
    
    func OpenFoodFactsFoodToDB(name: String, defaultQuantity: Float, unit: String, calories: Int16, carbs: Float, protein: Float, fat: Float, daytime: Int16, quantity: Float, selectedDate: Date) {
        
        let food = Food(context: context)
        
        food.name = name
        food.defaultQuantity = defaultQuantity
        food.unit = unit
        food.kcal = calories
        food.carbohydrate = carbs
        food.protein = protein
        food.fat = fat
        
        food.lastUsed = Date()
        
        let trackedFood = TrackedFood(context: context)
        trackedFood.date = selectedDate
        trackedFood.daytime = daytime
        trackedFood.quantity = quantity
        trackedFood.food = food
        
        //Speichern
        do {
            try context.save()
            print("Lebensmittel erfolgreich in Food gespeichert")
            print("Lebensmittel erfolgreich in TrackedFood gespeichert")
        } catch {
            print("Benutzer konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
}
