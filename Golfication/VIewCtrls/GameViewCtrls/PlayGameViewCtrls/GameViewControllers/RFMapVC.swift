//
//  RFMapVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 09/02/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

//Thirsk and Northallerton Golf Club
//course_8110

import UIKit
import GoogleMaps
import FirebaseAuth
import ActionSheetPicker_3_0
import FirebaseDatabase
import FirebaseAnalytics
import UserNotifications
struct GreenData {
    let front: CLLocationCoordinate2D
    let center: CLLocationCoordinate2D
    let back: CLLocationCoordinate2D
}
class MarkerButton:UIButton{
    init(){
        super.init(frame:.zero)
        backgroundColor = UIColor.glfBlack50
        titleLabel?.textColor = UIColor.glfWhite
        imageView?.clipsToBounds = false
        imageView?.contentMode = .center
        layer.cornerRadius = 15.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class RFMapVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,ExitGamePopUpDelegate{
    var propertyArray = [Properties]()
    var isAcceptInvite = false
    
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var fairwayHitStackView: UIStackView!
    @IBOutlet weak var girStackView: UIStackView!
    @IBOutlet weak var puttsStackView: UIStackView!
    @IBOutlet weak var chipShotStackView: UIStackView!
    @IBOutlet weak var greenSideSandShotStackView: UIStackView!
    @IBOutlet weak var penalitiesStackView: UIStackView!
    @IBOutlet weak var stackViewStrokes1: UIStackView!
    @IBOutlet weak var stackViewStrokes2: UIStackView!
    @IBOutlet weak var stackViewStrokes3: UIStackView!
    @IBOutlet weak var stackViewStrokes4: UIStackView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnEditShots: UIButton!
    @IBOutlet weak var lblPlayerNameDSV: UILabel!
    @IBOutlet weak var lblPlayerNameSSV: UILabel!
    @IBOutlet weak var imgViewWind: UIImageView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var imgViewWindForeground: UIImageView!
    @IBOutlet weak var lblWindSpeedForeground: UILabel!
    @IBOutlet weak var lblEditShotNumber: UILabel!
    @IBOutlet weak var btnCenter: UIButton!
    
    @IBOutlet weak var exitGamePopUpView: ExitGamePopUpView!
    @IBOutlet weak var lblFrontDist: UILabel!
    @IBOutlet weak var lblCenterDist: UILabel!
    @IBOutlet weak var lblEndDist: UILabel!
    @IBOutlet weak var lblCenterHeader: UILabel!
    @IBOutlet weak var viewForground : UIView!
    
    @IBOutlet weak var stablefordView: UIView!
    @IBOutlet weak var stablefordSubView: UIView!
    @IBOutlet weak var imgViewStblReferesh: UIImageView!
    @IBOutlet weak var btnStablefordScore: UIButton!
    @IBOutlet weak var lblStblScore: UILabel!
    @IBOutlet weak var imgViewStblfordInfo: UIImageView!
    
    @IBOutlet weak var topHoleParView: UIView!
    @IBOutlet weak var topHoleParHCPView: UIView!
    @IBOutlet weak var topParView: UIView!
    @IBOutlet weak var lblTopPar: UILabel!
    @IBOutlet weak var topHCPView: UIView!
    @IBOutlet weak var lblTopHCP: UILabel!
    @IBOutlet weak var btnTopHoleNo: UIButton!
    var teeTypeArr = [(tee:String,color:String,handicap:Double)]()
    var buttonsArrayForFairwayHit = [UIButton]()
    var buttonsArrayForGIR = [UIButton]()
    var buttonsArrayForPutts = [UIButton]()
    var buttonsArrayForChipShot = [UIButton]()
    var buttonsArrayForSandSide = [UIButton]()
    var buttonsArrayForPenalty = [UIButton]()
    var buttonsArrayForStrokes = [UIButton]()
    var holeWiseShots = NSMutableDictionary()
    var playerId:String!
    var playerIndex:Int!
    var classicScoring = classicMode()
    var isFromViewDid = false
    var startingIndex = Int()
    var gameTypeIndex = Int()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    // Header IBOutlets
    @IBOutlet weak var backBtnHeader: UIButton!
    // WindRelated IBOutlests
    var firstX = CGFloat()
    var firstY = CGFloat()
    var first = false

    @IBOutlet weak var fairwayHitContainerSV: UIStackView!
    
    // Menu
    var stackViewMenu : UIStackView!
    @IBAction func btnActionMenu(_ sender: UIButton) {
        if(stackViewMenu.isHidden){
            stackViewMenu.isHidden = false
        }else{
            stackViewMenu.isHidden = true
        }
    }
    var holeOutforAppsFlyer = [Int]()
    var btnForSuggMark1 = MarkerButton()
    var btnForSuggMark2 = MarkerButton()
    @IBAction func btnActionChangeHole(_ sender: Any) {
        
        var strArr = [String]()
        for hole in self.scoring{    
            strArr.append("Hole \(hole.hole) - Par - \(hole.par)")
        }
        ActionSheetStringPicker.show(withTitle: "Select Hole", rows: strArr, initialSelection: holeIndex, doneBlock: { (picker, value, index) in
            self.holeIndex = value
            self.updateMap(indexToUpdate: value)
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func btnActionFinishRound(_ sender: Any) {
        
        var playerIndex = 0
        var i = 0
        for data in self.playersButton{
            self.holeOutforAppsFlyer[i] = self.checkHoleOutZero(playerId: data.id)
            if(data.id == Auth.auth().currentUser!.uid){
                playerIndex = i
            }
            i += 1
        }
        
        if isEdited{
            self.exitGamePopUpView.btnDiscardText = "Delete Round"
        }
        self.exitGamePopUpView.labelText = "\(self.holeOutforAppsFlyer[playerIndex])/\(scoring.count) Holes Completed."
        self.exitGamePopUpView.isHidden = false
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
        FBSomeEvents.shared.logGameEndedEvent(holesPlayed: self.holeOutforAppsFlyer[playerIndex], valueToSum: 2)
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

    func saveAndviewScore(){
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
                currentHoleWhilePlaying.setObject("\(self.scoring[self.holeIndex].hole)", forKey: "currentHole" as NSCopying)
                ref.child("matchData/\(self.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
                self.holeIndex = holIndex
                if(self.holeIndex == self.scoring.count){
                    self.holeIndex = 0
                }
                self.updateMap(indexToUpdate: self.holeIndex)
                self.updateCurrentHole(index: self.scoring[self.holeIndex].hole)
            }))
            emptyAlert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
                self.progressView.show()
                let generateStats = GenerateStats()
                generateStats.matchKey = self.matchId
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
    
    var detailedScore = NSMutableArray()
    func checkHoleOutZero(playerId:String) -> Int{
        detailedScore = NSMutableArray()
        // --------------------------- Check If User has not played game at all ------------------------
        var myVal: Int = 0
        for i in 0..<self.scoring.count{
            for dataDict in self.scoring[i].players{
                for (key,value) in dataDict{
                    if let dic = value as? NSDictionary{
                        if dic.value(forKey: "holeOut") as! Bool == true{
                            if(key as? String == playerId){
                                for (key,value) in value as! NSMutableDictionary{
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
    @IBAction func btnActionEditViewShowHide(_ sender:UIButton) {
        self.playerStatsAction(self.btnPlayerStats)
    }
    @IBAction func btnActionRestartRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
            if(!self.playersButton.isEmpty){
                self.checkIfMuliplayerJoined(matchID:self.matchId)
            }else{
                self.resetScoreNodeForMe()
            }
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
    }
    func resetScoreNodeForMe(){
        for i in 0..<self.courseData.numberOfHoles.count{
            let player = NSMutableDictionary()
            for j in 0..<playersButton.count{
                if(playersButton[j].id == Auth.auth().currentUser?.uid){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                    ref.child("matchData/\(self.matchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoring[i].players[j].addEntries(from: playerData)
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.mapView.isMyLocationEnabled = true
        let userLocation = locations.last
        userLocationForClub = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }

    @IBOutlet weak var playerStackWConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerStackWConstraint2: NSLayoutConstraint!
    func setupMultiplayersButton(){
        
        var keyData = String()
        for (key,value) in matchDataDic{
            keyData = key as! String
            if(keyData == "player"){
                var i = 0
                var name = String()
                for (k,v) in value as! NSMutableDictionary{
                    
                    let btn = UIButton()
                    btn.frame.size.width = 40
                    btn.frame.size.height = 40
                    btn.tag = i
                    btn.layer.cornerRadius = btn.frame.size.height/2
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    btn.layer.borderWidth = 2.0
                    btn.backgroundColor = UIColor.clear
                    if let img = (v as! NSMutableDictionary).value(forKeyPath: "image") as? String{
                        btn.sd_setImage(with: URL(string:img), for: .normal, placeholderImage: #imageLiteral(resourceName: "me"), completed: nil)
                        btn.layer.borderColor = UIColor.glfWhite.cgColor
                    }
                    btn.layer.borderColor = UIColor.glfWhite.cgColor
                    btn.layer.masksToBounds = true
                    self.multiPlayerSV.addArrangedSubview(btn)
                    playerStackWConstraint.constant = CGFloat(40*(i+1)) + self.multiPlayerSV.spacing
                    if i == 2{
                        playerStackWConstraint.constant = CGFloat(45*(i+1)) + self.multiPlayerSV.spacing
                    }
                    else if i == 3{
                        playerStackWConstraint.constant = CGFloat(47*(i+1)) + self.multiPlayerSV.spacing
                    }
                    else if i == 4{
                        playerStackWConstraint.constant = CGFloat(49*(i+1)) + self.multiPlayerSV.spacing
                    }
                    
                    let btn2 = UIButton()
                    btn2.frame.size.width = 40
                    btn2.frame.size.height = 40
                    btn2.tag = i
                    btn2.layer.cornerRadius = btn2.frame.size.height/2
                    btn2.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    btn2.layer.borderWidth = 2.0
                    btn2.backgroundColor = UIColor.clear
                    if let img = (v as! NSMutableDictionary).value(forKeyPath: "image") as? String{
                        btn2.sd_setImage(with: URL(string:img), for: .normal, placeholderImage: #imageLiteral(resourceName: "me"), completed: nil)
                        btn2.layer.borderColor = UIColor.glfWhite.cgColor
                    }
                    btn2.layer.borderColor = UIColor.glfWhite.cgColor
                    btn2.layer.masksToBounds = true
                    self.multiPlayerSV2.addArrangedSubview(btn2)
                    playerStackWConstraint2.constant = CGFloat(40*(i+1)) + self.multiPlayerSV2.spacing
                    if i == 2{
                        playerStackWConstraint2.constant = CGFloat(45*(i+1)) + self.multiPlayerSV2.spacing
                    }
                    else if i == 3{
                        playerStackWConstraint2.constant = CGFloat(47*(i+1)) + self.multiPlayerSV2.spacing
                    }
                    else if i == 4{
                        playerStackWConstraint2.constant = CGFloat(49*(i+1)) + self.multiPlayerSV2.spacing
                    }
                    
                    
                    self.holeOutforAppsFlyer.append(0)
                    name = (v as! NSMutableDictionary).value(forKeyPath: "name") as! String
                    self.lblPlayerNameDSV.text = "\(name)'s Score"
                    self.lblPlayerNameSSV.text = "\(name)'s Score"
                    
                    if(k as! String == Auth.auth().currentUser!.uid){
                        self.lblPlayerNameDSV.text = "Your Score"
                        self.lblPlayerNameSSV.text = "Your Score"
                    }
                    i += 1
                    playersButton.append((button:btn, isSelected: false, id: k as! String,name:name))
                    self.multiPlayerSV.isHidden = false
                    self.multiPlayerSV2.isHidden = false
                    
                    
                }
                if(i == 1){
                    self.multiPlayerSV.isHidden = true
                    self.multiPlayerSV2.isHidden = true
                }
            }
        }
        
        self.progressView.hide()
        var j = 0
        for data in playersButton{
            if data.id == Auth.auth().currentUser!.uid{
                playerId = data.id
                self.playerIndex = j
                playersButton[j].isSelected = true
                break
            }
            j += 1
        }
        self.teeTypeArr.removeAll()
        if let players = matchDataDic.value(forKey: "player") as? NSMutableDictionary{
            for data in players{
                let v = data.value
                var teeOfP = String()
                if let tee = (v as! NSMutableDictionary).value(forKeyPath: "tee") as? String{
                    teeOfP = tee
                }
                var teeColorOfP = String()
                if let tee = (v as! NSMutableDictionary).value(forKeyPath: "teeColor") as? String{
                    teeColorOfP = tee
                }
                var handicapOfP = Double()
                if let hcp = (v as! NSMutableDictionary).value(forKeyPath: "handicap") as? String{
                    handicapOfP = Double(hcp)!
                }
                if(teeOfP != "") && (handicapOfP != 0.0){
                    self.teeTypeArr.append((tee: teeOfP,color:teeColorOfP ,handicap: handicapOfP))
                }
            }
        }
        if !self.teeTypeArr.isEmpty{
            self.stablefordView.isHidden = false
            self.topHoleParView.isHidden = true
            self.topHoleParHCPView.isHidden = false
            self.imgViewStblfordInfo.isHidden = true
        }else{
            self.imgViewStblReferesh.isHidden = true
            self.lblStblScore.text = "n/a"
        }
        var currentHole = self.startingIndex
        if(self.isContinueMatch){
            
            if(self.scoring.isEmpty){
                self.initilizeScoreNode()
            }
            if let current = matchDataDic.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as? String{
                currentHole = Int(current)!
            }else{
                if let current = matchDataDic.value(forKeyPath: "currentHole") as? String{
                    currentHole = Int(current.isEmpty ? "1":current)! - 1
                }
            }
            updateScoringHoleData()
        }
        else{
            self.initilizeScoreNode()
        }
        for i in 0..<self.scoring.count{
            if(self.scoring[i].hole == currentHole){
                self.holeIndex = i
                break
            }
        }
        
        self.isFromViewDid = true
        fairwayHitContainerSV.isHidden = false
        if self.scoring[self.holeIndex].par == 3{
            fairwayHitContainerSV.isHidden = true
        }
        self.updateMap(indexToUpdate: self.holeIndex)
        btnPlayerStats.isEnabled = true
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func btnActionStableford(_ sender: Any) {
        if self.teeTypeArr.isEmpty{
            self.ifnoStableFord()
        }else{
            self.updateHoleWiseShots()
            if self.btnStablefordScore.currentTitle!.contains("Stable"){
                self.btnStablefordScore.setTitle("Net Score", for: .normal)
                self.lblStblScore.text = "\(classicScoring.netScore!)"
            }else{
                self.btnStablefordScore.setTitle("Stableford Score", for: .normal)
                self.lblStblScore.text = "\(classicScoring.stableFordScore!)"
            }
        }
    }
    func statusStableFord(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.stablefordView.isHidden = self.chkStableford
            })
        }
    }
    var chkStableford = false
    func ifnoStableFord(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if !self.chkStableford{
                    let viewCtrl = RequestSFPopup(nibName:"RequestSFPopup", bundle:nil)
                    viewCtrl.modalPresentationStyle = .overCurrentContext
                    self.present(viewCtrl, animated: true, completion: nil)
                }else{
                    
                }
            })
        }
    }
    func updateScoringHoleData(){
        for i in 0..<courseData.numberOfHoles.count{
            self.scoring[i].hole = courseData.numberOfHoles[i].hole
        }
    }
    func checkIfMuliplayerJoined(matchID:String){
        var isJoined = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(self.matchId)/player") { (snapshot) in
            var playerDict = NSMutableDictionary()
            if(snapshot.value != nil){
                print(snapshot.value as! NSMutableDictionary)
                playerDict = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                if(snapshot.value != nil){
                    for (key,value) in playerDict{
                        if(key as! String != Auth.auth().currentUser!.uid){
                            let data = value as! NSMutableDictionary
                            for (k,v) in data{
                                if(k as! String == "status"){
                                    if(v as! Int) > 1{
                                        isJoined =  true
                                        break
                                    }
                                }
                            }
                        }
                    }
                    if(isJoined){
                        self.resetScoreNodeForMe()
                    }else{
                        self.initilizeScoreNode()
                    }
                    self.holeIndex = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                        self.updateCurrentHole(index: self.scoring[self.holeIndex].hole)
                        self.updateMap(indexToUpdate: self.holeIndex)
                    })
                    
                }
            })
        }
    }
    @IBAction func btnActionDiscardRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Discard Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to Discard the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Discard Round", style: .default, handler: { (action: UIAlertAction!) in
            self.exitWithoutSave()
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
        
    }
    func exitWithoutSave(){
        self.updateFeedNode()
        if(matchId.count > 1){
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId)").removeValue()
            matchId.removeAll()
            isUpdateInfo = true
            self.navigationController?.popToRootViewController(animated:true)
            addPlayersArray.removeAllObjects()
            if mode>0{
                Analytics.logEvent("mode\(mode)_game_discarded", parameters: [:])
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            }
        }
        scoring.removeAll()
        
    }

    
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.hide()
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
            self.progressView.show()
            let group = DispatchGroup()
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            for data in dataDic{
                group.enter()
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(selectedGolfName).", type: "8", category: "finishedGame", matchDataId: self.matchId, feedKey: "")
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
        feedDict.setObject(matchDataDic.value(forKey: "timestamp") as Any, forKey: "timestamp" as NSCopying)
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
            if(self.matchDataDic.object(forKey: "player") != nil){
                let tempArray = self.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
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
            viewCtrl.finalScoreData = self.scoring
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            viewCtrl.fromGameImprovement = true
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.scoring.removeAll()
            self.matchId.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }
    private func getHCPValue(playerID:String,holeNo:Int)->Int{
        var index = 0
        var hcp = 0
        for playersdata in self.playersButton{
            if (playersdata.id == playerID){
                break
            }
            index += 1
        }
        for tee in self.courseData.holeHcpWithTee{
            if tee.hole == holeNo{
                for data in tee.teeBox where !teeTypeArr.isEmpty{
                    if (data.value(forKey: "teeType") as! String) == (self.teeTypeArr[index].tee).lowercased() && (data.value(forKey: "teeColorType") as! String) == (self.teeTypeArr[index].color).lowercased(){
                        hcp = data.value(forKey:"hcp") as? Int ?? 0
                        break
                    }
                }
                break
            }
        }
        return hcp
    }
    var isUserInsideBound = false
    
    var mapTimer = Timer()
    
    var playersButton = [(button:UIButton,isSelected:Bool,id:String,name:String)]()
    
    var locationManager = CLLocationManager()
    
    var userLocationForClub : CLLocationCoordinate2D?
    var positionsOfDotLine = [CLLocationCoordinate2D]()
    var polygonArray = [[CLLocationCoordinate2D]]()
    var isBackground : Bool{
        let state = UIApplication.shared.applicationState
        if state == .background {
            return true
        }else{
            return false
        }
    }
    //    var mapView = GMSMapView()
    var progressView = SDLoader()
    
    var markers = [GMSMarker]()
    var userMarker = GMSMarker()
    var draggingMarker = GMSMarker()
    var markerInfo = GMSMarker()
    var suggestedMarker1 = GMSMarker()
    var suggestedMarker2 = GMSMarker()
    
    var line = GMSPolyline()
    var solidLine = GMSPolyline()
    var curvedLines = GMSPolyline()
    
    var matchDataDic = NSMutableDictionary()
    
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var activePlayerData = [NSDictionary]()
    var userIdWithImage = [(id:String,url:String,name:String)]()
    
    var matchId = String()
    var courseId = String()
    var userId = String()
    
    var holeIndex = 0
    var matchType = Int()
    var tagVal = 0
    
    var isContinueMatch : Bool!
    var isUpdating :Bool!
    var isDraggingMarker : Bool!
    var holeOutFlag : Bool!
    var isSolidLinePloted = false
    var gir = Bool()
    
    
    @IBAction func viewScoreAction(_ sender: UIButton) {
        let players = NSMutableArray()
        if(matchDataDic.object(forKey: "player") != nil){
            let tempArray = matchDataDic.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                players.add(dict)
            }
        }
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = scoring
        viewCtrl.playerData = players
        viewCtrl.isContinue = true
        viewCtrl.holeHcpWithTee = self.courseData.holeHcpWithTee
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    
    func getScoreIntoClassicNode(hole:Int,playerKey:String)->classicMode{
        let classicScore = classicMode()
        if tagVal != 0{
            classicScore.strokesCount = tagVal
        }
        for data in self.scoring[hole].players{
            if let dic = (data).value(forKey: playerKey) as? NSMutableDictionary{
                if let chipShot = dic.value(forKey: "chipCount") as? Int{
                    classicScore.chipShot = chipShot
                }
                if let sandShot = dic.value(forKey: "sandCount") as? Int{
                    classicScore.sandShot = sandShot
                }
                if let strokesCount = dic.value(forKey: "strokes") as? Int{
                    if tagVal == 0{
                        classicScore.strokesCount = strokesCount
                    }
                    else{
                        classicScore.strokesCount = tagVal
                    }
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
                if let sb = dic.value(forKey: "stableFordPoints") as? Int{
                    classicScore.stableFordScore = sb
                }
                if let netScore = dic.value(forKey: "netScore") as? Int{
                    classicScore.netScore = netScore
                }
            }
        }
        return classicScore
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: NewGameVC.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: !isAcceptInvite)
                break
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        statusStableFord()
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapTimer.invalidate()
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationWillEnterForeground)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidEnterBackground)
    }
    @objc func hideStableFord(_ notification:NSNotification){
        let alertVC = UIAlertController(title: "Thank you for your time!", message: "Stableford scoring for your course should be available in the next 48 hours!", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        self.chkStableford = true
        self.stablefordView.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideStableFord"), object: nil)
    }
    // ------------------------ By Amit ----------------------
    @IBAction func scoreBtnTapped(_ sender: UIButton) {
        isScoreTapped = true
        self.scoreSV.isHidden = true
        btnDetailScoring.tag = 1
        detailScoreAction(btnDetailScoring)
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreSV2.isHidden = false
        })
        self.view.layoutIfNeeded()
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
        
    }
    @IBAction func expendScoreAction(_ sender: Any) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreSecondSV.isHidden = false
            self.btnExpendScore.isHidden = true
        })
        self.view.layoutIfNeeded()

        for btn in buttonsArrayForStrokes{
            btn.setTitle("\(btn.tag)", for: .normal)
            btn.layer.borderWidth = 0
            for lay in btn.layer.sublayers!{
                lay.borderWidth = 0
            }
        }
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
        updateColorToStrokes()
    }
    
    func updateColorToStrokes(){
        guard let strokes : Int = self.holeWiseShots.value(forKey: "strokes") as? Int else {
            for btn in buttonsArrayForStrokes{
                btn.backgroundColor = UIColor.clear
            }
            for btn in self.stackViewStrokes1.arrangedSubviews{
                (btn as! UIButton).backgroundColor = UIColor.clear
            }
            return
        }
        
        for btn in buttonsArrayForStrokes{
            if(strokes == btn.tag){
                btn.backgroundColor = UIColor.glfBluegreen
            }else{
                btn.backgroundColor = UIColor.clear
            }
        }
        if(!self.scoreSecondSV.isHidden) && (self.btnExpendScore.isHidden){
            
        }else{
            var newI = self.scoring[self.holeIndex].par - 2
            for btn in self.stackViewStrokes1.arrangedSubviews{
                (btn as! UIButton).setTitle("\(newI)", for: .normal)
                updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoring[self.holeIndex].par), btn: btn as! UIButton)
                if(strokes == newI){
                    (btn as! UIButton).backgroundColor = UIColor.glfBluegreen
                }else{
                    (btn as! UIButton).backgroundColor = UIColor.clear
                }
                newI += 1
            }
        }
    }
    
