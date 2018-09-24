//
//  Array + RemoveDuplicate.swift
//  Golfication
//
//  Created by IndiRenters on 12/7/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
