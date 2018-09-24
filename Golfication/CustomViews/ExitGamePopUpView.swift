//
//  ExitGamePopUpView.swift
//  Golfication
//
//  Created by Rishabh Sood on 26/07/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

@objc protocol ExitGamePopUpDelegate {
    @objc optional func saveNExitPressed(button:UIButton)
    @objc optional func discardPressed(button:UIButton)
}
class ExitGamePopUpView: UIView {

    var delegate:ExitGamePopUpDelegate!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var btnSaveNExit: UIButton!
    @IBOutlet weak var lblHole: UILabel!
    @IBOutlet weak var lblStatic: UILabel!

    var labelText: String? {
        get { return lblHole?.text }
        set { lblHole.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
        btnSaveNExit.setCorner(color: UIColor.clear.cgColor)
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.glfBluegreen.cgColor, UIColor.glfGreenBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = btnSaveNExit.frame
        btnSaveNExit.layer.addSublayer(gradient)
        
        lblStatic.text = "You'll not able to edit this round anymore.\nAre you sure want to exit?"
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ExitGamePopUpView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func saveNExitAction(_ sender: UIButton!) {
        delegate.saveNExitPressed!(button: sender)
    }

    
    @IBAction func discardAction(sender: UIButton) {
        delegate.discardPressed!(button: sender)
    }

    @IBAction func crossAction(sender: UIButton) {
        self.isHidden = true
    }
    
    func show(navItem: UINavigationItem) {
        self.isHidden = false
        navItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hide(navItem: UINavigationItem) {
        self.isHidden = true
        navItem.rightBarButtonItem?.isEnabled = true
    }

}
