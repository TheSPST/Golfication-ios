//
//  customPieView.swift
//  Golfication
//
//  Created by Khelfie on 02/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class customPieViewCenter: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.glfWhiteThree.setFill()
        let oval4Path = UIBezierPath()
        oval4Path.addArc(withCenter: CGPoint(x:rect.width/2,y:rect.height), radius: rect.height*0.8, startAngle: -120 * CGFloat.pi/180, endAngle: -60 * CGFloat.pi/180, clockwise: true)
        oval4Path.addLine(to: CGPoint(x:rect.width/2,y:rect.height))
        oval4Path.close()
        oval4Path.fill()
        // Specify a border (stroke) color.
//        oval4Path.stroke()
    }
    func updateViewWithColor(rect:CGRect,color:UIColor,radius:CGFloat){
        let oval4Path = UIBezierPath()
        oval4Path.addArc(withCenter: CGPoint(x:rect.width/2,y:rect.height), radius: radius, startAngle: -120 * CGFloat.pi/180, endAngle: -60 * CGFloat.pi/180, clockwise: true)
        oval4Path.addLine(to: CGPoint(x:rect.width/2,y:rect.height))
        oval4Path.close()
        oval4Path.fill()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = oval4Path.cgPath
        shapeLayer.fillColor =  color.cgColor
        self.layer.addSublayer(shapeLayer)
    }
}

