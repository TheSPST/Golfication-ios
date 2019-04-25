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

class SettingVC: UIViewController , UITableViewDelegate, UITableViewDataSource,BluetoothDelegate{
    var sharedInstance: BluetoothSync!
    let kHeaderSectionTag: Int = 6900
    var sectionOne:[Int] = [0, 1]
    var sectionTwo:[Int] = [0, 1, 2, 3, 4]
//    var sectionThree:[Int] = [0, 1]
    var progressView = SDLoader()
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var golfBagArray = NSMutableArray()
    /*
     FBSomeEvents.shared.singleParamFBEvene(param: "Set Goals")
     
     Set Swing Goals
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Settings".localized()
        self.navigationItem.rightBarButtonItem?.title = "Logout".localized()
        
        self.tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0)
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.checkVersion()
        self.checkFilterValuesFromFirebase()
        FBSomeEvents.shared.singleParamFBEvene(param: "View Settings")
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
//        var hand = 0
//        if Constants.handicap != "-"{
//            hand = Int(Double(Constants.handicap)!.rounded())
//        }
        
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
    }
    
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: btnLogoutAction
    @IBAction func btnLogoutAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Logout")
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to Logout?".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { [weak alert] (_) in
            // Do Nothing
            debugPrint("Cancel Alert: \(alert?.title ?? "")")
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            //("Ok Alert: \(alert?.title ?? "")")
            debugPrint("ok :\(alert?.title ?? "")")
            
            if Auth.auth().currentUser != nil{
                BackgroundMapStats.deleteCoreData()
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
        if Constants.isDevice && Constants.isProMode{
            return 6
        }
        else if !Constants.isDevice && Constants.isProMode{
            return 5
        }
        else if Constants.isDevice && !Constants.isProMode{
            return 4
        }
        else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 2
        }
        else if section == 1{
            return 5
        }
//        else if section == 2{
//            return 2
//        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2{
            return 0
        }
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44.0)
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
            label.text = ""
            header.backgroundColor = UIColor.clear
            label.isHidden = true
        }
        else if section == 3{
            if Constants.isDevice && Constants.isProMode{
                
                label.text = "Scoring Goals"
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                let btnInfo = UIButton(frame: CGRect(x: 0, y: 0, width: headerFrame.width, height: 35))
                btnInfo.backgroundColor = UIColor.clear
                btnInfo.tag = section
                btnInfo.addTarget(self, action: #selector(self.scoringGoalWasTouched(_:)), for: .touchUpInside)
                header.addSubview(btnInfo)
                
            }
            else if !Constants.isDevice && Constants.isProMode{
                label.text = "Scoring Goals"
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                let btnInfo = UIButton(frame: CGRect(x: 0, y: 0, width: headerFrame.width, height: 35))
                btnInfo.backgroundColor = UIColor.clear
                btnInfo.tag = section
                btnInfo.addTarget(self, action: #selector(self.scoringGoalWasTouched(_:)), for: .touchUpInside)
                header.addSubview(btnInfo)
            }
            else if Constants.isDevice && !Constants.isProMode{
                label.frame = CGRect(x: 10, y: (35.0/2)-8, width: 270, height: 35.0)
                label.text = "Debug Golfication X"
                label.sizeToFit()
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                header.tag = section
                let headerTapGesture = UITapGestureRecognizer()
                headerTapGesture.addTarget(self, action: #selector(self.debugModeWasTouched(_:)))
                header.addGestureRecognizer(headerTapGesture)
            }
        }
        else if section == 4{
            if Constants.isDevice && Constants.isProMode{
                label.text = "Swing Goals"
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                let btnInfo = UIButton(frame: CGRect(x: 0, y: 0, width: headerFrame.width, height: 35))
                btnInfo.backgroundColor = UIColor.clear
                btnInfo.tag = section
                btnInfo.addTarget(self, action: #selector(self.scoringGoalWasTouched(_:)), for: .touchUpInside)
                header.addSubview(btnInfo)
            }
            else if !Constants.isDevice && Constants.isProMode{
                label.text = "Swing Goals"
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                let btnInfo = UIButton(frame: CGRect(x: 0, y: 0, width: headerFrame.width, height: 35))
                btnInfo.backgroundColor = UIColor.clear
                btnInfo.tag = section
                btnInfo.addTarget(self, action: #selector(self.scoringGoalWasTouched(_:)), for: .touchUpInside)
                header.addSubview(btnInfo)
            }
        }
        else{
            if Constants.isDevice && Constants.isProMode{
                label.frame = CGRect(x: 10, y: (35.0/2)-8, width: 270, height: 35.0)
                label.text = "Debug Golfication X"
                label.sizeToFit()
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.tableView.frame.size
                
                let arrowImage = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 5, width: 25, height: 25))
                arrowImage.image = UIImage(named: "forwardArrow")
                header.addSubview(arrowImage)
                
                header.tag = section
                let headerTapGesture = UITapGestureRecognizer()
                headerTapGesture.addTarget(self, action: #selector(self.debugModeWasTouched(_:)))
                header.addGestureRecognizer(headerTapGesture)
            }
        }
        label.textColor = UIColor.black
        header.addSubview(label)
        return header
    }
    
    @objc func scoringGoalWasTouched(_ sender: UIButton){
        
        var titleStr = String()
        if sender.tag == 3{
            titleStr = "Scoring Goals"
            FBSomeEvents.shared.singleParamFBEvene(param: "Click Goals")
        }
        else{
            titleStr = "Swing Goals"
            FBSomeEvents.shared.singleParamFBEvene(param: "Click Swing Goals")
        }
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "GoalsVC") as! GoalsVC
        viewCtrl.golfBagArray = self.golfBagArray
        viewCtrl.titleStr = titleStr
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @objc func debugModeWasTouched(_ sender: UITapGestureRecognizer){
        let alertVC = UIAlertController(title: "Debug", message: "Connect your Golfication X to start the Debug mode.".localized(), preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Connect", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.sharedInstance = BluetoothSync.getInstance()
            self.sharedInstance.delegate = self
            self.sharedInstance.initCBCentralManager()
            NotificationCenter.default.addObserver(self, selector: #selector(self.debugSettingPress(_:)), name: NSNotification.Name(rawValue: "debugSetting"), object: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(action)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    func didUpdateState(_ state: CBManagerState) {
        debugPrint("state== ",state)
        var alert = String()
        switch state {
        case .poweredOff:
            alert = "Make sure that your bluetooth is turned on."
            break
        case .poweredOn:
            debugPrint("State : Powered On")
            if Constants.macAddress != nil{
                sharedInstance.delegate = nil
                if Constants.ble == nil || Constants.deviceGolficationX == nil{
                    Constants.ble = BLE()
                    Constants.ble.startScanning()
                }else{
                    Constants.ble.sendEleventhCommand()
                }
            }else{
                let alertVC = UIAlertController(title: "Alert", message: "Please finish the device setup first.", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                    self.navigationController?.pop()
                })
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            }
            return
        case .unsupported:
            alert = "This device is unsupported."
            break
        default:
            alert = "Try again after restarting the device."
            break
        }
        
        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.progressView.hide(navItem: self.navigationItem)
            self.sharedInstance.delegate = nil
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    @objc func debugSettingPress(_ notification:NSNotification){
        DispatchQueue.main.async( execute: {
            self.progressView.hide(navItem: self.navigationItem)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "debugSetting"), object: nil)
            let viewCtrl = UIStoryboard(name: "Device", bundle: nil).instantiateViewController(withIdentifier: "debugModeVC") as! DebugModeVC
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        })
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
        return cell
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
            FBSomeEvents.shared.singleParamFBEvene(param: "Settings Set Units")
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
            FBSomeEvents.shared.singleParamFBEvene(param: "Settings Set Strokes Gained")
            Constants.skrokesGainedFilter = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["strokesGained" :Constants.skrokesGainedFilter] as [AnyHashable:Any])
        }
//        else if indexPath.section == 2{
////            if !sectionThree.isEmpty{
////                for i in 0..<sectionThree.count{
////                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
////                }
////                for i in 0..<sectionThree.count{
////                    if sectionThree[i] == indexPath.row{
////                        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
////                        break
////                    }
////                }
////            }
////            Constants.onCourseNotification = indexPath.row
////            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["notification" :Constants.onCourseNotification] as [AnyHashable:Any])
//        }
//        else{
//            // DO nothing
//        }
    }
}
