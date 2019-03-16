//
//  BluetootheConnectionTesting.swift
//  Golfication
//
//  Created by Khelfie on 09/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
import UIKit
import CoreBluetooth
import FirebaseAuth
import GoogleMaps
import UICircularProgressRing

class BluetootheConnectionTesting: UIViewController ,BluetoothDelegate{
    
    @IBOutlet weak var btnDevice: UIButton!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet var btnScanForDevice: UIButton!
    @IBOutlet weak var stackViewHowToConnect: UIStackView!
    @IBOutlet weak var stackViewChooseDetails: UIStackView!
    @IBOutlet weak var sgmntCtrlOrientation: UISegmentedControl!
    @IBOutlet weak var stackViewDeviceConnected: UIStackView!
    @IBOutlet weak var sgmntCtrlMetric: UISegmentedControl!
    @IBOutlet weak var btnSetupTags: UIButton!
    @IBOutlet weak var btnTagImage: UIButton!
    @IBOutlet weak var lblRemainingTag: UILabel!
    @IBOutlet weak var lblAssignedTag: UILabel!
    @IBOutlet weak var stackViewForSetupTag: UIStackView!
    @IBOutlet weak var lblHandiLeft: UILocalizedLabel!
    @IBOutlet weak var lblHandiRight: UILocalizedLabel!
    @IBOutlet weak var btnHandiLeft: UIButton!
    @IBOutlet weak var btnHandiRight: UIButton!
    @IBOutlet weak var handiLeftView: UIView!
    @IBOutlet weak var handiRightView: UIView!
    @IBOutlet weak var btnDeviceAfterConnected: UIButton!
    @IBOutlet weak var lblToDiffer: UILabel!
    @IBOutlet weak var buyNowSV: UIStackView!
    @IBOutlet weak var btnBuyNow: UIButton!

    
    var isFinishGame = false
    var isDeviceSetup = false
    var packetOneFlagC8 = false
    var swingMatchId = String()
    var isDeviceStillConnected = false
    var clubs = NSMutableDictionary()
    var golfBag = [String]()
    var golfBagArr = NSMutableArray()
    var counter : UInt8 = 0
    var tagClubNumber = [(tag:String ,club:Int)]()
    var activeMatchId = String()
    let progressView = SDLoader()
    var golfBagDriverArray = ["Dr"]
    var golfBagWoodArray = ["3w", "4w", "5w", "7w"]
    var golfBagHybridArray = ["1h", "2h", "3h", "4h", "5h", "6h", "7h"]
    var golfBagIronArray = ["1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i"]
    var golfBagWageArray = ["Pw", "Sw", "Gw", "Lw"]
    var golfBagPuttArray = ["Pu"]
    var currentGameId = Int()
    var totalAssigned = Int()
    var barBtnBLE = UIBarButtonItem()
    var golfXPopupView: UIView!
    var btnRetry: UIButton!
    var btnNoDevice: UIButton!
    var lblScanStatus: UILabel!
    var deviceCircularView: CircularProgress!
    var timeOutTimer = Timer()
    var sharedInstance: BluetoothSync!
    //        SGBarChartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: 10.0)!

    var attrs = [
        NSAttributedStringKey.font : UIFont(name: "SFProDisplay-Medium", size: 12.0)!,
        NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x007AFF),
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string: "Buy Now", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnBuyNow.setAttributedTitle(attributedString, for: .normal)

        btnSetupTags.setCorner(color: UIColor.clear.cgColor)
        btnScanForDevice.setCorner(color: UIColor.clear.cgColor)
        btnDevice.setCircle(frame: self.btnDevice.frame)
        self.title = "Connect Device"
        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)
        
