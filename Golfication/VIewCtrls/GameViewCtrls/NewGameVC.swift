//
//  NewGameVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 04/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import ActionSheetPicker_3_0
import FirebaseAnalytics
import UserNotifications
import CTShowcase
import CoreBluetooth
import UICircularProgressRing
import FirebaseStorage

class NewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BluetoothDelegate{
    
    // MARK: Set Outlets
    
    @IBOutlet weak var stblfordRulesLabel: UILabel!
    @IBOutlet weak var gameTypeStackView: UIStackView!
    @IBOutlet weak var changeCourseView: CardView!
    @IBOutlet weak var lblGolfName: UILabel!
    @IBOutlet weak var lblContinueGolfName: UILabel!
    @IBOutlet weak var lblContinueHoleNum: UILabel!
    @IBOutlet weak var lblRequestMap: UILabel!
    @IBOutlet weak var lblRangeFinder: UILabel!
    @IBOutlet weak var lblShotTracker: UILabel!
    
    @IBOutlet weak var startingTeeCardView: CardView!
    @IBOutlet weak var btnDropDownTee: UIButton!
    @IBOutlet weak var lblTeeName: UILabel!
    @IBOutlet weak var lblTeeType: UILabel!
    @IBOutlet weak var lblTeeRating: UILabel!
    @IBOutlet weak var lblTeeSlope: UILabel!
    
    @IBOutlet weak var lblRequestInfo: UILabel!
    @IBOutlet weak var lblRFRequestInfo: UILabel!

    @IBOutlet var gameTypeSgmtCtrl: UISegmentedControl!
//    @IBOutlet var scoringTypeSgmtCtrl: UISegmentedControl!

    @IBOutlet weak var btnEnd: UILocalizedButton!
    @IBOutlet weak var btnOnePlayer: UIButton!
    @IBOutlet weak var btnTwoPlayer: UIButton!
    @IBOutlet weak var btnThreePlayer: UIButton!
    @IBOutlet weak var btnFourPlayer: UIButton!
    @IBOutlet weak var btnFivePlayer: UIButton!
    @IBOutlet weak var btnRcntOnePlayer: UIButton!
    @IBOutlet weak var btnRcntTwoPlayer: UIButton!
    @IBOutlet weak var btnRcntThreePlayer: UIButton!
    @IBOutlet weak var btnOtherHole: UILocalizedButton!
    @IBOutlet weak var btnOneHole: UIButton!
    @IBOutlet weak var btnTenHole: UIButton!
    @IBOutlet weak var btnMoreInfo: UIButton!
    @IBOutlet weak var btnHomeCourse: UILocalizedButton!
    @IBOutlet weak var btnNearestCourse: UILocalizedButton!

    @IBOutlet weak var btnStartContinue: UIButton!

    @IBOutlet weak var classicScoringSV: UIStackView!
//    @IBOutlet weak var newGameSV: UIStackView!
    
    @IBOutlet weak var newGamescrollView: UIScrollView!

    let progressView = SDLoader()
    @IBOutlet weak var continueGameView: UIView!
    @IBOutlet weak var golfCourseBgView: UIView!

    @IBOutlet weak var scoreTableView: UITableView!
    
    @IBOutlet weak var scoreTblHConstraint: NSLayoutConstraint!

    @IBOutlet weak var switchRangeFinder: UISwitch!
    @IBOutlet weak var switchShotTracker: UISwitch!
    @IBOutlet weak var stackRequestInfo: UIStackView!

    var barBtnBLE: UIBarButtonItem!

    let imagePicker = UIImagePickerController()
    var cameraBtn: UIButton!
    var requestSFPopupView: UIView!
    
    // MARK: Set Variables
    var isAccept = Int()
    var holeType = 0
    var holeOutCount = 0
    var currentHoleFromFirebase : Int!

    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var players = NSMutableArray()
    var btnPlayerArray = [UIButton]()
    var btnRecentArray = [UIButton]()
    var buttonscheck = [UIButton]()
    var finalMatchDic = NSMutableDictionary()
    var recentPlyrMArr = NSMutableArray()
    var golfDataMArray = [NSMutableDictionary]()
    var notifScoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var isContinueClicked = Bool()
    var gameTypePopUp = Bool()
    
    var homeCourseName = String()
    var homeCourseId = String()
    var homeCourseLat = String()
    var homeCourseLng = String()

    var gameMode = ""
//    var gameType: String = "18 holes"
    var requestedMatchId = String()
    var scoringMode = ""
    var attributedStringArray = [String]()
    var detailedScore = NSMutableArray()
    var sharedInstance: BluetoothSync!
    var timeOutTimer = Timer()

    // Marke : StartingTee Action
    var courseData = CourseData()
    @IBAction func btnActionStartingTee(_ sender: UIButton) {
        let myController = UIAlertController(title: "Select Tee", message: "Please select your Tee according to your Handicap", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let messageAttributed = NSMutableAttributedString(
            string: myController.message!,
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.glfBluegreen, NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 15.0)!])
        myController.setValue(messageAttributed, forKey: "attributedMessage")
        var i = 0
        for tee in Constants.teeArr{
            let whiteTee = (UIAlertAction(title: "\(tee.name) (\(tee.type) Tee)", style: UIAlertActionStyle.default, handler: { action in
                self.lblTeeName.text = "\(tee.name)"
                self.lblTeeType.text = "(\(tee.type) Tee)"
                self.lblTeeRating.text = tee.rating
                self.lblTeeSlope.text = tee.slope
                Constants.selectedSlope = Int(tee.slope)!
                Constants.selectedRating = tee.rating
                Constants.selectedTee = "\(tee.type)"
                Constants.selectedTeeColor = "\(tee.name)"
            }))
            myController.addAction(whiteTee)
            i += 1
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            debugPrint("Cancelled")
        })
        myController.addAction(cancelOption)
        present(myController, animated: true, completion: nil)
    }
    func getHandicap(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "handicap") { (snapshot) in
            if let handic = snapshot.value as? String{
                Constants.handicap = handic
            }
        }
    }
    // MARK: backAction
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        Constants.addPlayersArray.removeAllObjects()
    }
    
    
    var golfXPopupView: UIView!
    var btnRetry: UIButton!
    var btnNoDevice: UIButton!
    var lblScanStatus: UILabel!
    var deviceCircularView: CircularProgress!
    var isDeviceSetup = false
    var fromGolfBarBtn = false
    // MARK: golfXAction
    @objc func golfXAction() {
        if(Constants.deviceGolficationX == nil){
            fromGolfBarBtn = true
            self.sharedInstance = BluetoothSync.getInstance()
            self.sharedInstance.delegate = self
            self.sharedInstance.initCBCentralManager()
        }
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
            if(Constants.deviceGolficationX == nil) && fromGolfBarBtn{
               fromGolfBarBtn = false
            if Constants.ble == nil{
                Constants.ble = BLE()
                Constants.ble.isPracticeMatch = false
                NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
            }
            Constants.ble.startScanning()
            showPopUp()
            }
//            self.sharedInstance.delegate = nil
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
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if golfXPopupView != nil{
           self.golfXPopupView.removeFromSuperview()
        }
        fromGolfBarBtn = false
        self.timeOutTimer.invalidate()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "Scanning_Time_Out"))

        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
