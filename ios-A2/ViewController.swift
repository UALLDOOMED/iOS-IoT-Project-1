//
//  ViewController.swift
//  fire
//
//  Created by Kang Meng on 28/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit

import Firebase
//import FirebaseCore
//import FirebaseFirestore

class ViewController: UIViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    weak var listener: ListenerRegistration?
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var luminanceLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgColor = UIColor(red: 186/255, green: 185/225, blue: 187/255, alpha: 0.5)
        self.navigationController?.navigationBar.barTintColor = bgColor
        colorView.layer.cornerRadius = 5.0
        
        self.listener = delegate.db.collection("sensorData").document("current").addSnapshotListener {
            documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            //            print("\(document.documentID) => \(document.data())")
            let t = document.data()?["timestamp"] as! Timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            dateFormatter.timeZone = .current
            self.timeLabel.text = dateFormatter.string(from: t.dateValue())
            self.tempLabel.text = "\(document.data()?["temp"] as! Float) °C"
            self.luminanceLabel.text = "\(document.data()?["luminance"] as! NSNumber) lux"
            self.colorView.backgroundColor = UIColor(red: document.data()?["red"] as! CGFloat / 255, green: document.data()?["green"] as! CGFloat / 255, blue: document.data()?["blue"] as! CGFloat / 255, alpha: 1)
            self.colorLabel.text = "R:\(round(document.data()?["red"] as! CGFloat)) G:\(round(document.data()?["green"] as! CGFloat)) B:\(round(document.data()?["blue"] as! CGFloat))"
        }
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
}
