//
//  customPieView.swift
//  Golfication
//
//  Created by Khelfie on 02/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class customPieView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.orange.setFill()
        let path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2),
                            radius: self.frame.size.width/2,
                            startAngle: CGFloat(-60.0).toRadians(),
                            endAngle: CGFloat(0.0).toRadians(),
                            clockwise: true)
        path.fill()
        // Specify a border (stroke) color.
        UIColor.purple.setStroke()
        path.stroke()
       
        
        
        
    }
    func createOval(){
    
    }
}
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}
