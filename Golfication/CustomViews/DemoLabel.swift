//
//  DemoLabel.swift
//  Golfication
//
//  Created by Khelfie on 20/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class DemoLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = NSTextAlignment.center
        self.font = UIFont(name: "SFProDisplay-Regular", size: 20.0)
        self.numberOfLines = 2
        self.tag = 555
        self.textColor = UIColor.glfWarmGrey
        self.text = "DEMO STATS"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