    @IBAction func playerStatsAction(_ sender: UIButton) {
        if scrlView.isHidden{
            scrlView.isHidden = false
            btnNext.isHidden = true
            btnPrev.isHidden = true
            btnPlayerStats.isHidden = true
            self.btnEditShots.isHidden = true
            scrlHConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
                self.view.layoutIfNeeded()
            })
            self.classicScoring = getScoreIntoClassicNode(hole:self.holeIndex,playerKey:self.playerId)
            self.updateValue()
        }
        else{
            isScoreExpended = false
            isScoreDetailExpended = false
            isScoreTapped = false
            self.btnEditShots.isHidden = false
            sender.tag = 0
            scoreSecondSV.isHidden = true
            btnPlayerStats.isHidden = false
            btnExpendScore.isHidden = false
            scoreSV2.isHidden = true
            scoreSV.isHidden = false
            self.detailScoreSV.isHidden = true
            btnNext.isHidden = false
            btnPrev.isHidden = false
            btnDetailScoring.tag = 0
            detailScoreAction(btnDetailScoring)
            UIView.animate(withDuration: 0.3, animations: {
                self.scrlHConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.scrlView.isHidden = true
            })
        }
    }

    @IBAction func detailScoreAction(_ sender: UIButton) {
        if sender.tag == 0{
            
//            UIView.animate(withDuration: 0.3, animations: {
                self.detailScoreSV.isHidden = true
//            })
            sender.tag = 1
            self.view.layoutIfNeeded()
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
            UIView.animate(withDuration: 0.4, animations: {
                self.btnDetailScoring.imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
        else{
//            UIView.animate(withDuration: 0.3, animations: {
                self.detailScoreSV.isHidden = false
//            })
            UIView.animate(withDuration: 0.4, animations: {
                self.btnDetailScoring.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            sender.tag = 0
            self.view.layoutIfNeeded()
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
        }
    }
    @IBOutlet weak var btnDetailScoring: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNextScrl: UIButton!
    @IBOutlet weak var btnPrevScrl: UIButton!
    @IBOutlet weak var btnExpendScore: UIButton!
    @IBOutlet weak var btnTopShotRanking: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnViewScoreCard: UIButton!
    @IBOutlet weak var btnEndRound: UIButton!
    @IBOutlet weak var btnPlayerStats: UIButton!
    @IBOutlet weak var scoreSV: UIStackView!
    @IBOutlet weak var scoreSV2: UIStackView!
    @IBOutlet weak var detailScoreSV: UIStackView!
    @IBOutlet weak var scoreSecondSV: UIStackView!
    @IBOutlet weak var scoreEndContainerSV: UIStackView!
    @IBOutlet weak var multiPlayerSV: UIStackView!
    @IBOutlet weak var multiPlayerSV2: UIStackView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var scrlHConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblHoleNumber: UILabel!
    @IBOutlet weak var lblParNumber: UILabel!
    @IBOutlet weak var btnPlayerStats2: UIButton!
    @IBOutlet weak var btnMoveToMapGround: UIButton!
    @IBOutlet weak var lblHoleNumber2: UILabel!
    @IBOutlet weak var lblParNumber2: UILabel!
    @IBOutlet weak var btnHoleSelection: UIButton!
    
    @IBOutlet weak var scrlContainerView: UIView!
    @IBOutlet weak var stackViewForDistance: UIStackView!
    
    var isScoreExpended = false
    var isScoreDetailExpended = false
    var isScoreTapped = false
    let swipeUp = UISwipeGestureRecognizer()
    let swipeDown = UISwipeGestureRecognizer()
    var courseData = CourseData()

    let swipeHeaderUp = UISwipeGestureRecognizer()
    let swipeHeaderDown = UISwipeGestureRecognizer()
    let swipeHeaderDown2 = UISwipeGestureRecognizer()

    @objc func swipedViewHeaderUp(){
        self.btnActionMoveToMap(Any.self)
    }
    @objc func swipedViewHeaderDown(){
        self.btnActionMoveToMap(Any.self)
    }
    @objc func swipedViewUp(){
        if scrlView.isHidden{
            playerStatsAction(btnPlayerStats)
        }
    }
    @objc func swipedViewDown(){
        if !scrlView.isHidden{
            playerStatsAction(btnPlayerStats)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        btnPlayerStats.isEnabled = false
        self.view.isUserInteractionEnabled = false
        let onCourse = matchDataDic.value(forKeyPath: "onCourse") as! Bool
        self.courseId = "course_\(matchDataDic.value(forKeyPath: "courseId") as! String)"
        if (onCourse){
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            let currentLocation: CLLocation = self.locationManager.location!
            self.userLocationForClub = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            self.mapView.isMyLocationEnabled = true
            if onCourseNotification == 1{
                self.registerBackgroundTask()
            }
        }
        var matchDataDictionary = NSMutableDictionary()
        if(self.isAcceptInvite){
            matchDataDictionary = self.matchDataDic
        }else{
            matchDataDictionary = matchDataDic
        }
        self.startingIndex = Int(matchDataDictionary.value(forKeyPath: "startingHole") as? String ?? "1") ?? 1
        self.gameTypeIndex = matchDataDictionary.value(forKey: "matchType") as! String == "9 holes" ? 9:18
        self.courseData.startingIndex = self.startingIndex
        self.courseData.gameTypeIndex = self.gameTypeIndex
        courseId = "course_\(matchDataDictionary.value(forKeyPath: "courseId") as! String)"
        progressView.show()
        self.courseData.getGolfCourseDataFromFirebase(courseId: courseId)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMap(_:)), name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendNotificationOnCourse(_:)), name: NSNotification.Name(rawValue: "updateLocation"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHoleFromNotification(_:)), name: NSNotification.Name(rawValue: "holeChange"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideStableFord(_:)), name: NSNotification.Name(rawValue: "hideStableFord"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        //         getGolfCourseDataFromFirebase()
    }
    @objc func appDidEnterForeground(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            break
            
        case .restricted, .denied:
            let alert = UIAlertController(title: "Need Authorization or Enable GPS from Privacy Settings", message: "This game mode is unusable if you don't authorize this app or don't enable GPS", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.backButtonAction(self.backBtnHeader)
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Do Nothing
            break
        }
    }

    // --------------------------- End -------------------------------
    @objc func sendNotificationOnCourse(_ notification:NSNotification){
        self.locationManager.startUpdatingLocation()
        var distance  = GMSGeometryDistance(self.positionsOfDotLine.last!,self.userLocationForClub!)
        var suffix = "meter"
        if(distanceFilter != 1){
            distance = distance*YARD
            suffix = "yard"
        }
        Notification.sendRangeFinderNotification(msg: "Hole \(self.scoring[self.holeIndex].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDic.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0)
        debugPrint("distance",distance)
    }
    @objc func changeHoleFromNotification(_ notification:NSNotification){
        if let nextOrPrev = notification.object as? String{
            if(nextOrPrev == "next"){
                self.nextAction(self.btnNext)
            }else{
                self.previousAction(self.btnPrev)
            }
        }
    }
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    @objc func appDidEnterBackground() {
        let thePresenter = self.navigationController?.visibleViewController
        if (thePresenter != nil) && (thePresenter?.isKind(of:RFMapVC.self))! {
            if onCourseNotification == 0{
                self.mapTimer.invalidate()
            }else{
                self.updateMap(indexToUpdate: self.holeIndex)
            }
        }else{
            self.mapTimer.invalidate()
        }
    }
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).imageView?.tintImageColor(color: UIColor.glfWhite)
                
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).imageView?.tintImageColor(color: UIColor.glfWhite)
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).setTitleColor(UIColor.glfWhite, for: .selected)
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).setTitleColor(UIColor.glfWhite, for: .selected)
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).setTitleColor(UIColor.glfWhite, for: .selected)
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
                (view as! UIButton).layer.borderColor = UIColor.glfWhite.cgColor
                (view as! UIButton).setTitleColor(UIColor.glfWhite, for: .selected)
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
    func initalSetup(){
        lblEditShotNumber.layer.cornerRadius = lblEditShotNumber.frame.size.height/2
        lblEditShotNumber.layer.masksToBounds = true
        
        topHCPView.setCornerView(color: UIColor.glfWhite.cgColor)
        topParView.setCornerView(color: UIColor.glfWhite.cgColor)
        btnTopHoleNo.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnTopHoleNo.frame.height/2)
        stablefordSubView.setCornerView(color: UIColor.glfWhite.cgColor)
        imgViewStblReferesh.tintImageColor(color: UIColor.glfWhite)
        scrlView.isHidden = true
        btnNext.isHidden = false
        btnPrev.isHidden = false
        btnDetailScoring.setCorner(color: UIColor.glfWhite.cgColor)
        btnNext.setCircle(frame: self.btnNext.frame)
        btnPrev.setCircle(frame: self.btnPrev.frame)
        btnNextScrl.setCircle(frame: btnNextScrl.frame)
        btnPrevScrl.setCircle(frame: btnPrevScrl.frame)
        self.exitGamePopUpView.show(navItem: self.navigationItem)
        self.exitGamePopUpView.delegate = self
        self.exitGamePopUpView.isHidden = true
        
        btnScore.setCornerWithCircleWidthOne(color: UIColor.white.cgColor)
        self.mapView.mapType = GMSMapViewType.satellite
        
        btnForSuggMark1.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        btnForSuggMark1.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark1.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        btnForSuggMark2.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        btnForSuggMark2.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark2.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        
        btnTopShotRanking.layer.cornerRadius = 10.0
        btnTopShotRanking.layer.masksToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = btnTopShotRanking.bounds
        btnTopShotRanking.layer.addSublayer(gradient)
        
        btnShotRanking.layer.cornerRadius = 10.0
        btnShotRanking.layer.masksToBounds = true
        let gradient1 = CAGradientLayer()
        gradient1.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient1.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient1.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient1.frame = btnShotRanking.bounds
        btnShotRanking.layer.addSublayer(gradient1)
        
        btnViewScoreCard.layer.cornerRadius = 15.0
        btnViewScoreCard.layer.masksToBounds = true
        let gradient2 = CAGradientLayer()
        gradient2.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient2.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient2.frame = btnViewScoreCard.bounds
        btnViewScoreCard.layer.addSublayer(gradient2)
        
        btnEndRound.backgroundColor = UIColor.clear
        btnEndRound.layer.borderWidth = 1.0
        btnEndRound.layer.borderColor = UIColor.white.cgColor
        btnEndRound.layer.cornerRadius = 15.0
        
        detailScoreAction(btnDetailScoring)
        
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.addTarget(self, action: #selector(self.swipedViewUp))
        btnPlayerStats.addGestureRecognizer(swipeUp)

        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.addTarget(self, action: #selector(self.swipedViewDown))
        scrlView.addGestureRecognizer(swipeDown)

        swipeHeaderUp.direction = UISwipeGestureRecognizerDirection.up
        swipeHeaderUp.addTarget(self, action: #selector(self.swipedViewHeaderUp))
        viewForground.addGestureRecognizer(swipeHeaderUp)

        swipeHeaderDown.direction = UISwipeGestureRecognizerDirection.down
        swipeHeaderDown.addTarget(self, action: #selector(self.swipedViewHeaderDown))
        topHeaderView.addGestureRecognizer(swipeHeaderDown)

        swipeHeaderDown2.direction = UISwipeGestureRecognizerDirection.down
        swipeHeaderDown2.addTarget(self, action: #selector(self.swipedViewHeaderDown))
        btnCenter.superview?.addGestureRecognizer(swipeHeaderDown2)
        
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(sender:)))
//        self.btnPlayerStats.addGestureRecognizer(gesture)
        
        multiPlayerSV.isHidden = true
        multiPlayerSV2.isHidden = true
        
        btnCenter.roundCorners([.bottomLeft,.bottomRight], radius: 3.0)
        
        self.btnEditShots.setCircle(frame: self.btnEditShots.frame)
        let originalImage =  #imageLiteral(resourceName: "backArrow")
        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backBtnHeader.setImage(backBtnImage, for: .normal)
        backBtnHeader.tintColor = UIColor.glfWhite
        
        btnCenter.roundCorners([.bottomLeft,.bottomRight], radius: 3.0)
        
        btnPlayerStats.setCircle(frame: self.btnPlayerStats.frame)
        let layer = CAGradientLayer()
        layer.frame.size = btnPlayerStats.frame.size
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 1/2, y: 1)
        layer.colors = [UIColor.glfBlack50.cgColor, UIColor.glfBlack50.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.locations = [0.0 ,0.5, 0.5, 1.0]
        layer.cornerRadius = self.btnPlayerStats.frame.height/2
        btnPlayerStats.layer.insertSublayer(layer, at: 0)
        
        btnPlayerStats2.imageView?.clipsToBounds = false
        btnPlayerStats2.imageView?.contentMode = .center
        btnPlayerStats2.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        btnMoveToMapGround.roundCorners([.bottomLeft,.bottomRight], radius: 3.0)

        self.mapView.settings.consumesGesturesInView = true
        for gestureRecognizer in self.mapView.gestureRecognizers! {
            gestureRecognizer.addTarget(self, action: #selector(RFMapVC.handleTap(_:)))
        }
        self.detailScoreSV.isHidden = true
        
        setInitialUI()
        
    }
    /*
    @objc func wasDragged(sender: UIPanGestureRecognizer) {
        self.view.bringSubview(toFront: sender.view!)
        var translatedPoint = sender.translation(in: self.view)
        if sender.state == .began {
            firstX = sender.view!.center.x
            firstY = sender.view!.center.y
        }
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        sender.view!.center = translatedPoint
        if sender.state == .ended {
            let velocityX: CGFloat = (0.2 * sender.velocity(in: self.view).x)
            let finalX: CGFloat = firstX
            var finalY: CGFloat = translatedPoint.y + (0.35 * sender.velocity(in: self.view).y)
            
            let screenSize = UIScreen.main.bounds.size
            let height = screenSize.height
            var  UPHeight = CGFloat()
            var  DownHeight = CGFloat()
            if height == 568
            {
                UPHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) + 300
                DownHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) - 20
            }
            else if height == 667
            {
                UPHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) + 378
                DownHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) - 20
            }
            else if height == 736
            {
                UPHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) + 445
                DownHeight = (self.view.frame.size.height - self.view.frame.size.height / 3) - 20
            }
            if translatedPoint.y < UPHeight {
                finalY = DownHeight
//                self.SwipeGestureImage.image = UIImage.init(named: "down.png")
            }
            else if translatedPoint.y > DownHeight {
                finalY = UPHeight;
//                self.SwipeGestureImage.image = UIImage.init(named: "up.png")
            }
            let animationDuration: CGFloat = (abs(velocityX) * 0.0002) + 0.2
            print("finalX = \(finalX) , finalY = \(finalY)")
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(TimeInterval(animationDuration))
            UIView.setAnimationCurve(.easeOut)
            UIView.setAnimationDelegate(self)
            //            UIView.setAnimationDidStopSelector(#selector(self.animationDidFinish))
            sender.view!.center = CGPoint(x: finalX, y: finalY)
            UIView.commitAnimations()
        }
    }*/
    func updateNotificationFor30Minutes(){
        ref.child("matchData/\(self.matchId)/scoring").observe(DataEventType.value, with: { (snapshot) in
            Notification.sendLocaNotificatonToUser()
        })
    }
    @IBAction func btnActionMoveToMap(_ sender: Any) {
        if(self.viewForground.isHidden){
            self.showHideViews(isHide:true)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn],
                           animations: {
                            self.viewForground.center.y += self.viewForground.bounds.height
                            self.btnMoveToMapGround.center.y += self.viewForground.bounds.height
                            self.btnMoveToMapGround.layoutIfNeeded()
                            self.viewForground.layoutIfNeeded()
            }, completion:nil)

        }else{
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn],
                           animations: {
                            self.viewForground.center.y -= self.viewForground.bounds.height
                            self.btnMoveToMapGround.center.y -= self.viewForground.bounds.height
                            self.btnMoveToMapGround.layoutIfNeeded()
                            self.viewForground.layoutIfNeeded()
            },  completion: {
                (value: Bool) in
                self.showHideViews(isHide:false)
            })
        }
    }
    
    func showHideViews(isHide:Bool){
        if !(scrlView.isHidden){
            scrlView.isHidden = true
        }
        self.btnNext.isHidden = false
        self.btnPrev.isHidden = false
        
        self.btnCenter.isHidden = isHide
        self.imgViewWind.isHidden = isHide
        self.lblWindSpeed.isHidden = isHide
        self.btnPlayerStats.isHidden = isHide
        self.btnEditShots.isHidden = isHide
        self.viewForground.isHidden = !isHide
        self.lblCenterHeader.superview!.isHidden = isHide
        self.btnMoveToMapGround.isHidden = !isHide
        UIView.animate(withDuration: 0.4, animations: {
            self.btnMoveToMapGround.imageView?.transform = CGAffineTransform(rotationAngle: (180 * CGFloat(Double.pi)) / 180.0)
        })
    }
    func plotMarker(position:CLLocationCoordinate2D, userData:Int){
        let marker = GMSMarker(position: position)
        marker.title = "Point"
        marker.userData = userData
        marker.icon = #imageLiteral(resourceName: "target")
        marker.map = mapView
        if(marker.userData as! Int == 44){
            marker.isDraggable = false
        }
        else{
            marker.isDraggable = true
        }
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        
        if userData == 0{
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            btn.setCircle(frame: btn.frame)
            btn.isUserInteractionEnabled = false
            if let img = (Auth.auth().currentUser?.photoURL){
                btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
            }
            else{
                btn.backgroundColor = UIColor.glfWhite
                let name = Auth.auth().currentUser?.displayName
                btn.setTitle("\(name?.first ?? " ")", for: .normal)
                btn.setTitleColor(UIColor.glfBlack, for: .normal)
            }
            marker.iconView = btn
        }
        if(userData == 2){
            marker.icon = #imageLiteral(resourceName: "holeflag")
            marker.groundAnchor = CGPoint(x:0,y:1)
        }
        markers.append(marker)
    }
    
    func plotLine(positions:[CLLocationCoordinate2D]){
        let path = GMSMutablePath()
        for position in positions{
            path.add(position)
        }
        line.map = nil
        line = GMSPolyline(path: path)
        let lengths:[NSNumber] = [2,2]
        let styles = [GMSStrokeStyle.solidColor(UIColor.glfWhite), GMSStrokeStyle.solidColor(UIColor.clear)]
        line.spans = GMSStyleSpans(line.path!,styles , lengths as [NSNumber], GMSLengthKind(rawValue: 1)!)
        line.strokeWidth = 2.0
        line.geodesic = true
        line.map = mapView
        plotSuggestedMarkers(position: positions)
    }
    func plotSolidLine(positions:[CLLocationCoordinate2D]){
        isSolidLinePloted = true
        let path = GMSMutablePath()
        for position in positions{
            path.add(position)
        }
        solidLine.map = nil
        solidLine = GMSPolyline(path: path)
        solidLine.strokeWidth = 2.0
        solidLine.strokeColor = UIColor.glfWhite
        solidLine.geodesic = true
        solidLine.map = mapView
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn.setCircle(frame: btn.frame)
        btn.isUserInteractionEnabled = false
        if let img = (Auth.auth().currentUser?.photoURL){
            btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
        }
        else{
            btn.backgroundColor = UIColor.glfWhite
            let name = Auth.auth().currentUser?.displayName
            btn.setTitle("\(name?.first ?? " ")", for: .normal)
        }
        
        userMarker.position = positions.first!
        userMarker.title = "user"
        userMarker.userData = "-1"
        userMarker.iconView = btn
        userMarker.map = mapView
    }
    
    func rotateView(latlng1:CLLocationCoordinate2D,latlng2:CLLocationCoordinate2D)->Double{
        let bearingAngle = GMSGeometryHeading(latlng1, latlng2)
        return bearingAngle
    }
    
    func updateLine(mapView:GMSMapView, marker:GMSMarker){
        isUpdating = true
        draggingMarker = marker
        if(!positionsOfDotLine.isEmpty && marker.title == "Point" ){
            positionsOfDotLine.remove(at: marker.userData as! Int)
            positionsOfDotLine.insert(marker.position, at: marker.userData as! Int)
            //print("Moving only dashedLine")
            plotLine(positions: positionsOfDotLine)
        }
    }
    
    
    func mapView (_ mapView:GMSMapView, didBeginDragging didBeginDraggingMarker:GMSMarker){
        updateLine(mapView: mapView, marker: didBeginDraggingMarker)
    }
    
    func mapView (_ mapView: GMSMapView, didDrag didDragMarker:GMSMarker){
        updateLine(mapView: mapView, marker: didDragMarker)
    }
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker){
        updateLine(mapView: mapView, marker: didEndDraggingMarker)
    }
    func mapView(_ mapView: GMSMapView,  marker:GMSMarker)->Bool{
        marker.map = nil
        return true
    }
    
    func getPlayersList(){
        self.activePlayerData.removeAll()
        for (key,value) in self.matchDataDic{
            if(key as! String == "player"){
                for (k,v) in value as! NSMutableDictionary{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    self.activePlayerData.append(dict)
                }
            }
            if(key as! String == "matchType"){
                let matchType = value as! String
                self.matchType = (matchType.count == 7 ? 9 : 18 )
                
            }
        }
    }

    
    func setFronBackCenter(ind:Int,currentLocation:CLLocationCoordinate2D)->GreenData{
        var front = CLLocationCoordinate2D()
        var end = CLLocationCoordinate2D()
        
        var heading = GMSGeometryHeading(courseData.centerPointOfTeeNGreen[ind].green,currentLocation)
        for i in 1..<50{
            let point = GMSGeometryOffset(courseData.centerPointOfTeeNGreen[ind].green,Double(i), heading)
            if(callFindPositionInsideFeature(position:point) != "G"){
                front = point
                break
            }
        }
        heading = GMSGeometryHeading(currentLocation,courseData.centerPointOfTeeNGreen[ind].green)
        for i in 1..<50{
            let point = GMSGeometryOffset(courseData.centerPointOfTeeNGreen[ind].green, Double(i), heading)
            if(callFindPositionInsideFeature(position:point) != "G"){
                end = point
                break
            }
        }
        return GreenData(front: front, center:courseData.centerPointOfTeeNGreen[ind].green , back: end)
    }
    func callFindPositionInsideFeature(position:CLLocationCoordinate2D)->String{
        var featureName = "R"
        for data in courseData.numberOfHoles[self.holeIndex].fairway{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "F"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].gb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "GB"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].fb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "FB"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].wh{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "WH"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].tee{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "T"
                break
            }
        }
        if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature:courseData.numberOfHoles[holeIndex].green)){
            featureName = "G"
        }
        return featureName
    }
    func updateWindSpeed(latLng:CLLocationCoordinate2D,indexToUpdate:Int){
        let lat = latLng.latitude
        let lng = latLng.longitude
        BackgroundMapStats.getDataFromJson(lattitude: lat , longitude: lng, onCompletion: { response,arg  in
            DispatchQueue.main.async(execute: {
                let headingOfHole = GMSGeometryHeading(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee,self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
                debugPrint(response!)
                var windHeading = Double()
                for data in response!{
                    debugPrint(data.key)
                    if data.key == "wind"{
                        let windSpeed = (data.value as AnyObject).value(forKey: "speed") as! Double
                        let windSpeedWithUnit = windSpeed * 2.23694
                        self.lblWindSpeed.text = " \(windSpeedWithUnit.rounded(toPlaces: 1)) mph"
                        self.lblWindSpeedForeground.text = "WIND \(windSpeedWithUnit.rounded(toPlaces: 1)) mph"
                        if(distanceFilter == 1){
                            self.lblWindSpeed.text = " \((windSpeedWithUnit*1.60934).rounded(toPlaces: 1)) km/h"
                            self.lblWindSpeedForeground.text = "WIND \((windSpeedWithUnit*1.60934).rounded(toPlaces: 1)) km/h"
                        }
                        if let degree = (data.value as AnyObject).value(forKey: "deg") as? Double{
                            windHeading = degree + 90
                        }
                        let rotationAngle = headingOfHole - windHeading
                        UIButton.animate(withDuration: 2.0, animations: {
                            self.imgViewWind.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                            self.imgViewWindForeground.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                        })
                        break
                    }
                }
                } as @convention(block) () -> Void)
        })
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
    var previousLocation : CLLocationCoordinate2D!
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.mapView.settings.scrollGestures = true
        if(!self.scrlView.isHidden){
            self.playerStatsAction(self.btnPlayerStats)
            self.lblEditShotNumber.isHidden = self.btnPlayerStats.isHidden ? true:false
        }
        
        if(sender.numberOfTouches > 0){
            var positions = CGPoint()
            var newPosition = CLLocationCoordinate2D()
            let currentZoom = self.mapView.camera.zoom
            switch (sender.state){
            case .changed:
                positions = sender.location(in: self.mapView)
                newPosition = self.mapView.projection.coordinate(for: positions)
                let ind = getNearbymarkers(position: newPosition,markers:markers)
                debugPrint(ind)
                if(self.positionsOfDotLine.count>2 && markers[ind].map != nil){
                    let distance = GMSGeometryDistance(markers[ind].position, newPosition)
                    if(distance < self.getDistanceWithZoom(zoom: currentZoom)) && sender.numberOfTouches != 2{
                        debugPrint(currentZoom)
                        debugPrint("changed")
                        debugPrint(distance)
                        markers[ind].position = newPosition
                        self.mapView.settings.scrollGestures = false
                        updateLine(mapView: mapView, marker: markers[ind])
                        isDraggingMarker = true
                        previousLocation = positionsOfDotLine[0]
                    }
                }
                break
            default:
                break
            }
        }
    }
    @objc func strokesAction(sender: UIButton!){
        let title = sender.currentTitle
        lblEditShotNumber.text = " \(title!) "

        self.holeWiseShots.setObject(Int(title!)!, forKey: "strokes" as NSCopying)
        self.holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(["strokes":Int(title!)!] as [AnyHashable : Any])
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(["holeOut":true] as [AnyHashable : Any])
        self.setHoleShotDetails(par:self.scoring[self.holeIndex].par,shots:Int(title!)!)
        self.btnScore.setTitle("\(title!)", for: .normal)
        isScoreTapped = true
        self.scoreSV.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreSV2.isHidden = false
        })
        self.view.layoutIfNeeded()
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
        if(!self.teeTypeArr.isEmpty){
            self.uploadStableFordPints(playerId: self.playerId,strokes:Int(title!)!)
        }else{
            updateScoreData()
        }
    }
    func calculateTotalExtraShots(playerID:String)->Double{
        var index = 0
        for playersdata in self.playersButton{
            if (playersdata.isSelected){
                break
            }
            index += 1
        }
        var slopeIndex = 0
        for data in teeArr{
            if(data.type.lowercased() == self.teeTypeArr[index].tee.lowercased()) && (data.name.lowercased() == self.teeTypeArr[index].color.lowercased()){
                break
            }
            slopeIndex += 1
        }
        let data = (self.teeTypeArr[index].handicap * Double(teeArr[slopeIndex].slope)!)
        return (Double(data / 113)).rounded()
    }
    func uploadStableFordPints(playerId:String,strokes:Int){
        var index = 0
        for playersdata in self.playersButton{
            if (playersdata.isSelected){
                break
            }
            index += 1
        }
        let par = self.scoring[holeIndex].par
        let courseHCP = Int(self.calculateTotalExtraShots(playerID: playerId))
        let temp = courseHCP/18
        var totalShotsInThishole = temp+par
        let hcp = self.getHCPValue(playerID: playerId, holeNo: self.scoring[holeIndex].hole)
        
        if (courseHCP - temp*18 >= hcp) {
            totalShotsInThishole += 1;
        }
        var sbPoint = totalShotsInThishole - strokes + 2
        if sbPoint<0 {
            sbPoint = 0
        }
        let netScore = strokes - (totalShotsInThishole - par)
        holeWiseShots.setObject(sbPoint, forKey: "stableFordPoints" as NSCopying)
        lblStblScore.text = "\(sbPoint)"
        btnStablefordScore.setTitle("Stableford Score", for: .normal)
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(playerId)/stableFordPoints").setValue(sbPoint)
        holeWiseShots.setObject(netScore, forKey: "netScore" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(playerId)/netScore").setValue(netScore)
        updateScoreData()
    }
    @IBAction func btnActionScore(_ sender: UIButton) {

        if (self.btnExpendScore.isHidden){
            for btn in buttonsArrayForStrokes{
                btn.setTitle("\(btn.tag)", for: .normal)
                btn.layer.borderWidth = 0
                for lay in btn.layer.sublayers!{
                    lay.borderWidth = 0
                }
            }
        }
        self.updateValue()
        self.scoreSV.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreSV2.isHidden = true
        })
        updateColorToStrokes()
    }
    func updateScoreData(){
        var i = 0
        for data in scoring[self.holeIndex].players{
            let keys = data.allKeys as! [String]
            if keys.first == self.playerId{
                if(holeWiseShots.value(forKey: "holeOut") == nil){
                    holeWiseShots.setValue(false, forKey: "holeOut")
                }
                let dict = NSMutableDictionary()
                dict.setValue(holeWiseShots, forKey: self.playerId)
                scoring[self.holeIndex].players[i] = dict
            }
            i += 1
        }
    }
    func updateHoleWiseShots(){
        var i = 0
        for data in self.scoring[self.holeIndex].players{
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
            buttonsArrayForChipShot[classicScoring.chipShot!%10].setTitleColor(UIColor.glfWhite, for: .selected)
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
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].setTitleColor(UIColor.glfWhite, for: .selected)
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
                buttonsArrayForSandSide[classicScoring.sandShot!%10].setTitleColor(UIColor.glfWhite, for: .selected)
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
                buttonsArrayForPutts[classicScoring.putting!%10].setTitleColor(UIColor.glfWhite, for: .selected)
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
            btn.imageView?.tintImageColor(color: UIColor.glfWhite)
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
        // && classicScoring.holeOut!
        if classicScoring.strokesCount != nil{
            self.setHoleShotDetails(par:self.scoring[self.holeIndex].par,shots:classicScoring.strokesCount!)
            self.btnScore.setTitle("\(classicScoring.strokesCount!)", for: .normal)
            self.scoreSV.isHidden = true
            self.scoreSV2.isHidden = false
            lblEditShotNumber.isHidden = self.btnPlayerStats.isHidden ? true:false
            lblEditShotNumber.text = " \(classicScoring.strokesCount!) "
//            self.lblStblScore.text = "\(self.classicScoring.strokesCount!)"
//            self.btnStablefordScore.setTitle("Stableford Score", for: .normal)
        }else{
            self.scoreSV.isHidden = false
            self.scoreSV2.isHidden = true
            lblEditShotNumber.isHidden = true
        }
        updateColorToStrokes()
    }
    func updateStrokesButtonWithoutStrokes(strokes:Int,btn:UIButton){
        if strokes <= -2 || strokes <= -3{
            //double circle
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = UIColor.glfWhite.cgColor
            layer.cornerRadius = layer.frame.height/2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = btn.frame.height/2
            btn.layer.borderColor = UIColor.glfWhite.cgColor
            
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
            btn.layer.borderColor = UIColor.glfWhite.cgColor
            btn.layer.cornerRadius = btn.frame.size.height/2
        }
            
        else if strokes == 1{
            //single square
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.glfWhite.cgColor
        }
            
        else if strokes >= 2 || strokes >= 3{
            //double square
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = UIColor.glfWhite.cgColor
            layer.cornerRadius = 2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 2
            btn.layer.borderColor = UIColor.glfWhite.cgColor
        }
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
                    btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            let originalImage1 = imgArray[btn.tag]
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(backBtnImage1, for: .normal)
            btn.imageView?.tintImageColor(color: UIColor.glfWhite)
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
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
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
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
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
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
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
            btn.imageView?.tintImageColor(color: UIColor.glfWhite)
            btn.isHidden = true
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
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
                btn.setTitleColor(UIColor.glfWhite, for: .normal)
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
    
    func setHoleShotDetails(par:Int,shots:Int){
        var holeFinishStatus = String()
        if (shots > par) {
            if (shots - par > 1) {
                holeFinishStatus = " \(shots-par) Bogey"
            } else {
                holeFinishStatus = " Bogey"
            }
        } else if (shots < par) {
            if (par == 3) {
                if (par - shots == 1) {
                    holeFinishStatus = "  Birdie  "
                } else if (par - shots == 2) {
                    holeFinishStatus = " Hole In One "
                }
            } else if (par == 4) {
                if (par - shots == 1) {
                    holeFinishStatus = "  Birdie  "
                } else if (par - shots == 2) {
                    holeFinishStatus = "  Eagle  "
                } else if (par - shots == 3) {
                    holeFinishStatus = " Hole In One "
                }
            } else if (par == 5) {
                if (par - shots == 1) {
                    holeFinishStatus = "  Birdie  "
                } else if (par - shots == 2) {
                    holeFinishStatus = "  Eagle  "
                } else if (par - shots == 3) {
                    holeFinishStatus = "  Albatross  "
                } else if (par - shots == 4) {
                    holeFinishStatus = " Hole In One "
                }
            }
        } else if (shots == par) {
            holeFinishStatus = "  Par  "
        }
        btnShotRanking.setTitle(holeFinishStatus, for: .normal)
        btnTopShotRanking.setTitle(holeFinishStatus, for: .normal)
        btnTopShotRanking.isHidden = false
    }
    
    
    func getNearbymarkers(position:CLLocationCoordinate2D,markers:[GMSMarker])->Int{
        var distanceArray = [Double]()
        for markers in markers{
            let distance = GMSGeometryDistance(markers.position, position)
            distanceArray.append(distance)
            debugPrint(markers.title!)
        }
        return distanceArray.index(of: distanceArray.min()!) ?? 0
    }
    func initilizeScoreNode(){
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
        self.scoring.removeAll()
        for i in 0..<courseData.numberOfHoles.count{
            self.scoring.append((hole: courseData.numberOfHoles[i].hole, par: 0,players:[NSMutableDictionary]()))
            let player = NSMutableDictionary()
            for j in 0..<playersButton.count{
                let playerScore = NSMutableDictionary()
                let playerData = ["holeOut":false] as [String : Any]
                player.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                playerScore.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                self.scoring[i].players.append(playerScore)
            }
            self.scoring[i].par = courseData.numberOfHoles[i].par
            player.setObject(courseData.numberOfHoles[i].par, forKey: "par" as NSCopying)
            holeArray.append(player)
        }
        scoring.setObject(holeArray, forKey: "scoring" as NSCopying)
        if(!isAcceptInvite) && (matchId.count > 1){
            ref.child("matchData/\(self.matchId)/").updateChildValues(scoring as! [AnyHashable : Any])
        }
    }
    func getScoreFromMatchDataFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)/scoring/\(self.holeIndex)/") { (snapshot) in
            self.progressView.show()
            if  let score = (snapshot.value as? NSDictionary){
                var playersArray = [NSMutableDictionary]()
                for(key,value) in score{
                    if(key as! String != "par"){
                        let dict = NSMutableDictionary()
                        dict.setObject(value, forKey: key as! String as NSCopying)
                        playersArray.append(dict)
                    }
                }
                self.scoring[self.holeIndex].players = playersArray
            }
            
            DispatchQueue.main.async(execute: {
                self.progressView.hide()
                self.updateHoleWiseShots()
            })
        }
    }
    // Update Map - removing all markers and features from map and reload map with new Features and details.
    func updateMap(indexToUpdate:Int){
        self.suggestedMarker1.map = nil
        self.suggestedMarker2.map = nil
        var indexToUpdate = indexToUpdate
        mapTimer.invalidate()
        isSolidLinePloted = false
        mapView.clear()
        isDraggingMarker = false
        isUpdating = false
        holeOutFlag = false
        curvedLines.map = nil
        if(self.scrlView.isHidden){
          self.isFromViewDid = true
        }
        self.scrlView.isHidden = true
        self.first = false
        indexToUpdate = indexToUpdate == -1 ? indexToUpdate+1 : indexToUpdate
        self.isUpdating = false
        btnTopShotRanking.setTitle("", for: .normal)
        btnTopShotRanking.isHidden = true
        markers.removeAll()
        self.lblHoleNumber.text = "\(self.scoring[indexToUpdate].hole)"
        self.lblHoleNumber2.text = "Hole\(self.scoring[indexToUpdate].hole)"
        self.lblParNumber.text = "par \(self.scoring[indexToUpdate].par)"
        self.lblParNumber2.text = "par \(self.scoring[indexToUpdate].par)"
        
        self.lblTopPar.text = "PAR \(self.scoring[indexToUpdate].par)"
        let hcp = self.getHCPValue(playerID: self.playerId, holeNo: self.scoring[indexToUpdate].hole)
        self.lblTopHCP.text = "HCP \(hcp == 0 ? "-":"\(hcp)")"
        
        locationManager.startUpdatingLocation()
        self.positionsOfDotLine.removeAll()
        if(self.userLocationForClub != nil) && (self.playerId == Auth.auth().currentUser!.uid){
            self.positionsOfDotLine.append(self.userLocationForClub!)
        }else{
            self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
        }
        self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].fairway)
        self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
        self.updateWindSpeed(latLng: positionsOfDotLine[1], indexToUpdate: indexToUpdate)
        let distance = GMSGeometryDistance(self.positionsOfDotLine.first!,self.positionsOfDotLine.last!) * YARD
        let heading = GMSGeometryHeading(self.positionsOfDotLine.first!,self.positionsOfDotLine.last!)
        if(distance < 250){
            positionsOfDotLine[1] = GMSGeometryOffset(self.positionsOfDotLine.last!, -1, heading)
        }
        self.mapView.animate(toLocation: positionsOfDotLine[1])
        self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
        let zoomLevel = BackgroundMapStats.getTheZoomLevel(positionsOfDotLine:positionsOfDotLine)
        self.mapView.setMinZoom(zoomLevel.1-1, maxZoom: 22.0)
        
        for i in 0..<positionsOfDotLine.count{
            self.plotMarker(position: positionsOfDotLine[i], userData: i)
        }
        if(playersButton.count > 1){
            plotLine(positions: positionsOfDotLine)
            if(suggestedMarker1.map != nil ){
                plotSuggestedMarkers(position: positionsOfDotLine)
            }
        }
        self.getScoreFromMatchDataFirebase()
        if (btnExpendScore.isHidden){
            UIView.animate(withDuration: 0.3, animations: {
                self.scoreSecondSV.isHidden = true
                self.btnExpendScore.isHidden = false
            })
        }
        var newI = self.scoring[indexToUpdate].par - 2
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(newI)", for: .normal)
            updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoring[indexToUpdate].par), btn: btn as! UIButton)
            newI += 1
        }
        var counter = 0
        if(userLocationForClub != nil) && (self.playerId == Auth.auth().currentUser!.uid){
            mapTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                if(self.positionsOfDotLine.count > 2){
                    if self.isBackground{
                        if(counter%60 == 0){
                            self.locationManager.startUpdatingLocation()
                        }
                    }else{
                        self.locationManager.startUpdatingLocation()
                    }
                    let distance  = GMSGeometryDistance(self.positionsOfDotLine.first!,self.userLocationForClub!)
                    if (distance < 15000.0){
                        self.positionsOfDotLine.remove(at: 0)
                        self.positionsOfDotLine.insert(self.userLocationForClub!, at: 0)
                        self.isUserInsideBound = true
                        self.markers[0].position = self.positionsOfDotLine.first!
                        if(self.previousLocation != nil){
                            let newDis = GMSGeometryDistance(self.positionsOfDotLine.first!, self.previousLocation)
                            if(newDis > 10){
                                self.first = false
                            }
                        }
                        
                        if(!self.first){
                            let newDist = GMSGeometryDistance(self.positionsOfDotLine.first!,self.positionsOfDotLine.last!)
                            if(newDist > 225){
                                self.positionsOfDotLine[1] = GMSGeometryOffset(self.positionsOfDotLine.first!, 225, GMSGeometryHeading(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!))
                                self.markers[1].position = self.positionsOfDotLine[1]
                            }
                            self.first = true
                        }
                        self.plotLine(positions: self.positionsOfDotLine)
                        var data : GreenData!
                        if(self.courseData.holeGreenDataArr.isEmpty){
                            data = self.setFronBackCenter(ind: indexToUpdate, currentLocation: self.userLocationForClub!)
                        }else{
                            data = self.courseData.holeGreenDataArr[indexToUpdate]
                        }
                        var distanceF = GMSGeometryDistance(data.front,self.userLocationForClub!) * YARD
                        var distanceC = GMSGeometryDistance(data.center,self.userLocationForClub!) * YARD
                        var distanceE = GMSGeometryDistance(data.back,self.userLocationForClub!) * YARD
                        var suffix = "yd"
                        if(distanceFilter == 1){
                            suffix = "m"
                            distanceF = distanceF/YARD
                            distanceC = distanceC/YARD
                            distanceE = distanceE/YARD
                        }
                        self.lblFrontDist.text = "\(Int(distanceF)) \(suffix)"
                        self.lblCenterDist.text = "\(Int(distanceC)) \(suffix)"
                        self.lblEndDist.text = "\(Int(distanceE)) \(suffix)"
                        self.lblCenterHeader.text = "\(Int(distanceC)) \(suffix)"
                        if(counter%60 == 0){
                            Notification.sendRangeFinderNotification(msg: "Hole \(self.scoring[indexToUpdate].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDic.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distanceC)) \(suffix)", subtitle:"",timer:1.0)
                        }
                        counter += 2
                    }
                    else{
                        let alert = UIAlertController(title: "Alert" , message: "You are not inside the Hole Boundary Switching Back to GPS OFF Mode" , preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        timer.invalidate()
                        self.isUserInsideBound = false
                        self.navigationController?.pop()
                    }
                }
            })
        }
        if !self.scoreSecondSV.isHidden{
            for btn in self.buttonsArrayForStrokes{
                btn.setTitle("\(btn.tag)", for: .normal)
                btn.layer.borderWidth = 0
                for lay in btn.layer.sublayers!{
                    lay.borderWidth = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if self.isFromViewDid{
                self.isFromViewDid = false
            }else{
                self.scrlView.isHidden = false
            }
            if self.classicScoring.stableFordScore != nil{
                self.lblStblScore.text = "\(self.classicScoring.stableFordScore!)"
                self.btnStablefordScore.setTitle("Stableford Score", for: .normal)
            }
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height
            self.view.layoutIfNeeded()
        })

    }
    func getSuggestedClub(distance:Double,isGreen:Bool,shot:Int)->NSMutableAttributedString{
        var clubName = String()
        var distance = distance
        if(distanceFilter == 1){
            distance = distance/YARD
        }
        
        let dict1: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 15)!,
            ]
        let dict2:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 15)!,
            ]
        for clubs in courseData.clubData{
            if(distance >= Double(clubs.min) && distance <= Double(clubs.max)){
                clubName = clubs.name + " - \(Int(distance.rounded())) Yd"
                if(distanceFilter == 1){
                    clubName = clubs.name + " - \(Int(distance.rounded())) m"
                }
                
                if(shot > 1 && clubs.name == "Dr"){
                    clubName = "1i - \(Int(distance.rounded())) Yd"
                    if(distanceFilter == 1){
                        clubName = "1i - \(Int(distance.rounded())) m"
                    }
                }
                break
            }
            else if(distance < 80){
                if(isGreen){
                    clubName = "Pu - \(Int((distance*3).rounded())) ft"
                    if(distanceFilter == 1){
                        clubName = "Pu - \(Int((distance/3).rounded())) m"
                    }
                    
                }
                else{
                    clubName = "Lw - \(Int((distance).rounded())) Yd"
                    if(distanceFilter == 1){
                        clubName = "Lw - \(Int((distance).rounded())) m"
                    }
                }
                break
            }
            else{
                if(shot > 1){
                    clubName = "1i - \(Int(distance.rounded())) Yd"
                    if(distanceFilter == 1){
                        clubName = "1i - \(Int((distance).rounded())) m"
                    }
                }
                else{
                    clubName = "Dr - \(Int(distance.rounded())) Yd"
                    if(distanceFilter == 1){
                        clubName = "Dr - \(Int((distance).rounded())) m"
                    }
                }
                
            }
        }
        let attributedText = NSMutableAttributedString()
        let strData = clubName.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        attributedText.append(NSAttributedString(string: String(strData.first!), attributes: dict1))
        attributedText.append(NSAttributedString(string: String(strData.last!), attributes: dict2))
        return attributedText
    }
    @objc func loadMap(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        self.updateNotificationFor30Minutes()
        setupMultiplayersButton()
    }
    func clubReco(dist:Double,lie:String)->String {
        if (lie.trim() == "G"){
            return " Pu";
        }else {
            var index = 0
            var i2 = 0
            var minX = 1000000.0
            var preferredClubs = [String]()
            for i in 0..<courseData.clubData.count {
                if (!courseData.clubs.contains(courseData.clubData[i].name)){ continue}
                if (courseData.clubData[i].name == "Pu"){continue}
                if (courseData.clubData[i].name == "Dr") &&
                    (lie != "T"){continue}
                let max = Double(courseData.clubData[i].max)
                let min = Double(courseData.clubData[i].min)
                var x = 0.0
                if (dist >= max) {
                    x = dist - max;
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                } else if (dist <= min) {
                    x = min - dist;
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                } else if (dist >= min && dist <= max) {
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                }
                if (x < minX) {
                    index = i2;
                    minX = x;
                }
                i2 = i2+1
            }
            return preferredClubs[index]
        }
    }
    func plotSuggestedMarkers(position:[CLLocationCoordinate2D]){
        if(position.count > 2){
            let dict1: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 15)!,
                ]
            let dict2:[NSAttributedStringKey:Any] = [
                NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 15)!,
                ]
            
            var markerText = String()
            var markerText1 = String()
            var markerClub = String()
            var markerClub1 = String()
            
            suggestedMarker1.map = nil
            let dist1 = GMSGeometryDistance(position.first!, position[1]) * YARD
            let dist = GMSGeometryDistance(position[1], position.last!) * YARD
            
            markerText1 = "  \(Int(dist1)) yd "
            markerText = "  \(Int(dist == 0 ? 1:dist)) yd "
            if(distanceFilter == 1){
                markerText = "  \(Int((dist < YARD ? YARD:dist)/(YARD))) m "
                markerText1 = "  \(Int(dist1/(YARD))) m "
            }
            markerClub1 = clubReco(dist: dist1, lie: "T")
            markerClub = clubReco(dist: dist, lie: "O")
            if(dist > 250){
                markerClub = " - "
            }else if dist < 2{
                markerClub = " Pu "
            }
            if(dist1 > 250){
                markerClub1 = " - "
            }
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
            attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
            btnForSuggMark2.setAttributedTitle(attributedText, for: .normal)
            
            let attributedText1 = NSMutableAttributedString()
            attributedText1.append(NSAttributedString(string: markerClub1, attributes: dict1))
            attributedText1.append(NSAttributedString(string: markerText1, attributes: dict2))
            btnForSuggMark1.setAttributedTitle(attributedText1, for: .normal)
            
            suggestedMarker1.iconView = btnForSuggMark1
            suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
            suggestedMarker1.position = GMSGeometryOffset(position.first!, dist1/2, GMSGeometryHeading(position.first!, position[1]))
            suggestedMarker1.map = self.mapView
            
            suggestedMarker2.map = nil
            suggestedMarker2.iconView = btnForSuggMark2
            suggestedMarker2.position = GMSGeometryOffset(position[1], dist/2, GMSGeometryHeading(position[1], position.last!))
            suggestedMarker2.groundAnchor = CGPoint(x:-0.02,y:0.5)
            suggestedMarker2.map = self.mapView
            
        }
    }
    func letsRotateWithZoom(latLng1:CLLocationCoordinate2D,latLng2 : CLLocationCoordinate2D){
        let rotationAngle = rotateView(latlng1: latLng1, latlng2: latLng2)
        let middlePointWithZoom = BackgroundMapStats.getTheZoomLevel(positionsOfDotLine: self.positionsOfDotLine)
        let camera = GMSCameraPosition.camera(withLatitude: middlePointWithZoom.0.latitude,
                                              longitude: middlePointWithZoom.0.longitude,
                                              zoom: middlePointWithZoom.1)
        self.mapView.animate(to: camera)
        self.mapView.animate(toBearing: rotationAngle)
    }
    func getDistanceWithZoom(zoom:Float)->Double{
        var checkDistance:Double = 20
        if (zoom > 20) {
            checkDistance = 1
        } else if (zoom > 19.8 && zoom < 20) {
            checkDistance = 2
        } else if (zoom > 19.6 && zoom < 19.8) {
            checkDistance = 2
        } else if (zoom > 19.4 && zoom < 19.6) {
            checkDistance = 3
        } else if (zoom > 19.2 && zoom < 19.4) {
            checkDistance = 4
        } else if (zoom > 19 && zoom < 19.2) {
            checkDistance = 5
        } else if (zoom > 18.8 && zoom < 19) {
            checkDistance = 6
        } else if (zoom > 18.6 && zoom < 18.8) {
            checkDistance = 7
        } else if (zoom > 18.4 && zoom < 18.6) {
            checkDistance = 8
        } else if (zoom > 18.2 && zoom < 18.4) {
            checkDistance = 9
        } else if (zoom > 17 && zoom < 18.2) {
            checkDistance = 10
        } else if (zoom > 17.8 && zoom < 18) {
            checkDistance = 11
        } else if (zoom > 17.6 && zoom < 17.8) {
            checkDistance = 12
        } else if (zoom > 17.4 && zoom < 17.6) {
            checkDistance = 13
        } else if (zoom > 17.2 && zoom < 17.4) {
            checkDistance = 14
        } else if (zoom > 17 && zoom < 17.2) {
            checkDistance = 15
        } else if (zoom > 16.8 && zoom < 17) {
            checkDistance = 16
        } else if (zoom > 16.6 && zoom < 16.8) {
            checkDistance = 17
        } else if (zoom > 16.4 && zoom < 16.6) {
            checkDistance = 18
        } else if (zoom > 16.2 && zoom < 16.4) {
            checkDistance = 19
        } else if (zoom > 16 && zoom < 16.2) {
            checkDistance = 20
        }
        return checkDistance
    }
}
extension RFMapVC{
    
