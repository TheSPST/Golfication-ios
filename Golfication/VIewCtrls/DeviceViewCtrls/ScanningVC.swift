//
//  ScanningVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 13/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FirebaseAuth

class ScanningVC: UIViewController, BluetoothDelegate {
    
    @IBOutlet weak var btnBuyNow: UIButton!

    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var lblWaitingForSwing: UILabel!
    @IBOutlet weak var lblStartSwinging: UILabel!
    @IBOutlet weak var barBtnBLE: UIBarButtonItem!
    @IBOutlet weak var viewHaveDevice: UIView!
    
    @IBOutlet weak var noDeviceSV: UIStackView!
    @IBOutlet weak var startSwingingSV: UIStackView!

    @IBOutlet weak var swingProgressView: UIProgressView!
    var progressView = SDLoader()
    var tempTimer: Timer!
    var currentGameId = Int()
    var activeMatchId = String()
    var swingMatchId = String()
    var fromSetup = false
    var swingDetails = [(shotNo:Int,bs:Double,ds:Double,hv:Double,cv:Double,ba:Double,tempo:Double,club:String,time:Int64,hole:Int)]()
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    var isDeviceSetup = false
    var progressValue = 0.0
    var deviceCircularView: CircularProgress!
    var golfXPopupView: UIView!
    var btnRetry: UIButton!
    var btnNoDevice: UIButton!
    var lblScanStatus: UILabel!
    var timeOutTimer = Timer()

