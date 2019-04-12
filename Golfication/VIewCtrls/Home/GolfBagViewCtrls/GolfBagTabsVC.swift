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

class GolfBagTabsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider, BluetoothDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var brandView: UIView!
    @IBOutlet weak var avgDistView: UIView!
    @IBOutlet weak var clubLengthView: UIView!
    @IBOutlet weak var loftAngleView: UIView!
    @IBOutlet weak var shaftView: UIView!
    @IBOutlet weak var flexView: UIView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var tagTableView: UITableView!

    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnEdit: UILocalizedButton!
    @IBOutlet weak var btnSyncTag: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var btnTempAddBag: UIButton!
    @IBOutlet weak var btnTempRemoveBag: UIButton!

//    @IBOutlet weak var scanProgressView: ScanProgressView!
    @IBOutlet weak var syncStackView: UIStackView!
    @IBOutlet weak var scrlView: UIScrollView!
    
    @IBOutlet weak var lblEdit: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblAvgDistance: UILabel!
    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var lblLoft: UILabel!
    @IBOutlet weak var lblShaft: UILabel!
    @IBOutlet weak var lblFlex: UILabel!

    @IBOutlet weak var lblTagAssignedValue: UILabel!
    @IBOutlet weak var lblBrandValue: UILabel!
    @IBOutlet weak var lblAvgDistanceValue: UILabel!
    @IBOutlet weak var lblLengthValue: UILabel!

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
    var golfBagTabMArray = NSMutableArray()

    var timer = Timer()
