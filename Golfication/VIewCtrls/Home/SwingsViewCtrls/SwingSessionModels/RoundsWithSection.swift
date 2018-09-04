//
//  RoundsWithSection.swift
//  Golfication
//
//  Created by IndiRenters on 11/7/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
class RoundsWithSection:NSObject{
    var sections:String!
    var rows:[Rounds] = []
    
    func addSection(row:Rounds){
        rows.append(row)
    }
}