//        self.getGolfBagData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupFinished(_:)), name: NSNotification.Name(rawValue:"command2Finished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.responseFirstCommand(_:)), name: NSNotification.Name(rawValue: "responseFirstCommand"), object: nil)
        barBtnBLE = UIBarButtonItem(image:  UIImage(named: "golficationBarG"), style: .plain, target: self, action: #selector(self.btnActionConnectBL(_:)))
        if Constants.isDevice{
            self.navigationItem.rightBarButtonItem = barBtnBLE
            checkDeviceStatus()
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
        self.buyNowSV.isHidden = true
        if !Constants.isDevice{
            self.buyNowSV.isHidden = false
        }
    }
    @IBAction func metricChangeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            Constants.distanceFilter = 1
        }else{
            Constants.distanceFilter = 0
        }

    }
    
    @IBAction func buyNowAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.title = ""
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @objc func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    func checkDeviceStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.golficationXDisconnected(_:)), name: NSNotification.Name(rawValue: "GolficationX_Disconnected"), object: nil)
        
        if(Constants.deviceGolficationX == nil){
            self.barBtnBLE.image =  UIImage(named: "golficationBarG")
        }
        else{
            self.barBtnBLE.image =  UIImage(named: "golficationBar")
        }
    }
    @objc func golficationXDisconnected(_ notification: NSNotification) {
        self.barBtnBLE.image =  UIImage(named: "golficationBarG")
        self.btnDevice.frame.origin.x = self.btnDevice.frame.origin.x - 25
        self.btnDevice.frame.origin.y = self.btnDevice.frame.origin.y - 25
        self.stackViewHowToConnect.isHidden = false
        self.stackViewChooseDetails.isHidden = true
        self.btnScanForDevice.isHidden = false
        self.buyNowSV.isHidden = true
        if !Constants.isDevice{
            self.buyNowSV.isHidden = false
        }
        self.stackViewForSetupTag.isHidden = true
        self.stackViewDeviceConnected.isHidden = true
        self.btnDevice.isHidden = false
        self.lblToDiffer.isHidden = true
        self.btnDeviceAfterConnected.isHidden = true
        self.view.layoutIfNeeded()

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
            if Constants.deviceGolficationX == nil{
                if Constants.ble == nil{
                    Constants.ble = BLE()
                }
                Constants.ble.isSetupScreen = true
                Constants.ble.startScanning()
                showPopUp()
            }
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
        Constants.deviceGolficationX = nil
        self.barBtnBLE.image =  UIImage(named: "golficationBarG")
        self.timeOutTimer.invalidate()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "Scanning_Time_Out"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "SetupScreen"))

        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            self.sharedInstance.delegate = nil
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }

    @objc func retryAction(_ sender: UIButton) {
        if golfXPopupView != nil{
            self.golfXPopupView.removeFromSuperview()
        }
        sharedInstance = BluetoothSync.getInstance()
        sharedInstance.delegate = self
        sharedInstance.initCBCentralManager()
    }
    @objc func btnActionConnectBL(_ sender: UIBarButtonItem) {
        if golfXPopupView != nil{
            self.golfXPopupView.removeFromSuperview()
        }
        sharedInstance = BluetoothSync.getInstance()
        sharedInstance.delegate = self
        sharedInstance.initCBCentralManager()
    }
    @IBAction func btnActionScanForDevice(_ sender: UIButton) {
        if golfXPopupView != nil{
            self.golfXPopupView.removeFromSuperview()
        }
        sharedInstance = BluetoothSync.getInstance()
        sharedInstance.delegate = self
        sharedInstance.initCBCentralManager()
    }
    
    func showPopUp(){
        self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SeventyFivePercentUpdated(_:)), name: NSNotification.Name(rawValue: "75_Percent_Updated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScreen(_:)), name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupScreen(_:)), name: NSNotification.Name(rawValue: "SetupScreen"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.ScanningTimeOut(_:)), name: NSNotification.Name(rawValue: "Scanning_Time_Out"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartPhone(_:)), name: NSNotification.Name(rawValue: "RestartPhone"), object: nil)

        self.barBtnBLE.image =  UIImage(named: "golficationBarG")
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.golfXPopupView = (Bundle.main.loadNibNamed("ScanningGolfX", owner: self, options: nil)![0] as! UIView)
        self.golfXPopupView.frame = self.view.bounds
        self.view.addSubview(self.golfXPopupView)
        setGofXUISetup()
    }
    @objc func timerAction() {
        self.timeOutTimer.invalidate()
        Constants.ble.textInfo = "Device not found. Please try again."
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
    
    @objc func restartPhone(_ notification: NSNotification){
        DispatchQueue.main.async(execute: {
            self.noDeviceAvailable()
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "RestartPhone"))
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
        self.lblScanStatus.text = Constants.ble.textInfo
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.btnRetry.isHidden = false
        self.btnNoDevice.isHidden = false
        self.barBtnBLE.image =  UIImage(named: "golficationBarG")
        Constants.ble.stopScanning()
    }
    
    @objc func SeventyFivePercentUpdated(_ notification: NSNotification){
        DispatchQueue.main.async(execute: {
            self.timeOutTimer.invalidate()
            self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
            
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.50, toValue: 0.75)
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        })
    }
    
    @objc func animateProgress() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.golfXPopupView.removeFromSuperview()
        if Constants.ble != nil{
            Constants.ble.stopScanning()
        }

        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        updateScreenBLE()
    }
    @objc func setupProgress() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.golfXPopupView.removeFromSuperview()
        if Constants.ble != nil{
            Constants.ble.stopScanning()
        }
        
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "SetupScreen"))
        updateScreenBLE()
    }

    func updateScreenBLE(){
        self.barBtnBLE.image =  UIImage(named: "golficationBar")
        self.lblDeviceName.text = "Golficaion X"
        self.stackViewHowToConnect.isHidden = true
        self.stackViewChooseDetails.isHidden = false
        self.btnScanForDevice.isHidden = true
        self.buyNowSV.isHidden = true
        self.btnDevice.frame.origin.x = self.btnDevice.frame.origin.x + 25
        self.btnDevice.frame.origin.y = self.btnDevice.frame.origin.y + 25
        self.stackViewForSetupTag.isHidden = false
        self.stackViewDeviceConnected.isHidden = false
        self.btnDevice.isHidden = true
        self.lblToDiffer.isHidden = false
        self.btnDeviceAfterConnected.isHidden = false
        self.btnTagImage.setCircle(frame: self.btnTagImage.frame)
        self.view.backgroundColor = UIColor.glfWhite
        self.handiRightView.layer.borderWidth = 2.0
        self.handiLeftView.layer.borderWidth = 2.0
        self.handiLeftView.layer.borderColor = UIColor.clear.cgColor
        self.handiRightView.layer.borderColor = UIColor.glfGreenBlue.cgColor
        self.view.layoutIfNeeded()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        self.barBtnBLE.image =  UIImage(named: "golficationBar")
        self.view.makeToast("Device is connected.")
        
        if Constants.handed.contains("Left"){
            self.handiChangedAction(self.btnHandiLeft)
        }else{
            self.handiChangedAction(self.btnHandiRight)
        }
        
        if Constants.distanceFilter == 1{
            self.sgmntCtrlMetric.selectedSegmentIndex = 0
        }else{
            self.sgmntCtrlMetric.selectedSegmentIndex = 1
        }
    }
    @objc func setupFinished(_ notification: NSNotification){
        DispatchQueue.main.async {
            Constants.ble.isDeviceSetup = true
            Constants.isTagSetupModified = false
            UIApplication.shared.keyWindow?.makeToast("Golfication X setup complete.")
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue:"command2Finished"))
        }
    }
    @objc func cancelGolfXAction(_ sender: UIButton!) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        golfXPopupView.removeFromSuperview()
    }
    @objc func updateScreen(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        
        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.75, toValue: 1.0)
            self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
        })
    }
    @objc func setupScreen(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        
        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.75, toValue: 1.0)
            self.perform(#selector(self.setupProgress), with: nil, afterDelay: 1.0)
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.getGolfBagData()
        if(Constants.deviceGolficationX != nil) && Constants.ble != nil{
            Constants.ble.currentGameId = 0
            Constants.ble.isSetupScreen = true
            updateScreenBLE()
        }
    }
    func getGolfBagData(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.totalAssigned = 0
            if let tempArray = snapshot.value as? NSMutableArray{
                self.golfBagArr = tempArray
                for data in self.golfBagArr{
                    if let clubDict = data as? NSMutableDictionary{
                        self.clubs.addEntries(from: [clubDict.value(forKey: "clubName") as! String : clubDict.value(forKey: "tag") as! Bool])
                        if let tag = clubDict.value(forKey: "tag") as? Bool {
                            self.totalAssigned += tag ? 1:0
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                var newGolfBagDriverArray = [String]()
                var newGolfBagWoodArray = [String]()
                var newGolfBagHybridArray = [String]()
                var newGolfBagIronArray = [String]()
                var newGolfBagWageArray = [String]()
                var newGolfBagPuttArray = [String]()
                
                for (key,_) in self.clubs{
                    let club = key as! String
                    if(self.golfBagDriverArray.contains(club)){
                        newGolfBagDriverArray.append(club)
                    }else if(self.golfBagWoodArray.contains(club)){
                        newGolfBagWoodArray.append(club)
                    }else if(self.golfBagHybridArray.contains(club)){
                        newGolfBagHybridArray.append(club)
                    }else if(self.golfBagIronArray.contains(club)){
                        newGolfBagIronArray.append(club)
                    }else if(self.golfBagWageArray.contains(club)){
                        newGolfBagWageArray.append(club)
                    }else if(self.golfBagPuttArray.contains(club)){
                        newGolfBagPuttArray.append(club)
                    }
                }
                self.golfBagDriverArray.removeAll()
                self.golfBagWoodArray.removeAll()
                self.golfBagHybridArray.removeAll()
                self.golfBagIronArray.removeAll()
                self.golfBagWageArray.removeAll()
                self.golfBagPuttArray.removeAll()
                
                var allClubs = ["Dr","3w","4w","5w","7w","1i","2i","3i","4i","5i","6i","7i","8i","9i","1h","2h","3h","4h","5h","6h","7h","Pw","Gw","Sw","Lw","Pu"]
                for j in 0..<allClubs.count{
                    for i in 0..<newGolfBagDriverArray.count{
                        let clubName = newGolfBagDriverArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagDriverArray.append(clubName)
                        }
                    }
                    for i in 0..<newGolfBagWoodArray.count{
                        let clubName = newGolfBagWoodArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagWoodArray.append(clubName)
                        }
                    }
                    for i in 0..<newGolfBagHybridArray.count{
                        let clubName = newGolfBagHybridArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagHybridArray.append(clubName)
                        }
                    }
                    for i in 0..<newGolfBagIronArray.count{
                        let clubName = newGolfBagIronArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagIronArray.append(clubName)
                        }
                    }
                    for i in 0..<newGolfBagWageArray.count{
                        let clubName = newGolfBagWageArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagWageArray.append(clubName)
                        }
                    }
                    for i in 0..<newGolfBagPuttArray.count{
                        let clubName = newGolfBagPuttArray[i]
                        if allClubs[j] == clubName{
                            self.golfBagPuttArray.append(clubName)
                        }
                    }
                }

                debugPrint("golfBagDriverArray",self.golfBagDriverArray)
                debugPrint("golfBagWoodArray",self.golfBagWoodArray)
                debugPrint("golfBagHybridArray",self.golfBagHybridArray)
                debugPrint("golfBagIronArray",self.golfBagIronArray)
                debugPrint("golfBagWageArray",self.golfBagWageArray)
                debugPrint("golfBagPuttArray",self.golfBagPuttArray)