//            self.sharedInstance.delegate = nil
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
    }
    
    func setGofXUISetup(){
        btnNoDevice = (golfXPopupView.viewWithTag(111) as! UIButton)
        btnNoDevice.layer.cornerRadius = btnNoDevice.frame.size.height/2
        
        btnRetry = (golfXPopupView.viewWithTag(222) as! UIButton)
        btnRetry.addTarget(self, action: #selector(self.retryAction(_:)), for: .touchUpInside)
        btnRetry.layer.cornerRadius = 3.0
        
        let btnCancel = golfXPopupView.viewWithTag(333) as! UIButton
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
        Constants.ble.stopScanning()
    }
    
    @objc func SeventyFivePercentUpdated(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.50, toValue: 0.75)
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "75_Percent_Updated"))
        })
    }
    @objc func updateScreen(_ notification: NSNotification){
        self.timeOutTimer.invalidate()
        DispatchQueue.main.async(execute: {
            self.deviceCircularView.setProgressWithAnimationGolfX(duration: 1.0, fromValue: 0.75, toValue: 1.0)
            self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
        })
    }
    @objc func animateProgress() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.golfXPopupView.removeFromSuperview()
        if Constants.ble == nil{
           Constants.ble = BLE()
        }
        Constants.ble.stopScanning()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        updateScreenBLE()
    }
    func updateScreenBLE(){
        self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBar")
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.view.makeToast("Device is connected.")
    }
    @objc func retryAction(_ sender: UIButton) {
        if Constants.ble == nil{
            Constants.ble = BLE()
            Constants.ble.isPracticeMatch = false
            NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
        }
        Constants.ble.startScanning()
        self.golfXPopupView.removeFromSuperview()
        showPopUp()
    }
    
    @objc func chkBluetoothStatus(_ notification: NSNotification) {
        let notifBleStatus = notification.object as! String
        if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_ON"){
        }
        else{
            self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
//            Constants.ble.stopScanning()
        }
    }

    @objc func cancelGolfXAction(_ sender: UIButton!) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        golfXPopupView.removeFromSuperview()
    }
    
    @IBAction func rangeFinderChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
           scoringMode = "rangeFinder"
           lblRangeFinder.textColor = UIColor.glfBluegreen
        }
        else {
            scoringMode = "classic"
            switchShotTracker.isOn = false
            lblShotTracker.textColor = UIColor.lightGray
//            shotTrackerChanged(mySwitch: switchShotTracker)
            lblRangeFinder.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func shotTrackerChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            scoringMode = "Advanced(GPS)"
            switchRangeFinder.isOn = true
            lblRangeFinder.textColor = UIColor.glfBluegreen
            lblShotTracker.textColor = UIColor.glfBluegreen
        }
        else {
            scoringMode = "rangeFinder"
            lblShotTracker.textColor = UIColor.lightGray
        }
    }

    @objc func tapLabel(tap: UITapGestureRecognizer) {
        for attributedText in attributedStringArray {
            if attributedText == "course often"{
            guard let range = self.lblRequestInfo.text?.range(of: attributedText)?.nsRange
                else {
                return
            }
            if tap.didTapAttributedTextInLabel(label: self.lblRequestInfo, inRange: range) {
                
                if(Auth.auth().currentUser!.uid.count > 1){
                    ref.child("unmappedCourseRequest/\(Auth.auth().currentUser!.uid)/").updateChildValues([Constants.selectedGolfID:Timestamp] as [AnyHashable:Any])
                }
                let alert = UIAlertController(title: "Alert", message: "Thanks for your request. We will notify you when this course is mapped for advanced scoring.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                lblRequestMap.text = ""
                lblRequestMap.isHidden = true
                btnMoreInfo.isHidden = true
                stackRequestInfo.isHidden = true
                attributedStringArray = [String]()

                /*if scoringMode == "rangeFinder" || scoringMode == "classic"{
                    moreInfoAction(btnMoreInfo)
                }
                else{
                    if let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "CustomPopUpViewController") as? CustomPopUpViewController{
                        viewCtrl.isInfo = false
                        if scoringMode == "classic"{
                            isAdvanced = false
                        }
                        else{
                            isAdvanced = true
                        }
                        self.present(viewCtrl, animated: true, completion: nil)
                        
                        viewCtrl.btnCheckBox.isHidden = true
                        viewCtrl.lblAlwaysChoose.isHidden = true
                        viewCtrl.btnContinue.setTitle("Select", for: .normal)
                        viewCtrl.btnContinue.addTarget(self, action: #selector(self.selectScoringAction(_:)), for: .touchUpInside)
                    }
                }*/
            }
        }
    }
}

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        if(Constants.deviceGolficationX != nil){
        self.sharedInstance = BluetoothSync.getInstance()
        self.sharedInstance.delegate = self
        self.sharedInstance.initCBCentralManager()
        }
        imagePicker.delegate = self
        self.getHandicap()
        // for Bluetooth device setup
        barBtnBLE = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.golfXAction))
        barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
        self.navigationItem.rightBarButtonItem = barBtnBLE
        self.startingTeeCardView.isHidden = true
        self.stblfordRulesLabel.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(completeDeviceSetup(_:)), name: NSNotification.Name(rawValue: "setupDevice"), object: nil)
        // End Round
        NotificationCenter.default.addObserver(self, selector: #selector(self.EndRound(_:)), name: NSNotification.Name(rawValue: "EndRound"), object: nil)

        // for continue action from scorecard
        NotificationCenter.default.addObserver(self, selector: #selector(continueButtonAction(_:)), name: NSNotification.Name(rawValue: "continueAction"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMapWithBLECommands(_:)), name: NSNotification.Name(rawValue: "courseDataAPI"), object: nil)

        //Apply to the label
        btnMoreInfo.isHidden = true
        scoreTableView.allowsSelection = false
        // Close if share screen is opened
        let thePresenter = self.navigationController?.visibleViewController
        if (thePresenter?.isKind(of:ShareStatsVC.self))! {
            thePresenter?.dismiss(animated: false, completion: nil)
        }
        
        classicScoringSV.isHidden = true
        self.btnFivePlayer.isHidden = true
        
        btnRecentArray = [btnRcntOnePlayer, btnRcntTwoPlayer, btnRcntThreePlayer]
        btnPlayerArray = [btnOnePlayer, btnTwoPlayer, btnThreePlayer, btnFourPlayer, btnFivePlayer]
        
        btnPlayerArray[4].setTitle(Auth.auth().currentUser?.displayName, for: .normal)
        btnPlayerArray[4].titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        btnPlayerArray[4].setTitleColor(UIColor.black, for: .normal)
        
        Constants.selectedGolfID = ""
        Constants.selectedGolfName = ""
        Constants.selectedLat = ""
        Constants.selectedLong = ""
        
        buttonscheck.append(btnOneHole)
        buttonscheck.append(btnTenHole)
        buttonscheck.append(btnOtherHole)

        setInitialUi()
        getUserDataFromFireBase()
        if(Constants.strokesGainedDict.count == 0){
            getStrokesGainedFirebaseData()
        }
        getHomeCourse()
        
    }
    
    func getHomeCourse() {
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "homeCourseDetails") { (snapshot) in
            if(snapshot.childrenCount > 0){
                self.btnHomeCourse.isHidden = false
            }
            else{
                self.btnHomeCourse.isHidden = true
            }
         }
    }
    
    // Mark: StartShowCase
    func startShowcase(){
        if(isShowCase){
            let startGameShowCase = CTShowcaseView(title: "", message: "Hit start to begin your round." , key: "strtGame") { () -> () in
                self.startGameAction()
            }
            let highlighteStart =  startGameShowCase.highlighter as! CTStaticGlowHighlighter
            highlighteStart.highlightColor = UIColor.glfWhite
            
            let playerAddedShowCase = CTShowcaseView(title: "", message: "DeeJay have been added\nto your game." , key:"playerAdded") { () -> () in
//                self.scrollNewGame.contentOffset = .zero
                startGameShowCase.setup(for: self.btnStartContinue!, offset: .zero , margin: 0)
                startGameShowCase.show()
            }
            let highlightePlayerAdded = CTDynamicGlowHighlighter()
            highlightePlayerAdded.highlightColor = UIColor.glfWhite
            
            highlightePlayerAdded.animDuration = 0.5
            highlightePlayerAdded.glowSize = 5
            highlightePlayerAdded.highlightType = .circle
            playerAddedShowCase.continueButton.isHidden = false
            highlightePlayerAdded.maxOffset = 10
            playerAddedShowCase.highlighter = highlightePlayerAdded
            let addPlayerShowCase = CTShowcaseView(title: "", message: "Add DeeJay to your game." , key:"addPlayer") { () -> () in
                playerAddedShowCase.setup(for: self.btnOnePlayer, offset: .zero , margin: 5)
                self.btnOnePlayer.setBackgroundImage(#imageLiteral(resourceName: "dJohnson"), for: .normal)
                self.btnOnePlayer.setTitle("", for: .normal)
                playerAddedShowCase.show()
            }
            let highlighteAddPlayer = CTDynamicGlowHighlighter()
            highlighteAddPlayer.highlightColor = UIColor.glfWhite
            highlighteAddPlayer.animDuration = 0.5
            highlighteAddPlayer.glowSize = 5
            highlighteAddPlayer.maxOffset = 10
            highlighteAddPlayer.highlightType = .circle
            
            addPlayerShowCase.highlighter = highlighteAddPlayer
            let showcaseSelectHole = CTShowcaseView(title: "", message: "Start at Hole 1", key: "selectHole") { () -> () in
//                let point = CGPoint(x: 0, y: 200)
//                self.scrollNewGame.contentOffset = point
                self.startHoleAction(sender: self.btnOneHole)
                addPlayerShowCase.setup(for: self.btnRcntOnePlayer, offset: .zero , margin: 5)
                addPlayerShowCase.show()
            }
            let highlighter1 = CTDynamicGlowHighlighter()
            highlighter1.highlightColor = UIColor.glfWhite
            highlighter1.animDuration = 0.5
            highlighter1.glowSize = 5
            highlighter1.maxOffset = 10
            showcaseSelectHole.highlighter = highlighter1
            let showcaseGameType = CTShowcaseView(title: "", message: "Start a 9-hole or 18-hole round.", key: "gameType") { () -> () in

                self.startHoleAction(sender: self.btnOneHole)
                addPlayerShowCase.setup(for: self.btnRcntOnePlayer, offset: .zero , margin: 5)
                addPlayerShowCase.show()
            }
            let highlighter2 = CTDynamicGlowHighlighter()
            // Configure its parameters if you don't like the defaults
            highlighter2.highlightColor = UIColor.glfWhite
            highlighter2.animDuration = 0.5
            highlighter2.glowSize = 5
            highlighter2.maxOffset = 10
            showcaseGameType.highlighter = highlighter2
            
            let showcaseChooseCourse = CTShowcaseView(title: "", message: "Confirm this course to proceed.", key:"chooseCourse") { () -> () in
                showcaseGameType.setup(for: self.gameTypeStackView!, offset: .zero , margin: 5)
                showcaseGameType.show()
            }
            if(isShowCase){
//                self.gameTypeSgmtCtrl.selectedSegmentIndex = 1
                btnTenHole.backgroundColor = UIColor(rgb: 0x008F63)
                btnTenHole.setTitleColor(UIColor.white, for: .normal)
                self.btnRcntOnePlayer.setBackgroundImage(#imageLiteral(resourceName: "dJohnson"), for: .normal)
                
            }
            let highlighter = showcaseChooseCourse.highlighter as! CTStaticGlowHighlighter
            highlighter.highlightColor = UIColor.glfWhite
            showcaseChooseCourse.setup(for: self.changeCourseView, offset: .zero , margin: 5)
            showcaseChooseCourse.show()
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        self.continueGameView.isHidden = true
        self.newGamescrollView.isHidden = true
        if Constants.selectedGolfName == ""{
            lblGolfName.text = "Select a Course"
        }
        else{
            lblGolfName.text = Constants.selectedGolfName
        }
        isAccept += 1
        self.getActiveMatches()
        selectedGameTypeFromFirebase()
        
        if(isShowCase) && Constants.matchId.count == 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
//                self.startShowcase()
            })
        }

        // --------------------------- From select course vc
        if !(Constants.selectedLat == "" && Constants.selectedLong == "") {
            let spString = Constants.selectedLat.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            if(spString.count == 2){
                Constants.selectedLat = "\(spString.first!)"
                Constants.selectedLong = "\(spString.last!)"
            }
        }
        
        // Set Add Player Title & Image
        for i in 0..<btnPlayerArray.count{
            
            if i != 4{
                btnPlayerArray[i].titleLabel?.font = UIFont.systemFont(ofSize: 35.0)
                btnPlayerArray[i].setTitleColor(UIColor.lightGray, for: .normal)
                btnPlayerArray[i].setTitle("+", for: .normal)
                btnPlayerArray[i].setBackgroundImage(nil, for: .normal)
            }
        }
        
        if Constants.addPlayersArray.count>0 {
            for i in 0..<btnRecentArray.count{
                ((btnRecentArray[i]) ).isSelected = false
            }
            for i in 0..<Constants.addPlayersArray.count{
                if ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int) == btnRcntOnePlayer.tag {
                    btnRcntOnePlayer.isSelected = true
                }
                else if ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int) == btnRcntTwoPlayer.tag {
                    btnRcntTwoPlayer.isSelected = true
                }
                else if ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int) == btnRcntThreePlayer.tag {
                    btnRcntThreePlayer.isSelected = true
                }
                let img = (Constants.addPlayersArray[i] as AnyObject).object(forKey:"image") as? String ?? ""
                if(img != ""){
                    let imgURL = URL(string:img)
                    btnPlayerArray[i].sd_setBackgroundImage(with: imgURL, for: .normal, completed: nil)
                    btnPlayerArray[i].setTitle("", for: .normal)
                    
                }else{
                    //btnPlayerArray[i].setTitle((addPlayersArray[i] as AnyObject).object(forKey:"name") as? String, for: .normal)
                }
            }
        }
        else{
            for i in 0..<btnRecentArray.count{
                btnRecentArray[i].isSelected = false
            }
        }
        // ------------------------ end -------------------------------------------
        
        if Constants.isDevice{
            self.navigationItem.rightBarButtonItem = barBtnBLE
            self.barBtnBLE.image = #imageLiteral(resourceName: "golficationBarG")
            
            if(Constants.deviceGolficationX != nil){
                updateScreenBLE()
            }
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: setInitialUi
    func setInitialUi() {
        let originalImage = #imageLiteral(resourceName: "gps_icon")
        let courseImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnNearestCourse.tintColor = UIColor.white
        btnNearestCourse.setImage(courseImage, for: .normal)
        btnNearestCourse.setTitle(" " + "Nearest Course".localized(), for: .normal)

        let originalImage1 = #imageLiteral(resourceName: "home_icon")
        let homeImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnHomeCourse.tintColor = UIColor.white
        btnHomeCourse.setImage(homeImage, for: .normal)
        btnHomeCourse.setTitle(" " + "Home Course".localized(), for: .normal)
        
        golfCourseBgView.setCornerView(color: UIColor.clear.cgColor)
        
        self.btnOnePlayer.setCircle(frame: self.btnOnePlayer.frame)
        self.btnTwoPlayer.setCircle(frame: self.btnTwoPlayer.frame)
        self.btnThreePlayer.setCircle(frame: self.btnThreePlayer.frame)
        self.btnFourPlayer.setCircle(frame: self.btnFourPlayer.frame)
        
        self.btnRcntOnePlayer.setCircle(frame: self.btnRcntOnePlayer.frame)
        self.btnRcntTwoPlayer.setCircle(frame: self.btnRcntTwoPlayer.frame)
        self.btnRcntThreePlayer.setCircle(frame: self.btnRcntThreePlayer.frame)
        
        self.btnOneHole.setCircle(frame: self.btnOneHole.frame)
        self.btnTenHole.setCircle(frame: self.btnTenHole.frame)
        self.btnOtherHole.layer.cornerRadius = 3
        if(!isShowCase){
            btnOneHole.backgroundColor = UIColor(rgb: 0x008F63)
            btnOneHole.setTitleColor(UIColor.white, for: .normal)
        }
        
        btnEnd.setTitle(" " + "End Round".localized() + " ", for: .normal)
        btnEnd.setCorner(color: UIColor(rgb: 0x7094B3).cgColor)
        
        btnRequestMapping.setCorner(color: UIColor.clear.cgColor)
        lblLegacyAppMode.isHidden = true
        golficationXView.isHidden = true
        
        playOnCourseAction(btnPlayOnCourse)
    }

    func deselectGOlfXView() {
        btnCheckBox.setCircle(frame: btnCheckBox.frame)
        btnCheckBox.backgroundColor = UIColor.lightGray
        
        golficationXView.layer.cornerRadius = 5
        golficationXView.layer.masksToBounds = false
        golficationXView.layer.shadowColor = UIColor.black.cgColor
        golficationXView.layer.shadowOffset = CGSize(width: 1, height: 1)
        golficationXView.layer.shadowOpacity = 0.15
        
        golficationXView.layer.borderWidth = 0.0
        golficationXView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: homeCourseAction
    @IBAction func homeCourseAction(_ sender: Any) {
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "homeCourseDetails") { (snapshot) in
            
            if(snapshot.value != nil){
                var homeCourseData = NSDictionary()
                homeCourseData = snapshot.value as! NSDictionary
                //// -------------------------------------------------

                    self.homeCourseId = homeCourseData.object(forKey: "id") as! String
                    self.homeCourseName = homeCourseData.object(forKey: "name") as! String
                    self.homeCourseLng = homeCourseData.object(forKey: "lng") as! String
                    self.homeCourseLat = homeCourseData.object(forKey: "lat") as! String
                
                    self.lblGolfName.text = self.homeCourseName

                    Constants.selectedGolfName = self.homeCourseName
                    Constants.selectedGolfID = self.homeCourseId
                    Constants.selectedLat = self.homeCourseLat
                    Constants.selectedLong = self.homeCourseLng
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.selectedGameTypeFromFirebase()
            })
        }
    }
    
    // MARK: nearestCourseAction
    @IBAction func nearestCourseAction(_ sender: Any) {
//        let locationManager = CLLocationManager()
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        if let currentLocation: CLLocation = locationManager.location{
            self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
        }
        else{

            let alert = UIAlertController(title: "Alert", message: "Please enable GPS to get your nearest course.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: searchLocationAction
    @IBAction func searchLocationAction(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
        viewCtrl.fromNewGame = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: moreInfoAction
    @IBAction func moreInfoAction(_ sender: UIButton) {
        
        if let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "CustomPopUpViewController") as? CustomPopUpViewController{
            viewCtrl.isInfo = true
            self.present(viewCtrl, animated: true, completion: nil)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "MappingRequest"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.requestMappigNotif(_:)), name: NSNotification.Name(rawValue: "MappingRequest"), object: nil)
        }
    }
    
    @objc func requestMappigNotif(_ notification: NSNotification) {
        if(Auth.auth().currentUser!.uid.count > 1){
            ref.child("unmappedCourseRequest/\(Auth.auth().currentUser!.uid)/").updateChildValues([Constants.selectedGolfID:Timestamp] as [AnyHashable:Any])
        }
        let alert = UIAlertController(title: "Alert", message: "Thanks for your request. We will notify you this course is mapped for advanced scoring.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        lblRequestMap.text = ""
        lblRequestMap.isHidden = true
        btnMoreInfo.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "MappingRequest"), object: nil)
    }
    
    // MARK: gameTypeChanged
    @IBAction func gameTypeChanged(_ sender: UISegmentedControl) {
        switch gameTypeSgmtCtrl.selectedSegmentIndex {
        case 0:
            Constants.gameType = "18 holes"
        case 1:
            Constants.gameType = "9 holes"
        default:
            break;
        }
    }
    // MARK: startHoleAction
    @IBAction func startHoleAction(sender: AnyObject) {
        let btn = sender as! UIButton
        
        for getbutton in buttonscheck {
            getbutton.backgroundColor = UIColor.lightGray
            getbutton.setTitleColor(UIColor.black, for: .normal)
            
            if (getbutton.tag == 3) && !(btn.tag == 3){
                getbutton.setTitle("Other".localized(), for: .normal)
            }
        }
        btn.backgroundColor = UIColor(rgb: 0x008F63)
        btn.setTitleColor(UIColor.white, for: .normal)
        
        if btn.tag == 3 {
            
            self.otherHoleAction(sender)
        }
        else{
            Constants.startingHole = String(btn.tag)
        }
    }

    func otherHoleAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        ActionSheetStringPicker.show(withTitle: "Choose Starting Hole", rows: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18"], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            Constants.startingHole = "\(value+1)"
            
            btn.setTitle(Constants.startingHole, for: .normal)
            btn.backgroundColor = UIColor(rgb: 0x008F63)
            btn.setTitleColor(UIColor.white, for: .normal)
            
            for getbutton in self.buttonscheck {
                getbutton.backgroundColor = UIColor.lightGray
                getbutton.setTitleColor(UIColor.black, for: .normal)
                
                if Constants.startingHole == "1" && getbutton.tag == 1{
                    getbutton.backgroundColor = UIColor(rgb: 0x008F63)
                    getbutton.setTitleColor(UIColor.white, for: .normal)
                    btn.setTitle("Other".localized(), for: .normal)
                    
                }
                else if Constants.startingHole == "10" && getbutton.tag == 10{
                    getbutton.backgroundColor = UIColor(rgb: 0x008F63)
                    getbutton.setTitleColor(UIColor.white, for: .normal)
                    btn.setTitle("Other".localized(), for: .normal)
                    
                }
                else{
                    if getbutton.tag == 3 && !(Constants.startingHole == "1") && !(Constants.startingHole == "10"){
                        
                        getbutton.backgroundColor = UIColor(rgb: 0x008F63)
                        getbutton.setTitleColor(UIColor.white, for: .normal)
                    }
                }
            }
            
            return
        }, cancel: { ActionStringCancelBlock in
            
            for getbutton in self.buttonscheck {
                
                if Constants.startingHole == "1" && getbutton.tag == 1{
                    getbutton.backgroundColor = UIColor(rgb: 0x008F63)
                    getbutton.setTitleColor(UIColor.white, for: .normal)
                }
                else if Constants.startingHole == "10" && getbutton.tag == 10{
                    getbutton.backgroundColor = UIColor(rgb: 0x008F63)
                    getbutton.setTitleColor(UIColor.white, for: .normal)
                }
                else{
                    if getbutton.tag == 3 && (getbutton.titleLabel?.text == "Other".localized()){
                        getbutton.backgroundColor = UIColor.lightGray
                        getbutton.setTitleColor(UIColor.black, for: .normal)
                    }
                }
            }
            return
            
        }, origin: sender)
    }
    
    // MARK: addPlayerAction
    @IBAction func addPlayerAction(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: getActiveMatches
    func getActiveMatches(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "activeMatches") { (snapshot) in
            let group = DispatchGroup()
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            for data in dataDic{
                group.enter()
                if(data.value){
                    Constants.matchId = data.key
//                    let object = BackgroundMapStats()
//                    object.getScoreFromMatchDataFirebase(keyId: data.key)
                }else if(!data.value){
                    self.requestedMatchId = data.key
                }
                group.leave()
            }
            group.notify(queue: .main){
//                self.progressView.hide(navItem: self.navigationItem)
                self.setActiveMatchUI()
                self.getDeletedMAtch()
            }
        }
    }
    var allDeletedMatchID = [String]()
    func getDeletedMAtch(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "deletedMatches") { (snapshot) in
            var dict = NSMutableDictionary()
            if snapshot.value != nil{
                dict = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                if dict.count != 0{
                    self.allDeletedMatchID = dict.allKeys as! [String]
                }
                if self.allDeletedMatchID.contains(Constants.matchId){
                    Constants.isEdited = true
                }else{
                    Constants.isEdited = false
                }
            })
        }
    }
    // MARK: getStrokesGainedFirebaseData
    func getStrokesGainedFirebaseData(){
        
        let group = DispatchGroup()
        for i in 0..<Constants.strkGainedString.count{
            group.enter()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: Constants.strkGainedString[i]) { (snapshot) in
                Constants.strokesGainedDict.append(snapshot.value as! NSMutableDictionary)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            
        }
    }
    
    // MARK: getUserDataFromFireBase
    func getUserDataFromFireBase() {
        let myLocation = CLLocation()
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            
            if(snapshot.childrenCount > 0){
                var userData = NSDictionary()
                userData = snapshot.value as! NSDictionary
                //// -------------------------------------------------
                if !(isShowCase){
                    if let lastCourseDic = userData.object(forKey: "lastCourseDetails") as? NSDictionary{
                        Constants.selectedGolfID = lastCourseDic.object(forKey: "id") as! String
                        Constants.selectedGolfName = lastCourseDic.object(forKey: "name") as! String
                        Constants.selectedLong = lastCourseDic.object(forKey: "lng") as! String
                        Constants.selectedLat = lastCourseDic.object(forKey: "lat") as! String
                        
                        self.lblGolfName.text = Constants.selectedGolfName
                        
                        if !(Constants.selectedLat == "" && Constants.selectedLong == "") {
                            let spString = Constants.selectedLat.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                            if(spString.count == 2){
                                Constants.selectedLat = "\(spString.first!)"
                                Constants.selectedLong = "\(spString.last!)"
                            }
                        }
//                        self.getNearByData(latitude: Double(selectedLat)!, longitude: Double(selectedLong)!, currentLocation: myLocation)
                        
                            self.selectedGameTypeFromFirebase()
                            self.setActiveMatchUI()
                    }
                    else if let homeCourseDic = userData.object(forKey: "homeCourseDetails") as? NSDictionary{
                        self.homeCourseId = homeCourseDic.object(forKey: "id") as! String
                        self.homeCourseName = homeCourseDic.object(forKey: "name") as! String
                        self.homeCourseLng = homeCourseDic.object(forKey: "lng") as! String
                        self.homeCourseLat = homeCourseDic.object(forKey: "lat") as! String
                        
                        Constants.selectedGolfName = self.homeCourseName
                        Constants.selectedGolfID = self.homeCourseId
                        Constants.selectedLat = self.homeCourseLat
                        Constants.selectedLong = self.homeCourseLng
                        
                        UserDefaults.standard.set(Constants.selectedLat, forKey: "HomeLat")
                        UserDefaults.standard.set(Constants.selectedLong, forKey: "HomeLng")
                        UserDefaults.standard.set(Constants.selectedGolfName, forKey: "HomeCourseName")
                        UserDefaults.standard.synchronize()
                        
                        self.lblGolfName.text = Constants.selectedGolfName
                        
                        if !(Constants.selectedLat == "" && Constants.selectedLong == "") {
                            let spString = Constants.selectedLat.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                            if(spString.count == 2){
                                Constants.selectedLat = "\(spString.first!)"
                                Constants.selectedLong = "\(spString.last!)"
                            }
                        }
                        if(Constants.selectedLat == "") || (Constants.selectedLong == ""){
                            let emptyAlert = UIAlertController(title: "Error", message: "Please try Again", preferredStyle: UIAlertControllerStyle.alert)
                            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                self.navigationController?.popToRootViewController(animated: false)
                            }))
                            self.present(emptyAlert, animated: true, completion: nil)
                        }else{
                            self.selectedGameTypeFromFirebase()
                            self.setActiveMatchUI()
                        }
                    }
                    else{
                        var lat =  myLocation.coordinate.latitude
                        var lng =  myLocation.coordinate.longitude
                        
                        if lat == 0 && lng == 0 {
                            //Chena Bend
                            lat = Double("64.830673")!
                            lng = Double("-147.576172")!
                        }
                        self.getNearByData(latitude: lat, longitude: lng, currentLocation: myLocation)
                    }
                }else{
                    // chenaBend
                    let lat = Double("64.830673")!
                    let lng = Double("-147.576172")!
                    self.getNearByData(latitude: lat, longitude: lng, currentLocation: myLocation)
                }

                
                // -----------------------------------------------------
                if let friendsData = userData["friends"] as? [String : Bool]{
                    let group = DispatchGroup()
                    for (key, _) in friendsData{
                        group.enter()
                        
                        self.recentPlyrMArr.removeAllObjects()
                        self.recentPlyrMArr = NSMutableArray()
                        
                        ref.child("userList/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.exists() {
                                let dataDic = (snapshot.value as? NSDictionary)!
                                let tempdic = NSMutableDictionary()
                                tempdic.setObject(key , forKey: "id" as NSCopying)
                                tempdic.setObject(dataDic.value(forKey: "name") ?? "", forKey: "name" as NSCopying)
                                tempdic.setObject(dataDic.value(forKey: "image") ?? "", forKey: "image" as NSCopying)
                                tempdic.setObject(dataDic.value(forKey: "timestamp") ?? "", forKey: "timestamp" as NSCopying)
                                self.recentPlyrMArr.add(tempdic)
                            }
                            group.leave()
                        })
                    }
                    
                    group.notify(queue: .main, execute: {
                        
                        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                        let array: NSArray = self.recentPlyrMArr.sortedArray(using: [sortDescriptor]) as NSArray
                        
                        self.recentPlyrMArr.removeAllObjects()
                        self.recentPlyrMArr = NSMutableArray()
                        self.recentPlyrMArr = array.mutableCopy() as! NSMutableArray
                        
                        self.setRecentPlayerUI()
                    })
                }
                if let gameTypeStatus = userData["gameTypePopUp"] as? Bool{
                    self.gameTypePopUp = gameTypeStatus
                }
            }
            else{
                debugPrint("There is no data.")
            }
        }
    }
    
    // MARK: getNearByData
    func getNearByData(latitude: Double, longitude: Double, currentLocation: CLLocation){

        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    // In case of -1 response
                    debugPrint("Error", error ?? "")
                    
                    self.isAccept += 1
                })
            }
            else{
                self.golfDataMArray =  [NSMutableDictionary]()
                
                let (courses) = arg0
                let group = DispatchGroup()
                
                courses?.forEach {
                    group.enter()
                    
                    let dataDic = NSMutableDictionary()
                    dataDic.setObject($0.key, forKey:"Id"  as NSCopying)
                    dataDic.setObject($0.value.Name, forKey : "Name" as NSCopying)
                    dataDic.setObject($0.value.City, forKey : "City" as NSCopying)
                    dataDic.setObject($0.value.Country, forKey : "Country" as NSCopying)
                    dataDic.setObject($0.value.Latitude, forKey : "Latitude" as NSCopying)
                    dataDic.setObject($0.value.Longitude, forKey : "Longitude" as NSCopying)
                    if($0.key != "99999999"){
                        self.golfDataMArray.append(dataDic)
                    }
                    group.leave()
                    group.notify(queue: .main) {
                        
                    }
                }
                DispatchQueue.main.async(execute: {
                    if !self.golfDataMArray.isEmpty{
                        self.golfDataMArray = BackgroundMapStats.sortAndShow(searchDataArr: self.golfDataMArray, myLocation: currentLocation)
                        Constants.selectedGolfID = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Id") as? String)!
                        Constants.selectedGolfName = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Name") as? String)!
                        Constants.selectedLong = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Longitude") as? String)!
                        Constants.selectedLat = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Latitude") as? String)!
                        self.lblGolfName.text = Constants.selectedGolfName
                        
                        self.selectedGameTypeFromFirebase()
                    }
                    self.setActiveMatchUI()
                })
            }
        }
    }
    
    // MARK: setActiveMatchUI
    func setActiveMatchUI(){
        // ------- check active match ------------------
        var isActiveMatch = false
        if(Constants.matchId.count > 1){
            isActiveMatch = true
        }
        else if(requestedMatchId.count > 1 && isAccept == 1){
            let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "StartNewGameVC") as! StartNewGameVC
            viewCtrl.matchId = requestedMatchId
            requestedMatchId = String()
            self.navigationController?.pushViewController(viewCtrl, animated: false)
        }
        if isActiveMatch{
            if(!isShowCase){
                if(Constants.matchId.count > 1){
                    self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
                }
            }
        }
        else{
            self.progressView.hide(navItem: self.navigationItem)
            //btnStartContinue.setTitle("Start Round", for: .normal) // Amit's Changes
            btnStartContinue.setTitle("Next".localized(), for: .normal)

            continueGameView.isHidden = true
            newGamescrollView.isHidden = false
        }
        btnStartContinue.isHidden = false
    }
    // MARK: selectedGameTypeFromFirebase
    func checkRangeFinderHoleData() {
        if  !(Constants.selectedGolfID == "") {
            Constants.teeArr.removeAll()
            let golfId = "course_\(Constants.selectedGolfID)"
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "golfCourses/\(golfId)/rangefinder/courseDetails") { (snapshot) in
                var rangeFinArr = [NSMutableDictionary]()
                if let rangeFin = snapshot.value as? [NSMutableDictionary]{
                    rangeFinArr = rangeFin
                }
                DispatchQueue.main.async(execute: {
                    if (rangeFinArr.isEmpty){
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "golfCourses/\(golfId)/stableford/courseDetails") { (snapshot) in
                            if let rangeFin = snapshot.value as? [NSMutableDictionary]{
                                rangeFinArr = rangeFin
                            }
                            DispatchQueue.main.async(execute: {
                                self.processSelectTee(rangeFinArr: rangeFinArr)
                            })
                        }
                    }else{
                        self.processSelectTee(rangeFinArr: rangeFinArr)
                    }
                })
            }
        }
    }
    private func processSelectTee(rangeFinArr:[NSMutableDictionary]){
        for data in rangeFinArr{
            var ratin = "N/A"
            if let rating = data.value(forKey: "courseRating") as? Double{
                ratin = "\(rating)"
            }
            var slope = 113
            if let slo = data.value(forKey: "slopeRating") as? Int{
                slope = slo
            }
            let teeName = data.value(forKey: "teeColor") as! String
            let teeType = data.value(forKey: "tee") as! String
            Constants.teeArr.append((name: teeName.capitalizingFirstLetter(), type: teeType.capitalizingFirstLetter(),rating:ratin, slope:"\(slope)"))
        }
        if(!Constants.teeArr.isEmpty){
            self.startingTeeCardView.isHidden = false
            self.stblfordRulesLabel.isHidden = false
            self.lblTeeName.text = "\(Constants.teeArr[0].name)"
            self.lblTeeType.text = "(\(Constants.teeArr[0].type) Tee)"
            self.lblTeeSlope.text = Constants.teeArr[0].slope
            self.lblTeeRating.text = Constants.teeArr[0].rating
            Constants.selectedSlope = Int(Constants.teeArr[0].slope)!
            Constants.selectedRating = Constants.teeArr[0].rating
            Constants.selectedTee = Constants.teeArr[0].type
            Constants.selectedTeeColor = Constants.teeArr[0].name
        }else{
            Constants.selectedTee = ""
            Constants.selectedTeeColor = ""
            Constants.selectedSlope = 0
            Constants.selectedRating = ""
            self.startingTeeCardView.isHidden = true
            self.stblfordRulesLabel.isHidden = true
        }
    }
    // MARK: selectedGameTypeFromFirebase
    func selectedGameTypeFromFirebase() {

        if  !(Constants.selectedGolfID == "") {
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            let golfId = "course_\(Constants.selectedGolfID)"
            self.checkRangeFinderHoleData()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "golfCourses/\(golfId)") { (snapshot) in
                if snapshot.value != nil{

                    DispatchQueue.main.async(execute: {
                        let golfData = snapshot.value as! NSDictionary
                        
                        if let parArray = golfData.object(forKey: "par") as? NSArray{
                            
                            if parArray.count == 18{
                                self.gameTypeSgmtCtrl.selectedSegmentIndex = 0
                            }
                            else{
                                self.gameTypeSgmtCtrl.selectedSegmentIndex = 1
                            }
                            self.gameTypeChanged(self.gameTypeSgmtCtrl)
                        }
                        if (golfData.object(forKey: "coordinates") as? NSArray) != nil{
                            self.classicScoringSV.isHidden = true
                            self.stackRequestInfo.isHidden = true
//                            self.scoringTypeSgmtCtrl.isEnabled = true
//                            self.scoringTypeSgmtCtrl.selectedSegmentIndex = 1
                            
                            self.gameMode = "Advanced(GPS)"
                            self.scoringMode = "Advanced(GPS)"
                            
                            self.switchShotTracker.isOn = true
                            //self.shotTrackerChanged(mySwitch: self.switchShotTracker)
                            self.switchShotTracker.isEnabled = true

                            self.switchRangeFinder.isOn = true
                            //self.rangeFinderChanged(mySwitch: self.switchRangeFinder)
                            self.switchRangeFinder.isEnabled = true

                        }
                        else{
                            if let rangefinder = golfData.object(forKey: "rangefinder") as? NSDictionary{
                                
                                var greenLat = Double()
                                var greenLng = Double()
                                if let rangeFinderHoles = rangefinder.object(forKey: "holes") as? NSArray{
                                    if let lat = (rangeFinderHoles[0] as AnyObject).object(forKey: "greenLat") as? Double{
                                        greenLat = lat
                                    }
                                    if let lng = (rangeFinderHoles[0] as AnyObject).object(forKey: "greenLng") as? Double{
                                        greenLng = lng
                                    }
                                }
                                if(rangefinder.object(forKey: "holes") != nil) && (greenLat != 0)  && (greenLng != 0){
                                    self.gameMode = "rangeFinder"
                                    self.scoringMode = "rangeFinder"
                                    self.lblRequestMap.text = "This course is only available with Classic Scoring + Rangefinder."
                                    
                                    self.lblRFRequestInfo.text = "*Shot tracking is currently unavailable for this course."
                                    self.lblRequestInfo.text = "If you play on this course often Tap here to let us know and we'll work on it."

                                    self.switchRangeFinder.isOn = true
                                    //self.rangeFinderChanged(mySwitch: self.switchRangeFinder)
                                    self.switchRangeFinder.isEnabled = true

                                    self.switchShotTracker.isOn = false
                                    //self.shotTrackerChanged(mySwitch: self.switchShotTracker)
                                    self.switchShotTracker.isEnabled = false
                                }
                                else{
                                    self.gameMode = "classic"
                                    self.scoringMode = "classic"
                                    self.lblRequestMap.text = "This course is only available with Classic Scoring."
                                    
                                    self.lblRFRequestInfo.text = "*Shot tracking and Rangefinder is currently unavailable for this course."
                                    self.lblRequestInfo.text = "If you play on this course often Tap here to let us know and we'll work on it."

                                    self.switchRangeFinder.isOn = false
                                    //self.rangeFinderChanged(mySwitch: self.switchRangeFinder)
                                    self.switchRangeFinder.isEnabled = false

                                    self.switchShotTracker.isOn = false
                                    //self.shotTrackerChanged(mySwitch: self.switchShotTracker)
                                    self.switchShotTracker.isEnabled = false
                                }
                            }
                            else{
                                self.gameMode = "classic"
                                self.scoringMode = "classic"
                                self.lblRequestMap.text = "This course is available with Classic Scoring only. Request mapping to enable Advanced Stats."
                                
                                self.lblRFRequestInfo.text = "*Shot tracking and Rangefinder is currently unavailable for this course."
                                self.lblRequestInfo.text = "If you play on this course often Tap here to let us know and we'll work on it."

                                self.switchRangeFinder.isOn = false
                                //self.rangeFinderChanged(mySwitch: self.switchRangeFinder)
                                self.switchRangeFinder.isEnabled = false
                                
                                self.switchShotTracker.isOn = false
                                //self.shotTrackerChanged(mySwitch: self.switchShotTracker)
                                self.switchShotTracker.isEnabled = false
                            }
//                            self.classicScoringSV.isHidden = false  // changed by Amit
//                            self.stackRequestInfo.isHidden = false
                             self.classicScoringSV.isHidden = true
                             self.stackRequestInfo.isHidden = true

                            let myMutableString = NSMutableAttributedString(string: self.lblRequestInfo.text!)
                            myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(rgb: 0x3A7CA5), range: NSRange(location: 33, length: 8))
                            self.lblRequestInfo.attributedText = myMutableString

                            self.attributedStringArray.append("course often")
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:)))
                            self.lblRequestInfo.addGestureRecognizer(tap)
                            self.lblRequestInfo.isUserInteractionEnabled = true

//                            self.scoringTypeSgmtCtrl.isEnabled = false
//                            self.scoringTypeSgmtCtrl.selectedSegmentIndex = 0
                        }
//                        self.scoringModeChanged(self.scoringTypeSgmtCtrl)
                        self.progressView.hide(navItem: self.navigationItem)
                        debugPrint("ModeGame",self.gameMode)
                        debugPrint("modeScoring",self.scoringMode)

                        if Constants.isDevice{
                            self.lblLegacyAppMode.isHidden = false
                            self.golficationXView.isHidden = false
                            
                            if self.scoringMode == "rangeFinder" || self.scoringMode == "classic"{
                                self.playGolfXView.isHidden = true
                                self.mappingGolfXView.isHidden = false
                                self.playOnCourseAction(self.btnPlayOnCourse)
                                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "unmappedCourseRequest/\(Auth.auth().currentUser!.uid)") { (snapshot) in
                                    var dataDic = NSDictionary()
                                    if(snapshot.childrenCount > 0){
                                        dataDic = snapshot.value as! NSDictionary
                                        for (key,_) in dataDic{
                                            if let keyVal = key as? Int{
                                                if keyVal == Int(Constants.selectedGolfID){
                                                    self.btnRequestMapping.isHidden = true
                                                }
                                            }
                                            else if let keyVal = key as? String{
                                                if keyVal == Constants.selectedGolfID{
                                                    self.btnRequestMapping.isHidden = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                self.playGolfXView.isHidden = false
                                self.mappingGolfXView.isHidden = true
                            }
                            self.deselectGOlfXView()
                        }
                    })
                }
                else{
                    self.lblLegacyAppMode.isHidden = true
                    self.golficationXView.isHidden = true
                    self.playOnCourseAction(self.btnPlayOnCourse)
                }
            }
        }
    }
    
    @IBAction func btnActionForRequestMapping(_ sender: UIButton) {
        if(Auth.auth().currentUser!.uid.count > 1){
            ref.child("unmappedCourseRequest/\(Auth.auth().currentUser!.uid)/").updateChildValues([Constants.selectedGolfID:Timestamp] as [AnyHashable:Any])
        }
        btnRequestMapping.isHidden = true
        lblOverlapping.text = "Thanks for your request. We will notify you when this course is mapped for advanced scoring."
    }
    // MARK: getScoreFromMatchDataFirebase
    func getScoreFromMatchDataFirebase(keyId:String){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(keyId)/") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)

            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                Constants.matchDataDic = matchDict as! NSMutableDictionary
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,v) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                            if(k as! String) == Auth.auth().currentUser!.uid{
                                if let tee = (v as! NSMutableDictionary).value(forKey: "tee") as? String{
                                    Constants.selectedTee = tee
                                    Constants.selectedTee.capitalizeFirstLetter()
                                }
                                if let teeColor = (v as! NSMutableDictionary).value(forKey: "teeColor") as? String{
                                    Constants.selectedTeeColor = teeColor
                                }
                                if let swingKey = (v as! NSMutableDictionary).value(forKey: "swingKey") as? String{
                                    if Constants.ble == nil{
                                        Constants.ble = BLE()
                                    }
                                    Constants.ble.swingMatchId = swingKey
                                }
                            }
                        }
                    }
                    if(keyData == "courseId"){
                        Constants.selectedGolfID = value as! String
                        self.checkRangeFinderHoleData()
                    }
                    if(keyData == "courseName"){
                        Constants.selectedGolfName = value as! String
                        self.lblGolfName.text = Constants.selectedGolfName
                    }
                    if(keyData == "lat"){
                        Constants.selectedLat = value as! String
                    }
                    if(keyData == "lng"){
                        Constants.selectedLong = value as! String
                    }
                    if (keyData == "scoring"){
                        scoreArray = (value as! NSArray)
                    }
                    if (keyData == "scoringMode"){
                        let scoringMode = value as! String
                        if(scoringMode == "classic"){
                            Constants.mode = 3
                        }
                        else if(scoringMode == "rangefinder"){
                            Constants.mode = 2
                        }
                        else{
                            Constants.mode = 1
                        }
                    }
                    if(keyData == "currentHole"){
                        if !(value as! String == ""){
                            self.currentHoleFromFirebase = Int(value as! String)
                            self.lblContinueHoleNum.text = "Playing Hole".localized() + " " + String(self.currentHoleFromFirebase)
                        }
                    }
                    if(keyData == "matchType"){
                        if(value as! String == "18 holes"){
                            self.holeType = 18
                        }
                        else{
                            self.holeType = 9
                        }
                    }
                }
                self.holeOutCount = 0
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = (value as! Int)
                        }
                        for playerId in playersKey{
                            if(key as! String)==playerId{
                                let dict = NSMutableDictionary()
                                dict.setObject(value, forKey: key as! String as NSCopying)
                                if((key as! String) == Auth.auth().currentUser!.uid){
                                    if(((value as! NSMutableDictionary).value(forKey: "holeOut")) as! Bool){
                                        self.holeOutCount += 1
                                    }
                                }
                                playersArray.append(dict)
                            }
                        }
                    }
                    self.scoring.append((hole: i+1, par:par,players:playersArray))
                }
            }
            DispatchQueue.main.async(execute: {
                self.continueGameView.isHidden = false
                self.newGamescrollView.isHidden = true
                self.btnStartContinue.setTitle("Continue Round".localized(), for: .normal)
                
                self.players.removeAllObjects()
                self.players = NSMutableArray()
                if(Constants.matchDataDic.object(forKey: "player") != nil){
                    let tempArray = Constants.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
                    for (k,v) in tempArray{
                        let dict = v as! NSMutableDictionary
                        dict.addEntries(from: ["id":k])
                        self.players.add(dict)
                    }
                    self.scoreTableView.reloadData()
                    
                    self.scoreTblHConstraint.constant = CGFloat(55*self.players.count)
                    if(self.players.count == 2) || (self.players.count == 1) {
                        self.scoreTblHConstraint.constant = CGFloat(65*self.players.count)
                    }
                    self.view.layoutIfNeeded()

                    self.lblContinueGolfName.text = Constants.selectedGolfName
                    //self.lblContinueHoleNum.text = "Playing Hole " + startingHole
                }
                
                if Constants.ble != nil && !Constants.ble.swingMatchId.isEmpty{
                    self.checkSwingKey()
                }else{
                    if self.isContinueClicked{
                        self.isContinueClicked = false
                        self.redirectToGameModeScreen()
                    }
                }

            })
        }
    }
    func checkSwingKey(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession/\(Constants.ble.swingMatchId)/") { (snapshot) in
            var isSwing = false
            if let bool = snapshot.value as? Bool{
                isSwing = bool
            }
            DispatchQueue.main.async(execute: {
                if isSwing{
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(Constants.ble.swingMatchId)/") { (snapshot) in
                        var swingData = NSMutableDictionary()
                        if let dict = snapshot.value as? NSMutableDictionary{
                            swingData = dict
                        }
                        DispatchQueue.main.async(execute: {
                            if let gameID = swingData.value(forKey: "gameId") as? Int{
                                Constants.ble.currentGameId = gameID
                            }
                            if self.isContinueClicked{
                                self.isContinueClicked = false
                                self.redirectToGameModeScreen()
                            }
                        })
                    }
                }
            })
        }
    }
    func redirectToGameModeScreen() {
        self.finalMatchDic.setObject(Constants.matchDataDic, forKey: Constants.matchId as NSCopying)

        if(Constants.mode == 3){
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "BasicScoringVC") as! BasicScoringVC
            viewCtrl.scoreData = self.scoring
            viewCtrl.matchDataDict = Constants.matchDataDic
            viewCtrl.isContinue = true
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }else{
            self.checkingLocation()
        }
        
