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
import CoreData
import MaterialTapTargetPrompt_iOS
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
class RFMapVC: UIViewController,GMSMapViewDelegate,ExitGamePopUpDelegate{
    var propertyArray = [Properties]()
    var isAcceptInvite = false
    let blurWhiteCircleLayer = CAShapeLayer()
    let showcaseView = UIView()
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
    @IBOutlet weak var btnEditShots: UIButton!
    @IBOutlet weak var lblPlayerNameDSV: UILabel!
    @IBOutlet weak var lblPlayerNameSSV: UILabel!
    @IBOutlet weak var imgViewWindForeground: UIImageView!
    @IBOutlet weak var lblEditShotNumber: UILabel!
    @IBOutlet weak var btnCenter: UILocalizedButton!
    
    @IBOutlet weak var exitGamePopUpView: ExitGamePopUpView!
    @IBOutlet weak var lblFrontDist: UILabel!
    @IBOutlet weak var lblCenterDist: UILabel!
    @IBOutlet weak var lblEndDist: UILabel!
    @IBOutlet weak var lblBackElev: UILabel!
    @IBOutlet weak var lblCenterElev: UILabel!
    @IBOutlet weak var lblFrontElev: UILabel!
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
    @IBOutlet weak var btnTopHoleNo: UILocalizedButton!
    @IBOutlet weak var eddieView: EddieViewRFMap!
    
    @IBOutlet weak var lblWindS: UILabel!
    @IBOutlet weak var lblWindU: UILabel!
    @IBOutlet weak var btnEleBack: UIButton!
    @IBOutlet weak var btnEleCenter: UIButton!
    @IBOutlet weak var btnEleFront: UIButton!
    @IBOutlet weak var unlockEddieView: UIView!
    @IBOutlet weak var siriSetupView: UIView!
    @IBOutlet weak var btnUnlockE: UIButton!
    @IBOutlet weak var btnSiriSetup: UIButton!
    @IBOutlet weak var lblWindDistEle: UILabel!
    @IBOutlet weak var lblDistWind: UILabel!
    @IBOutlet weak var btnElevWind: UIButton!
    
    @IBOutlet weak var lblDirEddie: UILabel!
    @IBOutlet weak var lblDirBack: UILabel!
    @IBOutlet weak var lblDirCenter: UILabel!
    @IBOutlet weak var lblDirFront: UILabel!
    @IBOutlet weak var btnWindImgLock: UIButton!
    @IBOutlet weak var windNotesView: WindNotesView!
    @IBOutlet weak var lockBack: UIImageView!
    @IBOutlet weak var lockCenter: UIImageView!
    @IBOutlet weak var lockFront: UIImageView!
    @IBOutlet weak var lblWindOnlyLbl: UILabel!
    
    @IBOutlet weak var gpsBtn: UIButton!
    @IBOutlet weak var farFromTheHoleView : FarFromTheHole!
    @IBOutlet weak var bottomDistance: NSLayoutConstraint!
    
    @IBOutlet weak var lblGetEddieForElevation: UILabel!
    @IBOutlet weak var lblEddiegivesPlays: UILocalizedLabel!
    
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

    @IBOutlet weak var lblSiriHeading: UILocalizedLabel!
    @IBOutlet weak var lblIfYou: UILabel!
    
    @IBOutlet weak var lblFront: UILocalizedLabel!
    @IBOutlet weak var lblCenter: UILocalizedLabel!
    @IBOutlet weak var lblBack: UILocalizedLabel!
    // Header IBOutlets
    @IBOutlet weak var backBtnHeader: UIButton!
    // WindRelated IBOutlests
    var firstX = CGFloat()
    var firstY = CGFloat()
    var first = false
    var windSpeed = 0.0
    var windHeading = 0.0

    @IBOutlet weak var fairwayHitContainerSV: UIStackView!

    // Menu
    var stackViewMenu : UIStackView!
    @objc func addNotesAction(_ sender: Any) {
        var matchDataDictionary = NSMutableDictionary()
        if(self.isAcceptInvite){
            matchDataDictionary = self.matchDataDic
        }else{
            matchDataDictionary = matchDataDic
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Rangefinder Notes")
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        viewCtrl.notesCourseID = matchDataDictionary.value(forKeyPath: "courseId") as! String
        viewCtrl.notesHoleNum = "hole\(self.scoring[self.holeIndex].hole)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @IBAction func btnActionMenu(_ sender: UIButton) {
        if(stackViewMenu.isHidden){
            stackViewMenu.isHidden = false
        }else{
            stackViewMenu.isHidden = true
        }
    }
    var holeOutforAppsFlyer = [Int]()
    var btnForSugg1 = SuggestionView()
    var btnForSugg2 = SuggestionView()
    @IBAction func btnActionChangeHole(_ sender: Any) {
        var strArr = [String]()
        for hole in self.scoring{    
            strArr.append("Hole".localized() + " \(hole.hole) - " + "Par".localized() + " - \(hole.par)")
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
        
        if Constants.isEdited{
            self.exitGamePopUpView.btnDiscardText = "Delete Round".localized()
        }
        self.exitGamePopUpView.labelText = "\(self.holeOutforAppsFlyer[playerIndex])/\(scoring.count) " + "holes completed".localized()
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
        BackgroundMapStats.deleteCoreData()
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
                        self.lblPlayerNameDSV.text = "Your Score".localized()
                        self.lblPlayerNameSSV.text = "Your Score".localized()
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
                if data.key as! String == Auth.auth().currentUser!.uid{
                    if let goal = (v as! NSMutableDictionary).value(forKey: "goals") as? NSMutableDictionary{
                        if let target = goal.value(forKey: "target") as? NSMutableDictionary{
                            self.targetGoal.Birdie = target.value(forKey: "birdie") as! Int
                            self.targetGoal.par = target.value(forKey: "par") as! Int
                            self.targetGoal.gir = target.value(forKey: "gir") as! Int
                            self.targetGoal.fairwayHit = target.value(forKey: "fairway") as! Int
                        }
                        if let achieved = goal.value(forKey: "achieved") as? NSMutableDictionary{
                            self.achievedGoal.Birdie = achieved.value(forKey: "birdie") as! Int
                            self.achievedGoal.par = achieved.value(forKey: "par") as! Int
                            self.achievedGoal.gir = achieved.value(forKey: "gir") as! Int
                            self.achievedGoal.fairwayHit = achieved.value(forKey: "fairway") as! Int
                        }
                        self.eddieView.updateGoalView(achievedGoal: achievedGoal, targetGoal: targetGoal)
                    }
                }
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
                    if hcp.contains(find: "-"){
                        handicapOfP = 0
                    }else{
                        handicapOfP = Double(hcp)!
                    }
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
        if self.isContinueMatch == nil{
           self.isContinueMatch = false
        }
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
        locationManager.startUpdatingLocation()
        self.farFromTheHoleView.layer.cornerRadius = 5.0
        self.farFromTheHoleView.btnContinue.addTarget(self, action: #selector(self.farFromTheHoleContinueAction), for: .touchUpInside)
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
                self.btnStablefordScore.setTitle("Net Score".localized(), for: .normal)
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
                    if key == Constants.selectedGolfID{
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
                    if key == Constants.selectedGolfID{
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
        let emptyAlert = UIAlertController(title: "Discard Round".localized(), message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to Discard the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Discard Round".localized(), style: .default, handler: { (action: UIAlertAction!) in
            self.exitWithoutSave()
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
        
    }
    func exitWithoutSave(){
        FBSomeEvents.shared.singleParamFBEvene(param: "Discard Game")
        if(matchId.count > 1){
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId)").removeValue()
            matchId.removeAll()
            Constants.isUpdateInfo = true
            Constants.addPlayersArray.removeAllObjects()
            if Constants.mode>0{
                Analytics.logEvent("mode\(Constants.mode)_game_discarded", parameters: [:])
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["my.notification"])
            }
            self.mapTimer.invalidate()
            self.gotoFeedBackViewController(mID: Constants.matchId, mode: Constants.mode, isDiscard: true)
        }
        BackgroundMapStats.deleteCoreData()
        scoring.removeAll()
    }

    @objc func statsCompleted(_ notification: NSNotification) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Save Game")
        Notification.sendLocaNotificatonAfterGameFinished()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.hide()
        if(matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        var endingTime = Timestamp
        if Constants.isEdited{
            if let player = Constants.matchDataDic.value(forKeyPath: "player") as? NSDictionary{
                let data = player.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSDictionary
                if let etime = data?.value(forKeyPath: "endTimestamp") as? Int64{
                    endingTime = etime
                }
            }
        }
        if(Auth.auth().currentUser!.uid.count>1) &&  (matchId.count > 1){
            ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
            ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["endTimestamp":endingTime])
        }
        Constants.addPlayersArray = NSMutableArray()
        self.updateFeedNode(finisedTime : endingTime)
        Constants.isUpdateInfo = true
        if Constants.mode>0{
            Analytics.logEvent("mode\(Constants.mode)_game_completed", parameters: [:])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["my.notification"])
        }
        if(matchId.count > 1){
            self.gotoFeedBackViewController(mID: matchId,mode:Constants.mode)
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
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(Constants.selectedGolfName).", type: "8", category: "finishedGame", matchDataId: self.matchId, feedKey: "")
                group.leave()
            }
            
            group.notify(queue: .main){
                self.progressView.hide()
            }
        }
    }
    func updateFeedNode(finisedTime:Int64){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(finisedTime, forKey: "timestamp" as NSCopying)
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
    func gotoFeedBackViewController(mID:String,mode:Int,isDiscard:Bool = false){
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        viewCtrl.matchIdentifier = mID
        viewCtrl.mode = mode
        if !isDiscard{
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
                viewCtrl.fromGameImprovement = false
                self.navigationController?.pushViewController(viewCtrl, animated: true)
                self.scoring.removeAll()
                self.matchId.removeAll()
            }
        }else{
            viewCtrl.onDoneBlock = { result in
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
            }
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
//    var isBackground : Bool{
//        let state = UIApplication.shared.applicationState
//        if state == .background {
//            return true
//        }else{
//            return false
//        }
//    }
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
        var selectedTee = [(tee:String,color:String,handicap:Double)]()
        for data in players{
            if let player = data as? NSMutableDictionary{
                var teeOfP = String()
                if let tee = player.value(forKeyPath: "tee") as? String{
                    teeOfP = tee
                }
                var teeColorOfP = String()
                if let tee = player.value(forKeyPath: "teeColor") as? String{
                    teeColorOfP = tee
                }
                var handicapOfP = Double()
                if let hcp = player.value(forKeyPath: "handicap") as? String{
                    handicapOfP = Double(hcp)!
                }
                if(teeOfP != ""){
                    selectedTee.append((tee: teeOfP,color:teeColorOfP, handicap: handicapOfP))
                }
            }
        }
        viewCtrl.teeTypeArr = selectedTee

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
        if self.navigationController == nil{
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            return
        }else{
            for controller in self.navigationController!.viewControllers{
                if controller.isKind(of: NewGameVC.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: !isAcceptInvite)
                    break
                }
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
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
        
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
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
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
            bottomView.isHidden = false
            btnNext.isHidden = true
            btnPrev.isHidden = true
//            btnPlayerStats.isHidden = true
            self.btnEditShots.isHidden = true
            self.lblEditShotNumber.isHidden = true
            scrlHConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
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
            self.lblEditShotNumber.isHidden = false
            sender.tag = 0
            scoreSecondSV.isHidden = true
//            btnPlayerStats.isHidden = false
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
                self.bottomView.isHidden = true
            })
        }
    }