    @IBAction func barBtnBLEAction(_ sender: Any) {
        if (self.barBtnBLE.image == #imageLiteral(resourceName: "golficationBarG")) && (Constants.macAddress != nil){
            self.getSwingData()
        }else{
           self.getGolfBagUpdate()
        }
    }
    func getGolfBagUpdate(){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            var golfBagArray = NSMutableArray()
            var selectedClubs = NSMutableArray()
            if let glfbag = snapshot.value as? NSMutableArray{
                golfBagArray = glfbag
                for i in 0..<golfBagArray.count{
                    if let dict = golfBagArray[i] as? NSDictionary{
                        selectedClubs.add(dict)
                        for data in Constants.clubWithMaxMin where data.name == dict.value(forKey: "clubName") as! String{
                            if (data.name).contains("Pu"){
                                dict.setValue(30, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":30])
                            }else if(dict.value(forKey: "avgDistance") == nil){
                                let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                dict.setValue(avgDistance, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":avgDistance])
                            }
                            
                        }
                    }
                    else{
                        let tempArray = snapshot.value as! NSMutableArray
                        var golfBagData = [String: NSMutableArray]()
                        for i in 0..<tempArray.count{
                            let golfBagDict = NSMutableDictionary()
                            golfBagDict.setObject("", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(tempArray[i], forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                            for data in Constants.clubWithMaxMin where data.name == tempArray[i] as! String{
                                if (data.name).contains("Pu"){
                                    golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                                }else{
                                    let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                    golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                                }
                            }
                            golfBagArray.replaceObject(at: i, with: golfBagDict)
                            golfBagData = ["golfBag": golfBagArray]
                            
                            selectedClubs.add(golfBagDict)
                        }
                        if golfBagData.count>0{
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                        }
                        break
                    }
                }
            }
            else{
                let golfBagArray = NSMutableArray()
                golfBagArray.addObjects(from: ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"])
                var golfBagData = [String: NSMutableArray]()
                selectedClubs = NSMutableArray()
                let tempArray = NSMutableArray()
                
                for i in 0..<golfBagArray.count{
                    let golfBagDict = NSMutableDictionary()
                    golfBagDict.setObject("", forKey: "brand" as NSCopying)
                    golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                    golfBagDict.setObject(golfBagArray[i], forKey: "clubName" as NSCopying)
                    golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                    golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                    for data in Constants.clubWithMaxMin where data.name == golfBagArray[i] as! String{
                        if (data.name).contains("Pu"){
                            golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                        }else{
                            let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                            golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                        }
                    }
                    tempArray.insert(golfBagDict, at: i)
                    golfBagData = ["golfBag": tempArray]
                    
                    selectedClubs.add(golfBagDict)
                }
                if golfBagData.count>0{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                Constants.tempGolfBagArray = NSMutableArray()
                Constants.tempGolfBagArray = NSMutableArray(array: golfBagArray)
                let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
                debugPrint("golfBagArray.count:",golfBagArray.count)
                viewCtrl.golfBagArr = golfBagArray
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showShotsAfterSwing(_:)), name: NSNotification.Name(rawValue: "getSwing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noSetup(_:)), name: NSNotification.Name(rawValue: "noSetup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.takeSwing(_:)), name: NSNotification.Name(rawValue: "readyToTakeSwing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: "DeviceConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.discardGame(_:)), name: NSNotification.Name(rawValue: "DiscardCancel"), object: nil)
        
        setInitialUI()
        
        if Constants.isDevice{
            viewHaveDevice.isHidden = true
            noDeviceSV.isHidden = true
            self.getSwingData()
//            sharedInstance = BluetoothSync.getInstance()
//            sharedInstance.delegate = self
//            sharedInstance.initCBCentralManager()
        }
        else{
            viewHaveDevice.isHidden = true
            noDeviceSV.isHidden = false
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "DiscardCancel"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
    }
    var sharedInstance: BluetoothSync!

    @IBAction func btnACtionBuyNow(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.title = ""
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
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
            
//            sharedInstance.delegate = nil
            return
            
        case .unsupported:
            alert = "This device is unsupported."
            break
        default:
            alert = "Try again after restarting the device."
            break
        }
        if Constants.ble == nil{
            Constants.ble = BLE()
        }
        Constants.ble.stopScanning()
        
        self.timeOutTimer.invalidate()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "Scanning_Time_Out"))

        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            self.sharedInstance.delegate = nil
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showPopUp(){
        self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)

        NotificationCenter.default.addObserver(self, selector: #selector(self.SeventyFivePercentUpdated(_:)), name: NSNotification.Name(rawValue: "75_Percent_Updated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScreen(_:)), name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ScanningTimeOut(_:)), name: NSNotification.Name(rawValue: "Scanning_Time_Out"), object: nil)
        
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.golfXPopupView = (Bundle.main.loadNibNamed("ScanningGolfX", owner: self, options: nil)![0] as! UIView)
        self.golfXPopupView.frame = self.view.bounds
        self.view.addSubview(self.golfXPopupView)
        setGofXUISetup()
    }
    @objc func timerAction() {
        self.timeOutTimer.invalidate()
        self.noDeviceAvailable()
    }
    func setGofXUISetup(){
        btnNoDevice = (golfXPopupView.viewWithTag(111) as! UIButton)
        btnNoDevice.layer.cornerRadius = btnNoDevice.frame.size.height/2
        
        btnRetry = (golfXPopupView.viewWithTag(222) as! UIButton)
        btnRetry.addTarget(self, action: #selector(self.retryAction(_:)), for: .touchUpInside)
        btnRetry.layer.cornerRadius = 3.0
        
        let btnCancel = (golfXPopupView.viewWithTag(333) as! UIButton)
        btnCancel.addTarget(self, action: #selector(self.cancelGolfXAction(_:)), for: .touchUpInside)
        deviceCircularView = (golfXPopupView.viewWithTag(444) as! CircularProgress)
        deviceCircularView.progressColor = UIColor.glfBluegreen
        deviceCircularView.trackColor = UIColor.clear
        deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        deviceCircularView.progressLayer.lineWidth = 3.0
        
        lblScanStatus = (golfXPopupView.viewWithTag(555) as! UILabel)
        DispatchQueue.main.async {
            self.lblScanStatus.text = "Scanning for Golfication X..."
            self.btnRetry.isHidden = true
            self.btnNoDevice.isHidden = true
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.0, toValue: 0.50)
        }
    }
    @objc func cancelGolfXAction(_ sender: UIButton!) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        golfXPopupView.removeFromSuperview()
    }
    @objc func SeventyFivePercentUpdated(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)

        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.50, toValue: 0.75)
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        })
    }
    @objc func discardGame(_ notification: NSNotification){
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "DiscardCancel"))
    }
    @objc func updateScreen(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.75, toValue: 0.90)
            self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
        })
    }
    
    @objc func ScanningTimeOut(_ notification: NSNotification){
        DispatchQueue.main.async(execute: {
           self.noDeviceAvailable()
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "Scanning_Time_Out"))
        })
    }
    
    func noDeviceAvailable() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.lblScanStatus.text = "Couldn't find your device"
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.btnRetry.isHidden = false
        self.btnNoDevice.isHidden = false
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        if Constants.ble != nil{
            Constants.ble.stopScanning()
        }
    }
    
    @objc func animateProgress() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        Constants.ble.stopScanning()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        Constants.deviceGameType = 2
        Constants.ble.sendThirdCommand()
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    var totalPracticeSession = 1
    func getSwingData() {
        var swingMArray = NSMutableArray()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession") { (snapshot) in
            var dataDic = [String:Bool]()
            if(snapshot.value != nil){
                if let dataDi = snapshot.value as? [String:Bool]{
                    dataDic = dataDi
//                    self.totalPracticeSession = dataDi.count+1
//                    self.title = "Practice Session \(dataDi.count+1)"
                }
            }
            DispatchQueue.main.async(execute: {
                    let group = DispatchGroup()
                    if(dataDic.count == 0){
                        self.progressView.hide(navItem: self.navigationItem)
                    }
                    for (key, value) in dataDic{
                        group.enter()
                        if (value){
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                                if(snapshot.value != nil){
                                    if let data = snapshot.value as? NSDictionary{
                                        let timestamp = data.value(forKey: "timestamp") as? Int64
                                        if(timestamp != nil){
                                            let timeStart = Date(timeIntervalSince1970: (TimeInterval(timestamp!/1000)))
                                            let timeEnd = Calendar.current.date(byAdding: .second, value: 10*60*60, to: timeStart as Date)
                                            let timeNow = Date()
                                            if(timeNow > timeEnd!){
                                                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([key:false])
                                            }
                                        }
                                        self.currentGameId = data.value(forKey: "gameId") as! Int
                                        self.swingMatchId = key
                                        if let swings = data.value(forKey: "swings") as? NSMutableArray{
                                            for swing in swings{
                                                if let swin = swing as? NSMutableDictionary{
                                                    let shot = swin.value(forKey: "shotNum") as! Int
                                                    let bs = swin.value(forKey: "backSwing") as! Double
                                                    let ds = swin.value(forKey: "downSwing") as! Double
                                                    let hv = swin.value(forKey: "handSpeed") as! Double
                                                    let cv = swin.value(forKey: "clubSpeed") as! Double
                                                    let ba = swin.value(forKey: "backSwingAngle") as! Double
                                                    let tempo = swin.value(forKey: "tempo") as! Double
                                                    let club = swin.value(forKey: "club") as! String
                                                    let time = swin.value(forKey: "timestamp") as! Int64
                                                    self.swingDetails.append((shotNo: shot, bs: bs, ds: ds, hv: hv, cv: cv, ba: ba, tempo: tempo, club: club, time: time,hole:0))
                                                }
                                            }
                                        }
                                        if let playType = data.value(forKey: "playType") as? String{
                                            if(playType != "match") && self.swingDetails.count != 0{
                                                swingMArray.add(data)
                                            }else if playType == "match"{
                                                self.currentGameId = 0
                                                self.fromSetup = true
                                            }
                                        }
                                    }
                                }
                                group.leave()
                            }
                        }
                        else{
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)/playType") { (snapshot) in
                                if let data = snapshot.value as? String{
                                    if data.contains(find: "practice"){
                                        self.totalPracticeSession += 1
                                    }
                                }
                                
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main, execute: {
                        self.progressView.hide(navItem: self.navigationItem)
                        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                        let array: NSArray = swingMArray.sortedArray(using: [sortDescriptor]) as NSArray
                        swingMArray.removeAllObjects()
                        swingMArray = NSMutableArray()
                        swingMArray = array.mutableCopy() as! NSMutableArray
                        debugPrint(swingMArray)
                        if swingMArray.count > 0{
                            let dict = NSMutableDictionary()
                            dict.addEntries(from: ["id" : self.swingMatchId])
                            dict.addEntries(from: ["gameId":self.currentGameId])
                            
                            if Constants.ble == nil{
                                Constants.ble = BLE()
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getSwing"), object: dict)
                            }
                        }else{
                            if Constants.ble == nil{
                                Constants.ble = BLE()
                            }
                        }
                        Constants.ble.startScanning()
                        Constants.ble.isSetupScreen = !self.fromSetup
                        Constants.ble.isDeviceSetup = false
                        Constants.ble.swingMatchId = self.swingMatchId
                        Constants.ble.currentGameId = self.currentGameId
                        Constants.deviceGameType = 2
//                        if self.isFromViewWillApp{
//                            self.isFromViewWillApp = false
//                        }else{
                            self.showPopUp()
//                        }
//                        self.title = "Practice Sessions \(self.totalPracticeSession)"
                    })
                })
                
            }
        }
    @objc func noSetup(_ notification:NSNotification){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func reloadData(_ notification:NSNotification){
        DispatchQueue.main.async {
            self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "DeviceConnected"))
    }

    @objc func takeSwing(_ notification:NSNotification){
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.3, fromValue: 0.90, toValue: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
            self.noDeviceSV.isHidden = true
            self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
            self.golfXPopupView.removeFromSuperview()
            self.startSwingingSV.isHidden = false
            self.viewHaveDevice.isHidden = false
            self.title = "Practice Sessions \(self.totalPracticeSession)"
        })
