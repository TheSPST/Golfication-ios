//
//  GolfBagTabsVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import FirebaseAuth
import XLPagerTabStrip
import CoreBluetooth

var syncdArray = NSMutableArray()

class GolfBagTabsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider, BluetoothDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var brandView: UIView!
    @IBOutlet weak var loftAngleView: UIView!
    @IBOutlet weak var clubLengthView: UIView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var tagTableView: UITableView!

    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSyncTag: UIButton!
    @IBOutlet weak var btnAddToBag: UIButton!
    
    @IBOutlet weak var btnTempAddBag: UIButton!
    @IBOutlet weak var btnTempRemoveBag: UIButton!

    @IBOutlet weak var scanProgressView: ScanProgressView!
    @IBOutlet weak var syncStackView: UIStackView!
    let progressView = SDLoader()
    
    var selectedBagStr = String()
    var tagNames = [String]()
    
    var golfBagDriverArray = ["Dr"]
    var golfBagWoodArray = ["3w", "4w", "5w", "7w"]
    var golfBagHybridArray = ["1h", "2h", "3h", "4h", "5h", "6h", "7h"]
    var golfBagIronArray = ["1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i"]
    var golfBagWageArray = ["Pw", "Sw", "Gw", "Lw"]
    var golfBagPuttArray = ["Pu"]
    var commanBagArray = [String]()
    var tagNameMArray = NSMutableArray()

    var golfBagStr = String()
    var indexOfCellBeforeDragging = 0
    var fromEdit = Bool()
    var bagMArray = NSMutableArray()
    var tagNameArray = NSMutableArray()

    var sharedInstance: BluetoothSync!
    
    var timer = Timer()
//    var periName = ""
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brandView.layer.borderWidth = 1.0
        brandView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        loftAngleView.layer.borderWidth = 1.0
        loftAngleView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        clubLengthView.layer.borderWidth = 1.0
        clubLengthView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        btnRemove.layer.cornerRadius = 3.0
        btnEdit.layer.cornerRadius = 3.0
        btnSyncTag.layer.cornerRadius = 3.0
        btnAddToBag.layer.cornerRadius = 3.0
        
        btnTempAddBag.layer.cornerRadius = 3.0
        btnTempRemoveBag.layer.cornerRadius = 3.0
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
            sharedInstance.startScanPeripheral()
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
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        
        debugPrint("peripheral.name== ", peripheral.name ?? "")
        debugPrint("RSSI== ", RSSI)
        self.scanProgressView.show(navItem: self.navigationItem)
        self.scanProgressView.progressView.setProgress(10, animated: true)
