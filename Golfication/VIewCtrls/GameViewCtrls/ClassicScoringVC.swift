//
//  ClassicScoringVC.swift
//  Golfication
//
//  Created by Khelfie on 07/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import ActionSheetPicker_3_0
import UserNotifications

class ClassicScoringVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var titleLabel : UIButton!
    @IBOutlet weak var backBtnHeader: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackViewMenu: StackView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblCourseNameTitle: UILabel!
    @IBOutlet weak var btnViewScoreCard: UIButton!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var btnContinue: UILocalizedButton!
    
    var holeOutforAppsFlyer = [Int]()
    var holeOut = false
    var gir : Bool!
    var holeWiseShots = NSMutableDictionary()
    var classicScoring = classicMode()
    var isAccept = false
    var plyerViseScore = [[(gir:Bool,fairwayHit:String)]]()
    var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var isContinue = false
    var currentIndex = 0
    var playerData = NSMutableArray()
    var matchDataDict = NSMutableDictionary()
    var playersArray = [(id:String,name:String,image:String,isExpended:Bool)]()
    var playerIndex = 0
    var currentPlayerId = String()
    var isAcceptInvite = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let originalImage =  #imageLiteral(resourceName: "backArrow")
        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backBtnHeader.setBackgroundImage(backBtnImage, for: .normal)
        backBtnHeader.tintColor = UIColor.glfWhite
        self.navigationController?.navigationBar.isHidden = true
        self.btnContinue.layer.cornerRadius = 3
        self.btnContinue.setTitle("  " + "Continue".localized(), for: .normal)
        
        self.lblCourseNameTitle.text = self.matchDataDict.value(forKey: "courseName") as? String
        if(Constants.matchDataDic.object(forKey: "player") != nil){
            let tempArray = Constants.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                playerData.add(dict)
            }
        }

        var i = 0
        for data in playerData{
            let id = (data as! NSMutableDictionary).value(forKey: "id") as! String
            let name = (data as! NSMutableDictionary).value(forKey: "name") as! String
            let image = (data as! NSMutableDictionary).value(forKey: "image") as! String
            self.playersArray.append((id: id, name: name, image: image,isExpended:false))
            if(id == Auth.auth().currentUser?.uid){
                self.playerIndex = i
                self.currentPlayerId = id
            }
            i += 1
            self.holeOutforAppsFlyer.append(0)
        }
        if !isContinue {
            self.initilizeScoreNode()
        }else{
            
        }
        //
        let downArrow = #imageLiteral(resourceName: "Club_arrow_down")
        let downArrowImage = downArrow.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.titleLabel.setImage(downArrowImage, for: .normal)
        self.titleLabel.tintColor = UIColor.glfBlack
        self.titleLabel.semanticContentAttribute = .forceRightToLeft
        
        self.btnContinue.isHidden = true
        
        
        
        // swipe gesture for chipping card view
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector((handleSwipes)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.tableView.addGestureRecognizer(leftSwipe)
        self.tableView.addGestureRecognizer(rightSwipe)
   
    }
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            self.currentIndex = self.currentIndex - 1
            if(self.currentIndex == -1){
                self.currentIndex = self.scoreData.count-1
            }
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                self.tableView.frame = self.tableView.frame.offsetBy(dx: self.view.frame.width, dy: 0)
            }
            animator.startAnimation()
            
        }
        if (sender.direction == .left) {
            self.currentIndex = self.currentIndex + 1
            if(self.currentIndex == self.scoreData.count){
                self.currentIndex = 0
            }
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                self.tableView.frame = self.tableView.frame.offsetBy(dx: -self.view.frame.width, dy: 0)
            }
            animator.startAnimation()
        }
        
        titleLabel.setTitle("Hole".localized() + " \(currentIndex+1) - " + "Par".localized() + " \(self.scoreData[self.currentIndex].par)", for: .normal)

        self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Back Button Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: NewGameVC.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: !isAcceptInvite)
                break
            }
        }