//        else if(mode == 2){
//            if  !(selectedGolfID == "") {
//                self.checkingLocation()
//
//            }
//        }
//        else{
//            if  !(selectedGolfID == ""){
//                self.checkingLocation()
//            }
//        }
        Notification.sendLocaNotificatonToUser()
    }
    func checkingLocation(){
        let onCourse = Constants.matchDataDic.value(forKey: "onCourse") as! Bool
        if onCourse{
//            let locationManager = CLLocationManager()
            if(locationManager.location == nil){
                locationManager.requestAlwaysAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            }
            if let _: CLLocation = locationManager.location{
                if(Constants.mode == 2){
                    if  !(Constants.selectedGolfID == "") {
                        self.pushRFMapVC()
                    }
                    
                }else{
                    if  !(Constants.selectedGolfID == "") {
                        self.pushDefultMapVC()
                    }
                }
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "Please enable GPS to play this game mode.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            if(Constants.mode == 2){
                self.pushRFMapVC()
            }else{
                self.pushDefultMapVC()
            }
        }
    }
    
    func pushRFMapVC(){
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
        viewCtrl.matchDataDic = Constants.matchDataDic
        viewCtrl.isContinueMatch = true
        viewCtrl.matchId = Constants.matchId
        viewCtrl.scoring = self.scoring
        viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    func pushDefultMapVC() {
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
        viewCtrl.isContinue = true
        viewCtrl.matchDataDict = Constants.matchDataDic
        viewCtrl.currentMatchId = Constants.matchId
        viewCtrl.scoring = self.scoring
        viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @IBOutlet weak var btnPlayOnCourse: UIButton!
    @IBOutlet weak var btnPrevRound: UIButton!
    
    @IBOutlet weak var lblPlayOnCourse: UILocalizedLabel!
    @IBOutlet weak var lblPrevRound: UILocalizedLabel!
    @IBOutlet weak var imagePlayOnCourse: UIImageView!
    @IBOutlet weak var imagePrevRound: UIImageView!
    @IBOutlet weak var lblSubPlayOnCourse: UILocalizedLabel!
    @IBOutlet weak var lblSubPrevRound: UILocalizedLabel!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var golficationXView: UIView!
    @IBOutlet weak var lblLegacyAppMode: UILabel!
    @IBOutlet weak var btnRequestMapping: UIButton!

    @IBOutlet weak var playGolfXView: UIView!
    @IBOutlet weak var mappingGolfXView: UIView!

    @IBOutlet weak var lblOverlapping: UILabel!
    @IBOutlet weak var popUpContainerView: UIView!
    @IBOutlet weak var popUpSubView: CardView!

    var modeInt = 0
    
    @IBAction func playGolfXAction(_ sender: Any) {
        modeInt = 0

        btnCheckBox.backgroundColor = UIColor.glfBluegreen

        golficationXView.layer.borderWidth = 1.0
        golficationXView.layer.borderColor = UIColor.glfBluegreen.cgColor
        golficationXView.layer.cornerRadius = 5
        
        golficationXView.layer.masksToBounds = false
        golficationXView.layer.shadowColor = UIColor.clear.cgColor
        golficationXView.layer.shadowOffset = CGSize(width: 1, height: 1);
        golficationXView.layer.shadowOpacity = 0.15
        
        
        btnPlayOnCourse.setCorner(color: UIColor.lightGray.cgColor)
        btnPrevRound.setCorner(color: UIColor.lightGray.cgColor)

        lblPlayOnCourse.textColor = UIColor.lightGray
        imagePlayOnCourse.image = #imageLiteral(resourceName: "on_course_0")
        lblSubPlayOnCourse.textColor = UIColor.lightGray

        lblPrevRound.textColor = UIColor.lightGray
        imagePrevRound.image = #imageLiteral(resourceName: "score_prev_0")
        lblSubPrevRound.textColor = UIColor.lightGray

        btnStartContinue.setTitle("Start".localized(), for: .normal)
    }
    
    @IBAction func playOnCourseAction(_ sender: Any) {
        modeInt = 0
        btnPlayOnCourse.setCorner(color: UIColor.glfBluegreen.cgColor)
        btnPrevRound.setCorner(color: UIColor.lightGray.cgColor)
        
        lblPlayOnCourse.textColor = UIColor.glfBluegreen
        imagePlayOnCourse.image = #imageLiteral(resourceName: "on_course_1")
        lblSubPlayOnCourse.textColor = UIColor.glfBluegreen
        
        lblPrevRound.textColor = UIColor.lightGray
        imagePrevRound.image = #imageLiteral(resourceName: "score_prev_0")
        lblSubPrevRound.textColor = UIColor.lightGray
        
        btnStartContinue.setTitle("Next".localized(), for: .normal)

        deselectGOlfXView()
    }
    @IBAction func prevRoundAction(_ sender: Any) {
        modeInt = 1
        btnPlayOnCourse.setCorner(color: UIColor.lightGray.cgColor)
        btnPrevRound.setCorner(color: UIColor.glfBluegreen.cgColor)
        
        lblPlayOnCourse.textColor = UIColor.lightGray
        imagePlayOnCourse.image = #imageLiteral(resourceName: "on_course_0")
        lblSubPlayOnCourse.textColor = UIColor.lightGray

        lblPrevRound.textColor = UIColor.glfBluegreen
        imagePrevRound.image = #imageLiteral(resourceName: "score_prev_1")
        lblSubPrevRound.textColor = UIColor.glfBluegreen
        
        btnStartContinue.setTitle("Next".localized(), for: .normal)

        deselectGOlfXView()
    }
    
    @IBAction func startContinueAction(_ sender: Any) {
        // Amit's Changes
        if btnStartContinue.titleLabel?.text == "Continue Round".localized(){
            var swingK = String()
            for data in self.players{
                if ((data as! NSMutableDictionary).value(forKey: "id") as! String) == Auth.auth().currentUser!.uid{
                    if let swingKey = (data as! NSMutableDictionary).value(forKey: "swingKey") as? String{
                        swingK = swingKey
                        break
                    }
                }
            }
            if swingK.isEmpty{
                isContinueClicked = true
                setActiveMatchUI()
            }else if !swingK.isEmpty && Constants.deviceGolficationX != nil{
                isContinueClicked = true
                setActiveMatchUI()
            }else{
                view.makeToast("Please Connect Device first...")
            }
        }
        else if btnStartContinue.titleLabel?.text == "Start".localized(){
             playGolfX()
        }
        else{
            isContinueClicked = false
            let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "NextRoundVC") as! NextRoundVC
            viewCtrl.selectedMode = modeInt
            viewCtrl.scoringMode = self.scoringMode
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    let locationManager = CLLocationManager()
    func playGolfX(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break
            
        case .restricted, .denied:
            // Disable location features
            let alert = UIAlertController(title: "Need Authorization or Enable GPS from Privacy Settings", message: "This game mode is unusable if you don't authorize this app or don't enable GPS", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            if let currentLocation: CLLocation = locationManager.location{
                
                var currentCoord = CLLocationCoordinate2D()
                currentCoord = currentLocation.coordinate
                
                let location1 = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
                let location2 = CLLocation(latitude: Double(Constants.selectedLat)!, longitude: Double(Constants.selectedLong)!)
                let distance : CLLocationDistance = location1.distance(from: location2)
                debugPrint("distance = \(distance) m")
                
                if(distance <= 15000.0){
                    popUpContainerView.isHidden = false
                }
                else{
                    // show alert
                    let emptyAlert = UIAlertController(title: "Alert", message: "You need to be near the course to play in On-Course mode.", preferredStyle: UIAlertControllerStyle.alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
            }
            break
        }
    }

    @IBAction func addFriendAction(sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        viewCtrl.selectedMode = modeInt
        viewCtrl.selectedTab = 2
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        popUpContainerView.isHidden = true
    }
    
    @IBAction func skipAction(sender: UIButton) {
        Constants.addPlayersArray = NSMutableArray()
        
        popUpContainerView.isHidden = true
        let gameCompleted = StartGameModeObj()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        // setup ultimate short tracking
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultMapApiCompleted(_:)), name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
        gameCompleted.showDefaultMap(onCourse:modeInt)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != popUpSubView {
            popUpContainerView.isHidden = true
        }
    }
    @objc func defaultMapApiCompleted(_ notification: NSNotification) {
        notifScoring = notification.object as! [(hole:Int,par:Int,players:[NSMutableDictionary])]
        if Constants.deviceGolficationX != nil{
            self.courseData.startingIndex = Constants.startingHole == "" ? 1:Int(Constants.startingHole)
            self.courseData.gameTypeIndex = Constants.gameType == "9 holes" ? 9:18
            self.courseData.getGolfCourseDataFromFirebase(courseId: "course_\(Constants.selectedGolfID)")
        }else{
            self.progressView.hide(navItem: self.navigationItem)
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
            viewCtrl.matchDataDict = Constants.matchDataDic
            viewCtrl.isContinue = false
            viewCtrl.currentMatchId = Constants.matchId
            viewCtrl.scoring = notifScoring
            viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
        }

    }
    @objc func loadMapWithBLECommands(_ notification: NSNotification) {
        var isDeviceConnected = false
        if Constants.deviceGolficationX != nil{
            isDeviceConnected = true
        }
        self.progressView.hide(navItem: self.navigationItem)
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
        viewCtrl.matchDataDict = Constants.matchDataDic
        viewCtrl.isContinue = false
        viewCtrl.currentMatchId = Constants.matchId
        viewCtrl.scoring = notifScoring
        viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
        viewCtrl.isDeviceConnected = isDeviceConnected
        viewCtrl.courseData = self.courseData
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "courseDataAPI"), object: nil)
    }
    // MARK: startGameAction
    func startGameAction() {
        //        self.progressView.show(navItem: self.navigationItem)
        
        if(Constants.selectedGolfID.count > 0) && !(Constants.selectedGolfID == "") && scoringMode != "classic"{
            var golfId = "course_\(Constants.selectedGolfID)"
            if(isShowCase){
                golfId = "course_14513"
            }
            
            if(scoringMode == "rangeFinder") && !isShowCase{
                var isBot = false
                if Constants.addPlayersArray.count>0{
                    for data in Constants.addPlayersArray{
                        let player = data as! NSMutableDictionary
                        let id = player.value(forKey: "id")
                        if id as! String == "jpSgWiruZuOnWybYce55YDYGXP62"{
                            isBot = true
                            let alert = UIAlertController(title: "Alert", message: "Deejay Bot is only available in Advanced scoring.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                        }
                    }
                    if(!isBot){
                        self.setUpRFMap(golfId: golfId)
                    }
                }else{
                    self.setUpRFMap(golfId: golfId)
                }
            }
            else{
                self.showDefaultMap()
            }
        }
    }
    // MARK: setUpMapData
    func setUpMapData(scoringMode:String){
        
        Constants.matchDataDic = NSMutableDictionary()
        let tempdic = NSMutableDictionary()
        tempdic.setObject(Auth.auth().currentUser?.uid ?? "", forKey: "id" as NSCopying)
        tempdic.setObject(Auth.auth().currentUser?.displayName ?? "", forKey: "name" as NSCopying)
        if Constants.selectedTee.count > 1{
            tempdic.setObject(Constants.selectedTee.lowercased(), forKey: "tee" as NSCopying)
            tempdic.setObject(Constants.handicap, forKey: "handicap" as NSCopying)
        }

        var imagUrl =  ""
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        tempdic.setObject(imagUrl, forKey: "image" as NSCopying)
        tempdic.setObject(2, forKey: "status" as NSCopying)
        tempdic.setObject(-1, forKey: "timestamp" as NSCopying)
        Constants.addPlayersArray.insert(tempdic, at: 0)
        
        for i in 1..<Constants.addPlayersArray.count{
            (Constants.addPlayersArray[i] as AnyObject).setObject(1, forKey: "status" as NSCopying)
        }
        Constants.matchDataDic.setObject(Constants.selectedGolfID, forKey: "courseId" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedGolfName, forKey: "courseName" as NSCopying)
        Constants.matchDataDic.setObject(self.brginTimestamp, forKey: "timestamp" as NSCopying)
        Constants.matchDataDic.setObject(Constants.gameType, forKey: "matchType" as NSCopying)
        Constants.matchDataDic.setObject(Constants.startingHole, forKey: "startingHole" as NSCopying)
        Constants.matchDataDic.setObject(Constants.startingHole, forKey: "currentHole" as NSCopying)
        if(scoringMode.count > 0){
            Constants.matchDataDic.setObject(scoringMode, forKey: "scoringMode" as NSCopying)
        }
        Constants.matchDataDic.setObject((Auth.auth().currentUser?.uid)!, forKey: "startedBy" as NSCopying)
        let playerDict = NSMutableDictionary()
        for data in Constants.addPlayersArray{
            let player = data as! NSMutableDictionary
            let id = player.value(forKey: "id")
            playerDict.setObject(player, forKey: id as! NSCopying)
        }
        
        Constants.matchDataDic.setObject(playerDict, forKey: "player" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedLat, forKey: "lat" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedLong, forKey: "lng" as NSCopying)
        Constants.matchId = ref!.child("matchData").childByAutoId().key
        self.finalMatchDic.setObject(Constants.matchDataDic, forKey: Constants.matchId as NSCopying)
        
        for player in Constants.addPlayersArray{
            if let reciever = ((player as AnyObject).object(forKey:"id") as? String){
                if(reciever != Auth.auth().currentUser?.uid){
                    Notification.sendNotification(reciever: reciever, message: "\(Auth.auth().currentUser?.displayName ?? "Guest1") has invited you to a game", type:"7", category: "dont know",matchDataId: Constants.matchId, feedKey: "")
                }
            }
        }
        ref.child("matchData").updateChildValues(self.finalMatchDic as! [AnyHashable : Any])
        if(!isShowCase){
            for (key,_) in playerDict{
                if((key as! String) == Auth.auth().currentUser?.uid) && (Constants.matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([Constants.matchId:true] as [AnyHashable:Any])
                }
                else if(Constants.matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([Constants.matchId:false] as [AnyHashable:Any])
                }
            }
        }
    }
    
    var brginTimestamp: Int64 {
        return Int64(NSDate().timeIntervalSince1970*1000)
    }
    @objc func completeDeviceSetup(_ notiication : NSNotification){
        let alertVC = UIAlertController(title: "Alert", message: "Please finish the device setup first.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
//            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
            self.navigationController?.popToRootViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    @objc func continueButtonAction(_ notiication : NSNotification){
        btnStartContinue.setTitle("Continue Round".localized(), for: .normal)
        self.startContinueAction(Any.self)
    }
    @objc func EndRound(_ notiication : NSNotification){
        self.endAction(Any.self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "EndRound"), object: nil)
    }
    @IBAction func btnActionConnectDevice(_ sender: Any) {
        if Constants.isDevice{
            Constants.ble.startScanning()
        }
    }
    
    // MARK: showDefaultMap
    func showDefaultMap()  {
        
        setUpMapData(scoringMode: "")
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
        viewCtrl.matchDataDict = Constants.matchDataDic
        viewCtrl.currentMatchId = Constants.matchId
        viewCtrl.scoring = self.scoring
        viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        Constants.mode = 1
        //        let playerCount = (matchDataDic.value(forKey: "player") as! NSArray).count
        
        Analytics.logEvent("mode1_gameStarted", parameters: [:])
        Notification.sendLocaNotificatonToUser()
        self.getActiveMatches()
    }
    
    // MARK: setUpRFMap
    func setUpRFMap(golfId: String)  {
        Constants.matchDataDic = NSMutableDictionary()
        let tempdic = NSMutableDictionary()
        tempdic.setObject(Auth.auth().currentUser?.uid ?? "", forKey: "id" as NSCopying)
        tempdic.setObject(Auth.auth().currentUser?.displayName ?? "", forKey: "name" as NSCopying)
        if Constants.selectedTee.count > 1{
            tempdic.setObject(Constants.selectedTee.lowercased(), forKey: "tee" as NSCopying)
            tempdic.setObject(Constants.handicap, forKey: "handicap" as NSCopying)
            
        }
        var imagUrl =  ""
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        tempdic.setObject(imagUrl, forKey: "image" as NSCopying)
        tempdic.setObject(2, forKey: "status" as NSCopying)
        tempdic.setObject(-1, forKey: "timestamp" as NSCopying)
        Constants.addPlayersArray.insert(tempdic, at: 0)
        for i in 1..<Constants.addPlayersArray.count{
            (Constants.addPlayersArray[i] as AnyObject).setObject(1, forKey: "status" as NSCopying)
        }
        if(isShowCase){
            let dJohnSonUser = NSMutableDictionary()
            dJohnSonUser.setObject("Deejay" , forKey: "name" as NSCopying)
            dJohnSonUser.setObject( "http://www.golfication.com/assets/DJ%20256PNG.png", forKey: "image" as NSCopying)
            dJohnSonUser.setObject(self.brginTimestamp , forKey: "timestamp" as NSCopying)
            dJohnSonUser.setObject( "jpSgWiruZuOnWybYce55YDYGXP62", forKey: "id" as NSCopying)
            Constants.addPlayersArray.add(dJohnSonUser)
        }
        Constants.matchDataDic.setObject(Constants.selectedGolfID, forKey: "courseId" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedGolfName, forKey: "courseName" as NSCopying)
        Constants.matchDataDic.setObject(self.brginTimestamp, forKey: "timestamp" as NSCopying)
        Constants.matchDataDic.setObject(Constants.gameType, forKey: "matchType" as NSCopying)
        Constants.matchDataDic.setObject(Constants.startingHole, forKey: "startingHole" as NSCopying)
        Constants.matchDataDic.setObject(Constants.startingHole, forKey: "currentHole" as NSCopying)
        Constants.matchDataDic.setObject("rangefinder", forKey: "scoringMode" as NSCopying)
        Constants.matchDataDic.setObject((Auth.auth().currentUser?.uid)!, forKey: "startedBy" as NSCopying)
        let playerDict = NSMutableDictionary()
        for data in Constants.addPlayersArray{
            let player = data as! NSMutableDictionary
            let id = player.value(forKey: "id")
            playerDict.setObject(player, forKey: id as! NSCopying)
        }
        Constants.matchDataDic.setObject(playerDict, forKey: "player" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedLat, forKey: "lat" as NSCopying)
        Constants.matchDataDic.setObject(Constants.selectedLong, forKey: "lng" as NSCopying)
        Constants.matchId = ref!.child("matchData").childByAutoId().key
        self.finalMatchDic.setObject(Constants.matchDataDic, forKey: Constants.matchId as NSCopying)
        for player in Constants.addPlayersArray{
            if let reciever = ((player as AnyObject).object(forKey:"id") as? String){
                if(reciever != Auth.auth().currentUser?.uid){
                    Notification.sendNotification(reciever: reciever, message: "\(Auth.auth().currentUser?.displayName ?? "Guest1") send you request to join the game", type:"7", category: "dont know",matchDataId: Constants.matchId, feedKey: "")
                }
            }
            
        }
        ref.child("matchData").updateChildValues(self.finalMatchDic as! [AnyHashable : Any])
        if(!isShowCase){
            for (key,_) in playerDict{
                if((key as! String) == Auth.auth().currentUser?.uid) && Constants.matchId.count > 1{
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([Constants.matchId:true] as [AnyHashable:Any])
                }
                else if (Constants.matchId.count>1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([Constants.matchId:false] as [AnyHashable:Any])
                }
            }
        }
        if  !(Constants.selectedGolfID == "") {
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
            viewCtrl.matchDataDic = Constants.matchDataDic
            viewCtrl.isContinueMatch = false
            viewCtrl.matchId = Constants.matchId
            viewCtrl.courseId = golfId
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            
            Constants.mode = 2
            Analytics.logEvent("mode2_gameStarted", parameters: [:])
            Notification.sendLocaNotificatonToUser()
        }
        self.getActiveMatches()
        
    }
    
    // MARK: endAction
    @IBAction func endAction(_ sender: Any) {
        var myVal: Int = 0
        for i in 0..<scoring.count{
            for dataDict in scoring[i].players{
                for (key,value) in dataDict{
                    let dic = value as! NSDictionary
                    if dic.value(forKey: "holeOut") as! Bool == true{
                        if(key as? String == Auth.auth().currentUser!.uid){
                            for (key,value) in value as! NSMutableDictionary
                            {
                                if (key as! String == "holeOut" && value as! Bool){
                                    myVal = myVal + (value as! Int)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let myController = UIAlertController(title: "Round in progress".localized(), message: "\(myVal)" + "/" + "\(scoring.count) " + "holes completed".localized(), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let messageAttributed = NSMutableAttributedString(
            string: myController.message!,
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.glfBluegreen, NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 16.0)!])
        myController.setValue(messageAttributed, forKey: "attributedMessage")
        
        let saveOption = (UIAlertAction(title: "Save Round", style: UIAlertActionStyle.default, handler: { action in
            self.saveAndviewScore()
        }))
        var descardRound = "Discard Round".localized()
        if Constants.isEdited{
            descardRound = "Delete Round"
        }
        let discardOption = (UIAlertAction(title: descardRound, style: UIAlertActionStyle.default, handler: { action in
            self.exitWithoutSave()
        }))
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            debugPrint("Cancelled")
        })
        discardOption.setValue(UIColor.red, forKey: "titleTextColor")
        myController.addAction(saveOption)
        myController.addAction(discardOption)
        myController.addAction(cancelOption)
        present(myController, animated: true, completion: nil)
    }

    
    func checkHoleOutZero() -> Int{
        // --------------------------- Check If User has not completed detail scoring  ------------------------
        detailedScore = NSMutableArray()
        let playerId = Auth.auth().currentUser!.uid
        var myVal: Int = 0
        for i in 0..<scoring.count{
            for dataDict in scoring[i].players{
                for (key,value) in dataDict{
                    let dic = value as! NSDictionary
                    if dic.value(forKey: "holeOut") as! Bool == true{
                        if(key as? String == playerId){
                            for (key,value) in value as! NSMutableDictionary
                            {
                                if (key as! String == "holeOut" && value as! Bool){
                                    
                                    let countDic = NSMutableDictionary()
                                    countDic.setObject(i, forKey: "HoleIndex" as NSCopying)
                                    countDic.setObject(dic.count, forKey: "DetailCount" as NSCopying)
                                    detailedScore.addObjects(from: [countDic])
                                    myVal = myVal + (value as! Int)
                                }
                            }
                        }
                    }
                }
            }
        }
        return myVal
    }
    
    func exitWithoutSave(){
        
        if(Constants.matchId.count > 1){
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            if(Constants.matchId.count > 1){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(Constants.matchId)").removeValue()
            }
            Constants.matchId.removeAll()
            for data in self.players{
                if ((data as! NSMutableDictionary).value(forKey: "id") as! String) == Auth.auth().currentUser!.uid{
                    if let swingKey = (data as! NSMutableDictionary).value(forKey: "swingKey") as? String{
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([swingKey:false])
                        Constants.ble.discardGameFromDevice()
                        break
                    }
                }
            }

            Constants.isUpdateInfo = true
            self.navigationController?.popViewController(animated: true)
            Constants.addPlayersArray.removeAllObjects()
            if Constants.mode>0{
                Analytics.logEvent("mode\(Constants.mode)_game_discarded", parameters: [:])
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                //center.removePendingNotificationRequests(withIdentifiers: ["UYLLocalNotification"])
            }
        }
        self.scoring.removeAll()
        scoring.removeAll()
    }
    
    func saveAndviewScore(){
        
        var holIndex = -1
        let totalThru: Int = self.checkHoleOutZero()
        FBSomeEvents.shared.logGameEndedEvent(holesPlayed: totalThru, valueToSum: Double(Constants.mode))
        for i in 0..<detailedScore.count{
            let dic = detailedScore[i] as! NSMutableDictionary
            if (dic.value(forKey: "DetailCount") as! Int == 2){
                holIndex = dic.value(forKey: "HoleIndex") as! Int
                break
            }
        }
        if (totalThru >= 9) && !(Constants.mode == 1) && (holIndex > -1){
//        if (totalThru >= 6) && !(mode == 1) && (holIndex>0){
            let emptyAlert = UIAlertController(title: "Alert", message: "Would you like to complete Detailed Scoring to get better stats?", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "Add Detailed Scores", style: .default, handler: { (action: UIAlertAction!) in
                
                let currentHoleWhilePlaying = NSMutableDictionary()
                currentHoleWhilePlaying.setObject("\(holIndex+1)", forKey: "currentHole" as NSCopying)
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
                
                self.isContinueClicked = true
                self.setActiveMatchUI()
            }))
            emptyAlert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
                NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
                self.generateStatsData()
            }))
            self.present(emptyAlert, animated: true, completion: nil)
        }
        else{
            NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
            if(totalThru > 8){
                self.generateStatsData()
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
            }
        }
    }
    func generateStatsData(){
        for data in self.players{
            if ((data as! NSMutableDictionary).value(forKey: "id") as! String) == Auth.auth().currentUser!.uid{
                if let swingKey = (data as! NSMutableDictionary).value(forKey: "swingKey") as? String{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([swingKey:false])
                    break
                }
            }
        }
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        let generateStats = GenerateStats()
        generateStats.matchKey = Constants.matchId
        generateStats.generateStats()
        let totalThru: Int = self.checkHoleOutZero()
    }
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.hide(navItem: self.navigationItem)

        if(Constants.matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(Constants.matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        
        if(Auth.auth().currentUser!.uid.count>1) &&  (Constants.matchId.count > 1){
            ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
            if !Constants.isProMode && Constants.mode == 1{
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["summaryTimer":Timestamp])
            }
        }
        isShowCase = false
        Constants.addPlayersArray = NSMutableArray()
        for i in 0..<btnPlayerArray.count{
            if i != 4{
                btnPlayerArray[i].titleLabel?.font = UIFont.systemFont(ofSize: 35.0)
                btnPlayerArray[i].setTitleColor(UIColor.lightGray, for: .normal)
                btnPlayerArray[i].setTitle("+", for: .normal)
            }
        }
        self.updateFeedNode()
        Constants.isUpdateInfo = true
        if Constants.mode>0{
            Analytics.logEvent("mode\(Constants.mode)_game_completed", parameters: [:])
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            //center.removePendingNotificationRequests(withIdentifiers: ["UYLLocalNotification"])
        }
        if(Constants.matchId.count > 1){
            self.gotoFeedBackViewController(mID: Constants.matchId,mode:Constants.mode)
        }
    }
    
    func sendMatchFinishedNotification(){
        if recentPlyrMArr.count>0 {
            for i in 0..<recentPlyrMArr.count{
                let key = (recentPlyrMArr[i] as AnyObject).object(forKey:"id") as? String
                
                Notification.sendNotification(reciever: key!, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(Constants.selectedGolfName).", type: "8", category: "finishedGame", matchDataId: Constants.matchId, feedKey: "")
            }
        }
        self.setActiveMatchUI()
    }
    
    func updateFeedNode(){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(Constants.matchDataDic.value(forKey: "timestamp") as Any, forKey: "timestamp" as NSCopying)
        feedDict.setObject(Constants.matchId, forKey: "matchKey" as NSCopying)
        feedDict.setObject("2", forKey: "type" as NSCopying)
        var imagUrl = String()
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        feedDict.setObject(imagUrl, forKey: "userImage" as NSCopying)
        let feedId = ref!.child("feedData").childByAutoId().key
        let finalFeedDic = NSMutableDictionary()
        finalFeedDic.setObject(feedDict, forKey: feedId as NSCopying)
        
        ref.child("feedData").updateChildValues(finalFeedDic as! [AnyHashable : Any])
        ref.child("userData/\(feedDict.value(forKey: "userKey")!)/myFeeds").updateChildValues([feedId:true])
    }
    
    func gotoFeedBackViewController(mID:String,mode:Int){
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        viewCtrl.matchIdentifier = mID
        viewCtrl.mode = mode
        viewCtrl.onDoneBlock = { result in
            let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
            viewCtrl.finalPlayersData = self.players
            viewCtrl.finalScoreData = self.scoring
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            viewCtrl.fromGameImprovement = true
            viewCtrl.isManualScoring = mode != 1 ? true:false
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            Constants.matchId.removeAll()
            self.scoring.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }
    
    // MARK: setRecentPlayerUI
    func setRecentPlayerUI() {
        for i in 0..<btnRecentArray.count{
            btnRecentArray[i].isUserInteractionEnabled = false
            if(i < recentPlyrMArr.count){
                btnRecentArray[i].isUserInteractionEnabled = true
                if let tag = (recentPlyrMArr[i] as AnyObject).object(forKey:"timestamp") as? Int{
                    btnRecentArray[i].tag = tag
                }
                let imageStr = ((recentPlyrMArr[i] as AnyObject).value(forKey: "image") as? String) ?? ""
                if !(imageStr == ""){
                    
                    let imageUrl = URL(string: imageStr)
                    self.btnRecentArray[i].sd_setBackgroundImage(with: imageUrl, for: .normal, completed: nil)
                }
                else{
                    let titleStr = ((recentPlyrMArr[i] as AnyObject).value(forKey: "name") as? String) ?? ""
                    btnRecentArray[i].setTitle("\(titleStr.first ?? " ")", for: .normal)
                }
                if((recentPlyrMArr[i] as AnyObject).object(forKey:"id") as! String) == "jpSgWiruZuOnWybYce55YDYGXP62"{
                    self.btnRecentArray[i].setCornerWithCircle(color: UIColor.glfRosyPink.cgColor)
                }
            }
        }
    }
    
    // MARK: recentPlayerAction
    @IBAction func recentPlayerAction(_ sender: UIButton) {
        
        let tempdic = NSMutableDictionary()
        
        if !sender.isSelected{
            // ----------------- Add -----------------------
            
            if Constants.addPlayersArray.count>3 {
                
                let emptyAlert = UIAlertController(title: "Alert", message: "You can choose maximum 4 friends", preferredStyle: UIAlertControllerStyle.alert)
                emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(emptyAlert, animated: true, completion: nil)
            }
            else{
                sender.isSelected = true
                for i in 0..<recentPlyrMArr.count{
                    if let tmstmp = (recentPlyrMArr[i] as AnyObject).object(forKey:"timestamp") as? Int{
                        if sender.tag == tmstmp{
                            tempdic.setObject((recentPlyrMArr[i] as AnyObject).object(forKey:"id") as! String, forKey: "id" as NSCopying)
                            tempdic.setObject((recentPlyrMArr[i] as AnyObject).object(forKey:"name") as! String, forKey: "name" as NSCopying)
                            tempdic.setObject((recentPlyrMArr[i] as AnyObject).object(forKey:"image") as? String ?? "", forKey: "image" as NSCopying)
                            tempdic.setObject(sender.tag, forKey: "timestamp" as NSCopying)
                            break
                        }
                    }
                }
                
                Constants.addPlayersArray.add(tempdic)
                
                for i in 0..<Constants.addPlayersArray.count{
                    btnPlayerArray[i].setTitle("", for: .normal)
                    if (sender.tag == ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int)){
                        if(((Constants.addPlayersArray[i] as AnyObject).object(forKey:"image") as? String) != nil){
                            let imageUrl = URL(string: ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"image") as! String))
                            ((self.btnPlayerArray[i]) ).sd_setBackgroundImage(with: imageUrl, for: .normal, completed: nil)
                        }
                        else{
                            let titleStr = (Constants.addPlayersArray[i] as AnyObject).object(forKey:"name") as? String ?? ""
                            btnPlayerArray[i].setTitle("\(titleStr.first ?? " ")", for: .normal)
                        }
                        break
                    }
                }
            }
        }
        else{
            //------------------- Remove ------------------
            if Constants.addPlayersArray.count>0{
                
                sender.isSelected = false
                for i in 0..<Constants.addPlayersArray.count{
                    if (sender.tag == ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int)){
                        Constants.addPlayersArray.removeObject(at: i)
                        break
                    }
                }
                
                for i in 0..<Constants.addPlayersArray.count{
                    //                    if (sender.tag == ((addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as? Int)){
                    if(((Constants.addPlayersArray[i] as AnyObject).object(forKey:"image") as? String) != nil){
                        let imageUrl = URL(string: ((Constants.addPlayersArray[i] as AnyObject).object(forKey:"image") as! String))
                        self.btnPlayerArray[i].sd_setBackgroundImage(with: imageUrl, for: .normal, completed: nil)
                    }
                    else{
                        let titleStr = (Constants.addPlayersArray[i] as AnyObject).object(forKey:"name") as? String ?? ""
                        btnPlayerArray[i].setTitle("\(titleStr.first ?? " ")", for: .normal)
                    }
                }
                for j in Constants.addPlayersArray.count..<btnPlayerArray.count{
                    if j != 4{
                        btnPlayerArray[j].titleLabel?.font = UIFont.systemFont(ofSize: 35.0)
                        btnPlayerArray[j].setTitleColor(UIColor.lightGray, for: .normal)
                        btnPlayerArray[j].setTitle("+", for: .normal)
                        btnPlayerArray[j].setBackgroundImage(nil, for: .normal)
                    }
                }
            }
        }
    }
    
    // MARK: viewScoreAction
    @IBAction func viewScoreAction(_ sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = scoring
        viewCtrl.playerData = players
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }

    
    // MARK: UITableView Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return players.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.white
        let lblPlayer = UILabel()
        lblPlayer.frame = CGRect(x: 0, y: 0, width: 90, height: 25)
        lblPlayer.text = "Players".localized()
        lblPlayer.textColor = UIColor.black
        lblPlayer.backgroundColor = UIColor.clear
        lblPlayer.textAlignment = NSTextAlignment.left
        lblPlayer.font = UIFont.systemFont(ofSize: 11.0)
        header.addSubview(lblPlayer)
        
        let lblStroke = UILabel()
        lblStroke.frame = CGRect(x: tableView.frame.size.width-60, y: 0, width: 60, height: 25)
        lblStroke.text = "Strokes".localized()
        lblStroke.textColor = UIColor.black
        lblStroke.backgroundColor = UIColor.clear
        lblStroke.textAlignment = NSTextAlignment.right
        lblStroke.font = UIFont.systemFont(ofSize: 11.0)
        header.addSubview(lblStroke)
        
        let lblThru = UILabel()
        lblThru.frame = CGRect(x: tableView.frame.size.width-(lblStroke.frame.size.width+40+10), y: 0, width: 40, height: 25)
        lblThru.text = "Thru".localized()
        lblThru.textColor = UIColor.black
        lblThru.backgroundColor = UIColor.clear
        lblThru.textAlignment = NSTextAlignment.right
        lblThru.font = UIFont.systemFont(ofSize: 11.0)
        header.addSubview(lblThru)
        
        let lblToPar = UILabel()
        lblToPar.frame = CGRect(x: tableView.frame.size.width-(lblStroke.frame.size.width+lblThru.frame.size.width+50+10+10), y: 0, width: 50, height: 25)
        lblToPar.text = "To Par".localized()
        lblToPar.textColor = UIColor.black
        lblToPar.backgroundColor = UIColor.clear
        lblToPar.textAlignment = NSTextAlignment.right
        lblToPar.font = UIFont.systemFont(ofSize: 11.0)
        header.addSubview(lblToPar)
        
        return header
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "PlayersCell") as! NewGameScoreTableViewCell!
        let userName = (players[indexPath.row] as AnyObject).value(forKey: "name") as! String
        let nameArray = userName.components(separatedBy: " ")
        cell?.lblPlayerName.text = nameArray.first!
        if((players[indexPath.row] as AnyObject).value(forKey: "image") != nil){
            let imageStr = ((players[indexPath.row] as AnyObject).value(forKey: "image") as? String) ?? ""
            cell?.imgPlayer.sd_setImage(with: URL(string:imageStr),placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
        }
        let playerId = (players[indexPath.row] as AnyObject).value(forKey: "id") as? String
        var finalPar: Int = 0
        var myVal: Int = 0
        var finalStroke: Int = 0
        for i in 0..<scoring.count{
            for dataDict in scoring[i].players{
                for (key,value) in dataDict{
                    let dic = value as! NSDictionary
                    if dic.value(forKey: "holeOut") as! Bool == true{
                        if(key as? String == playerId){
                            for (key,value) in value as! NSMutableDictionary{
                                if(key as! String == "shots"){
                                    let shotsArray = value as! NSArray
                                    finalStroke += shotsArray.count
                                    let allScore  = shotsArray.count - (scoring[i].par)
                                    finalPar += allScore
                                }
                                if (key as! String == "holeOut" && value as! Bool){
                                    myVal = myVal + (value as! Int)
                                }
                                if(key as! String == "strokes"){
                                    let shots = value as! Int
                                    finalStroke += shots
                                    let allScore  = shots - (scoring[i].par)
                                    finalPar += allScore
                                }
                            }
                        }
                    }
                }
            }
        }
        cell?.lblPar.text = "\(finalPar)"
        if finalPar>0{
            cell?.lblPar.text = "+\(finalPar)"
        }
        cell?.lblThru.text = "\(myVal)"
        if let status = (players[indexPath.row] as AnyObject).value(forKey: "status") as? Int{
            if status == 3 || status == 4{
                if scoring.count == 18{
                    if myVal == 18{
                        cell?.lblThru.text = "F"
                    }
                }
                else{
                    if myVal == 9{
                        cell?.lblThru.text = "F"
                    }
                }
            }
        }
        cell?.lblStrokes.text = "\(finalStroke)"
        
        return cell!
    }
    
}
extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
