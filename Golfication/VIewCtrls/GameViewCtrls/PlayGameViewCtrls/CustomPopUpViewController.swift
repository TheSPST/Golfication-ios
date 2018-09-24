//
//  CustomPopUpViewController.swift
//  Golfication
//
//  Created by Khelfie on 14/02/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
var isAdvanced = true
class CustomPopUpViewController: UIViewController {
    
    var players = NSMutableArray()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var isInfo : Bool!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var popUpView: CardView!
    @IBOutlet weak var popUpStackView: UIStackView!
    @IBOutlet weak var advancedScoringCardView: UIView!
    @IBOutlet weak var classicScoringCardView: UIView!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblAlwaysChoose: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBAction func btnCloseAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnActionContinue(_ sender: Any) {
        if(!isInfo){
            if(self.btnCheckBox.isSelected){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gameTypePopUp" :false] as [AnyHashable:Any])
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Advanced"), object: isAdvanced)
            dismiss(animated: true, completion: nil)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MappingRequest"), object: isAdvanced)
            dismiss(animated: true, completion: nil)
        }

    }
    @IBAction func btnActionCheckBox(_ sender: Any) {
        if(self.btnCheckBox.isSelected){
            self.btnCheckBox.isSelected = false
            self.btnCheckBox.setBackgroundImage(nil, for: .normal)
        }
        else{
            self.btnCheckBox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
            self.btnCheckBox.isSelected = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let originalImage =  #imageLiteral(resourceName: "map_arrow")
//        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//        btnClose.setBackgroundImage(backBtnImage, for: .normal)
//        btnClose.tintColor = UIColor.glfFlatBlue
        if(!isInfo){
            self.setupInitialUI()
        }
        else{
            self.setupAnotherUI()
        }

        // Do any additional setup after loading the view.
    }
    func setupInitialUI(){
        
        self.btnCheckBox.isSelected = true
        self.btnCheckBox.setCorner(color: UIColor.glfWarmGrey.cgColor)
        self.btnCheckBox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
        self.btnCheckBox.tintColor = UIColor.clear
        
        self.advancedScoringCardView.isUserInteractionEnabled = true
        self.classicScoringCardView.isUserInteractionEnabled = true

        let tapAdvanced = UITapGestureRecognizer(target: self, action: #selector(tapAdvanced(tap:)))
        self.advancedScoringCardView.addGestureRecognizer(tapAdvanced)
        let tapClassic = UITapGestureRecognizer(target: self, action: #selector(tapClassic(tap:)))
        self.classicScoringCardView.addGestureRecognizer(tapClassic)
        
        self.tapAdvanced(tap: tapAdvanced)
    }
    
    func setupAnotherUI(){
        self.btnCheckBox.isHidden = true
//        self.lblTitle.isHidden = true
        self.lblAlwaysChoose.isHidden = true
        self.btnContinue.setTitle("Request Advanced Mapping", for: .normal)
        self.advancedScoringCardView.isUserInteractionEnabled = false
        self.classicScoringCardView.isUserInteractionEnabled = false
        self.lblTitle.text = "Request Advanced Mapping"
        
        self.changeColor(color: UIColor.glfBlack50,  borderWidth: 1.0, borderColor: UIColor.lightGray, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.advancedScoringCardView)
        self.changeColor(color: UIColor.glfBluegreen, borderWidth: 1.0, borderColor: UIColor.glfGreenBlue, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.classicScoringCardView)
        
        
    }
    @objc func tapAdvanced(tap: UITapGestureRecognizer) {
        isAdvanced = true
        self.changeColor(color: UIColor.glfBluegreen,borderWidth: 1.0, borderColor: UIColor.glfGreenBlue, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.advancedScoringCardView)
        self.changeColor(color: UIColor.glfBlack75, borderWidth: 1.0, borderColor: UIColor.lightGray, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.classicScoringCardView)
    }
    
    @objc func tapClassic(tap: UITapGestureRecognizer) {
        isAdvanced = false
        self.changeColor(color: UIColor.glfBlack75,borderWidth: 1.0, borderColor: UIColor.lightGray, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.advancedScoringCardView)
        self.changeColor(color: UIColor.glfBluegreen,borderWidth: 1.0, borderColor: UIColor.glfGreenBlue, cornerRadius: 3.0 ,clipsToBounds:false, cardView: self.classicScoringCardView)
    }
    

    func changeColor(color:UIColor,borderWidth:CGFloat, borderColor:UIColor, cornerRadius:CGFloat,clipsToBounds:Bool, cardView:UIView){
        cardView.layer.borderWidth = borderWidth
        cardView.layer.borderColor = borderColor.cgColor
        cardView.layer.cornerRadius = cornerRadius
        cardView.clipsToBounds = clipsToBounds
        
        for view in cardView.subviews{
            if view.isKind(of: UILabel.self){
                (view as! UILabel).textColor = color
            }
            else if view.isKind(of: UIStackView.self){
                for label in (view as! UIStackView).subviews{
                    (label as! UILabel).textColor = color
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
