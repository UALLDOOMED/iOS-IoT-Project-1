//
//  SensorData.swift
//  fire
//
//  Created by Kang Meng on 1/10/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit

class SensorData: NSObject {
    var pressure: Double
    var temp: Double
    var red: Double
    var green: Double
    var blue: Double
    var IR: Double
    var luminance: Double
    var time: Date
    
    init(pressure: Double, temp: Double, red: Double, green: Double, blue: Double, IR: Double, luminance: Double, time: Date) {
        self.pressure = pressure
        self.temp = temp
        self.red = red
        self.green = green
        self.blue = blue
        self.IR = IR
        self.luminance = luminance
        self.time = time
    }
}
