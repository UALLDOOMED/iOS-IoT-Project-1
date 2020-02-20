//
//  ChartViewController.swift
//  fire
//
//  Created by Kang Meng on 4/10/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import Charts
import Firebase

class ChartViewController: UIViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    weak var listener: ListenerRegistration?
    var sensorDatas: [SensorData] = []
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgColor = UIColor(red: 186/255, green: 185/225, blue: 187/255, alpha: 0.5)
        self.navigationController?.navigationBar.barTintColor = bgColor
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delegate.db.collection("sensorData").order(by: "timestamp", descending: true).limit(to: 10).getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.sensorDatas = []
                for document in querySnapshot!.documents {
                    self.sensorDatas.insert(SensorData(pressure: (document.data()["pressure"] as! NSNumber).doubleValue, temp: (document.data()["temp"] as! NSNumber).doubleValue, red: (document.data()["red"] as! NSNumber).doubleValue, green: (document.data()["green"] as! NSNumber).doubleValue, blue: (document.data()["blue"] as! NSNumber).doubleValue, IR: (document.data()["IR"] as! NSNumber).doubleValue, luminance: (document.data()["luminance"] as! NSNumber).doubleValue, time: (document.data()["timestamp"] as! Timestamp).dateValue()), at: 0)
                }
                self.setChartValues()
            }
        }
        super.viewWillAppear(animated)
    }
    
    func setChartValues(_ count : Int = 10){
        var dataArray : [ChartDataEntry] = []
        var dataArray2 : [BarChartDataEntry] = []
        for i in 0 ..< count {
            let value = ChartDataEntry(x : Double(i),y : sensorDatas[i].temp)
            let value2 = BarChartDataEntry(x: Double(i), yValues: [sensorDatas[i].pressure])
            dataArray.append(value)
            dataArray2.append(value2)
        }
        let chartDataset = LineChartDataSet(entries : dataArray, label: "Temperature(°C)")
        chartDataset.colors = ChartColorTemplates.joyful()
        let chartDataset2 = BarChartDataSet(entries : dataArray2, label: "Pressure(kPa)")
        chartDataset2.colors = ChartColorTemplates.pastel()
        let chartData = LineChartData(dataSet: chartDataset)
        let chartData2 = BarChartData(dataSet: chartDataset2)
        self.lineChartView.data = chartData
        self.barChartView.data = chartData2
        lineChartView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 228/255, alpha: 0.8)
        barChartView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 228/255, alpha: 0.8)
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 2.0, easingOption: .linear)
        lineChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelPosition = .bottom
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
