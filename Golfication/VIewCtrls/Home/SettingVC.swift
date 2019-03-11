//
//  SettingVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SettingVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    let kHeaderSectionTag: Int = 6900
    
    var sectionOne:[Int] = [0, 1]
    var sectionTwo:[Int] = [0, 1, 2, 3, 4]
    var sectionThree:[Int] = [0, 1]
    
    var progressView = SDLoader()
    var goalsDic = NSMutableDictionary()
    var swingGoalsDic = NSMutableDictionary()
    
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var golfBagArray = NSMutableArray()
    var clubMArray = NSMutableArray()
    //    var swingMArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Settings".localized()
        self.navigationItem.rightBarButtonItem?.title = "Logout".localized()
        
        let clubTempArr = NSMutableArray()
        clubTempArr.add("Swing Tempo")
        clubTempArr.add("Back Swing")
        for j in 0..<Constants.allClubs.count{
            for i in 0..<golfBagArray.count{
                let dic = golfBagArray[i] as! NSMutableDictionary
                if let clubName  = (dic.value(forKey: "clubName") as? String){
                    if Constants.allClubs[j] == clubName{
                        if clubName != "Pu"{
                            clubTempArr.add(clubName)
                        }
                    }
                }
            }
        }
        self.getBenchMark(clubTempArr:clubTempArr)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0)
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.checkVersion()
        self.checkFilterValuesFromFirebase()
    }
    func getBenchMark(clubTempArr:NSMutableArray){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "benchmarks/" + Constants.benchmark_Key) { (snapshot) in
            let benchMarkVal = snapshot.value as! NSMutableDictionary
            
            DispatchQueue.main.async(execute: {
                self.clubMArray = NSMutableArray()
                for i in 0..<clubTempArr.count{
                    let clubMDic = NSMutableDictionary()
                    let clubName = clubTempArr[i] as! String
                    if clubName == "Swing Tempo"{
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        clubMDic.setObject(1, forKey: "minVal" as NSCopying)
                        clubMDic.setObject(6, forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(3, forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Back Swing"{
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        clubMDic.setObject(90, forKey: "minVal" as NSCopying)
                        clubMDic.setObject(300, forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(195, forKey: "defaultVal" as NSCopying)
                    }
                    else{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: clubName) as! String)!
                        clubMDic.setObject(self.getFullClubName(clubName:clubName), forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    self.clubMArray.add(clubMDic)
                }
                self.getSwingGoalsData()
            })
        }
    }
    
    func getSwingGoalsData(){
        swingGoalsDic = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingGoals") { (snapshot) in
            if snapshot.value != nil{
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.swingGoalsDic = goalsDic
                }
            }
            else{
                debugPrint("clubMArray",self.clubMArray)
                let swingDict = NSMutableDictionary()
                
                for i in 0..<self.clubMArray.count{
                    let dic = self.clubMArray[i] as! NSMutableDictionary
                    var clubName = dic.value(forKey: "clubName") as! String
                    if clubName == "Back Swing" || clubName == "Swing Tempo"{
                        clubName = dic.value(forKey: "clubName") as! String
                    }
                    else{
                        clubName = self.getShortClubName(clubName: dic.value(forKey: "clubName") as! String)
                    }
                    let defaultVal =  dic.value(forKey: "defaultVal") as! Int
                    swingDict.setObject(defaultVal, forKey: clubName as NSCopying)
                }
                self.swingGoalsDic = swingDict
                let golfFinalDic = ["swingGoals":swingDict]
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfFinalDic)
            }
            DispatchQueue.main.async( execute: {
                debugPrint("swingGoalsDic",self.swingGoalsDic)
                self.progressView.hide(navItem: self.navigationItem)
            })
        }
    }
    func getShortClubName(clubName: String) -> String{
        var shortClubName = String()
        
        var lastChar = String()
        
        if clubName.contains(find: "Iron"){
            lastChar = String(clubName.dropLast(5))
            shortClubName = lastChar + "i"
        }
        else if clubName.contains(find: "Hybrid"){
            lastChar = String(clubName.dropLast(7))
            shortClubName = lastChar + "h"
        }
        else if clubName.contains(find: "Driver"){
            shortClubName = "Dr"
        }
        else if clubName.contains(find: "Wedge"){
            let firstChar = clubName.first!
            if firstChar == "P"{
                shortClubName = "Pw"
            }
            else if firstChar == "S"{
                shortClubName = "Sw"
            }
            else if firstChar == "G"{
                shortClubName = "Gw"
            }
            else if firstChar == "L"{
                shortClubName = "Lw"
            }
        }
        else if clubName.contains(find: "Wood"){
            lastChar = String(clubName.dropLast(5))
            shortClubName = lastChar + "w"
        }
        else if clubName.contains(find: "Putter"){
            lastChar = String(clubName.dropLast(6))
            shortClubName = lastChar + "Pu"
        }
        return shortClubName
    }
    
    func getFullClubName(clubName: String) -> String{
        var fullClubName = String()
        
        let lastChar = clubName.last!
        let firstChar = clubName.first!
        
        if lastChar == "i"{
            fullClubName = String(firstChar) + " Iron"
        }
        else if lastChar == "h"{
            fullClubName = String(firstChar) + " Hybrid"
        }
        else if lastChar == "r"{
            fullClubName = "Driver"
        }
        else if lastChar == "u"{
            fullClubName = "Putter"
        }
        else if lastChar == "w"{
            if clubName == "Pw"{
                fullClubName =  "Pitching Wedge"
            }
            else if clubName == "Sw"{
                fullClubName =  "Sand Wedge"
            }
            else if clubName == "Gw"{
                fullClubName =  "Gap Wedge"
            }
            else if clubName == "Lw"{
                fullClubName =  "Lob Wedge"
            }
            else{
                fullClubName = String(firstChar) + " Wood"
            }
        }
        return fullClubName
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.hide()
    }
    func checkVersion(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "info") { (snapshot) in
            if(snapshot.childrenCount > 0){
                if let dic = snapshot.value as? NSDictionary{
                    if let appVersion = dic["appVersion"] as? String{
                        self.versionLbl.text = "Version".localized() + " " + "\(appVersion.dropLast(8))"
                    }
                }
            }
            else{
                self.versionLbl.text = ""
            }
        }
    }
    
    func checkFilterValuesFromFirebase(){
        self.progressView.show()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var hand = 0
        if Constants.handicap != "-"{
            hand = Int(Double(Constants.handicap)!.rounded())
        }
        goalsDic = NSMutableDictionary()
        debugPrint("handicap == ",hand)
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "goals") { (snapshot) in
            if snapshot.value != nil{
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.goalsDic = goalsDic
                }
            }
            else{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "target/\(hand)") { (snapshot) in
                    if let targetDic = snapshot.value as? NSMutableDictionary{
                        self.goalsDic = targetDic
                        
                        let goalsDict = NSMutableDictionary()
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()), forKey: "birdie" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()), forKey: "fairway" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()), forKey: "gir" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "par") as! Double).rounded()), forKey: "par" as NSCopying)
                        
                        if Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "birdie" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "fairway" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "gir" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "par") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "par" as NSCopying)
                        }
                        //----------------------------------------------------------------------
                        if Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "birdie" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()) > 14{
                            goalsDict.setObject(14, forKey: "fairway" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "gir" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "par") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "par" as NSCopying)
                        }
                        self.goalsDic = goalsDict
                        let golfFinalDic = ["goals":goalsDict]
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfFinalDic)
                    }
                }
            }
            DispatchQueue.main.async( execute: {
                FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "unit") { (snapshot) in
                    if snapshot.exists(){
                        if let index = snapshot.value as? Int{
                            Constants.distanceFilter = index
                        }
                    }
                    else{
                        Constants.distanceFilter = 0
                    }
                    DispatchQueue.main.async( execute: {
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "strokesGained") { (snapshot) in
                            
                            if snapshot.exists(){
                                if let index = snapshot.value as? Int{
                                    Constants.skrokesGainedFilter = index
                                }
                            }
                            else{
                                Constants.skrokesGainedFilter = 0
                            }
                            DispatchQueue.main.async( execute: {
                                FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "notification") { (snapshot) in
                                    if snapshot.exists(){
                                        if let index = snapshot.value as? Int{
                                            Constants.onCourseNotification = index
                                        }
                                    }
                                    else{
                                        Constants.onCourseNotification = 0
                                    }
                                    DispatchQueue.main.async( execute: {
                                        self.progressView.hide()
                                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                                        
                                        self.tableView.delegate = self
                                        self.tableView.dataSource = self
                                        self.tableView.reloadData()
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: btnLogoutAction
    @IBAction func btnLogoutAction(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to Logout.".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { [weak alert] (_) in
            // Do Nothing
            debugPrint("Cancel Alert: \(alert?.title ?? "")")
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            //("Ok Alert: \(alert?.title ?? "")")
            debugPrint("ok :\(alert?.title ?? "")")
            
            if Auth.auth().currentUser != nil{
                //print("fb display name== ",Auth.auth().currentUser?.displayName ?? "")
                Constants.isDevice = Bool()
                Constants.isProMode = Bool()
                Constants.section5 = [String]()
                Constants.selectedGolfID = ""
                Constants.selectedGolfName = ""
                //profileGolfName = ""
                Constants.selectedLat = ""
                Constants.selectedLong = ""
                Constants.matchDataDic = NSMutableDictionary()
                Constants.gameType = ""
                Constants.startingHole = ""
                Constants.matchId = ""
                Constants.skrokesGainedFilter = 0
                Constants.distanceFilter = 0
                Constants.onCourseNotification = 0
                Constants.deviceGolficationX = nil
                Constants.ble = nil
                
                Constants.deviceGameType = 0
                Constants.tempGolfBagArray = NSMutableArray()
                Constants.isTagSetupModified = false
                Constants.baselineDict =  nil
                Constants.strokesGainedDict = [NSMutableDictionary]()
                Constants.isUpdateInfo = false
                Constants.isProfileUpdated = false
                Constants.clubWithMaxMin = [(name:String,max:Int,min:Int)]()
                Constants.firmwareVersion = nil
                Constants.oldFirmwareVersion = nil
                Constants.canSkip = nil
                Constants.gender = ""
                Constants.handed = ""
                Constants.handicap = ""
                Constants.trial = false
                Constants.tagClubNumber = [(tag:Int ,club:Int,clubName:String)]()
                Constants.syncdArray = NSMutableArray()
                Constants.tagClubNum = [(tag:Int, club: Int, clubName: String)]()
                Constants.back9 = false
                Constants.macAddress = nil
                Constants.ResponseData = nil
                Constants.charctersticsGlobalForWrite = nil
                Constants.charctersticsGlobalForRead = nil
                Constants.allMacAdrsDic = NSMutableDictionary()
                Constants.OADFeedback = false
                Constants.bleObserver = 0
                Constants.fileName = String()
                Constants.swingSessionKey = String()
                Constants.fromStatsPost = false
                Constants.benchmark_Key = String()
                self.signOutCurrentUser()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func signOutCurrentUser() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        FBSDKLoginManager().logOut()
        let firebaseAuth = Auth.auth()
        do {
            //try! Auth.auth().signOut()
            try firebaseAuth.signOut()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            var navCtrl = self.navigationController!
            self.progressView.hide()
            let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthParentVC") as! AuthParentVC
            navCtrl = UINavigationController(rootViewController: viewCtrl)
            self.present(navCtrl, animated: false, completion: nil)
        }
            
        catch let signOutError as NSError {
            
            let alert = UIAlertController(title: "Alert", message: signOutError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table View Delegate And DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = nil
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 || section == 4{
            if (self.expandedSectionHeaderNumber == section) {
                if section == 3{
                    return 4
                }
                else{
                    return clubMArray.count
                }
            }
            else {
                return 0
            }
        }
        else{
            if section == 0{
                return 2
            }
            else if section == 1{
                return 5
            }
            else if section == 2{
                return 2
            }
            else{
                return 4
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3{
            return CGFloat(110.0)
        }
        if indexPath.section == 4{
            if indexPath.row == 2{
                return CGFloat(125.0)
            }
            else{
                return CGFloat(100.0)
            }
        }
        else{
            return CGFloat(44.0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.10)
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: 270, height: 35.0)
        
        if section == 0{
            label.text =  "Distance".localized()
        }
        else if section == 1{
            label.text =  "Strokes Gained".localized()
        }
        else if section == 2{
            label.text = "Rangefinder Distance Notification"
        }
        else if section == 3{
            label.text = "Game Goals"
            
            if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                viewWithTag.removeFromSuperview()
            }
            let headerFrame = self.tableView.frame.size
            
            let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 7, width: 18, height: 18))
            theImageView.image = UIImage(named: "Chevron-Dn-Wht")
            theImageView.tag = kHeaderSectionTag + section
            
            header.addSubview(theImageView)
            
            header.tag = section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
            header.addGestureRecognizer(headerTapGesture)
        }
        else{
            label.frame = CGRect(x: 10, y: (35.0/2)-8, width: 270, height: 35.0)
            label.text = "Swing Goals"
            label.sizeToFit()
            
            if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                viewWithTag.removeFromSuperview()
            }
            let headerFrame = self.tableView.frame.size
            
            let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 7, width: 18, height: 18))
            theImageView.image = UIImage(named: "Chevron-Dn-Wht")
            theImageView.tag = kHeaderSectionTag + section
            
            header.addSubview(theImageView)
            
            header.tag = section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
            header.addGestureRecognizer(headerTapGesture)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let btnInfo = UIButton()
            btnInfo.frame = CGRect(x:label.frame.origin.x+label.frame.size.width+10, y:7, width:25, height:25)
            btnInfo.setBackgroundImage(infoBtnImage, for: .normal)
            btnInfo.tintColor = UIColor.glfFlatBlue
            btnInfo.addTarget(self, action: #selector(self.headerInfoClicked(_:)), for: .touchUpInside)
            header.addSubview(btnInfo)
        }
        label.textColor = UIColor.black
        header.addSubview(label)
        return header
    }
    
    @objc func headerInfoClicked(_ sender: UIButton){
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
        viewCtrl.title = "Clubhead Speed"
        viewCtrl.desc = StatsIntoConstants.clubheadSpeed
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! SettingCell
        
        cell.lblGoal.isHidden = true
        cell.goalStackView.isHidden = true
        cell.btnGoalInfo.isHidden = true
        cell.lblClubHead.isHidden = true
        if indexPath.section == 0{
            if Constants.distanceFilter == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else
            {
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
            case 0: cell.textLabel?.text = "Imperial (feet,yards,miles)".localized()
            case 1: cell.textLabel?.text = "Metric(metres,kilometres)".localized()
                
            default: break
            }
        }
        else if indexPath.section == 1{
            if Constants.skrokesGainedFilter == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else
            {
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
            case 0: cell.textLabel?.text = "PGA Tour".localized()
            case 1: cell.textLabel?.text = "Men's - Scratch".localized()
            case 2: cell.textLabel?.text = "Men's - 18 Handicap".localized()
            case 3: cell.textLabel?.text = "Women's - Scratch".localized()
            case 4: cell.textLabel?.text = "Women's - 18 Handicap".localized()
            default: break
            }
        }
        else if indexPath.section == 2{
            if Constants.onCourseNotification == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }else{
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
            case 0: cell.textLabel?.text = "Off - Less battery consumption"
            case 1: cell.textLabel?.text = "On - More battery consumption"
            default: break
            }
        }
        else if indexPath.section == 3{
            cell.goalStackView.isHidden = false
            cell.lblGoal.isHidden = false
            cell.btnGoalInfo.isHidden = false
            cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
            
            cell.isSelected = false
            cell.tintColor = UIColor.clear
            cell.accessoryType = cell.isSelected ? .none : .none
            
            cell.textLabel?.text = ""
            cell.lblMinGoal.text = "1"
            cell.lblMaxGoal.text = "18"
            cell.goalSlider.minimumValue = 1
            cell.goalSlider.maximumValue = 18
            
            cell.goalSlider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
            cell.goalSlider.tag = indexPath.row
            cell.lblGoalVal.tag = indexPath.row
            
            switch indexPath.row{
            case 0: cell.lblGoal.text = "PAR"
            cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "par") as! Double).rounded()))
            cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "par") as! Double).rounded()))"
                
            case 1: cell.lblGoal.text = "BIRDIE"
            cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "birdie") as! Double).rounded()))
            cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "birdie") as! Double).rounded()))"
                
            case 2: cell.lblGoal.text = "FAIRWAY HIT"
            cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "fairway") as! Double).rounded()))
            cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "fairway") as! Double).rounded()))"
                
            case 3: cell.lblGoal.text = "GIR"
            cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "gir") as! Double).rounded()))
            cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "gir") as! Double).rounded()))"
            
            cell.lblMaxGoal.text = "14"
            cell.goalSlider.maximumValue = 14
                
            default: break
            }
            cell.btnGoalInfo.tag = indexPath.row
            cell.btnGoalInfo.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
        }
        else{
            cell.goalStackView.isHidden = false
            cell.lblGoal.isHidden = false
            cell.btnGoalInfo.isHidden = true
            if indexPath.row == 0 || indexPath.row == 1{
                cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
            }
            else{
                cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 15.0)
            }
            
            if indexPath.row == 2{
                cell.lblClubHead.isHidden = false
            }
            else{
                cell.lblClubHead.isHidden = true
            }
            
            cell.isSelected = false
            cell.tintColor = UIColor.clear
            cell.accessoryType = cell.isSelected ? .none : .none
            
            cell.textLabel?.text = ""
            
            let clubDic = clubMArray[indexPath.row] as! NSDictionary
            cell.lblGoal.text = (clubDic.value(forKey: "clubName") as! String)
            
            cell.lblMinGoal.text = "\(clubDic.value(forKey: "minVal") as! Int)"
            cell.lblMaxGoal.text = "\(clubDic.value(forKey: "maxVal") as! Int)"
            cell.goalSlider.minimumValue = Float((clubDic.value(forKey: "minVal") as! Int))
            cell.goalSlider.maximumValue = Float((clubDic.value(forKey: "maxVal") as! Int))
            
            cell.goalSlider.value = Float(Int((clubDic.value(forKey: "defaultVal") as! Int)))
            cell.lblGoalVal.text = "\(Int((clubDic.value(forKey: "defaultVal") as! Int)))"
            
            cell.goalSlider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
            cell.goalSlider.tag = (indexPath.section*100)+indexPath.row
            cell.lblGoalVal.tag = (indexPath.section*100)+indexPath.row
            
            cell.btnGoalInfo.tag = (indexPath.section*100)+indexPath.row
            cell.btnGoalInfo.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    // MARK: - infoClicked
    @objc func infoClicked(_ sender:UIButton){
        let section = sender.tag/100
        //        let row = sender.tag%100
        
        if section == 0{
            var title = String()
            var desc = String()
            
            if sender.tag == 0{
                title = "PAR"
                desc = StatsIntoConstants.parAverage
            }
            else if sender.tag == 1{
                title = "BIRDIE"
                desc = "Birdie"
            }
            else if sender.tag == 2{
                title = "FAIRWAY HIT"
                desc = StatsIntoConstants.fairwayHitTrend
            }
            else{
                title = "GIR"
                desc = StatsIntoConstants.GIR
            }
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = (title as String)
            viewCtrl.desc = desc
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else{
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = "Clubhead Speed"
            viewCtrl.desc = StatsIntoConstants.clubheadSpeed
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let section = sender.tag/100
        let row = sender.tag%100
        
        if section == 0{
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 3))  as! SettingCell
            cell.lblGoalVal.text = "\(Int((cell.goalSlider.value).rounded()))"
            
            let updatedValue  = Int((cell.goalSlider.value).rounded())
            if sender.tag == 0{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["par":updatedValue])
            }
            else if sender.tag == 1{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["birdie":updatedValue])
            }
            else if sender.tag == 2{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["fairway":updatedValue])
            }
            else{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["gir":updatedValue])
            }
        }
        else{
            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 4))  as! SettingCell
            cell.lblGoalVal.text = "\(Int((cell.goalSlider.value).rounded()))"
            
            let clubDic = clubMArray[row] as! NSDictionary
            var clubName = clubDic.value(forKey: "clubName") as! String
            let defaultVal  = Int((cell.goalSlider.value).rounded())
            
            if clubName == "Back Swing" || clubName == "Swing Tempo"{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues([clubName:defaultVal])
            }
            else{
                clubName  = getShortClubName(clubName: clubDic.value(forKey: "clubName") as! String)
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues([clubName:defaultVal])
            }
            for i in 0..<clubMArray.count{
                let dic = clubMArray[i] as! NSDictionary
                if dic.value(forKey: "clubName") as! String == clubDic.value(forKey: "clubName") as! String{
                    let clubDic = NSMutableDictionary()
                    clubDic.setObject(dic.value(forKey: "clubName") as! String, forKey: "clubName" as NSCopying)
                    clubDic.setObject(dic.value(forKey: "minVal")!, forKey: "minVal" as NSCopying)
                    clubDic.setObject(dic.value(forKey: "maxVal")!, forKey: "maxVal" as NSCopying)
                    clubDic.setObject(defaultVal, forKey: "defaultVal" as NSCopying)
                    
                    clubMArray.replaceObject(at: i, with: clubDic)
                    break
                }
            }
            debugPrint("clubMArray",clubMArray)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)!
        cell.tintColor = UIColor.glfGreen
        
        if indexPath.section == 0{
            if !sectionOne.isEmpty{
                for i in 0..<sectionOne.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionOne.count{
                    if sectionOne[i] == indexPath.row{
                        tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.distanceFilter = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["unit" :Constants.distanceFilter] as [AnyHashable:Any])
        }
        else if indexPath.section == 1{
            if !sectionTwo.isEmpty{
                for i in 0..<sectionTwo.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionTwo.count{
                    if sectionTwo[i] == indexPath.row{
                        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.skrokesGainedFilter = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["strokesGained" :Constants.skrokesGainedFilter] as [AnyHashable:Any])
        }
        else if indexPath.section == 2{
            if !sectionThree.isEmpty{
                for i in 0..<sectionThree.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionThree.count{
                    if sectionThree[i] == indexPath.row{
                        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.onCourseNotification = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["notification" :Constants.onCourseNotification] as [AnyHashable:Any])
        }
        else{
            // DO nothing
        }
    }
    
    // MARK: - Expand / Collapse Methods
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer){
        
        let headerView = sender.view!
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            getUpDatedGoalsValues(section:section, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            }
            else {
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                getUpDatedGoalsValues(section:section, imageView: eImageView!)
            }
        }
    }
    func getUpDatedGoalsValues(section:Int, imageView: UIImageView){
        self.goalsDic = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "goals") { (snapshot) in
            if snapshot.value != nil{
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.goalsDic = goalsDic
                }
            }
            DispatchQueue.main.async( execute: {
                self.tableViewExpandSection(section, imageView: imageView)
            })
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        
        self.expandedSectionHeaderNumber = -1
        var indexesPath = [IndexPath]()
        if section == 3{
            for i in 0 ..< 4 {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        else{
            for i in 0 ..< clubMArray.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        self.tableView!.beginUpdates()
        self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
        self.tableView!.endUpdates()
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        var indexesPath = [IndexPath]()
        if section == 3{
            for i in 0 ..< 4 {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        else{
            for i in 0 ..< clubMArray.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        self.expandedSectionHeaderNumber = section
        self.tableView!.beginUpdates()
        self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
        self.tableView!.endUpdates()
    }
}
