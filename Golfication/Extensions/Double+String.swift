//
//  Double+String.swift
//  Golfication
//
//  Created by IndiRenters on 10/23/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
