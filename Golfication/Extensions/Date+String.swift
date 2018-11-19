//
//  Date+String.swift
//  Golfication
//
//  Created by IndiRenters on 10/23/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
extension NSDate
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
}
extension NSDate {
    
    var timeAgoSinceNow: String {
        return getTimeAgoSinceNow()
    }
    
    private func getTimeAgoSinceNow() -> String {
        
        var interval = Calendar.current.dateComponents([.year], from: self as Date, to: Date()).year!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " y ago" : "\(interval)" + " y ago"
        }
        interval = Calendar.current.dateComponents([.month], from: self as Date, to: Date()).month!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " m ago" : "\(interval)" + " m ago"
        }
        interval = Calendar.current.dateComponents([.day], from: self as Date, to: Date()).day!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " d ago" : "\(interval)" + " d ago"
        }
        interval = Calendar.current.dateComponents([.hour], from: self as Date, to: Date()).hour!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " h ago" : "\(interval)" + " h ago"
        }
        interval = Calendar.current.dateComponents([.minute], from: self as Date, to: Date()).minute!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " m ago" : "\(interval)" + " m ago"
        }
        return "just now"
    }
}
