//
//  AssignTabsVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import XLPagerTabStrip
import CoreBluetooth
import CoreBluetooth

class AssignTabsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider, BluetoothDelegate {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblTagName: UILabel!
    @IBOutlet weak var scanProgressView: ScanProgressView!
    let progressView = SDLoader()
    @IBOutlet weak var btnSyncTag: UIButton!
    var selectedBagStr = String()
    var clubs = NSMutableDictionary()
    var golfBagArr = NSMutableArray()
    var tagClubNumber = [(tag:Int ,club:Int,clubName:String)]()
    var beconArray = [NSMutableDictionary]()
    var golfBagDriverArray = [String]()
    var golfBagWoodArray = [String]()
    var golfBagHybridArray = [String]()
    var golfBagIronArray = [String]()
    var golfBagWageArray = [String]()
    var golfBagPuttArray = [String]()
    var commanBagArray = [String]()
    
    var golfBagStr = String()
    var indexOfCellBeforeDragging = 0
    var sharedInstance: BluetoothSync!
    var timer = Timer()
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: golfBagStr)
    }
    @objc func btnContinueAction(){
        debugPrint("Continue")
        self.calculateTagWithClubNumber()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "command"))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command2"), object: tagClubNumber)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSyncTag.layer.cornerRadius = 3.0
        NotificationCenter.default.addObserver(self, selector: #selector(btnContinueAction), name: NSNotification.Name(rawValue: "command"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
        let isSync = clubs.value(forKey: selectedBagStr) as! Bool
        updateSyncBtnWithout(isSync:isSync)
        
        if commanBagArray.count == 1{
            pageControl.isHidden = true
        }
        else{
            pageControl.isHidden = false
        }
        
    }
    func calculateTagWithClubNumber(){
        tagClubNumber.removeAll()
        for j in 0..<self.golfBagArr.count{
            if let club = self.golfBagArr[j] as? NSMutableDictionary{
                if club.value(forKey: "tag") as! Bool{
                    let tagNumber = club.value(forKey: "tagNum") as! Int
                    let clubName = club.value(forKey: "clubName") as! String
                    let clubNumber = allClubs.index(of: clubName)! + 1
                    tagClubNumber.append((tag: tagNumber, club: clubNumber,clubName:clubName))
                }
            }
        }
        //        for i in 0..<allClubs.count{
        //
        //        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    func updateSyncBtnWithout(isSync:Bool){
        if(isSync){
            self.btnSyncTag.backgroundColor = UIColor.glfWarmGrey
            self.btnSyncTag.setTitle("Desync Tags", for: .normal)
        }else{
            self.btnSyncTag.backgroundColor = UIColor.glfBluegreen
            self.btnSyncTag.setTitle("Sync Tags", for: .normal)
        }
    }
    func updateSyncBtn(isSync:Bool,club:String?){
        var bagDict = NSMutableDictionary()
        var index : Int!
        if(club != nil){
            for i in 0..<golfBagArr.count{
                let bag = golfBagArr[i] as! NSMutableDictionary
                if (bag.value(forKey:"clubName") as! String) == club{
                    bagDict = bag
                    index = i
                    break
                }
            }
        }
        if(isSync){
            sharedInstance = BluetoothSync.getInstance()
            sharedInstance.delegate = self
            sharedInstance.initCBCentralManager()
            
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            
        }else{
            self.btnSyncTag.backgroundColor = UIColor.glfBluegreen
            self.btnSyncTag.setTitle("Sync Tags", for: .normal)
            if(club != nil){
                clubs.setValue(true, forKey: club!)
                bagDict.setValue(false, forKey: "tag")
                bagDict.setValue("", forKey: "tagName")
                bagDict.setValue(0, forKey: "tagNum")
                golfBagArr[index] = bagDict
                let newDict = ["golfBag":golfBagArr]
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(newDict as [AnyHashable : Any])
            }
        }
    }
    
    @objc func timerAction() {
        timer.invalidate()
        self.sharedInstance.stopScanPeripheral()
        self.sharedInstance.delegate = nil
        self.scanProgressView.hide(navItem: self.navigationItem)
        
        let alertVC = UIAlertController(title: "Alert", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func syncTagAction(_ sender: UIButton) {
        debugPrint(selectedBagStr)
        var isSync = true
        self.beconArray.removeAll()
        if(sender.currentTitle == "Desync Tags"){
            isSync = false
        }
        
        updateSyncBtn(isSync: isSync, club: selectedBagStr)
    }
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
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
            let isSync = clubs.value(forKey: selectedBagStr) as! Bool
            updateSyncBtnWithout(isSync:isSync)
            
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
                let isSync = clubs.value(forKey: selectedBagStr) as! Bool
                updateSyncBtnWithout(isSync:isSync)
                collectionView.collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
        return cell
    }
    
    // MARK: syncTag
    func syncTag(tagName: String, peripheral: CBPeripheral) {
        let tagNameTempArray = NSMutableArray()
        for i in 0..<golfBagArr.count{
            let dict = golfBagArr[i] as! NSDictionary
            if (dict.value(forKey: "tag") as! Bool == true){
                tagNameTempArray.add(dict.value(forKey: "tagName") as! String)
            }
        }
        
        for i in 0..<golfBagArr.count{
            let dict = golfBagArr[i] as! NSDictionary
            if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                
                if !(tagNameTempArray.contains(tagName)){
                    
                    let last2Char = Int(tagName.suffix(5))
                    let golfBagDict = NSMutableDictionary()
                    golfBagDict.setObject("Titleiest", forKey: "brand" as NSCopying)
                    golfBagDict.setObject("43", forKey: "clubLength" as NSCopying)
                    golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                    golfBagDict.setObject("2.3", forKey: "loftAngle" as NSCopying)
                    golfBagDict.setObject(true, forKey: "tag" as NSCopying)
                    golfBagDict.setObject(tagName, forKey: "tagName" as NSCopying)
                    golfBagDict.setObject(last2Char!, forKey: "tagNum" as NSCopying)
                    
                    golfBagArr.replaceObject(at: i, with: golfBagDict)
                    let golfBagData = ["golfBag": golfBagArr]
                    
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                    self.scanProgressView.hide(navItem: self.navigationItem)

                    self.btnSyncTag.backgroundColor = UIColor.glfWarmGrey
                    self.btnSyncTag.setTitle("Desync Tags", for: .normal)
//                    lblTagName.text = tagName
                    
                    for j in 0..<self.commanBagArray.count{
                        if self.selectedBagStr == self.commanBagArray[j] {
                            
                            let indexPath = IndexPath(row: j, section: 0)
                            guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                                else{return}
                            cell.golfImage.layer.borderWidth = 2.0
                            cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                            cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                        }
                    }
                    
                    self.sharedInstance.connectedPeripheral = peripheral
                    self.sharedInstance.stopScanPeripheral()

                    //self.sharedInstance.connectPeripheral(peripheral)
                }else{
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
    
    // MARK: Bluetooth Delegates
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
        debugPrint(advertisementData["kCBAdvDataLocalName"] as Any)
        self.scanProgressView.show(navItem: self.navigationItem)
        
        if let newPeriName = advertisementData["kCBAdvDataLocalName"] as? String{
            if newPeriName.contains("SGX") ||  newPeriName.contains("GGX") || newPeriName.contains("LGX"){
                self.syncTag(tagName: newPeriName, peripheral: peripheral)
            }
        }else if let periName = peripheral.name{
            if periName.contains("SGX") ||  periName.contains("GGX") || periName.contains("LGX"){
                self.syncTag(tagName: periName, peripheral: peripheral)
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
            }
        }
        else {
            debugPrint("No service Found")
        }
        self.scanProgressView.hide(navItem: self.navigationItem)
        sharedInstance.delegate = nil
    }
}
