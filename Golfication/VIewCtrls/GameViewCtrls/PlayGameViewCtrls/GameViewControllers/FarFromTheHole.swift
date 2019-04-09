//
//  FarFromTheHole.swift
//  Golfication
//
//  Created by Rishabh Sood on 06/04/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class FarFromTheHole: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        self.layer.borderColor = UIColor.glfBlack40.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        btnContinue.setCorner(color: UIColor.clear.cgColor)
        addSubview(view)
    }
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
}
