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
import UICircularProgressRing
import ActionSheetPicker_3_0
class AssignTabsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider, BluetoothDelegate {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var stackViewAvgDist: UIStackView!
    @IBOutlet weak var btnAvgDistance: UIButton!
    @IBOutlet weak var lblTagName: UILocalizedLabel!
    var scanProgressView: UIView!
    var btnNoTag: UIButton!
    var btnRetry: UIButton!
    var btnCancel:UIButton!
    
    weak var tagCircularView: CircularProgress!
    var lblScanStatus: UILabel!
    var lblScanInfo: UILabel!
    var clubImageView:UIImageView!
    
    let progressView = SDLoader()
    @IBOutlet weak var btnSyncTag: UIButton!
    var selectedBagStr = String()
    var clubs = NSMutableDictionary()
    var golfBagArr = NSMutableArray()
    
    var beconArray = [NSMutableDictionary]()
    var golfBagDriverArray = [String]()
    var golfBagWoodArray = [String]()
    var golfBagHybridArray = [String]()
    var golfBagIronArray = [String]()
    var golfBagWageArray = [String]()
    var golfBagPuttArray = [String]()
    var commanBagArray = [String]()
    var tagsIn5Sec = NSMutableDictionary()
    var golfBagStr = String()
    var indexOfCellBeforeDragging = 0
    var sharedInstance: BluetoothSync!
//    var golfBagArr = NSMutableArray()

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: golfBagStr)
    }
    @objc func btnContinueAction(){
//        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "command"))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSyncTag.layer.cornerRadius = 3.0
        self.btnSyncTag.backgroundColor = UIColor.glfBluegreen
        
//        NotificationCenter.default.addObserver(self, selector: #selector(btnContinueAction), name: NSNotification.Name(rawValue: "command"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "command"))
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
        if self.selectedBagStr.contains("Pu"){
            self.stackViewAvgDist.isHidden = true
            self.btnAvgDistance.isHidden = true
        }
        for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
            for i in 0..<self.golfBagArr.count{
                if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                    let avg = dict.value(forKey: "avgDistance") as! Int
                    self.btnAvgDistance.setTitle("\(avg)", for: .normal)
                    //                        self.btnAvgDistance.setTitle("\(BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2)))", for: .normal)
                    
                    break
                }
            }
