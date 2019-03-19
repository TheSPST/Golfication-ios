//
//  SuggestionView.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
class SuggestionView: UIView {

    @IBOutlet weak var lblElev: UILabel!
    @IBOutlet weak var btnElev: UIButton!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblDirection: UILabel!
    @IBOutlet weak var lblElevDist: UILabel!
    @IBOutlet weak var lockedImgView: UIImageView!
    
    func setAllData(club:String,dist:Int,elevDis:String){
        lblClub.text = club
        lblDistance.text = "\(dist)"
        if Constants.isProMode{
            lblElev.text = elevDis
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setViewForOffCourse(){
        lockedImgView.isHidden = true
        lblDirection.isHidden = true
    }
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        lockedImgView.isHidden = Constants.isProMode
    }
    func autoresize(){
        let width = lblClub.frame.maxX > btnElev.frame.maxX ? lblClub.frame.maxX:btnElev.frame.maxX
        self.frame.size = CGSize(width: width, height: 65)
    }
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
