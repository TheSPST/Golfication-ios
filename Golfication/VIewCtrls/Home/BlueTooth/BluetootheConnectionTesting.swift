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

class BluetootheConnectionTesting: UIViewController {
    
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
    @IBOutlet weak var lblHandiLeft: UILabel!
    @IBOutlet weak var lblHandiRight: UILabel!
    @IBOutlet weak var btnHandiLeft: UIButton!
    @IBOutlet weak var btnHandiRight: UIButton!
    @IBOutlet weak var handiLeftView: UIView!
    @IBOutlet weak var handiRightView: UIView!
    @IBOutlet weak var btnDeviceAfterConnected: UIButton!
    @IBOutlet weak var lblToDiffer: UILabel!
    
    var isFinishGame = false
    var isDeviceSetup = false
    var packetOneFlagC8 = false
    var swingMatchId = String()
    var isDeviceStillConnected = false
    var clubs = NSMutableDictionary()
    var golfBag = [String]()
    var golfBagArr = NSMutableArray()
    var counter : UInt8 = 0
    var tagClubNumber = [(tag:Int ,club:Int)]()
    var activeMatchId = String()
    let progressView = SDLoader()
    var golfBagDriverArray = ["Dr"]
    var golfBagWoodArray = ["3w", "4w", "5w", "7w"]
    var golfBagHybridArray = ["1h", "2h", "3h", "4h", "5h", "6h", "7h"]
    var golfBagIronArray = ["1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i"]
    var golfBagWageArray = ["Pw", "Sw", "Gw", "Lw"]
    var golfBagPuttArray = ["Pu"]
    var isPracticeMatch = false
    var currentGameId = Int()
    var totalAssigned = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSetupTags.setCorner(color: UIColor.clear.cgColor)
        btnScanForDevice.setCorner(color: UIColor.clear.cgColor)
        btnDevice.setCircle(frame: self.btnDevice.frame)
        self.title = "Connect Device"
        self.getGolfBagData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScreen(_:)), name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupFinished(_:)), name: NSNotification.Name(rawValue:"command2Finished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.responseFirstCommand(_:)), name: NSNotification.Name(rawValue: "responseFirstCommand"), object: nil)


    }
    @objc func setupFinished(_ notification: NSNotification){
        let alertVC = UIAlertController(title: "Alert", message: "Golfication X setup successfull ompleted.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)

        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue:"command2Finished"))
    }
    @objc func updateScreen(_ notification: NSNotification){
        self.lblDeviceName.text = "\(deviceGolficationX.name ?? "No Name")"
        self.stackViewHowToConnect.isHidden = true
        self.stackViewChooseDetails.isHidden = false
        self.btnScanForDevice.isHidden = true
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
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(deviceGolficationX != nil){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        }
    }
    func getGolfBagData(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            if let tempArray = snapshot.value as? NSMutableArray{
                self.golfBagArr = tempArray
                for data in tempArray{
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
                
                self.golfBagDriverArray = newGolfBagDriverArray
                self.golfBagWoodArray = newGolfBagWoodArray
                self.golfBagHybridArray = newGolfBagHybridArray
                self.golfBagIronArray = newGolfBagIronArray
                self.golfBagWageArray = newGolfBagWageArray
                self.golfBagPuttArray = newGolfBagPuttArray
                
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
                self.lblRemainingTag.text = "\(14 - self.totalAssigned) remaining"
                self.getIsDeviceAlreadySetup()
            })
        }
    }
    func getIsDeviceAlreadySetup(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "deviceSetup") { (snapshot) in
            if (snapshot.value as? Bool) != nil{
                self.isDeviceSetup = snapshot.value as! Bool
            }
            DispatchQueue.main.async(execute: {
                self.getActiveRound()
            })
        }
    }
    func getActiveRound(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser!.uid)/activeMatches") { (snapshot) in
            var activeRoundKeysArray = [String:Bool]()
            if (snapshot.value != nil) {
                activeRoundKeysArray = (snapshot.value as? [String : Bool])!
            }
            DispatchQueue.main.async(execute: {
                for data in activeRoundKeysArray{
                    if(data.value){
                        self.activeMatchId = data.key
                    }
                }
                
                self.getSwingKey(matchId:self.activeMatchId)
            })
        }
    }
    
    // MARK: handiChangedAction
    @IBAction func handiChangedAction(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            self.sgmntCtrlOrientation.selectedSegmentIndex = 0
            btnHandiLeft.setImage(#imageLiteral(resourceName: "handiLeftDark"), for: .normal)
            btnHandiRight.setImage(#imageLiteral(resourceName: "handiRIghtLight"), for: .normal)
            lblHandiLeft.textColor = UIColor.black
            lblHandiRight.textColor = UIColor(rgb: 0x133022)
            handiLeftView.layer.borderColor = UIColor.glfBluegreen.cgColor
            handiRightView.layer.borderColor = UIColor.clear.cgColor
            
        case 1:
            self.sgmntCtrlOrientation.selectedSegmentIndex = 1
            btnHandiRight.setImage(#imageLiteral(resourceName: "handiRIghtDark"), for: .normal)
            btnHandiLeft.setImage(#imageLiteral(resourceName: "handiLeftLight"), for: .normal)
            lblHandiLeft.textColor = UIColor(rgb: 0x133022)
            lblHandiRight.textColor = UIColor.black
            handiLeftView.layer.borderColor = UIColor.clear.cgColor
            handiRightView.layer.borderColor = UIColor.glfBluegreen.cgColor
        default:
            break;
        }
    }
    
    
    func getSwingKey(matchId:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "matchData/\(matchId)/plyer/\(Auth.auth().currentUser!.uid)/swingKey") { (snapshot) in
            if (snapshot.value != nil) {
                self.swingMatchId = snapshot.value as! String
            }
            DispatchQueue.main.async(execute: {
                self.getCurrentGameID()
            })
        }
    }
    func getCurrentGameID(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(self.swingMatchId)") { (snapshot) in
            var swingData = NSMutableDictionary()
            if (snapshot.value != nil) {
                swingData = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                for (key,value) in swingData{
                    if(key as! String == "gameId"){
                        self.currentGameId = value as! Int
                    }
                    else if(key as! String == "playType"){
                        if(value as! String == "practice"){
                            self.isPracticeMatch = true
                        }
                    }
                }
            })
        }
    }

    @IBAction func btnActionSetupTags(_ sender: UIButton) {
        let leftOrRight :UInt8 = UInt8(self.sgmntCtrlOrientation.selectedSegmentIndex + 1)
        let metric :UInt8 = UInt8(self.sgmntCtrlMetric.selectedSegmentIndex + 1)
        ble.sendFirstCommand(leftOrRight: leftOrRight,metric: metric)
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
        viewCtrl.golfBagArr = golfBagArr
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func btnActionScanForDevice(_ sender: UIButton) {
        ble = BLE()
        ble.startScanning()
    }
}

