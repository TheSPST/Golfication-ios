//
//  CustomScoringViewCtrl.swift
//  Golfication
//
//  Created by Khelfie on 22/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class CustomScoringViewCtrl: UIViewController {

    @IBOutlet weak var manualScoringView: ManualScoring!
    var playerId:String!
    var holeNumber:Int!
    var parNumber:Int!
    var holeOut = false
    var gir : Bool!
    var gameType:Int = 0
    var buttonsArrayForStrokes = [UIButton]()
    var buttonsArrayForFairwayHit = [UIButton]()
    var buttonsArrayForGIR = [UIButton]()
    var buttonsArrayForPutts = [UIButton]()
    var buttonsArrayForChipShot = [UIButton]()
    var buttonsArrayForSandSide = [UIButton]()
    var buttonsArrayForPenalty = [UIButton]()
    var holeWiseShots = NSMutableDictionary()
    var classicScoring = classicMode()
    var isAccept = false

    
    @IBAction func backBtnAction(_ sender: Any) {
        if(isAccept){
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func fairwayHitAction(sender: UIButton!) {
        for btn in buttonsArrayForFairwayHit{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject(btn.currentTitle!, forKey: "fairway" as NSCopying)
            }
        }
    }
    @objc func girAction(sender: UIButton!) {
        for btn in buttonsArrayForGIR{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                if(btn.currentTitle! == "T"){
                    holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
                }
                else{
                    holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
                }
            }
        }
    }

    @objc func puttsAction(sender: UIButton!) {
        for btn in buttonsArrayForPutts{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "putting" as NSCopying)
            }
        }
    }
    @objc func chipShotAction(sender: UIButton!) {
        for btn in buttonsArrayForChipShot{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "chipCount" as NSCopying)
            }
        }
    }
    @objc func sandShotAction(sender: UIButton!) {
        for btn in buttonsArrayForSandSide{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "sandCount" as NSCopying)
            }
        }
    }
    @objc func penaltyShotAction(sender: UIButton!) {
        for btn in buttonsArrayForPenalty{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "penaltyCount" as NSCopying)
            }
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        for btn in buttonsArrayForStrokes{
            if btn.isSelected{
                holeWiseShots.setObject((btn.tag % 10) + 1, forKey: "strokes" as NSCopying)
            }
        }
        if (holeWiseShots.value(forKey: "strokes") as? Int) != nil{
            holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
            holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
            debugPrint(holeWiseShots)
            ref.child("matchData/\(Constants.matchId)/scoring/\(holeNumber!-1)/\(playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            let dataObject = (hole:holeNumber-1,id:playerId,dict:holeWiseShots)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newObject"), object: dataObject)
            dismiss(animated: true, completion: nil)
        }else{
            let emptyAlert = UIAlertController(title: "Alert", message: "Please select strokes for this hole first!", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }

    }
    func updateDictionaryWithValues(dict:NSMutableDictionary)->NSMutableDictionary{
        let dictnary = dict
        let chipShot = dict.value(forKey: "chipCount")
        let sandShot = dict.value(forKey: "sandCount")
        let putting = dict.value(forKey: "putting")
        if((chipShot) != nil) && ((sandShot) != nil) && ((putting) != nil){
            if(chipShot as! Int == 1) && (sandShot as! Int == 0) && (putting as! Int == 1){
                dictnary.setObject(true, forKey: "chipUpDown" as NSCopying)
            }else if(chipShot as! Int > 0) && (((chipShot as! Int) + (putting as! Int)) > 2) && (putting as! Int > 0){
                dictnary.setObject(false, forKey: "chipUpDown" as NSCopying)
            }
            if(chipShot as! Int == 0) && (sandShot as! Int == 1) && (putting as! Int == 1){
                dictnary.setObject(true, forKey: "sandUpDown" as NSCopying)
            }else if(chipShot as! Int > 0) && (((putting as! Int) + (putting as! Int)) > 2) && (putting as! Int > 0){
                dictnary.setObject(false, forKey: "sandUpDown" as NSCopying)
            }
        }
        return dictnary
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            if !(self.manualScoringView.point(inside: position, with: event)){
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialUI()
        self.updateValue()
        
        // Do any additional setup after loading the view.
    }
    func updateValue(){
        if ((classicScoring.chipShot) != nil){
            buttonsArrayForChipShot[classicScoring.chipShot!%10].isSelected = true
            buttonsArrayForChipShot[classicScoring.chipShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.chipShot! % 10), forKey: "chipCount" as NSCopying)
        }
        if ((classicScoring.penaltyShot) != nil){
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].isSelected = true
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.penaltyShot! % 10), forKey: "penaltyCount" as NSCopying)

        }
        if ((classicScoring.sandShot) != nil){
            buttonsArrayForSandSide[classicScoring.sandShot!%10].isSelected = true
            buttonsArrayForSandSide[classicScoring.sandShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.sandShot! % 10), forKey: "sandCount" as NSCopying)

        }
        if ((classicScoring.putting) != nil){
            buttonsArrayForPutts[classicScoring.putting!%10].isSelected = true
            buttonsArrayForPutts[classicScoring.putting!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.putting! % 10), forKey: "putting" as NSCopying)

        }
        if ((classicScoring.gir) != nil){
            if(classicScoring.gir!){
               buttonsArrayForGIR[0].isSelected = true
               buttonsArrayForGIR[0].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
            }
            else{
                buttonsArrayForGIR[1].isSelected = true
                buttonsArrayForGIR[1].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
            }
        }
        if ((classicScoring.fairway) != nil){
            switch (classicScoring.fairway!){
            case "L":
                buttonsArrayForFairwayHit[0].isSelected = true
                buttonsArrayForFairwayHit[0].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject("L", forKey: "fairway" as NSCopying)
                break
            case "H":
                buttonsArrayForFairwayHit[1].isSelected = true
                buttonsArrayForFairwayHit[1].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject("H", forKey: "fairway" as NSCopying)
                break
            default:
                buttonsArrayForFairwayHit[2].isSelected = true
                buttonsArrayForFairwayHit[2].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject("R", forKey: "fairway" as NSCopying)
                break
            }
        }
    }
    func setInitialUI(){
        let gir = ["T","F"]
        manualScoringView.titleLabel.text = "Hole - \(holeNumber!) Par - \(parNumber!)"
        var tag = 0
        for view in manualScoringView.fairwayHitStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(fairwayHitAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForFairwayHit.append((view as! UIButton))
            }
        }
        tag = 10
        for view in manualScoringView.girStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).setTitle(gir[tag%10], for: .normal)
                (view as! UIButton).addTarget(self, action: #selector(girAction), for: .touchUpInside)

                tag += 1
                buttonsArrayForGIR.append((view as! UIButton))
            }
        }
        tag = 20
        for view in manualScoringView.puttsStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(puttsAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPutts.append((view as! UIButton))
            }
        }
        tag = 30
        for view in manualScoringView.chipShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(chipShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForChipShot.append((view as! UIButton))
            }
        }
        tag = 40
        for view in manualScoringView.greenSideSandShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(sandShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForSandSide.append((view as! UIButton))
            }
        }
        tag = 50
        for view in manualScoringView.penalitiesStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(penaltyShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPenalty.append((view as! UIButton))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
