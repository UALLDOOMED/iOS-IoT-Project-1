//
//  HistoryViewController.swift
//  fire
//
//  Created by Kang Meng on 1/10/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var sensorDatas: [SensorData] = []
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgColor = UIColor(red: 186/255, green: 185/225, blue: 187/255, alpha: 0.5)
        self.navigationController?.navigationBar.barTintColor = bgColor
        //        startDatePicker.maximumDate = endDatePicker.date
        //        endDatePicker.minimumDate = startDatePicker.date
        
        // from https://blog.apoorvmote.com/updating-label-from-datepicker-swift/
        startDatePicker.addTarget(self, action: #selector(self.startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(self.endDateChanged), for: .valueChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sensorDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let sensorData = self.sensorDatas[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        dateFormatter.timeZone = .current
        cell.timeLabel.text = dateFormatter.string(from: sensorData.time)
        cell.tempLabel.text = "\(sensorData.temp) °C"
        cell.colorLabel.text = "R:\(sensorData.red.rounded()) G:\(sensorData.green.rounded()) B: \(sensorData.blue.rounded())"
        cell.colorView.backgroundColor = UIColor(red: CGFloat(sensorData.red / 255), green: CGFloat(sensorData.green / 255), blue: CGFloat(sensorData.blue / 255), alpha: 1)
        return cell
    }
    
    @IBAction func fetchData(_ sender: Any) {
        self.sensorDatas = []
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        delegate.db.collection("sensorData").whereField("timestamp", isGreaterThanOrEqualTo: startDate).whereField("timestamp", isLessThanOrEqualTo: endDate).getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let sensorData = SensorData(pressure: Double((document.data()["pressure"] as! NSNumber).floatValue), temp: Double((document.data()["temp"] as! NSNumber).floatValue), red: Double((document.data()["red"] as! NSNumber).floatValue), green: Double((document.data()["green"] as! NSNumber).floatValue), blue: Double((document.data()["blue"] as! NSNumber).floatValue), IR: Double((document.data()["IR"] as! NSNumber).floatValue), luminance: Double((document.data()["luminance"] as! NSNumber).floatValue), time: (document.data()["timestamp"] as! Timestamp).dateValue())
                    self.sensorDatas.append(sensorData)
                }
                if self.sensorDatas.count == 0{
                    self.displayMessage(title: "No Record Found", message: "Try another period of date")
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker) {
        self.endDatePicker.minimumDate = datePicker.date
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker) {
        self.startDatePicker.maximumDate = datePicker.date
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