//            self.btnAvgDistance.setTitle("\(BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2)))", for: .normal)
        }
        
        pageControl.numberOfPages = commanBagArray.count
        collectionViewFlowLayout.minimumLineSpacing = 0
        
        if let isSync = clubs.value(forKey: selectedBagStr) as? Bool{
        updateSyncBtnWithout(isSync:isSync)
        }
        if commanBagArray.count == 1{
            pageControl.isHidden = true
        }
        else{
            pageControl.isHidden = false
        }
        
        if scanProgressView != nil{
            self.tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
            scanProgressView.removeFromSuperview()
        }
        setUpTagData()
    }
    func setupScanUI(){
        self.scanProgressView = (Bundle.main.loadNibNamed("ScanProgressView", owner: self, options: nil)![0] as! UIView)
        self.scanProgressView.frame = self.view.bounds
        self.view.addSubview(self.scanProgressView)

        btnNoTag = (scanProgressView.viewWithTag(111) as! UIButton)
        btnNoTag.layer.cornerRadius = btnNoTag.frame.size.height/2
        
        btnRetry = (scanProgressView.viewWithTag(222) as! UIButton)
        btnRetry.addTarget(self, action: #selector(self.retryAction(_:)), for: .touchUpInside)
        btnRetry.layer.cornerRadius = 3.0
        
        btnCancel = (scanProgressView.viewWithTag(333) as! UIButton)
        btnCancel.addTarget(self, action: #selector(self.cancelTagAction(_:)), for: .touchUpInside)
        btnCancel.isHidden = true
        
        tagCircularView = (scanProgressView.viewWithTag(444) as! CircularProgress)
        tagCircularView.progressColor = UIColor.glfBluegreen
        tagCircularView.trackColor = UIColor.clear
        tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
        tagCircularView.progressLayer.lineWidth = 3.0
        
        lblScanStatus = (scanProgressView.viewWithTag(555) as! UILabel)
        
        clubImageView = (scanProgressView.viewWithTag(666) as! UIImageView)
        clubImageView.image =  UIImage(named: selectedBagStr)
        
        lblScanInfo = (scanProgressView.viewWithTag(777) as! UILabel)
    }
    
    func enableSubViews(){
        let thePresenter = (self.navigationController?.visibleViewController)!
        if (thePresenter.isKind(of:ButtonBarPagerTabStripViewController.self)) {
            thePresenter.view.isUserInteractionEnabled = true
        }
        if (thePresenter.isKind(of:AssignTagVC.self)) {
            thePresenter.navigationItem.rightBarButtonItem?.isEnabled = true
            thePresenter.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    func disableSubViews(){
        let thePresenter = (self.navigationController?.visibleViewController)!
        if (thePresenter.isKind(of:ButtonBarPagerTabStripViewController.self)) {
            thePresenter.view.isUserInteractionEnabled = false
        }
        if (thePresenter.isKind(of:AssignTagVC.self)) {
            thePresenter.navigationItem.rightBarButtonItem?.isEnabled = false
            thePresenter.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func cancelTagAction(_ sender: UIButton!) {
        scanProgressView.removeFromSuperview()
        enableSubViews()
    }
    
    @objc func retryAction(_ sender: UIButton) {
        if scanProgressView != nil{
            self.tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
            scanProgressView.removeFromSuperview()
            enableSubViews()
        }
        syncTagAction(btnSyncTag)
    }
    
    @IBAction func selectAvdDistance(_ sender: Any) {
        var rangeArr = [Int]()
        var avg = 0
        for i in 0..<self.golfBagArr.count{
            if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                avg = dict.value(forKey: "avgDistance") as! Int
                break
            }
        }
//        for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
//            avg = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
//        }
        debugPrint("avg:",avg)
        if avg > 0{
            let min = BackgroundMapStats.getDataInTermOf5(data:Int((avg * 50)/100))
            let max = BackgroundMapStats.getDataInTermOf5(data:Int((avg * 150)/100))
            var i = min
            while i < max{
                rangeArr.append(i)
                i += 5
            }
            ActionSheetStringPicker.show(withTitle: "Choose Average Distance", rows: rangeArr.reversed(), initialSelection: rangeArr.reversed().firstIndex(of: avg)!, doneBlock: {
                picker, value, index in
                self.btnAvgDistance.setTitle("\(index!)", for: .normal)
                for i in 0..<self.golfBagArr.count{
                    if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                        for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                            Constants.isTagSetupModified = true
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":index!])
                            dict.setValue(index!, forKey: "avgDistance")
                        }
                    }
                }
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: sender)
        }

        
    }
//    func setUpData(){
//
//        self.progressView.show(atView: self.view, navItem: self.navigationItem)
//        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
//            self.progressView.hide(navItem: self.navigationItem)
//
//            if(snapshot.value != nil){
//                self.golfBagArr = NSMutableArray()
//                self.golfBagArr = snapshot.value as! NSMutableArray
//                self.setUpTagData()
//            }
//        }
//    }
    
    func setUpTagData(){
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        if self.golfBagArr.count > 0{
            for i in 0..<self.golfBagArr.count{
                if let dict = self.golfBagArr[i] as? NSDictionary{
                    if let tag = dict.value(forKey: "tag") as? Bool{
                        self.lblTagName.text = "None"
                        self.lblTagName.textColor = UIColor.black.withAlphaComponent(0.5)
                        self.btnSyncTag.setTitle("Sync Tag", for: .normal)
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
                        if tag{
                            if let tagName = dict.value(forKey: "tagName") as? String{
                                if self.selectedBagStr == dict.value(forKey: "clubName") as? String{
                                    self.lblTagName.text = tagName
                                    self.lblTagName.textColor = UIColor.glfBluegreen

                                    self.btnSyncTag.setTitle("Unsync Tag", for: .normal)

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
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        /*collectionView.reloadData()
        collectionView.layoutIfNeeded()
        var tag = false
        var tagName = String()
        if self.golfBagArr.count > 0{
            for i in 0..<self.golfBagArr.count{
                if let dict = self.golfBagArr[i] as? NSDictionary{
                    if self.selectedBagStr == dict.value(forKey: "clubName") as? String {
                        tag = dict.value(forKey: "tag") as! Bool
                        tagName = dict.value(forKey: "tagName") as! String
                        break
                    }
                    //                    if let boolTag = dict.value(forKey: "tag") as? Bool{
                    //                        tag = boolTag
                    //                    }
                }
            }
            
            if tag{
                //if let tagName = dict.value(forKey: "tagName") as? String{
                //if self.selectedBagStr == dict.value(forKey: "clubName") as? String{
                self.lblTagName.text = tagName
                self.lblTagName.textColor = UIColor.glfBluegreen
                self.btnSyncTag.setTitle("Unsync Tag", for: .normal)
                
                for j in 0..<self.commanBagArray.count{
                if self.selectedBagStr == self.commanBagArray[j] {
                
                let indexPath = IndexPath(row: j, section: 0)
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                else{
                    return
                    }
                cell.golfImage.layer.borderWidth = 2.0
                cell.golfImage.layer.borderColor = UIColor.glfBluegreen75.cgColor
                cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                break
                }
                }
                //break
                //}
                //}
            }
            else{
                self.lblTagName.text = "None"
                self.lblTagName.textColor = UIColor.black.withAlphaComponent(0.5)
                self.btnSyncTag.setTitle("Sync Tag", for: .normal)
                for j in 0..<self.commanBagArray.count{
                if self.selectedBagStr == self.commanBagArray[j] {
                
                let indexPath = IndexPath(row: j, section: 0)
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? GolfBagCollectionCell
                else{
                    break
                    }
                cell.golfImage.layer.borderWidth = 0.0
                cell.golfImage.layer.borderColor = UIColor.clear.cgColor
                cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2
                 break
                }
                }
            }
            //}
            //}
            //}
        }*/
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    func updateSyncBtnWithout(isSync:Bool){
        if(isSync){
            self.btnSyncTag.setTitle("Unsync Tag", for: .normal)
        }else{
            self.btnSyncTag.setTitle("Sync Tag", for: .normal)
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
            self.setupScanUI()
            
            self.tagsIn5Sec.removeAllObjects()
            sharedInstance = BluetoothSync.getInstance()
            sharedInstance.delegate = self
            sharedInstance.initCBCentralManager()
            
            DispatchQueue.main.async {
                self.lblScanStatus.text = "Waiting for tag..."
                self.lblScanInfo.text = "Press the tag button\nfor 2 seconds and release."
                self.btnRetry.isHidden = true
                self.btnNoTag.isHidden = true
                
                self.disableSubViews()
            }
            DispatchQueue.main.async(execute: {
                self.tagCircularView.setProgressWithAnimation(duration: 7.0, value: 1.0)
                self.perform(#selector(self.animateProgress), with: nil, afterDelay: 7.0)
            })
        }else{
            self.btnSyncTag.setTitle("Sync Tag", for: .normal)
            self.lblTagName.text = "None"
            self.lblTagName.textColor = UIColor.black.withAlphaComponent(0.5)

            if(club != nil){
                clubs.setValue(true, forKey: club!)
                bagDict.setValue(false, forKey: "tag")
                bagDict.setValue("", forKey: "tagName")
                bagDict.setValue("", forKey: "tagNum")
                golfBagArr[index] = bagDict
                Constants.isTagSetupModified = true
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["golfBag":golfBagArr]) { (error, ref) in
                    self.setUpTagData()
                }
            }
        }
    }

    @objc func animateProgress() {

            self.sharedInstance.stopScanPeripheral()
            self.sharedInstance.delegate = nil
            
            let data = self.tagsIn5Sec.allKeys as! [String]
            let ordered = data.sorted()
            debugPrint(self.tagsIn5Sec)
            if !ordered.isEmpty{
                if let name = (self.tagsIn5Sec.value(forKey: "\(ordered.first!)") as! CBPeripheral).name{
                    
                    self.syncTag(tagName: name, peripheral: (self.tagsIn5Sec.value(forKey: "\(ordered.first!)") as! CBPeripheral))
                    
                }else{
                    self.lblScanStatus.text = "Sync Failed"
                    self.lblScanInfo.text = "Unable to detect tag.\nPlease try again."
                    tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
                    self.btnRetry.isHidden = false
                    self.btnNoTag.isHidden = false
                    self.btnCancel.isHidden = false
                    debugPrint("Please try again.")
                    enableSubViews()
                }
            }else{
                self.lblScanStatus.text = "Sync Failed"
                self.lblScanInfo.text = "Unable to detect tag.\nPlease try again."
                tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
                self.btnRetry.isHidden = false
                self.btnNoTag.isHidden = false
                self.btnCancel.isHidden = false
                self.view.makeToast("No tag found, Please try again")
                enableSubViews()
            }
    }

    @IBAction func syncTagAction(_ sender: UIButton) {
        debugPrint(selectedBagStr)
        var isSync = true
        self.beconArray.removeAll()
        if(sender.currentTitle == "Unsync Tag"){
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
            for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                for i in 0..<self.golfBagArr.count{
                    if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                        let avg = dict.value(forKey: "avgDistance") as! Int
                        self.btnAvgDistance.setTitle("\(avg)", for: .normal)
                        break
                    }
                }
            }
            if let isSync = clubs.value(forKey: selectedBagStr) as? Bool{
            updateSyncBtnWithout(isSync:isSync)
            }
            setUpTagData()
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
                for data in Constants.clubWithMaxMin where data.name == self.selectedBagStr{
                    for i in 0..<self.golfBagArr.count{
                        if let dict = self.golfBagArr[i] as? NSDictionary, (dict.value(forKey: "clubName") as! String).contains(self.selectedBagStr){
                            let avg = dict.value(forKey: "avgDistance") as! Int
                            self.btnAvgDistance.setTitle("\(avg)", for: .normal)
                            break
                        }
                    }
                }
                if let isSync = clubs.value(forKey: selectedBagStr) as? Bool{
                updateSyncBtnWithout(isSync:isSync)
                }
                setUpTagData()

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
        
        cell.golfImage.layer.borderWidth = 0.0
        cell.golfImage.layer.borderColor = UIColor.clear.cgColor
        cell.golfImage.layer.cornerRadius = cell.golfImage.frame.size.height/2

        return cell
    }
    
    // MARK: syncTag
    func syncTag(tagName: String, peripheral: CBPeripheral) {

        let tagNumTempArray = NSMutableArray()
        var tagNameTempArray = [Int]()

        for i in 0..<golfBagArr.count{
            let dict = golfBagArr[i] as! NSDictionary
            if (dict.value(forKey: "tag") as! Bool == true){
                tagNumTempArray.add(dict.value(forKey: "tagNum") as! String)
                let tagName = (dict.value(forKey: "tagName") as! String)
                let dropFirst4 = String(tagName.dropFirst(4))
                tagNameTempArray.append(Int(dropFirst4)!)
            }
        }
        tagNameTempArray = tagNameTempArray.sorted()
        var tagNameInt = 0
        if tagNameTempArray.count == 0{
            tagNameInt = tagNameInt + 1
        }
        else{
        for i in 0..<tagNameTempArray.count{
            let tag = tagNameTempArray[i]
            if tag == i + 1{
               tagNameInt = tag + 1
               
            }
            else{
               tagNameInt = i + 1
                break
            }
        }
    }
        if tagNumTempArray.count < 14{
            let dropFirst3 = String(tagName.dropFirst(3))
            
            if !(tagNumTempArray.contains(dropFirst3)){
                
                for i in 0..<self.golfBagArr.count{
                    let dict = self.golfBagArr[i] as! NSDictionary
                    if (dict.value(forKey: "clubName") as! String == self.selectedBagStr){
                        
                        let golfBagDict = NSMutableDictionary()
                        golfBagDict.setObject("", forKey: "brand" as NSCopying)
                        golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                        golfBagDict.setObject(self.selectedBagStr, forKey: "clubName" as NSCopying)
                        golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                        golfBagDict.setObject(true, forKey: "tag" as NSCopying)
                        golfBagDict.setObject("Tag \(tagNameInt)", forKey: "tagName" as NSCopying)
                        golfBagDict.setObject(dropFirst3, forKey: "tagNum" as NSCopying)
                        golfBagDict.setObject(dict.value(forKey: "avgDistance") as! Int, forKey: "avgDistance" as NSCopying)
                        
                        self.golfBagArr.replaceObject(at: i, with: golfBagDict)
                        Constants.isTagSetupModified = true
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["golfBag": self.golfBagArr], withCompletionBlock: { (error, ref) in
                            
                            self.tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)
                            self.scanProgressView.removeFromSuperview()
                            self.enableSubViews()
                            self.setSyncData(tagName: "Tag \(tagNameInt)", peripheral: peripheral)
                            return
                        })
                    }
                }
            }
            else{
                var clubName = String()
                for i in 0..<self.golfBagArr.count{
                    let dict = self.golfBagArr[i] as! NSDictionary
                    if (dict.value(forKey: "tagNum") as! String == dropFirst3){
                        clubName = dict.value(forKey: "clubName") as! String
                        break
                    }
                }
                self.lblScanStatus.text = "Sync Failed"
                let fullClubName = getFullClubName(clubName:clubName)
                self.lblScanInfo.text = "This tag is already used\nwith \(fullClubName)."
                self.tagCircularView.setProgressWithAnimation(duration: 0.0, value: 0.0)

                self.btnRetry.isHidden = false
                self.btnNoTag.isHidden = false
                self.btnCancel.isHidden = false
                enableSubViews()
                
                self.sharedInstance.stopScanPeripheral()
                self.sharedInstance.delegate = nil
            }
        }else{
            view.makeToast("You can not sync more than 14 Tags.")
        }
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
    
    func setSyncData(tagName: String, peripheral: CBPeripheral){
        self.lblTagName.text = tagName
        self.lblTagName.textColor = UIColor.glfBluegreen

        self.btnSyncTag.setTitle("Unsync Tag", for: .normal)
        
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
        self.setUpTagData()
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

        if let newPeriName = advertisementData["kCBAdvDataLocalName"] as? String{
            if newPeriName.contains("LGX") {//||  newPeriName.contains("GGX") || newPeriName.contains("LGX"){
                tagsIn5Sec.setValue(peripheral, forKey: "\(RSSI)")
            }
        }else if let periName = peripheral.name{
            if periName.contains("LGX") {//||  periName.contains("GGX") || periName.contains("LGX"){
                tagsIn5Sec.setValue(peripheral, forKey: "\(RSSI)")
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
        scanProgressView.removeFromSuperview()
        enableSubViews()
        sharedInstance.delegate = nil
    }
}