    @IBAction func detailScoreAction(_ sender: UIButton) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Rangefinder Detailed Scoring")
        if sender.tag == 0{
            
//            UIView.animate(withDuration: 0.3, animations: {
                self.detailScoreSV.isHidden = true
//            })
            sender.tag = 1
            self.view.layoutIfNeeded()
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
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
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
        }
    }
    @IBOutlet weak var btnDetailScoring: UILocalizedButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNextScrl: UIButton!
    @IBOutlet weak var btnPrevScrl: UIButton!
    @IBOutlet weak var btnExpendScore: UIButton!
    @IBOutlet weak var btnTopShotRanking: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnViewScoreCard: UILocalizedButton!
    @IBOutlet weak var btnEndRound: UILocalizedButton!
    @IBOutlet weak var btnPlayerStats: UILocalizedButton!
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
    @IBOutlet weak var btnPlayerStats2: UILocalizedButton!
    @IBOutlet weak var btnMoveToMapGround: UIButton!
    @IBOutlet weak var lblHoleNumber2: UILabel!
    @IBOutlet weak var lblParNumber2: UILabel!
    @IBOutlet weak var btnHoleSelection: UIButton!
    @IBOutlet weak var bottomView: UIView!

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
    var isViewDidEntered = false
    var isFarFromHoleFirstTime = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblEditShotNumber.isHidden = !self.scrlView.isHidden

        self.farFromTheHoleView.isHidden = true
        self.isViewDidEntered = true
        FBSomeEvents.shared.singleParamFBEvene(param: "View Rangefinder Game")
        btnPlayerStats.isHidden = true
        locationManager.delegate = self
        initalSetup()
        self.gpsBtn.setCircle(frame: self.gpsBtn.frame)
        self.gpsBtn.backgroundColor = UIColor.glfBlack40
        self.gpsBtn.addTarget(self, action: #selector(self.gpsAction(_:)), for: .touchUpInside)
        self.mapView.delegate = self
        btnPlayerStats.isEnabled = false
        self.view.isUserInteractionEnabled = false
        if matchDataDic.count == 0{
           matchDataDic = Constants.matchDataDic
        }
        let onCourse = matchDataDic.value(forKeyPath: "onCourse") as? Bool ?? true
        self.courseId = "course_\(matchDataDic.value(forKeyPath: "courseId") as! String)"
        if (onCourse){
            locationManager.startUpdatingLocation()
            if let currentLocation: CLLocation = self.locationManager.location{
                self.userLocationForClub = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            }
//            self.mapView.isMyLocationEnabled = false
//            if Constants.onCourseNotification == 1{
//                self.registerBackgroundTask()
//            }
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
//        NotificationCenter.default.addObserver(self, selector: #selector(self.sendNotificationOnCourse(_:)), name: NSNotification.Name(rawValue: "updateLocation"),object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHoleFromNotification(_:)), name: NSNotification.Name(rawValue: "holeChange"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideStableFord(_:)), name: NSNotification.Name(rawValue: "hideStableFord"),object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        //         getGolfCourseDataFromFirebase()
    }
    @objc func gpsAction(_ sender:UIButton){
        self.gpsBtn.tag = 11
        locationManager.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            let userToTeeDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[self.holeIndex].tee)
            let userToGreenDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[self.holeIndex].green)
            let radiusDistance = GMSGeometryDistance(self.courseData.centerPointOfTeeNGreen[self.holeIndex].tee, self.courseData.centerPointOfTeeNGreen[self.holeIndex].green) + 200
            if radiusDistance > userToTeeDistance && radiusDistance > userToGreenDistance{
                self.updateMap(indexToUpdate: self.holeIndex)
            }else{
                self.farFromTheHoleView.isHidden = false
            }
        })
    }
    @objc func farFromTheHoleContinueAction(_ sender:UIButton){
        self.farFromTheHoleView.isHidden = true
    }
//    @objc func appDidEnterForeground(){
//        switch CLLocationManager.authorizationStatus() {
//        case .notDetermined:
//            self.locationManager.requestAlwaysAuthorization()
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//            break
//
//        case .restricted, .denied:
//            let alert = UIAlertController(title: "Need Authorization or Enable GPS from Privacy Settings", message: "This game mode is unusable if you don't authorize this app or don't enable GPS", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
//                self.backButtonAction(self.backBtnHeader)
//            }))
//            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//                let url = URL(string: UIApplicationOpenSettingsURLString)!
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }))
//            self.present(alert, animated: true, completion: nil)
//            break
//
//        case .authorizedWhenInUse, .authorizedAlways:
//            // Do Nothing
//            break
//        }
//    }

    // --------------------------- End -------------------------------
