//
//  PracticePageContainerVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import ActionSheetPicker_3_0
import FirebaseAuth
class PracticePageContainerVC: ButtonBarPagerTabStripViewController,UITableViewDelegate,UITableViewDataSource, DemoFooterViewDelegate, BluetoothDelegate {
    @IBOutlet weak var shadowView: UIView!
    var shotsArray = [String]()
    @IBOutlet weak var barBtnBLE: UIBarButtonItem!
    @IBOutlet weak var barBtnMenu: UIBarButtonItem!
    
    @IBOutlet weak var swingDetailsView: UIView!
    @IBOutlet weak var swingTableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    let kHeaderSectionTag: Int = 6900
    var holeShot = [(key:String,hole:Int,shot:Int)]()
    var parStrokesG = [(hole:Int,par:Int,strkG:String)]()
    var holeParStrokesG = [(hole:Int,par:Int,strkG:[String])]()
    var holeInSection = [Int]()
    var isDemoStats = Bool()
    var sharedInstance: BluetoothSync!

    @IBAction func backAction(_ sender: Any) {
        if(swingDetailsView.isHidden){
            if superClassName == "SwingSessionVC"{
                swingDetailsView.isHidden = false
                //                self.navigationController?.popViewController(animated: true)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            if superClassName == "SwingSessionVC"{
                self.navigationController?.popViewController(animated: true)
            }else{
                swingDetailsView.isHidden = true
            }
            
        }
    }
    var swingKey = String()
    var tempArray1 = NSArray()
    var isFirst = false
    var count:Int!
    var superClassName : String!
    var fromRoundsPlayed = Bool()
    var swingId = String()
    var currentGameId = Int()
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.glfBluegreen
        settings.style.buttonBarItemFont = UIFont(name: "SFProDisplay-Medium", size: 14.0)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        super.viewDidLoad()
        
