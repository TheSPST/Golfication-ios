//
//  CustomPromoCardVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 30/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

@objc protocol CustomProModeDelegate {
    @objc optional func deviceLockBtnPressed(button:UIButton)
    @objc optional func proLockBtnPressed(button:UIButton)
}

class CustomProModeView: UIView {
    
    var delegate:CustomProModeDelegate!

    var label: UILabel!
    var btnPro: UIButton!
    var btnDevice: UIButton!
    var proImageView: UIImageView!
    var titleLabel: UILabel!

    var labelText: String? {
        get { return label?.text }
        set { label.text = newValue }
    }
    
    var titleLabelText: String? {
        get { return titleLabel?.text }
        set { titleLabel.text = newValue }
    }
    
    var btnTitle: String? {
        get {
            return btnPro?.titleLabel?.text
        }
        set {
            btnPro.setTitle(newValue, for: .normal)
        }
    }

    var btnDeviceTitle: String? {
        get {
            return btnDevice?.titleLabel?.text
        }
        set {
            btnDevice.setTitle(newValue, for: .normal)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //https://github.com/codepath/ios_guides/wiki/Custom-Views
        initSubviews()
    }
    
    func initSubviews() {

        proImageView = UIImageView()
        proImageView.image = UIImage(named: "pro")
        proImageView.backgroundColor = UIColor.clear
        //addSubview(proImageView)
        
        label = UILabel()
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "SFProDisplay-Regular", size: 19.0)
        label.numberOfLines = 2
        self.addSubview(label)
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.font = UIFont(name: "SFProDisplay-Medium", size: 16.0)
        self.addSubview(titleLabel)
        
        btnPro = UIButton()
        btnPro.backgroundColor = UIColor.white
        btnPro.setTitleColor(UIColor(rgb: 0x008A64), for: .normal)
        btnPro.layer.borderWidth = 2.0
        btnPro.layer.cornerRadius = 20.0
        btnPro.layer.borderColor = UIColor(rgb: 0x008A64).cgColor
        btnPro.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
        btnPro.addTarget(self, action: #selector(btnProClicked(_:)), for: .touchUpInside)
        self.addSubview(btnPro)
        
        btnDevice = UIButton()
        btnDevice.backgroundColor = UIColor.white
        btnDevice.setTitleColor(UIColor(rgb: 0x008A64), for: .normal)
        btnDevice.layer.borderWidth = 2.0
        btnDevice.layer.cornerRadius = 20.0
        btnDevice.layer.borderColor = UIColor(rgb: 0x008A64).cgColor
        btnDevice.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
        btnDevice.addTarget(self, action: #selector(btnDeviceClicked(_:)), for: .touchUpInside)
        self.addSubview(btnDevice)
    }
    
    @objc func btnProClicked(_ sender: UIButton!) {
        
        delegate.proLockBtnPressed!(button: sender)
    }
    
    @objc func btnDeviceClicked(_ sender: UIButton!) {
        
        delegate.deviceLockBtnPressed!(button: sender)
    }
}
extension UIView
{
    func makeBlurView(targetView:UIView?)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetView!.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 1.0
        targetView?.addSubview(blurEffectView)
    }
}
