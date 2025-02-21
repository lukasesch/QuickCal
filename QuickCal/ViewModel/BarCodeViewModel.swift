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
import CryptoKit

class BarCodeViewModel: ObservableObject {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Published var scannedBarcode: String? = nil
    @Published var product: FoodItem? = nil
    @Published var isSessionRunning: Bool = false
    
    private let context: NSManagedObjectContext
    private let cameraManager = CameraManager()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        // Den neuen CameraManager als Delegate setzen
        cameraManager.delegate = self
    }
    
    // MARK: - Kamera-Management
    
    /// Startet die Kamerasession:
    /// - Setzt die alte Session zurück, konfiguriert sie neu und startet sie.
    func startScanning(in view: UIView) {
        cameraManager.resetSession()  // Session zurücksetzen
        cameraManager.configureSession(in: view)
        cameraManager.startSession()
        DispatchQueue.main.async {
            self.isSessionRunning = true
        }
    }
    
    /// Stoppt die laufende Kamerasession und aktualisiert den Status.
    func stopScanning() {
        cameraManager.stopSession()
        DispatchQueue.main.async {
            self.isSessionRunning = false
        }
    }
    
    /// Liefert den aktuellen Preview-Layer zurück.
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return cameraManager.getPreviewLayer()
    }
    
    // Produkt über Barcode über OpenFoodFacts API suchen
    func searchProductByBarcode(barcode: String, completion: @escaping (FoodItem?) -> Void) {
        print("Searching product for barcode: \(barcode)")
        
        let baseUrl = "https://de.openfoodfacts.org"
        let urlString = "\(baseUrl)/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        print("Requesting URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let productData = jsonResponse["product"] as? [String: Any] else {
                    print("Invalid JSON structure or product not found")
                    completion(nil)
                    return
                }
                
                let brand = productData["brands"] as? String ?? "Unbekannte Marke"
                let name = productData["product_name"] as? String ?? "Unbekanntes Produkt"
                let unit = (productData["nutriments_unit"] as? String) ?? "g"
                let kcal = (productData["nutriments"] as? [String: Any])?["energy-kcal_100g"] as? Int16 ?? 10
                let fat = (productData["nutriments"] as? [String: Any])?["fat_100g"] as? Double ?? 0.0
                let carbohydrate = (productData["nutriments"] as? [String: Any])?["carbohydrates_100g"] as? Double ?? 0.0
                let protein = (productData["nutriments"] as? [String: Any])?["proteins_100g"] as? Double ?? 0.0
                
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
                completion(foodItem)
            } catch {
                print("JSON Parsing error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // Lebensmittel zur Datenbank hinzufügen
    func OpenFoodFactsFoodToDB(name: String, defaultQuantity: Float, unit: String, calories: Int16, carbs: Float, protein: Float, fat: Float, daytime: Int16, quantity: Float, selectedDate: Date) {
        // Unique Hash in Hexadezimal erstellen
        let hashString = "\(name)\(defaultQuantity)\(unit)\(calories)\(carbs)\(protein)\(fat)"
        let hash = SHA256.hash(data: Data(hashString.utf8))
        let uniqueID = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        
        var food: Food?
        do {
            let existingFoods = try context.fetch(fetchRequest)
            if let existingFood = existingFoods.first {
                print("Lebensmittel existiert bereits in der Datenbank: \(name)")
                food = existingFood
                food?.lastUsed = Date()
            } else {
                food = Food(context: context)
                food?.name = name
                food?.defaultQuantity = defaultQuantity
                food?.unit = unit
                food?.kcal = calories
                food?.carbohydrate = carbs
                food?.protein = protein
                food?.fat = fat
                food?.uniqueID = uniqueID
                food?.lastUsed = Date()
                print("Neues Lebensmittel wurde erstellt: \(name)")
            }
        } catch {
            print("Fehler beim Abrufen von Lebensmitteln: \(error.localizedDescription)")
            return
        }
        
        guard let food = food else {
            print("Fehler: Lebensmittel konnte nicht erstellt oder abgerufen werden.")
            return
        }
        
        let trackedFood = TrackedFood(context: context)
        trackedFood.date = selectedDate
        trackedFood.daytime = daytime
        trackedFood.quantity = quantity
        trackedFood.food = food
        
        do {
            try context.save()
            print("Lebensmittel erfolgreich aktualisiert (lastUsed) und in TrackedFood gespeichert")
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    func toggleTorch() {
        cameraManager.toggleTorch()
    }
}

extension BarCodeViewModel: CameraManagerDelegate {
    func didDetectBarcode(with code: String) {
        // Session stoppen um mehrmaliges Scannen eines BarCodes im Bild zu verhindern
        self.stopScanning()
        
        DispatchQueue.main.async {
            self.scannedBarcode = code
        }
        
        self.searchProductByBarcode(barcode: code) { [weak self] product in
            DispatchQueue.main.async {
                self?.product = product
            }
        }
    }
    
    func didFail(with error: Error) {
        print("Camera Manager Error: \(error.localizedDescription)")
    }
}
