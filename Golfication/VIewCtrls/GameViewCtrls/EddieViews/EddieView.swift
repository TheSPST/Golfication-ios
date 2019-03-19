//
//  EddieView.swift
//  Golfication
//
//  Created by Rishabh Sood on 08/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable final class EddieView:UIView{
    
    @IBOutlet weak var eddieImgView: UIImageView!
    var gradient = CAGradientLayer()
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var shadowOffsetWidth: Int = 1
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.15

    @IBOutlet weak var stackViewLbls: UIStackView!
    @IBOutlet weak var lblGoals: UILabel!
    @IBOutlet weak var viewUnlockEddie: UIView!
    @IBOutlet weak var viewEddieAvailable: UIView!
    @IBOutlet weak var imgViewLocked: UIImageView!
    @IBOutlet weak var viewPar : UIView!
    @IBOutlet weak var viewGIR : UIView!
    @IBOutlet weak var viewBirdie : UIView!
    @IBOutlet weak var viewFH : UIView!
    
    @IBOutlet weak var btnUnlockEddie: UIButton!
    @IBOutlet weak var lblPar : UILabel!
    @IBOutlet weak var lblGIR : UILabel!
    @IBOutlet weak var lblBirdie : UILabel!
    @IBOutlet weak var lblFH : UILabel!
    @IBOutlet weak var view: UIView!

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
        eddieImgView.setCircle(frame: eddieImgView.frame)
        viewPar.setCornerView(color: UIColor.glfBlack5.cgColor)
        viewGIR.setCornerView(color: UIColor.glfBlack5.cgColor)
        viewBirdie.setCornerView(color: UIColor.glfBlack5.cgColor)
        viewFH.setCornerView(color: UIColor.glfBlack5.cgColor)
        viewPar.layer.cornerRadius = 5.0
        viewGIR.layer.cornerRadius = 5.0
        viewBirdie.layer.cornerRadius = 5.0
        viewFH.layer.cornerRadius = 5.0
        
        addSubview(view)
        viewUnlockEddie.layer.cornerRadius = 12.5
        imgViewLocked.isHidden = Constants.isProMode
        viewUnlockEddie.isHidden = Constants.isProMode
        viewEddieAvailable.isHidden = !Constants.isProMode
        imgViewLocked.tintImageColor(color: UIColor.glfWarmGrey)
        imgViewLocked.tintColor = UIColor.glfWarmGrey
        if !Constants.isProMode{
            self.lblPar.text = "-"
            self.lblBirdie.text = "-"
            self.lblGIR.text = "-"
            self.lblFH.text = "-"
            viewPar.backgroundColor = UIColor.glfStackBackColor
            viewGIR.backgroundColor = UIColor.glfStackBackColor
            viewBirdie.backgroundColor = UIColor.glfStackBackColor
            viewFH.backgroundColor = UIColor.glfStackBackColor
        }else{
            self.lblPar.textColor = UIColor.glfBlack
            self.lblBirdie.textColor = UIColor.glfBlack
            self.lblGIR.textColor = UIColor.glfBlack
            self.lblFH.textColor = UIColor.glfBlack
            for lbl in stackViewLbls.subviews{
                if let label = lbl as? UILabel{
                    label.textColor = UIColor.glfBlack
                }
            }
        }
    }
    
    func updateGoalView(achievedGoal:Goal,targetGoal:Goal){
        if Constants.isProMode{
            var fhPer = Double(achievedGoal.fairwayHit)/Double(targetGoal.fairwayHit)
            var girPer = Double(achievedGoal.gir)/Double(targetGoal.gir)
            var birdiePer = Double(achievedGoal.Birdie)/Double(targetGoal.Birdie)
            var parPer = Double(achievedGoal.par)/Double(targetGoal.par)
            
            if achievedGoal.fairwayHit >= targetGoal.fairwayHit{
                fhPer = 1.0
            }
            if achievedGoal.gir >= targetGoal.gir{
                girPer = 1.0
            }
            if achievedGoal.Birdie >= targetGoal.Birdie{
                birdiePer = 1.0
            }
            if achievedGoal.par >= targetGoal.par{
                parPer = 1.0
            }
            fillViewLayer(per: 1.0-fhPer, layer: self.viewFH.layer)
            fillViewLayer(per: 1.0-girPer, layer: self.viewGIR.layer)
            fillViewLayer(per: 1.0-birdiePer, layer: self.viewBirdie.layer)
            fillViewLayer(per: 1.0-parPer, layer: self.viewPar.layer)
            lblFH.text = "\(achievedGoal.fairwayHit)/\(targetGoal.fairwayHit)"
            lblGIR.text = "\(achievedGoal.gir)/\(targetGoal.gir)"
            lblBirdie.text = "\(achievedGoal.Birdie)/\(targetGoal.Birdie)"
            lblPar.text = "\(achievedGoal.par)/\(targetGoal.par)"
        }
    }
    func fillViewLayer(per:Double,layer:CALayer){
        if ((layer.sublayers?[0] as? CAGradientLayer) != nil) {
           layer.sublayers?.remove(at: 0)
        }
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        let color = UIColor(red: 255.0/255.0, green: 166.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0).cgColor
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, color, color]
        gradient.locations = [NSNumber(value: 0.0), NSNumber(value: per), NSNumber(value: per), NSNumber(value: 1.0)]
        layer.insertSublayer(gradient, at: 0)
    }
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
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
    func setGradientColor(topColor: UIColor, bottomColor: UIColor) {
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
    }
}
