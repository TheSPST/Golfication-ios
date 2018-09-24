//
//  ManualScoring.swift
//  Golfication
//
//  Created by Khelfie on 22/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class ManualScoring: UIView {

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var strokesStackView: UIStackView!
//    @IBOutlet weak var strokesStackView2: UIStackView!

    @IBOutlet weak var fairwayHitStackView: UIStackView!
    @IBOutlet weak var girStackView: UIStackView!
    @IBOutlet weak var puttsStackView: UIStackView!
    @IBOutlet weak var chipShotStackView: UIStackView!
    @IBOutlet weak var greenSideSandShotStackView: UIStackView!
    @IBOutlet weak var penalitiesStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var shadowOffsetWidth: Int = 1
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.15
    @IBOutlet weak var strokesStackViewComman: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)


    }
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
