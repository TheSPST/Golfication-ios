//
//  EddieViewRFMap.swift
//  Golfication
//
//  Created by Rishabh Sood on 11/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class EddieViewRFMap: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lockImgView: UIImageView!
    
    @IBOutlet weak var viewPar: UIView!
    @IBOutlet weak var lblParValue: UILabel!
    @IBOutlet weak var viewGIR: UIView!
    @IBOutlet weak var lblGIRValue: UILabel!
    @IBOutlet weak var viewBirdie: UIView!
    @IBOutlet weak var lblBirdieValue: UILabel!
    @IBOutlet weak var viewFairwayHit: UIView!
    @IBOutlet weak var lblFairwayHitValue: UILabel!
    
    @IBOutlet weak var btnUnlockEddie: UIButton!
    @IBOutlet weak var lblPar: UILabel!
    @IBOutlet weak var lblGIR: UILabel!
    @IBOutlet weak var lblBirdie: UILabel!
    @IBOutlet weak var lblFairwayHit: UILabel!
    
    @IBOutlet weak var byEddieView: UIView!
    @IBOutlet weak var unlockEddieView: UIView!
    
    
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
        self.layer.borderColor = UIColor.glfWarmGrey.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        addSubview(view)
        unlockEddieView.layer.cornerRadius = 12.5
        byEddieView.isHidden = !Constants.isProMode
        unlockEddieView.isHidden = Constants.isProMode
        lockImgView.isHidden = Constants.isProMode
        viewPar.layer.cornerRadius = 5.0
        viewBirdie.layer.cornerRadius = 5.0
        viewFairwayHit.layer.cornerRadius = 5.0
        viewGIR.layer.cornerRadius = 5.0

        if !Constants.isProMode{
            lblParValue.text = "--"
            lblGIRValue.text = "--"
            lblBirdieValue.text = "--"
            lblFairwayHitValue.text = "--"
            
            lblGIRValue.textColor = UIColor.glfStackBackColor
            lblParValue.textColor = UIColor.glfStackBackColor
            lblBirdieValue.textColor = UIColor.glfStackBackColor
            lblFairwayHitValue.textColor = UIColor.glfStackBackColor
            
            lblGIR.textColor = UIColor.glfStackBackColor
            lblPar.textColor = UIColor.glfStackBackColor
            lblBirdie.textColor = UIColor.glfStackBackColor
            lblFairwayHit.textColor = UIColor.glfStackBackColor
            
            viewPar.setCornerView(color: UIColor.glfStackBackColor.cgColor)
            viewBirdie.setCornerView(color: UIColor.glfStackBackColor.cgColor)
            viewFairwayHit.setCornerView(color: UIColor.glfStackBackColor.cgColor)
            viewGIR.setCornerView(color: UIColor.glfStackBackColor.cgColor)
            
        }else{
            lblGIRValue.textColor = UIColor.glfWhite
            lblParValue.textColor = UIColor.glfWhite
            lblBirdieValue.textColor = UIColor.glfWhite
            lblFairwayHitValue.textColor = UIColor.glfWhite
            
            lblGIR.textColor = UIColor.glfWhite
            lblPar.textColor = UIColor.glfWhite
            lblBirdie.textColor = UIColor.glfWhite
            lblFairwayHit.textColor = UIColor.glfWhite
            
            viewPar.setCornerView(color: UIColor.glfWhite.cgColor)
            viewBirdie.setCornerView(color: UIColor.glfWhite.cgColor)
            viewFairwayHit.setCornerView(color: UIColor.glfWhite.cgColor)
            viewGIR.setCornerView(color: UIColor.glfWhite.cgColor)
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
            fillViewLayer(per: 1.0-fhPer, layer: viewFairwayHit.layer)
            fillViewLayer(per: 1.0-girPer, layer: viewGIR.layer)
            fillViewLayer(per: 1.0-birdiePer, layer: viewBirdie.layer)
            fillViewLayer(per: 1.0-parPer, layer: viewPar.layer)
            lblFairwayHitValue.text = "\(achievedGoal.fairwayHit)/\(targetGoal.fairwayHit)"
            lblGIRValue.text = "\(achievedGoal.gir)/\(targetGoal.gir)"
            lblBirdieValue.text = "\(achievedGoal.Birdie)/\(targetGoal.Birdie)"
            lblParValue.text = "\(achievedGoal.par)/\(targetGoal.par)"
        }
    }
    func fillViewLayer(per:Double,layer:CALayer){
        if ((layer.sublayers?[0] as? CAGradientLayer) != nil) {
            layer.sublayers?.remove(at: 0)
        }
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        let color = UIColor.glfFlatBlue.cgColor
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, color, color]
        gradient.locations = [NSNumber(value: 0.0), NSNumber(value: per), NSNumber(value: per), NSNumber(value: 1.0)]
        gradient.cornerRadius = 5.0
        layer.insertSublayer(gradient, at: 0)
    }
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
}
