//
//  ViewController.swift
//  Vertragsmanager CoreData
//
//  Created by Christian Gesty on 09.11.19.
//  Copyright © 2019 Christian Gesty. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var contractTableView: UITableView!
    
    
    var category: [String] = ["Auto", "Telefon", "Haus", "Versicherungen"]
    var images: [String] = ["car", "telefon", "home", "versicherungen"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        contractTableView.delegate = self
        contractTableView.dataSource = self
    }
    
    
    @IBAction func addNewContractButton_Tapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Kategorie", message: "Wähle eine Kategorie aus.", preferredStyle: .alert)
        
        // über eine for-Schleife die Actions erstellen mithilfe der Methode "createActions"
        for x in 0..<category.count {
            alert.addAction(createActions(category: category[x]))
        }
        
        // Der ViewController(self) soll das Alert "präsentieren"
        self.present(alert, animated: true, completion: nil)
    }
    
    func createActions(category: String) -> UIAlertAction {
        let action = UIAlertAction(title: category, style: .default) { (action) in
            // Speichern, auf welche Kategorie der Nutzer gedrückt hat
            let categoryAsString = action.title!
            self.createAlertForUserData(category: categoryAsString)
        }
        
        return action
    }
    
    func createAlertForUserData(category: String) {
        
        let alert = UIAlertController(title: "Vertrag hinzufügen", message: "", preferredStyle: .alert)
        
        // Die 5 Textfelder hinzufügen
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Vertragsname"
            nameTextField.keyboardType = .default
        }
        
        alert.addTextField { (priceTextField) in
            priceTextField.placeholder = "Preis pro Monat"
            priceTextField.keyboardType = .decimalPad
            
            // Target hinzufügen, damit automatisch, sobald der User die Eingabe beendet, ein CHF davor steht
            priceTextField.addTarget(self, action: #selector(self.endEditingPrice(_:)), for: .editingDidEnd)
            
            // Target hinzufügen, damit automatisch, sobald der User ins Feld klickt, alles gelöscht wird und der User die Eingabe erneuern kann, ohne alles rauslöschen zu müssen.
            priceTextField.addTarget(self, action: #selector(self.startEditingPrice(_:)), for: .editingDidBegin)
        }
        
        alert.addTextField { (startTextField) in
            startTextField.placeholder = "Vertragsbeginn"
            
            // Target hinzufügen, sobald der User die Eingabe beginnt, soll die Methode aufgerufen werden, wo ihm der Datepicker angezeigt wird
            startTextField.addTarget(self, action: #selector(self.openCalender(_:)), for: .touchDown)
            // .touchDown = jedesmal, wenn der User auf das Feld klickt (sozusagen, wenn er "runterdrückt")
            
        }
        
        alert.addTextField { (durationTextField) in
            durationTextField.placeholder = "Laufzeit in Monate"
            durationTextField.keyboardType = .numberPad
            
            // Target hinzufügen, dass sobald der User die Monate eingegeben hat, die App automatisch das Ende der Vertragslaufzeit errechnet
            durationTextField.addTarget(self, action: #selector(self.calculateContractEnd(_:)), for: .editingDidEnd)
        }
        
        alert.addTextField { (endTextField) in
            self.endTextField = endTextField
            endTextField.placeholder = "Vetragsende"
        }
        
        let save = UIAlertAction(title: "Speichern", style: .default) { (save) in
            // Die Textfelder werden wie ein Array in die Alertbox eingebaut, somit kann man darauf auch genau so zugreifen
            let name = self.checkUserInput(value: alert.textFields![0].text!)
            let price = self.checkUserInput(value: alert.textFields![1].text!)
            let start = self.checkUserInput(value: alert.textFields![2].text!)
            let duration = self.checkUserInput(value: alert.textFields![3].text!)
            let end = self.checkUserInput(value: alert.textFields![4].text!)
           
            // Daten dauerhaft und im Array gespeichert
            CoreDataManager.shared.addNewItem(category: category, name: name, price: price, startContract: start, duration: duration, endContract: end)
            // Tabelle aktuallisieren
            self.contractTableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .default) { (cancel) in }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - check user input
    func checkUserInput(value: String?) -> String {
        // Optional Binding, weil überprüft werden muss, ob der User eine Eingabe gemacht hat oder ob er das Feld leer gelassen hat
        if let input = value {
            return input
        } else {
            return "Kein Wert vorhanden"
        }
        
        
        
    }
    
    @objc func endEditingPrice(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            textField.text = "CHF \(textField.text!)"
        } else {
            textField.text = ""
        }
    }
    
    @objc func startEditingPrice(_ textField: UITextField) {
        textField.text = ""
    }
    
    // MARK: - Vetragsdaten mit dem DatePicker
    
    // Konstante initialisiert mit dem DatePicker()
    let datePicker = UIDatePicker()
    var startTextField = UITextField()
    var endTextField = UITextField()
    
    @objc func openCalender(_ textField: UITextField) {
        startTextField = textField
        // Wähle die Mode aus (Countdown, Datum, Datum + Zeit, Zeit
        datePicker.datePickerMode = .date
        
        // Dem Textfeld sagen, dass statt der normalen Tastatur der DatePicker angezeigt werden soll
        textField.inputView = datePicker
        
        // Target hinzufügen, dass sobald der Wert sich geändert hat, eine Methode ausgeführt werden soll, die das Datum im Textfeld anzeigt - also jedesmal wenn der User am "rädchen" dreht und den Tag/Monat/Jahr ändert, soll das im Textfeld aktuallisiert werden
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc func dateChanged(_ userDate: UIDatePicker) {
        // Wieder das Spiel mit dem DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MMM. yyyy"
        dateFormatter.locale = Locale(identifier: "de_DE")
        let dateAsString = dateFormatter.string(from: userDate.date)
        
        // nun das Datum in Textform in der globalen Variablen "startTextField" abspeichern
        // doch zuerst überprüfen, ob der User überhaupt ein Datum ausgewählt hat
        if dateAsString.isEmpty {
            return
        } else {
            startTextField.text = dateAsString
        }
    }
    
    @objc func calculateContractEnd(_ textField: UITextField) {
        // Hier mit Guard-Statement überprüfen, ob der User eine Anzahl Monate als Vertragslaufzeit angegeben hat - falls ja, ziehe den Wert da raus und arbeite damit weiter, falls NICHT, RETURN, damit die App nicht abstürtzt
        guard let text = textField.text else { return }
        
        if text.isEmpty {
            return
        } else {
            // Wieder eine DateFormatter-Instanz erstellen, da auch das Vertragsende, welches berechnet wird, als Datum angezeigt wird
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd. MMM. yyyy"
            dateFormatter.locale = Locale(identifier: "de_DE")
            
            // In Tage ausrechnen
            let days = Double(text)! * 30.0
            // Sekunden * Minuten * 24 Stunden * Anzahl Tage welche der User in das Textfeld eingegeben hat
            let date = datePicker.date.addingTimeInterval(60.0*60.0*24.0*days)
            endTextField.text = dateFormatter.string(from: date)
        }
        
    }
    

}

// extension = Erweiterung
// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 238 / 255, green: 92 / 255, blue: 66 / 255, alpha: 0.8)
        
        // Elemente in das View einfügen
        let image = UIImage(named: images[section])
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = category[section]
        label.font = UIFont(name: "Din Alternate", size: 25)
        label.frame = CGRect(x: 40, y: 5, width: 200, height: 30)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.deleteContractItemAt(section: indexPath.section, index: indexPath.row)
            contractTableView.reloadData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return category.count // 4 Sektionen
    }
    
    // Angeben, wieviele Tabellenzeilen pro Sektion erstellt werden müssen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CoreDataManager.shared.count(section: section)
    }
    
    // Tabellenzeile erstellen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        
        let contractItem = CoreDataManager.shared.getContractItem(section: indexPath.section, index: indexPath.row)
        
        itemCell.nameLabel.text = contractItem.name
        itemCell.priceLabel.text = contractItem.price
        itemCell.startLabel.text = contractItem.start
        itemCell.durationLabel.text = contractItem.duration
        itemCell.endLabel.text = contractItem.end
        
        return itemCell
    }
    
    
}

