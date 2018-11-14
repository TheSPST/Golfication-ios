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

class ScanningVC: UIViewController {
    
    @IBOutlet weak var deviceCircularView: UICircularProgressRingView!
    @IBOutlet weak var btnRetry: UIButton!
    @IBOutlet weak var btnNoDevice: UIButton!
    @IBOutlet weak var btnBuyNow: UIButton!

    @IBOutlet weak var lblWaitingForSwing: UILabel!
    @IBOutlet weak var lblStartSwinging: UILabel!
    @IBOutlet weak var barBtnBLE: UIBarButtonItem!
    @IBOutlet weak var lblScanStatus: UILabel!
    @IBOutlet weak var viewHaveDevice: UIView!
    
    @IBOutlet weak var noDeviceSV: UIStackView!
    @IBOutlet weak var startScanningSV: UIStackView!
    @IBOutlet weak var startSwingingSV: UIStackView!

    @IBOutlet weak var swingProgressView: UIProgressView!
    var progressView = SDLoader()
    var tempTimer: Timer!
    var currentGameId = Int()
    var activeMatchId = String()
    var swingMatchId = String()
    var isPracticeMatch = Bool()
    var swingDetails = [(shotNo:Int,bs:Double,ds:Double,hv:Double,cv:Double,ba:Double,tempo:Double,club:String,time:Int64)]()
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    var isDeviceSetup = false
    var progressValue = 0.0
    @IBAction func barBtnBLEAction(_ sender: Any) {
        if (self.barBtnBLE.image == #imageLiteral(resourceName: "golficationBarG")){
            Constants.ble = BLE()
            Constants.ble.startScanning()
            Constants.ble.isPracticeMatch = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showShotsAfterSwing(_:)), name: NSNotification.Name(rawValue: "getSwing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noSetup(_:)), name: NSNotification.Name(rawValue: "noSetup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.takeSwing(_:)), name: NSNotification.Name(rawValue: "readyToTakeSwing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: "DeviceConnected"), object: nil)
        setInitialUI()
        
        if Constants.isDevice{
            viewHaveDevice.isHidden = false
            noDeviceSV.isHidden = true
            startScanningSV.isHidden = false
            startSwingingSV.isHidden = true
            getSwingData()
        }
        else{
            viewHaveDevice.isHidden = true
            noDeviceSV.isHidden = false
        }
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
                    self.totalPracticeSession = dataDi.count+1
//                    self.title = "Practice Session \(dataDi.count+1)"
                }
            }
            DispatchQueue.main.async(execute: {
                    let group = DispatchGroup()
                    if(dataDic.count == 0){
                        self.progressView.hide(navItem: self.navigationItem)
                        self.retryAction(self.btnRetry)
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
                                                    self.swingDetails.append((shotNo: shot, bs: bs, ds: ds, hv: hv, cv: cv, ba: ba, tempo: tempo, club: club, time: time))
                                                }
                                            }
                                        }
                                        if let playType = data.value(forKey: "playType") as? String{
                                            if(playType != "match") && self.swingDetails.count != 0{
                                                swingMArray.add(data)
                                            }
                                        }
                                    }
                                }
                                group.leave()
                            }
                        }
                        else{
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
                        self.retryAction(self.btnRetry)
                    })
                })
                
            }
        }
    @objc func noSetup(_ notification:NSNotification){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func reloadData(_ notification:NSNotification){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startMatchCalling"), object: true)
            self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "DeviceConnected"))
    }

    @objc func takeSwing(_ notification:NSNotification){
        self.noDeviceSV.isHidden = true
        self.startScanningSV.isHidden = true
        self.startSwingingSV.isHidden = false
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
    }
    @objc func showShotsAfterSwing(_ notification:NSNotification){
        if let dict = notification.object as? NSMutableDictionary{
            self.currentGameId = dict.value(forKey: "gameId") as! Int
            let swingKey = dict.value(forKey: "id") as! String
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/") { (snapshot) in
                var dict = NSMutableDictionary()
                if let diction = snapshot.value as? NSMutableDictionary{
                    dict = diction
                }
                DispatchQueue.main.async(execute: {
                    if let swingArr = dict.value(forKey: "swings") as? NSArray{
                        debugPrint("Diction:\(swingArr)")
                        self.lblWaitingForSwing.text = "Fetching Swing details...."
                        self.lblStartSwinging.text = "Swing Detected"
                        self.perform(#selector(self.updateProgress), with: nil, afterDelay: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "PracticePageContainerVC") as! PracticePageContainerVC
                            viewCtrl.swingKey = swingKey
                            viewCtrl.count = self.totalPracticeSession
                            var shotsAr = [String]()
                            for i in 0..<swingArr.count{
                                shotsAr.append("Shot \(i+1)")
                            }
                            viewCtrl.shotsArray = shotsAr
                            viewCtrl.tempArray1 = swingArr
                            self.navigationController?.pushViewController(viewCtrl, animated: true)
                        })
                    }else{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "readyToTakeSwing"), object: nil)
                    }
                })
            }
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "getSwing"))
    }
    
    func setInitialUI(){
        btnNoDevice.layer.cornerRadius = btnNoDevice.frame.size.height/2
        btnRetry.layer.cornerRadius = 3.0
        btnBuyNow.layer.cornerRadius = 3.0
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        self.barBtnBLE.isEnabled = true
    }
    func getIsDeviceAlreadySetup(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "deviceSetup") { (snapshot) in
            if (snapshot.value as? Bool) != nil{
                self.isDeviceSetup = snapshot.value as! Bool
            }
            DispatchQueue.main.async(execute: {
                if(self.isDeviceSetup){
                    self.setInitialDeviceData()
                }else{
                    self.view.makeToast("Please Finish Setup First from the profile.")
                    self.noDeviceSV.isHidden = false
                    self.startScanningSV.isHidden = true
                    self.startSwingingSV.isHidden = true
                    self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
                }
            })
        }
    }
    func setInitialDeviceData(){
        lblScanStatus.text = "Scanning for Golfication X..."
        btnRetry.isHidden = true
        btnNoDevice.isHidden = true
        startSwingingSV.isHidden = true
        DispatchQueue.main.async(execute: {
             if(Constants.deviceGolficationX == nil){
                Constants.ble = BLE()
                Constants.ble.isDeviceSetup = false
                Constants.ble.startScanning()
                Constants.ble.isPracticeMatch = true
                Constants.ble.swingMatchId = self.swingMatchId
                Constants.ble.currentGameId = self.currentGameId
//                Constants.ble.swingDetails = self.swingDetails
                debugPrint("swingMatchId:",self.swingMatchId)
                debugPrint("currentGameId:",self.currentGameId)
                debugPrint("swingDetails:",self.swingDetails)
                self.deviceCircularView.setProgress(value: CGFloat(90), animationDuration: 5.5, completion: {
                    if(Constants.deviceGolficationX != nil) && !Constants.ble.isContinue{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startMatchCalling"), object: true)
                    }else{
                        self.lblScanStatus.text = "Couldn't find your device"
                        self.deviceCircularView.setProgress(value: CGFloat(0), animationDuration: 0.0)
                        self.btnRetry.isHidden = false
                        self.btnNoDevice.isHidden = false
                        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
                    }
                })
             }else{
                Constants.ble.isPracticeMatch = true
                Constants.ble.isDeviceSetup = false
                Constants.ble.swingMatchId = self.swingMatchId
                Constants.ble.currentGameId = self.currentGameId
                Constants.ble.swingDetails = self.swingDetails
                Constants.ble.sendThirdCommand()
            }
        })
    }
    @objc func updateProgress() {
        progressValue = progressValue + 0.1
        self.swingProgressView.progress = Float(progressValue)
        if progressValue != 2.0 {
            self.perform(#selector(updateProgress), with: nil, afterDelay: 0.1)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func retryAction(_ sender: UIButton) {
        btnRetry.isHidden = true
        self.btnNoDevice.isHidden = true
        self.setInitialDeviceData()
    }
}
