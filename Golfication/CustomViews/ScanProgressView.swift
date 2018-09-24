//
//  ScanProgressView.swift
//  Golfication
//
//  Created by Rishabh Sood on 17/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class ScanProgressView: UIView {

    @IBOutlet weak var scanningSubView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ScanProgressView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    func show(navItem: UINavigationItem) {
        self.isHidden = false
        
        scanningSubView.isHidden = false
//        progressView.startAnimating()
        navItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hide(navItem: UINavigationItem) {
        self.isHidden = true
        
        scanningSubView.isHidden = true
//        progressView.stopAnimating()
        navItem.rightBarButtonItem?.isEnabled = true
    }
}