    @objc func buttonAction(sender: UIButton!) {
        for i in 0..<playersButton.count{
            if(i == sender.tag){
                if(!playersButton[i].isSelected){
                    playersButton[i].isSelected = true
                    self.playerId = playersButton[i].id
                }
            }
            else{
                playersButton[i].isSelected = false
            }
        }
        for i in 0..<playersButton.count{
            if(playersButton[i].isSelected){
                self.lblPlayerNameDSV.text = "Your Score"
                self.lblPlayerNameSSV.text = "Your Score"
                if(playersButton[i].id != Auth.auth().currentUser!.uid){
                    self.lblPlayerNameDSV.text = "\(playersButton[i].name)'s Score"
                    self.lblPlayerNameSSV.text = "\(playersButton[i].name)'s Score"
                }
                self.holeWiseShots = NSMutableDictionary()
                updateMap(indexToUpdate: holeIndex)
                break
            }
        }
    }
}

extension RFMapVC{
    
    func updateCurrentHole(index: Int){
        Notification.sendLocaNotificatonToUser()
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(index)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(self.matchId)/").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if(self.positionsOfDotLine.count > 2){
                self.plotSuggestedMarkers(position: self.positionsOfDotLine)
            }
        })
    }
    
    @IBAction func nextAction(_ sender: UIButton!) {
        holeIndex += 1
        holeIndex = holeIndex % self.scoring.count
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.scoring[self.holeIndex].hole)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        self.updateMap(indexToUpdate: holeIndex)
        self.updateCurrentHole(index: self.scoring[self.holeIndex].hole)
        if(holeIndex == 0){
            self.holeOutforAppsFlyer[self.playerIndex] = self.checkHoleOutZero(playerId: Auth.auth().currentUser!.uid)
            if(self.holeOutforAppsFlyer[self.playerIndex] == self.scoring.count){
                self.btnActionFinishRound(self.btnEndRound)
            }
        }
        fairwayHitContainerSV.isHidden = false
    }
    
    @IBAction func previousAction(_ sender: UIButton!) {

        holeIndex -= 1
        holeIndex = holeIndex % self.scoring.count
        if(self.holeIndex == -1){
            holeIndex = self.scoring.count-1
        }
        self.updateMap(indexToUpdate: holeIndex)
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.scoring[self.holeIndex].hole)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        self.updateCurrentHole(index: self.scoring[self.holeIndex].hole)

        fairwayHitContainerSV.isHidden = false
        if self.scoring[self.holeIndex].par == 3{
            fairwayHitContainerSV.isHidden = true
        }
    }

    func getDataFromJson(lattitude:Double,longitude:Double, onCompletion: @escaping ([String:AnyObject]?, String?) -> Void) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lattitude)&lon=\(longitude)&APPID=a261cc920ea8ff18f5c941b4675f1b8a")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            guard let data = Data, error == nil else {  // check for fundamental networking error
                debugPrint("error=\(error ?? "some error Comes" as! Error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                return
            }
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            onCompletion(responseString, nil)
        }
        task.resume()
    }
}
