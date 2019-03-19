//
//  WindNotesView.swift
//  Golfication
//
//  Created by Rishabh Sood on 16/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class WindNotesView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var imgWind: UIImageView!
    @IBOutlet weak var imgNotes: UIImageView!
    @IBOutlet weak var lblWind: UILabel!
    @IBOutlet weak var btnWindLock: UIButton!
    @IBOutlet weak var btnNotesLock: UIButton!
    
    @IBOutlet weak var btnNotesUnlock: UIButton!
    @IBOutlet weak var btnWindUnlock: UIButton!
    @IBOutlet weak var midLblLine: UILabel!
    @IBOutlet weak var windStackView: UIStackView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setViewForOffCourse(){
        midLblLine.isHidden = true
        windStackView.isHidden = true
        view.bounds.size = CGSize(width: view.bounds.width, height: view.bounds.height/2)
        btnWindLock.isHidden = true
    }
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        imgWind.tintImageColor(color: UIColor.glfYellow)
        imgNotes.tintImageColor(color: UIColor.glfYellow)
        
        let originalImage1 = BackgroundMapStats.resizeImage(image: #imageLiteral(resourceName: "locked_1"), targetSize: CGSize(width:5,height:5))
        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        btnNotesLock.setImage(backBtnImage1, for: .normal)
        btnNotesLock.setCornerWithRadius(color: UIColor.clear.cgColor, radius: 5)
        btnNotesLock.tintColor = UIColor.glfBlack
        
        btnWindLock.setImage(backBtnImage1, for: .normal)
        btnWindLock.setCornerWithRadius(color: UIColor.clear.cgColor, radius: 5)
        btnWindLock.tintColor = UIColor.glfBlack
        btnNotesLock.isHidden = Constants.isProMode
        btnWindLock.isHidden = Constants.isProMode
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }}
