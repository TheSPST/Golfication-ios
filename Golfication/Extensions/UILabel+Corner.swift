//
//  UILabel+Corner.swift
//  Golfication
//
//  Created by IndiRenters on 11/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
extension UIButton{
    func setCircle(frame:CGRect){
        self.frame = frame
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
    func setCorner(color:CGColor){
        self.layer.cornerRadius = 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }

    func setCornerWithCircle(color:CGColor){
        self.layer.cornerRadius = self.frame.width*0.5
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCornerWithCircleWidthOne(color:CGColor){
        self.layer.cornerRadius = self.frame.width*0.5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCornerWithRadius(color:CGColor,radius:CGFloat){
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
}
extension UILabel{
    func setCircle(frame:CGRect){
        self.frame = frame
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
    func setCorner(color:CGColor){
        self.layer.cornerRadius = 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCornerWithRadius(color:CGColor,radius:CGFloat){
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCornerWithCircle(color:CGColor){
        self.layer.cornerRadius = self.frame.width*0.5
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCornerWithCircleWidthOne(color:CGColor){
        self.layer.cornerRadius = self.frame.width*0.5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
}
extension UIView{
    func setCornerView(color:CGColor){
    self.layer.cornerRadius = 2.0
    self.layer.borderWidth = 1.0
    self.layer.borderColor = color
    self.layer.masksToBounds = true
    }
}

extension UIImageView{
    func setCircle(frame:CGRect){
        self.frame = frame
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
    func setCorner(color:CGColor){
        self.layer.cornerRadius = 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color
        self.layer.masksToBounds = true
    }
    func setCircleWithColor(frame:CGRect,color:CGColor){
        self.frame = frame
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        self.layer.borderWidth = 0.3
        self.layer.borderColor = color
    }
}
