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
    
    func setAllData(club:String,dist:Int){
        lblClub.text = club
        lblDistance.text = "\(dist)"
    }
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
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