//        progressBar.setProgress(percentage / 100.0, animated: false)
         let periName = peripheral.name ?? ""
        if (periName.contains("GX")){
            if !(tagNameMArray.contains(periName)){
                let dic = NSMutableDictionary()
                dic.setValue(periName, forKey: "PeripheralName")
                dic.setValue(peripheral, forKey: "Peripheral")

                tagNameArray.add(dic)
                self.scanProgressView.progressView.setProgress(30, animated: true)
//                self.syncTag(tagName: periName, peripheral: peripheral)
            }
        }
    }
    
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {
        debugPrint("Connected")
        if let services = connectedPeripheral.services{
            for service in services{
                debugPrint(service)
            }
        }
        debugPrint("Searching For Services")
    }
    
    func didDiscoverServices(_ peripheral: CBPeripheral) {
        
        if let services = peripheral.services{
            for service in services {
                debugPrint(service.uuid)
                //                if(service.uuid == golficationXServiceCBUUID_READ){
                //                    service_Read = service
                //                    debugPrint("Read UUID :\(service_Read!.uuid)")
                //                    deviceGolficationX.discoverCharacteristics(nil, for: service_Read)
                //                }
                //                if(service.uuid == golficationXServiceCBUUID_Write){
                //                    service_Write = service
                //                    debugPrint("Write UUID  :\(service_Write!.uuid)")
                //                    deviceGolficationX.discoverCharacteristics(nil, for: service_Write)
                //                }
            }
        }
        else {
            debugPrint("No service Found")
        }
        self.scanProgressView.hide(navItem: self.navigationItem)
        sharedInstance.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fromEdit = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        editView.isHidden = true
        defaultView.isHidden = true
        
        if golfBagStr == "Drivers"{
            commanBagArray = golfBagDriverArray
        }
        else if golfBagStr == "Woods"{
            commanBagArray = golfBagWoodArray
        }
        else if golfBagStr == "Hybrids"{
            commanBagArray = golfBagHybridArray
        }
        else if golfBagStr == "Irons"{
            commanBagArray = golfBagIronArray
        }
        else if golfBagStr == "Wedges"{
            commanBagArray = golfBagWageArray
        }
        else if golfBagStr == "Putter"{
            commanBagArray = golfBagPuttArray
        }
        selectedBagStr = commanBagArray[pageControl.currentPage]
        pageControl.numberOfPages = commanBagArray.count
        collectionViewFlowLayout.minimumLineSpacing = 0
        
        if commanBagArray.count == 1{
            pageControl.isHidden = true
        }
        else{
            pageControl.isHidden = false
        }
        
        //if syncdArray.count == 0{
        getGolfBagData()
        //}
        let tblContainerGesture = UITapGestureRecognizer(target: self, action: #selector(self.tblContainerTapped(_:)))
        tableContainerView.addGestureRecognizer(tblContainerGesture)
    }
    
    @objc func tblContainerTapped(_ sender:UITapGestureRecognizer){
        for tblVIew in tableContainerView.subviews{
            if !(tblVIew.isKind(of: UITableView.self)){
                tableContainerView.isHidden = true
            }
        }
    }
    
    func getGolfBagData() {
        syncdArray = NSMutableArray()
        bagMArray = NSMutableArray()
        
        self.editView.isHidden = false
        self.defaultView.isHidden = true
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
            if(snapshot.value != nil){
                
                golfBagArray = snapshot.value as! NSMutableArray
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    self.bagMArray.add(dict.value(forKey: "clubName") as! String)
                    if (dict.value(forKey: "tag") as! Bool == true){
                        syncdArray.add(dict.value(forKey: "clubName") as! String)
                    }
                }
                if (self.bagMArray.contains(self.selectedBagStr)){
                    self.btnAddToBag.isHidden = true
                    
                    if !self.fromEdit{
                        self.editView.isHidden = true
                        self.defaultView.isHidden = false
                    }
                }
                else{
                    self.btnAddToBag.isHidden = false
                    self.editView.isHidden = false
                    self.defaultView.isHidden = true
                }
                if syncdArray.count>0{
                    for j in 0..<syncdArray.count{
                        if self.selectedBagStr == syncdArray[j] as! String{
                            
                            //for k in 0..<self.commanBagArray.count{
                            //if self.selectedBagStr == self.commanBagArray[k] {
                            
                            let indexPath = IndexPath(row: j, section: 0)
                            guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                else{break}
                            cell.golfImage.layer.borderWidth = 2.0
                            cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                            cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                            
                            if !self.fromEdit{
                                self.editView.isHidden = true
                                self.defaultView.isHidden = false
                            }
                            break
                            //}
                            //}
                        }
                    }
                }
                // -------------------------------------------------
                
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        //self.syncStackView.isHidden = false //commented by Amit
                        if (dict.value(forKey: "tag") as! Bool == true){
                            self.btnSyncTag.backgroundColor = UIColor.glfWarmGrey
                            self.btnSyncTag.setTitle("Desync Tags", for: .normal)
                            return
                        }
                        else{
                            self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                            self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                            return
                        }
                    }
                }
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if !(dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                        self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                        self.syncStackView.isHidden = true
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func clubLengthAction(_ sender: Any){
        ActionSheetStringPicker.show(withTitle: "Select Club Length", rows: ["5", "6"], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            if value == 0 {
                //self.saveAndviewScore()
            }
            else{
                //self.exitWithoutSave()
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    @IBAction func loftAngleAction(_ sender: Any){
        ActionSheetStringPicker.show(withTitle: "Select Loft Angle", rows: ["3", "4"], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            if value == 0 {
                //self.saveAndviewScore()
            }
            else{
                //self.exitWithoutSave()
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    @IBAction func chooseBrandAction(_ sender: Any){
        ActionSheetStringPicker.show(withTitle: "Select Brand", rows: ["1", "2"], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            if value == 0 {
                //self.saveAndviewScore()
            }
            else{
                //self.exitWithoutSave()
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    @IBAction func removeBagAction(_ sender: Any){
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
            self.editView.isHidden = false
            self.defaultView.isHidden = true
            
            if(snapshot.value != nil){
                
                golfBagArray = snapshot.value as! NSMutableArray
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        // if (dict.value(forKey: "tag") as! Bool == true){
                        
                        golfBagArray.removeObject(at: i)
                        let golfBagData = ["golfBag": golfBagArray]
                        
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                        
                        for j in 0..<self.commanBagArray.count{
                            if self.selectedBagStr == self.commanBagArray[j] {
                                
                                let indexPath = IndexPath(row: j, section: 0)
                                guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                    else{break}
                                cell.golfImage.layer.borderWidth = 0.0
                                cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                                cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                                break
                            }
                        }
                        break
                        //}
                    }
                }
            }
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        fromEdit = true
        getGolfBagData()
    }
    
    @IBAction func addToBagAction(_ sender: Any) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        let tempBagArray = NSMutableArray()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
            self.editView.isHidden = true
            self.defaultView.isHidden = false
            
            if(snapshot.value != nil){
                golfBagArray = snapshot.value as! NSMutableArray
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    tempBagArray.add(dict.value(forKey: "clubName") as! String)
                }
            }
            DispatchQueue.main.async(execute: {
                if !(tempBagArray.contains(self.selectedBagStr)){
                    
                    let golfBagDict = NSMutableDictionary()
                    golfBagDict.setObject("Titleiest", forKey: "brand" as NSCopying)
                    golfBagDict.setObject("43", forKey: "clubLength" as NSCopying)
                    golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                    golfBagDict.setObject("2.3", forKey: "loftAngle" as NSCopying)
                    golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                    golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                    
                    golfBagArray.insert(golfBagDict, at: 0)
                    let golfBagData = ["golfBag": golfBagArray]
                    
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                    
                    //self.syncStackView.isHidden = false //commented by Amit
                    self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                    self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                }
            })
        }
    }
    
    @IBAction func syncTagAction(_ sender: Any) {
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            
            var golfBagArray = NSMutableArray()
            self.editView.isHidden = true
            self.defaultView.isHidden = false
            
            if(snapshot.value != nil){
                
                golfBagArray = snapshot.value as! NSMutableArray
                
                self.tagNameMArray = NSMutableArray()
                syncdArray = NSMutableArray()

                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "tag") as! Bool == true){
                        self.tagNameMArray.add(dict.value(forKey: "tagName") as! String)
                        syncdArray.add(dict.value(forKey: "clubName") as! String)
                    }
                }
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        
//                        if (dict.value(forKey: "tag") as! Bool == true){
                        if syncdArray.contains(self.selectedBagStr){
                            let golfBagDict = NSMutableDictionary()
                            golfBagDict.setObject("Titleiest", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("43", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("2.3", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                            
                            golfBagArray.replaceObject(at: i, with: golfBagDict)
                            let golfBagData = ["golfBag": golfBagArray]
                            
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            
                            self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                            self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                            
                            for j in 0..<self.commanBagArray.count{
                                if self.selectedBagStr == self.commanBagArray[j] {
                                    
                                    let indexPath = IndexPath(row: j, section: 0)
                                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                        else{break}
                                    cell.golfImage.layer.borderWidth = 0.0
                                    cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                                    cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                                }
                            }
//                            self.sharedInstance.delegate = nil
                            break
                        }
                        else{
                            self.sharedInstance = BluetoothSync.getInstance()
                            self.sharedInstance.delegate = self
                            self.sharedInstance.initCBCentralManager()
                            
                            self.scanProgressView.progressView.setProgress(0, animated: false)

                            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
                            break
                        }
                    }
                }
            }
        }
    }
    
    @objc func timerAction() {
        timer.invalidate()
        self.sharedInstance.stopScanPeripheral()
        self.sharedInstance.delegate = nil
        
        if tagNameArray.count == 0{
        self.scanProgressView.hide(navItem: self.navigationItem)
        self.scanProgressView.progressView.setProgress(0, animated: false)

        let alertVC = UIAlertController(title: "Alert", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)

        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        }
        else if tagNameArray.count == 1{

            let dic = tagNameArray[0] as! NSDictionary
            let periName = dic.value(forKey: "PeripheralName") as! String
            let peripheral = dic.value(forKey: "Peripheral") as! CBPeripheral

            self.syncTag(tagName: periName, peripheral: peripheral)
        }
        else{
            // Show List
            self.scanProgressView.hide(navItem: self.navigationItem)
            self.scanProgressView.progressView.setProgress(0, animated: false)

            tableContainerView.isHidden = false
            tagTableView.delegate = self
            tagTableView.dataSource = self
            tagTableView.reloadData()
        }
    }
    
    func syncTag(tagName: String, peripheral: CBPeripheral) {
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            
            self.scanProgressView.progressView.setProgress(50, animated: true)

            var golfBagArray = NSMutableArray()
            self.editView.isHidden = true
            self.defaultView.isHidden = false
            
            if(snapshot.value != nil){
                
                golfBagArray = snapshot.value as! NSMutableArray
                
                let tagNameTempArray = NSMutableArray()
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "tag") as! Bool == true){
                        tagNameTempArray.add(dict.value(forKey: "tagName") as! String)
                    }
                }
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        
                        if (dict.value(forKey: "tag") as! Bool == true){
                            let golfBagDict = NSMutableDictionary()
                            golfBagDict.setObject("Titleiest", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("43", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("2.3", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                            
                            golfBagArray.replaceObject(at: i, with: golfBagDict)
                            let golfBagData = ["golfBag": golfBagArray]
                            
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            
                            self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                            self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                            
                            for j in 0..<self.commanBagArray.count{
                                if self.selectedBagStr == self.commanBagArray[j] {
                                    
                                    let indexPath = IndexPath(row: j, section: 0)
                                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                        else{break}
                                    cell.golfImage.layer.borderWidth = 0.0
                                    cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                                    cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                                }
                            }
                            self.sharedInstance.delegate = nil
                            return
                        }
                        else{
                            if !(tagNameTempArray.contains(tagName)){
                                let last2Char = Int(tagName.suffix(3))
                                
                                let golfBagDict = NSMutableDictionary()
                                golfBagDict.setObject("Titleiest", forKey: "brand" as NSCopying)
                                golfBagDict.setObject("43", forKey: "clubLength" as NSCopying)
                                golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                                golfBagDict.setObject("2.3", forKey: "loftAngle" as NSCopying)
                                golfBagDict.setObject(true, forKey: "tag" as NSCopying)
                                golfBagDict.setObject(tagName, forKey: "tagName" as NSCopying)
                                golfBagDict.setObject(last2Char!, forKey: "tagNum" as NSCopying)
                                
                                golfBagArray.replaceObject(at: i, with: golfBagDict)
                                let golfBagData = ["golfBag": golfBagArray]
                                
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                                
                                self.btnSyncTag.backgroundColor = UIColor.glfWarmGrey
                                self.btnSyncTag.setTitle("Desync Tags", for: .normal)
                                
                                for j in 0..<self.commanBagArray.count{
                                    if self.selectedBagStr == self.commanBagArray[j] {
                                        
                                        let indexPath = IndexPath(row: j, section: 0)
                                        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                            else{break}
                                        cell.golfImage.layer.borderWidth = 2.0
                                        cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                                        cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                                    }
                                }
                                
                                self.sharedInstance.connectedPeripheral = peripheral
                                self.sharedInstance.stopScanPeripheral()
                                //self.sharedInstance.connectPeripheral(peripheral)
                                self.scanProgressView.progressView.setProgress(100, animated: true)
                                self.scanProgressView.hide(navItem: self.navigationItem)
                            }
                            else{
                                let alertVC = UIAlertController(title: "Alert", message: "Tag is already used, Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                                    self.dismiss(animated: true, completion: nil)
                                })
                                alertVC.addAction(action)
                                self.present(alertVC, animated: true, completion: nil)
                                
                                self.scanProgressView.hide(navItem: self.navigationItem)
                                self.sharedInstance.stopScanPeripheral()
                                self.sharedInstance.delegate = nil
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    func calculateSectionInset() -> CGFloat { // should be overridden
        return 75
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        collectionViewFlowLayout.itemSize = CGSize(width: collectionView.collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionView.collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionView.collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        return Int(round(proportionalOffset))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            pageControl.currentPage = snapToIndex
            selectedBagStr = commanBagArray[snapToIndex]
            
            if (self.bagMArray.contains(self.selectedBagStr)){
                self.btnAddToBag.isHidden = true
                //syncStackView.isHidden = false //commented by Amit
                
                editView.isHidden = false
                defaultView.isHidden = true
            }
            else{
                syncStackView.isHidden = true
                self.btnAddToBag.isHidden = false
                
                editView.isHidden = true
                defaultView.isHidden = false
            }
            
            for j in 0..<syncdArray.count{
                if selectedBagStr == syncdArray[j] as! String{
                    let indexPath = IndexPath(row: snapToIndex, section: 0)
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                        else{break}
                    cell.golfImage.layer.borderWidth = 2.0
                    cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                    cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                    
                    //                    editView.isHidden = true
                    //                    defaultView.isHidden = false
                    return
                }
            }
            for j in 0..<syncdArray.count{
                if !(selectedBagStr == syncdArray[j] as! String){
                    let indexPath = IndexPath(row: snapToIndex, section: 0)
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                        else{break}
                    cell.golfImage.layer.borderWidth = 0.0
                    cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                    cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                    
                    //                    editView.isHidden = false
                    //                    defaultView.isHidden = true
                    return
                }
            }
            let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        }
        else {
            // This is a much better to way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            if indexPath.row >= 0 && commanBagArray.count > indexPath.row{
                pageControl.currentPage = indexPath.row
                selectedBagStr = commanBagArray[indexPath.row]
                collectionView.collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                if (self.bagMArray.contains(self.selectedBagStr)){
                    self.btnAddToBag.isHidden = true
                    //syncStackView.isHidden = false //commented by Amit
                    
                    editView.isHidden = true
                    defaultView.isHidden = false
                }
                else{
                    syncStackView.isHidden = true
                    self.btnAddToBag.isHidden = false
                    
                    editView.isHidden = false
                    defaultView.isHidden = true
                }
                
                for j in 0..<syncdArray.count{
                    if selectedBagStr == syncdArray[j] as! String{
                        let indexPath = IndexPath(row: indexPath.row, section: 0)
                        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                            else{break}
                        cell.golfImage.layer.borderWidth = 2.0
                        cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                        cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                        
                        //editView.isHidden = true
                        //defaultView.isHidden = false
                        return
                    }
                }
                for j in 0..<syncdArray.count{
                    if !(selectedBagStr == syncdArray[j] as! String){
                        let indexPath = IndexPath(row: indexPath.row, section: 0)
                        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                            else{break}
                        cell.golfImage.layer.borderWidth = 0.0
                        cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                        cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                        
                        //editView.isHidden = false
                        //defaultView.isHidden = true
                        return
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commanBagArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! GolfBagCollectionCell
        cell.golfTitle.text = commanBagArray[indexPath.row]
        cell.golfImage.image = UIImage(named: commanBagArray[indexPath.row])
//        if cell.golfImage.image == nil {
//            cell.golfImage.image = UIImage(named: "TempBag")
//        }
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: golfBagStr)
    }
}
extension GolfBagTabsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //variable type is inferred
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)

        let dic = tagNameArray[indexPath.row] as! NSDictionary
        cell.textLabel?.text = dic.value(forKey: "PeripheralName") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableContainerView.isHidden = true
        
        self.scanProgressView.show(navItem: self.navigationItem)
        
        let dic = tagNameArray[indexPath.row] as! NSDictionary
        let periName = dic.value(forKey: "PeripheralName") as! String
        let peripheral = dic.value(forKey: "Peripheral") as! CBPeripheral
        
        self.syncTag(tagName: periName, peripheral: peripheral)
        
        tagTableView.delegate = nil
        tagTableView.dataSource = nil
    }
}


