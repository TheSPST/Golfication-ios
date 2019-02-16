//
//  DemoFooterView.swift
//  Golfication
//
//  Created by Khelfie on 13/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

@objc protocol DemoFooterViewDelegate {
    @objc optional func playGameButton(button:UIButton)
}
class DemoFooterView: UIView {
    var delegate:DemoFooterViewDelegate!
    
    var label: UILabel!
    var btnPlayGame: UIButton!
//    var labelText: String? {
//        get { return label?.text }
//        set { label.text = newValue }
//    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        
        label = UILabel()
        label.textColor = UIColor.glfWhite
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "SFProDisplay-Regular", size: 15.0)
        label.numberOfLines = 2
        label.text = "Play atleast one game to get these stats"
        self.addSubview(label)
        
        btnPlayGame = UIButton()
        btnPlayGame.backgroundColor = UIColor.white
        btnPlayGame.setTitleColor(UIColor.glfBlack75, for: .normal)
//        btnPlayGame.layer.borderWidth = 2.0
        btnPlayGame.layer.cornerRadius = 5.0
//        btnPlayGame.layer.borderColor = UIColor(rgb: 0x008A64).cgColor
        btnPlayGame.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 13.0)
        btnPlayGame.setTitle("Play Game", for: .normal)
        btnPlayGame.addTarget(self, action: #selector(btnPlayGameClicked(_:)), for: .touchUpInside)
        self.addSubview(btnPlayGame)
    }
    @objc func btnPlayGameClicked(_ sender: UIButton!) {
        delegate.playGameButton!(button: sender)
    }
}