        superClassName = NSStringFromClass((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].classForCoder)!).components(separatedBy: ".").last!
        if superClassName == "SwingSessionVC"{
            self.swingDetailsView.isHidden = false
            self.navigationItem.rightBarButtonItems = nil
            
        }else{
            UIApplication.shared.isIdleTimerDisabled = true
            self.swingDetailsView.isHidden = true
            NotificationCenter.default.addObserver(self, selector: #selector(self.showShotsAfterSwing(_:)), name: NSNotification.Name(rawValue: "getSwingInside"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPopUp(_:)), name: NSNotification.Name(rawValue: "practiceFinished"), object: nil)
            self.moveToViewController(at: shotsArray.count-1)
        }
        debugPrint("tempArray1==",tempArray1)
        self.reloadTableWithStrokesGained()
        NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
        
        if isDemoStats{
            setDemoFotter()
        }
    }
    func setDemoFotter(){
        let demoView = DemoFooterView()
        demoView.frame = CGRect(x: 0.0, y: self.view.frame.height-55.0, width: self.view.frame.width, height: 55.0)
        demoView.delegate = self
        demoView.backgroundColor = UIColor.glfFlatBlue
        demoView.label.frame = CGRect(x: 10, y: demoView.frame.size.height/2-22, width: demoView.frame.width * 0.7, height: 44.0)
        demoView.btnPlayGame.frame = CGRect(x:demoView.frame.width - demoView.frame.width * 0.25 - 10, y: demoView.frame.size.height/2-15, width: demoView.frame.width * 0.25, height: 30.0)
        self.view.addSubview(demoView)
        
        demoView.label.text = "Get your swing stats with Golfication X"
        demoView.label.textAlignment = .left
        demoView.label.textColor = UIColor.white
        demoView.btnPlayGame.setTitle("Connect Now", for: .normal)
    }
    
    func playGameButton(button: UIButton) {
        self.sharedInstance = BluetoothSync.getInstance()
        self.sharedInstance.delegate = self
        self.sharedInstance.initCBCentralManager()
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
            
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.sharedInstance.delegate = nil
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
            self.sharedInstance.delegate = nil
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func reloadTableWithStrokesGained(){
        let group = DispatchGroup()
        for data in self.holeShot{
            group.enter()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(data.key)/scoring/\(data.hole)") { (snapshot) in
                var parVal = 0
                var strokesGainedVal = "-"
                if(snapshot.value != nil){
                    if let da = snapshot.value as? NSMutableDictionary{
                        if let par = da.value(forKey: "par") as? Int{
                            debugPrint("par",par)
                            parVal = par
                        }
                        let dictiona = da.value(forKey: Auth.auth().currentUser!.uid) as! NSMutableDictionary
                        if let shots = dictiona.value(forKey: "shots") as? NSArray{
                            if shots.count > data.shot{
                                if let shotDict = shots[data.shot] as? NSMutableDictionary{
                                    if let strokesGained = shotDict.value(forKey: "strokesGained") as? Double{
                                        debugPrint("strokesGained:",strokesGained)
                                        if strokesGained > 0{
                                            strokesGainedVal = "+ \(strokesGained.rounded(toPlaces: 2))"
                                        }else{
                                            strokesGainedVal = "\(strokesGained.rounded(toPlaces: 2))"
                                        }
                                    }
                                }
                            }
                        }
                        self.parStrokesG.append((hole:data.hole,par: parVal, strkG: strokesGainedVal))
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            debugPrint(self.parStrokesG)
            var numberOfSection = [Int]()
            for data in self.holeShot{
                numberOfSection.append(data.hole)
                self.holeInSection.append(data.hole)
            }
            self.holeInSection = self.holeInSection.removeDuplicates()
            for i in 0..<self.holeInSection.count{
                self.holeParStrokesG.append((hole: self.holeInSection[i], par: 0, strkG: [String]()))
                for d in self.parStrokesG{
                    if d.hole == self.holeInSection[i]{
                        self.holeParStrokesG[i].par = d.par
                        self.holeParStrokesG[i].strkG.append(d.strkG)
                    }
                }
            }
            debugPrint(self.holeParStrokesG)
            self.swingTableView.reloadData()
            
            if self.fromRoundsPlayed{
                let imgView = UIImageView()
                self.expandedSectionHeaderNumber = 0
                self.tableViewExpandSection(0, imageView: imgView)
            }

        }
    }
    @objc func chkBluetoothStatus(_ notification: NSNotification) {
        let notifBleStatus = notification.object as! String
        if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_ON"){
            //            self.setInitialDeviceData()
        }
        else{
            if self.barBtnBLE != nil{
                self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
            }
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
    }
    @IBAction func barBtnBLEAction(_ sender: Any) {
        if (self.barBtnBLE.image == #imageLiteral(resourceName: "golficationBarG")){
            Constants.ble = BLE()
            Constants.ble.startScanning()
            Constants.ble.currentGameId = self.currentGameId
            Constants.ble.swingMatchId = self.swingId
            Constants.ble.isPracticeMatch = true
        }
    }
    
    @IBAction func barBtnMenuAction(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Menu", rows: ["Finish","View All"], initialSelection: 0, doneBlock: { (picker, value, index) in
            if(value == 0){
                debugPrint("Finished")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
            }else if(value == 1){
                debugPrint("ViewALL")
                self.swingDetailsView.isHidden = false
            }
            
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin:sender)
    }
    //MARK: PracticeMatchFinished
    @objc func finishedPopUp(_ notification:NSNotification){
        self.backAction(Any.self)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "practiceFinished"))
    }
    //MARK: showShotsAfterSwing
    @objc func showShotsAfterSwing(_ notification:NSNotification){
        if let dict = notification.object as? NSMutableDictionary{
            Constants.ble.playSound()
            let swingKey = dict.value(forKey: "id") as! String
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/") { (snapshot) in
                var dict = NSMutableDictionary()
                if let diction = snapshot.value as? NSMutableDictionary{
                    dict = diction
                }
                DispatchQueue.main.async(execute: {
                    let swingArr = dict.value(forKey: "swings") as! NSArray
                    var shotsAr = [String]()
                    for i in 0..<swingArr.count{
                        shotsAr.append("Shot \(i+1)")
                    }
                    self.shotsArray = shotsAr
                    self.tempArray1 = swingArr
                    self.isFirst = false
                    self.moveToViewController(at: shotsAr.count-1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.reloadPagerTabStripView()
                        self.moveToViewController(at: shotsAr.count-1)
                    })
                })
            }
        }
    }
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        if playButton != nil{
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        superClassName = NSStringFromClass((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].classForCoder)!).components(separatedBy: ".").last!
        if !isFirst{
            isFirst = true
            shotsArray.append("Shot \(shotsArray.count+1)")
            if superClassName == "SwingSessionVC"{
                shotsArray.removeLast()
            }
        }
        
        let myArray = NSMutableArray()
        myArray.addObjects(from: shotsArray)
        var finalArray = NSMutableArray()
        finalArray = myArray.mutableCopy() as! NSMutableArray
        for i in 0..<tempArray1.count{
            let swingDetails = tempArray1[i] as! NSMutableDictionary
            if let club = swingDetails.value(forKey: "club") as? String{
                if club == "Pu"{
                    finalArray.removeObject(at: i)
                    break
                }
            }
        }
        var array = [UIViewController]()
        for i in 0..<finalArray.count{
            let storyboard = UIStoryboard(name: "Device", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "PracticeSessionVC") as! PracticeSessionVC
            viewCtrl.shotNumStr = finalArray[i] as! String
            viewCtrl.shotsArray = finalArray as! [String]
            viewCtrl.count = self.count
            viewCtrl.superClassName = superClassName
            if(i < tempArray1.count){
                viewCtrl.swingDetails = tempArray1[i] as! NSMutableDictionary
            }
            array.append(viewCtrl)
        }
        return array
    }
    
    // MARK: - Tableview Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if fromRoundsPlayed{
            if (self.expandedSectionHeaderNumber == section) {
                if superClassName != "SwingSessionVC"{
                    return shotsArray.count-1
                }else{
                    return self.holeParStrokesG[section].strkG.count
                }
            }
            else {
                return 0
            }
        }
        else{
            if superClassName != "SwingSessionVC"{
                return shotsArray.count-1
            }else{
                return shotsArray.count
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if fromRoundsPlayed{
            return holeInSection.count
            /*if sectionNames.count > 0 {
             tableView.backgroundView = nil
             return sectionNames.count
             } else {
             let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
             messageLabel.text = "Retrieving data.\nPlease wait."
             messageLabel.numberOfLines = 0;
             messageLabel.textAlignment = .center;
             messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
             messageLabel.sizeToFit()
             self.swingTableView.backgroundView = messageLabel
             }*/
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(66.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fromRoundsPlayed{
            return 44.0
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.10)
        
        let label = UILabel()
        
        label.frame = CGRect(x: 10, y: 0, width: 200, height: 44.0)
        label.text = "Hole - \(self.holeParStrokesG[section].hole+1) Par \(self.holeParStrokesG[section].par)"
        label.textColor = UIColor.glfBluegreen
        header.addSubview(label)
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.swingTableView.frame.size
        
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swingTableViewCell", for: indexPath) as! SwingTableViewCell
        var index = indexPath.item
        if fromRoundsPlayed{
            var totalIndex = 0
            for i in 0..<self.holeParStrokesG.count{
                if i == indexPath.section{
                    totalIndex += indexPath.row
                    break
                }else{
                    totalIndex += self.holeParStrokesG[i].strkG.count
                }
            }
            index = totalIndex
        }
        if let swingDetails = tempArray1[index] as? NSMutableDictionary{
            if fromRoundsPlayed{
                cell.lblTitle.text = "Shot \(swingDetails.value(forKey: "shotNum") as! Int)"
                let strkGain = holeParStrokesG[indexPath.section].strkG[indexPath.row]
                var color = UIColor.glfRosyPink
                if strkGain.contains("+"){
                    color = UIColor.glfBluegreen
                }else if strkGain == "-"{
                    color = UIColor.glfWarmGrey
                }
                let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : color]
                let dict2: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfFlatBlue]
                let dict3: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                
                let attributedText = NSMutableAttributedString()
                if let club = swingDetails.value(forKey: "club") as? String{
                    attributedText.append(NSAttributedString(string: "\(club == "" ? "Driver":BackgroundMapStats.getClubName(club: club))", attributes: dict2))
                }else{
                    attributedText.append(NSAttributedString(string:"Driver"))
                }
                attributedText.append(NSAttributedString(string: "              StrokesGained  ",attributes:dict3))
                attributedText.append(NSAttributedString(string: "\(strkGain)", attributes: dict1))
                cell.lblSubtitle.attributedText = attributedText
            }
            else{
                cell.lblTitle.text = "Swing \(indexPath.item+1)"
                if let club = swingDetails.value(forKey: "club") as? String{
                    cell.lblSubtitle.text = BackgroundMapStats.getClubName(club: club)
                }
            }
            if let time = swingDetails.value(forKey: "timestamp") as? Int64{
                debugPrint(time)
                let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en")
                dateFormatter.dateFormat = "HH:mm"
                let strDate = dateFormatter.string(from: date)
                cell.lblTimeStamp.text = "\(strDate)"
            }else{
                cell.lblTimeStamp.text = "No Time Available"
            }
            if let swingScore = swingDetails.value(forKey: "swingScore") as? Double{
                cell.lblScore.text = "\(Int(swingScore))"
            }
            if let club = swingDetails.value(forKey: "club") as? String{
                if club == "Pu"{
                    cell.backgroundColor = UIColor.glfWarmGrey.withAlphaComponent(0.5)
                    cell.lblScore.text = "N/A"
                    cell.lblScore.textColor = UIColor.glfWarmGrey
                }else{
                    cell.backgroundColor = UIColor.glfWhite
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fromRoundsPlayed{
            var sectioncount = 0
            for i in 0..<(indexPath.section == 0 ? 1:indexPath.section){
                sectioncount += self.holeParStrokesG[i].strkG.count
            }
            sectioncount += indexPath.row
            if self.holeParStrokesG.count == 1{
                sectioncount = indexPath.row
            }
            if let swingDetails = tempArray1[sectioncount] as? NSMutableDictionary{
                if let club = swingDetails.value(forKey: "club") as? String{
                    if club != "Pu"{
                        self.moveToViewController(at: sectioncount)
                        self.swingDetailsView.isHidden = true
                    }
                }
            }
        }
        else{
            if let swingDetails = tempArray1[indexPath.item] as? NSMutableDictionary{
                if let club = swingDetails.value(forKey: "club") as? String{
                    if club != "Pu"{
                        self.moveToViewController(at: indexPath.item)
                        self.swingDetailsView.isHidden = true
                    }
                }
            }
        }
    }
    
    // MARK: - Expand / Collapse Methods
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        
        let headerView = sender.view!
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            }
            else {
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        
        let sectionData = self.holeParStrokesG[section].strkG as NSArray
        self.expandedSectionHeaderNumber = -1
        if (sectionData.count == 0) {
            return
        }
        else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.swingTableView!.beginUpdates()
            self.swingTableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.swingTableView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        
        let sectionData = self.holeParStrokesG[section].strkG as NSArray
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1
            return
        }
        else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.swingTableView!.beginUpdates()
            self.swingTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.swingTableView!.endUpdates()
        }
    }
}