//                self.golfBagDriverArray = newGolfBagDriverArray
//                self.golfBagWoodArray = newGolfBagWoodArray
//                self.golfBagHybridArray = newGolfBagHybridArray
//                self.golfBagIronArray = newGolfBagIronArray
//                self.golfBagWageArray = newGolfBagWageArray
//                self.golfBagPuttArray = newGolfBagPuttArray
                
                self.golfBag.removeAll()
                if(self.golfBagDriverArray.count != 0){
                    self.golfBag.append("Drivers")
                }
                if(self.golfBagWoodArray.count != 0){
                    self.golfBag.append("Woods")
                }
                if(self.golfBagHybridArray.count != 0){
                    self.golfBag.append("Hybrids")
                }
                if(self.golfBagIronArray.count != 0){
                    self.golfBag.append("Irons")
                }
                if(self.golfBagWageArray.count != 0){
                    self.golfBag.append("Wedges")
                }
                if(self.golfBagPuttArray.count != 0){
                    self.golfBag.append("Putter")
                }
                self.lblAssignedTag.text = "\(self.totalAssigned) assigned"
                self.lblRemainingTag.text = "\(self.golfBagArr.count - self.totalAssigned) remaining"
                self.getIsDeviceAlreadySetup()
            })
        }
    }
    func getIsDeviceAlreadySetup(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "deviceInfo/setup") { (snapshot) in
            var isSetup = false
            if (snapshot.value as? Bool) != nil{
                isSetup = snapshot.value as! Bool
            }
            DispatchQueue.main.async(execute: {
                self.isDeviceSetup = isSetup
                self.progressView.hide(navItem: self.navigationItem)
            })
        }
    }
    // MARK: handiChangedAction
    @IBAction func handiChangedAction(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            self.sgmntCtrlOrientation.selectedSegmentIndex = 0
            btnHandiLeft.setImage(UIImage(named: "handiLeftDark"), for: .normal)
            btnHandiRight.setImage(UIImage(named: "handiRIghtLight"), for: .normal)
            lblHandiLeft.textColor = UIColor.black
            lblHandiRight.textColor = UIColor(rgb: 0x133022)
            handiLeftView.layer.borderColor = UIColor.glfBluegreen.cgColor
            handiRightView.layer.borderColor = UIColor.clear.cgColor
        case 1:
            self.sgmntCtrlOrientation.selectedSegmentIndex = 1
            btnHandiRight.setImage(UIImage(named: "handiRIghtDark"), for: .normal)
            btnHandiLeft.setImage(UIImage(named: "handiLeftLight"), for: .normal)
            lblHandiLeft.textColor = UIColor(rgb: 0x133022)
            lblHandiRight.textColor = UIColor.black
            handiLeftView.layer.borderColor = UIColor.clear.cgColor
            handiRightView.layer.borderColor = UIColor.glfBluegreen.cgColor
        default:
            break;
        }
    }
    
    @IBAction func btnActionSetupTags(_ sender: UIButton) {
        let leftOrRight :UInt8 = UInt8(self.sgmntCtrlOrientation.selectedSegmentIndex + 1)
        let metric :UInt8 = UInt8(self.sgmntCtrlMetric.selectedSegmentIndex + 1)
        Constants.ble.sendFirstCommand(leftOrRight: leftOrRight,metric: metric)
//        let viewCtrl = UIStoryboard(name: "Device", bundle: nil).instantiateViewController(withIdentifier: "debugModeVC") as! DebugModeVC
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @objc func responseFirstCommand(_ notification: NSNotification){
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "responseFirstCommand"))
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AssignTagVC") as! AssignTagVC
        viewCtrl.golfBagDriverArray = golfBagDriverArray
        viewCtrl.golfBagIronArray = golfBagIronArray
        viewCtrl.golfBagWoodArray = golfBagWoodArray
        viewCtrl.golfBagWageArray = golfBagWageArray
        viewCtrl.golfBagHybridArray = golfBagHybridArray
        viewCtrl.golfBagPuttArray = golfBagPuttArray
        viewCtrl.golfBag = golfBag
        viewCtrl.clubs = clubs
        viewCtrl.golfBagArr = self.golfBagArr
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
}

