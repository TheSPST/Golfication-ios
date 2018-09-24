
//
//  String+Width.swift
//  Golfication
//
//  Created by IndiRenters on 11/29/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Foundation
extension String {
    func SizeOf_String( font: UIFont) -> CGSize {
        let fontAttribute = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttribute)  // for Single Line
        return size;
    }
}
extension Array {
    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
}
