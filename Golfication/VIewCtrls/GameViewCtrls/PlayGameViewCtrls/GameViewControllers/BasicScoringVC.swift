//
//  BasicScoringVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

import UserNotifications

class BasicScoringVC: UIViewController,ExitGamePopUpDelegate{
    @IBOutlet weak var menuStackView: StackView!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var holeParDDView: UIView!
    @IBOutlet weak var scorePopView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDetailScoring: UIButton!
    @IBOutlet weak var btnExpendScore: UIButton!
    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    @IBOutlet weak var btnViewScoreCard: UIButton!

    @IBOutlet weak var scoreSV: UIStackView!
    @IBOutlet weak var detailScoreSV: UIStackView!
    @IBOutlet weak var scoreSecondSV: UIStackView!

    @IBOutlet weak var stackBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnChangeHole: UIButton!
    
    @IBOutlet weak var stackViewForMultiplayer: UIStackView!
    @IBOutlet weak var fairwayHitStackView: UIStackView!
    @IBOutlet weak var girStackView: UIStackView!
    @IBOutlet weak var puttsStackView: UIStackView!
    @IBOutlet weak var chipShotStackView: UIStackView!
    @IBOutlet weak var greenSideSandShotStackView: UIStackView!
    @IBOutlet weak var penalitiesStackView: UIStackView!
    @IBOutlet weak var lblHoleNumber: UILabel!
    @IBOutlet weak var lblParNumber: UILabel!
    @IBOutlet weak var btnDownArraow: UIButton!
    @IBOutlet weak var lblCourseName: UILabel!
    @IBOutlet weak var stackViewStrokes1: UIStackView!
    @IBOutlet weak var stackViewStrokes2: UIStackView!
    @IBOutlet weak var stackViewStrokes3: UIStackView!
    @IBOutlet weak var stackViewStrokes4: UIStackView!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnFinishRound: UIButton!
    @IBOutlet weak var lblPlayerNameDSV: UILabel!
    @IBOutlet weak var lblPlayerNameSSV: UILabel!
    @IBOutlet weak var exitGamePopUpView: ExitGamePopUpView!
    
