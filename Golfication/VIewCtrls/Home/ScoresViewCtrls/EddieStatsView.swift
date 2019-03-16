//
//  EddieStatsView.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class EddieStatsView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var eddieImageVIew: UIImageView!

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
        self.addSubview(view)
        
        btnView.layer.cornerRadius = 5.0
        btnView.layer.borderWidth = 1.0
        btnView.layer.borderColor = UIColor.glfBlack75.cgColor
        btnView.layer.masksToBounds = true
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}
