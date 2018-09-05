//
//  ScoreBoardForInputViewCtrl.swift
//  Golfication
//
//  Created by Khelfie on 23/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Firebase
import ActionSheetPicker_3_0
import FirebaseAnalytics

class CellButton : UIButton{
    var userData:String?
    override init(frame: CGRect) {
        self.userData = ""
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.userData = ""
        super.init(coder: aDecoder)
    }
}
class ScoreBoardForInputViewCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var fairwayHitStackView: UIStackView!
    @IBOutlet weak var girStackView: UIStackView!
    @IBOutlet weak var puttsStackView: UIStackView!
    @IBOutlet weak var chipShotStackView: UIStackView!
    @IBOutlet weak var greenSideSandShotStackView: UIStackView!
    @IBOutlet weak var penalitiesStackView: UIStackView!
    @IBOutlet weak var scoringView: UIView!
    
    @IBOutlet weak var scorePopView: UIView!
    @IBOutlet weak var btnDetailScoring: UIButton!
    @IBOutlet weak var btnExpendScore: UIButton!
    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    
    @IBOutlet weak var scoreSV: UIStackView!
    @IBOutlet weak var detailScoreSV: UIStackView!
    @IBOutlet weak var scoreSecondSV: UIStackView!
    
    @IBOutlet weak var stackViewStrokes1: UIStackView!
    @IBOutlet weak var stackViewStrokes2: UIStackView!
    @IBOutlet weak var stackViewStrokes3: UIStackView!
    @IBOutlet weak var stackViewStrokes4: UIStackView!
    
    @IBOutlet weak var lblPlayerNameDSV: UILabel!
    @IBOutlet weak var lblPlayerNameSSV: UILabel!
    
    @IBOutlet weak var lblHolePar: UILabel!

    var progressView = SDLoader()
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    //@IBOutlet weak var btnDetailsScoringConstraints: NSLayoutConstraint!
    
    let bView = BottomViewInScore()

    @IBAction func btnMenuAction(_ sender: Any) {
        self.holeOutforAppsFlyer = self.checkHoleOutZero(playerId: Auth.auth().currentUser!.uid)
        ActionSheetStringPicker.show(withTitle: "Menu", rows: ["Finish Round","Restart Round","End Round"], initialSelection: 0, doneBlock: { (picker, value, index) in
            if value != 1{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: NewGameVC.self) {
                        _ =  self.navigationController!.popToViewController(controller, animated: !self.isAcceptInvite)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EndRound"), object: nil)
                        })
                        break
                    }
                }
            }else{
                let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer)/\(self.scoreData.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
                emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
                    self.progressView.show(atView: self.view, navItem: self.navigationItem)
                    self.resetScoreNodeForMe()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.getScoreFromMatchDataFirebase()
                        self.progressView.hide(navItem: self.navigationItem)
                        self.holeOutforAppsFlyer = 0
                    })
                }))
                emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(emptyAlert, animated: true, completion: nil)

            }
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        

    }
    func checkHoleOutZero(playerId:String) -> Int{
        // --------------------------- Check If User has not played game at all ------------------------
        var myVal: Int = 0
        for i in 0..<self.scoreData.count{
            for dataDict in self.scoreData[i].players{
                for (key,value) in dataDict{
                    if let dic = value as? NSDictionary{
                        if dic.value(forKey: "holeOut") as! Bool == true{
                            if(key as? String == playerId){
                                for (key,value) in value as! NSMutableDictionary
                                {
                                    if (key as! String == "holeOut" && value as! Bool){
                                        let countDic = NSMutableDictionary()
                                        countDic.setObject(i, forKey: "HoleIndex" as NSCopying)
                                        countDic.setObject(dic.count, forKey: "DetailCount" as NSCopying)
                                        myVal = myVal + (value as! Int)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return myVal
    }
    func resetScoreNodeForMe(){
        for i in 0..<self.scoreData.count{
            let player = NSMutableDictionary()
            for j in 0..<self.scoreData[0].players.count{
                let id = (self.scoreData[0].players[j]).allKeys[0] as! String
                if(id == Auth.auth().currentUser?.uid){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: id as NSCopying)
                    ref.child("matchData/\(matchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoreData[i].players[j].addEntries(from: playerData)
                }
            }
        }
    }
    var buttonsArrayForStrokes = [UIButton]()
    var buttonsArrayForFairwayHit = [UIButton]()
    var buttonsArrayForGIR = [UIButton]()
    var buttonsArrayForPutts = [UIButton]()
    var buttonsArrayForChipShot = [UIButton]()
    var buttonsArrayForSandSide = [UIButton]()
    var buttonsArrayForPenalty = [UIButton]()
    var holeWiseShots = NSMutableDictionary()
    var classicScoring = classicMode()
    var playerId : String!
    var index = 0
    var isAcceptInvite = false
    @IBOutlet weak var scoringSuperView: UIView!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    var playerData = NSMutableArray()
    var isAccept = false
    var scrollView: UIScrollView!
    var tblView: UITableView!
    let kHeaderSectionTag: Int = 6900
    var matchDataDict = NSMutableDictionary()
    var menueTableView: UITableView!
    var isContinue = false
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var holeOutforAppsFlyer = Int()

    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    
    var plyerViseScore = [[(gir:Bool,fairwayHit:String)]]()
    var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    
    let padding: CGFloat = 10.0
    let width: CGFloat = 50.0
    
    @IBAction func detailScoreAction(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.scorePopView.isHidden = false
        }
        else{
            sender.tag = 0
            self.scorePopView.isHidden = true
        }
        self.view.layoutIfNeeded()

    }
    
    @IBAction func backBtnAction(_ sender: Any) {
//        for controller in self.navigationController!.viewControllers as Array {
//            if controller.isKind(of: NewGameVC.self) {
//                _ =  self.navigationController!.popToViewController(controller, animated: !self.isAcceptInvite)
//                break
//            }
//        }
        self.navigationController?.pop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateView"), object: nil)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").removeAllObservers()
    }
    func scrollViewDidScroll(_ scrollView1: UIScrollView){
        if (!(scrollView1.contentOffset.x>0 || scrollView1.contentOffset.x<0)) && scrollView1 == self.menueTableView {
            tblView.isScrollEnabled = true
            
            self.scrollView = (scrollView1 == self.menueTableView) ? self.tblView : scrollView1
            self.scrollView.setContentOffset(scrollView1.contentOffset, animated: false)
        }
        else
        {
            tblView.isScrollEnabled = false
        }
    }

    @IBAction func btnActionScore(_ sender: UIButton) {
        if let str = holeWiseShots.value(forKey: "strokes") as? Int{
            self.detailScoreSV.isHidden = true
            if (str > self.scoreData[self.index].par+2){
                self.scoreSV.isHidden = false
                self.scoreSecondSV.isHidden = false
                self.btnExpendScore.isHidden = true
                for btn in buttonsArrayForStrokes{
                    btn.setTitleColor(UIColor.glfWhite, for: .normal)
                }
                buttonsArrayForStrokes[str-1].setTitleColor(UIColor.glfBluegreen, for: .normal)
            }else{
                self.scoreSV.isHidden = false
                self.stackViewStrokes1.isHidden = false
                self.scoreSecondSV.isHidden = true
                self.btnExpendScore.isHidden = false
                var newI = self.scoreData[self.index].par - 2
                for btn in self.stackViewStrokes1.arrangedSubviews{
                    (btn as! UIButton).setTitleColor(UIColor.glfWhite, for: .normal)
                    updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[self.index].par), btn: btn as! UIButton,color:UIColor.white)
                    newI += 1
                }
                if let btn = self.stackViewStrokes1.arrangedSubviews[str-self.scoreData[self.index].par+2] as? UIButton{
                    updateStrokesButtonWithoutStrokes(strokes: (str-self.scoreData[self.index].par), btn: btn,color:UIColor.glfBluegreen)
                    btn.setTitleColor(UIColor.glfBluegreen, for: .normal)
                }
            }
        }
        
    }
    @IBAction func expendScoreAction(_ sender: Any) {
        scoreSecondSV.isHidden = false
        btnExpendScore.isHidden = true
        for btn in buttonsArrayForStrokes{
            btn.setTitle("\(btn.tag)", for: .normal)
            btn.layer.borderWidth = 0
            for lay in btn.layer.sublayers!{
                lay.borderWidth = 0
            }
        }
    }
    func getScoreFromMatchDataFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)/") { (snapshot) in
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            self.scoreData.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                matchDataDic = matchDict as! NSMutableDictionary
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,_) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                        }
                    }
                    if (keyData == "scoring"){
                        scoreArray = (value as! NSArray)
                    }
                }
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = value as! Int
                        }else{
                            let dict = NSMutableDictionary()
                            dict.setObject(value, forKey: key as! String as NSCopying)
                            playersArray.append(dict)
                        }
                    }
                    self.scoreData.append((hole: i, par:par,players:playersArray))
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
                self.menueTableView.reloadData()
                self.tblView.reloadData()
            })
        }
    }
    func initilizeScoreNode(){
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
        
        self.sectionItems = []
        self.sectionNames = []
        for i in 0..<self.scoreData.count{
            let player = NSMutableDictionary()
            for j in 0..<playerData.count{
                let data = playerData[j] as! NSMutableDictionary
                let playerScore = NSMutableDictionary()
                let playerDataHole = ["holeOut":false]
                player.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                playerScore.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                self.scoreData[i].players.append(playerScore)
            }
            player.setObject(self.scoreData[i].par, forKey: "par" as NSCopying)
            holeArray.append(player)
        }
        scoring.setObject(holeArray, forKey: "scoring" as NSCopying)
        ref.child("matchData/\(matchId)/").updateChildValues(scoring as! [AnyHashable : Any])
        
        self.title = "Your Scorecard"
        self.view.backgroundColor = UIColor(rgb: 0xF8F8F7)
        
        let tempDic = NSMutableDictionary()
        tempDic.setObject("parId", forKey: "id" as NSCopying)
        tempDic.setObject("Par", forKey: "name" as NSCopying)
        sectionNames.insert(tempDic, at: 0)
        
        for i in 0..<playerData.count{
            
            sectionNames.insert(playerData[i], at: i+1)
        }
        
        
        
        sectionItems = [[],["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        if mode == 1{
        sectionItems = [[],["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        }
        menueTableView =  UITableView(frame: CGRect(x: 0, y: 64+10, width: 180, height: self.view.frame.size.height-(64+10)), style: .grouped)
        menueTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenueCell")
        
        menueTableView.dataSource = self
        menueTableView.delegate = self
        menueTableView.tag = 0
        menueTableView.backgroundColor = UIColor.clear
        
        menueTableView.separatorStyle = .none
        self.menueTableView!.tableFooterView = UIView()
        view.addSubview(menueTableView)
        
        scrollView =  UIScrollView(frame: CGRect(x: menueTableView.frame.origin.x + menueTableView.frame.size.width, y: menueTableView.frame.origin.y, width: view.frame.size.width - menueTableView.frame.size.width-2, height: menueTableView.frame.size.height))
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        var tableWidth = CGFloat()
        for i in 0..<scoreData.count{
            
            tableWidth = 10+(width+padding)*CGFloat(i+2)
        }
        tblView =  UITableView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: scrollView.frame.size.height), style: .grouped)
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        tblView.dataSource = self
        tblView.delegate = self
        tblView.tag = 1
        tblView.backgroundColor = UIColor.clear
        tblView.separatorColor = UIColor(rgb: 0x01AD8C)
        tblView.alwaysBounceVertical = false
        tblView.tableFooterView = UIView()
        scrollView.addSubview(tblView)

        scrollView.contentSize = CGSize(width: tblView.frame.size.width, height: tblView.frame.size.height)
    }
    //MARK: - Setup Initital UI
    func setInitialUI(){
        var tag = 0
        for view in fairwayHitStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.fairwayHitAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForFairwayHit.append((view as! UIButton))
            }
        }
        tag = 10
        for view in girStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.girAction), for: .touchUpInside)
                
                tag += 1
                buttonsArrayForGIR.append((view as! UIButton))
            }
        }
        tag = 20
        for view in puttsStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.puttsAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPutts.append((view as! UIButton))
            }
        }
        tag = 30
        for view in chipShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.chipShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForChipShot.append((view as! UIButton))
            }
        }
        tag = 40
        for view in greenSideSandShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.sandShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForSandSide.append((view as! UIButton))
            }
        }
        tag = 50
        for view in penalitiesStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.penaltyShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPenalty.append((view as! UIButton))
            }
        }
        // Setup Stroks buttons
        buttonsArrayForStrokes.removeAll()
        var i = 1
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes2.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes3.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes4.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
    }
    @objc func strokesAction(sender: UIButton!){
        let title = sender.currentTitle
        self.holeWiseShots.setObject(Int(title!)!, forKey: "strokes" as NSCopying)
        self.holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(["strokes":Int(title!)!] as [AnyHashable : Any])
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(["holeOut":true] as [AnyHashable : Any])
        self.setHoleShotDetails(par:self.scoreData[self.index].par,shots:Int(title!)!)
        self.btnScore.setTitle("\(title!)", for: .normal)
        self.scoreSV.isHidden = true
        self.detailScoreSV.isHidden = false
        //btnDetailsScoringConstraints.constant = 16
        updateScoreData()
    }
    func updateScoreData(){
        var i = 0
        for data in scoreData[self.index].players{
            let keys = data.allKeys as! [String]
            if keys.first == self.playerId{
                if(holeWiseShots.value(forKey: "holeOut") == nil){
                    holeWiseShots.setValue(false, forKey: "holeOut")
                }
                let dict = NSMutableDictionary()
                dict.setValue(holeWiseShots, forKey: self.playerId)
                scoreData[self.index].players[i] = dict
            }
            i += 1
        }
    }
    func updateValue(){
        for i in 0..<buttonsArrayForChipShot.count{
            buttonsArrayForChipShot[i].isSelected = false
            buttonsArrayForChipShot[i].isHidden = false
            buttonsArrayForChipShot[i].backgroundColor = UIColor.clear
            if ((classicScoring.chipShot) != nil){
                buttonsArrayForChipShot[i].isHidden = true
            }
        }
        if ((classicScoring.chipShot) != nil){
            buttonsArrayForChipShot[classicScoring.chipShot!%10].isSelected = true
            buttonsArrayForChipShot[classicScoring.chipShot!%10].isHidden = false
            buttonsArrayForChipShot[classicScoring.chipShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.chipShot! % 10), forKey: "chipCount" as NSCopying)
        }
        for i in 0..<buttonsArrayForPenalty.count{
            buttonsArrayForPenalty[i].isSelected = false
            buttonsArrayForPenalty[i].isHidden = false
            buttonsArrayForPenalty[i].backgroundColor = UIColor.clear
            if ((classicScoring.penaltyShot) != nil){
                buttonsArrayForPenalty[i].isHidden = true
            }
        }
        if ((classicScoring.penaltyShot) != nil){
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].isSelected = true
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].isHidden = false
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.penaltyShot! % 10), forKey: "penaltyCount" as NSCopying)
            
        }
        for i in 0..<buttonsArrayForSandSide.count{
            buttonsArrayForSandSide[i].isSelected = false
            buttonsArrayForSandSide[i].isHidden = false
            buttonsArrayForSandSide[i].backgroundColor = UIColor.clear
            if ((classicScoring.sandShot) != nil){
                buttonsArrayForSandSide[i].isHidden = true
            }
            if ((classicScoring.sandShot) != nil){
                buttonsArrayForSandSide[classicScoring.sandShot!%10].isSelected = true
                buttonsArrayForSandSide[classicScoring.sandShot!%10].isHidden = false
                buttonsArrayForSandSide[classicScoring.sandShot!%10].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((classicScoring.sandShot! % 10), forKey: "sandCount" as NSCopying)
            }
        }
        for i in 0..<buttonsArrayForPutts.count{
            buttonsArrayForPutts[i].isSelected = false
            buttonsArrayForPutts[i].isHidden = false
            buttonsArrayForPutts[i].backgroundColor = UIColor.clear
            if ((classicScoring.putting) != nil){
                buttonsArrayForPutts[i].isHidden = true
            }
            if ((classicScoring.putting) != nil){
                buttonsArrayForPutts[classicScoring.putting!%10].isHidden = false
                buttonsArrayForPutts[classicScoring.putting!%10].isSelected = true
                buttonsArrayForPutts[classicScoring.putting!%10].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((classicScoring.putting! % 10), forKey: "putting" as NSCopying)
            }
        }
        
        buttonsArrayForGIR[0].isSelected = false
        buttonsArrayForGIR[1].isSelected = false
        buttonsArrayForGIR[0].isHidden = false
        buttonsArrayForGIR[1].isHidden = false
        buttonsArrayForGIR[0].backgroundColor = UIColor.clear
        buttonsArrayForGIR[1].backgroundColor = UIColor.clear
        buttonsArrayForGIR[0].imageView?.tintImageColor(color: UIColor.glfWarmGrey)
        buttonsArrayForGIR[1].imageView?.tintImageColor(color: UIColor.glfWarmGrey)
        buttonsArrayForGIR[0].tintColor = UIColor.glfWarmGrey
        buttonsArrayForGIR[1].tintColor = UIColor.glfWarmGrey
        if ((classicScoring.gir) != nil){
            buttonsArrayForGIR[0].isHidden = true
            buttonsArrayForGIR[1].isHidden = true
        }
        if ((classicScoring.gir) != nil){
            if(classicScoring.gir!){
                buttonsArrayForGIR[0].isSelected = true
                buttonsArrayForGIR[0].isHidden = false
                buttonsArrayForGIR[0].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForGIR[0].imageView?.tintImageColor(color: UIColor.glfWhite)
                buttonsArrayForGIR[0].tintColor = UIColor.glfWhite
                holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
            }
            else{
                buttonsArrayForGIR[1].isSelected = true
                buttonsArrayForGIR[1].isHidden = false
                buttonsArrayForGIR[1].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForGIR[1].imageView?.tintImageColor(color: UIColor.glfWhite)
                buttonsArrayForGIR[1].tintColor = UIColor.glfWhite
                
                holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
            }
        }
        
        for btn in buttonsArrayForFairwayHit{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            btn.isHidden = false
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            if ((classicScoring.fairway) != nil){
                btn.isHidden = true
            }
        }
        if ((classicScoring.fairway) != nil){
            switch (classicScoring.fairway!){
            case "L":
                buttonsArrayForFairwayHit[0].isSelected = true
                buttonsArrayForFairwayHit[0].isHidden = false
                buttonsArrayForFairwayHit[0].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[0].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("L", forKey: "fairway" as NSCopying)
                break
            case "H":
                buttonsArrayForFairwayHit[1].isSelected = true
                buttonsArrayForFairwayHit[1].isHidden = false
                buttonsArrayForFairwayHit[1].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[1].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("H", forKey: "fairway" as NSCopying)
                break
            default:
                buttonsArrayForFairwayHit[2].isSelected = true
                buttonsArrayForFairwayHit[2].isHidden = false
                buttonsArrayForFairwayHit[2].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[2].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("R", forKey: "fairway" as NSCopying)
                break
            }
        }
        //btnDetailsScoringConstraints.constant = 0
        if classicScoring.holeOut != nil && classicScoring.holeOut!{
            self.setHoleShotDetails(par:self.scoreData[self.index].par,shots:classicScoring.strokesCount!)
            self.btnScore.setTitle("\(classicScoring.strokesCount!)", for: .normal)
            self.scoreSV.isHidden = true
            self.detailScoreSV.isHidden = false
            //btnDetailsScoringConstraints.constant = 16
        }else{
            self.scoreSV.isHidden = false
            self.detailScoreSV.isHidden = true
            self.scoreSecondSV.isHidden = true
            //btnDetailsScoringConstraints.constant = 0
        }
    }
    func updateStrokesButtonWithoutStrokes(strokes:Int,btn:UIButton,color:UIColor){
        if strokes <= -2 || strokes <= -3{
            //double circle
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
            layer.cornerRadius = layer.frame.height/2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = btn.frame.height/2
            btn.layer.borderColor = color.cgColor
            
        }
            
        else if strokes == -1{
            //single circle
            if let layers = btn.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            btn.titleLabel?.layer.borderWidth = 0
            btn.layer.borderWidth = 1
            btn.layer.borderColor = color.cgColor
            btn.layer.cornerRadius = btn.frame.size.height/2
        }
            
        else if strokes == 1{
            //single square
            btn.layer.borderWidth = 1
            btn.layer.borderColor = color.cgColor
        }
            
        else if strokes >= 2 || strokes >= 3{
            //double square
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
            layer.cornerRadius = 2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 2
            btn.layer.borderColor = color.cgColor
        }
    }
    @objc func fairwayHitAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "fairway_left"),#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "fairway_right")]
        holeWiseShots.removeObject(forKey: "fairway")
        for btn in buttonsArrayForFairwayHit{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["fairway":NSNull()])
                for btn in buttonsArrayForFairwayHit{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    let originalImage1 = imgArray[btn.tag]
                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    btn.setImage(backBtnImage1, for: .normal)
                    btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            let originalImage1 = imgArray[btn.tag]
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(backBtnImage1, for: .normal)
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            btn.isHidden = true
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                btn.tintColor = UIColor.glfWhite
                btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                if(btn.tag == 0){
                    holeWiseShots.setObject("L", forKey: "fairway" as NSCopying)
                }else if (btn.tag == 1){
                    holeWiseShots.setObject("H", forKey: "fairway" as NSCopying)
                }else{
                    holeWiseShots.setObject("R", forKey: "fairway" as NSCopying)
                }
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
            
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func chipShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "chipCount")
        for btn in buttonsArrayForChipShot{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["chipCount":NSNull()])
                for btn in buttonsArrayForChipShot{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "chipCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func sandShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "sandCount")
        
        for btn in buttonsArrayForSandSide{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["sandCount":NSNull()])
                for btn in buttonsArrayForSandSide{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "sandCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func penaltyShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "penaltyCount")
        for btn in buttonsArrayForPenalty{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["penaltyCount":NSNull()])
                for btn in buttonsArrayForPenalty{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "penaltyCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    
    @objc func girAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "gir_false")]
        holeWiseShots.removeObject(forKey: "gir")
        for btn in buttonsArrayForGIR{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["gir":NSNull()])
                for btn in buttonsArrayForGIR{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                    let originalImage1 = imgArray[btn.tag%10]
                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    btn.setImage(backBtnImage1, for: .normal)
                    btn.tintColor = UIColor.glfWarmGrey
                    btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
                }
                break
            }
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            let originalImage1 = imgArray[btn.tag%10]
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(backBtnImage1, for: .normal)
            btn.tintColor = UIColor.glfWarmGrey
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            btn.isHidden = true
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                btn.tintColor = UIColor.glfWhite
                btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                if(btn.tag%10 == 0){
                    holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
                }
                else{
                    holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
                }
            }
            holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
            debugPrint(holeWiseShots)
            updateScoreData()
            ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
        }
    }
    @objc func puttsAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "putting")
        for btn in buttonsArrayForPutts{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["putting":NSNull()])
                for btn in buttonsArrayForPutts{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "putting" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    
    func setHoleShotDetails(par:Int,shots:Int){
        var holeFinishStatus = String()
        var color = UIColor()
        switch shots-par{
        case -1:
            holeFinishStatus = "  Birdie  "
            color = UIColor.glfFlatBlue
            break
        case -2:
            holeFinishStatus = "  Eagle  "
            color = UIColor.glfFlatBlue
            break
        case -3:
            holeFinishStatus = "  Albatross  "
            color = UIColor.glfFlatBlue
            break
        case 0:
            holeFinishStatus = "  Par  "
            color = UIColor.glfFlatBlue
            break
        case 1:
            holeFinishStatus = "  Bogey  "
            color = UIColor.glfWarmGrey
            break
        case 2:
            holeFinishStatus = "  D. Bogey  "
            color = UIColor.glfWarmGrey
            break
        default:
            holeFinishStatus = " \(shots-par) Bogey"
            color = UIColor.glfRosyPink
        }
        btnShotRanking.setTitle(holeFinishStatus, for: .normal)
        btnShotRanking.backgroundColor = color
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
    
    func getScoreIntoClassicNode(hole:Int,playerKey:String)->classicMode{
        let classicScore = classicMode()
        for data in scoreData[hole].players{
            if let dic = (data).value(forKey: playerKey) as? NSMutableDictionary{
                if let chipShot = dic.value(forKey: "chipCount") as? Int{
                    classicScore.chipShot = chipShot
                }
                if let sandShot = dic.value(forKey: "sandCount") as? Int{
                    classicScore.sandShot = sandShot
                }
                if let strokesCount = dic.value(forKey: "strokes") as? Int{
                    classicScore.strokesCount = strokesCount
                }
                if let holeOut = dic.value(forKey: "holeOut") as? Bool{
                    classicScore.holeOut = holeOut
                }
                if let putting = dic.value(forKey: "putting") as? Int{
                    classicScore.putting = putting
                }
                if let fairway = dic.value(forKey: "fairway") as? String{
                    classicScore.fairway = fairway
                }
                if let penaltyShot = dic.value(forKey: "penaltyCount") as? Int{
                    classicScore.penaltyShot = penaltyShot
                }
                if let gir = dic.value(forKey: "gir") as? Bool{
                    classicScore.gir = gir
                }
                if let holeOut = dic.value(forKey: "holeOut") as? Bool{
                    classicScore.holeOut = holeOut
                }
            }
        }
    return classicScore
        
    }
    func loadScoreWithUpdatedData(){
        self.title = "Your Scorecard"
        self.view.backgroundColor = UIColor(rgb: 0xF8F8F7)
        
        let tempDic = NSMutableDictionary()
        tempDic.setObject("parId", forKey: "id" as NSCopying)
        tempDic.setObject("Par", forKey: "name" as NSCopying)
        sectionNames.insert(tempDic, at: 0)
        for i in 0..<playerData.count{
            sectionNames.insert(playerData[i], at: i+1)
        }
        
        sectionItems = [[],["Fairways Hit","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Fairways Hit","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Fairways Hit","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Fairways Hit","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Fairways Hit","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        if mode == 1{
        sectionItems = [[],["Driving Distance", "Fairways Hit", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Fairways Hit", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Fairways Hit", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Fairways Hit", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Fairways Hit", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        }
        menueTableView =  UITableView(frame: CGRect(x: 0, y: 64+10, width: 180, height: self.view.frame.size.height-(64+10)), style: .grouped)
        menueTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenueCell")
        menueTableView.dataSource = self
        menueTableView.delegate = self
        menueTableView.tag = 0
        menueTableView.backgroundColor = UIColor.clear
        menueTableView.separatorStyle = .none
        //menueTableView.alwaysBounceVertical = false
        menueTableView.showsVerticalScrollIndicator = false
        self.menueTableView!.tableFooterView = UIView()
        view.addSubview(menueTableView)
        
        scrollView =  UIScrollView(frame: CGRect(x: menueTableView.frame.origin.x + menueTableView.frame.size.width, y: menueTableView.frame.origin.y, width: view.frame.size.width - menueTableView.frame.size.width-2, height: menueTableView.frame.size.height-40))
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        view.addSubview(bView)
        var tableWidth = CGFloat()
        for i in 0..<scoreData.count{
            
            tableWidth = 10+(width+padding)*CGFloat(i+2)
        }
        tblView =  UITableView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: scrollView.frame.size.height), style: .grouped)
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        tblView.dataSource = self
        tblView.delegate = self
        tblView.tag = 1
        tblView.backgroundColor = UIColor.clear
        tblView.separatorColor = UIColor(rgb: 0x01AD8C)
        tblView.alwaysBounceVertical = false
        tblView.tableFooterView = UIView()
        scrollView.addSubview(tblView)
        
        scrollView.contentSize = CGSize(width: tblView.frame.size.width, height: tblView.frame.size.height)
        let imgView = UIImageView()
        self.expandedSectionHeaderNumber = 1
        tableViewExpandSection(1, imageView: imgView)
        self.playerId = (self.sectionNames[1] as AnyObject).value(forKey: "id") as! String
    }
    @objc func btnContinueAction(){
        self.backBtnAction(Any.self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bView.frame = CGRect(x: 0, y: self.view.frame.height-40, width: self.view.frame.width, height: 40)
        bView.btn.frame = CGRect(x: 0, y: 0, width: bView.frame.size.width, height: bView.frame.size.height)
        bView.btn.addTarget(self, action: #selector(btnContinueAction), for: .touchUpInside)
        
        self.navigationController?.navigationBar.isHidden = false
        self.setInitialUI()
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        self.scoringView.layer.cornerRadius = 5
        self.loadScoreWithUpdatedData()
        self.scoringSuperView.isHidden = true
        btnDetailScoring.setCorner(color: UIColor.clear.cgColor)
        btnExpendScore.setCorner(color: UIColor.clear.cgColor)
        btnScore.setCornerWithCircleWidthOne(color: UIColor.white.cgColor)
        btnShotRanking.layer.cornerRadius = 10.0
        let tap = UITapGestureRecognizer(target: self, action:  #selector (self.superViewTouchAction (_:)))
        self.scoringSuperView.addGestureRecognizer(tap)
    }
    @objc func superViewTouchAction(_ sender:UITapGestureRecognizer){
        let location = sender.location(in: self.scoringSuperView)
        if !self.scoringView.frame.contains(location){
            self.scoringSuperView.isHidden = true
            getScoreFromMatchDataFirebase()
        }
    }
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.menueTableView.backgroundView = messageLabel
            self.tblView.backgroundView = messageLabel
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 0
        }
        else if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        }
        else {
            return 0
        }
    }
    @objc func buttonAction(sender: CellButton!) {

        self.view.addSubview(self.scoringSuperView)
        self.scoringSuperView.isHidden = false
        self.scoringView.isHidden = false
        self.scoringView.tag = 33
        
        self.fairwayHitStackView.superview?.isHidden = false
        if(self.scoreData[self.index].par == 3){
            self.fairwayHitStackView.superview?.isHidden = true
        }
        
        var newI = self.scoreData[self.index].par - 2
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(newI)", for: .normal)
            updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[self.index].par), btn: btn as! UIButton,color: UIColor.white)
            newI += 1
        }
        self.playerId = sender.userData
        self.index = sender.tag
        self.classicScoring = self.getScoreIntoClassicNode(hole: self.index,playerKey: self.playerId!)
        self.updateValue()
        self.holeWiseShots.removeAllObjects()
        lblHolePar.text = "Hole \(self.index+1) - Par \(self.scoreData[self.index].par)"
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.white
        
        if tableView.tag == 0 {
            let usrImageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 32, height: 32))
            
            if section != 0{
                usrImageView.image = #imageLiteral(resourceName: "you")
                if let url = (self.sectionNames[section] as AnyObject).value(forKey: "image") as? String{
                    usrImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
                }
                usrImageView.setCircle(frame: usrImageView.frame)
                usrImageView.tag = kHeaderSectionTag + section
                
                let label = UILabel()
                
                label.frame = CGRect(x: usrImageView.frame.origin.x + usrImageView.frame.size.width+10, y: 0, width: 80, height: 32)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.textColor = UIColor.glfWarmGrey
                header.addSubview(label)
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.menueTableView.frame.size
                
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
                theImageView.image = UIImage(named: "Chevron-Dn-Wht")
                
                theImageView.tag = kHeaderSectionTag + section
                
                header.addSubview(theImageView)
                header.addSubview(usrImageView)
                
                // make headers touchable
                header.tag = section
                let headerTapGesture = UITapGestureRecognizer()
                headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
                header.addGestureRecognizer(headerTapGesture)
//
//                UIView.animate(withDuration: 0.4, animations: {
//                    theImageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//                })
//                if (self.expandedSectionHeaderNumber == section) {
//                    UIView.animate(withDuration: 0.4, animations: {
//                        theImageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//                    })
//                }
            }
            else{

                let label = UILabel()
                label.frame = CGRect(x: usrImageView.frame.origin.x + usrImageView.frame.size.width+10, y: 16, width: 80, height: 15)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.sizeToFit()
                header.addSubview(label)
                
                let holeLbl = UILabel()
                holeLbl.frame = CGRect(x: label.frame.origin.x + label.frame.size.width+5, y: 5, width: 80, height: 15)
                holeLbl.textColor = UIColor.glfGreenBlue
                holeLbl.text = "Hole"
                header.addSubview(holeLbl)
            }
        }
        else{
            if section == 0{
                header.backgroundColor = UIColor.white
                //header.textLabel?.textColor = UIColor.black
                
                for i in 0..<scoreData.count{
                    //var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
                    
                    let label =  UILabel(frame: CGRect(x: 10+(width + padding)*CGFloat(i), y: 20, width: 50, height: 15))
                    label.text = "\(self.scoreData[i].par)"
                    label.textAlignment = .center
                    label.textColor = UIColor.black
                    header.addSubview(label)
                }
                let label =  UILabel(frame: CGRect(x: 10+(width + padding)*CGFloat(scoreData.count), y: 20, width: 50, height: 15))
                label.text = "Total"
                label.textAlignment = .center
                label.textColor = UIColor.black
                header.addSubview(label)

                for i in 0..<scoreData.count{
                    
                    let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 7, width: 50, height: 15))
                    label.text = "\(i+1)"
                    label.textAlignment = .center
                    label.textColor = UIColor.glfGreenBlue
                    
                    header.addSubview(label)
                }
            }
            else{
                header.backgroundColor = UIColor(rgb: 0x2E9F80)
                
                let playerId = (self.sectionNames[section] as AnyObject).value(forKey: "id") as! String
                for view in header.subviews{
                    if view.isKind(of: UILabel.self){
                        view.removeFromSuperview()
                    }
                }
                var totalStrokes = 0
                for i in 0..<self.scoreData.count{
                    
                    let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(i), y: 5, width: 35, height: 35))
                    subView.backgroundColor = UIColor.clear
                    header.addSubview(subView)
                    
                    let btn = CellButton()
                    btn.frame = CGRect(x: 5, y: 5, width: 25, height: 25)
                    btn.setTitle("-", for: .normal)
                    btn.titleLabel?.textAlignment = .center
                    btn.titleLabel?.textColor = UIColor.white
                    btn.tag = i
                    btn.userData = playerId
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    subView.addSubview(btn)
                    
                    for dataDict in self.scoreData[i].players{
                        
                        for (key,value) in dataDict{
                            let dic = value as! NSDictionary
                            if dic.value(forKey: "holeOut") as! Bool == true{
                                if(key as? String == playerId){
                                    for (key,value) in value as! NSMutableDictionary{
                                        var totalShots = 0
                                        var allScore = Int()
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            allScore  = shotsArray.count - (self.scoreData[i].par)
                                            totalShots = shotsArray.count
                                            btn.setTitle("\(totalShots)", for: .normal)
                                            totalStrokes += totalShots
                                        }
                                        else if (key as! String == "strokes"){
                                            allScore  = (value as! Int) - (self.scoreData[i].par)
                                            totalShots = (value as! Int)
                                            btn.setTitle("\(totalShots)", for: .normal)
                                            totalStrokes += totalShots
                                        }
                                        if allScore <= -2 || allScore <= -3{
                                            //double circle
                                            subView.layer.borderWidth = 1.0
                                            subView.layer.cornerRadius = subView.frame.size.height/2
                                            subView.layer.borderColor = UIColor.white.cgColor
                                            
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.cornerRadius = btn.frame.size.height/2
                                            btn.layer.borderColor = UIColor.white.cgColor
                                        }
                                        else if allScore == -1{
                                            //single circle
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.cornerRadius = btn.frame.size.height/2
                                            btn.layer.borderColor = UIColor.white.cgColor
                                        }
                                        else if allScore == 1{
                                            //single square
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.borderColor = UIColor.white.cgColor
                                        }
                                        else if allScore >= 2 || allScore >= 3{
                                            //double square
                                            subView.layer.borderWidth = 1.0
                                            subView.layer.borderColor = UIColor.white.cgColor
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.borderColor = UIColor.white.cgColor
                                        }
                                        else{
                                            // do nothing
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(scoreData.count), y: 5, width: 35, height: 35))
                subView.backgroundColor = UIColor.clear
                header.addSubview(subView)
                
                let btn =  UIButton(frame: CGRect(x: 3, y: 5, width: 25, height: 25))
                btn.titleLabel?.textAlignment = .center
                btn.titleLabel?.textColor = UIColor.white
                btn.setTitle("-", for: .normal)
                if totalStrokes > 0{
                    btn.setTitle("\(totalStrokes)", for: .normal)
                }
                subView.addSubview(btn)
            }
        }
        
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 32.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String
        
        if tableView.tag == 0 {
            cellIdentifier = "MenueCell"
        }
        else{
            cellIdentifier = "DataCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.section > 0{
            
            if tableView.tag == 0 {
                let section = self.sectionItems[indexPath.section] as! NSArray
                cell.textLabel?.text = section[indexPath.row] as? String
                
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
            }
            else{
                cell.backgroundColor = UIColor(rgb: 0x2E9F80)
                cell.textLabel?.textColor = UIColor.clear
                cell.textLabel?.text = ""
                for subView in cell.contentView.subviews{
                    subView.removeFromSuperview()
                }

                let playerId = (self.sectionNames[indexPath.section] as AnyObject).value(forKey: "id") as! String
                
                var drDistance = 0
                var drivingCount = 0
                var frwHit = 0
                var aprchDistance = 0
                var aprchCount = 0
                var girTotal = 0
                var chipDown = 0
                var sandTotal = 0
                var puttsTotal = 0
                var penaltyTotal = 0
                for i in 0..<scoreData.count{
                    let btn = CellButton(frame:CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 32, height: 32))
                    btn.setTitle("-", for: .normal)
                    btn.titleLabel?.textAlignment = .center
                    btn.titleLabel?.textColor = UIColor.white
                    btn.tag = i
                    btn.userData = playerId
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    cell.contentView.addSubview(btn)

                    for dataDict in self.scoreData[i].players{
                        for (key,value) in dataDict{
                            if(key as? String == playerId){
                                if let dict = value as? NSMutableDictionary{
                                    for (key,value) in dict{
                                        if mode == 1{
                                            if indexPath.row == 0{
                                                if(key as! String == "drivingDistance"){
                                                    let drivingDistance = value as! Double
                                                    btn.setTitle( "\(Int(drivingDistance))", for: .normal)
                                                    drDistance += (Int(drivingDistance))
                                                    drivingCount += 1
                                                }
                                            }
                                            else if indexPath.row == 1{
                                                if(key as! String == "fairway"){
                                                    let fairway = value as! String
                                                    btn.setTitle("", for: .normal)
                                                    btn.setTitleColor(UIColor.clear, for: .normal)
                                                    btn.setImage(nil, for: .normal)
                                                    if(fairway == "H"){
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        frwHit += 1
                                                    }else if(fairway == "L"){
                                                        btn.setImage(#imageLiteral(resourceName: "fairway_left"), for: .normal)
                                                    }else{
                                                        btn.setImage(#imageLiteral(resourceName: "fairway_right"), for: .normal)
                                                    }
                                                    btn.tintColor = UIColor.glfWhite
                                                    btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                    
                                                }
                                            }
                                            else if indexPath.row == 2{
                                                if(key as! String == "approachDistance"){
                                                    let approchDist = value as! Double
                                                    btn.setTitle( "\(Int(approchDist))", for: .normal)
                                                    aprchDistance += (Int(approchDist))
                                                    aprchCount += 1
                                                }
                                            }
                                            else if indexPath.row == 3{
                                                if(key as! String == "gir"){
                                                    let gir = value as! Bool
                                                    btn.setTitle("", for: .normal)
                                                    btn.setTitleColor(UIColor.clear, for: .normal)
                                                    btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                    
                                                    girTotal += gir ? 1:0
                                                    
                                                    if !gir{
                                                        btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                    }
                                                    btn.tintColor = UIColor.glfWhite
                                                    btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                    cell.contentView.addSubview(btn)
                                                }
                                            }
                                            else if indexPath.row == 4{
                                                if(key as! String == "chipUpDown"){
                                                    if let chipUpDown = value as? Bool{
                                                        btn.setTitle("", for: .normal)
                                                        btn.setTitleColor(UIColor.clear, for: .normal)
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        
                                                        chipDown += chipUpDown ? 1:0
                                                        
                                                        if !chipUpDown{
                                                            btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfWhite
                                                        btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 5{
                                                if(key as! String == "sandUpDown"){
                                                    if let sandDown = value as? Bool{
                                                        btn.setTitle("", for: .normal)
                                                        btn.setTitleColor(UIColor.clear, for: .normal)
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        
                                                        sandTotal += sandDown ? 1:0
                                                        
                                                        if !sandDown{
                                                            btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfWhite
                                                        btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 6{
                                                if(key as! String == "putting"){
                                                    let approchDist = value as! Int
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    puttsTotal += approchDist
                                                }
                                            }
                                            else if indexPath.row == 7{
                                                if(key as! String == "penaltyCount"){
                                                    let approchDist = value as! Int
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    penaltyTotal += approchDist
                                                }
                                            }
                                        }
                                        else{
                                            
                                            if indexPath.row == 0{
                                                if(key as! String == "fairway"){
                                                    let fairway = value as! String
                                                    btn.setTitle("", for: .normal)
                                                    btn.setTitleColor(UIColor.clear, for: .normal)
                                                    btn.setImage(nil, for: .normal)
                                                    if(fairway == "H"){
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        frwHit += 1
                                                    }else if(fairway == "L"){
                                                        btn.setImage(#imageLiteral(resourceName: "fairway_left"), for: .normal)
                                                    }else{
                                                        btn.setImage(#imageLiteral(resourceName: "fairway_right"), for: .normal)
                                                    }
                                                    btn.tintColor = UIColor.glfWhite
                                                    btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                }
                                            }
                                            else if indexPath.row == 1{
                                                if(key as! String == "gir"){
                                                    let gir = value as! Bool
                                                    btn.setTitle("", for: .normal)
                                                    btn.setTitleColor(UIColor.clear, for: .normal)
                                                    btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                    
                                                    girTotal += gir ? 1:0
                                                    
                                                    if !gir{
                                                        btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                    }
                                                    btn.tintColor = UIColor.glfWhite
                                                    btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                    cell.contentView.addSubview(btn)
                                                }
                                            }
                                            else if indexPath.row == 2{
                                                if(key as! String == "chipUpDown"){
                                                    if let chipUpDown = value as? Bool{
                                                        btn.setTitle("", for: .normal)
                                                        btn.setTitleColor(UIColor.clear, for: .normal)
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        
                                                        chipDown += chipUpDown ? 1:0
                                                        
                                                        if !chipUpDown{
                                                            btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfWhite
                                                        btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 3{
                                                if(key as! String == "sandUpDown"){
                                                    if let sandDown = value as? Bool{
                                                        btn.setTitle("", for: .normal)
                                                        btn.setTitleColor(UIColor.clear, for: .normal)
                                                        btn.setImage(#imageLiteral(resourceName: "hit"), for: .normal)
                                                        
                                                        sandTotal += sandDown ? 1:0
                                                        
                                                        if !sandDown{
                                                            btn.setImage(#imageLiteral(resourceName: "gir_false"), for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfWhite
                                                        btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 4{
                                                if(key as! String == "putting"){
                                                    let approchDist = value as! Int
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    puttsTotal += approchDist
                                                }
                                            }
                                            else if indexPath.row == 5{
                                                if(key as! String == "penaltyCount"){
                                                    let approchDist = value as! Int
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    penaltyTotal += approchDist
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(scoreData.count), y: 0, width: 40, height: 32))
                label.text = "-"
                if mode == 1{
                    if indexPath.row == 0{
                        if drDistance>0{
                            label.text = "\(Int(drDistance/drivingCount))"
                        }
                    }
                    else if indexPath.row == 1{
                        if frwHit>0{
                            label.text = "\(frwHit)"
                        }
                    }
                    else if indexPath.row == 2{
                        if aprchDistance>0{
                            label.text = "\(Int(aprchDistance/aprchCount))"
                        }
                    }
                    else if indexPath.row == 3{
                        if girTotal>0{
                            label.text = "\(girTotal)"
                        }
                    }
                    else if indexPath.row == 4{
                        if chipDown>0{
                            label.text = "\(chipDown)"
                        }
                    }
                    else if indexPath.row == 5{
                        if sandTotal>0{
                            label.text = "\(sandTotal)"
                        }
                    }
                    else if indexPath.row == 6{
                        if puttsTotal>0{
                            label.text = "\(puttsTotal)"
                        }
                    }
                    else if indexPath.row == 7{
                        if penaltyTotal>0{
                            label.text = "\(penaltyTotal)"
                        }
                    }
                }
                else{
                    if indexPath.row == 0{
                        if frwHit>0{
                            label.text = "\(frwHit)"
                        }
                    }
                    else if indexPath.row == 1{
                        if girTotal>0{
                            label.text = "\(girTotal)"
                        }
                    }
                    else if indexPath.row == 2{
                        if chipDown>0{
                            label.text = "\(chipDown)"
                        }
                    }
                    else if indexPath.row == 3{
                        if sandTotal>0{
                            label.text = "\(sandTotal)"
                        }
                    }
                    else if indexPath.row == 4{
                        if puttsTotal>0{
                            label.text = "\(puttsTotal)"
                        }
                    }
                    else if indexPath.row == 5{
                        if penaltyTotal>0{
                            label.text = "\(penaltyTotal)"
                        }
                    }
                }
                label.textAlignment = .center
                label.textColor = UIColor.white
                label.backgroundColor = UIColor.clear
                cell.contentView.addSubview(label)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        //let headerView = sender.view as! UITableViewHeaderFooterView
        let headerView = sender.view
        if !(self.scoringView.isHidden){
            self.scoringView.isHidden = true
        }
        let section = headerView?.tag
        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section!
            tableViewExpandSection(section!, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section!, imageView: eImageView!)
            } else {
//                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                tableViewExpandSection(section!, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1
        if (sectionData.count == 0) {
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.menueTableView!.beginUpdates()
            self.menueTableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            
            self.menueTableView!.beginUpdates()
            self.menueTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
}