    var progressView = SDLoader()
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
    var holeIndex = 0
    var playerData = NSMutableArray()
    var isAccept = false
    var plyerViseScore = [[(gir:Bool,fairwayHit:String)]]()
    var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var matchDataDict = NSMutableDictionary()
    var isContinue = false
    var playersButton = [(button:UIButton,isSelected:Bool,id:String,name:String)]()
    let swipePrev = UISwipeGestureRecognizer()
    let swipeNext = UISwipeGestureRecognizer()
    var holeOutforAppsFlyer = [Int]()
    var startingIndex = Int()
    var gameTypeIndex = Int()
    @IBAction func btnActionMenu(_ sender: Any) {
        var j = 0
        for player in playersButton{
            self.holeOutforAppsFlyer[j] = self.checkHoleOutZero(playerId: player.id)
            j += 1
        }
        
        if(menuStackView.isHidden){
            menuStackView.isHidden = false
        }else{
            menuStackView.isHidden = true
        }
    }
    @IBAction func btnActionChangeHole(_ sender: Any) {
        menuStackView.isHidden = true
        var strArr = [String]()
        for hole in self.scoreData{
            strArr.append("Hole \(hole.hole) - Par - \(hole.par)")
        }
        ActionSheetStringPicker.show(withTitle: "Select Hole", rows: strArr, initialSelection: holeIndex, doneBlock: { (picker, value, index) in
            self.holeIndex = value
            self.updateData(indexToUpdate: value)
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
    }
    
    @IBAction func expendScoreAction(_ sender: Any) {
        scoreSecondSV.isHidden = false
        btnExpendScore.isHidden = true
        self.menuStackView.isHidden = true

        for btn in buttonsArrayForStrokes{
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
                btn.setTitle("\(btn.tag)", for: .normal)
                btn.layer.borderWidth = 0
            for lay in btn.layer.sublayers!{
                lay.borderWidth = 0
            }
        }
        if let str = holeWiseShots.value(forKey: "strokes") as? Int{
            self.buttonsArrayForStrokes[str-1].setTitleColor(UIColor.glfBluegreen, for: .normal)
        }
        
    }
    @IBAction func btnActionDiscardRound(_ sender: Any) {
        menuStackView.isHidden = true
        self.exitWithoutSave()
    }
    
    @IBAction func btnActionRestartRound(_ sender: Any) {
        menuStackView.isHidden = true
        var playerIndex = 0
        var i = 0
        for data in self.playersButton{
            self.holeOutforAppsFlyer[i] = self.checkHoleOutZero(playerId: data.id)
            if(data.id == Auth.auth().currentUser!.uid){
                playerIndex = i
            }
            i += 1
        }
        let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer[playerIndex])/\(scoreData.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.resetScoreNodeForMe()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.updateData(indexToUpdate:self.holeIndex)
                self.progressView.hide(navItem: self.navigationItem)
                var i = 0
                for _ in self.playersButton{
                    self.holeOutforAppsFlyer[i] = 0
                    i += 1
                }
            })
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
    }
    func resetScoreNodeForMe(){
        for i in 0..<self.scoreData.count{
            let player = NSMutableDictionary()
            for j in 0..<playersButton.count{
                if(playersButton[j].id == Auth.auth().currentUser?.uid){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                    ref.child("matchData/\(matchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoreData[i].players[j].addEntries(from: playerData)
                }
            }
        }
    }
    @IBAction func btnActionFinishRound(_ sender: UIButton) {
        menuStackView.isHidden = true
        var playerIndex = 0
        var i = 0
        for data in self.playersButton{
            self.holeOutforAppsFlyer[i] = self.checkHoleOutZero(playerId: data.id)
            if(data.id == Auth.auth().currentUser!.uid){
                playerIndex = i
            }
            i += 1
        }
        
        self.exitGamePopUpView.labelText = "\(self.holeOutforAppsFlyer[playerIndex])/\(scoreData.count) Holes Completed."
        self.exitGamePopUpView.isHidden = false
    }
    
    var detailedScore = NSMutableArray()
    func checkHoleOutZero(playerId:String) -> Int{
        detailedScore = NSMutableArray()
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
                                        detailedScore.addObjects(from: [countDic])
                                        
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
    func exitWithoutSave(){
        if(matchId.count > 1){
            self.updateFeedNode()
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            if(matchId.count > 1){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId)").removeValue()
            }
            matchId.removeAll()
            isUpdateInfo = true
            self.navigationController?.popToRootViewController(animated: true)
            addPlayersArray.removeAllObjects()
            if mode>0{
                Analytics.logEvent("mode\(mode)_game_discarded", parameters: [:])
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            }
        }
        self.scoreData.removeAll()
        scoreData.removeAll()
    }
    func saveAndviewScore(){

        // -----------------------------------------------------------------
        var holIndex = -1
        
        for i in 0..<detailedScore.count{
            let dic = detailedScore[i] as! NSMutableDictionary
            if (dic.value(forKey: "DetailCount") as! Int == 2){
                holIndex = dic.value(forKey: "HoleIndex") as! Int
                break
            }
        }
        if (holIndex > -1){
            let emptyAlert = UIAlertController(title: "Alert", message: "Would you like to complete Detailed Scoring to get better stats?", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "Add Detailed Scores", style: .default, handler: { (action: UIAlertAction!) in
                
                let currentHoleWhilePlaying = NSMutableDictionary()
                currentHoleWhilePlaying.setObject("\(holIndex+1)", forKey: "currentHole" as NSCopying)
                ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
                self.holeIndex = holIndex-1
                self.nextAction(self.btnNext)
            }))
            emptyAlert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
                self.progressView.show()
                let generateStats = GenerateStats()
                generateStats.matchKey = matchId
                generateStats.generateStats()
            }))
            self.present(emptyAlert, animated: true, completion: nil)
        }
        else{
            self.progressView.show()
            let generateStats = GenerateStats()
            generateStats.matchKey = matchId
            generateStats.generateStats()
        }
        // ------------------------------------------------------------------