//        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "readyToTakeSwing"))
    }
    
    @objc func showShotsAfterSwing(_ notification:NSNotification){
        if let dict = notification.object as? NSMutableDictionary{
//            Constants.ble.playSound()
            self.currentGameId = dict.value(forKey: "gameId") as! Int
            let swingKey = dict.value(forKey: "id") as! String
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/") { (snapshot) in
                
                if self.deviceCircularView != nil{
                    self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.0, toValue: 1.0)
                }
                var dict = NSMutableDictionary()
                if let diction = snapshot.value as? NSMutableDictionary{
                    dict = diction
                }
                DispatchQueue.main.async(execute: {
                    if let swingArr = dict.value(forKey: "swings") as? NSArray{
//                        debugPrint("Diction:\(swingArr)")
                        self.lblWaitingForSwing.text = "Fetching Swing details...."
                        self.lblStartSwinging.text = "Swing Detected"
                        self.perform(#selector(self.updateProgress), with: nil, afterDelay: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            if self.deviceCircularView != nil{
                                self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
                                self.deviceCircularView.removeFromSuperview()
                            }
                            let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "PracticePageContainerVC") as! PracticePageContainerVC
                            viewCtrl.swingKey = swingKey
                            viewCtrl.count = self.totalPracticeSession
                            var shotsAr = [String]()
                            for i in 0..<swingArr.count{
                                shotsAr.append("Shot \(i+1)")
                            }
                            viewCtrl.shotsArray = shotsAr
                            viewCtrl.tempArray1 = swingArr
                            viewCtrl.currentGameId = self.currentGameId
                            viewCtrl.swingId = self.swingMatchId
                            self.navigationController?.pushViewController(viewCtrl, animated: true)
                        })
                    }else{
                        self.viewHaveDevice.isHidden = false
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "readyToTakeSwing"), object: nil)
                        
                    }
                })
            }
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "getSwing"))
    }
    
    func setInitialUI(){
        //btnNoDevice.layer.cornerRadius = btnNoDevice.frame.size.height/2
        btnBuyNow.layer.cornerRadius = 3.0
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        self.barBtnBLE.isEnabled = true
        btnConnect.layer.cornerRadius = 3.0
    }

    @objc func updateProgress() {
        progressValue = progressValue + 0.1
        self.swingProgressView.progress = Float(progressValue)
        if progressValue != 2.0 {
            self.perform(#selector(updateProgress), with: nil, afterDelay: 0.1)
        }
    }
//    var isFromViewWillApp = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func retryAction(_ sender: UIButton) {
        viewHaveDevice.isHidden = false
        noDeviceSV.isHidden = true

        if Constants.ble == nil{
            Constants.ble = BLE()
        }
        Constants.ble.isSetupScreen = !self.fromSetup
        Constants.ble.startScanning()
        self.golfXPopupView.removeFromSuperview()
        showPopUp()
        startSwingingSV.isHidden = true
    }
}