//        self.navigationController?.popViewController(animated: !isAcceptInvite)
    }
    
    @IBAction func btnActionHoleChange(_ sender: UIButton) {
        var holeArray = [String]()
        for i in 1..<self.scoreData.count+1{
            holeArray.append("\(i)")
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.titleLabel.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        })
        ActionSheetStringPicker.show(withTitle: "Select Hole", rows: holeArray, initialSelection: self.currentIndex, doneBlock: {
            picker, value, index in
            self.currentIndex = value
            self.titleLabel.setTitle("Hole".localized() + " \(self.currentIndex+1) - " + "Par".localized() + " \(self.scoreData[self.currentIndex].par)", for: .normal)

            self.tableView.reloadData()
            UIView.animate(withDuration: 0.4, animations: {
                self.titleLabel.imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    //MARK: - TableView DataSources/Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton()
        btn.tag = indexPath.row
        guard let cell = tableView.cellForRow(at: indexPath) as? ClassicScoringTableViewCell
            else { return }

        if !(cell.isExpanded){
            self.btnActionMoreScore(btn)
        }

    }
    
    @objc func btnActionMoreScore(_ sender: UIButton) {
        self.currentPlayerId = playersArray[sender.tag].id
        self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ClassicScoringTableViewCell
            else { return }
        if cell.isExpanded{
            UIView.animate(withDuration: 0.4, animations: {
                cell.btnMoreStats.imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            cell.isExpanded = false
            playersArray[indexPath.row].isExpended = false
        }else{
            UIView.animate(withDuration: 0.4, animations: {
                cell.btnMoreStats.imageView?.transform = CGAffineTransform(rotationAngle: (0 * CGFloat(Double.pi)) / 180.0)
            })
            cell.isExpanded = true
            playersArray[indexPath.row].isExpended = true
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
    }
    
    @IBAction func btnActionMenu(_ sender: UIButton) {
        var j = 0
        for player in playersArray{
            self.holeOutforAppsFlyer[j] = self.checkHoleOutZero(playerId: player.id)
            j += 1
        }
        if(stackViewMenu.isHidden){
            stackViewMenu.isHidden = false
        }else{
            stackViewMenu.isHidden = true
        }
    }
    func checkHoleOutZero(playerId:String) -> Int{
        // --------------------------- Check If User has not played game at all ------------------------
        var myVal: Int = 0
        for i in 0..<self.scoreData.count{
            for dataDict in self.scoreData[i].players{
                for (key,value) in dataDict{
                    let dic = value as! NSDictionary
                    if dic.value(forKey: "holeOut") as! Bool == true{
                        if(key as? String == playerId){
                            for (key,value) in value as! NSMutableDictionary
                            {
                                if (key as! String == "holeOut" && value as! Bool){
                                    myVal = myVal + (value as! Int)
                                }
                            }
                        }
                    }
                }
            }
        }
        return myVal
    }
    func getScoreFromMatchDataFirebase(keyId:String){
        self.tableView.isHidden = true
        ref.child("matchData/\(keyId)/scoring/\(self.currentIndex)/\(self.currentPlayerId)").observe(DataEventType.value, with: { (snapshot) in
            if  let scoreDict = (snapshot.value as? NSMutableDictionary){
                var j = 0
                for playersId in self.playersArray{
                    if self.currentPlayerId == playersId.id{
                        let dict = NSMutableDictionary()
                        dict.addEntries(from: [self.currentPlayerId:scoreDict])
                        self.scoreData[self.currentIndex].players[j] = dict
                        break
                    }
                    j += 1
                }
                self.tableView.reloadData()
            }
            self.tableView.isHidden = false
        })
        { (error) in
            //            print(error.localizedDescription)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "ClassicScoringCell") as! ClassicScoringTableViewCell
        cell.holeWiseShots = NSMutableDictionary()
        cell.classicScoring = self.getScoreIntoClassicNode(hole: self.currentIndex, playerKey:playersArray[indexPath.row].id)
        cell.selectionStyle = .none
        cell.btnPlayerName.setTitle(playersArray[indexPath.row].name, for: .normal)
        cell.userImageView.sd_setImage(with: URL(string:playersArray[indexPath.row].image), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
        cell.isSelected = false
        cell.index = self.currentIndex
        cell.btnMoreStats.tag = indexPath.row
        cell.btnMoreStats.addTarget(self, action: #selector(self.btnActionMoreScore(_:)), for: .touchUpInside)
        cell.btnScoreSelection.tag = indexPath.row
        cell.btnScoreSelection.addTarget(self, action: #selector(self.btnActionScoreSelection(_:)), for: .touchUpInside)
        tableView.deselectRow(at: indexPath, animated: true)
        cell.playerId = self.scoreData[self.currentIndex].players[indexPath.row].allKeys[0] as! String
        cell.isExpanded = playersArray[indexPath.row].isExpended
        cell.updateValue()
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    // MARK: - Initilize ScoringNode
    func initilizeScoreNode(){
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
        for i in 0..<self.scoreData.count{
            //            holeOutforAppsFlyer = [Int]()
            let player = NSMutableDictionary()
            for j in 0..<self.playerData.count{
                let data = self.playerData[j] as! NSMutableDictionary
                let playerScore = NSMutableDictionary()
                let playerDataHole = ["holeOut":false]
                player.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                playerScore.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                self.scoreData[i].players.append(playerScore)
                // holeOutforAppsFlyer.append(0)
            }
            player.setObject(self.scoreData[i].par, forKey: "par" as NSCopying)
            holeArray.append(player)
        }
        self.btnContinue.isHidden = true
        scoring.setObject(holeArray, forKey: "scoring" as NSCopying)
        ref.child("matchData/\(Constants.matchId)/").updateChildValues(scoring as! [AnyHashable : Any])
    }
    @objc func btnActionScoreSelection(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ClassicScoringTableViewCell
            else { return }
        ActionSheetStringPicker.show(withTitle: "Strokes".localized(), rows: ["1", "2", "3", "4", "5", "6", "7", "8","9","10","11","12","13","14","15","16","17","18","19","20"], initialSelection: 0, doneBlock: {
            picker, value, index in
            cell.btnScoreSelection.setTitle("\(value+1)", for: .normal)
            self.holeWiseShots.setObject(value+1, forKey: "strokes" as NSCopying)
            self.holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
            cell.isExpanded = true
            self.playersArray[indexPath.row].isExpended = true
            ref.child("matchData/\(Constants.matchId)/scoring/\(self.currentIndex)/\(self.playersArray[indexPath.row].id)").updateChildValues(["strokes":value+1] as [AnyHashable : Any])
            ref.child("matchData/\(Constants.matchId)/scoring/\(self.currentIndex)/\(self.playersArray[indexPath.row].id)").updateChildValues(["holeOut":true] as [AnyHashable : Any])
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.btnContinue.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                cell.btnScoreSelection.imageView?.transform = CGAffineTransform(rotationAngle: (0 * CGFloat(Double.pi)) / 180.0)
            })
            return
        }, cancel: { ActionStringCancelBlock in
            
            return
        }, origin: sender)
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
                if let strokesCount = dic.value(forKey: "score") as? NSArray{
                    classicScore.strokesCount = strokesCount.count
                }
                if let holeOut = dic.value(forKey: "holeOut") as? Bool{
                    classicScore.holeOut = holeOut
                    self.btnContinue.isHidden = !holeOut
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
            }
        }
        return classicScore
    }
    
    @IBAction func btnActionViewScoreCard(_ sender: UIButton) {
        ref.child("matchData/\(Constants.matchId)/scoring/\(self.currentIndex)/\(self.currentPlayerId)").removeAllObservers()
        let players = NSMutableArray()
        if(Constants.matchDataDic.object(forKey: "player") != nil){
            let tempArray = Constants.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                players.add(dict)
            }
        }
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = scoreData
        viewCtrl.playerData = players
        viewCtrl.isContinue = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    
    @IBAction func btnPrevAction(_ sender: UIButton) {
        currentIndex -= 1
        if(currentIndex == -1){
            currentIndex = self.scoreData.count - 1
        }
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.tableView.frame = self.tableView.frame.offsetBy(dx: self.view.frame.width, dy: 0)
        }
        animator.startAnimation()
        titleLabel.setTitle("Hole".localized() + " \(currentIndex+1) - " + "Par".localized() + " \(self.scoreData[self.currentIndex].par)", for: .normal)

        self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
        //        self.tableView.reloadData()
    }
    @IBAction func btnNextAction(_ sender: UIButton) {
        currentIndex += 1
        if(currentIndex == self.scoreData.count){
            currentIndex = 0
        }
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.tableView.frame = self.tableView.frame.offsetBy(dx: -self.view.frame.width, dy: 0)
        }
        animator.startAnimation()
        
        titleLabel.setTitle("Hole".localized() + " \(currentIndex+1) - " + "Par".localized() + " \(self.scoreData[self.currentIndex].par)", for: .normal)

        self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
        //        self.tableView.reloadData()
    }
    @IBAction func btnActionFinishRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        if(self.holeOutforAppsFlyer[self.playerIndex] != self.scoreData.count){
            let emptyAlert = UIAlertController(title: "Finish Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoreData.count) Holes. Are you sure you want to finish the Round ?", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "Finish Round", style: .default, handler: { (action: UIAlertAction!) in
                if(self.holeOutforAppsFlyer[self.playerIndex] > 8){
                    self.saveAndviewScore()
                }else{
                    self.exitWithoutSave()
                }
            }))
            emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }else{
            self.saveAndviewScore()
        }
        
    }
    
    @IBAction func btnActionRestartRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoreData.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
            if(self.playerData.count > 1){
                self.checkIfMuliplayerJoined(matchID:Constants.matchId)
            }else{
                self.resetScoreNodeForMe()
            }
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
    }
    func resetScoreNodeForMe(){
        for i in 0..<self.scoreData.count{
            let player = NSMutableDictionary()
            for j in 0..<self.playersArray.count{
                if(self.playersArray[j].id == Auth.auth().currentUser?.uid){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: self.playersArray[j].id as NSCopying)
                    ref.child("matchData/\(Constants.matchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoreData[i].players[j].addEntries(from: player as! [AnyHashable : Any])
                    self.holeOutforAppsFlyer[j] = 0
                }
            }
        }
        debugPrint(self.scoreData)
        self.tableView.reloadData()
    }
    func checkIfMuliplayerJoined(matchID:String){
        var isJoined = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(Constants.matchId)/player") { (snapshot) in
            var playerDict = NSMutableDictionary()
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            

            if(snapshot.value != nil){
                debugPrint(snapshot.value as! NSMutableDictionary)
                playerDict = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
                
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
                    self.currentIndex = 0
                }
            })
        }
    }
    @IBAction func btnActionDiscardRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Discard Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoreData.count) Holes. Are you sure you want to Discard the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Discard Round", style: .default, handler: { (action: UIAlertAction!) in
            self.exitWithoutSave()
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
        
    }
    func exitWithoutSave(){
        if(Constants.matchId.count > 1){
            self.updateFeedNode()
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            if(Constants.matchId.count > 1){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(Constants.matchId)").removeValue()
            }
            Constants.matchId.removeAll()
            Constants.isUpdateInfo = true
            self.navigationController?.popToRootViewController(animated: true)
            Constants.addPlayersArray.removeAllObjects()
            if Constants.mode>0{
                Analytics.logEvent("mode\(Constants.mode)_game_discarded", parameters: [:])
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            }
        }
        self.scoreData.removeAll()
        scoreData.removeAll()
    }
    func saveAndviewScore(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()

        let generateStats = GenerateStats()
        generateStats.matchKey = Constants.matchId
        generateStats.generateStats()

    }
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.actvtIndView.isHidden = true
        self.actvtIndView.stopAnimating()
        
        if(Constants.matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(Constants.matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        if(Auth.auth().currentUser!.uid.count>1) &&  (Constants.matchId.count > 1){
            ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
        }
        Constants.addPlayersArray = NSMutableArray()
        self.updateFeedNode()
        Constants.isUpdateInfo = true
        if Constants.mode>0{
            Analytics.logEvent("mode\(Constants.mode)_game_completed", parameters: [:])
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        if(Constants.matchId.count > 1){
            self.gotoFeedBackViewController(mID: Constants.matchId,mode:Constants.mode)
        }
    }
    func sendMatchFinishedNotification(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser?.uid ?? "user1")/friends") { (snapshot) in
            let group = DispatchGroup()
            var dataDic = [String:Bool]()
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            for data in dataDic{
                group.enter()
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(Constants.selectedGolfName).", type: "8", category: "finishedGame", matchDataId: Constants.matchId, feedKey:"")
                group.leave()
            }
            
            group.notify(queue: .main){
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
            }
        }
    }
    func updateFeedNode(){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        feedDict.setObject(Constants.matchId, forKey: "matchKey" as NSCopying)
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
            if(Constants.matchDataDic.object(forKey: "player") != nil){
                let tempArray = Constants.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    players.add(dict)
                }
            }
            viewCtrl.finalPlayersData = players
            viewCtrl.finalScoreData = self.scoreData
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            viewCtrl.fromGameImprovement = false
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.scoreData.removeAll()
            Constants.matchId.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }
}