//    var periName = ""
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    @IBAction func dismissEditPopUp(_ sender: Any){
        editView.isHidden = true
        defaultView.isHidden = false
        btnTempAddBag.isHidden = true
    }
    @IBAction func saveAction(_ sender: Any){
        FBSomeEvents.shared.singleParamFBEvene(param: "Bag Save")
        for i in 0..<golfBagTabMArray.count{
            let dic = golfBagTabMArray[i] as! NSDictionary
            if (dic.value(forKey: "clubName") as! String == selectedBagStr){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["brand":selectedBrand])
                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":Int(selectedAvgDistance)!])
                if Constants.distanceFilter == 1{
                    let val = self.getValueWithMultipleOf5(selectedLength:self.selectedLength)
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["clubLength":"\(val)"])
                }
                else{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["clubLength":selectedLength])
                }
                
                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["loftAngle":selectedLoft])
                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["shaft":selectedShaft])
                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["flex":selectedFlex])
                
                fromEdit = false
                editView.isHidden = true
                defaultView.isHidden = false
                btnTempAddBag.isHidden = true
                getGolfBagData()
                break
            }
        }
    }
    func getValueWithMultipleOf5(selectedLength:String)->Double{
        let val = (Double(selectedLength)! / 2.54).rounded(toPlaces: 2)
        let decVal = val - Double(Int(val))
        return getValue(val:val,decVal:decVal)
    }
    func getValue(val:Double,decVal:Double)->Double{
        var val = val
        if decVal < 0.125{
            val = Double(Int(val))
        }else if decVal >= 0.125 && decVal < 0.375{
            val = Double(Int(val)) + 0.25
        }else if decVal >= 0.375 && decVal < 0.625{
            val = Double(Int(val)) + 0.5
        }else if decVal >= 0.625 && decVal < 0.875{
            val = Double(Int(val)) + 0.75
        }else{
            val = Double(Int(val)) + 1
        }
        if val < 22.0{
            val = 22.0
        }
        return val
    }
    func getValueWithMultipleOf5ForNonFilter(selectedLength:String)->Double{
        let val = Double(selectedLength)!
        let decVal = val - Double(Int(val))
        return getValue(val:val,decVal:decVal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brandView.layer.borderWidth = 1.0
        brandView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        loftAngleView.layer.borderWidth = 1.0
        loftAngleView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        clubLengthView.layer.borderWidth = 1.0
        clubLengthView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        avgDistView.layer.borderWidth = 1.0
        avgDistView.layer.borderColor = UIColor.glfBlack40.cgColor
        
        shaftView.layer.borderWidth = 1.0
        shaftView.layer.borderColor = UIColor.glfBlack40.cgColor

        flexView.layer.borderWidth = 1.0
        flexView.layer.borderColor = UIColor.glfBlack40.cgColor

        btnRemove.layer.cornerRadius = 3.0
        btnEdit.layer.cornerRadius = 3.0
        btnSyncTag.layer.cornerRadius = 3.0
        btnSave.layer.cornerRadius = 3.0
        
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
//        self.scanProgressView.show(navItem: self.navigationItem)
//        self.scanProgressView.progressView.setProgress(10, animated: true)
         let periName = peripheral.name ?? ""
        if (periName.contains("GX")){
            if !(tagNameMArray.contains(periName)){
                let dic = NSMutableDictionary()
                dic.setValue(periName, forKey: "PeripheralName")
                dic.setValue(peripheral, forKey: "Peripheral")

                tagNameArray.add(dic)
//                self.scanProgressView.progressView.setProgress(30, animated: true)
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
//        self.scanProgressView.hide(navItem: self.navigationItem)
        sharedInstance.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fromEdit = false
    }
    
    var selectedLoft = String()
    var selectedLoftArr = [String]()

    var selectedLengthArr = [String]()
    var selectedLength = String()
    var selectedAvgDistance = String()
    var selectedBrand = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        editView.isHidden = true
        defaultView.isHidden = true
        btnTempAddBag.isHidden = true

        if golfBagStr == "Drivers"{
            commanBagArray = golfBagDriverArray
            btnTempRemoveBag.isEnabled = false
            btnRemove.isHidden = true
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
            btnTempRemoveBag.isEnabled = false
            btnRemove.isHidden = true
            btnEdit.isHidden = true
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
    
    @objc func tblContainerTapped(_ sender:UITapGestureRecognizer){
        for tblVIew in tableContainerView.subviews{
            if !(tblVIew.isKind(of: UITableView.self)){
                tableContainerView.isHidden = true
            }
        }
    }
    
    func getGolfBagData() {
        golfBagTabMArray = NSMutableArray()
        lblBrand.text = ""
        lblAvgDistance.text = ""
        lblLength.text = ""
        
        selectedShaft = "Steel"
        self.lblShaft.text = selectedShaft
        
        selectedFlex = "Extra Stiff"
        self.lblFlex.text = selectedFlex

        let golfBagEditPopUpData = GolfBagEditPopUpData()
        selectedLoftArr = golfBagEditPopUpData.getLoftAngleArray(clubName: self.selectedBagStr)
        selectedLoft = golfBagEditPopUpData.selectedLoft
        lblLoft.text = selectedLoft
        debugPrint("selectedLoftArr", selectedLoftArr)

        selectedLengthArr = golfBagEditPopUpData.getClubLengthArray(clubName: self.selectedBagStr)
        selectedLength = golfBagEditPopUpData.selectedLength
        debugPrint("selected",self.selectedLength)
        lblLength.text = selectedLength + " Inch"
        if Constants.distanceFilter == 1{
            lblLength.text = selectedLength + " cm"
        }
        debugPrint("selectedLengthArr", selectedLengthArr)

        self.lblLengthValue.text = "-"
        self.lblAvgDistanceValue.text = "-"
        self.lblBrandValue.text = "-"
        self.lblTagAssignedValue.text = "-"

        Constants.syncdArray = NSMutableArray()
        bagMArray = NSMutableArray()
        
        self.progressView.show(atView: self.scrlView, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
            if(snapshot.value != nil){
                self.golfBagTabMArray = snapshot.value as! NSMutableArray
                golfBagArray = snapshot.value as! NSMutableArray
                for i in 0..<golfBagArray.count{
                    if let dict = golfBagArray[i] as? NSDictionary{
                    self.bagMArray.add(dict.value(forKey: "clubName") as! String)
                    if (dict.value(forKey: "tag") as! Bool == true){
                        Constants.syncdArray.add(dict.value(forKey: "clubName") as! String)
                    }
                    // -------------------- New Code ammended by Amit ----------------------
                    if let avgDistance = dict.value(forKey: "avgDistance") as? Int{
                        if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                            self.selectedAvgDistance = "\(avgDistance)"
                            self.lblAvgDistance.text = self.selectedAvgDistance
                        }
                    }
                    else{
                        for data in Constants.clubWithMaxMin where data.name == dict.value(forKey: "clubName") as! String{
                            if (data.name).contains("Pu"){
                                dict.setValue(30, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":30])
                                if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                                    self.selectedAvgDistance = "\(30)"
                                    self.lblAvgDistance.text = self.selectedAvgDistance
                                }
                            }else if(dict.value(forKey: "avgDistance") == nil){
                                let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                dict.setValue(avgDistance, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":avgDistance])
                                if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                                    self.selectedAvgDistance = "\(avgDistance)"
                                    self.lblAvgDistance.text = self.selectedAvgDistance
                                }
                            }
                      }
                }
                    // -----------------------------------------------------------
                }
                }
                if (self.bagMArray.contains(self.selectedBagStr)){
//                    self.btnAddToBag.isHidden = true
//                    self.btnRemove.isHidden = false
                    self.selectedBrand = "Generic " + self.getFullClubName(clubName:self.selectedBagStr)
                    self.lblBrand.text = self.selectedBrand

                    if self.fromEdit{
                        self.lblEdit.text = "Edit " + self.getFullClubName(clubName:self.selectedBagStr)
                        self.editView.isHidden = false
                        self.defaultView.isHidden = true
                        self.btnTempAddBag.isHidden = true
                    }
                    else{
                        self.editView.isHidden = true
                        self.defaultView.isHidden = false
                        self.btnTempAddBag.isHidden = true
                    }
                }
                else{
//                    self.btnAddToBag.isHidden = false
//                    self.btnRemove.isHidden = true
                    self.editView.isHidden = true
                    self.defaultView.isHidden = true
                    self.btnTempAddBag.isHidden = false
                }
                /*if Constants.syncdArray.count>0{
                    for j in 0..<Constants.syncdArray.count{
                        if self.selectedBagStr == Constants.syncdArray[j] as! String{
                            
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
                }*/
                // -------------------------------------------------

                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
//                        self.syncStackView.isHidden = false //commented by Amit
                        if let tagName = dict.value(forKey: "tagName") as? String{
                            if tagName != ""{
                                self.lblTagAssignedValue.text = tagName
                            }
                        }
                        if let avgDistance = dict.value(forKey: "avgDistance") as? Int{
                            if avgDistance != 0{
                                self.lblAvgDistanceValue.text = "\(avgDistance)"
                            }
                        }
                        if let clubLength = dict.value(forKey: "clubLength") as? String{
                            if clubLength != ""{
                                self.lblLengthValue.text = clubLength + " Inch"
                                if Constants.distanceFilter == 1{
                                    self.lblLengthValue.text = "\((Double(clubLength)! * 2.54).rounded())" + " cm"
                                }
                            }
                        }
                        if let shaft = dict.value(forKey: "shaft") as? String{
                            self.selectedShaft = shaft
                            self.lblShaft.text = self.selectedShaft
                        }
                        if let brand = dict.value(forKey: "brand") as? String{
                            if brand != "" && brand != "Titleiest"{

                            self.selectedBrand = brand
                            self.lblBrand.text = self.selectedBrand
                            self.lblBrandValue.text = self.selectedBrand
                            }
                        }
                        if let flex = dict.value(forKey: "flex") as? String{
                            self.selectedFlex = flex
                            self.lblFlex.text = self.selectedFlex
                        }
                        if let loftAngle = dict.value(forKey: "loftAngle") as? String{
                            if loftAngle != "" && loftAngle != "2.3"{
                                self.selectedLoft = loftAngle
                                self.lblLoft.text = self.selectedLoft
                            }
                        }
                        if let clubLength = dict.value(forKey: "clubLength") as? String{
                            if clubLength != "" && clubLength != "43"{
                                self.selectedLength = clubLength
                                debugPrint("self.selectedLength",self.selectedLength)
                                self.lblLength.text = self.selectedLength + " Inch"
                                if Constants.distanceFilter == 1{
                                    self.selectedLength = "\((Double(clubLength)! * 2.54).rounded())"
                                    debugPrint("self.selectedLength",self.selectedLength)
                                    self.lblLength.text = self.selectedLength + " cm"
                                }
                            }
                        }
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
    var selectedFlex = String()
    var selectedFlexArr = ["Extra Stiff", "Stiff", "Senior", "Regular", "Ladies"]
    @IBAction func flexAction(_ sender: Any){
        for i in 0..<selectedFlexArr.count{
            if selectedFlexArr[i] == selectedFlex{
                ActionSheetStringPicker.show(withTitle: "Flex", rows: selectedFlexArr, initialSelection: i, doneBlock: {
                    picker, value, index in
                    self.selectedFlex = "\(index!)"
                    self.lblFlex.text = self.selectedFlex
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
                
                break
            }
        }
    }
    var selectedShaft = String()
    var selectedShaftArr = ["Steel", "Graphite"]
    @IBAction func shaftAction(_ sender: Any){
        for i in 0..<selectedShaftArr.count{
            if selectedShaftArr[i] == selectedShaft{
        ActionSheetStringPicker.show(withTitle: "Shaft", rows: selectedShaftArr, initialSelection: i, doneBlock: {
            picker, value, index in
            
            self.selectedShaft = "\(index!)"
            self.lblShaft.text = self.selectedShaft
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
                break
            }
        }
    }
    @IBAction func loftAngleAction(_ sender: Any){
        for i in 0..<selectedLoftArr.count{
            if selectedLoftArr[i] == selectedLoft{

        ActionSheetStringPicker.show(withTitle: "Loft Angle", rows: selectedLoftArr, initialSelection: i, doneBlock: {
            picker, value, index in
            
            self.selectedLoft = "\(index!)"
            self.lblLoft.text = self.selectedLoft

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
                
            break
            }
        }
    }
    @IBAction func clubLengthAction(_ sender: Any){
        for i in 0..<selectedLengthArr.count{
            if selectedLengthArr[i] == selectedLength{
                
            var unit = " Inch"
            if Constants.distanceFilter == 1{
                unit = " cm"
            }
        ActionSheetStringPicker.show(withTitle: "Club Length in\(unit)", rows: selectedLengthArr, initialSelection: i, doneBlock: {
            picker, value, index in
            
            self.selectedLength = "\(index!)"
            debugPrint(self.selectedLength)
            self.lblLength.text = self.selectedLength + unit

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
            break
        }
    }
}
    @IBAction func avgDistanceAction(_ sender: Any) {
        var rangeArr = [Int]()
        var avg = Int(selectedAvgDistance)!
        debugPrint("avg:",avg)
        if avg > 0{
            if avg == 5{
                for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                    avg = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                }
            }
            let min = BackgroundMapStats.getDataInTermOf5(data:Int((avg * 50)/100))
            let max = BackgroundMapStats.getDataInTermOf5(data:Int((avg * 150)/100))
            var i = min
            while i < max{
                rangeArr.append(i)
                i += 5
            }
            ActionSheetStringPicker.show(withTitle: "Average Distance", rows: rangeArr.reversed(), initialSelection: rangeArr.reversed().firstIndex(of: avg)!, doneBlock: {
                picker, value, index in
//                self.btnAvgDistance.setTitle("\(index!)", for: .normal)
                self.selectedAvgDistance = "\(index!)"
                self.lblAvgDistance.text = self.selectedAvgDistance

                //commented by Amit
                /*for i in 0..<self.golfBagArr.count{
                    if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                        for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                            Constants.isTagSetupModified = true
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":index!])
                            dict.setValue(index!, forKey: "avgDistance")
                        }
                    }
                }*/
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: sender)
        }
    }
    
    @IBAction func chooseBrandAction(_ sender: Any){
        ActionSheetStringPicker.show(withTitle: "Club Brand", rows: [selectedBrand], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            self.selectedBrand = "\(index!)"
            self.lblBrand.text = self.selectedBrand

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
        FBSomeEvents.shared.singleParamFBEvene(param: "Bag Remove Club")
        self.progressView.show(atView: self.scrlView, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
//            self.editView.isHidden = true
//            self.defaultView.isHidden = true
            
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
                        self.getGolfBagData()
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Bag Add Club")
        self.progressView.show(atView: self.scrlView, navItem: self.navigationItem)
        let tempBagArray = NSMutableArray()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)
            
            var golfBagArray = NSMutableArray()
            self.editView.isHidden = true
            self.defaultView.isHidden = false
            self.btnTempAddBag.isHidden = true
            
            if(snapshot.value != nil){
                golfBagArray = snapshot.value as! NSMutableArray
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    tempBagArray.add(dict.value(forKey: "clubName") as! String)
                }
            }
            DispatchQueue.main.async(execute: {
                if golfBagArray.count<14{
                if !(tempBagArray.contains(self.selectedBagStr)){
                    let golfBagDict = NSMutableDictionary()
                    golfBagDict.setObject(self.selectedBrand, forKey: "brand" as NSCopying)
                    if Constants.distanceFilter == 1{
                        let val = self.getValueWithMultipleOf5(selectedLength: self.selectedLength)
                        golfBagDict.setObject("\(val)", forKey: "clubLength" as NSCopying)
                    }
                    else{
                        golfBagDict.setObject(self.selectedLength, forKey: "clubLength" as NSCopying)
                    }
                    golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                    golfBagDict.setObject(self.selectedLoft, forKey: "loftAngle" as NSCopying)
                    golfBagDict.setObject(self.selectedShaft, forKey: "shaft" as NSCopying)
                    golfBagDict.setObject(self.selectedFlex, forKey: "flex" as NSCopying)
                    golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                    
                    // ------------------------- Calculate Avg Distance --------------------------------
                    for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                        if (data.name).contains("Pu"){
                            golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                        }
                        else{
                            let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                            golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                        }
                    }
                    // ----------------------------------------

                    golfBagArray.insert(golfBagDict, at: 0)
                    let golfBagData = ["golfBag": golfBagArray]
                    
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                    
//                    self.syncStackView.isHidden = false //commented by Amit
                    self.btnSyncTag.backgroundColor = UIColor.glfBluegreen75
                    self.btnSyncTag.setTitle("Sync Tags", for: .normal)
                    
                    self.getGolfBagData()
                }
            }
                else{
                    self.editView.isHidden = true
                    self.defaultView.isHidden = true
                    self.btnTempAddBag.isHidden = false

                    let alertVC = UIAlertController(title: "Alert", message: "You can not add more than 14 clubs.", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alertVC.addAction(action)
                    self.present(alertVC, animated: true, completion: nil)

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
                Constants.syncdArray = NSMutableArray()

                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "tag") as! Bool == true){
                        self.tagNameMArray.add(dict.value(forKey: "tagName") as! String)
                        Constants.syncdArray.add(dict.value(forKey: "clubName") as! String)
                    }
                }
                for i in 0..<golfBagArray.count{
                    let dict = golfBagArray[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        
//                        if (dict.value(forKey: "tag") as! Bool == true){
                        if Constants.syncdArray.contains(self.selectedBagStr){
                            let golfBagDict = NSMutableDictionary()
                            golfBagDict.setObject("", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                            
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
                            
//                            self.scanProgressView.progressView.setProgress(0, animated: false)

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
//        self.scanProgressView.hide(navItem: self.navigationItem)
//        self.scanProgressView.progressView.setProgress(0, animated: false)

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
//            self.scanProgressView.hide(navItem: self.navigationItem)
//            self.scanProgressView.progressView.setProgress(0, animated: false)

            tableContainerView.isHidden = false
            tagTableView.delegate = self
            tagTableView.dataSource = self
            tagTableView.reloadData()
        }
    }
    
    func syncTag(tagName: String, peripheral: CBPeripheral) {
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            
//            self.scanProgressView.progressView.setProgress(50, animated: true)

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
                            golfBagDict.setObject("", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                            
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
                                let last2Char = Int(tagName.suffix(5))
                                
                                let golfBagDict = NSMutableDictionary()
                                golfBagDict.setObject("", forKey: "brand" as NSCopying)
                                golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                                golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                                golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
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
//                                self.scanProgressView.progressView.setProgress(100, animated: true)
//                                self.scanProgressView.hide(navItem: self.navigationItem)
                            }
                            else{
                                let alertVC = UIAlertController(title: "Alert", message: "Tag is already used, Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                                    self.dismiss(animated: true, completion: nil)
                                })
                                alertVC.addAction(action)
                                self.present(alertVC, animated: true, completion: nil)
                                
//                                self.scanProgressView.hide(navItem: self.navigationItem)
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
            
            let golfBagEditPopUpData = GolfBagEditPopUpData()
            selectedLoftArr = golfBagEditPopUpData.getLoftAngleArray(clubName: self.selectedBagStr)
            debugPrint("selectedLoftArr", selectedLoftArr)
            
            selectedLengthArr = golfBagEditPopUpData.getClubLengthArray(clubName: self.selectedBagStr)
            debugPrint("selectedLengthArr", selectedLengthArr)

            self.lblEdit.text = "Edit " + self.getFullClubName(clubName:self.selectedBagStr)

            for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                for i in 0..<self.golfBagTabMArray.count{
                    if let dict = self.golfBagTabMArray[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                        let avg = dict.value(forKey: "avgDistance") as! Int
                        selectedAvgDistance = "\(avg)"
                        self.lblAvgDistance.text = selectedAvgDistance
//                        self.btnAvgDistance.setTitle("\(avg)", for: .normal)
                        break
                    }
                }
            }
            for i in 0..<self.golfBagTabMArray.count{
                if let dict = self.golfBagTabMArray[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                    self.lblLengthValue.text = "-"
                    self.lblAvgDistanceValue.text = "-"
                    self.lblBrandValue.text = "-"
                    self.lblTagAssignedValue.text = "-"

                    if let tagName = dict.value(forKey: "tagName") as? String, dict.value(forKey: "tagName") as! String != "" {
                        self.lblTagAssignedValue.text = tagName
                    }
                    if let brand = dict.value(forKey: "brand") as? String, dict.value(forKey: "brand") as! String != "", dict.value(forKey: "brand") as! String != "Titleiest"{
                        self.lblBrandValue.text = brand
                    }
                    if let avgDistance = dict.value(forKey: "avgDistance") as? Int, dict.value(forKey: "avgDistance") as! Int != 0{
                        self.lblAvgDistanceValue.text = "\(avgDistance)"
                    }
                    if let clubLength = dict.value(forKey: "clubLength") as? String, dict.value(forKey: "clubLength") as! String != ""{
                        self.lblLengthValue.text = clubLength + " Inch"
                        if Constants.distanceFilter == 1{
                            self.lblLengthValue.text = "\((Double(clubLength)! * 2.54).rounded())" + " cm"
                        }
                    }
                    break
                }
            }

            if (self.bagMArray.contains(self.selectedBagStr)){
//                self.btnAddToBag.isHidden = true
//                self.btnRemove.isHidden = false
//                syncStackView.isHidden = false //commented by Amit
                
                self.editView.isHidden = true
                self.defaultView.isHidden = false
                self.btnTempAddBag.isHidden = true
            }
            else{
                syncStackView.isHidden = true
//                self.btnAddToBag.isHidden = false
//                self.btnRemove.isHidden = true
                
                self.editView.isHidden = true
                self.defaultView.isHidden = true
                self.btnTempAddBag.isHidden = false
            }
            
            /*for j in 0..<Constants.syncdArray.count{
                if selectedBagStr == Constants.syncdArray[j] as! String{
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
            for j in 0..<Constants.syncdArray.count{
                if !(selectedBagStr == Constants.syncdArray[j] as! String){
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
            }*/
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
                
                let golfBagEditPopUpData = GolfBagEditPopUpData()
                selectedLoftArr = golfBagEditPopUpData.getLoftAngleArray(clubName: self.selectedBagStr)
                debugPrint("selectedLoftArr", selectedLoftArr)
                
                selectedLengthArr = golfBagEditPopUpData.getClubLengthArray(clubName: self.selectedBagStr)
                debugPrint("selectedLengthArr", selectedLengthArr)

                self.lblEdit.text = "Edit " + self.getFullClubName(clubName:self.selectedBagStr)

                for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                    for i in 0..<self.golfBagTabMArray.count{
                        if let dict = self.golfBagTabMArray[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                            let avg = dict.value(forKey: "avgDistance") as! Int
//                            self.btnAvgDistance.setTitle("\(avg)", for: .normal)
                            selectedAvgDistance = "\(avg)"
                            self.lblAvgDistance.text = selectedAvgDistance
                            break
                        }
                    }
                }
                for i in 0..<self.golfBagTabMArray.count{
                    if let dict = self.golfBagTabMArray[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                        self.lblLengthValue.text = "-"
                        self.lblAvgDistanceValue.text = "-"
                        self.lblBrandValue.text = "-"
                        self.lblTagAssignedValue.text = "-"
                        
                        if let tagName = dict.value(forKey: "tagName") as? String, dict.value(forKey: "tagName") as! String != "" {
                            self.lblTagAssignedValue.text = tagName
                        }
                        if let brand = dict.value(forKey: "brand") as? String, dict.value(forKey: "brand") as! String != "", dict.value(forKey: "brand") as! String != "Titleiest"{
                            self.lblBrandValue.text = brand
                        }
                        if let avgDistance = dict.value(forKey: "avgDistance") as? Int, dict.value(forKey: "avgDistance") as! Int != 0{
                            self.lblAvgDistanceValue.text = "\(avgDistance)"
                        }
                        if let clubLength = dict.value(forKey: "clubLength") as? String, dict.value(forKey: "clubLength") as! String != ""{
                            self.lblLengthValue.text = clubLength + " Inch"
                            if Constants.distanceFilter == 1{
                                self.lblLengthValue.text = "\((Double(clubLength)! * 2.54).rounded())" + " cm"
                            }
                        }
                        break
                    }
                }
                collectionView.collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                if (self.bagMArray.contains(self.selectedBagStr)){
//                    self.btnAddToBag.isHidden = true
//                    self.btnRemove.isHidden = false

//                    syncStackView.isHidden = false //commented by Amit
                    
                    self.editView.isHidden = true
                    self.defaultView.isHidden = false
                    self.btnTempAddBag.isHidden = true
                }
                else{
                    syncStackView.isHidden = true
//                    self.btnAddToBag.isHidden = false
//                    self.btnRemove.isHidden = true

                    self.editView.isHidden = true
                    self.defaultView.isHidden = true
                    self.btnTempAddBag.isHidden = false
                }
                
                /*for j in 0..<Constants.syncdArray.count{
                    if selectedBagStr == Constants.syncdArray[j] as! String{
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
                for j in 0..<Constants.syncdArray.count{
                    if !(selectedBagStr == Constants.syncdArray[j] as! String){
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
                }*/
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
        
//        self.scanProgressView.show(navItem: self.navigationItem)
        
        let dic = tagNameArray[indexPath.row] as! NSDictionary
        let periName = dic.value(forKey: "PeripheralName") as! String
        let peripheral = dic.value(forKey: "Peripheral") as! CBPeripheral
        
        self.syncTag(tagName: periName, peripheral: peripheral)
        
        tagTableView.delegate = nil
        tagTableView.dataSource = nil
    }
}