//    @objc func sendNotificationOnCourse(_ notification:NSNotification){
//        self.locationManager.startUpdatingLocation()
//        var distance  = GMSGeometryDistance(self.positionsOfDotLine.last!,self.userLocationForClub!)
//        var suffix = "meter"
//        if(Constants.distanceFilter != 1){
//            distance = distance*Constants.YARD
//            suffix = "yard"
//        }
//        Notification.sendRangeFinderNotification(msg: "Hole \(self.scoring[self.holeIndex].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDic.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0)
//        debugPrint("distance",distance)
//    }
//    @objc func changeHoleFromNotification(_ notification:NSNotification){
//        if let nextOrPrev = notification.object as? String{
//            if(nextOrPrev == "next"){
//                self.nextAction(self.btnNext)
//            }else{
//                self.previousAction(self.btnPrev)
//            }
//        }
//    }
//    func registerBackgroundTask() {
//        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            self?.endBackgroundTask()
//        }
//        assert(backgroundTask != UIBackgroundTaskInvalid)
//    }
//    @objc func appDidEnterBackground() {
//        let thePresenter = self.navigationController?.visibleViewController
//        if (thePresenter != nil) && (thePresenter?.isKind(of:RFMapVC.self))! {
//            if Constants.onCourseNotification == 0{
//                self.mapTimer.invalidate()
//            }else{
//                self.updateMap(indexToUpdate: self.holeIndex)
//            }
//        }else{
//            self.mapTimer.invalidate()
//        }
//    }
//    func endBackgroundTask() {
//        print("Background task ended.")
//        UIApplication.shared.endBackgroundTask(backgroundTask)
//        backgroundTask = UIBackgroundTaskInvalid
//    }
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
    var achievedGoal = Goal()
    var targetGoal = Goal()
    func initalSetup(){
        self.eddieView.setup()
        eddieView.btnUnlockEddie.addTarget(self, action: #selector(self.unlockEddie(_:)), for: .touchUpInside)
        self.siriSetupView.isHidden = !Constants.isProMode
        self.unlockEddieView.isHidden = Constants.isProMode
        lockBack.isHidden = Constants.isProMode
        lockCenter.isHidden = Constants.isProMode
        lockFront.isHidden = Constants.isProMode
        lblWindOnlyLbl.isHidden = Constants.isProMode
        self.btnUnlockE.setCornerWithRadius(color: UIColor.clear.cgColor, radius: self.btnUnlockE.frame.height/2)
        self.imgViewWindForeground.tintImageColor(color: UIColor.glfYellow)
        BackgroundMapStats.setDir(isUp: false, label: self.lblDirEddie)
        self.btnWindImgLock.setCircle(frame: self.btnWindImgLock.frame)
        let originalImage1 = BackgroundMapStats.resizeImage(image: #imageLiteral(resourceName: "locked_1"), targetSize: CGSize(width:10,height:10))
        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.btnWindImgLock.setImage(backBtnImage1, for: .normal)
        self.btnWindImgLock.tintColor = UIColor.glfBlack
        self.btnWindImgLock.backgroundColor = UIColor.glfWhite
        self.btnWindImgLock.isHidden = Constants.isProMode
        
        let originalImage2 =  #imageLiteral(resourceName: "setting").resize(CGSize(width:18,height:18))
        let backBtnImage2 = originalImage2!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.btnSiriSetup.setImage(backBtnImage2, for: .normal)
        self.btnSiriSetup.tintColor = UIColor.glfYellow
        self.btnSiriSetup.setCorner(color: UIColor.glfYellow.cgColor)
        self.btnSiriSetup.setTitle("  Setup", for: .normal)
        
        lblEditShotNumber.layer.cornerRadius = lblEditShotNumber.frame.size.height/2
        lblEditShotNumber.layer.masksToBounds = true
        
        topHCPView.setCornerView(color: UIColor.glfWhite.cgColor)
        topParView.setCornerView(color: UIColor.glfWhite.cgColor)
        btnTopHoleNo.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnTopHoleNo.frame.height/2)
        stablefordSubView.setCornerView(color: UIColor.glfWhite.cgColor)
        imgViewStblReferesh.tintImageColor(color: UIColor.glfWhite)
        scrlView.isHidden = true
        bottomView.isHidden = true
        btnNext.isHidden = false
        btnPrev.isHidden = false
//        btnDetailScoring.setCorner(color: UIColor.glfWhite.cgColor)
        btnDetailScoring.setTitleColor(UIColor.glfWhite, for: .normal)
        btnDetailScoring.setImage(#imageLiteral(resourceName: "Club_arrow_down").resize(CGSize(width:10,height:10)), for: .normal)
//        btnDetailScoring.imageView?.tintImageColor(color: UIColor.glfWhite)
        btnNext.setCircle(frame: self.btnNext.frame)
        btnPrev.setCircle(frame: self.btnPrev.frame)
        btnNextScrl.setCircle(frame: btnNextScrl.frame)
        btnPrevScrl.setCircle(frame: btnPrevScrl.frame)
        self.exitGamePopUpView.show(navItem: self.navigationItem)
        self.exitGamePopUpView.delegate = self
        self.exitGamePopUpView.isHidden = true
        
        btnScore.setCornerWithCircleWidthOne(color: UIColor.white.cgColor)
        self.mapView.mapType = GMSMapViewType.satellite
        btnForSugg1 = SuggestionView(frame: CGRect(x: 0, y: 0, width: 120, height: 65))
        btnForSugg1.autoresize()
        btnForSugg2 = SuggestionView(frame: CGRect(x: 0, y: 0, width: 120, height: 65))
        btnForSugg2.autoresize()
        btnForSugg1.setCornerView(color: UIColor.clear.cgColor)
        btnForSugg2.setCornerView(color: UIColor.clear.cgColor)
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

//        swipeDown.direction = UISwipeGestureRecognizerDirection.down
//        swipeDown.addTarget(self, action: #selector(self.swipedViewDown))
//        scrlView.addGestureRecognizer(swipeDown)

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
        
        let quote = "If you have your earphones, next time just say "
        let qoute2 = "\"What's the distance\""
        if UIDevice.current.iPhoneX || UIDevice.current.iPhonePlus || UIDevice.current.iPhoneXR || UIDevice.current.iPhoneXSMax{
            self.bottomDistance.constant = 50
            self.lblBackElev.font = self.lblBackElev.font.withSize(70)
            self.lblCenterElev.font = self.lblCenterElev.font.withSize(80)
            self.lblFrontElev.font = self.lblFrontElev.font.withSize(70)
            self.lblSiriHeading.font = self.lblSiriHeading.font.withSize(24)
            self.lblWindOnlyLbl.font = self.lblWindOnlyLbl.font.withSize(28)
            self.lblGetEddieForElevation.font = self.lblGetEddieForElevation.font.withSize(16)
            self.lblEddiegivesPlays.font = self.lblEddiegivesPlays.font.withSize(24)
            
            self.lblFront.font = self.lblFront.font.withSize(17)
            self.lblBack.font = self.lblBack.font.withSize(17)
            self.lblFront.font = self.lblFront.font.withSize(17)
            
            self.lblFrontDist.font = self.lblFrontDist.font.withSize(17)
            self.lblCenterDist.font = self.lblCenterDist.font.withSize(17)
            self.lblEndDist.font = self.lblEndDist.font.withSize(17)
            
            let attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 16)]
            let attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Italic", size: 16)]
            let attributedText = NSMutableAttributedString()
            let attributedQuote = NSAttributedString(string: quote, attributes: attributes as [NSAttributedStringKey : Any])
            let attributedQuote2 = NSAttributedString(string: qoute2, attributes: attributes2 as [NSAttributedStringKey : Any])
            attributedText.append(attributedQuote)
            attributedText.append(attributedQuote2)
            self.lblIfYou.attributedText = attributedText
        }
        else if UIDevice.current.iPhone5{
            self.bottomDistance.constant = 8
            self.lblBackElev.font = self.lblBackElev.font.withSize(40)
            self.lblCenterElev.font = self.lblCenterElev.font.withSize(50)
            self.lblFrontElev.font = self.lblFrontElev.font.withSize(40)
            self.lblSiriHeading.font = self.lblSiriHeading.font.withSize(18)
            
            self.lblFront.font = self.lblFront.font.withSize(12)
            self.lblBack.font = self.lblBack.font.withSize(12)
            self.lblFront.font = self.lblFront.font.withSize(12)
            
            self.lblFrontDist.font = self.lblFrontDist.font.withSize(12)
            self.lblCenterDist.font = self.lblCenterDist.font.withSize(12)
            self.lblEndDist.font = self.lblEndDist.font.withSize(12)
            
            self.lblGetEddieForElevation.font = self.lblGetEddieForElevation.font.withSize(12)
            self.lblEddiegivesPlays.font = self.lblEddiegivesPlays.font.withSize(18)
            self.lblWindOnlyLbl.font = self.lblWindOnlyLbl.font.withSize(20)
            let attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 11)]
            let attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Italic", size: 11)]
            let attributedText = NSMutableAttributedString()
            let attributedQuote = NSAttributedString(string: quote, attributes: attributes as [NSAttributedStringKey : Any])
            let attributedQuote2 = NSAttributedString(string: quote, attributes: attributes2 as [NSAttributedStringKey : Any])
            attributedText.append(attributedQuote)
            attributedText.append(attributedQuote2)
            self.lblIfYou.attributedText = attributedText
            
        }
        setInitialUI()
    }
    @IBAction func supportAction(_ sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        self.present(navCtrl, animated: true, completion: nil)
    }
    @objc func unlockEddie(_ sender: UIButton){
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Rangefinder Pulldown Eddie")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "RangeFinder"
        self.navigationController?.pushViewController(viewCtrl, animated: false)
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
    
    @IBAction func btnActionSiriSetup(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "SiriSetupVC") as! SiriSetupVC
    self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    @IBAction func btnActionUnlockEddie(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Rangefinder Goals Eddie")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "RangeFinder"
        self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    func updateNotificationFor30Minutes(){
        ref.child("matchData/\(self.matchId)/scoring").observe(DataEventType.value, with: { (snapshot) in
            Notification.sendLocaNotificatonToUser()
        })
    }
    @IBAction func btnActionMoveToMap(_ sender: Any) {
        if(self.viewForground.isHidden){
            FBSomeEvents.shared.singleParamFBEvene(param: "View Rangefinder Pulldown")
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
            bottomView.isHidden = true
        }
        self.btnNext.isHidden = false
        self.btnPrev.isHidden = false
        
        self.btnCenter.isHidden = isHide
        self.windNotesView.isHidden = isHide
//        self.btnPlayerStats.isHidden = isHide
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
    var windTimeStamp = Int64()
    func updateWindSpeed(latLng:CLLocationCoordinate2D,indexToUpdate:Int){
        let lat = latLng.latitude
        let lng = latLng.longitude
        
        BackgroundMapStats.getDataFromJson(lattitude: lat , longitude: lng, onCompletion: { response,arg  in
            DispatchQueue.main.async(execute: {
                let headingOfHole = GMSGeometryHeading(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee,self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
                debugPrint(response!)
                for data in response!{
                    debugPrint(data.key)
                    if data.key == "wind"{
                        self.windTimeStamp = Timestamp + 600000
                        self.windSpeed = (data.value as AnyObject).value(forKey: "speed") as! Double
                        let windSpeedWithUnit = self.windSpeed * 2.23694
                        self.windNotesView.lblWind.text = " \(Int(windSpeedWithUnit.rounded())) mph"
                        self.lblWindS.text = "\(Int(windSpeedWithUnit.rounded()))"
                        self.lblWindU.text = "mph"
                        if(Constants.distanceFilter == 1){
                            self.lblWindU.text = "kmph"
                            self.lblWindS.text = "\(Int(windSpeedWithUnit*1.60934))"
                            self.windNotesView.lblWind.text = "\(Int(windSpeedWithUnit*1.60934)) kmph"
                        }
                        if let degree = (data.value as AnyObject).value(forKey: "deg") as? Double{
                            self.windHeading = degree + 135
                        }
                        let rotationAngle1 = self.windHeading - headingOfHole
                        let rotationAngle = self.windHeading - self.mapView.camera.bearing
                        UIButton.animate(withDuration: 2.0, animations: {
                            self.windNotesView.imgWind.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                            self.imgViewWindForeground.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle1)) / 180.0 * CGFloat(Double.pi))
                        })
                        break
                    }
                }
                } as @convention(block) () -> Void)
        })
    }
    var previousLocation : CLLocationCoordinate2D!
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.mapView.settings.scrollGestures = true
        self.showcaseView.isHidden = true
        if(!self.scrlView.isHidden){
            self.playerStatsAction(self.btnPlayerStats)
            self.lblEditShotNumber.isHidden = self.scrlView.isHidden ? true:false
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
                isDraggingMarker = false
                break
            }
        }
    }
    
    @objc func btnActionWindLocked(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Rangefinder Wind")
        if !Constants.isProMode{
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
            viewCtrl.source = "RangeFinder"
            self.navigationController?.pushViewController(viewCtrl, animated: false)
        }
    }
    
    @objc func strokesAction(sender: UIButton!){
        let title = sender.currentTitle
        lblEditShotNumber.text = " \(title!) "
        FBSomeEvents.shared.singleParamFBEvene(param: "Score Rangefinder Hole \(self.scoring[self.holeIndex].hole)")
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
        self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
        if(!self.teeTypeArr.isEmpty){
            self.uploadStableFordPints(playerId: self.playerId,strokes:Int(title!)!)
        }else{
            updateScoreData()
        }
        self.updateSiriHole()
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
        for data in Constants.teeArr{
            if(data.type.lowercased() == self.teeTypeArr[index].tee.lowercased()) && (data.name.lowercased() == self.teeTypeArr[index].color.lowercased()){
                break
            }
            slopeIndex += 1
        }
        let data = (self.teeTypeArr[index].handicap * Double(Constants.teeArr[slopeIndex].slope)!)
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
        self.achievedGoal = BackgroundMapStats.calculateGoal(scoreData: self.scoring, targetGoal: self.targetGoal)
        self.eddieView.updateGoalView(achievedGoal: achievedGoal, targetGoal: targetGoal)
    }
    func updateSiriHole(){
        var inde = 0
        for data in self.scoring{
            for usr in data.players{
                if let play = usr.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSMutableDictionary{
                    let holeOut = play.value(forKey: "holeOut") as? Bool ?? false
                    if !holeOut{
                        break
                    }else{
                        inde += 1
                    }
                }
            }
        }
        if let counter = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: context){
            counter.forEach { counter in
                context.delete(counter as! NSManagedObject)
            }
        }
        if let curHoleEntity = NSEntityDescription.insertNewObject(forEntityName: "CurrentHoleEntity", into: context) as? CurrentHoleEntity{
            curHoleEntity.timestamp = Timestamp
            curHoleEntity.holeIndex = Int16(inde)
            CoreDataStorage.saveContext(context)
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
            lblEditShotNumber.isHidden = self.btnNext.isHidden
            lblEditShotNumber.text = " \(classicScoring.strokesCount!) "
//            self.lblStblScore.text = "\(self.classicScoring.strokesCount!)"
//            self.btnStablefordScore.setTitle("Stableford Score", for: .normal)
        }else{
            self.scoreSV.isHidden = false
            self.scoreSV2.isHidden = true
            lblEditShotNumber.isHidden = true
        }
        updateColorToStrokes()
        self.achievedGoal = BackgroundMapStats.calculateGoal(scoreData: self.scoring, targetGoal: self.targetGoal)
        self.eddieView.updateGoalView(achievedGoal: self.achievedGoal, targetGoal: self.targetGoal)
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
                holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
            
        }
        holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
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
                holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
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
                holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
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
                holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
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
            holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
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
                holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = BackgroundMapStats.updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.holeIndex)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    
    func setHoleShotDetails(par:Int,shots:Int){
        var holeFinishStatus = String()
        if (shots > par) {
            if (shots - par > 1) {
                holeFinishStatus = " \(shots-par) "+"Bogey".localized()
            } else {
                holeFinishStatus = " "+"Bogey".localized()
            }
        } else if (shots < par) {
            if (par == 3) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                } else if (par - shots == 2) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                }
            } else if (par == 4) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                } else if (par - shots == 2) {
                    holeFinishStatus = "  "+"Eagle".localized()+"  "
                } else if (par - shots == 3) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                }
            } else if (par == 5) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                } else if (par - shots == 2) {
                    holeFinishStatus = "  "+"Eagle".localized()+"  "
                } else if (par - shots == 3) {
                    holeFinishStatus = "  "+"Albatross".localized()+"  "
                } else if (par - shots == 4) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                }
            }
        } else if (shots == par) {
            holeFinishStatus = "  "+"Par".localized()+"  "
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
        if self.scoring.count == 9{
            self.targetGoal.Birdie = Constants.targetGoal.Birdie/2 == 0 ? 1:Constants.targetGoal.Birdie/2
            self.targetGoal.par = Constants.targetGoal.par/2 == 0 ? 1:Constants.targetGoal.par/2
            self.targetGoal.gir = Constants.targetGoal.gir/2 == 0 ? 1:Constants.targetGoal.gir/2
            self.targetGoal.fairwayHit = Constants.targetGoal.fairwayHit/2 == 0 ? 1:Constants.targetGoal.fairwayHit/2
        }else{
            self.targetGoal = Constants.targetGoal
        }
        let goal = NSMutableDictionary()
        goal.setValue(self.targetGoal.Birdie, forKey: "birdie")
        goal.setValue(self.targetGoal.par, forKey: "par")
        goal.setValue(self.targetGoal.gir, forKey: "gir")
        goal.setValue(self.targetGoal.fairwayHit, forKey: "fairway")
        ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)/goals/target").updateChildValues(goal as! [AnyHashable : Any])
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
        if self.playerId.contains(find: "\(Auth.auth().currentUser!.uid)"){
            windNotesView.btnNotesUnlock.isHidden = false
        }else{
            windNotesView.btnNotesUnlock.isHidden = true
        }
        self.suggestedMarker1.map = nil
        self.suggestedMarker2.map = nil
        let indexToUpdate = indexToUpdate == -1 ? indexToUpdate+1 : indexToUpdate
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
        bottomView.isHidden = true
        self.first = false
        self.isUpdating = false
        btnTopShotRanking.setTitle("", for: .normal)
        btnTopShotRanking.isHidden = true
        markers.removeAll()
        self.lblHoleNumber.text = "\(self.scoring[indexToUpdate].hole)"
        self.lblHoleNumber2.text = "Hole".localized() + " \(self.scoring[indexToUpdate].hole)"

        self.lblParNumber.text = "Par".localized() + " \(self.scoring[indexToUpdate].par)"

        self.lblParNumber2.text = "Par".localized() + " \(self.scoring[indexToUpdate].par)"

        self.lblTopPar.text = "PAR \(self.scoring[indexToUpdate].par)"
        let hcp = self.getHCPValue(playerID: self.playerId, holeNo: self.scoring[indexToUpdate].hole)
        self.lblTopHCP.text = "HCP \(hcp == 0 ? "-":"\(hcp)")"
        
        locationManager.startUpdatingLocation()
        self.positionsOfDotLine.removeAll()
        if(self.userLocationForClub != nil) && (self.playerId == Auth.auth().currentUser!.uid){
            let userToTeeDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
            let userToGreenDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
            let radiusDistance = GMSGeometryDistance(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee, self.courseData.centerPointOfTeeNGreen[indexToUpdate].green) + 200
            if radiusDistance > userToTeeDistance && radiusDistance > userToGreenDistance{
                self.positionsOfDotLine.append(self.userLocationForClub!)
                self.gpsBtn.isHidden = true
            }else{
                self.gpsBtn.isHidden = false
                self.isFarFromHoleFirstTime = false
                self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
            }
        }else{
            self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
        }
        self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].fairway)
        self.positionsOfDotLine.append(self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)

        let distance = GMSGeometryDistance(self.positionsOfDotLine.first!,self.positionsOfDotLine.last!) * Constants.YARD
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
            mapTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if(self.positionsOfDotLine.count > 2){
//                    if self.isBackground{
//                        if(counter%60 == 0){
//                            self.locationManager.startUpdatingLocation()
//                        }
//                    }else{
                        self.locationManager.startUpdatingLocation()
//                    }
//                    debugPrint(self.windSpeed)
//                    debugPrint(self.windHeading)
                    if let currentLocation: CLLocation = self.locationManager.location{
                        if counter%5 == 0{
                            let dict = NSMutableDictionary()
                            dict.addEntries(from: ["lat" : currentLocation.coordinate.latitude])
                            dict.addEntries(from: ["lng" : currentLocation.coordinate.longitude])
                            ref.child("gps/\(Auth.auth().currentUser!.uid)/\(self.matchId)/hole\(self.scoring[self.holeIndex].hole)").updateChildValues(["\(Timestamp)" : dict])
                        }
                    }
                    if Constants.isProMode && self.windTimeStamp < Timestamp{
                        self.updateWindSpeed(latLng: self.userLocationForClub!, indexToUpdate: indexToUpdate)
                    }else{
                        if let currentLocation: CLLocation = self.locationManager.location{
                            debugPrint(currentLocation.altitude)
                            self.userLocationForClub = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                            let heading = GMSGeometryHeading(self.userLocationForClub!,self.courseData.centerPointOfTeeNGreen[self.holeIndex].green)
                            let rotationAngle = self.windHeading-heading
                            UIButton.animate(withDuration: 0.5, animations: {
                                self.imgViewWindForeground.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle) / 180.0 * CGFloat(Double.pi))
                            })
                        }
                    }
                    let userToTeeDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
                    let userToGreenDistance = GMSGeometryDistance(self.userLocationForClub!, self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
                    let radiusDistance = GMSGeometryDistance(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee, self.courseData.centerPointOfTeeNGreen[indexToUpdate].green) + 200
                    if radiusDistance > userToTeeDistance && radiusDistance > userToGreenDistance{
                        self.positionsOfDotLine.remove(at: 0)
                        self.positionsOfDotLine.insert(self.userLocationForClub!, at: 0)
                        self.gpsBtn.isHidden = true
                    }else{
                        self.gpsBtn.isHidden = false
                        self.positionsOfDotLine.remove(at: 0)
                        self.positionsOfDotLine.insert(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee, at: 0)
                    }
                    
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
                        data = self.setFronBackCenter(ind: indexToUpdate, currentLocation: self.positionsOfDotLine.first!)
                    }else{
                        data = self.courseData.holeGreenDataArr[indexToUpdate]
                    }
                    self.updateElevationForeground(p1: self.positionsOfDotLine.first!, p2: data.front, btn: self.btnEleFront, lbl: self.lblDirFront, lblElev: self.lblFrontElev)
                    self.updateElevationForeground(p1: self.positionsOfDotLine.first!, p2: data.center, btn: self.btnEleCenter, lbl: self.lblDirCenter, lblElev: self.lblCenterElev)
                    self.updateElevationForeground(p1: self.positionsOfDotLine.first!, p2: data.back, btn: self.btnEleBack, lbl: self.lblDirBack, lblElev: self.lblBackElev)
                    var distanceF = GMSGeometryDistance(data.front,self.positionsOfDotLine.first!) * Constants.YARD
                    var distanceC = GMSGeometryDistance(data.center,self.positionsOfDotLine.first!) * Constants.YARD
                    var distanceE = GMSGeometryDistance(data.back,self.positionsOfDotLine.first!) * Constants.YARD
                   
                    let elevDistanceFront = BackgroundMapStats.getPlaysLike(headingTarget: GMSGeometryHeading(self.positionsOfDotLine.first!,data.front), degree: self.windHeading-135, windSpeed: self.windSpeed*2.23694, dist: GMSGeometryDistance(self.positionsOfDotLine.first!,data.front)*Constants.YARD)
                    self.lblFrontElev.text = "\(Int(elevDistanceFront.rounded()))"

                    let elevDistanceCenter = BackgroundMapStats.getPlaysLike(headingTarget: GMSGeometryHeading(self.positionsOfDotLine.first!,data.center), degree: self.windHeading-135, windSpeed: self.windSpeed*2.23694, dist: GMSGeometryDistance(self.positionsOfDotLine.first!,data.center)*Constants.YARD)
                    self.lblCenterElev.text = "\(Int(elevDistanceCenter.rounded()))"
                    
                    let elevDistancBack = BackgroundMapStats.getPlaysLike(headingTarget: GMSGeometryHeading(self.positionsOfDotLine.first!,data.back), degree: self.windHeading-135, windSpeed: self.windSpeed*2.23694, dist: GMSGeometryDistance(self.positionsOfDotLine.first!,data.back)*Constants.YARD)
                    self.lblBackElev.text = "\(Int(elevDistancBack.rounded()))"
                    var suffix = "yd"
                    if(Constants.distanceFilter == 1){
                        suffix = "m"
                        distanceF = distanceF/Constants.YARD
                        distanceC = distanceC/Constants.YARD
                        distanceE = distanceE/Constants.YARD
                    }
                    self.lblFrontDist.text = "\(Int(distanceF)) \(suffix)"
                    self.lblCenterDist.text = "\(Int(distanceC)) \(suffix)"
                    self.lblEndDist.text = "\(Int(distanceE)) \(suffix)"
                    self.lblCenterHeader.text = "\(Int(elevDistanceCenter.rounded()))"
                    if !Constants.isProMode{
                        self.lblFrontDist.text = "ELEVATION"
                        self.lblCenterDist.text = "ELEVATION"
                        self.lblEndDist.text = "ELEVATION"
                        
                        self.btnEleFront.isHidden = true
                        self.lblDirFront.isHidden = true
                        self.btnEleCenter.isHidden = true
                        self.lblDirCenter.isHidden = true
                        self.btnEleBack.isHidden = true
                        self.lblDirBack.isHidden = true
                    }