//        self.progressView.show()
//        let generateStats = GenerateStats()
//        generateStats.matchKey = matchId
//        generateStats.generateStats()
        
    }
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.show()
        if(matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        if(Auth.auth().currentUser!.uid.count>1) &&  (matchId.count > 1){
            ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
        }
        addPlayersArray = NSMutableArray()
        self.updateFeedNode()
        isUpdateInfo = true
        if mode>0{
            Analytics.logEvent("mode\(mode)_game_completed", parameters: [:])
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        if(matchId.count > 1){
            self.gotoFeedBackViewController(mID: matchId,mode:mode)
        }
    }
    func sendMatchFinishedNotification(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser?.uid ?? "user1")/friends") { (snapshot) in
            let group = DispatchGroup()
            var dataDic = [String:Bool]()
            self.progressView.show()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            for data in dataDic{
                group.enter()
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(selectedGolfName).", type: "8", category: "finishedGame", matchDataId: matchId, feedKey:"")
                group.leave()
            }
            
            group.notify(queue: .main){
                self.progressView.hide()
            }
        }
    }
    func updateFeedNode(){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        feedDict.setObject(matchId, forKey: "matchKey" as NSCopying)
        feedDict.setObject("2", forKey: "type" as NSCopying)
        var imagUrl = String()
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        feedDict.setObject(imagUrl, forKey: "userImage" as NSCopying)
        let feedId = ref!.child("feedData").childByAutoId().key
        let finalFeedDic = NSMutableDictionary()
        finalFeedDic.setObject(feedDict, forKey: feedId as NSCopying)
        
        ref.child("feedData").updateChildValues(finalFeedDic as! [AnyHashable : Any])
        ref.child("userData/\(feedDict.value(forKey: "userKey")!)/myFeeds").updateChildValues([feedId:true])
    }
    func gotoFeedBackViewController(mID:String,mode:Int){
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        viewCtrl.matchIdentifier = mID
        viewCtrl.mode = mode
        viewCtrl.onDoneBlock = { result in
            let players = NSMutableArray()
            let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
            if(self.matchDataDict.object(forKey: "player") != nil){
                let tempArray = self.matchDataDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    if(k as! String == Auth.auth().currentUser!.uid){
                        dict.addEntries(from: ["status":4])
                    }
                    players.add(dict)
                }
            }
            viewCtrl.finalPlayersData = players
            viewCtrl.finalScoreData = self.scoreData
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.scoreData.removeAll()
            matchId.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }
    @IBAction func detailScoreAction(_ sender: UIButton) {
        menuStackView.isHidden = true
        if sender.tag == 0{
            sender.tag = 1
            self.scorePopView.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.btnDetailScoring.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            self.view.layoutIfNeeded()
        }
        else{
            sender.tag = 0
            self.scorePopView.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.btnDetailScoring.imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        var maxLimit = scoreData.count-1
        if(self.scoreData.count > self.gameTypeIndex) && self.startingIndex+self.gameTypeIndex-1 <= self.scoreData.count{
            maxLimit = (self.startingIndex+self.gameTypeIndex) - 2
        }else if self.startingIndex+self.gameTypeIndex-1 > self.scoreData.count{
            if(self.gameTypeIndex < self.scoreData.count){
                maxLimit =  (self.startingIndex+self.gameTypeIndex-1) - self.scoreData.count
            }
        }
        menuStackView.isHidden = true
        holeIndex += 1
        self.btnNext.isHidden = false
        self.btnFinishRound.isHidden = true
        self.btnPrev.isEnabled = true
        self.swipeNext.isEnabled = true
        self.swipePrev.isEnabled = true
        if(holeIndex == scoreData.count){
            holeIndex = 0
        }
        updateData(indexToUpdate: self.holeIndex)
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.holeIndex+1)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        if(holeIndex == maxLimit){
            self.btnNext.isHidden = true
            self.swipePrev.isEnabled = false
            self.btnFinishRound.isHidden = false
        }
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        containerView.layer.add(transition, forKey: nil)
    }
    
    @IBAction func prevAction(_ sender: Any) {
        var minLimit = 0
        if(self.startingIndex != 1){
            if(self.scoreData.count > self.gameTypeIndex){
                minLimit = self.startingIndex - 1
            }
        }
        
        menuStackView.isHidden = true
        holeIndex -= 1
        self.btnNext.isHidden = false
        self.swipePrev.isEnabled = true
        self.btnFinishRound.isHidden = true
        if(holeIndex < 0){
            holeIndex = scoreData.count-1
        }
        updateData(indexToUpdate: self.holeIndex)
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.holeIndex+1)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        if(holeIndex == minLimit){
            self.swipeNext.isEnabled = false
            self.btnPrev.isEnabled = false
        }
        
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        containerView.layer.add(transition, forKey: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        menuStackView.isHidden = true
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: NewGameVC.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: !isAccept)
                break
            }
        }
    }
    
    @IBAction func btnActionScore(_ sender: UIButton) {
        menuStackView.isHidden = true
        if let str = holeWiseShots.value(forKey: "strokes") as? Int{
            self.detailScoreSV.isHidden = true
            if (str > self.scoreData[self.holeIndex].par+2){
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
                var newI = self.scoreData[self.holeIndex].par - 2
                for btn in self.stackViewStrokes1.arrangedSubviews{
                    (btn as! UIButton).setTitleColor(UIColor.glfWhite, for: .normal)
                    updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[self.holeIndex].par), btn: btn as! UIButton,color:UIColor.white)
                    newI += 1
                }
                if let btn = self.stackViewStrokes1.arrangedSubviews[str-self.scoreData[self.holeIndex].par+2] as? UIButton{
                    updateStrokesButtonWithoutStrokes(strokes: (str-self.scoreData[self.holeIndex].par), btn: btn,color:UIColor.glfBluegreen)
                    btn.setTitleColor(UIColor.glfBluegreen, for: .normal)
                }
            }
        }
        

    }
    
    @IBAction func btnActionViewScorecard(_ sender: Any) {
        menuStackView.isHidden = true
        let players = NSMutableArray()
        if(matchDataDict.object(forKey: "player") != nil){
            let tempArray = matchDataDict.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                players.add(dict)
            }
        }
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardForInputViewCtrl") as! ScoreBoardForInputViewCtrl
        viewCtrl.scoreData = scoreData
        viewCtrl.playerData = players
        viewCtrl.isContinue = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @objc func updateView(_ notification:NSNotification){
        if(isContinue){
            if let current = self.matchDataDict.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as? String{
                self.holeIndex = Int(current)!-1
            }else{
                if let current = matchDataDic.value(forKeyPath: "currentHole") as? String{
                    self.holeIndex = Int(current.isEmpty ? "1":current)! - 1
                }
            }
        }
        if(self.holeIndex == scoreData.count-1){
            self.btnNext.isHidden = true
            self.swipePrev.isEnabled = false
            self.btnFinishRound.isHidden = false
        }
        self.updateData(indexToUpdate:self.holeIndex)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        holeParDDView.layer.cornerRadius = 15.0
        btnDetailScoring.setCorner(color: UIColor.clear.cgColor)
        btnExpendScore.setCorner(color: UIColor.clear.cgColor)
        btnScore.setCornerWithCircleWidthOne(color: UIColor.white.cgColor)
        btnShotRanking.layer.cornerRadius = 10.0
        btnViewScoreCard.layer.cornerRadius = 15.0
        btnViewScoreCard.layer.masksToBounds = true
        let gradient2 = CAGradientLayer()
        gradient2.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient2.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient2.frame = btnViewScoreCard.bounds
        btnViewScoreCard.layer.addSublayer(gradient2)
        self.btnFinishRound.setCorner(color: UIColor.glfWarmGrey.cgColor)
        let originalImage =  #imageLiteral(resourceName: "backArrow")
        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnBack.setImage(backBtnImage, for: .normal)
        btnBack.tintColor = UIColor.glfWhite
        self.startingIndex = 1
        if let startingIndex = matchDataDic.value(forKeyPath: "startingHole") as? String{
            if startingIndex.count > 2{
                self.startingIndex = Int(startingIndex)!
            }
        }
        self.gameTypeIndex = matchDataDic.value(forKey: "matchType") as! String == "9 holes" ? 9:18
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateView(_:)), name: NSNotification.Name(rawValue: "updateView"),object: nil)

        lblCourseName.text = "\(matchDataDict.value(forKey: "courseName")!)"
        for (key,value) in self.matchDataDict{
            let keyData = key as! String
            if(keyData == "player"){
                var i = 0
                var name = String()
                for (k,v) in value as! NSMutableDictionary{
                    var isSelected = false
                    var btn = UIButton()
                    for view in self.stackViewForMultiplayer.arrangedSubviews{
                        if view.isKind(of: UIButton.self) && view.tag == i{
                            btn = view as! UIButton
                            break
                        }
                    }
                    btn.isHidden = false
                    btn.setCornerWithRadius(color: UIColor.clear.cgColor, radius: 25)
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    btn.layer.borderWidth = 2.0
                    self.holeOutforAppsFlyer.append(0)
                    name = (v as! NSMutableDictionary).value(forKeyPath: "name") as! String
                    if let img = (v as! NSMutableDictionary).value(forKeyPath: "image") as? String{
                        btn.sd_setImage(with: URL(string:img), for: .normal,placeholderImage: #imageLiteral(resourceName: "me"), completed: nil)
                        self.lblPlayerNameDSV.text = "\(name)'s Score"
                        self.lblPlayerNameSSV.text = "\(name)'s Score"
                        btn.layer.borderColor = UIColor.glfWhite.cgColor
                    }
                    if(k as! String == Auth.auth().currentUser!.uid){
                        isSelected = true
                        if(k as! String == "currentHole"){
                            self.holeIndex = Int(v as! String)!-1
                        }
                    }
                    i += 1
                    playersButton.append((button:btn, isSelected: isSelected, id: k as! String,name:name))
                }
                if(i == 1){
                    self.stackViewForMultiplayer.isHidden = true
                }else{
                    self.stackViewForMultiplayer.isHidden = false
                }
            }
        }
        for data in playersButton{
            if data.id == Auth.auth().currentUser!.uid{
                playerId = data.id
                self.buttonAction(sender: data.button)
                break
            }
        }
        swipePrev.direction = UISwipeGestureRecognizerDirection.left
        swipePrev.addTarget(self, action: #selector(self.swipedViewPrev))
        scorePopView.addGestureRecognizer(swipePrev)
        containerView.addGestureRecognizer(swipePrev)
        
        swipeNext.direction = UISwipeGestureRecognizerDirection.right
        swipeNext.addTarget(self, action: #selector(self.swipedViewNext))
        scorePopView.addGestureRecognizer(swipeNext)
        containerView.addGestureRecognizer(swipeNext)
        
        setInitialUI()
        hideDetailScoreView()
        
        if(isContinue){
            if let current = self.matchDataDict.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as? String{
                self.holeIndex = Int(current)!-1
            }else{
                if let current = self.matchDataDict.value(forKeyPath: "currentHole") as? String{
                    self.holeIndex = current == "" ? startingIndex : Int(current)! - 1
                }
            }
        }else{
            self.holeIndex = startingIndex - 1
        }
        self.exitGamePopUpView.show(navItem: self.navigationItem)
        self.exitGamePopUpView.delegate = self
        self.exitGamePopUpView.isHidden = true
        if(self.holeIndex > self.scoreData.count){
           self.holeIndex = 0
        }
        updateData(indexToUpdate: self.holeIndex)
        if(self.holeIndex == startingIndex - 1){
            self.btnPrev.isEnabled = false
            self.swipeNext.isEnabled = false
        }else if(self.holeIndex == scoreData.count-1){
            self.btnNext.isHidden = true
            self.swipePrev.isEnabled = false
            self.btnFinishRound.isHidden = false
        }

        if(!isContinue) && (!isAccept){
            if(matchDataDict.object(forKey: "player") != nil){
                let tempArray = matchDataDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    playerData.add(dict)
                }
            }
            self.initilizeScoreNode()
        }
        if(self.gameTypeIndex < scoreData.count){
            self.btnChangeHole.isUserInteractionEnabled = false
        }else{
            self.btnChangeHole.isUserInteractionEnabled = true
        }
    }
    @objc func swipedViewPrev(){
        self.nextAction(Any.self)
    }
    @objc func swipedViewNext(){
        self.prevAction(Any.self)
    }
    
    func saveNExitPressed(button:UIButton) {
        var playerIndex = Int()
        NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        for data in self.playersButton{
            if(data.id == Auth.auth().currentUser!.uid){
                break
            }
            playerIndex += 1
        }
        FBSomeEvents.shared.logGameEndedEvent(holesPlayed: self.holeOutforAppsFlyer[playerIndex], valueToSum: 3)
        if(self.holeOutforAppsFlyer[playerIndex] >= 9){
            self.saveAndviewScore()
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        }
        debugPrint("SaveNExit Tapped")
        self.exitGamePopUpView.hide(navItem: self.navigationItem)
    }
    
    func discardPressed(button:UIButton) {
        debugPrint("discard Tapped")
        self.exitGamePopUpView.hide(navItem: self.navigationItem)
        self.exitWithoutSave()
    }
    func getScoreFromMatchDataFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)/scoring/\(self.holeIndex)/") { (snapshot) in
            if  let score = (snapshot.value as? NSDictionary){
                var playersArray = [NSMutableDictionary]()
                for(key,value) in score{
                    if(key as! String != "par"){
                        let dict = NSMutableDictionary()
                        dict.setObject(value, forKey: key as! String as NSCopying)
                        playersArray.append(dict)
                    }
                }
                self.scoreData[self.holeIndex].players = playersArray
            }
            
            DispatchQueue.main.async(execute: {
                self.updateHoleWiseShots()
            })
        }
    }
    
    @objc func buttonAction(sender: UIButton!){
        for i in 0..<playersButton.count{
            if(i == sender.tag){
                if(!playersButton[i].isSelected){
                    playersButton[i].isSelected = true
                    self.playerId = playersButton[i].id
                    self.updateData(indexToUpdate: self.holeIndex)
                }
            }
            else{
                playersButton[i].isSelected = false
                playersButton[i].button.layer.borderColor = UIColor.clear.cgColor
            }
        }
        for data in playersButton{
            if data.isSelected{
                self.lblPlayerNameDSV.text = "\(data.name)'s Score"
                self.lblPlayerNameSSV.text = "\(data.name)'s Score"
                if(data.id == Auth.auth().currentUser!.uid){
                    self.lblPlayerNameDSV.text = "Your Score"
                    self.lblPlayerNameSSV.text = "Your Score"
                }
                data.button.layer.borderColor = UIColor.glfWhite.cgColor
            }
        }
    }
    func hideDetailScoreView(){
        scoreSecondSV.isHidden = true
        btnExpendScore.isHidden = false
        scorePopView.isHidden = true
        detailScoreSV.isHidden = true
        scoreSV.isHidden = false
    }
    func updateData(indexToUpdate:Int){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        var indexToUpdate = indexToUpdate
        indexToUpdate = indexToUpdate == -1 ? indexToUpdate+1 : indexToUpdate
        
        self.holeWiseShots = NSMutableDictionary()
        self.btnExpendScore.isHidden = false
        
        self.lblHoleNumber.text = "Hole \(indexToUpdate+1)"
        self.lblParNumber.text = "Par \(self.scoreData[indexToUpdate].par)"
        self.fairwayHitStackView.superview?.isHidden = false
        if(self.scoreData[indexToUpdate].par == 3){
            self.fairwayHitStackView.superview?.isHidden = true
        }
        var newI = self.scoreData[indexToUpdate].par - 2
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(newI)", for: .normal)
            updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[indexToUpdate].par), btn: btn as! UIButton,color:UIColor.white)
            newI += 1
            (btn as! UIButton).setTitleColor(UIColor.glfWhite, for: .normal)
        }
        self.getScoreFromMatchDataFirebase()
    }
    func updateHoleWiseShots(){
        var i = 0
        for data in scoreData[self.holeIndex].players{
            let keys = data.allKeys as! [String]
            if keys.first == self.playerId{
                if let holeData = data.value(forKey: self.playerId!) as? NSMutableDictionary{
                    holeWiseShots = holeData
                }else{
                    holeWiseShots.setDictionary(data.value(forKey: self.playerId!) as! [String:Any])
                }
            }
            i += 1
        }
        self.classicScoring = getScoreIntoClassicNode(hole:self.holeIndex,playerKey:self.playerId)
        updateValue()
    }
    func updateScoreData(){
        var i = 0
        for data in scoreData[self.holeIndex].players{
            let keys = data.allKeys as! [String]
            if keys.first == self.playerId{
                if(holeWiseShots.value(forKey: "holeOut") == nil){
                   holeWiseShots.setValue(false, forKey: "holeOut")
                }
                let dict = NSMutableDictionary()
                dict.setValue(holeWiseShots, forKey: self.playerId)
                scoreData[self.holeIndex].players[i] = dict
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
        if classicScoring.holeOut != nil && classicScoring.holeOut!{
            self.setHoleShotDetails(par:self.scoreData[self.holeIndex].par,shots:classicScoring.strokesCount!)
            self.btnScore.setTitle("\(classicScoring.strokesCount!)", for: .normal)
            self.scoreSV.isHidden = true
            self.detailScoreSV.isHidden = false
        }else{
            self.scoreSV.isHidden = false
            self.detailScoreSV.isHidden = true
            self.scoreSecondSV.isHidden = true
            self.stackViewStrokes1.isHidden = false
        }
        self.progressView.hide(navItem: self.navigationItem)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
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
    
    @objc func strokesAction(sender: UIButton!){
        let title = sender.currentTitle
        self.holeWiseShots.setObject(Int(title!)!, forKey: "strokes" as NSCopying)
        self.holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(["strokes":Int(title!)!] as [AnyHashable : Any])
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(["holeOut":true] as [AnyHashable : Any])
        self.setHoleShotDetails(par:self.scoreData[self.holeIndex].par,shots:Int(title!)!)
        self.btnScore.setTitle("\(title!)", for: .normal)
        self.scoreSV.isHidden = true
        self.detailScoreSV.isHidden = false
        sender.setTitleColor(UIColor.glfBluegreen, for: .normal)
//        sender.layer.borderWidth = 1
//        sender.layer.borderColor = UIColor.glfBluegreen.cgColor
//        for lay in sender.layer.sublayers!{
//            lay.borderWidth = 1
//            lay.borderColor = UIColor.glfBluegreen.cgColor
//        }
        updateScoreData()
    }
    
    @objc func fairwayHitAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "fairway_left"),#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "fairway_right")]
        holeWiseShots.removeObject(forKey: "fairway")
        for btn in buttonsArrayForFairwayHit{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["fairway":NSNull()])
                for btn in buttonsArrayForFairwayHit{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    let originalImage1 = imgArray[btn.tag]
                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    btn.setImage(backBtnImage1, for: .normal)
                    btn.tintColor = UIColor.glfWarmGrey
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
            btn.tintColor = UIColor.glfWarmGrey

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
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }

        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()

        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func chipShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "chipCount")
        for btn in buttonsArrayForChipShot{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["chipCount":NSNull()])
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
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func sandShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "sandCount")

        for btn in buttonsArrayForSandSide{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["sandCount":NSNull()])
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
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func penaltyShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "penaltyCount")
        for btn in buttonsArrayForPenalty{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["penaltyCount":NSNull()])
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
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    
    @objc func girAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "gir_false")]
        holeWiseShots.removeObject(forKey: "gir")
        for btn in buttonsArrayForGIR{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["gir":NSNull()])
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
            ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
        }
    }
    @objc func puttsAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "putting")
        for btn in buttonsArrayForPutts{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)/").updateChildValues(["putting":NSNull()])
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
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
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
            if(chipShot as! Int != 0) && (sandShot as! Int != 0){
                dictnary.setObject(false, forKey: "sandUpDown" as NSCopying)
                dictnary.setObject(false, forKey: "chipUpDown" as NSCopying)
            }
        }
        return dictnary
    }
    
    func getScoreIntoClassicNode(hole:Int,playerKey:String)->classicMode{
        let classicScore = classicMode()
        for data in scoreData[hole].players{
            if let dic = data.value(forKey: playerKey) as? NSMutableDictionary{
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
    func initilizeScoreNode(){
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
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
        if !(isAccept){
            ref.child("matchData/\(matchId)/").updateChildValues(scoring as! [AnyHashable : Any])
        }

    }
}
