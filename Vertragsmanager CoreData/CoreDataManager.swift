//
//  CoreDataManager.swift
//  Vertragsmanager CoreData
//
//  Created by Robin Ruf on 02.01.21.
//  Copyright © 2021 Christian Gesty. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataManager {
    
    // Da jede Kategorie unterschiedliche Anzahl an Verträgen beinhaltet, erstellen wir für jede Kategorie/Sektion ein separates Array
    var car = [Contract]()
    var phone = [Contract]()
    var home = [Contract]()
    var versicherungen = [Contract]()
    
    var context: NSManagedObjectContext!
    
    // Unsere Konstante, um auf die DB zugreifen zu können (speichern, laden, löschen von Daten)
    static let shared = CoreDataManager()
    
    // init
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Objekte laden
        loadItems()
    }
    
    
    // Methoden
    func getContractItem(section: Int, index: Int) -> Contract {
        // Prüfen, in welcher Sektion wir uns befinden
        if section == 0 { // Sektion "Auto"
            return self.car[index] // Gib mir bei jedem Durchlauf jedes Objekt von jeder Zeile zurück
        } else if section == 1 {
            return self.phone[index]
        } else if section == 2 {
            return self.home[index]
        } else {
            return self.versicherungen[index]
        }
    }
    
    // Daten löschen können
    func deleteContractItemAt(section: Int, index: Int) {
        
        // im Context löschen
        context.delete(getContractItem(section: section, index: index))
        
        // immer wenn wir was im Context verändern, müssen wir speichern
        save()
        
        // im Array löschen
        if section == 0 { // Sektion "Auto"
            self.car.remove(at: index)
        } else if section == 1 {
            self.phone.remove(at: index)
        } else if section == 2 {
            self.home.remove(at: index)
        } else {
            self.versicherungen.remove(at: index)
        }
        
    }
    
    // Zählen, wieviele Instanzen(Objekte) sich in den verschienenen Sektionen befinden, damit die exakte Anzahl in der App wiedergegeben wird
    func count(section: Int) -> Int {
        var count = 0
        
        switch section {
        case 0: count = car.count
        case 1: count = phone.count
        case 2: count = home.count
        case 3: count = versicherungen.count
        default:
            break
        }
        
        return count
    }
    
    // Methode zum abspeichern der vom User eingegebenen Daten
    func addNewItem(category: String, name: String, price: String, startContract: String, duration: String, endContract: String)  {
        
        // Entity Objekt erstellen
        // Jeder Vertrag wird als Entity gespeichert. Dann muss man den Namen der Entity wählen (newContract) und dann wo es gespeichert werden soll - da wir es permanent speichern wollen, muss es im "context" gespeichert werden.
        // as! Contract = Die Vorlage bei den CoreData Entity's die wir erstellt haben hiess "Contract" und somit können wir nun auf alle von uns erstellten Eigenschafter dieser Entity zugreifen. Beispiel: newContractItem.name , newContractItem.price etc.
        let newContractItem = NSEntityDescription.insertNewObject(forEntityName: "Contract", into: context) as! Contract
        
        newContractItem.category = category
        newContractItem.name = name
        newContractItem.price = price
        newContractItem.start = startContract
        newContractItem.duration = duration
        newContractItem.end = endContract
        
        save()
        
        // Vertragsitem ins Array speichern
        switch category {
        case "Auto": car.append(newContractItem)
        case "Telefon": phone.append(newContractItem)
        case "Haus": home.append(newContractItem)
        case "Versicherungen": versicherungen.append(newContractItem)
        default:
            break
        }
    }
    
    // Daten laden
    func loadItems() {
        // <Contract> = Schau nach, ob du im Speicher Objekte des Typs (Entity) "Contract" findest!
        let request: NSFetchRequest<Contract> = NSFetchRequest<Contract>(entityName: "Contract")
        
        // da ein Fehler geworfen werden kann, weil die Daten gelöscht wurden o.ä. per do-catch Statement
        do {
            // Anfrage ausführen und das Ergebnis in einer Konstanten als Array abspeichern
            let contractItemsArray = try context.fetch(request)
            
            // Jetzt bei jedem Objekt im Array prüfen, welche Kategorie es hat und jenachdem ins Array zuweisen
            for item in contractItemsArray {
                if item.category == "Auto" {
                    car.append(item)
                } else if item.category == "Telefon" {
                    phone.append(item)
                } else if item.category == "Haus" {
                    home.append(item)
                } else {
                    versicherungen.append(item)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Speichern
    func save() {
        do {
            try context.save()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
 }