//                    if(counter%60 == 0){
//                        Notification.sendRangeFinderNotification(msg: "Hole \(self.scoring[indexToUpdate].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDic.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distanceC)) \(suffix)", subtitle:"",timer:1.0)
//                    }
                    counter += 1
                }
            })
        }else{
            self.plotLine(positions: positionsOfDotLine)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.plotSuggestedMarkers(position: self.positionsOfDotLine)
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
                self.bottomView.isHidden = false
            }
            if self.classicScoring.stableFordScore != nil{
                self.lblStblScore.text = "\(self.classicScoring.stableFordScore!)"
                self.btnStablefordScore.setTitle("Stableford Score", for: .normal)
            }
            self.scrlHConstraint.constant = self.scrlContainerView.frame.size.height + 180
            self.view.layoutIfNeeded()
        })

    }
    func updateElevationForeground(p1:CLLocationCoordinate2D,p2:CLLocationCoordinate2D,btn:UIButton,lbl:UILabel,lblElev:UILabel){
        if !self.courseData.elevationHole.isEmpty{
            let elevation1 = self.getElevationPoint(position: p1, holeArr: self.courseData.elevationHole[self.holeIndex])
            let elevation2 = self.getElevationPoint(position: p2, holeArr: self.courseData.elevationHole[self.holeIndex])
            
            let elev1 = elevation1.value(forKey: "elevation") as! Double
            let elev2 = elevation2.value(forKey: "elevation") as! Double
            var finalElev = elev1-elev2
            var suffix = "m"
            if(Constants.distanceFilter == 0){
                finalElev = finalElev*3.28084
                suffix = "ft"
            }
            if finalElev > 0{
                BackgroundMapStats.setDir(isUp: false, label: lbl)
                btn.setTitleColor(UIColor.glfGreen, for: .normal)
            }else{
                if Constants.isProMode{
                    BackgroundMapStats.setDir(isUp: true, label: lbl)
                    btn.setTitleColor(UIColor.glfRed, for: .normal)
                }
            }
            btn.setTitle("\(Int(abs(finalElev))) \(suffix)", for: .normal)
        }else{
            lbl.isHidden = true
            btn.isHidden = true
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let rotationAngle = self.windHeading - position.bearing
        self.windNotesView.imgWind.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle) / 180.0 * CGFloat(Double.pi))
    }
    func getSuggestedClub(distance:Double,isGreen:Bool,shot:Int)->NSMutableAttributedString{
        var clubName = String()
        var distance = distance
        if(Constants.distanceFilter == 1){
            distance = distance/Constants.YARD
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
                if(Constants.distanceFilter == 1){
                    clubName = clubs.name + " - \(Int(distance.rounded())) m"
                }
                
                if(shot > 1 && clubs.name == "Dr"){
                    clubName = "1i - \(Int(distance.rounded())) Yd"
                    if(Constants.distanceFilter == 1){
                        clubName = "1i - \(Int(distance.rounded())) m"
                    }
                }
                break
            }
            else if(distance < 80){
                if(isGreen){
                    clubName = "Pu - \(Int((distance*3).rounded())) ft"
                    if(Constants.distanceFilter == 1){
                        clubName = "Pu - \(Int((distance/3).rounded())) m"
                    }
                    
                }
                else{
                    clubName = "Lw - \(Int((distance).rounded())) Yd"
                    if(Constants.distanceFilter == 1){
                        clubName = "Lw - \(Int((distance).rounded())) m"
                    }
                }
                break
            }
            else{
                if(shot > 1){
                    clubName = "1i - \(Int(distance.rounded())) Yd"
                    if(Constants.distanceFilter == 1){
                        clubName = "1i - \(Int((distance).rounded())) m"
                    }
                }
                else{
                    clubName = "Dr - \(Int(distance.rounded())) Yd"
                    if(Constants.distanceFilter == 1){
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
        if !isContinueMatch{
            self.updateCoreData()
        }
        windNotesView.btnNotesUnlock.addTarget(self, action: #selector(self.addNotesAction(_:)), for: .touchUpInside)
        windNotesView.btnWindUnlock.addTarget(self, action: #selector(self.btnActionWindLocked(_:)), for: .touchUpInside)
    }
    func updateCoreData(){
        var greenModel = [GreenLatLngModel]()
        var i = 0
        for data in self.courseData.numberOfHoles{
            for latLng in data.green{
                let model = GreenLatLngModel()
                model.greenNum = i
                model.lat = latLng.latitude
                model.lng = latLng.longitude
                greenModel.append(model)
            }
            i += 1
        }
        var frontBackDistanceArr = [FrontBackDistance]()
        for data in self.courseData.holeGreenDataArr{
            let fbDistance = FrontBackDistance()
            fbDistance.backLat = data.back.latitude
            fbDistance.backLng = data.back.longitude
            fbDistance.centerLat = data.center.latitude
            fbDistance.centerLng = data.center.longitude
            fbDistance.frontLat = data.front.latitude
            fbDistance.frontLng = data.front.longitude
            frontBackDistanceArr.append(fbDistance)
        }
        BackgroundMapStats.donateInteraction()
        context.performAndWait{ () -> Void in
            if let counter1 = NSManagedObject.findAllForEntity("TeeDistanceEntity", context: context){
                counter1.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            if let counter1 = NSManagedObject.findAllForEntity("FrontBackDistanceEntity", context: context){
                counter1.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            if let counter1 = NSManagedObject.findAllForEntity("CourseDetailsEntity", context: context){
                counter1.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            if let counter = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: context){
                counter.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            for data in greenModel{
                if let greenEntity = NSEntityDescription.insertNewObject(forEntityName: "GreenDistanceEntity", into: context) as? GreenDistanceEntity{
                    greenEntity.greeNum = Int16(data.greenNum)
                    greenEntity.lat = data.lat
                    greenEntity.lng = data.lng
                    CoreDataStorage.saveContext(context)
                }
            }
            var i = 0
            for data in self.courseData.centerPointOfTeeNGreen{
                if let teeEntity = NSEntityDescription.insertNewObject(forEntityName: "TeeDistanceEntity", into: context) as? TeeDistanceEntity{
                    teeEntity.teeNum = Int16(i)
                    teeEntity.lat = data.tee.latitude
                    teeEntity.lng = data.tee.longitude
                    CoreDataStorage.saveContext(context)
                    i += 1
                }
            }
            for data in frontBackDistanceArr{
                if let frontBackEntity = NSEntityDescription.insertNewObject(forEntityName: "FrontBackDistanceEntity", into: context) as? FrontBackDistanceEntity{
                    frontBackEntity.backLat = data.backLat
                    frontBackEntity.backLng = data.backLng
                    frontBackEntity.frontLat = data.frontLat
                    frontBackEntity.frontLng = data.frontLng
                    frontBackEntity.centerLat = data.centerLat
                    frontBackEntity.centerLng = data.centerLng
                    CoreDataStorage.saveContext(context)
                }
            }
            if let courseDataEn = NSEntityDescription.insertNewObject(forEntityName: "CourseDetailsEntity", into: context) as? CourseDetailsEntity{
                var matchDataDictionary = NSMutableDictionary()
                if(self.isAcceptInvite){
                    matchDataDictionary = self.matchDataDic
                }else{
                    matchDataDictionary = matchDataDic
                }
                courseDataEn.cName = matchDataDictionary.value(forKey: "courseName") as? String
                courseDataEn.uName = Auth.auth().currentUser!.displayName
                courseDataEn.imgUrl = ""
                CoreDataStorage.saveContext(context)
            }
            for data in greenModel{
                if let greenEntity = (NSEntityDescription.insertNewObject(forEntityName: "GreenDistanceEntity", into: context) as? GreenDistanceEntity){
                    greenEntity.greeNum = Int16(data.greenNum)
                    greenEntity.lat = data.lat
                    greenEntity.lng = data.lng
                    CoreDataStorage.saveContext(context)
                }
            }
            if let counter = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: context){
                counter.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            if let curHoleEntity = NSEntityDescription.insertNewObject(forEntityName: "CurrentHoleEntity", into: context) as? CurrentHoleEntity{
                curHoleEntity.timestamp = Timestamp
                curHoleEntity.holeIndex = Int16(0)
                CoreDataStorage.saveContext(context)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if let thePresenter = self.navigationController?.visibleViewController{
                    if (thePresenter.isKind(of:RFMapVC.self)) && self.farFromTheHoleView.isHidden{
                        self.showCaseTargetMarker()
                        timerForMiddleMarker.invalidate()
                    }
                }
            })

        })
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
    func getElevationPoint(position:CLLocationCoordinate2D,holeArr:NSArray)->NSMutableDictionary{
        var coordArr = [CLLocationCoordinate2D]()
        var hArr = [NSMutableDictionary]()
        for value in holeArr{
            hArr.append(value as! NSMutableDictionary)
        }
        for data in hArr{
            coordArr.append(CLLocationCoordinate2D(latitude: data.value(forKey: "lat") as! Double, longitude: data.value(forKey: "lng") as! Double))
        }
        let nearbuy = holeArr[BackgroundMapStats.nearByPoint(newPoint: position, array: coordArr)]
        return nearbuy as! NSMutableDictionary
    }
    func plotSuggestedMarkers(position:[CLLocationCoordinate2D]){
        if(position.count > 2){
            var markerClub = String()
            var markerClub1 = String()
            
            suggestedMarker1.map = nil
            var dist1 = GMSGeometryDistance(position.first!, position[1]) * Constants.YARD
            var dist = GMSGeometryDistance(position[1], position.last!) * Constants.YARD
            var suffix = "yd"
            if(Constants.distanceFilter == 1){
                dist1 = dist1/Constants.YARD
                dist = dist/Constants.YARD
                suffix = "m"
            }
            let elev1 = BackgroundMapStats.getPlaysLike(headingTarget: GMSGeometryHeading(position.first!, position[1]), degree: self.windHeading-135, windSpeed: self.windSpeed * 2.23694, dist: GMSGeometryDistance(position.first!, position[1]) * Constants.YARD)
            
            let elev = BackgroundMapStats.getPlaysLike(headingTarget: GMSGeometryHeading(position[1], position.last!), degree: self.windHeading-135, windSpeed: self.windSpeed * 2.23694, dist: GMSGeometryDistance(position[1], position.last!) * Constants.YARD)
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
            
            btnForSugg1.setAllData(club: markerClub1, dist: Int(elev1.rounded()), elevDis:"\(Int(dist1)) \(suffix)")
            if !courseData.elevationHole.isEmpty{
                let elevation1 = self.getElevationPoint(position: position.first!, holeArr: courseData.elevationHole[self.holeIndex])
                let elevation2 = self.getElevationPoint(position: position[1], holeArr: courseData.elevationHole[self.holeIndex])
                let elev1 = elevation1.value(forKey: "elevation") as! Double
                let elev2 = elevation2.value(forKey: "elevation") as! Double
                var finalElev = elev1-elev2
                var suffix = "m"
                if(Constants.distanceFilter == 0){
                    finalElev = finalElev*3.28084
                    suffix = "ft"
                }
                if finalElev > 0{
                    BackgroundMapStats.setDir(isUp: false, label: btnForSugg1.lblDirection)
                    btnForSugg1.btnElev.setTitleColor(UIColor.glfGreen, for: .normal)
                }else{
                    if Constants.isProMode{
                        BackgroundMapStats.setDir(isUp: true, label: btnForSugg1.lblDirection)
                        btnForSugg1.btnElev.setTitleColor(UIColor.glfRed, for: .normal)
                    }
                }
                btnForSugg1.btnElev.setTitle("\(Int(abs(finalElev))) \(suffix)", for: .normal)
                btnForSugg1.lblDirection.isHidden = !Constants.isProMode
                btnForSugg1.btnElev.isHidden = !Constants.isProMode
            }else{
                btnForSugg1.lblDirection.isHidden = true
                BackgroundMapStats.setDir(isUp: true, label: btnForSugg1.lblDirection)
                btnForSugg1.btnElev.isHidden = true
            }

            btnForSugg1.autoresize()
            suggestedMarker1.iconView = btnForSugg1
            suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
            suggestedMarker1.position = GMSGeometryOffset(position.first!, dist1/2, GMSGeometryHeading(position.first!, position[1]))
            suggestedMarker1.map = self.mapView
            suggestedMarker2.map = nil
            btnForSugg2.setAllData(club: markerClub, dist: Int(elev.rounded()), elevDis: "\(Int(dist)) \(suffix)")
            if !courseData.elevationHole.isEmpty{
                let elevation1 = self.getElevationPoint(position: position[1], holeArr: courseData.elevationHole[self.holeIndex])
                let elevation2 = self.getElevationPoint(position: position.last!, holeArr: courseData.elevationHole[self.holeIndex])
                let elev1 = elevation1.value(forKey: "elevation") as! Double
                let elev2 = elevation2.value(forKey: "elevation") as! Double
                var finalElev = elev1-elev2
                var suffix = "m"
                if(Constants.distanceFilter == 0){
                    finalElev = finalElev*3.28084
                    suffix = "ft"
                }
                if finalElev > 0{
                    BackgroundMapStats.setDir(isUp: false, label: btnForSugg2.lblDirection)
                    btnForSugg2.btnElev.setTitleColor(UIColor.glfGreen, for: .normal)
                }else{
                    if Constants.isProMode{
                        BackgroundMapStats.setDir(isUp: true, label: btnForSugg2.lblDirection)
                        btnForSugg2.btnElev.setTitleColor(UIColor.glfRed, for: .normal)
                    }
                }
                btnForSugg2.btnElev.setTitle("\(Int(abs(finalElev))) \(suffix)", for: .normal)
                btnForSugg2.lblDirection.isHidden = !Constants.isProMode
                btnForSugg2.btnElev.isHidden = !Constants.isProMode
            }else{
                btnForSugg2.lblDirection.isHidden = true
                BackgroundMapStats.setDir(isUp: true, label: btnForSugg2.lblDirection)
                btnForSugg2.btnElev.isHidden = true
            }
            btnForSugg2.autoresize()
            suggestedMarker2.iconView = btnForSugg2
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

    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        if isViewDidEntered{
            self.farFromTheHoleView.isHidden = self.isFarFromHoleFirstTime
            if isContinueMatch{
                isViewDidEntered = false
            }
        }
        self.isFarFromHoleFirstTime = true
    }
}
extension RFMapVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //        self.mapView.isMyLocationEnabled = true
        let userLocation = locations.last
        userLocationForClub = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        locationManager.stopUpdatingLocation()
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
                self.lblPlayerNameDSV.text = "Your Score".localized()
                self.lblPlayerNameSSV.text = "Your Score".localized()
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
        FBSomeEvents.shared.singleParamFBEvene(param: "View Rangefinder Hole \(index)")
        Notification.sendLocaNotificatonToUser()
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(index)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(self.matchId)/").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
    }
    
    @IBAction func nextAction(_ sender: UIButton!) {
        self.isViewDidEntered = false
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
        self.isViewDidEntered = false
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
}
extension RFMapVC{
    // MARK :- showCaseMiddleMarker
    func userInteractionSomeView(isHide:Bool){
        self.btnNext.isHidden = isHide
        self.btnPrev.isHidden = isHide
        self.btnEditShots.isHidden = isHide
        self.lblEditShotNumber.isHidden = isHide
        self.windNotesView.isHidden = isHide
    }
    func showCaseTargetMarker(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            let tutorialCount = UserDefaults.standard.integer(forKey: "RFTutorial")
            if(self.positionsOfDotLine.count > 1) && tutorialCount < 2{
                self.userInteractionSomeView(isHide:true)
                self.showcaseView.frame = CGRect(origin:.zero,size:CGSize(width:self.mapView.frame.height,height:self.mapView.frame.height))
                self.showcaseView.layer.cornerRadius = (self.showcaseView.frame.height)*0.5
                self.showcaseView.backgroundColor = UIColor.glfBlack95
                self.showcaseView.isUserInteractionEnabled = true
                
                let point = self.mapView.projection.point(for: self.positionsOfDotLine[1])
                self.showcaseView.center = point
                let fram = self.showcaseView.convert(point, from:self.view)

                let label2 = UILabel(frame: CGRect(x: fram.x-30, y: fram.y-30, width: 60, height: 60))
                
                label2.backgroundColor = UIColor.clear
                label2.setCircle(frame: label2.frame)
                
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.showcaseView.bounds
                maskLayer.fillColor = UIColor.glfBlack95.cgColor
                
                let path = UIBezierPath(rect: self.showcaseView.bounds)
                maskLayer.fillRule = kCAFillRuleEvenOdd
                
                // Append the circle to the path so that it is subtracted.
                path.append(UIBezierPath(ovalIn: label2.frame))
                maskLayer.path = path.cgPath
                
                self.showcaseView.layer.mask = maskLayer
                self.blurWhiteCircleLayer.path = UIBezierPath(roundedRect: label2.frame, cornerRadius: 30).cgPath
                self.blurWhiteCircleLayer.fillColor = UIColor.white.cgColor
                self.blurWhiteCircleLayer.opacity = 0.0
                
                self.showcaseView.layer.addSublayer(self.blurWhiteCircleLayer)
                self.showcaseView.addSubview(label2)
                let lbl = UILabel(frame: CGRect(x:label2.frame.minX-self.view.frame.height*0.2, y: label2.frame.minY+self.view.frame.height*0.2, width: self.view.frame.width*0.8, height: 60))
                lbl.numberOfLines = 0
                lbl.text = "Drag the marker to set your target.".localized()
                if UIDevice.current.iPhone5 || UIDevice.current.iPhoneSE{
                    lbl.font = UIFont(name: "SFProDisplay-Medium", size: 18)
                }else{
                    lbl.font = UIFont(name: "SFProDisplay-Medium", size: 22)
                }
                lbl.textColor = UIColor.glfWhite
                lbl.textAlignment = .left
                lbl.sizeToFit()
                let newPoint = self.showcaseView.convert(CGPoint(x:16,y:point.y+100), from:self.view)
                lbl.frame.origin = newPoint
                self.showcaseView.addSubview(label2)
                self.showcaseView.addSubview(lbl)
                
                self.addBulrFilterToWhiteCircle(blurWhiteCircleLayer:self.blurWhiteCircleLayer)
                self.playAnimationForWhiteCircle(blurWhiteCircleLayer:self.blurWhiteCircleLayer)
                self.mapView.addSubview(self.showcaseView)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.showcaseView.isHidden = false
                })
                UserDefaults.standard.set(tutorialCount+1, forKey: "RFTutorial")
                UserDefaults.standard.synchronize()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    var timerForMiddleMarker = Timer()
                    timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                        if let thePresenter = self.navigationController?.visibleViewController{
                            if (thePresenter.isKind(of:RFMapVC.self)) && !self.isDraggingMarker && self.farFromTheHoleView.isHidden && self.btnNext.isHidden && self.showcaseView.isHidden{
                                self.userInteractionSomeView(isHide:false)
                                self.showCaseRecommendedClub()
                                timerForMiddleMarker.invalidate()
                            }
                        }
                    })
                })
            }
        })
    }
    func addBulrFilterToWhiteCircle(blurWhiteCircleLayer:CAShapeLayer){
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(0, forKey: "inputRadius")
        blurFilter?.setValue(30, forKey: "inputRadius")
        blurWhiteCircleLayer.filters = [blurFilter!]
    }
    func playAnimationForWhiteCircle(blurWhiteCircleLayer:CAShapeLayer){
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1.55
        animation.beginTime = CACurrentMediaTime() + 0.8
        
        let point = self.mapView.projection.point(for: self.positionsOfDotLine[1])
        self.showcaseView.center = point
        let frams = self.showcaseView.convert(point, from:self.view)
        let label2 = UILabel(frame: CGRect(x: frams.x-30, y: frams.y-30, width: 60, height: 60))
        label2.setCircle(frame: label2.frame)
        var fram : CGRect = self.showcaseView.convert(label2.frame, from:self.showcaseView)
        fram = self.add(number: 100,fram:fram)
        
        let path = UIBezierPath(roundedRect: fram, cornerRadius: 100)
        path.append(UIBezierPath(roundedRect: fram, cornerRadius: 60))
        path.usesEvenOddFillRule = true
        
        animation.toValue = path.cgPath
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.repeatCount = HUGE
        // if you remove it the shape will return to the original shape after the animation finished
        animation.fillMode = kCAFillRuleEvenOdd
        animation.isRemovedOnCompletion = false
        blurWhiteCircleLayer.add(animation, forKey: nil)
        
        let opacityanimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        opacityanimation.fromValue = 0.7
        opacityanimation.toValue = 0
        opacityanimation.beginTime = CACurrentMediaTime() + 0.8
        opacityanimation.repeatCount = HUGE
        opacityanimation.duration = 1.55
        blurWhiteCircleLayer.add(opacityanimation, forKey: nil)
    }
    private func add(number: CGFloat, fram:CGRect)->CGRect{
        return CGRect(x:fram.minX - (number/2), y:fram.minY - (number/2), width:fram.width + number, height:fram.height + number)
    }
    
    func showCaseRecommendedClub(){
        var label2 = UILabel()
        let point = self.mapView.projection.point(for: suggestedMarker1.position)
        label2 = UILabel(frame: CGRect(x: point.x, y: point.y-self.btnForSugg1.frame.height/2, width: self.btnForSugg1.frame.width, height: self.btnForSugg1.frame.height))
        self.mapView.addSubview(label2)
        let tapTargetPrompt = MaterialTapTargetPrompt(target: label2, type: .rectangle)
        tapTargetPrompt.action = {
            label2.removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.isDraggingMarker{
                            self.showCaseDistanceToGreen()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.dismissed = {
            print("view dismissed")
            label2.removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.isDraggingMarker{
                            self.showCaseDistanceToGreen()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.circleColor = UIColor.glfBlack95
        tapTargetPrompt.primaryText = ""
        let str = BackgroundMapStats.getClubName(club: self.btnForSugg1.lblClub.text!.trim())
        var attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 22)]
        var attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 18)]
        if UIDevice.current.iPhone5 || UIDevice.current.iPhoneSE{
            attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 18)]
            attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 14)]
        }
        
        let attributedText = NSMutableAttributedString()
        let attributedQuote = NSAttributedString(string: "Your recommended club for this shot is \(str)\n", attributes: attributes as [NSAttributedStringKey : Any])
        let attributedQuote2 = NSAttributedString(string: "\nTap to continue.", attributes: attributes2 as [NSAttributedStringKey : Any])
        attributedText.append(attributedQuote)
        attributedText.append(attributedQuote2)
        tapTargetPrompt.secondaryTextLabel.attributedText = attributedText
        tapTargetPrompt.secondaryTextLabel.textAlignment = .left
        tapTargetPrompt.secondaryTextLabel.frame = CGRect(origin: CGPoint(x:self.view.frame.width/2 ,y:self.view.frame.width*1.2), size: CGSize(width:self.view.frame.width*0.8,height:5))
        tapTargetPrompt.secondaryTextLabel.sizeToFit()
    }
    func showCaseDistanceToGreen(){
        let tapTargetPrompt = MaterialTapTargetPrompt(target: self.lblCenterHeader)
        tapTargetPrompt.action = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.isDraggingMarker && !self.btnCenter.isHidden{
                            self.showCasePulledDown()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.dismissed = {
            print("view dismissed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.isDraggingMarker && !self.btnCenter.isHidden{
                            self.showCasePulledDown()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.circleColor = UIColor.glfBlack95
        tapTargetPrompt.primaryText = ""
        var attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 22)]
        var attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 18)]
        if UIDevice.current.iPhone5 || UIDevice.current.iPhoneSE{
            attributes = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 18)]
            attributes2 = [NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Regular", size: 14)]
        }
        
        let attributedText = NSMutableAttributedString()
        let attributedQuote = NSAttributedString(string: "Check your distance to the green\n", attributes: attributes as [NSAttributedStringKey : Any])
        let attributedQuote2 = NSAttributedString(string: "\nTap to continue.", attributes: attributes2 as [NSAttributedStringKey : Any])
        attributedText.append(attributedQuote)
        attributedText.append(attributedQuote2)
        tapTargetPrompt.secondaryTextLabel.attributedText = attributedText
        tapTargetPrompt.secondaryTextLabel.frame = CGRect(origin: CGPoint(x:self.view.frame.width/4 ,y:self.view.frame.width*1.2), size: CGSize(width:self.view.frame.width*0.8,height:5))
        tapTargetPrompt.secondaryTextLabel.textAlignment = .left
        tapTargetPrompt.secondaryTextLabel.sizeToFit()
    }
    func showCasePulledDown(){
        let tapTargetPrompt = MaterialTapTargetPrompt(target: self.btnCenter)
        tapTargetPrompt.action = {
            self.btnActionMoveToMap(Any.self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.viewForground.isHidden{
                            self.showCasePulledUp()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.dismissed = {
            print("view dismissed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && !self.viewForground.isHidden{
                            self.showCasePulledUp()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.circleColor = UIColor.glfBlack95
        tapTargetPrompt.primaryText = ""
        tapTargetPrompt.secondaryText = "Pull down to view distances to front, center and back.".localized()
        tapTargetPrompt.secondaryTextLabel.frame = CGRect(origin: CGPoint(x:self.view.frame.width/4 ,y:self.view.frame.width*1.2), size: CGSize(width:self.view.frame.width*0.8,height:5))
        tapTargetPrompt.secondaryTextLabel.textAlignment = .left
        tapTargetPrompt.secondaryTextLabel.sizeToFit()

    }
    func showCasePulledUp(){
        let tapTargetPrompt = MaterialTapTargetPrompt(target: self.btnMoveToMapGround)
        tapTargetPrompt.action = {
            self.btnActionMoveToMap(Any.self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && self.viewForground.isHidden && !self.btnNext.isHidden && !self.isDraggingMarker{
                            self.showCaseEnterHoleScore()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.dismissed = {
            print("view dismissed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                var timerForMiddleMarker = Timer()
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:RFMapVC.self)) && self.viewForground.isHidden && !self.btnNext.isHidden && !self.isDraggingMarker{
                            self.showCaseEnterHoleScore()
                            timerForMiddleMarker.invalidate()
                        }
                    }
                })
            })
        }
        tapTargetPrompt.circleColor = UIColor.glfBlack95
        tapTargetPrompt.primaryText = ""
        tapTargetPrompt.secondaryText = "Swipe up to go back to GPS view.".localized()
        tapTargetPrompt.secondaryTextLabel.frame = CGRect(origin: CGPoint(x:self.view.frame.width/6,y:self.view.frame.width/2), size: CGSize(width:self.view.frame.width*0.8,height:5))
        tapTargetPrompt.secondaryTextLabel.sizeToFit()
    }
    
    func showCaseEnterHoleScore(){
        let tapTargetPrompt = MaterialTapTargetPrompt(target: self.btnEditShots)
        tapTargetPrompt.action = {
            self.playerStatsAction(self.btnPlayerStats)
        }
        tapTargetPrompt.dismissed = {
            print("view dismissed")
        }
        tapTargetPrompt.circleColor = UIColor.glfBlack95
        tapTargetPrompt.primaryText = ""
        tapTargetPrompt.secondaryText = "Score your hole when finished.".localized()
        tapTargetPrompt.secondaryTextLabel.frame = CGRect(origin: CGPoint(x:self.view.frame.width/6,y:self.view.frame.width/2), size: CGSize(width:self.view.frame.width*0.8,height:5))
        tapTargetPrompt.secondaryTextLabel.sizeToFit()
    }
}
