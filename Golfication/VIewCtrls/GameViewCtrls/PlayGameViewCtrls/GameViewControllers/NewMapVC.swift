//
//  NewMapVC.swift
//  Golfication
//
//  Created by Khelfie on 27/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import GoogleMaps
import Dropper
import ActionSheetPicker_3_0
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics
import UserNotifications
import CTShowcase
import GLKit
import UICircularProgressRing
private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}
class SuggestionMarkerView:UIView{
    let lblTitle = UILabel()
    let lblSubtitle = UILabel()
    init(){
        super.init(frame:.zero)
        backgroundColor = UIColor.glfBlack50
        lblTitle.frame = CGRect(origin: CGPoint(x: 2.5, y: 2.5), size: CGSize(width: 90.0, height: 20.0))
        lblTitle.textColor = UIColor.glfBlueyGreen
        lblTitle.textAlignment = .center
        lblSubtitle.frame = CGRect(origin: CGPoint(x: 2.5, y: 22.5), size: CGSize(width: 90.0, height: 20.0))
        lblSubtitle.textColor = UIColor.glfWhite
        lblSubtitle.textAlignment = .center
        self.layer.cornerRadius = CGFloat(15.0)
        addSubview(lblTitle)
        addSubview(lblSubtitle)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NoDataAvailableLabel:UILabel{
    init(){
        super.init(frame:.zero)
        text = "No Data Available"
        textColor = UIColor.glfWhite
        backgroundColor = UIColor.glfBlack
        textAlignment = .center
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ShotMarker:UIView{
    let btn = UIButton()
    let lbl = UILabel()
    let newBtn = UIButton()
    init(){
        super.init(frame:.zero)
        btn.frame = CGRect(origin: CGPoint(x: 2.5, y: 2.5), size: CGSize(width: 25.0, height: 25.0))
        lbl.frame = CGRect(origin: CGPoint(x: 30, y: 2.5), size: CGSize(width: 75.0, height: 25.0))
        newBtn.backgroundColor = UIColor.clear
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.glfWhite
        btn.setCircle(frame: btn.frame)
        btn.backgroundColor = UIColor.glfWhite
        btn.setTitleColor(UIColor.glfBlack, for: .normal)
        backgroundColor = UIColor.glfGreenBlue
        layer.cornerRadius = 15
        isUserInteractionEnabled = true
        addSubview(btn)
        addSubview(lbl)
        addSubview(newBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class UserMarker:UIView{
    let btn = UIButton()
    let lbl = UILabel()
    
    init(){
        super.init(frame:.zero)
        btn.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 30.0, height: 30.0))
        lbl.frame = CGRect(origin: CGPoint(x: 35, y: 2.5), size: CGSize(width: 100.0, height: 25.0))
        lbl.backgroundColor = UIColor.glfBluegreen
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 12.5
        lbl.layer.masksToBounds = true
        lbl.textColor = UIColor.glfWhite
        btn.setCircle(frame: btn.frame)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.glfWhite.cgColor
        btn.backgroundColor = UIColor.glfWhite
        btn.setImage(#imageLiteral(resourceName: "you"), for: .normal)
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        layer.cornerRadius = 15
        addSubview(btn)
        addSubview(lbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

var Timestamp: Int64 {
    return Int64(NSDate().timeIntervalSince1970*1000)
}

class NewMapVC: UIViewController,GMSMapViewDelegate,UIGestureRecognizerDelegate,ExitGamePopUpDelegate, ARViewDelegate, BluetoothDelegate{
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnCenter: UILocalizedButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgViewWind: UIImageView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var btnPlayersStats: UILocalizedButton!
    @IBOutlet weak var viewForground: UIView!
    @IBOutlet weak var lblBackDistance: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblFrontDistance: UILabel!
    @IBOutlet weak var imgViewWindForeground: UIImageView!
    @IBOutlet weak var lblWindSpeedForeground: UILabel!
    @IBOutlet weak var btnMoveToMapGround: UIButton!
    @IBOutlet weak var lblHoleNumber: UILabel!
    @IBOutlet weak var lblParNumber: UILabel!
    @IBOutlet weak var btnVRView: UIButton!
    @IBOutlet weak var btnStylizedMapView: UIButton!
    @IBOutlet weak var btnClubs: UIButton!
    @IBOutlet weak var btnTrackShot: UIButton!
    @IBOutlet weak var stackViewSubBtn: UIStackView!
    @IBOutlet weak var btnSelectClubs: UIButton!
    @IBOutlet weak var lblShotNumber: UILabel!
    @IBOutlet weak var lblEditShotNumber: UILabel!
    
    @IBOutlet weak var btnMultiplayerLbl: UIButton!
    @IBOutlet weak var btnAddPenaltyLbl: UIButton!
    @IBOutlet weak var btnCloseLbl: UIButton!
    @IBOutlet weak var btnRemovePenaltyLbl: UIButton!
    @IBOutlet weak var btnDeleteLbl: UIButton!
    @IBOutlet weak var btnHoleoutLbl: UIButton!
    
    @IBOutlet weak var btnMultiplayer: UIButton!
    @IBOutlet weak var btnPenaltyShot: UIButton!
    @IBOutlet weak var btnHoleOut: UIButton!
    @IBOutlet weak var btnDeleteShot: UIButton!
    @IBOutlet weak var btnShareShot: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnRemovePenalty: UIButton!
    
    @IBOutlet weak var stackViewForMultiplayer: UIStackView!
    @IBOutlet weak var btnNextScrl: UIButton!
    @IBOutlet weak var btnPrevScrl: UIButton!
    @IBOutlet weak var btnLandedOnEdit: UIButton!
    @IBOutlet weak var btnLandedOnDropDown: UIButton!
    @IBOutlet weak var centerSV: UIStackView!
    @IBOutlet weak var stackViewForViewForground: UIStackView!
    @IBOutlet weak var lblPlayersName: UILabel!
    
    @IBOutlet weak var exitGamePopUpView: ExitGamePopUpView!
    // MARK:- playersScore outlets
    @IBOutlet weak var viewHoleStats: UIView!
    @IBOutlet weak var btnViewScorecard: UILocalizedButton!
    @IBOutlet weak var btnEndRound: UILocalizedButton!
    @IBOutlet weak var btnTotalShotsNumber: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    @IBOutlet weak var lblHoleNumber2: UILabel!
    @IBOutlet weak var lblParNumber2: UILabel!
    @IBOutlet weak var lblRaceToFlagTitle: UILabel!
    @IBOutlet weak var barChartParentStackView: UIStackView!
    @IBOutlet weak var stackViewBarCharts: UIStackView!
    @IBOutlet weak var multiplayerPageControl: UIPageControl!
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var holeViewStackView: UIStackView!
    @IBOutlet weak var stackViewForGreenShots: UIStackView!
    @IBOutlet weak var btnImgUpDown: UIButton!
    @IBOutlet weak var scoreTableView: UITableView!
    @IBOutlet weak var btnPlayersStats2: UILocalizedButton!
    @IBOutlet weak var lblCenterHeader: UILabel!
    @IBOutlet weak var fgBConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnShareHoleStats: UIButton!
    @IBOutlet weak var btnRestartShot: UIButton!
    @IBOutlet weak var btnRestartLbl: UIButton!
    @IBOutlet weak var topHoleParView: UIView!
    @IBOutlet weak var topHoleParHCPView: UIView!
    @IBOutlet weak var lblTopPar: UILabel!
    @IBOutlet weak var lblTopHCP: UILabel!
    @IBOutlet weak var btnHole: UILocalizedButton!
    @IBOutlet weak var topParView: UIView!
    @IBOutlet weak var topHCPView: UIView!
    
    @IBOutlet weak var centerSVWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var playerStatsHeightConst: NSLayoutConstraint!
    @IBOutlet weak var playerStatsWidthConst: NSLayoutConstraint!
    @IBOutlet weak var btnClubHeightConst: NSLayoutConstraint!
    @IBOutlet weak var btnClubWidthConst: NSLayoutConstraint!
    @IBOutlet weak var btnTrackShotWidth: NSLayoutConstraint!
    @IBOutlet weak var btnTrackShotHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stableFordView: UIView!
    @IBOutlet weak var btnStableScore: UIButton!
    @IBOutlet weak var lblStblScore: UILabel!
    @IBOutlet weak var imgViewStableFordInfo: UIImageView!
    @IBOutlet weak var imgViewRefreshScore: UIImageView!
    @IBOutlet weak var stablefordSubView: UIView!
    @IBOutlet weak var lblHCPHeader: UILabel!
    
    @IBOutlet weak var btnGolficationX: UIButton!
    
    var isBackground : Bool{
        let state = UIApplication.shared.applicationState
        if state == .background {
            return true
        }else{
            return false
        }
    }
    var totalTimer : TimeInterval = 1
    /*var isGolfX : Bool{
        if Constants.ble == nil{
            return false
        }else{
            return !Constants.ble.isPracticeMatch
        }
    }*/
    var golfXPopupView: UIView!
    var btnRetry: UIButton!
    var btnNoDevice: UIButton!
    var lblScanStatus: UILabel!
    var deviceCircularView: CircularProgress!
    var isDeviceSetup = false
    var swingShotArr = NSArray()
    var isNextPrevBtn = false

    func checkDeviceStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.golficationXDisconnected(_:)), name: NSNotification.Name(rawValue: "GolficationX_Disconnected"), object: nil)
        
        if(Constants.deviceGolficationX == nil){
            self.btnGolficationX.setImage( #imageLiteral(resourceName: "golficationBarG"),for:.normal)
            self.btnGolficationX.isUserInteractionEnabled = true
        }
        else{
            self.btnGolficationX.setImage( #imageLiteral(resourceName: "golficationBar"),for:.normal)
            self.btnGolficationX.isUserInteractionEnabled = false
        }
    }
    @objc func golficationXDisconnected(_ notification: NSNotification) {
        self.btnGolficationX.setImage( #imageLiteral(resourceName: "golficationBarG"),for:.normal)
        self.btnGolficationX.isUserInteractionEnabled = true
    }
    
    //----------------------------------- Amit's Changes -----------------------------
    var sharedInstance: BluetoothSync!
    var timeOutTimer = Timer()

    @IBAction func btnActionGolficationX(_ sender: Any) {
        if(Constants.deviceGolficationX == nil){
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
            self.btnActionBack(self.btnBack)
            break
        case .poweredOn:
            debugPrint("State : Powered On")
            
            if self.deviceGameID == 0{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(self.swingMatchId)/gameId") { (snapshot) in
                    var gameid = 0
                    if (snapshot.value != nil) {
                        gameid = snapshot.value as! Int
                        self.deviceGameID = gameid
                    }
                    DispatchQueue.main.async(execute: {
                        if Constants.ble == nil{
                            Constants.ble = BLE()
                        }
                        Constants.ble.swingMatchId = self.swingMatchId
                        Constants.ble.currentGameId = self.deviceGameID
                        Constants.ble.startScanning()
//                        NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)

                        self.showPopUp()
                        self.sharedInstance.delegate = nil
                    })
                }
            }else{
                if Constants.ble == nil{
                    Constants.ble = BLE()
                }
                Constants.ble.swingMatchId = self.swingMatchId
                Constants.ble.currentGameId = self.deviceGameID
                Constants.ble.startScanning()
//                NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)

                showPopUp()
                self.sharedInstance.delegate = nil
            }
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
    
    func showPopUp(){
        self.timeOutTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SeventyFivePercentUpdated(_:)), name: NSNotification.Name(rawValue: "75_Percent_Updated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScreen(_:)), name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ScanningTimeOut(_:)), name: NSNotification.Name(rawValue: "Scanning_Time_Out"), object: nil)
        
        self.btnGolficationX.setImage(UIImage(named:"golficationBarG"), for: .normal)
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.golfXPopupView = (Bundle.main.loadNibNamed("ScanningGolfX", owner: self, options: nil)![0] as! UIView)
        self.golfXPopupView.frame = self.view.bounds
        self.view.addSubview(self.golfXPopupView)
        setGofXUISetup()
    }
    
    @objc func timerAction() {
        self.timeOutTimer.invalidate()
        self.noDeviceAvailable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        statusStableFord()
        self.navigationController?.navigationBar.isHidden = true
        
        if Constants.isDevice{
            if(Constants.deviceGolficationX != nil){
                updateScreenBLE()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)

        if (selectClubDropper != nil) && (selectClubDropper.status != .hidden){
            selectClubDropper.hide()
        }
        if self.mapTimer.isValid{
            self.mapTimer.invalidate()
        }
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidBecomeActive)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidEnterBackground)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationWillEnterForeground)
        
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(self.selectedUserId)").removeAllObservers()
        UIApplication.shared.isIdleTimerDisabled = false
        
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
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.lblScanStatus.text = "Couldn't find your device"
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.btnRetry.isHidden = false
        self.btnNoDevice.isHidden = false
        self.btnGolficationX.setImage( #imageLiteral(resourceName: "golficationBarG"),for: .normal)
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
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: 0.0, toValue: 0.0)
        self.golfXPopupView.removeFromSuperview()
        Constants.ble.stopScanning()
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateScreen"))
        updateScreenBLE()
    }

    func updateScreenBLE(){
        self.btnGolficationX.setImage( #imageLiteral(resourceName: "golficationBar"), for: .normal)
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.view.makeToast("Device is connected.")
    }
    @objc func retryAction(_ sender: UIButton) {
        self.golfXPopupView.removeFromSuperview()
        btnActionGolficationX(self.btnGolficationX)
        /*if Constants.ble == nil{
            Constants.ble = BLE()
            Constants.ble.isPracticeMatch = false
//            NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
        }
        Constants.ble.startScanning()
        showPopUp()*/
    }
    @objc func chkBluetoothStatus(_ notification: NSNotification) {
        let notifBleStatus = notification.object as! String
        if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_ON"){
        }
        else{
            self.btnGolficationX.setImage(#imageLiteral(resourceName: "golficationBarG"), for: .normal)
            self.btnActionBack(self.btnBack)
        }
    }
    /*@objc func chkBluetoothStatus(_ notification: NSNotification) {
        let notifBleStatus = notification.object as! String
        if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_ON"){
            if(Constants.deviceGolficationX == nil){
                
                DispatchQueue.main.async(execute: {
                    self.btnGolficationX.setImage(#imageLiteral(resourceName: "golficationBarG"), for: .normal)
                })
            }
            else{
                DispatchQueue.main.async(execute: {
                    self.btnGolficationX.setImage(#imageLiteral(resourceName: "golficationBar"), for: .normal)
                    self.view.makeToast("Device is already connected.")
//                    Constants.ble.stopScanning()
                })
            }
        }
        else if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_OFF"){
            self.btnGolficationX.setImage(#imageLiteral(resourceName: "golficationBarG"), for: .normal)
        }else{
            //Constants.ble.stopScanning()
        }
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
    }*/
    @objc func cancelGolfXAction(_ sender: UIButton!) {
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
        golfXPopupView.removeFromSuperview()
    }
    // -------------------------------------- End ---------------------------------------------
    
    
    // MARK:- All PanGesture Related Local Variables
    var panGesture  = UIPanGestureRecognizer()
    var btnPanGesture  = UIPanGestureRecognizer()
    var fgViewPanGesture  = UIPanGestureRecognizer()
    var isUserInsideBound = false
    var circ = GMSCircle()
    private var currentState1: State = .closed
    private var currentState: State = .closed
    
    private var runningAnimators1 = [UIViewPropertyAnimator]()
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    private var animationProgress = [CGFloat]()
    private var animationProgress1 = [CGFloat]()
    
    private var popupOffset = CGFloat()
    private var popupFgOffset = CGFloat()
    let userMarkerView = UserMarker()
    
    // MARK:- All local variable
    var matchDataDict = NSMutableDictionary()
    var noDataLabel = NoDataAvailableLabel()
    var courseData = CourseData()
    var courseId = String()
    var progressView = SDLoader()
    var positionsOfDotLine = [CLLocationCoordinate2D]()
    var positionsOfCurveLines = [CLLocationCoordinate2D]()
    var holeOutFlag = false
    var locationManager = CLLocationManager()
    var holeIndex = 0
    var markers = [GMSMarker]()
    var markersForCurved = [GMSMarker]()
    var line = GMSPolyline()
    var pathOfGreen = GMSMutablePath()
    var isDraggingMarker = false
    var draggingMarker = GMSMarker()
    var suggestedMarkerOffCourse = GMSMarker()
    var btnForSuggMarkOffCourse = SuggestionMarkerView()
    var shotCount = Int()
    var isHoleByHole = false
    var selectClubDropper : Dropper!
    var markerInfo = GMSMarker()
    var markerInfo2 = GMSMarker()

    var markerInfoSwing = GMSMarker()
    var markerInfoSwing2 = GMSMarker()
    
    var curvedLines = GMSPolyline()
    var curvedLine2 = GMSPolyline()
    var penaltyShots = [Bool]()
    var shotViseCurve = [(shot:Int,line:GMSPolyline,markerPosition:GMSMarker,swingPosition:GMSMarker)]()
    var userLocationForClub : CLLocationCoordinate2D?
    var previousUserLocation = CLLocationCoordinate2D()
    
    var clubsWithFullName = [String]()
    var isUpdating :Bool!
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var playerArrayWithDetails = NSMutableDictionary()
    var playersButton = [(button:UIButton,isSelected:Bool,id:String,name:String)]()
    var teeTypeArr = [(tee:String,color:String,handicap:Double)]()
    var stblefordScore = [(hole:Int,sFPoint:Int,newScore:Int,totalsShot:Int)]()
    var currentMatchId = String()
    var holeOutCount = Int()
    var gir = Bool()
    var player = NSMutableDictionary()
    var selectedUserId = String()
    var playerShotsArray = [NSMutableDictionary]()
    var isProcessing = false
    var isTracking = false
    var isAcceptInvite = false
    var swingMatchId = String()
    fileprivate var places = [Place]()
    var shotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
    var isContinue = false
    let swipeUp = UISwipeGestureRecognizer()
    let swipeDown = UISwipeGestureRecognizer()
    var userMarker = GMSMarker()
    var trackingMarker = GMSMarker()
    var isPintMarker = false
    var multiplayerButtons = [UIButton]()
    var tappedMarker : GMSMarker!
    var tempPlayerData = NSDictionary()
    var holeOutforAppsFlyer = [Int]()
    var mapTimer = Timer()
    var allMarkers = [GMSMarker]()
    var isOnCourse = false
    var suggestedMarker1 = GMSMarker()
    var suggestedMarker2 = GMSMarker()
    var btnForSuggMark1 = UIButton()
    var btnForSuggMark2 = UIButton()
    var isShowcase = false
    var isShowcaseFlag = false
    var isStopShotCT = false
    var dragMarkShowCase : GMSMarker!
    var windHeading = Double()
    var btnUserSmall = UIButton()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var shotForEdit : Int!
    var swingData = [[Any]]()
    var startingIndex = Int()
    var gameTypeIndex = Int()
    var isDeviceConnected = false
    
    @IBOutlet weak var greenStackViewHeight: NSLayoutConstraint!
    // Mark :- GetTableContentHeight
    var tableViewHeight: CGFloat {
        scoreTableView.layoutIfNeeded()
        var height = scoreTableView.contentSize.height
        self.scoreTableView.isScrollEnabled = false
        if(self.playersButton.count > 1){
            if(height > 150){
                height = 150
                self.scoreTableView.isScrollEnabled = true
            }
        }else{
            if(height > 280){
                height = 280
                self.scoreTableView.isScrollEnabled = true
            }
        }
        return height
    }
    
    var playerIndex : Int{
        var inde = 0
        for players in playersButton{
            if(players.isSelected){
                let playerId = players.id
                if self.scoring.count != 0{
                    for i in 0..<self.scoring[self.holeIndex].players.count{
                        if((self.scoring[self.holeIndex].players[i].value(forKey: playerId)) != nil){
                            inde = i
                            break
                        }
                    }
                }

            }
        }
        return inde
    }
    var allWaterHazard = [[CLLocationCoordinate2D]]()
    // Mark :- bot Related Variables
    var botStrokesGained = Double()
    var botSGPutting = Double()
    var maxDrive = Double()
    var avgDrive = Double()
    var girWithFairway = Double()
    var girWithoutFairway = Double()
    var isBotTurn = false
    let distanceFairway = NSMutableDictionary()
    let distanceRough = NSMutableDictionary()
    var gir3Perc = Double()
    var fairwayHitPerc = Double()
    var fairwayLeftPerc = Double()
    var fairwayRightPerc = Double()
    var allPolygonOfOneHole = [GMSPolygon]()
    
    var glfButtonMapShotRanking: UIColor {
        return UIColor(red: 0/255.0, green: 197.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    }
    var glfMapBG: UIColor {
        return UIColor(red: 0/255.0, green: 108.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    }
    
    var swingMarker = GMSMarker()
    var swingMarker2 = GMSMarker()
    
    @objc func swipedViewUp(){
        if self.viewHoleStats.isHidden{
            btnActionPlayerStats(Any.self)
        }
    }
    @objc func swipedViewDown(){
        if !self.viewHoleStats.isHidden{
            btnActionPlayerStats(Any.self)
        }
    }
    func saveNExitPressed(button:UIButton) {
        if(self.swingMatchId.count > 0){
            checkScoringData()
        }
        else{
            saveData()
        }
    }
    
    var isSyncd = false
    var unSyncdIndex = 0
    
    func checkScoringData(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(self.currentMatchId)/scoring") { (snapshot) in
            
            var scoringArray =  NSArray()
            if snapshot.value != nil{
                scoringArray = snapshot.value as! NSArray
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if scoringArray.count>0{
                    for i in 0..<scoringArray.count{
                        let dic = scoringArray[i] as! NSDictionary
                        for (key,value) in dic{
                            if key as! String == Auth.auth().currentUser!.uid{
                                let keyVal = value as! NSDictionary
                                if keyVal.value(forKey: "holeOut") as! Bool == true{
                                    if let shotsArray = keyVal.value(forKey: "shots") as? NSMutableArray{
                                        for j in 0..<shotsArray.count{
                                            let myDic = shotsArray[j] as! NSDictionary
                                            if let distance = myDic.value(forKey: "distance") as? Double
                                            {
                                                debugPrint("distance",distance)
                                                self.isSyncd = true
                                            }
                                            else{
                                                self.unSyncdIndex = i+1
                                                self.isSyncd = false
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if self.unSyncdIndex>0 && !self.isSyncd{
                    self.exitGamePopUpView.hide(navItem: self.navigationItem)
                    let emptyAlert = UIAlertController(title: "Alert", message: "Please sync hole \(self.unSyncdIndex)", preferredStyle: UIAlertControllerStyle.alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
                else{
                    self.saveData()
                }
            })
        }
    }
    
    func saveData(){
        var playerIndex = Int()
        if(self.swingMatchId.count > 0){
            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        
        for data in self.playersButton{
            if(data.id == Auth.auth().currentUser!.uid){
                break
            }
            playerIndex += 1
        }
        FBSomeEvents.shared.logGameEndedEvent(holesPlayed: self.holeOutforAppsFlyer[playerIndex], valueToSum: 1)
        if(self.holeOutforAppsFlyer[playerIndex] > 8){
            self.saveAndviewScore()
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        }
        debugPrint("SaveNExit Tapped")
        self.exitGamePopUpView.hide(navItem: self.navigationItem)

    }
    func discardPressed(button:UIButton) {
        debugPrint("discard Tapped")
        self.exitGamePopUpView.hide(navItem: self.navigationItem)
        self.exitWithoutSave()
    }
    
    var engine: ARKitEngine!
    var points: [Any]!
    var arSelectedIndex: NSInteger!
    var currentDetailView :DetailView!
    var boxViews = [UIView]()
    
    // MARK:- btnVRView
    @IBAction func btnVRAction(_ sender: Any) {
        //https://github.com/calonso/ios-arkit
        arSelectedIndex = -1
        
        var teeCoord = [CLLocationCoordinate2D]()
        var gbCoord = [CLLocationCoordinate2D]()
        var fbCoord = [CLLocationCoordinate2D]()
        var hzCoord = [CLLocationCoordinate2D]()
        var pointData = [(name:String,location:CLLocation)]()
        
        points = [Any]()
        var locations = [CLLocationCoordinate2D]()
        for i in 0..<courseData.numberOfHoles[holeIndex].tee.count{
            let holeIndex = (self.holeIndex) % courseData.numberOfHoles.count
            let name = "Tee"
            teeCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: courseData.numberOfHoles[holeIndex].tee[i]))
            let flagCoordinates = teeCoord[i]
            let latitude = flagCoordinates.latitude
            let longitude = flagCoordinates.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            locations.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            let place = Place(location: location, reference: "reference", name: name, address: "address" )
            self.places.append(place)
            pointData.append((name: name, location: location))
            break
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].gb.count{
            let name = "Bunker"
            gbCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: courseData.numberOfHoles[holeIndex].gb[i]))
            let flagCoordinates = gbCoord[i]
            let latitude = flagCoordinates.latitude
            let longitude = flagCoordinates.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            locations.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            let place = Place(location: location, reference: "reference", name: name, address: "address" )
            self.places.append(place)
            pointData.append((name: name, location: location))
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].fb.count{
            let name = "Bunker"
            fbCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: courseData.numberOfHoles[holeIndex].fb[i]))
            let flagCoordinates = fbCoord[i]
            let latitude = flagCoordinates.latitude
            let longitude = flagCoordinates.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            locations.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            let place = Place(location: location, reference: "reference", name: name, address: "address" )
            self.places.append(place)
            pointData.append((name: name, location: location))
        }
        for data in allWaterHazard{
            let name = "Hazard"
            hzCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: data))
            let flagCoordinates = hzCoord.last!
            let latitude = flagCoordinates.latitude
            let longitude = flagCoordinates.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            locations.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            let place = Place(location: location, reference: "reference", name: name, address: "address" )
            self.places.append(place)
            pointData.append((name: name, location: location))
        }
        
        let flagCoordinates = courseData.centerPointOfTeeNGreen[holeIndex].green
        let name = "Green"
        let latitude = flagCoordinates.latitude
        let longitude = flagCoordinates.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        locations.append(CLLocationCoordinate2D(latitude: flagCoordinates.latitude, longitude: flagCoordinates.longitude))
        let place = Place(location: location, reference: "reference", name: name, address: "address")
        self.places.append(place)
        pointData.append((name: name, location: location))
        
        var alt = 0.0
        locationManager.startUpdatingLocation()
        if let currentLocation: CLLocation = self.locationManager.location{
            alt = currentLocation.altitude
        }
        var arr = [(name:String,location:CLLocation)]()
        for _ in 0..<places.count{
            if locations.count != 0{
                let index = BackgroundMapStats.nearByPoint(newPoint: self.userLocationForClub!, array: locations)
                arr.append(pointData[index])
                pointData.remove(at: index)
                locations.remove(at: index)
            }
        }
        
        for i in 0..<arr.count{
            let location = CLLocation(coordinate: arr[i].location.coordinate, altitude: alt, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
            alt += 1
            let point = ARGeoCoordinate(location:location)!
            point.dataObject = arr[i].name
            self.points.append(point)
        }
        
        let config = ARKitConfig.defaultConfig(for: self)
        config?.orientation = self.interfaceOrientation
        //config?.useAltitude = true
        let s :CGSize = UIScreen.main.bounds.size
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            config?.radarPoint = CGPoint(x:s.width - 50, y:s.height - 50);
        } else {
            config?.radarPoint = CGPoint(x:s.height - 50, y:s.width - 50);
        }
        
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.setImage(UIImage(named: "cross"), for: .normal)
        closeBtn.sizeToFit()
        closeBtn.addTarget(self, action: #selector(self.closeAr(_:)), for: .touchUpInside)
        
        closeBtn.center = CGPoint(x:25, y:25)
        self.boxViews = [UIView]()
        
        /*if self.positionsOfCurveLines.count>1{
         for i in 0..<positionsOfCurveLines.count{
         let lat = positionsOfCurveLines[i].latitude
         let long = positionsOfCurveLines[i].longitude
         
         let location = CLLocation(latitude: lat, longitude: long)
         let curvePoints = ARGeoCoordinate(location:location)!
         curvePoints.dataObject = ""
         self.points.append(curvePoints)
         }
         }*/
        engine = ARKitEngine.init(config: config!)
        //        engine.numberOfCurve = positionsOfCurveLines.count
        engine.addCoordinates(points! as NSArray)
        engine.settingUnit = Constants.distanceFilter
        engine.addExtraView(closeBtn)
        engine.startListening()
        
        
        //         if #available(iOS 11.0, *) {
        //         let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "ARPlanViewController") as! ARPlanViewController
        //         viewCtrl.places = self.places
        //         viewCtrl.positionsOfCurveLines = self.positionsOfCurveLines
        //         self.navigationController?.pushViewController(viewCtrl, animated: true)
        //         }
    }

    @objc func closeAr(_ sender: UIButton) {
          engine.hide()
    }
    
    func view(for coordinate: ARGeoCoordinate!, floorLooking: Bool) -> ARObjectView! {
        
        let text = coordinate.dataObject as! String
        
        let distance = coordinate.baseDistance
        debugPrint("mydistance:",distance)
        
        var view: ARObjectView? = nil
        
        if (floorLooking) {
            let arrowImg = UIImage(named: "arrow.png")
            
            let arrowView = UIImageView.init(image: arrowImg)
            view = ARObjectView.init(frame: arrowView.bounds)
            view?.addSubview(arrowView)
            view?.displayed = false
        } else {
            
            let boxView = UIImageView.init(image: UIImage(named: "open_markerAR"))
            
            let imgViewInner = UIImageView()
            debugPrint(text)
            if text.contains("Bunker"){
                imgViewInner.image = UIImage(named: "bunkerAR")
            }else if text.contains("Hazard"){
                imgViewInner.image = UIImage(named: "hazardAR")
            }else if text.contains("Green"){
                imgViewInner.image = UIImage(named: "greenAR")
            }else if text.contains("userShot"){
                imgViewInner.image = UIImage(named: "user_targetAR")
            }else if text.contains("Tee"){
                imgViewInner.image = UIImage(named: "teeAR")
            }
            imgViewInner.frame = CGRect(x: 14.5, y: 10, width: 25, height: 25)
            boxView.addSubview(imgViewInner)
            
            let lbl = UILabel.init(frame: CGRect(x:50, y:0, width:boxView.frame.size.width-50, height:50))
            lbl.font = UIFont.systemFont(ofSize: 13.0)
            lbl.minimumScaleFactor = 2.0
            lbl.backgroundColor = UIColor.clear
            lbl.textColor = UIColor.white
            lbl.textAlignment = .left
            lbl.numberOfLines = 0
            boxView.addSubview(lbl)
            boxView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            boxViews.append(boxView)
            view = ARObjectView.init(frame: boxView.frame)
            view?.addSubview(boxView)
        }
        view?.sizeToFit()
        return view
    }
    
    func itemTouched(with index: Int) {
        /*arSelectedIndex = index
         let name = engine.dataObject(with: index) as! String
         currentDetailView = Bundle.main.loadNibNamed("DetailView", owner: self, options: nil)![0] as? DetailView
         
         currentDetailView.nameLbl.text = name
         engine.addExtraView(currentDetailView)*/
        
        debugPrint("index:",index)
        let view = self.boxViews[index]
        var open = true
        for lbl in view.subviews{
            if (lbl.isKind(of: UILabel.self)){
                if lbl.isHidden{
                    lbl.isHidden = false
                    (view as! UIImageView).image = UIImage(named: "open_markerAR")
                    open = true
                }else{
                    lbl.isHidden = true
                    (view as! UIImageView).image = UIImage(named: "Collapsed_markerAR")
                    open = false
                }
            }
        }
        view.contentMode = .scaleAspectFit
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        for img in view.subviews{
            if (img.isKind(of: UIImageView.self)){
                if !open{
                    img.center = view.center
                }else{
                    img.frame.origin = CGPoint(x:14.5,y:10.5)
                }
            }
        }
        view.layoutIfNeeded()
    }
    func didChangeLooking(_ floorLooking: Bool) {
        if (floorLooking) {
            if (arSelectedIndex != -1) {
                currentDetailView.removeFromSuperview()
                let floorView = engine.floorView(with: arSelectedIndex)
                floorView?.displayed = true
            }
        } else {
            if (arSelectedIndex != -1) {
                let floorView = engine.floorView(with: arSelectedIndex)
                floorView?.displayed = false
                arSelectedIndex = -1;
            }
        }
    }
    // -----------------------------------------------------------------------
    
    @IBAction func btnActionRetry(_ sender: Any) {
        debugPrint("Cancle Pressed")
        self.isTracking = false
        if(!self.positionsOfDotLine.isEmpty){
            self.positionsOfDotLine.remove(at: 0)
        }
        if(isPintMarker){
            isPintMarker = false
            self.btnNext.isHidden = false
            self.btnPrev.isHidden = false
            self.btnPrevScrl.isHidden = false
            self.btnNextScrl.isHidden = false
        }
        
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(Auth.auth().currentUser!.uid)/shotTracking").setValue(nil)
        self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
        self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
        if(!self.positionsOfCurveLines.isEmpty){
            self.positionsOfDotLine.insert(positionsOfCurveLines.last! , at: 0)
        }else{
            self.positionsOfDotLine.insert( courseData.centerPointOfTeeNGreen[self.holeIndex].tee, at: 0)
        }
        
        for i in 0..<self.scoring[self.holeIndex].players.count{
            if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                if let playerDict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as? NSMutableDictionary{
                    debugPrint(playerDict)
                    playerDict.removeObject(forKey: "shotTracking")
                    self.scoring[self.holeIndex].players[i].setValue(playerDict, forKey: self.selectedUserId)
                    
                }
            }
        }
        self.updateMap(indexToUpdate: self.holeIndex)
        self.btnRestartLbl.isHidden = true
        self.btnRestartShot.isHidden = true
    }
    @IBAction func btnActionShareHoleStats(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ShareMapScoreVC") as! ShareMapScoreVC
        viewCtrl.shareMapView = self.mapView
        viewCtrl.isVertical = false
        debugPrint("shotsCount: \(self.shotsDetails.count)")
        let tempView = UIView(frame:self.mapView.frame)
        let imgView = UIImageView(image: self.scoreTableView.screenshot())
        let lbls = UILabel(frame:CGRect(x: 0, y: 0, width: tempView.frame.width, height: 30))
        if(self.btnShotRanking.currentTitle != nil){
            lbls.text = "You Scored a \(self.btnShotRanking.currentTitle!.trim())"
        }
        lbls.textAlignment = .center
        let newlbl = UILabel(frame:CGRect(x: 0, y: 0, width: tempView.frame.width, height: 30))
        newlbl.text = "Hole".localized() + " \(self.scoring[self.holeIndex].hole) - " + "Par".localized() + " \(self.scoring[self.holeIndex].par)"

        newlbl.textAlignment = .center
        let youSc = UIImageView(image: lbls.screenshot())
        let title = UIImageView(image: newlbl.screenshot())
        
        let lbl = UILabel(frame:CGRect(x: 0, y: 0, width: tempView.frame.width, height: 30))
        lbl.text = (self.matchDataDict.value(forKey: "courseName") as! String)
        lbl.textAlignment = .center
        lbl.font = UIFont(name:"SFProDisplay-Bold", size: 14)!
        
        imgView.center = tempView.center
        
        youSc.center = tempView.center
        youSc.center.y = imgView.frame.minY - youSc.frame.height
        
        title.center = tempView.center
        title.center.y = youSc.frame.minY - title.frame.height
        
        lbl.center = tempView.center
        lbl.center.y = title.frame.minY - lbl.frame.height
        
        
        
        tempView.addSubview(imgView)
        tempView.addSubview(youSc)
        tempView.addSubview(title)
        tempView.addSubview(lbl)
        
        
        viewCtrl.screenShot1 = tempView.screenshot()
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        navCtrl.modalPresentationStyle = .overCurrentContext
        self.present(navCtrl, animated: false, completion: nil)
    }
    
    @IBAction func btnActionPlayerStats(_ sender: Any) {
        
        if(self.viewHoleStats.isHidden){
            
            self.btnPlayersStats.isHidden = true
            self.lblShotNumber.isHidden = true
            self.lblEditShotNumber.isHidden = true
            self.btnTrackShot.isHidden = true
            self.btnPrev.isHidden = true
            self.btnNext.isHidden = true
            self.btnMultiplayerLbl.isHidden = true
            self.btnMultiplayer.isHidden = true
            self.btnShareShot.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            self.viewHoleStats.isHidden = false
            self.scoreTableView.reloadData()
            self.constraintTableHeight.constant = tableViewHeight
            self.multiplayerPageControl.isHidden = true
            self.lblRaceToFlagTitle.isHidden = true
            self.barChartParentStackView.isHidden = true
            self.stableFordView.isHidden = !self.holeOutFlag || chkStableford
            if(self.playersButton.count > 1){
                self.updateRaceToFlag()
                if (btnMultiplayer.tag == 1){
                    self.btnActionMultiplayer(btnMultiplayer)
                }
                for play in playersButton{
                    if (play.isSelected){
                        if !self.viewHoleStats.isHidden{
                            self.playersAction(sender: multiplayerButtons[play.button.tag])
                        }
                        break
                    }
                }
            }
            if(selectClubDropper.status == .shown) || (selectClubDropper.status == .displayed){
                selectClubDropper.hideWithAnimation(0.15)
            }
            self.stackViewForGreenShots.isHidden = true
            if(isPintMarker){
                self.btnPrevScrl.isHidden = true
                self.btnNextScrl.isHidden = true
            }else{
                self.btnPrevScrl.isHidden = false
                self.btnNextScrl.isHidden = false
            }
            if !self.swingMatchId.isEmpty{
                self.hideWhenDeviceConnected()
            }
        }else{
            self.stackViewForGreenShots.isHidden = false
            self.btnPlayersStats.isHidden = false
            self.lblShotNumber.isHidden = holeOutFlag
            self.lblEditShotNumber.isHidden = (holeOutFlag && !isHoleByHole) ? false : true
            self.btnTrackShot.isHidden = isHoleByHole ? true:false
            self.btnPrev.isHidden = false
            self.btnNext.isHidden = false
            self.btnShareShot.isHidden = (shotCount>1 && !isHoleByHole) ? false:true
            if(self.playersButton.count > 1){
                self.btnMultiplayer.isHidden = false
                self.btnMultiplayerLbl.isHidden = false
            }else{
                self.btnMultiplayer.isHidden = true
                self.btnMultiplayerLbl.isHidden = true
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(value: Bool) in
                self.viewHoleStats.isHidden = true
            })
            
            if(isPintMarker){
                self.btnPrev.isHidden = true
                self.btnNext.isHidden = true
            }else{
                self.btnPrev.isHidden = false
                self.btnNext.isHidden = false
            }
        }
    }
    
    // MARK:- btnMapViewStylized
    @IBAction func btnActionMV(_ sender: Any) {
        self.getBezierPathAllFeatures()
        if self.btnStylizedMapView.tag == 0{
            self.allPolygonOfOneHole.removeAll()
            self.updateMapWithColors()
            self.btnStylizedMapView.tag = 1
        }else{
            self.btnStylizedMapView.tag = 0
            circ.map = nil
            for poly in allPolygonOfOneHole{
                poly.map = nil
            }
            //            self.updateMap(indexToUpdate: self.holeIndex)
        }
        //        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
        //        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
    }
    // MARK:- btnActionPrevHole
    @IBAction func btnActionPrevHole(_ sender: Any) {
        isNextPrevBtn = true
        
        holeIndex -= 1
        if(holeIndex == -1){
            holeIndex = self.scoring.count - 1
        }
        if(!isHoleByHole){
            self.updateMap(indexToUpdate: holeIndex)
            self.updateCurrentHole(index: holeIndex)
        }else{
            var playerId : String!
            var totalShots = 0
            for players in playersButton{
                if(players.isSelected){
                    playerId = players.id
                    for i in 0..<self.scoring[holeIndex].players.count{
                        if let dict = self.scoring[holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary{
                            if let shotsArr = dict.value(forKey: "shots") as? [NSMutableDictionary]{
                                totalShots = shotsArr.count
                            }
                            break
                        }
                    }
                }
            }
            if(totalShots != 0){
                self.updateMap(indexToUpdate: holeIndex)
            }else{
                btnActionPrevHole(Any.self)
            }
        }
    }
    // MARK:- btnActionNextHole
    @IBAction func btnActionNextHole(_ sender: Any) {
        isNextPrevBtn = true
        holeIndex += 1
        if(holeIndex == self.scoring.count){
            holeIndex = 0
        }
        if(!isHoleByHole){
            self.updateMap(indexToUpdate: holeIndex)
            self.updateCurrentHole(index: holeIndex)
        }else{
            var playerId : String!
            var totalShots = 0
            for players in playersButton{
                if(players.isSelected){
                    playerId = players.id
                    for i in 0..<self.scoring[holeIndex].players.count{
                        if let dict = self.scoring[holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary{
                            if let shotsArr = dict.value(forKey: "shots") as? [NSMutableDictionary]{
                                totalShots = shotsArr.count
                            }
                            break
                        }
                    }
                }
            }
            if(totalShots != 0){
                self.updateMap(indexToUpdate: holeIndex)
            }else{
                btnActionNextHole(Any.self)
            }
        }
        if(holeIndex == 0) && !isHoleByHole{
            self.holeOutforAppsFlyer[self.playerIndex] = self.checkHoleOutZero(playerId: Auth.auth().currentUser!.uid)
            if(self.holeOutforAppsFlyer[self.playerIndex] == self.scoring.count){
                self.btnActionEndRound(self.btnEndRound)
            }
        }
    }
    // MARK:- backbtnAction
    @IBAction func btnActionBack(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: NewGameVC.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: !self.isAcceptInvite)
                break
            }
        }
        if(isHoleByHole){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnActionClubSelection(_ sender: UIButton) {
        selectClubDropper.maxHeight = 300
        if selectClubDropper.status == .hidden {
            selectClubDropper.theme = Dropper.Themes.white
            selectClubDropper.cornerRadius = 3
            selectClubDropper.delegate = self
            selectClubDropper.cellVisibility = true
            selectClubDropper.showWithAnimation(0.15, options: .left, position: .top, button: self.btnSelectClubs)
        } else {
            selectClubDropper.hideWithAnimation(0.1)
        }
    }
    
    @IBAction func btnActionEditLandedOn(_ sender: UIButton) {
        ActionSheetStringPicker.show(withTitle: "Landed On", rows: ["Fairway".localized(),"Green".localized(),"Bunker".localized(),"Rough".localized(),"Water Hazard".localized()], initialSelection: sender.tag, doneBlock: { (picker, value, index) in
            sender.setTitle("\(index!)", for: .normal)
            self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
            self.setColorLandedOn(index:index as! String)
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin:sender)
    }
    // MARK: - btnActionFinishRound
    
    @IBAction func btnActionEndRound(_ sender: Any) {
        if !self.swingMatchId.isEmpty{
            //changed by Amit
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EndRound"), object: nil)

            let alertVC = UIAlertController(title: "Alert", message: "Please End this round from previous screen.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                self.navigationController!.popViewController(animated: true)
            })
            let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                debugPrint("Cancelled")
            })
            alertVC.addAction(cancelOption)
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }else{
            var playerIndex = 0
            var i = 0
            for data in self.playersButton{
                self.holeOutforAppsFlyer[i] = self.checkHoleOutZero(playerId: data.id)
                if(data.id == Auth.auth().currentUser!.uid){
                    playerIndex = i
                }
                i += 1
            }
            self.exitGamePopUpView.labelText = "\(self.holeOutforAppsFlyer[playerIndex])/\(scoring.count) " + "holes completed".localized()
            if Constants.isEdited{
                self.exitGamePopUpView.btnDiscardText = "Delete Round"
            }
            self.exitGamePopUpView.isHidden = false
        }
    }
    func exitWithoutSave(){
        self.updateFeedNode()
        if(Constants.matchId.count > 1){
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            if(Constants.matchId.count > 1){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(Constants.matchId)").removeValue()
            }
            Constants.matchId.removeAll()
            Constants.isUpdateInfo = true
            self.navigationController!.popToRootViewController(animated: true)
            Constants.addPlayersArray.removeAllObjects()
            if(self.swingMatchId.count > 0){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
                //Constants.ble.discardGameFromDevice()
            }
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
        
//        if(self.swingMatchId.count > 0){
//            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
//        }
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        let generateStats = GenerateStats()
        generateStats.matchKey = Constants.matchId
        generateStats.generateStats()
    }
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.hide(navItem: self.navigationItem)
        
        if(Constants.matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(Constants.matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        if Constants.matchId.count > 1{
            ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
            if !Constants.isProMode{
                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["summaryTimer":Timestamp])
            }
        }
        Constants.addPlayersArray = NSMutableArray()
        self.updateFeedNode()
        Constants.isUpdateInfo = true
        if Constants.mode>0{
            Analytics.logEvent("mode\(Constants.mode)_game_completed", parameters: [:])
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        if(Constants.matchId.count > 1){
            self.gotoFeedBackViewController(mID: Constants.matchId,mode:Constants.mode)
        }
    }
    func sendMatchFinishedNotification(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser?.uid ?? "user1")/friends") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            
            let group = DispatchGroup()
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            for data in dataDic{
                group.enter()
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(Constants.selectedGolfName).", type: "8", category: "finishedGame", matchDataId: self.currentMatchId, feedKey:"")
                group.leave()
            }
            
            group.notify(queue: .main){
                self.progressView.hide(navItem: self.navigationItem)
            }
        }
    }
    func updateFeedNode(){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(self.matchDataDict.value(forKey: "timestamp") as Any, forKey: "timestamp" as NSCopying)
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
            let players = NSMutableArray()
            let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
            if(self.matchDataDict.object(forKey: "player") != nil){
                let tempArray = self.matchDataDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    if(k as! String == Auth.auth().currentUser!.uid){
                        dict.addEntries(from: ["status":4])
                    }
                    players.add(dict)
                }
            }
            viewCtrl.finalPlayersData = players
            viewCtrl.finalScoreData = self.scoring
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            viewCtrl.fromGameImprovement = true
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.scoring.removeAll()
            Constants.matchId.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }
    @IBAction func btnActionViewScoreCard(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = self.scoring
        let players = NSMutableArray()
        var selectedTee = [(tee:String,color:String,handicap:Double)]()
        if(self.matchDataDict.object(forKey: "player") != nil){
            let tempArray = matchDataDict.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                players.add(dict)
            }
        }
        viewCtrl.playerData = players
        for data in players{
            if let player = data as? NSMutableDictionary{
                var teeOfP = String()
                if let tee = player.value(forKeyPath: "tee") as? String{
                    teeOfP = tee
                }
                var teeColorOfP = String()
                if let tee = player.value(forKeyPath: "teeColor") as? String{
                    teeColorOfP = tee
                }
                var handicapOfP = Double()
                if let hcp = player.value(forKeyPath: "handicap") as? String{
                    handicapOfP = Double(hcp)!
                }
                if(teeOfP != ""){
                    selectedTee.append((tee: teeOfP,color:teeColorOfP, handicap: handicapOfP))
                }
            }
        }
        viewCtrl.holeHcpWithTee = self.courseData.holeHcpWithTee
        viewCtrl.teeTypeArr = selectedTee
        viewCtrl.isContinue = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    @objc func reinstateBackgroundTask() {
        if backgroundTask == UIBackgroundTaskInvalid{
            registerBackgroundTask()
        }
    }
    @objc func appDidEnterBackground() {
        let thePresenter = self.navigationController?.visibleViewController
        if (thePresenter != nil) && (thePresenter?.isKind(of:NewMapVC.self))! {
            if Constants.onCourseNotification == 0{
                self.mapTimer.invalidate()
            }else{
                self.totalTimer = 60
                self.updateMap(indexToUpdate: self.holeIndex)
            }
        }else{
            self.mapTimer.invalidate()
        }
    }
    @objc func appDidEnterForeground(){
        let thePresenter = self.navigationController?.visibleViewController
        if (thePresenter != nil) && (thePresenter?.isKind(of:NewMapVC.self))! {
            self.view.makeToast("gathering location please wait........", duration: 2.0, position: .bottom)
            self.mapTimer.invalidate()
            self.totalTimer = 1
            self.updateMap(indexToUpdate: self.holeIndex)
        }else{
            self.mapTimer.invalidate()
        }
        self.checkCurrentLocation()
    }
    func checkCurrentLocation(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            break
            
        case .restricted, .denied:
            let alert = UIAlertController(title: "Need Authorization or Enable GPS from Privacy Settings", message: "This game mode is unusable if you don't authorize this app or don't enable GPS", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.btnActionBack(self.btnBack)
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Do Nothing
            break
        }
    }
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)

        if let onCourse = self.matchDataDict.value(forKeyPath: "onCourse") as? Bool{
            self.isOnCourse = onCourse
            if Constants.deviceGolficationX != nil && isDeviceConnected{
                self.btnGolficationX.isHidden = false
//                self.btnGolficationX.isUserInteractionEnabled = false
            }else if isDeviceConnected{
                if Constants.deviceGolficationX == nil{
                    self.btnGolficationX.setImage(UIImage(named: "golficationBarG"), for: .normal)
//                    self.btnGolficationX.isUserInteractionEnabled = true
                }
            }else if isContinue && Constants.deviceGolficationX != nil && !isDeviceConnected{
                self.btnGolficationX.isHidden = false
//                self.btnGolficationX.isUserInteractionEnabled = false
            }
//            self.checkDeviceStatus()
        
        }
        // for BluetoothChecking
        // register background task
        if(isOnCourse){
            if Constants.onCourseNotification == 1{
                self.registerBackgroundTask()
            }
        }
        self.mapView.delegate = self
        self.initialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.doAfterResponse(_:)), name: NSNotification.Name(rawValue: "response9"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendNotificationOnCourse(_:)), name: NSNotification.Name(rawValue: "updateLocation"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopTrackingFromNotification(_:)), name: NSNotification.Name(rawValue: "shotTracking"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHoleFromNotification(_:)), name: NSNotification.Name(rawValue: "holeChange"),object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.shareShotsDissmiss(_:)), name: NSNotification.Name(rawValue: "ShareShots"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideStableFord(_:)), name: NSNotification.Name(rawValue: "hideStableFord"),object: nil)

        if(!self.isHoleByHole){
            self.startingIndex = Int(self.matchDataDict.value(forKeyPath: "startingHole") as? String ?? "1") ?? 1
            self.gameTypeIndex = self.matchDataDict.value(forKey: "matchType") as! String == "9 holes" ? 9:18
            self.courseData.startingIndex = self.startingIndex
            self.courseData.gameTypeIndex = self.gameTypeIndex
        }else{
            if let players = self.matchDataDict.value(forKeyPath: "player") as? NSMutableDictionary{
                for data in players{
                    if ((data.value as! NSMutableDictionary).value(forKey: "id") as! String) == Auth.auth().currentUser!.uid{
                        if let swingKey = (data.value as! NSMutableDictionary).value(forKey: "swingKey") as? String{
                            self.swingMatchId = swingKey
                            self.getSwingData(swingKey: swingKey)
                            break
                        }
                    }
                }
            }
        }
        courseId = "course_\(self.matchDataDict.value(forKeyPath: "courseId") as! String)"
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMap(_:)), name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        if self.courseData.numberOfHoles.count != 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        }else{
            self.courseData.getGolfCourseDataFromFirebase(courseId: courseId)
        }
    }
    @objc func hideStableFord(_ notification:NSNotification){
        let alertVC = UIAlertController(title: "Thank you for your time!", message: "Stableford scoring for your course should be available in the next 48 hours!", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        self.chkStableford = true
        self.stableFordView.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideStableFord"), object: nil)
    }
    @IBAction func btnActionStableford(_ sender: UIButton) {
        if self.teeTypeArr.isEmpty{
            self.ifnoStableFord()
        }else{
            var netScore : Int!
            var sbScore : Int!
            
            for data in self.scoring[self.holeIndex].players{
                if let dataDic = data.value(forKey: self.selectedUserId) as? NSMutableDictionary{
                    if let netScoring = dataDic.value(forKey: "netScore") as? Int{
                        netScore = netScoring
                    }
                    if let netScoring = dataDic.value(forKey: "stableFordPoints") as? Int{
                        sbScore = netScoring
                    }
                }
            }
            if self.btnStableScore.currentTitle!.contains("Stable"){
                self.btnStableScore.setTitle("Net Score".localized(), for: .normal)
                self.lblStblScore.text = "\(netScore ?? 0)"
            }else if self.btnStableScore.currentTitle!.contains("Net"){
                self.btnStableScore.setTitle("Stableford Score", for: .normal)
                self.lblStblScore.text = "\(sbScore!)"
            }
        }
    }
    var chkStableford = false
    func statusStableFord(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == Constants.selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.stableFordView.isHidden = self.chkStableford
            })
        }
    }
    func ifnoStableFord(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == Constants.selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if !self.chkStableford{
                    let viewCtrl = RequestSFPopup(nibName:"RequestSFPopup", bundle:nil)
                    viewCtrl.modalPresentationStyle = .overCurrentContext
                    self.present(viewCtrl, animated: true, completion: nil)
                }else{
                    self.stableFordView.isHidden = self.chkStableford
                }
            })
        }
    }
    @objc func shareShotsDissmiss(_ notification:NSNotification){
        self.updateMap(indexToUpdate: self.holeIndex)
    }
    
    @objc func sendNotificationOnCourse(_ notification:NSNotification){
        self.locationManager.startUpdatingLocation()
        var distance  = GMSGeometryDistance(self.positionsOfDotLine.last!,self.userLocationForClub!)
        var suffix = "meter"
        if(Constants.distanceFilter != 1){
            distance = distance*Constants.YARD
            suffix = "yard"
        }
        Notification.sendGameDetailsNotification(msg: "Hole \(self.scoring[self.holeIndex].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDict.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking,isHole: self.holeOutFlag)
        debugPrint("distance",distance)
    }
    @objc func stopTrackingFromNotification(_ notification:NSNotification){
        self.btnActionTrackShots(self.btnTrackShot)
        self.sendNotificationOnCourse(notification)
    }
    @objc func changeHoleFromNotification(_ notification:NSNotification){
        if let nextOrPrev = notification.object as? String{
            if(nextOrPrev == "next"){
                self.btnActionNextHole(Any.self)
            }else{
                self.btnActionPrevHole(Any.self)
            }
        }
    }
    @objc func doAfterResponse(_ notification:NSNotification){
        if (notification.object as? Bool) != nil{
            if self.scoring.count != 0{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(self.selectedUserId)") { (snapshot) in
                    var playersData = NSMutableDictionary()
                    if let dict = snapshot.value as? NSMutableDictionary{
                        playersData = dict
                    }
                    DispatchQueue.main.async(execute: {
                        var holeOut = false
                        var wantToDrag = false
                        var shots = [NSMutableDictionary]()
                        if let sho = playersData.value(forKey: "shots") as? NSArray{
                            wantToDrag = sho.count > 0 ? true:false
                            for i in 0..<sho.count{
                                let shot = sho[i] as! NSMutableDictionary
                                if let dat = shot.value(forKey: "clubDetected") as? Bool{
                                    if !dat{
                                        let latLng = CLLocationCoordinate2D(latitude: shot.value(forKey: "lat1") as! Double, longitude: shot.value(forKey: "lng1") as! Double)
                                        var lie = self.callFindPositionInsideFeature(position: latLng)
                                        let distance = GMSGeometryDistance(latLng, self.courseData.centerPointOfTeeNGreen[self.holeIndex].green)
                                        if i == 0{
                                            lie = "T"
                                        }
                                        let recommendedClub = self.clubReco(dist: distance, lie: lie)
                                        shot.setValue(recommendedClub, forKey: "club")
                                        debugPrint(recommendedClub)
                                    }
                                    shots.append(shot)
                                }else{
                                    shots.append(shot)
                                }
                            }
                        }
                        playersData.setValue(shots, forKey: "shots")
                        let playerDict = NSMutableDictionary()
                        playerDict.setObject(playersData, forKey: self.selectedUserId as NSCopying)
                        if let scoring = Constants.matchDataDic.value(forKey: "scoring") as? NSArray{
                            let sco = scoring
                            (sco[self.holeIndex] as! NSMutableDictionary).setValue(playersData, forKey: self.selectedUserId)
                            Constants.matchDataDic.setValue(sco, forKey: "scoring")
                        }
                        self.scoring[self.holeIndex].players[self.playerIndex] = playerDict
                        holeOut = playersData.value(forKey: "holeOut") as! Bool
                        if(holeOut){
                            self.uploadPutting(playerId: self.selectedUserId)
                        }
                        self.updateMap(indexToUpdate: self.holeIndex)
                        self.getSwingData(swingKey: self.swingMatchId)
                        if wantToDrag{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                                for markers in self.markersForCurved{
                                    self.isDraggingMarker = true
                                    self.updateStateWhileDragging(marker:markers)
                                }
                            })
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                            self.uploadTotalStrokesGained(playerId: self.selectedUserId)
                            if holeOut {
                                if self.isNextPrevBtn{
                                    self.isNextPrevBtn = false
                                }
                                else{
                                    self.btnActionPlayerStats(self.btnPlayersStats)
                                }
                            }
                        })
                    })
                }
            }
        }
    }

    func uploadTotalStrokesGained(playerId : String){
        for i in 0..<self.scoring[holeIndex].players.count{
            var strokesGainedDistance = Double()
            if let playerDict = self.scoring[holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary{
                if let scoreArray = playerDict.value(forKey: "shots") as? [NSMutableDictionary]{
                    for i in 0..<scoreArray.count{
                        if let sg = scoreArray[i].value(forKey: "strokesGained") as? Double{
                            strokesGainedDistance += sg
                        }
                    }
                    playerArrayWithDetails.setObject(strokesGainedDistance, forKey: "strokesGainedOfAllShots" as NSCopying)
                    ref.child("matchData/\(self.currentMatchId)/scoring/\(holeIndex)/\(playerId)/").updateChildValues(["strokesGainedOfAllShots":strokesGainedDistance] as [AnyHashable : Any])
                }
            }
        }
    }
    func setupPanGuesture(){
        
        popupOffset = 372.5
        self.viewForground.isHidden = false
        fgViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedFgView(_:)))
        viewForground.isUserInteractionEnabled = true
        viewForground.addGestureRecognizer(fgViewPanGesture)
        
        fgViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedFgView(_:)))
        centerSV.addGestureRecognizer(fgViewPanGesture)
        
        fgViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedFgView(_:)))
        headerView.addGestureRecognizer(fgViewPanGesture)
        
        fgViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedFgView(_:)))
        btnMoveToMapGround.addGestureRecognizer(fgViewPanGesture)
        btnMoveToMapGround.addTarget(self, action: #selector(self.openContainer(_:)), for: .touchUpInside)
        
        //        btnCenter.addTarget(self, action: #selector(self.openContainer(_:)), for: .touchUpInside)
        
        btnMoveToMapGround.isHidden = true
        popupFgOffset = self.view.frame.size.height - 64
        self.fgBConstraint.constant = popupFgOffset
        self.viewForground.layoutIfNeeded()
    }
    
    @objc func openContainer(_ sender:UIButton){
        
        fgAnimateTransitionIfNeeded(to: currentState1.opposite, duration: 1)
    }
    
    @objc func draggedFgView(_ recognizer:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: viewForground)
        self.view.bringSubview(toFront: centerSV)
        
        switch recognizer.state {
        case .began:
            
            fgAnimateTransitionIfNeeded(to: currentState1.opposite, duration: 1)
            
            runningAnimators1.forEach { $0.pauseAnimation() }
            
            animationProgress1 = runningAnimators1.map { $0.fractionComplete }
        case .changed:
            
            let translation = recognizer.translation(in: viewForground)
            
            var fraction = -translation.y / popupFgOffset
            
            if currentState1 == .closed { fraction *= -1 }
            if runningAnimators1[0].isReversed { fraction *= -1 }
            
            for (index, animator) in runningAnimators1.enumerated() {
                animator.fractionComplete = fraction + animationProgress1[index]
            }
        case .ended:
            
            let yVelocity = recognizer.velocity(in: viewForground).y
            let shouldClose = yVelocity > 0
            
            if yVelocity == 0 {
                runningAnimators1.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            switch currentState1 {
            case .closed:
                if !shouldClose && !runningAnimators1[0].isReversed { runningAnimators1.forEach { $0.isReversed = !$0.isReversed}}
                if shouldClose && runningAnimators1[0].isReversed { runningAnimators1.forEach { $0.isReversed = !$0.isReversed }}
            case .open:
                if shouldClose && !runningAnimators1[0].isReversed { runningAnimators1.forEach { $0.isReversed = !$0.isReversed }}
                if !shouldClose && runningAnimators1[0].isReversed { runningAnimators1.forEach { $0.isReversed = !$0.isReversed }}
            }
            
            runningAnimators1.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            ()
        }
        //        if(self.fgBConstraint.constant > 30){
        //            self.btnMoveToMapGround.isHidden = true
        //            self.centerSV.isHidden = false
        //        }else{
        //            self.btnMoveToMapGround.isHidden = false
        //            self.centerSV.isHidden = true
        //        }
        debugPrint("currentState : \(fgBConstraint.constant)")
        
    }
    private func fgAnimateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators1.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.fgBConstraint.constant = 30
                
                self.btnMoveToMapGround.isHidden = false
                self.centerSV.isHidden = true
                self.centerSVWidthConstraints.constant = 0
                self.view.layoutIfNeeded()
                self.imgViewWind.isHidden = true
                self.lblWindSpeed.isHidden = true
                
                self.stackViewForViewForground.isHidden = false
                self.imgViewWindForeground.isHidden = false
                self.lblWindSpeedForeground.isHidden = false
                
            case .closed:
                
                self.fgBConstraint.constant = self.popupFgOffset
                
                self.stackViewForViewForground.isHidden = true
                self.imgViewWindForeground.isHidden = true
                self.lblWindSpeedForeground.isHidden = true
            }
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
            case .start:
                self.currentState1 = state.opposite
                debugPrint("StartCall: \(state)")
            case .end:
                debugPrint("endedCalled : \(state)")
                self.currentState1 = state
            case .current:
                ()
            }
            
            // manually reset the constraint positions
            switch self.currentState1 {
            case .open:
                self.fgBConstraint.constant = 30
                UIView.animate(withDuration: 0.5, animations: {
                    self.stackViewForViewForground.isHidden = false
                    self.imgViewWindForeground.isHidden = false
                    self.lblWindSpeedForeground.isHidden = false
                    
                })
            case .closed:
                self.fgBConstraint.constant = self.popupFgOffset
                UIView.animate(withDuration: 0.5, animations: {
                    self.btnMoveToMapGround.isHidden = true
                    self.centerSV.isHidden = false
                    self.centerSVWidthConstraints.constant = 80
                    self.view.layoutIfNeeded()
                    self.imgViewWind.isHidden = false
                    self.lblWindSpeed.isHidden = false
                    
                    self.stackViewForViewForground.isHidden = true
                    self.imgViewWindForeground.isHidden = true
                    self.lblWindSpeedForeground.isHidden = true
                })
            }
            // remove all running animators
            self.runningAnimators1.removeAll()
        }
        
        // start all animators
        transitionAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators1.append(transitionAnimator)
    }
    @IBAction func btnActionHoleOut(_ sender: UIButton) {
        let shotClub = courseData.clubs[self.btnSelectClubs.tag]
        
        if(!holeOutFlag){
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.btnNext.isHidden = true
            self.btnPrev.isHidden = true
            self.btnPrevScrl.isHidden = true
            self.btnNextScrl.isHidden = true
            if(isUserInsideBound) && !isPintMarker{
                if(self.btnHoleoutLbl.currentTitle == "  In the hole  "){
                    self.btnHoleOut.isHidden = true
                    self.btnHoleoutLbl.isHidden = true
                    self.btnPenaltyShot.isHidden = true
                    self.btnAddPenaltyLbl.isHidden = true
                    userMarkerView.lbl.text = "tracking hole.."
                }else{
                    self.btnActionShots(fromHoleOut: true)
                }
                self.view.makeToast("Press Stop when you are at the pin Location.", duration: 3.0, position: .bottom)
                //                let alertController = UIAlertController(title: "Info", message: "Press Stop when you are at the pin Location.", preferredStyle: .alert)
                //                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                //                alertController.addAction(okayAction)
                //                self.present(alertController, animated: true, completion: nil)
                isPintMarker = true
                self.progressView.hide(navItem:self.navigationItem)
            }else{
                isUpdating = false
                self.penaltyShots.append(false)
                plotCurvedPolyline(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!,whichLine: false, club: shotClub)
                
                shotViseCurve.append((shot: shotCount, line: curvedLines, markerPosition: markerInfo,swingPosition: swingMarker))
                plotMarkerForCurvedLine(position: positionsOfDotLine.first!,userData: shotCount)
                plotMarkerForCurvedLine(position: positionsOfDotLine.last!,userData: shotCount+1)
                
                markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
                markersForCurved.last?.groundAnchor = CGPoint(x:0,y:1)
                positionsOfCurveLines.append(positionsOfDotLine.first!)
                positionsOfCurveLines.append(positionsOfDotLine.last!)
                
                
                if (isOnCourse) && (!positionsOfCurveLines.isEmpty){
                    positionsOfCurveLines.removeLast()
                }
                
                if(isOnCourse) && shotCount>0{
                    positionsOfCurveLines = BackgroundMapStats.removeRepetedElement(curvedArray: positionsOfCurveLines)
                }else{
                    if(shotCount>0){
                        positionsOfCurveLines = BackgroundMapStats.removeRepetedElement(curvedArray: positionsOfCurveLines)
                    }
                }
                
                for marker in markers{
                    marker.map = nil
                }
                line.map = nil
                markers[markers.count-2].map = nil
                for subview in stackViewForGreenShots.subviews {
                    subview.removeFromSuperview()
                }
                
                debugPrint(positionsOfCurveLines)
                greenStackViewHeight.constant = 0
                if(isBotTurn){
                    for i in 1..<markersForCurved.count-1{
                        markersForCurved[i].map = nil
                    }
                }
                for i in 0..<shotViseCurve.count{
                    removeLinesAndMarkers(index: i)
                    if(isBotTurn){
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i+1) , execute: {
                            self.showLinesAndMarker(index: i)
                        })
                    }else{
                        self.showLinesAndMarker(index: i)
                    }
                }
                holeOutFlag = true
                positionsOfDotLine.removeAll()
                shotCount = shotCount+1
                self.uploadStats(shot: shotCount, clubName: shotClub,playerKey: self.selectedUserId)
                
                //                if(!isBotTurn){
                //                    updateStateWhileDragging(marker:markersForCurved.last!)
                //                }
                if Constants.mode>0 && !isBotTurn{
                    self.holeOutforAppsFlyer[self.playerIndex] += 1
                    Analytics.logEvent("mode\(Constants.mode)_holeout\(holeOutforAppsFlyer[self.playerIndex])", parameters: [:])
                }
                
                self.suggestedMarkerOffCourse.map = nil
                self.btnHoleOut.isHidden = true
                self.btnHoleoutLbl.isHidden = true
                self.btnTrackShot.setImage(#imageLiteral(resourceName: "edit_White"), for: .normal)
                self.lblShotNumber.isHidden = true
                self.lblEditShotNumber.isHidden = false
                self.lblEditShotNumber.text = "\(shotCount)"
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                    self.btnShareShot.isHidden = false
                }, completion: {(_Bool)->Void in
                    if(!self.isHoleByHole) && (!self.isShowcaseFlag) && (!self.isContinue){
                        self.showCaseShareShots()
                        self.isShowcaseFlag = true
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    if(self.playersButton.count > 1){
                        self.updateRaceToFlag()
                    }
                    self.btnClubs.isHidden = true
                    self.btnSelectClubs.isHidden = true
                    self.noDataLabel.removeFromSuperview()
                    self.tappedMarker = self.shotViseCurve.last!.markerPosition
                    self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex, playerId: self.selectedUserId)
                    self.btnActionPlayerStats(self.btnPlayersStats)
                    self.progressView.hide(navItem: self.navigationItem)
                    if(self.isPintMarker) && self.isOnCourse{
                        self.isPintMarker = false
                        self.progressView.hide(navItem:self.navigationItem)
                        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(Auth.auth().currentUser!.uid)/shotTracking").setValue(nil)
                        for i in 0..<self.scoring[self.holeIndex].players.count{
                            if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                                if let playerDict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as? NSMutableDictionary{
                                    debugPrint(playerDict)
                                    playerDict.removeObject(forKey: "shotTracking")
                                    self.scoring[self.holeIndex].players[i].setValue(playerDict, forKey: self.selectedUserId)
                                    
                                }
                            }
                        }
                        self.updateMap(indexToUpdate: self.holeIndex)
                    }
                })
            }
        }
    }
    func setColorLandedOn(index:String){
        if index == "Green".localized(){
            self.btnLandedOnDropDown.backgroundColor = UIColor.glfGreen
        }else if index == "Fairway".localized() {
            self.btnLandedOnDropDown.backgroundColor = UIColor.glfFairway
        }else if index == "Bunker".localized(){
            self.btnLandedOnDropDown.backgroundColor = UIColor.glfBunker
        }else if index == "Water Hazard".localized(){
            self.btnLandedOnDropDown.backgroundColor = UIColor.glfBlueyGreen
        }else{
            self.btnLandedOnDropDown.backgroundColor = UIColor.glfRough
        }
    }
    func initilizeScoreNode(playerData:NSMutableArray){
        self.scoring.removeAll()
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
        for i in 0..<courseData.numberOfHoles.count{
            self.scoring.append((hole: courseData.numberOfHoles[i].hole, par: courseData.numberOfHoles[i].par,players:[NSMutableDictionary]()))
            let player = NSMutableDictionary()
            for j in 0..<playerData.count{
                let data = playerData[j] as! NSMutableDictionary
                let playerScore = NSMutableDictionary()
                let playerDataHole = ["holeOut":false]
                player.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                playerScore.setObject(playerDataHole, forKey: (data.value(forKey: "id") as! String) as NSCopying)
                self.scoring[i].players.append(playerScore)
            }
            player.setObject(courseData.numberOfHoles[i].par, forKey: "par" as NSCopying)
            holeArray.append(player)
        }
        scoring.setObject(holeArray, forKey: "scoring" as NSCopying)
        if(!self.isAcceptInvite){
            ref.child("matchData/\(self.currentMatchId)/").updateChildValues(scoring as! [AnyHashable : Any])
        }
        setupMultiplayersButton()
    }
    @IBAction func btnActionTrackShots(_ sender: UIButton) {
        let shotClub = courseData.clubs[self.btnSelectClubs.tag]
        if(!holeOutFlag) && (btnTrackShot.currentImage != #imageLiteral(resourceName: "edit_White")) && (self.btnTrackShot.currentImage != #imageLiteral(resourceName: "check_mark_fab")) && (!isPintMarker){
            if(isUserInsideBound){
                self.btnActionShots(fromHoleOut: false)
            }else{
                self.allMarkers.removeAll()
                self.progressView.show(atView: self.view, navItem: self.navigationItem)
                isUpdating = false
                self.penaltyShots.append(false)
                plotCurvedPolyline(latLng1: positionsOfDotLine[0], latLng2: positionsOfDotLine[1],whichLine: false,club:shotClub)
                positionsOfCurveLines.append(positionsOfDotLine[0])
                positionsOfCurveLines.append(positionsOfDotLine[1])
                
                let heading = GMSGeometryHeading(positionsOfDotLine[1], positionsOfDotLine[2])
                let dist = GMSGeometryDistance(positionsOfDotLine[1], positionsOfDotLine[2])*Constants.YARD
                var midPoint = GMSGeometryOffset(positionsOfDotLine[1], GMSGeometryDistance(positionsOfDotLine[1], positionsOfDotLine[2])*0.7, heading)
                if(dist<201) && Int(dist)>0{
                    for i in 1..<Int(dist){
                        if(BackgroundMapStats.findPositionOfPointInside(position: midPoint, whichFeature: courseData.numberOfHoles[holeIndex].green)){
                            break
                        }else{
                            midPoint = GMSGeometryOffset(midPoint, Double(i), heading)
                        }
                    }
                }
                positionsOfDotLine[0]  = positionsOfDotLine[1]
                positionsOfDotLine[1] = midPoint
                plotMarkerForCurvedLine(position: markers[0].position,userData: shotCount)
                
                if(shotCount>0){
                    positionsOfCurveLines = BackgroundMapStats.removeRepetedElement(curvedArray: positionsOfCurveLines)
                }
                
                curvedLines.userData = shotCount
                shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker))
                shotCount = shotCount+1
                
                for marker in markers{
                    marker.map = nil
                }
                markers.removeAll()
                for i in 0..<positionsOfDotLine.count{
                    plotMarker(position: positionsOfDotLine[i], userData: i)
                }
                markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                markers.last?.groundAnchor = CGPoint(x:0,y:1)
                let mid = markers.count/2
                markers[mid].icon = #imageLiteral(resourceName: "target")
                updateLine(mapView: self.mapView, marker: markers[mid])
                self.allMarkers = markers
                for subview in stackViewForGreenShots.subviews {
                    subview.removeFromSuperview()
                }
                greenStackViewHeight.constant = 0
                for i in 0..<shotViseCurve.count{
                    removeLinesAndMarkers(index: i)
                    if(!penaltyShots[i]){
                        showLinesAndMarker(index: i)
                    }else{
                        shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                    }
                }
                if(isBotTurn){
                    for marker in markersForCurved{
                        marker.map = nil
                    }
                }
                
                self.uploadStats(shot: shotCount,clubName:shotClub, playerKey: self.selectedUserId)
                if(!self.positionsOfDotLine.isEmpty){
                    if(GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * Constants.YARD) < 100{
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                            self.btnHoleOut.isHidden = false
                            self.btnHoleoutLbl.isHidden = false
                            
                        }, completion:{(_ completed: Bool) -> Void in
                            if(!self.isHoleByHole) && (!self.isOnCourse) && (!self.isContinue) && (!self.isShowcase){
                                self.isShowcase = true
                                self.showCaseHoleOutShots()
                            }
                        })
                    }
                }
                self.lblShotNumber.isHidden = false
                self.lblShotNumber.text = "  Shot \(shotCount+1)  "
                self.lblEditShotNumber.isHidden = true
                for player in playersButton{
                    if player.isSelected{
                        self.selectedUserId = player.id
                    }
                }
                if(!self.isBotTurn){
                    self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.plotLine(positions: self.positionsOfDotLine)
                        self.progressView.hide(navItem: self.navigationItem)
                        self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex, playerId: self.selectedUserId)
                        let landedOnACtoProgram = self.callFindPositionInsideFeature(position:self.positionsOfCurveLines.last!)
                        if(landedOnACtoProgram == "WH"){
                            self.tappedMarker = self.shotViseCurve.last!.markerPosition
                            self.btnActionPenaltyShot(self.btnPenaltyShot)
                        }
                    })
                }
            }
        }else if(self.btnTrackShot.currentImage! == #imageLiteral(resourceName: "edit_White")){
            debugPrint("clicked on Edit Shots")
            self.editShotAction()
        }else if (self.btnTrackShot.currentImage == #imageLiteral(resourceName: "check_mark_fab")){
            debugPrint("updating Moved Edited Shots")
            let landedOn = (self.btnLandedOnDropDown.titleLabel?.text)!.trim()
            self.showEditRelated(hide:false)
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.btnRemovePenaltyLbl.isHidden = true
            self.btnRemovePenalty.isHidden = true
            let clubName = courseData.clubs[self.btnSelectClubs.tag]
            let spString = landedOn.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            var finalStr = "\(landedOn.first!)"
            if(spString.count > 1){
                finalStr = "\(spString[0].first!)\(spString[1].first!)"
            }
            if(finalStr == "B"){
                finalStr = "GB"
            }
            let shotDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: selectedUserId)
            let localHoleOut : Bool = self.holeOutFlag
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                for i in 0..<self.positionsOfCurveLines.count-1{
                    let shot = i+1
                    var shotData = shotDetails[i]
                    if(i != self.positionsOfCurveLines.count-1){
                        self.holeOutFlag = false
                    }
                    if(shot-2 == sender.tag){
                        shotData.swingScore = finalStr
                    }
                    if(shot-1 == sender.tag){
                        shotData.club = clubName
                        shotData.endingPoint = finalStr
                    }
                    
                    for playerDetails in self.playersButton{
                        if(playerDetails.isSelected){
                            let playerId = playerDetails.id
                            
                            var landedOnACtoProgram = self.callFindPositionInsideFeature(position:self.positionsOfCurveLines[shot])
                            if(shot-1 == sender.tag){
                                landedOnACtoProgram = finalStr
                            }
                            if(shot==1){
                                var drivingDistance = 0.0
                                self.player = NSMutableDictionary()
                                self.gir = false
                                self.playerShotsArray = [NSMutableDictionary]()
                                
                                if(self.scoring[self.holeIndex].par>3){
                                    drivingDistance = GMSGeometryDistance(self.positionsOfCurveLines[shot-1], self.positionsOfCurveLines[shot])*Constants.YARD
                                    self.playerArrayWithDetails.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
                                }
                                if(!self.holeOutFlag){
                                    if(self.scoring[self.holeIndex].par > 3){
                                        self.playerArrayWithDetails.setObject(self.fairwayDetailsForFirstShotWithLandedOn(shot:shot,landedOn:landedOnACtoProgram), forKey: "fairway" as NSCopying)
                                    }
                                }
                                self.gir = landedOnACtoProgram == "G" ? true:false
                            }
                            if(shot == 2)&&(!self.gir)&&(self.scoring[self.holeIndex].par>3){
                                self.gir = landedOnACtoProgram == "G" ? true:false
                            }
                            if(shot == 3)&&(!self.gir)&&(self.scoring[self.holeIndex].par>4){
                                self.gir = landedOnACtoProgram == "G" ? true:false
                            }
                            self.uploadApproachAndApproachShots(playerId: playerId)
                            self.playerArrayWithDetails.setObject(self.gir, forKey: "gir" as NSCopying)
                            debugPrint(shotData.swingScore)
                            debugPrint(shotData.endingPoint)
                            self.playerShotsArray.append(self.reCalculateStats(shot: shot, club: shotData.club, isPenalty: shotData.penalty, end: shotData.endingPoint, start: shotData.swingScore))
                            if(i == self.shotCount-2){
                                self.holeOutFlag = localHoleOut
                            }
                            self.playerArrayWithDetails.setObject(localHoleOut, forKey: "holeOut" as NSCopying)
                            self.playerArrayWithDetails.setObject(self.playerShotsArray, forKey: "shots" as NSCopying)
                            
                            if(self.holeOutFlag){
                                self.uploadChipUpNDown(playerId: playerId)
                                self.uploadSandUpNDown(playerId: playerId)
                                self.uploadPutting(playerId: playerId)
                                self.uploadPenalty(playerId: playerId)
                                if(!self.teeTypeArr.isEmpty){
                                    self.uploadStableFordPints(playerId: playerId)
                                }
                            }
                            
                        }
                    }
                }
                self.holeOutFlag = localHoleOut
                Notification.sendLocaNotificatonToUser()
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(self.selectedUserId)/").updateChildValues(self.playerArrayWithDetails as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    self.isProcessing = false
                    if(finalStr == "WH"){
                        self.btnActionPenaltyShot(self.btnPenaltyShot)
                    }
                    self.getScoreFromMatchDataFirebases()
                    self.updateMap(indexToUpdate: self.holeIndex)
                    for mark in self.shotViseCurve{
                        mark.markerPosition.isTappable = true
                        mark.line.isTappable = true
                    }
                    for btn in self.stackViewForGreenShots.subviews{
                        btn.isUserInteractionEnabled = true
                    }
                    self.progressView.hide(navItem: self.navigationItem)
                })
            })
        }else if (isPintMarker) && self.btnTrackShot.currentImage == #imageLiteral(resourceName: "stop"){
            self.btnActionShots(fromHoleOut: false)
        }
    }
    func fairwayDetailsForFirstShotWithLandedOn(shot:Int,landedOn:String)->String{
        var fairwayHitOrMiss = ""
        if(landedOn != "F"){
            fairwayHitOrMiss = isFairwayHitOrMiss(position: positionsOfCurveLines[shot])
        }
        else{
            fairwayHitOrMiss = "H"
        }
        return fairwayHitOrMiss
    }
    func btnActionShots(fromHoleOut:Bool) {
        let clubName = courseData.clubs[self.btnSelectClubs.tag]
        if(!holeOutFlag){
            isUpdating = false
            if(btnTrackShot.currentImage == #imageLiteral(resourceName: "track_Shot")){
                
                self.btnTrackShot.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                self.btnTrackShot.backgroundColor = UIColor.glfWhite
                self.btnAddPenaltyLbl.isHidden = fromHoleOut
                self.btnPenaltyShot.isHidden = fromHoleOut
                self.btnRestartShot.isHidden = false
                self.btnRestartLbl.isHidden = false
                self.btnHoleoutLbl.isHidden = !fromHoleOut
                self.btnHoleOut.isHidden = !fromHoleOut
                if(fromHoleOut){
                    self.btnHoleOut.tag = 444
                    self.btnHoleoutLbl.tag = 444
                }else{
                    self.btnHoleOut.tag = 0
                    self.btnHoleoutLbl.tag = 0
                }
                self.btnAddPenaltyLbl.tag = 666
                self.btnPenaltyShot.tag = 666
                
                let newDict = NSMutableDictionary()
                newDict.setObject(clubName, forKey: "club" as NSCopying)
            
                newDict.setObject(self.positionsOfDotLine[0].latitude, forKey: "lat1" as NSCopying)
                newDict.setObject(self.positionsOfDotLine[0].longitude, forKey: "lng1" as NSCopying)
                
                newDict.setObject(fromHoleOut, forKey: "hole" as NSCopying)
                newDict.setObject(self.shotCount, forKey: "shot_no" as NSCopying)
                
                if(shotCount > 0){
                    for i in 0..<markers.count-1{
                        markers[i].map = nil
                    }
                }else{
                    
                    positionsOfCurveLines.append(positionsOfDotLine[0])
                    for i in 1..<markers.count-1{
                        markers[i].map = nil
                    }
                }
                markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                markers.last?.groundAnchor = CGPoint(x:0,y:1)
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(Auth.auth().currentUser!.uid)/shotTracking").updateChildValues(newDict as! [AnyHashable : Any])
                
                
                for i in 0..<self.scoring[self.holeIndex].players.count{
                    if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                        if let playerDict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as? NSMutableDictionary{
                            playerDict.setValue(newDict, forKey: "shotTracking")
                            self.scoring[self.holeIndex].players[i].setValue(playerDict, forKey: self.selectedUserId)
                            
                        }
                    }
                }
                
                self.isTracking = true
                debugPrint("count : \(self.positionsOfCurveLines.count)")
                if(!isContinue) && (!isHoleByHole) && (!isShowcase) && (!isStopShotCT){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.isStopShotCT = true
                        self.showCaseStopShotsOnCourse()
                    })
                }
            }
            else{
                self.isTracking = false
                self.btnAddPenaltyLbl.isHidden = true
                self.btnPenaltyShot.isHidden = true
                self.btnRestartShot.isHidden = true
                self.btnRestartLbl.isHidden = true
                self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
                self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
                self.penaltyShots.append(false)
                if (positionsOfCurveLines.last!.latitude == self.positionsOfDotLine[0].latitude) || (positionsOfCurveLines.last!.longitude == self.positionsOfDotLine[0].longitude){
                    let dist = GMSGeometryDistance(positionsOfCurveLines.last!, positionsOfDotLine[0])
                    let head = GMSGeometryHeading(positionsOfCurveLines.last!, positionsOfDotLine[0])
                    self.positionsOfDotLine[0] = GMSGeometryOffset(self.positionsOfCurveLines.last!, dist+0.8, head)
                }
                if !(BackgroundMapStats.findPositionOfPointInside(position: self.positionsOfDotLine.first!, whichFeature: courseData.numberOfHoles[holeIndex].green)) && isPintMarker{
                    
                    positionsOfCurveLines.append(self.positionsOfDotLine.last!)
                }else{
                    positionsOfCurveLines.append(self.positionsOfDotLine[0])
                }
                
                if(!isPintMarker) && !fromHoleOut{
                    let midPoint = BackgroundMapStats.middlePointOfListMarkers(listCoords: [positionsOfDotLine[1], positionsOfDotLine[2]])
                    positionsOfDotLine[0]  = positionsOfCurveLines.last!
                    positionsOfDotLine[1] = midPoint
                }else{
                    self.holeOutFlag = true
                    self.positionsOfDotLine.removeAll()
                }
                isUpdating = false
                plotCurvedPolyline(latLng1: positionsOfCurveLines[shotCount], latLng2: positionsOfCurveLines[shotCount+1],whichLine: false, club: clubName)
                plotMarkerForCurvedLine(position:positionsOfCurveLines[shotCount+1] ,userData: shotCount+1)
                if(shotCount>1){
                    positionsOfCurveLines = BackgroundMapStats.removeRepetedElement(curvedArray: positionsOfCurveLines)
                }
                for marker in markers{
                    marker.map = nil
                }
                markers.removeAll()
                for i in 0..<positionsOfDotLine.count{
                    plotMarker(position: positionsOfDotLine[i], userData: i)
                }
                if(!isPintMarker) && !fromHoleOut{
                    markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                    markers.last?.groundAnchor = CGPoint(x:0,y:1)
                    markers.last?.map = self.mapView
                    let mid = markers.count/2
                    markers[mid].icon = #imageLiteral(resourceName: "target")
                    plotLine(positions: positionsOfDotLine)
                }else{
                    markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
                    markersForCurved.last?.groundAnchor = CGPoint(x:0,y:1)
                    markersForCurved.last?.map = self.mapView
                    self.line.map = nil
                }
                
                
                shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo,swingPosition:swingMarker))
                for subview in stackViewForGreenShots.subviews {
                    subview.removeFromSuperview()
                }
                for i in 0..<shotViseCurve.count{
                    removeLinesAndMarkers(index: i)
                    if(!penaltyShots[i]){
                        showLinesAndMarker(index: i)
                    }else{
                        shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                    }
                }
                shotCount = shotCount+1
                if(!self.positionsOfDotLine.isEmpty){
                    if(GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * Constants.YARD) < 100{
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                            self.btnHoleOut.isHidden = false
                            self.btnHoleoutLbl.isHidden = false
                        }, completion:{(_ completed: Bool) -> Void in
                            if(!self.isHoleByHole) && (!self.isContinue) && (!self.isShowcase){
                                self.isShowcase = true
                                self.showCaseHoleOutShotsOnCourse()
                            }
                        })
                    }
                }
                self.lblShotNumber.isHidden = false
                self.lblShotNumber.text = "  Shot \(shotCount+1)  "
                self.lblEditShotNumber.isHidden = true
                for player in playersButton{
                    if player.isSelected{
                        self.selectedUserId = player.id
                    }
                }
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(Auth.auth().currentUser!.uid)/shotTracking").setValue(nil)
                for i in 0..<self.scoring[self.holeIndex].players.count{
                    if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                        if let playerDict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as? NSMutableDictionary{
                            debugPrint(playerDict)
                            playerDict.removeObject(forKey: "shotTracking")
                            self.scoring[self.holeIndex].players[i].setValue(playerDict, forKey: self.selectedUserId)
                            
                        }
                    }
                }
                self.uploadStats(shot: shotCount,clubName:clubName, playerKey: self.selectedUserId)
                if(!self.isBotTurn) && !isPintMarker{
                    self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.plotLine(positions: self.positionsOfDotLine)
                    })
                }
                debugPrint("count : \(self.positionsOfCurveLines.count)")
                self.userMarker.map = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: self.selectedUserId)
                self.allMarkers = self.markers
                if(self.isPintMarker) && !fromHoleOut && self.holeOutFlag{
                    self.isPintMarker = false
                    self.mapView(self.mapView, didEndDragging: self.markersForCurved.last!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        if(self.playersButton.count > 1){
                            self.updateRaceToFlag()
                        }
                        self.btnClubs.isHidden = true
                        self.btnSelectClubs.isHidden = true
                        self.noDataLabel.removeFromSuperview()
                        self.tappedMarker = self.shotViseCurve.last!.markerPosition
                        self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex, playerId: self.selectedUserId)
                        self.btnActionPlayerStats(self.btnPlayersStats)
                    })
                }
            })
        }
    }
    
    func editShotAction(){
        self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: self.selectedUserId)
        if(tappedMarker != nil){
            self.letsRotateWithZoom(latLng1: self.positionsOfCurveLines[tappedMarker.iconView!.tag], latLng2: self.positionsOfCurveLines[tappedMarker.iconView!.tag+1])
            for mark in shotViseCurve{
                mark.markerPosition.isTappable = false
                mark.line.isTappable = false
            }
            for btn in self.stackViewForGreenShots.subviews{
                btn.isUserInteractionEnabled = false
            }
            self.btnPlayersStats.isHidden = true
            self.btnRemovePenalty.isHidden = true
            self.btnRemovePenaltyLbl.isHidden = true
            if (self.penaltyShots.count > tappedMarker.iconView!.tag+1) && (self.penaltyShots[tappedMarker.iconView!.tag+1]){
                self.btnRemovePenalty.isHidden = false
                self.btnRemovePenaltyLbl.isHidden = false
            }
            self.btnShareShot.isHidden = true
            self.btnHoleoutLbl.isHidden = true
            self.showEditRelated(hide:true)
            for i in 0..<self.scoring[self.holeIndex].players.count{
                if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                    self.tempPlayerData = (self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as! NSDictionary).mutableCopy() as! NSDictionary
                    break
                }
            }
            let lie = shotsDetails[tappedMarker.iconView!.tag].endingPoint
            let club = shotsDetails[tappedMarker.iconView!.tag].club
            let indexPath = IndexPath(row: courseData.clubs.index(of: club.trim())!, section: 0)
            self.btnSelectClubs.tag = indexPath.row
//            if let cell = self.selectClubDropper.TableMenu.cellForRow(at: indexPath) as? DropperCell{
//                cell.textLabel?.isHidden = false
//                cell.textLabel?.backgroundColor = UIColor.glfBlack40
//            }
            self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
            self.btnLandedOnDropDown.setTitle("\(BackgroundMapStats.returnLandedOnFullName(data: lie).0)", for: .normal)
            self.setColorLandedOn(index:BackgroundMapStats.returnLandedOnFullName(data: lie).0)
            self.lblShotNumber.isHidden = true
            self.lblEditShotNumber.isHidden = false
            self.lblEditShotNumber.text = "\(tappedMarker.iconView!.tag+1)"
            self.mapView(self.mapView, didTap: self.shotViseCurve[tappedMarker.iconView!.tag].line)
            let tappedShot = tappedMarker.iconView!.tag
            var isMove = false
            if(tappedShot>0){
                isMove = self.penaltyShots[tappedShot-1]
            }
            for i in 0..<markersForCurved.count{
                markersForCurved[i].isTappable = false
                markersForCurved[i].isDraggable = false
                if(allMarkers.contains(markersForCurved[i])){
                    allMarkers.remove(at: allMarkers.index(of: markersForCurved[i])!)
                }
            }
            if(tappedShot == 0) && self.shotCount > 1{
                markersForCurved[tappedShot].isDraggable = true
                markersForCurved[tappedShot+1].isDraggable = true
                markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                markersForCurved[tappedShot+1].icon = #imageLiteral(resourceName: "cross")
                self.allMarkers.append(markersForCurved[tappedShot])
                self.allMarkers.append(markersForCurved[tappedShot+1])
            }else if (tappedShot != 0) && self.shotCount > tappedShot{
                if(markersForCurved.count > tappedShot+1){
                    if(self.holeOutFlag) && markersForCurved.count-1 == tappedShot+1{
                        markersForCurved[tappedShot].isDraggable = true
                        markersForCurved[tappedShot+1].isDraggable = true
                        markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                    }else{
                        markersForCurved[tappedShot+1].isDraggable = true
                        markersForCurved[tappedShot+1].icon = #imageLiteral(resourceName: "cross")
                        self.allMarkers.append(markersForCurved[tappedShot+1])
                    }
                }else if markersForCurved.count == tappedShot+1 && !holeOutFlag{
                    var indexForDot = -1
                    var indexForCur = -1
                    if(BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: positionsOfDotLine) != -1){
                        indexForDot = BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: self.positionsOfDotLine)
                    }
                    if BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: positionsOfCurveLines) != -1 {
                        indexForCur = BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: self.positionsOfCurveLines)
                    }
                    if(indexForCur != -1 && indexForDot != -1 ){
                        markers.first!.title = "PointWithCurved"
                    }
                    markers.first!.icon = #imageLiteral(resourceName: "cross")
                    self.allMarkers.append(markers.first!)
                }
            }else if tappedShot+1 == self.shotCount && holeOutFlag{
                markersForCurved[tappedShot].isDraggable = true
                markersForCurved[tappedShot+1].isDraggable = true
                markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                markersForCurved[tappedShot+1].icon = #imageLiteral(resourceName: "cross")
                self.allMarkers.append(markersForCurved[tappedShot])
                self.allMarkers.append(markersForCurved[tappedShot+1])
            }else if !holeOutFlag && tappedShot == 0 && !isOnCourse{
                var indexForDot = -1
                var indexForCur = -1
                if(BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: positionsOfDotLine) != -1){
                    indexForDot = BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: self.positionsOfDotLine)
                }
                if BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: positionsOfCurveLines) != -1 {
                    indexForCur = BackgroundMapStats.isPositionAvailable(latLng: markers.first!.position, latLngArray: self.positionsOfCurveLines)
                }
                if(indexForCur != -1 && indexForDot != -1 ){
                    markers.first!.title = "PointWithCurved"
                }
                markers.first!.icon = #imageLiteral(resourceName: "cross")
                markersForCurved[tappedShot].isDraggable = true
                markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                self.allMarkers.append(markersForCurved[tappedShot])
                self.allMarkers.append(markers.first!)
            }else if isOnCourse && !holeOutFlag && tappedShot == 0{
                markersForCurved[tappedShot].isDraggable = true
                markersForCurved[tappedShot+1].isDraggable = true
                markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                markersForCurved[tappedShot+1].icon = #imageLiteral(resourceName: "cross")
                self.allMarkers.append(markersForCurved[tappedShot])
                self.allMarkers.append(markersForCurved[tappedShot+1])
            }
            if(isMove){
                markersForCurved[tappedShot].isDraggable = true
                markersForCurved[tappedShot].icon = #imageLiteral(resourceName: "cross")
                self.allMarkers.append(markersForCurved[tappedShot])
            }
            for shots in shotViseCurve{
                debugPrint(shots.markerPosition.iconView!.tag)
            }
            if(!holeOutFlag){
                self.view.makeToast("touch on marker to drag the shot.", duration: 1.5, position: .bottom)
            }else{
                self.view.makeToast("Long press on marker to drag the shot.", duration: 1.5, position: .bottom)
            }
            
        }
    }
    @IBAction func btnActionClose(_ sender: UIButton) {
        self.showEditRelated(hide:false)
        self.btnRemovePenaltyLbl.isHidden = true
        self.btnRemovePenalty.isHidden = true
        for marker in markersForCurved{
            marker.isTappable = true
            marker.isDraggable = true
        }
        
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(self.selectedUserId)/").updateChildValues(self.tempPlayerData as! [AnyHashable : Any])
        for i in 0..<self.scoring[self.holeIndex].players.count{
            if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                let dict = NSMutableDictionary()
                dict.addEntries(from: [self.selectedUserId:tempPlayerData])
                
                self.scoring[self.holeIndex].players[i] = dict
                self.updateMap(indexToUpdate: self.holeIndex)
                break
            }
        }
        for mark in shotViseCurve{
            mark.markerPosition.isTappable = true
            mark.line.isTappable = true
        }
        //        for btn in self.stackViewForGreenShots.subviews{
        //            btn.isUserInteractionEnabled = true
        //        }
        //        for i in 0..<shotViseCurve.count{
        //            self.removeLinesAndMarkers(index: i)
        //        }
        //        for i in 0..<shotViseCurve.count{
        //            self.showLinesAndMarker(index: i)
        //        }
        self.updateMap(indexToUpdate: self.holeIndex)
    }
    
    @IBAction func btnActionPenaltyShot(_ sender: UIButton) {
        if(sender.tag == 666) || self.isTracking{
            self.btnActionShots(fromHoleOut: false)
            self.tappedMarker = self.shotViseCurve.last?.markerPosition
            sender.tag = 0
            self.btnAddPenaltyLbl.tag = 0
        }
        if(tappedMarker != nil){
            var playerIndex = 0
            let playerShotsData = NSMutableDictionary()
            var indexOfMarker = tappedMarker.iconView!.tag
            if isOnCourse && isTracking && !holeOutFlag{
                indexOfMarker += 1
            }
            
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.penaltyShots = [Bool]()
            var playerDict = NSMutableDictionary()
            var scoreArray = [NSMutableDictionary]()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    for i in 0..<self.scoring[self.holeIndex].players.count{
                        if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                            playerIndex = i
                            if let dict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as? NSMutableDictionary{
                                scoreArray = dict.value(forKey: "shots") as! [NSMutableDictionary]
                                playerDict = dict
                            }
                        }
                    }
                }
            }
            for m in markersForCurved{
                m.map = nil
            }
            var tryPenalty = true
            if(holeOutFlag){
                if (shotCount == indexOfMarker+1){
                    tryPenalty = false
                }
            }
            markersForCurved.removeAll()
            for i in 0..<scoreArray.count{
                for (key,value) in scoreArray[i]{
                    if(key as! String == "penalty"){
                        self.penaltyShots.append(value as! Bool)
                    }
                }
            }
            
            if tryPenalty{
                var numberOfPenalty = Int()
                if(indexOfMarker < penaltyShots.count-1){
                    for i in indexOfMarker+1..<penaltyShots.count{
                        if (self.penaltyShots[i]){
                            numberOfPenalty += 1
                        }else{
                            break
                        }
                    }
                }
                
                let coordStart = positionsOfCurveLines[indexOfMarker]
                let coordEnd = positionsOfCurveLines[indexOfMarker+1+numberOfPenalty]
                let heading = GMSGeometryHeading(coordStart, coordEnd)
                let shotsDict = self.scoring[self.holeIndex].players[playerIndex].value(forKey: self.selectedUserId) as! NSMutableDictionary
                var shotsValue = shotsDict.value(forKey: "shots") as! [NSMutableDictionary]
                let clubValue = shotsValue[indexOfMarker].value(forKey: "club") as! String
                numberOfPenalty = (numberOfPenalty == 0) ? 1 : numberOfPenalty
                var nextMarkerCoord : CLLocationCoordinate2D!
                let landedOnACtoProgram = self.callFindPositionInsideFeature(position:self.positionsOfCurveLines.last!)
                if(landedOnACtoProgram == "WH"){
                    nextMarkerCoord = moveOutsideFromWaterH(end:coordEnd,distance:5.0)
                }else{
                    nextMarkerCoord = GMSGeometryOffset(coordEnd, 10*Double(numberOfPenalty), heading+90)
                }
                if(positionsOfCurveLines.count-1 == indexOfMarker+1){
                    self.positionsOfCurveLines.append(nextMarkerCoord)
                }else{
                    positionsOfCurveLines.insert(nextMarkerCoord, at: indexOfMarker+2)
                }
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker], latLng2: positionsOfCurveLines[indexOfMarker+1],whichLine: false, club: clubValue)
                shotViseCurve[indexOfMarker] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker)
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker+1], latLng2: positionsOfCurveLines[indexOfMarker+2], whichLine: false, club: clubValue)
                shotViseCurve.insert((shot:  indexOfMarker+1, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker), at: indexOfMarker+1)
                
                var dict = getShotDetails(shot:indexOfMarker+1,club:clubValue,isPenalty: false)
                scoreArray.insert(dict, at: indexOfMarker)
                dict = getShotDetails(shot:indexOfMarker+2,club:clubValue,isPenalty: true)
                scoreArray.insert(dict, at: indexOfMarker+1)
                scoreArray.remove(at: indexOfMarker+2)
                playerDict.setValue(scoreArray, forKey: "shots")
                playerShotsData.setObject(playerDict, forKey: self.selectedUserId as NSCopying)
                
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/").updateChildValues(playerShotsData as! [AnyHashable : Any])
                shotCount = shotCount+1
                for i in 0..<self.scoring[self.holeIndex].players.count{
                    if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                        self.scoring[self.holeIndex].players[i] = playerShotsData
                    }
                }
            }
            self.penaltyShots.removeAll()
            for i in 0..<scoreArray.count{
                for (key,value) in scoreArray[i]{
                    if(key as! String == "penalty"){
                        self.penaltyShots.append(value as! Bool)
                    }
                }
            }
            
            for i in 0..<positionsOfCurveLines.count{
                plotMarkerForCurvedLine(position: positionsOfCurveLines[i],userData: i)
            }
            if(tryPenalty){
                for markers in markersForCurved{
                    updateStateWhileDragging(marker:markers)
                }
            }
            for subview in stackViewForGreenShots.subviews {
                subview.removeFromSuperview()
            }
            greenStackViewHeight.constant = 0
            for i in 0..<shotViseCurve.count{
                if !self.penaltyShots[i]{
                    showLinesAndMarker(index: i)
                }else{
                    shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                }
            }
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 , execute: {
                self.updateMap(indexToUpdate: self.holeIndex)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                    self.progressView.hide(navItem: self.navigationItem)
                    if(self.isOnCourse){
                        self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                    }else{
                        self.plotSuggestedMarkersOffCourse(position: self.positionsOfDotLine)
                    }
                    self.showEditRelated(hide:false)
                    self.btnAddPenaltyLbl.isHidden = true
                    self.btnPenaltyShot.isHidden = true
                })
            })
        }
    }
    
    func moveOutsideFromWaterH(end:CLLocationCoordinate2D,distance:Double)->CLLocationCoordinate2D{
        var point : CLLocationCoordinate2D!
        var nearbyPoint : CLLocationCoordinate2D!
        
        for wh in self.allWaterHazard{
            nearbyPoint = wh[BackgroundMapStats.nearByPoint(newPoint: end, array:wh)]
        }
        let heading = GMSGeometryHeading(end, nearbyPoint)
        point = GMSGeometryOffset(end,distance,heading)
        let landedOnACtoProgram = self.callFindPositionInsideFeature(position:point)
        if(landedOnACtoProgram == "WH"){
            point = self.moveOutsideFromWaterH(end:end,distance: distance+2)
        }
        return point
    }
    
    
    @IBAction func btnActionDeleteShot(_ sender: UIButton) {
        if(tappedMarker != nil){
            var playerIndex = 0
            let playerShotsData = NSMutableDictionary()
            var indexOfMarker = tappedMarker.iconView!.tag
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.penaltyShots = [Bool]()
            var playerDict = NSMutableDictionary()
            var scoreArray = [NSMutableDictionary]()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    for i in 0..<self.scoring[self.holeIndex].players.count{
                        if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                            playerIndex = i
                            playerDict = self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as! NSMutableDictionary
                            scoreArray = playerDict.value(forKey: "shots") as! [NSMutableDictionary]
                            break
                        }
                    }
                }
            }
            for m in markersForCurved{
                m.map = nil
            }
            var lastIndex : Int!
            markersForCurved.removeAll()
            let shotsDict = self.scoring[self.holeIndex].players[playerIndex].value(forKey: self.selectedUserId) as! NSMutableDictionary
            var shotsValue = shotsDict.value(forKey: "shots") as! [NSMutableDictionary]
            if(indexOfMarker+1 == positionsOfCurveLines.count){
                indexOfMarker -= 1
            }
            if(indexOfMarker+1 < penaltyShots.count){
                for i in indexOfMarker+1..<penaltyShots.count{
                    if !(self.penaltyShots[i]){
                        lastIndex = i
                        break
                    }
                }
            }
            
            let tempLocation = positionsOfCurveLines[lastIndex != nil ? lastIndex:indexOfMarker+1]
            positionsOfCurveLines.remove(at: lastIndex != nil ? lastIndex:indexOfMarker+1)
            var clubValue = shotsValue[indexOfMarker].value(forKey: "club") as! String
            shotCount = shotCount-1
            for i in 0..<scoreArray.count{
                for (key,value) in scoreArray[i]{
                    if(key as! String == "penalty"){
                        self.penaltyShots.append(value as! Bool)
                    }
                }
            }
            if(shotCount+1 == indexOfMarker+1){
                if(positionsOfDotLine.isEmpty){
                    self.holeOutFlag = false
                    self.positionsOfDotLine.append(positionsOfCurveLines.last!)
                    self.positionsOfDotLine.append(positionsOfCurveLines.last!)
                    self.positionsOfDotLine.append(tempLocation)
                    self.plotMarker(position: tempLocation, userData: 2)
                    self.plotMarker(position: positionsOfCurveLines.last!, userData: 1)
                    
                    self.plotLine(positions: self.positionsOfDotLine)
                }else{
                    positionsOfDotLine[0] = positionsOfCurveLines.last!
                    markers[0].position = positionsOfDotLine[0]
                    if(indexOfMarker != 0){
                        self.updateLine(mapView: self.mapView, marker: markers.first!)
                    }
                }
            }
            if(indexOfMarker != 0){
                var nextIndex = indexOfMarker+1
                for i in indexOfMarker+1..<penaltyShots.count{
                    if !(self.penaltyShots[i]){
                        nextIndex = i
                        break
                    }
                }
                debugPrint(indexOfMarker,nextIndex)
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker-1], latLng2: positionsOfCurveLines[nextIndex-1],whichLine: false,club:clubValue)
                shotViseCurve[indexOfMarker-1] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo,swingPosition:swingMarker)
                shotViseCurve.remove(at: indexOfMarker)
                scoreArray.remove(at: indexOfMarker)
                for i in 0..<shotViseCurve.count{
                    if(i<nextIndex-(indexOfMarker+1)){
                        scoreArray.remove(at: indexOfMarker)
                        shotViseCurve.remove(at: nextIndex-1)
                    }else{
                        break
                    }
                }
            }else if shotCount != 0{
                clubValue = shotsValue[indexOfMarker+1].value(forKey: "club") as! String
                var nextIndex = indexOfMarker+1
                for i in indexOfMarker+1..<penaltyShots.count{
                    if !(self.penaltyShots[i]){
                        nextIndex = i
                        break
                    }
                }
                
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker], latLng2: lastIndex != nil ? tempLocation : positionsOfCurveLines[nextIndex],whichLine: false,club:clubValue)
                shotViseCurve[indexOfMarker] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo,swingPosition:swingMarker)
                shotViseCurve.remove(at: indexOfMarker+1)
                scoreArray.remove(at: indexOfMarker)
                scoreArray.remove(at: indexOfMarker)
                
                for i in 0..<shotViseCurve.count{
                    if(i<nextIndex-(indexOfMarker+1)){
                        scoreArray.remove(at: indexOfMarker)
                        shotViseCurve.remove(at: nextIndex-1)
                    }else{
                        break
                    }
                }
                let dict = getShotDetails(shot:indexOfMarker+1,club:clubValue,isPenalty: false)
                scoreArray.insert(dict, at: indexOfMarker)
            }else{
                scoreArray.remove(at: indexOfMarker)
                self.shotViseCurve.remove(at: indexOfMarker)
            }
            self.penaltyShots.removeAll()
            
            playerDict.setValue(scoreArray, forKey: "shots")
            playerDict.setValue(self.holeOutFlag, forKey: "holeOut")
            playerShotsData.setObject(playerDict, forKey: self.selectedUserId as NSCopying)
            self.scoring[self.holeIndex].players[playerIndex] = playerShotsData
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/").updateChildValues(playerShotsData as! [AnyHashable : Any])
            
            for i in 0..<self.scoring[self.holeIndex].players.count{
                if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                    self.scoring[self.holeIndex].players[i] = playerShotsData
                }
            }
            for i in 0..<scoreArray.count{
                for (key,value) in scoreArray[i]{
                    if(key as! String == "penalty"){
                        self.penaltyShots.append(value as! Bool)
                    }
                }
            }
            
            for i in 0..<positionsOfCurveLines.count{
                plotMarkerForCurvedLine(position: positionsOfCurveLines[i],userData: i)
            }
            updateStateWhileDragging(marker:markersForCurved.last!)
            for subview in stackViewForGreenShots.subviews {
                subview.removeFromSuperview()
            }
            greenStackViewHeight.constant = 0
            for i in 0..<shotViseCurve.count{
                if !self.penaltyShots[i]{
                    showLinesAndMarker(index: i)
                }else{
                    shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                }
            }
            
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 , execute: {
                if(self.isOnCourse){
                    self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                }else{
                    self.plotSuggestedMarkersOffCourse(position: self.positionsOfDotLine)
                }
                self.progressView.hide(navItem: self.navigationItem)
                self.showEditRelated(hide:false)
                self.btnRemovePenaltyLbl.isHidden = true
                self.btnRemovePenalty.isHidden = true
                
                self.updateMap(indexToUpdate: self.holeIndex)
            })
        }
    }
    func setupHoleByHole(){
        self.btnHoleOut.isUserInteractionEnabled = false
        for markers in markersForCurved{
            markers.isDraggable = false
        }
        for marker in markers{
            marker.isDraggable = false
        }
        suggestedMarkerOffCourse.map = nil
        self.btnTrackShot.isHidden = true
        self.lblEditShotNumber.isHidden = true
        self.lblShotNumber.isHidden = true
        self.btnSelectClubs.isHidden = true
        self.btnClubs.isHidden = true
        self.btnTrackShot.isUserInteractionEnabled = false
        self.btnEndRound.isEnabled = false
        self.btnEndRound.setTitle("", for: .normal)
        self.btnEndRound.setCorner(color: UIColor.clear.cgColor)
        self.btnHoleOut.isHidden = true
        self.btnHoleoutLbl.isHidden = true
        self.btnBack.isEnabled = true
        self.btnShareShot.isHidden = true
    }
    @IBAction func btnActionShareShot(_ sender: UIButton) {
        
        if(tappedMarker != nil){
            let shotDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: self.selectedUserId)
            let j = tappedMarker.iconView!.tag
            var newJ = 0
            for i in 0..<self.shotViseCurve.count{
                self.shotViseCurve[i].line.map = nil
                self.shotViseCurve[i].markerPosition.map = nil
                if(self.shotViseCurve[i].markerPosition == self.tappedMarker){
                    newJ = i
                    self.shotViseCurve[i].line.map = self.mapView
                    self.shotViseCurve[i].markerPosition.map = self.mapView
                    self.shotViseCurve[i].markerPosition.position = self.tappedMarker.position
                }
            }
            if(holeOutFlag){
                for i in 0..<markersForCurved.count{
                    self.markersForCurved[i].map = nil
                    if(i == j)||(i == j+1){
                        self.markersForCurved[i].map = self.mapView
                    }
                }
            }
            
            self.letsRotateWithZoom(latLng1: positionsOfCurveLines[j], latLng2: positionsOfCurveLines[j+1],isScreenShot: true)
            let head = GMSGeometryHeading(positionsOfCurveLines[j], positionsOfCurveLines[j+1])
            debugPrint("Heading : \(head)")
            self.tappedMarker.rotation = head
            if(holeOutFlag){
                self.markersForCurved.last!.rotation = head
            }else{
                self.markers.last!.rotation = head
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                debugPrint("After Rotation : \(head)")
                let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ShareMapScoreVC") as! ShareMapScoreVC
                viewCtrl.shareMapView = self.mapView
                viewCtrl.isVertical = true
                debugPrint("shotsCount: \(self.shotCount)")
                
                let frame = self.mapView.frame
                let tempView = UIView(frame:CGRect(x: 0, y: 0, width: frame.height, height: frame.width))
                
                let lbl = UILabel(frame:CGRect(x: 0, y: 16, width: tempView.frame.width, height: 30))
                lbl.text = self.matchDataDict.value(forKey: "courseName") as? String
                lbl.textAlignment = .center
                lbl.textColor = UIColor.glfWarmGrey
                lbl.font = UIFont(name:"SFProDisplay-Bold", size: 18)!
                tempView.addSubview(lbl)
                
                let lbl1 = UILabel(frame:CGRect(x: 0, y: lbl.frame.maxY, width: tempView.frame.width, height: 30))
                lbl1.text = "Hole".localized() + " \(self.holeIndex+1) - " + "Par".localized() + " \(self.scoring[self.holeIndex].par)"

                lbl1.textAlignment = .center
                lbl1.textColor = UIColor.glfGreen
                lbl1.font = UIFont(name:"SFProDisplay-Regular", size: 22)!
                tempView.addSubview(lbl1)
                
                
                let lbl2 = UILabel(frame:CGRect(x: 0, y: lbl1.frame.maxY+16, width: tempView.frame.width, height: 30))
                lbl2.textAlignment = .center
                lbl2.textColor = UIColor.glfBlack
                lbl2.font = UIFont(name:"SFProDisplay-Regular", size: 18)!
                
                var distanceInYrd = shotDetails[newJ].distance
                var suffix = "yd"
                if(Constants.distanceFilter == 1){
                    distanceInYrd = shotDetails[newJ].distance/Constants.YARD
                    suffix = "m"
                }
                if(shotDetails[newJ].swingScore == "G" && shotDetails[newJ].endingPoint == "G"){
                    distanceInYrd = 3 * distanceInYrd
                    suffix = "ft"
                    if(Constants.distanceFilter == 1){
                        distanceInYrd = shotDetails[newJ].distance/(Constants.YARD)
                        suffix = "m"
                    }
                }
                lbl2.text = "\(Int(distanceInYrd.rounded())) \(suffix)"
                tempView.addSubview(lbl2)
                
                let lbl3 = UILabel(frame:CGRect(x: 0, y: lbl2.frame.maxY+16, width: tempView.frame.width, height: 30))
                lbl3.text = shotDetails[newJ].club
                lbl3.textAlignment = .center
                lbl3.textColor = UIColor.glfGreen
                lbl3.font = UIFont(name:"SFProDisplay-Regular", size: 18)!
                tempView.addSubview(lbl3)
                
                let lblForLine = UILabel(frame:CGRect(x: 0, y: 0, width: tempView.frame.width/6, height: 30))
                lblForLine.text = " -------------> "
                lblForLine.textAlignment = .center
                lblForLine.textColor = UIColor.black
                lblForLine.font = UIFont(name:"SFProDisplay-Regular", size: 20)!
                lblForLine.sizeToFit()
                
                let stkView = StackView(frame:CGRect(x: 0, y: 0, width: tempView.frame.width/2, height: 40))
                stkView.axis = .horizontal
                stkView.distribution = .equalCentering
                let start = UIImageView(image: BackgroundMapStats.imageOfButton(endingPoint: shotDetails[newJ].swingScore))
                stkView.addArrangedSubview(start)
                stkView.addArrangedSubview(lblForLine)
                let end = UIImageView(image: BackgroundMapStats.imageOfButton(endingPoint: shotDetails[newJ].endingPoint))
                stkView.addArrangedSubview(end)
                stkView.center.x = tempView.frame.width/2
                stkView.center.y = lbl2.frame.maxY + 4
                tempView.addSubview(stkView)
                var remainingDistance = Double()
                if(self.positionsOfCurveLines.count != j+1){
                    if(!self.holeOutFlag){
                        remainingDistance = GMSGeometryDistance(self.positionsOfCurveLines[j], self.positionsOfDotLine.last!)
                    }else{
                        remainingDistance = GMSGeometryDistance(self.positionsOfCurveLines[j], self.positionsOfCurveLines.last!)
                    }
                    suffix = "yd"
                    if(Constants.distanceFilter == 1){
                        remainingDistance = remainingDistance/Constants.YARD
                        suffix = "m"
                    }
                    //                    if(shotDetails[newJ].swingScore == "G" && shotDetails[newJ].endingPoint == "G"){
                    //                        remainingDistance = 3 * distanceInYrd
                    //                        suffix = "ft"
                    //                        if(distanceFilter == 1){
                    //                            remainingDistance = shotDetails[newJ].distance/(Constants.YARD)
                    //                            suffix = "m"
                    //                        }
                    //                    }
                    
                    let lbl4 = UILabel(frame:CGRect(x: end.frame.minX, y: stkView.frame.maxY + 16, width: tempView.frame.width-end.frame.minX, height: 30))
                    lbl4.text = "\(Int(remainingDistance)) \(suffix) to hole"
                    lbl4.textAlignment = .center
                    lbl4.textColor = UIColor.glfWarmGrey
                    lbl4.font = UIFont(name:"SFProDisplay-Regular", size: 22)!
                    tempView.addSubview(lbl4)
                    
                }
                tempView.frame.size.height =  lbl.frame.height + lbl1.frame.height + stkView.frame.height + 100
                viewCtrl.screenShot1 = tempView.screenshot()
                let navCtrl = UINavigationController(rootViewController: viewCtrl)
                navCtrl.modalPresentationStyle = .overCurrentContext
                self.present(navCtrl, animated: false, completion: nil)
                //                self.letsRotateWithZoom(latLng1: self.positionsOfCurveLines.first!, latLng2: self.positionsOfCurveLines.last!)
                //                self.updateMap(indexToUpdate: self.holeIndex)
            })
        }
    }
    
    @IBAction func btnActionRemovePenalty(_ sender: UIButton) {
        for i in 0..<self.shotViseCurve.count{
            if(self.shotViseCurve[i].markerPosition == self.tappedMarker){
                self.tappedMarker = self.shotViseCurve[i+1].markerPosition
                break
            }
        }
        self.btnActionDeleteShot(sender)
        self.btnRemovePenalty.isHidden = true
        self.btnRemovePenaltyLbl.isHidden = true
    }
    
    @IBAction func btnActionMultiplayer(_ sender: UIButton) {
        if(btnMultiplayer.tag == 0){
            btnMultiplayer.tag = 1
            self.btnMultiplayer.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
            showMultiplayer(hide: false)
        }else{
            btnMultiplayer.tag = 0
            for btn in playersButton where btn.isSelected{
                self.btnMultiplayer.setImage(btn.button.currentImage, for: .normal)
                self.btnMultiplayerLbl.setTitle(btn.name, for: .normal)
            }
            
            showMultiplayer(hide: true)
        }
    }
    func showMultiplayer(hide:Bool){
        for players in playersButton{
            players.button.isHidden = hide
        }
    }
    
    func removeLinesAndMarkers(index:Int){
        if(index < shotViseCurve.count){
            shotViseCurve[index].markerPosition.map = nil
            shotViseCurve[index].line.map = nil
            shotViseCurve[index].swingPosition.map = nil
        }
    }
    
    func showLinesAndMarker(index:Int){
        if(index < shotViseCurve.count){
            if(shotViseCurve[index].markerPosition.userData as! Int) != 0{
                shotViseCurve[index].markerPosition.map = mapView
                if(self.swingMatchId.count > 0){
                    shotViseCurve[index].swingPosition.map = mapView
                }
            }else{
                if let view = shotViseCurve[index].markerPosition.iconView as? ShotMarker{
                    let newIndex = stackViewForGreenShots.subviews.count
                    view.frame.origin = CGPoint(x:0,y:(newIndex*35))
                    stackViewForGreenShots.addSubview(view)
                    stackViewForGreenShots.frame.size.height = CGFloat((newIndex*35)+10)
                    greenStackViewHeight.constant = CGFloat((newIndex*35)+10)
                    stackViewForGreenShots.layoutIfNeeded()
                }
                
            }
            if(isBotTurn){
                if(index+1 < self.markersForCurved.count){
                    markersForCurved[index].map = mapView
                    markersForCurved[index+1].map = mapView
                }
                
            }
            shotViseCurve[index].line.map = mapView
            
        }
    }
    
    func plotMarkerForCurvedLine(position : CLLocationCoordinate2D, userData: Int){
        let marker = GMSMarker(position: position)
        marker.map = mapView
        marker.userData = userData
        marker.title = "Curved"
        marker.icon = #imageLiteral(resourceName: "fixed_point")
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        if(userData == 0){
            marker.icon = #imageLiteral(resourceName: "Tee")
        }
        marker.isDraggable = false
        marker.isTappable = false
        markersForCurved.append(marker)
    }
    func initialSetup(){
        self.mapView.mapType = GMSMapViewType.satellite
        self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
        // setup custom back button
        let originalImage =  #imageLiteral(resourceName: "backArrow")
        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnBack.setImage(backBtnImage, for: .normal)
        btnBack.tintColor = UIColor.glfBluegreen
        btnHole.setCornerWithRadius(color: UIColor.clear.cgColor, radius: self.btnHole.frame.height/2)
        topParView.setCornerView(color: UIColor.glfWhite.cgColor)
        topHCPView.setCornerView(color: UIColor.glfWhite.cgColor)
        stablefordSubView.setCornerView(color: UIColor.glfWhite.cgColor)
        imgViewRefreshScore.tintImageColor(color: UIColor.glfWhite)
        btnPrev.setCircle(frame: self.btnPrev.frame)
        btnNext.setCircle(frame: self.btnNext.frame)
        btnCenter.roundCorners([.bottomLeft,.bottomRight], radius: 3.0)
        btnMoveToMapGround.roundCorners([.bottomLeft,.bottomRight], radius: 3.0)
        
        btnEndRound.setCorner(color: UIColor.glfWhite.cgColor)
        btnViewScorecard.setCorner(color: UIColor.clear.cgColor)
        btnViewScorecard.layer.masksToBounds = true
        let gradient2 = CAGradientLayer()
        gradient2.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient2.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient2.frame = btnViewScorecard.bounds
        btnViewScorecard.layer.addSublayer(gradient2)
        btnRestartLbl.layer.cornerRadius = btnRestartLbl.frame.height/2
        
        btnPlayersStats2.imageView?.clipsToBounds = false
        btnPlayersStats2.imageView?.contentMode = .center
        btnPlayersStats2.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        btnForSuggMarkOffCourse.frame = CGRect(x: 0, y: 0, width: 95, height: 45)
        btnPlayersStats.setCircle(frame: self.btnPlayersStats.frame)
        let layers = CAGradientLayer()
        layers.frame.size = btnPlayersStats.frame.size
        layers.startPoint = .zero
        layers.endPoint = CGPoint(x:1/2,y:1)
        layers.colors = [UIColor.glfBlack50.cgColor, UIColor.glfBlack50.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        layers.locations = [0.0 ,0.5, 0.5, 1.0]
        layers.cornerRadius = self.btnPlayersStats.frame.height/2
        btnPlayersStats.layer.insertSublayer(layers, at: 0)
        
        self.exitGamePopUpView.show(navItem: self.navigationItem)
        self.exitGamePopUpView.delegate = self
        self.exitGamePopUpView.isHidden = true
        btnClubs.layer.cornerRadius = CGFloat(35.0)
        
        btnTrackShot.backgroundColor = UIColor.glfBluegreen
        btnTrackShot.layer.cornerRadius = CGFloat(35.0)
        btnTrackShot.layer.shadowColor = UIColor.black.cgColor
        btnTrackShot.layer.shadowOpacity = 0.75
        btnTrackShot.layer.shadowRadius = 2
        btnTrackShot.layer.shadowOffset = CGSize(width:5.0, height:5.0)
        
        
        for btn in stackViewSubBtn.subviews{
            (btn as! UIButton).setCircle(frame: btn.frame)
        }
        btnMultiplayerLbl.layer.cornerRadius = 15.0
        btnCloseLbl.layer.cornerRadius = 15.0
        btnDeleteLbl.layer.cornerRadius = 15.0
        btnAddPenaltyLbl.layer.cornerRadius = 15.0
        btnRemovePenaltyLbl.layer.cornerRadius = 15.0
        btnHoleoutLbl.layer.cornerRadius = 15.0
        
        btnLandedOnEdit.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnLandedOnEdit.frame.height/2)
        btnLandedOnDropDown.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnLandedOnDropDown.frame.height/2)
        
        btnSelectClubs.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnSelectClubs.frame.height/2)
        lblShotNumber.setCornerWithRadius(color: UIColor.clear.cgColor, radius: lblShotNumber.frame.height/2)
        lblEditShotNumber.setCornerWithRadius(color: UIColor.clear.cgColor, radius: lblEditShotNumber.frame.height/2)
        if Constants.deviceGolficationX == nil{
            courseData.clubs.remove(at: courseData.clubs.index(of: "more")!)
        }
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.addTarget(self, action: #selector(self.swipedViewUp))
        btnPlayersStats.addGestureRecognizer(swipeUp)
        
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.addTarget(self, action: #selector(self.swipedViewDown))
        viewHoleStats.addGestureRecognizer(swipeDown)
        for btn in self.stackViewForMultiplayer.arrangedSubviews where btn.isKind(of: UIButton.self){
            btn.isHidden = true
            (btn as! UIButton).setCircle(frame: btn.frame)
            (btn as! UIButton).addTarget(self, action: #selector(self.playersAction), for: .touchUpInside)
        }
        
        btnNextScrl.setCircle(frame: btnNextScrl.frame)
        btnPrevScrl.setCircle(frame: btnPrevScrl.frame)
        
        
        if(!self.isHoleByHole){
            self.mapView.settings.consumesGesturesInView = true
            for gestureRecognizer in self.mapView.gestureRecognizers! {
                if #available(iOS 11.0, *) {
                    debugPrint(gestureRecognizer.name as Any)
                } else {
                    // Fallback on earlier versions
                }
                if !gestureRecognizer.isKind(of: UITapGestureRecognizer.self){
                    gestureRecognizer.addTarget(self, action: #selector(NewMapVC.handleTap(_:)))
                    (gestureRecognizer as? UITapGestureRecognizer)?.numberOfTapsRequired = 2
                }
            }
        }
        if(!isHoleByHole){
            if let onCourse = self.matchDataDict.value(forKeyPath: "onCourse") as? Bool{
                if !(onCourse){
                    self.btnVRView.isHidden = true
                    self.centerSV.isHidden = true
                    self.centerSVWidthConstraints.constant = 0
                    self.lblWindSpeed.isHidden = true
                    self.imgViewWind.isHidden = true
                }else{
                    NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

                    setupPanGuesture()
                }
            }
        }else{
            self.centerSV.isHidden = true
            self.centerSVWidthConstraints.constant = 0
            self.view.layoutIfNeeded()
        }
        for view in self.stackViewForGreenShots.arrangedSubviews{
            view.removeFromSuperview()
        }
        
        btnForSuggMark1.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
        btnForSuggMark1.setTitleColor(UIColor.glfWhite, for: .normal)
        let layer1 = CAGradientLayer()
        layer1.frame.size = btnForSuggMark1.frame.size
        layer1.cornerRadius = 5
        layer1.backgroundColor = UIColor.glfBlack50.cgColor
        btnForSuggMark1.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark1.layer.insertSublayer(layer1, at: 0)
        btnForSuggMark1.titleLabel?.textColor = UIColor.glfBlack
        btnForSuggMark1.imageView?.layer.zPosition = 1
        btnForSuggMark1.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
        
        
        btnForSuggMark2.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
        btnForSuggMark2.setTitleColor(UIColor.glfWhite, for: .normal)
        let layer2 = CAGradientLayer()
        layer2.frame.size = btnForSuggMark1.frame.size
        layer2.cornerRadius = 5
        layer2.backgroundColor = UIColor.glfBlack50.cgColor
        
        btnForSuggMark2.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark2.layer.insertSublayer(layer2, at: 0)
        btnForSuggMark2.titleLabel?.textColor = UIColor.glfBlack
        btnForSuggMark2.imageView?.layer.zPosition = 1
        btnForSuggMark2.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
        self.scoreTableView.dataSource = self
        self.scoreTableView.delegate = self
        if(UIDevice.current.iPad){
            self.playerStatsHeightConst.constant = 120
            self.playerStatsWidthConst.constant = 120
            self.btnClubHeightConst.constant = 50
            self.btnClubWidthConst.constant = 50
            self.btnTrackShotWidth.constant = 50
            self.btnTrackShotHeight.constant = 50
            
            btnPlayersStats.setCircle(frame: self.btnPlayersStats.frame)
            let layers = CAGradientLayer()
            layers.frame.size = btnPlayersStats.frame.size
            layers.startPoint = .zero
            layers.endPoint = CGPoint(x:1/2,y:1)
            layers.colors = [UIColor.glfBlack50.cgColor, UIColor.glfBlack50.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
            layers.locations = [0.0 ,0.5, 0.5, 1.0]
            layers.cornerRadius = self.btnPlayersStats.frame.height/2
            btnPlayersStats.layer.insertSublayer(layers, at: 0)
            
            self.btnTrackShot.layer.cornerRadius = 25.0
            self.btnClubs.layer.cornerRadius = 25.0
            
            self.btnSelectClubs.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 10)!
            self.btnPlayersStats.titleLabel?.font = UIFont(name:"SFProDisplay-Bold", size: 15)!
        }
        self.getBotPlayersDataFromFirebase()
    }
    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .restricted, .denied:
                let alertController = UIAlertController(
                    title: "Background Location Access",
                    message: "For Rangefinder distance notification, please open this app's settings and set location access to 'Always'.",
                    preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(url, options:[:], completionHandler: { (isTrue) in
                            debugPrint("setting Opened")
                        })
                    }
                }
                alertController.addAction(openAction)
                self.present(alertController, animated: true, completion: nil)
            case .authorizedAlways:
                locationManager.allowsBackgroundLocationUpdates = true
        case .notDetermined:
                let alert = UIAlertController(title: "Alert" , message: "Please enable location to use this mode." , preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func markerAction(_ sender:UIButton){
        debugPrint(sender.tag)
    }
    @IBAction func btnActionChangeHole(_ sender: Any) {
        if(!isHoleByHole){
            var strArr = [String]()
            for hole in self.scoring{
                strArr.append("Hole".localized() + " \(hole.hole) - " + "Par".localized() + " - \(hole.par)")
            }
            ActionSheetStringPicker.show(withTitle: "Select Hole", rows: strArr, initialSelection: holeIndex, doneBlock: { (picker, value, index) in
                self.holeIndex = value
                self.updateMap(indexToUpdate: value)
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        }
    }
    
    func codeWhenClickToBackView(){
        if (!self.viewHoleStats.isHidden){
            self.btnActionPlayerStats(Any.self)
        }
        if(self.btnMultiplayer.currentImage == #imageLiteral(resourceName: "cross")){
            self.btnMultiplayer.tag = 0
            for btn in playersButton where btn.isSelected{
                self.btnMultiplayer.setImage(btn.button.currentImage, for: .normal)
            }
            showMultiplayer(hide: true)
        }
        if(selectClubDropper.status == .shown) || (selectClubDropper.status == .displayed){
            selectClubDropper.hideWithAnimation(0.15)
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if popupOffset >= viewHoleStats.frame.size.height{
            panGesture.isEnabled = true
            return false
        }
        panGesture.isEnabled = false
        return true
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.codeWhenClickToBackView()
        if (!self.isProcessing) && (!holeOutFlag) && !self.isTracking{
            self.backTouched()
            if(isOnCourse) && !self.isTracking{
                for m in markers{
                    m.isDraggable = true
                    self.allMarkers.append(m)
                }
            }
            self.allMarkers = self.allMarkers.removeDuplicates()
            if(!markers.isEmpty) && self.allMarkers.index(of: self.markers.first!) != nil{
                if !self.positionsOfCurveLines.isEmpty && !isOnCourse && btnClose.isHidden{
                    self.allMarkers.remove(at: self.allMarkers.index(of: self.markers.first!)!)
                }else if isOnCourse{
                    self.allMarkers.remove(at: self.allMarkers.index(of: self.markers.first!)!)
                }
                
            }
            
            //            }else if (markers.count > 0) && self.allMarkers.index(of: self.markers.first!) != nil{
            //                self.allMarkers.remove(at: self.allMarkers.index(of: self.markers.first!)!)
            //            }
            for coord in courseData.numberOfHoles[holeIndex].green{
                self.pathOfGreen.add(coord)
            }
            self.mapView.settings.scrollGestures = true
            if(sender.numberOfTouches == 1){
                var positions = CGPoint()
                var newPosition = CLLocationCoordinate2D()
                let currentZoom = self.mapView.camera.zoom
                
                switch (sender.state){
                case .began:
                    positions = sender.location(in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = BackgroundMapStats.getNearbymarkers(position: newPosition,markers:allMarkers)
                    self.dragMarkShowCase = allMarkers[ind]
                    print(ind)
                    if(!self.positionsOfDotLine.isEmpty && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < BackgroundMapStats.getDistanceWithZoom(zoom: currentZoom)){
                            debugPrint(currentZoom)
                            debugPrint("begun")
                            debugPrint(distance)
                            self.mapView.settings.scrollGestures = false
                            if ((allMarkers[ind].userData as! Int == 2) && (allMarkers[ind].title == "Point")){
                                if GMSGeometryContainsLocation(newPosition, pathOfGreen, true){
                                    allMarkers[ind].position = newPosition
                                }
                            }else{
                                allMarkers[ind].position = newPosition
                            }
                            self.mapView.settings.scrollGestures = true
                        }
                    }
                    break
                    
                case .ended:
                    self.dragMarkShowCase = nil
                    positions = sender.location(in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = BackgroundMapStats.getNearbymarkers(position: newPosition,markers:allMarkers)
                    print(ind)
                    if(!self.positionsOfDotLine.isEmpty && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < BackgroundMapStats.getDistanceWithZoom(zoom: currentZoom)){
                            debugPrint(currentZoom)
                            debugPrint("ended")
                            debugPrint(distance)
                            self.mapView.settings.scrollGestures = false
                            if ((allMarkers[ind].userData as! Int == 2) && (allMarkers[ind].title == "Point")){
                                if GMSGeometryContainsLocation(newPosition, pathOfGreen, true){
                                    allMarkers[ind].position = newPosition
                                }
                            }else{
                                allMarkers[ind].position = newPosition
                            }
                            if(allMarkers[ind].title == "Curved" || allMarkers[ind].title == "PointWithCurved"){
                                isDraggingMarker = true
                                updateStateWhileDragging(marker:allMarkers[ind])
                                isDraggingMarker = false
                            }
                            self.mapView.settings.scrollGestures = true
                        }
                    }
                    break
                case .changed:
                    positions = sender.location(in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = BackgroundMapStats.getNearbymarkers(position: newPosition,markers:allMarkers)
                    print(ind)
                    self.dragMarkShowCase = allMarkers[ind]
                    if(!self.positionsOfDotLine.isEmpty && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < BackgroundMapStats.getDistanceWithZoom(zoom: currentZoom)) && sender.numberOfTouches != 2{
                            debugPrint(currentZoom)
                            debugPrint("changed")
                            debugPrint(distance)
                            self.mapView.settings.scrollGestures = false
                            // for flag so it does not move outside the boundaries
                            if ((allMarkers[ind].userData as! Int == 2) && (allMarkers[ind].title == "Point")){
                                if GMSGeometryContainsLocation(newPosition, pathOfGreen, true){
                                    allMarkers[ind].position = newPosition
                                }
                            }else{
                                allMarkers[ind].position = newPosition
                            }
                            isDraggingMarker = true
                            
                            self.mapView(self.mapView, didDrag: allMarkers[ind])
                            //                            updateLine(mapView: mapView, marker: allMarkers[ind])
                            self.mapView.settings.scrollGestures = true
                            isDraggingMarker = false
                        }
                    }
                    break
                default:
                    break
                }
            }else if(sender.numberOfTouches == 2) && isDraggingMarker{
                self.mapView.settings.scrollGestures = false
            }else{
                self.mapView.settings.scrollGestures = false
            }
        }
        if (sender.numberOfTouches == 2){
            var rotationAngle = self.mapView.camera.bearing - self.windHeading
            if isOnCourse{
                if let location = self.locationManager.location{
                    let heading = GMSGeometryHeading(location.coordinate,self.courseData.centerPointOfTeeNGreen[self.holeIndex].green)
                    rotationAngle = heading - self.windHeading
                }
            }
            
            self.imgViewWind.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle) / 180.0 * CGFloat(Double.pi))
        }
        
    }
    
    func getShotDataOrdered(indexToUpdate:Int,playerId:String)->[(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]{
        var shotsArr = NSArray()
        var shotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
        for playerScore in scoring[indexToUpdate].players{
            for (key,value) in playerScore{
                if(playerId == key as! String){
                    let shots = value as! NSDictionary
                    for(key,value)in shots{
                        if(key as! String == "shots"){
                            shotsArr = value as! NSArray
                            break
                        }
                    }
                }
            }
        }
        if(shotsArr.count > 0){
            for data in shotsArr{
                let score = data as! NSMutableDictionary
                let distance = score.value(forKey: "distance") as? Double
                let club = score.value(forKey: "club") as! String
                let strokGaind = score.value(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double
                let endingPoints = score.value(forKey: "end") as? String
                let penalty = score.value(forKey: "penalty") as! Bool
                let startingPoint = score.value(forKey: "start") as? String
                shotsDetails.append((club: club, distance: distance ?? 0.0, strokesGained: strokGaind ?? 0.0, swingScore: startingPoint ?? "calculating",endingPoint:endingPoints ?? "calculationg ",penalty:penalty))
            }
        }
        if !self.holeOutFlag && !self.swingMatchId.isEmpty && !shotsDetails.isEmpty{
            shotsDetails.removeLast()
        }
        return shotsDetails
    }
    
    
    func mapView (_ mapView:GMSMapView, didBeginDragging didBeginDraggingMarker:GMSMarker){
        self.dragMarkShowCase = didBeginDraggingMarker
        if(didBeginDraggingMarker.icon == #imageLiteral(resourceName: "holeflag")){
            if GMSGeometryContainsLocation(didBeginDraggingMarker.position, pathOfGreen, true){
                isDraggingMarker = true
                debugPrint("inside")
            }else{
                isDraggingMarker = false
                debugPrint("outside")
            }
        }else{
            isDraggingMarker = true
        }
        
    }
    
    func mapView (_ mapView: GMSMapView, didDrag didDragMarker:GMSMarker){
        self.dragMarkShowCase = didDragMarker
        if(didDragMarker.icon == #imageLiteral(resourceName: "holeflag")){
            if GMSGeometryContainsLocation(didDragMarker.position, pathOfGreen, true){
                didDragMarker.isDraggable = true
                updateLine(mapView: mapView, marker: didDragMarker)
                debugPrint("inside")
                isDraggingMarker = true
                didDragMarker.isTappable = true
            }else{
                isDraggingMarker = false
                self.mapView(self.mapView, didEndDragging: didDragMarker)
            }
        }else{
            didDragMarker.isDraggable = true
            updateLine(mapView: mapView, marker: didDragMarker)
            isDraggingMarker = true
        }
        if(tappedMarker != nil) && self.positionsOfCurveLines.count >= 0 && self.shotViseCurve.count > tappedMarker.iconView!.tag && didDragMarker.icon != #imageLiteral(resourceName: "target") {
            self.mapView(self.mapView, didTap: self.shotViseCurve[tappedMarker.iconView!.tag].line)
        }
    }
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker){
        self.dragMarkShowCase = nil
        if(didEndDraggingMarker.title == "Curved" || didEndDraggingMarker.title == "PointWithCurved"){
            isDraggingMarker = true
            updateStateWhileDragging(marker:didEndDraggingMarker)
        }else{
            isDraggingMarker = false
        }
        if(tappedMarker != nil) && self.positionsOfCurveLines.count >= 0 && self.shotViseCurve.count > tappedMarker.iconView!.tag && didEndDraggingMarker.icon != #imageLiteral(resourceName: "target"){
            self.mapView(self.mapView, didTap: self.shotViseCurve[tappedMarker.iconView!.tag].line)
        }

    }
    func updateStateWhileDragging(marker:GMSMarker){
        var playerIndex : Int!
        var playerId : String!
        for players in playersButton{
            if(players.isSelected){
                playerId = players.id
                for i in 0..<self.scoring[holeIndex].players.count{
                    if((self.scoring[holeIndex].players[i].value(forKey: playerId)) != nil){
                        playerIndex = i
                        break
                    }
                }
            }
        }
        
        if(marker.title == "Curved"){
            if(marker.userData as! Int == 0){
                uploadStatsWithDragging(shot: marker.userData as! Int+1,playerId: playerId,playerIndex: playerIndex)
            }
            else if(marker.userData as! Int == shotCount){
                for i in 1..<markersForCurved.count{
                    uploadStatsWithDragging(shot: i , playerId: playerId, playerIndex: playerIndex)
                }
            }
            else{
                uploadStatsWithDragging(shot: marker.userData as! Int, playerId: playerId, playerIndex: playerIndex)
                uploadStatsWithDragging(shot: marker.userData as! Int + 1, playerId: playerId, playerIndex: playerIndex)
            }
        }else if(marker.title == "PointWithCurved"){
            uploadStatsWithDragging(shot: self.shotCount, playerId: playerId, playerIndex: playerIndex)
        }
        debugPrint(self.scoring[self.holeIndex].players)
        if(self.btnTrackShot.currentImage == #imageLiteral(resourceName: "check_mark_fab")){
            self.btnTrackShot.backgroundColor = UIColor.glfGreenBlue
        }
        self.getScoreFromMatchDataFirebases()
    }
    func uploadStatsWithDragging(shot:Int,playerId:String,playerIndex:Int){
        let girDict = NSMutableDictionary()
        let faiDict = NSMutableDictionary()
        self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: self.selectedUserId)
        if(shot==1) && (positionsOfCurveLines.count > 1){
            gir = false
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
            if(self.scoring[self.holeIndex].par > 3){
                faiDict.setObject(fairwayDetailsForFirstShot(shot:shot), forKey: "fairway" as NSCopying)
            }
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/").updateChildValues(faiDict as! [AnyHashable : Any])
            let drivDistDict = NSMutableDictionary()
            if(self.scoring[self.holeIndex].par>3){
                let drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*Constants.YARD
                drivDistDict.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
            }
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/").updateChildValues(drivDistDict as! [AnyHashable : Any])
            
        }
        else if(shot == 2)&&(!gir)&&(self.scoring[self.holeIndex].par>3){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        else if(shot == 3)&&(!gir)&&(self.scoring[self.holeIndex].par>4){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        
        
        if(holeOutFlag) && shot == self.shotCount{
            uploadChipUpNDown(playerId: playerId)
            uploadSandUpNDown(playerId: playerId)
            uploadPutting(playerId: playerId)
            self.uploadPenalty(playerId: playerId)
            if(!self.teeTypeArr.isEmpty){
                self.uploadStableFordPints(playerId: playerId)
            }
        }
        
        uploadApproachAndApproachShots(playerId: playerId)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/").updateChildValues(girDict as! [AnyHashable : Any])
        let shotsDict = self.scoring[self.holeIndex].players[playerIndex].value(forKey: playerId) as! NSMutableDictionary
        if var shotsValue = shotsDict.value(forKey: "shots") as? [NSMutableDictionary]{
            if(shot-1 < shotsValue.count){
                let clubValue = shotsValue[shot-1].value(forKey: "club") as! String
                let isPenaltyShot = shotsValue[shot-1].value(forKey: "penalty") as! Bool
                shotsValue[shot-1] = getShotDetails(shot:shot,club:clubValue,isPenalty: isPenaltyShot)
                if(!isDraggingMarker) && shotsDetails.count > shot-1{
                    shotsValue[shot-1] = self.reCalculateStats(shot: shot, club: shotsDetails[shot-1].club, isPenalty: shotsDetails[shot-1].penalty, end: shotsDetails[shot-1].endingPoint, start: shotsDetails[shot-1].swingScore)
                }
                shotsDict.setValue(shotsValue, forKey: "shots")
                //        print(shotsDict)
                self.scoring[self.holeIndex].players[playerIndex].setValue(shotsDict, forKey: playerId)
                
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/shots/\(shot-1)").updateChildValues(shotsValue[shot-1] as! [AnyHashable : Any])
            }
        }
    }
    private func reCalculateStats(shot:Int,club:String,isPenalty:Bool,end:String,start:String)->NSMutableDictionary{
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        if(club == ""){
            shotDictionary.setObject(courseData.clubs[self.btnSelectClubs.tag], forKey: "club" as NSCopying)
        }
        else{
            shotDictionary.setObject(club, forKey: "club" as NSCopying)
        }
        var start = start
        var end = end
        shotDictionary.setObject(isPenalty, forKey: "penalty" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].latitude, forKey: "lat2" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].longitude, forKey: "lng2" as NSCopying)
        shotDictionary.setObject(start, forKey: "start" as NSCopying)
        shotDictionary.setObject(end, forKey: "end" as NSCopying)
        
        let distanceBwShots = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])
        let distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines.last!)
        var distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfCurveLines.last!)
        if(distanceBwHole1 == 0) && !positionsOfDotLine.isEmpty{
            distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
        }
        shotDictionary.setObject((distanceBwShots*Constants.YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*Constants.YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*Constants.YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*Constants.YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*Constants.YARD).rounded()))"
        }
        if(Int((distanceBwHole0*Constants.YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*Constants.YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*Constants.YARD).rounded()) < 100) && shot == 0{
            start = "\(start)100"
        }
        debugPrint(start)
        debugPrint(end)
        var numberOfPenalty = 0
        if(shot < penaltyShots.count){
            for i in shot..<penaltyShots.count{
                if (self.penaltyShots[i]){
                    numberOfPenalty += 1
                }else{
                    break
                }
            }
        }
        
        for i in 0..<Constants.strkGainedString.count{
            var strkG = calculateStrokesGained(start:start,end:end,filterIndex:i)
            strkG = strkG - Double(numberOfPenalty)
            shotDictionary.setObject(strkG, forKey: Constants.strkGainedString[i] as NSCopying)
        }
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot]), forKey: "heading" as NSCopying)
        return shotDictionary
    }
    func mapView(_ mapView: GMSMapView,  marker:GMSMarker)->Bool{
        marker.map = nil
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func updateLine(mapView:GMSMapView, marker:GMSMarker){
        
        isUpdating = true
        draggingMarker = marker
        let ind = marker.userData as! Int
        var indexForDot = -1
        var indexForCur = -1
        if(BackgroundMapStats.isPositionAvailable(latLng: marker.position, latLngArray: positionsOfDotLine) != -1){
            indexForDot = BackgroundMapStats.isPositionAvailable(latLng: marker.position, latLngArray: positionsOfDotLine)
        }
        if BackgroundMapStats.isPositionAvailable(latLng: marker.position, latLngArray: positionsOfCurveLines) != -1 {
            indexForCur = BackgroundMapStats.isPositionAvailable(latLng: marker.position, latLngArray: positionsOfCurveLines)
        }
        if(indexForCur != -1 && indexForDot != -1 ){
            marker.title = "PointWithCurved"
        }
        for i in 0..<shotViseCurve.count{
            removeLinesAndMarkers(index: i)
        }
        if(!positionsOfDotLine.isEmpty && marker.title == "Point" ){
            positionsOfDotLine.remove(at: marker.userData as! Int)
            positionsOfDotLine.insert(marker.position, at: marker.userData as! Int)
            plotLine(positions: positionsOfDotLine)
        }else if(!positionsOfCurveLines.isEmpty && marker.title == "Curved"){
            if(shotCount > 1 && marker.userData as! Int > 0){
                if(positionsOfDotLine.isEmpty && shotCount == ind){
                    plotCurvedPolyline(latLng1: positionsOfCurveLines[ind-1], latLng2: positionsOfCurveLines[ind],whichLine: false, club: self.shotsDetails[ind-1].club)
                    shotViseCurve[ind-1] = (shot: ind-1, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker)
                }
                else{
                    if(isOnCourse) && shotCount == ind{
                        plotCurvedPolyline(latLng1: positionsOfCurveLines[ind-1], latLng2: positionsOfCurveLines[ind],whichLine: false, club: self.shotsDetails[ind-1].club)
                        shotViseCurve[ind-1] = (shot: ind-1, line: curvedLines , markerPosition:markerInfo,swingPosition:swingMarker)
                        
                    }else{
                        plotCurvedPolyline(latLng1: positionsOfCurveLines[ind-1], latLng2: marker.position,whichLine: false, club: self.shotsDetails[ind-1].club)
                        plotCurvedPolyline(latLng1: marker.position, latLng2: positionsOfCurveLines[ind+1],whichLine: true, club: self.shotsDetails[ind].club)
                        shotViseCurve[ marker.userData as! Int] = (shot:  marker.userData as! Int, line: curvedLine2 , markerPosition:markerInfo2, swingPosition:swingMarker2)
                        shotViseCurve[ marker.userData as! Int-1] = (shot:  marker.userData as! Int - 1, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker)
                    }
                }
            }
            else{
                plotLine(positions: positionsOfDotLine)
                plotCurvedPolyline(latLng1: positionsOfCurveLines[0], latLng2: positionsOfCurveLines[1],whichLine: false,club:shotsDetails[0].club)
                shotViseCurve[0] = (shot: 0, line: curvedLines , markerPosition:markerInfo, swingPosition:swingMarker)
            }
            positionsOfCurveLines.remove(at: ind)
            positionsOfCurveLines.insert(marker.position, at: ind)
        }
        else if(marker.title == "PointWithCurved"){
            positionsOfDotLine.remove(at: 0)
            positionsOfDotLine.insert(marker.position, at: 0)
            
            debugPrint("Moving Line Together : \(marker.userData as! Int)")
            //            updateMid()
            plotLine(positions: positionsOfDotLine)
            //-------------------//
            debugPrint("Moving Curved Together")
            debugPrint(positionsOfCurveLines.count)
            plotCurvedPolyline(latLng1: positionsOfCurveLines[shotCount-1], latLng2: marker.position,whichLine: true,club:(self.shotsDetails.last?.club)!)
            shotViseCurve[shotCount-1] = (shot:  shotCount-1, line: curvedLine2 , markerPosition:markerInfo2, swingPosition:swingMarker2)
            positionsOfCurveLines.remove(at: shotCount)
            positionsOfCurveLines.insert(marker.position, at: shotCount)
        }
        for subview in stackViewForGreenShots.subviews {
            subview.removeFromSuperview()
        }
        greenStackViewHeight.constant = 0
        
        for i in 0..<shotViseCurve.count{
            if(!penaltyShots[i]){
                showLinesAndMarker(index: i)
            }else{
                shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
            }
        }
    }
    
    func plotCurvedPolyline(latLng1:CLLocationCoordinate2D,latLng2:CLLocationCoordinate2D,whichLine:Bool,club:String){
        var isInside = false
        let height = 0.30
        let pathGreen = GMSMutablePath()
        for coord in courseData.numberOfHoles[self.holeIndex].green{
            pathGreen.add(coord)
        }
        var path = GMSMutablePath()
        let distance = GMSGeometryDistance(latLng1, latLng2)
        let heading = GMSGeometryHeading(latLng1, latLng2)
        let centerPoint = GMSGeometryOffset(latLng1, distance/2, heading)
        let  x = (1-height*height)*distance*0.5/(2*height);
        let  r = (1+height*height)*distance*0.5/(2*height);
        
        var newLatLng = CLLocationCoordinate2D()
        if(heading > 180){
            newLatLng = GMSGeometryOffset(centerPoint, x, heading+90)
        }
        else{
            newLatLng = GMSGeometryOffset(centerPoint, x, heading-90)
        }
        
        let headingBwFirstToCenterPoint = GMSGeometryHeading(newLatLng, latLng1)
        let headingBwLastToCenterPoint = GMSGeometryHeading(newLatLng, latLng2)
        
        
        let step = (headingBwLastToCenterPoint-headingBwFirstToCenterPoint)/100
        var curvedLatLngArr = [CLLocationCoordinate2D]()
        var curvedLatLng:CLLocationCoordinate2D!
        let btnView = ShotMarker()
        btnView.frame = CGRect(x: 0, y: 0, width: 110, height: 30)
        btnView.newBtn.frame = btnView.frame
        btnView.newBtn.addTarget(self, action: #selector(self.shotMarkerBtnAction), for: .touchUpInside)
        
        var labelPosition = CLLocationCoordinate2D()
        
        for i in 0..<101{
            curvedLatLng = GMSGeometryOffset(newLatLng, r, headingBwFirstToCenterPoint+(Double(i)*step))
            curvedLatLngArr.append(curvedLatLng)
            path.add(curvedLatLng)
            if(i==50){
                btnView.tag = shotCount
                btnView.newBtn.tag = shotCount
                let dict2:[NSAttributedStringKey:Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 14)!,
                    NSAttributedStringKey.foregroundColor : UIColor.white]
                
                let dict1: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 14)!,
                    NSAttributedStringKey.foregroundColor : UIColor.white]
                
                let attributedText = NSMutableAttributedString()
                
                var distanceInYrd = distance * Constants.YARD
                var suffix = "yd"
                let isLatLng1InsideGreen = BackgroundMapStats.findPositionOfPointInside(position: latLng1, whichFeature: courseData.numberOfHoles[holeIndex].green)
                let isLatLng2InsideGreen = BackgroundMapStats.findPositionOfPointInside(position: latLng2, whichFeature: courseData.numberOfHoles[holeIndex].green)
                if(isLatLng1InsideGreen) && (isLatLng2InsideGreen){
                    distanceInYrd = 3 * distanceInYrd
                    suffix = "ft"
                }
                if(Constants.distanceFilter == 1){
                    distanceInYrd = distance
                    suffix = "m"
                }
                distanceInYrd = distanceInYrd.rounded()
                var shot = String()
                if(isUpdating){
                    var ind = draggingMarker.userData as! Int
                    if(whichLine){
                        if(draggingMarker.title == "PointWithCurved"){
                            shot = "\(shotCount)"
                            attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                            attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                        }
                        else{
                            shot = "\(ind+1)"
                            attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                            attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                        }
                        
                    }else{
                        if(ind == 0 && draggingMarker.title != "PointWithCurved"){
                            ind = ind + 1
                        }
                        shot = "\(ind)"
                        attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                        attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                    }
                }
                else{
                    shot = "\(shotCount+1)"
                    attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                    attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                }
                btnView.btn.setTitle(shot, for: .normal)
                btnView.lbl.attributedText = attributedText
                labelPosition = curvedLatLng
            }
        }
        
        if(GMSGeometryContainsLocation(latLng1,pathGreen,true) && GMSGeometryContainsLocation(latLng1,pathGreen,true)){
            isInside = true
        }
        if(whichLine){
            markerInfo2.map = nil
            markerInfo2 = GMSMarker(position: labelPosition)
            markerInfo2.groundAnchor = CGPoint(x:0.02,y:0.5)
            markerInfo2.infoWindowAnchor = CGPoint(x:0,y:1)
            markerInfo2.iconView = btnView
            
            swingMarker2.map = nil
            swingMarker2 = GMSMarker(position: labelPosition)
            swingMarker2.groundAnchor = CGPoint(x:-4.0,y:0.5)
            swingMarker2.icon = #imageLiteral(resourceName: "edit_White")
            swingMarker2.userData = "Swing"
            if(isInside){
                markerInfo2.userData = 0
                path = GMSMutablePath()
                path.add(latLng1)
                path.add(latLng2)
            }else{
                markerInfo2.userData = 1
            }
            curvedLine2.map = nil
            curvedLine2.isTappable = true
            curvedLine2 = GMSPolyline(path:path)
            curvedLine2.strokeColor = UIColor.glfDarkGreen
            curvedLine2.strokeWidth = 2.0
            curvedLine2.geodesic = true
        }
        else{
            markerInfo.map = nil
            markerInfo = GMSMarker(position: labelPosition)
            markerInfo.groundAnchor = CGPoint(x:0.02,y:0.5)
            markerInfo.infoWindowAnchor = CGPoint(x:0,y:1)
            markerInfo.iconView = btnView

            swingMarker.map = nil
            swingMarker = GMSMarker(position: labelPosition)
            swingMarker.groundAnchor = CGPoint(x:-4.0,y:0.5)
            swingMarker.icon = #imageLiteral(resourceName: "edit_White")
            swingMarker.userData = "Swing"
            if(isInside){
                markerInfo.userData = 0
                path = GMSMutablePath()
                path.add(latLng1)
                path.add(latLng2)
            }else{
                markerInfo.userData = 1
            }
            curvedLines.map = nil
            curvedLines.isTappable = true
            curvedLines = GMSPolyline(path:path)
            curvedLines.strokeColor = UIColor.glfDarkGreen
            curvedLines.strokeWidth = 2.0
            curvedLines.geodesic = true


        }
    }
    @objc func shotMarkerBtnAction(sender:UIButton){
        debugPrint(sender.tag)
        
        let marker = self.shotViseCurve[sender.tag].markerPosition
        if(!isHoleByHole) && self.selectedUserId != "jpSgWiruZuOnWybYce55YDYGXP62" && !self.markers.contains(marker){
            tappedMarker = marker
            if (tappedMarker.iconView)?.tag != nil {
                self.codeWhenClickToBackView()
                self.btnTrackShot.tag = tappedMarker.iconView!.tag
                self.btnTrackShot.setImage(#imageLiteral(resourceName: "edit_White"), for: .normal)
                self.lblShotNumber.isHidden = true
                self.btnHoleOut.isHidden = true
                self.lblEditShotNumber.isHidden = false
                self.btnClubs.isHidden = true
                self.btnSelectClubs.isHidden = true
                self.lblEditShotNumber.text = "\(tappedMarker.iconView!.tag+1)"
                if(isOnCourse){
                    if self.mapTimer.isValid{
                        self.mapTimer.invalidate()
                    }
                }
            }
        }else{
            tappedMarker = (tappedMarker == nil) ? nil : nil
        }
    }
    func updateMid(){
        let distance = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)
        let heading = GMSGeometryHeading(positionsOfDotLine.first!, positionsOfDotLine.last!)
        let middilep = GMSGeometryOffset(positionsOfDotLine.first!, distance*0.8,heading)
        positionsOfDotLine[1] = middilep
        if(self.markers.count > 2){
            markers[1].position = middilep
        }
    }
    func plotSuggestedMarkersOffCourse(position:[CLLocationCoordinate2D]){
        var markerText = String()
        var markerClub = String()
        var markerText1 = String()
        var markerClub1 = String()
        
        suggestedMarkerOffCourse.map = nil
        suggestedMarkerOffCourse.isTappable = false
        
        let dict2:[NSAttributedStringKey:Any] = [NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 15)!,]
        
        if(!holeOutFlag){
            if(BackgroundMapStats.findPositionOfPointInside(position: position.first!, whichFeature:courseData.numberOfHoles[self.holeIndex].green)){
                let distance = GMSGeometryDistance(position.first!, position[1]) * Constants.YARD * 3
                markerText = "  \(Int(distance)) ft "
                if(Constants.distanceFilter == 1){
                    let distance = GMSGeometryDistance(position.first!, position.last!)
                    markerText = "  \(Int(distance)) m "
                }
                markerClub = clubReco(dist: distance, lie: "G")
                if (distance/3 < 100) {
                    self.btnSelectClubs.setTitle(BackgroundMapStats.getClubName(club: markerClub.trim()).uppercased(), for: .normal)
                    let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub.trim())!, section: 0)
                    self.btnSelectClubs.tag = indexPath.row
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    
                    let lie = callFindPositionInsideFeature(position: position[1])
                    let fullName = BackgroundMapStats.returnLandedOnFullName(data: lie)
                    btnForSuggMarkOffCourse.lblTitle.text = fullName.0
                    suggestedMarkerOffCourse.iconView = btnForSuggMarkOffCourse
                    suggestedMarkerOffCourse.position = GMSGeometryOffset(position.first!, distance/(2*Constants.YARD*3), GMSGeometryHeading(position[0], position[1]))
                    suggestedMarkerOffCourse.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarkerOffCourse.map = self.mapView
                    btnForSuggMarkOffCourse.lblSubtitle.attributedText = NSAttributedString(string: markerText, attributes: dict2)
                }
            }else{
                let distance = GMSGeometryDistance(position.first!, position.last!) * Constants.YARD
                if(distance > 100){
                    let dist1 = GMSGeometryDistance(position.first!, position[1]) * Constants.YARD
                    markerText1 = "  \(Int(dist1)) yd "
                    if(Constants.distanceFilter == 1){
                        markerText1 = "  \(Int(dist1/(Constants.YARD))) m "
                    }
                    let lie = callFindPositionInsideFeature(position: position[1])
                    if(self.shotCount != 0){
                        markerClub1 = clubReco(dist: dist1, lie: "O")
                    }else{
                        markerClub1 = clubReco(dist: dist1, lie: "T")
                    }
                    let markerClubText = BackgroundMapStats.getClubName(club: markerClub1.trim())
                    self.btnSelectClubs.setTitle(markerClubText.uppercased(), for: .normal)
                    let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub1.trim())!, section: 0)
                    self.btnSelectClubs.tag = indexPath.row
                    if let cell = self.selectClubDropper.TableMenu.cellForRow(at: indexPath) as? DropperCell{
                        cell.textLabel?.isHidden = false
                        cell.textLabel?.backgroundColor = UIColor.glfBlack40
                    }
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    btnForSuggMarkOffCourse.lblSubtitle.attributedText = NSAttributedString(string: markerText1, attributes: dict2)
                    let fullName = BackgroundMapStats.returnLandedOnFullName(data: lie)
                    btnForSuggMarkOffCourse.lblTitle.text = fullName.0
                    suggestedMarkerOffCourse.iconView = btnForSuggMarkOffCourse
                    suggestedMarkerOffCourse.position = GMSGeometryOffset(position.first!, dist1/(2*Constants.YARD), GMSGeometryHeading(position.first!, position[1]))
                    suggestedMarkerOffCourse.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarkerOffCourse.map = self.mapView
                }else{
                    let distance = GMSGeometryDistance(position[0], position[1]) * Constants.YARD
                    markerText = " \(Int(distance.rounded())) yd"
                    if(Constants.distanceFilter == 1){
                        markerText = " \(Int((distance/Constants.YARD).rounded())) m"
                    }
                    if(self.shotCount != 0){
                        markerClub = " \(clubReco(dist: distance, lie: "O"))"
                    }else{
                        markerClub = clubReco(dist: distance, lie: "T")
                    }
                    let lie = callFindPositionInsideFeature(position: position[1])
                    let markerClubText = BackgroundMapStats.getClubName(club: markerClub.trim())
                    self.btnSelectClubs.setTitle(markerClubText.uppercased(), for: .normal)
                    let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub.trim())!, section: 0)
                    self.btnSelectClubs.tag = indexPath.row
                    if let cell = self.selectClubDropper.TableMenu.cellForRow(at: indexPath) as? DropperCell{
                        cell.textLabel?.isHidden = false
                        cell.textLabel?.backgroundColor = UIColor.glfBlack40
                    }
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    btnForSuggMarkOffCourse.lblSubtitle.attributedText = NSAttributedString(string: markerText, attributes: dict2)
                    let fullName = BackgroundMapStats.returnLandedOnFullName(data: lie)
                    btnForSuggMarkOffCourse.lblTitle.text = fullName.0
                    suggestedMarkerOffCourse.iconView = btnForSuggMarkOffCourse
                    suggestedMarkerOffCourse.position = GMSGeometryOffset(position[0], distance/(2*Constants.YARD), GMSGeometryHeading(position[0], position[1]))
                    suggestedMarkerOffCourse.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarkerOffCourse.map = self.mapView
                }
            }
        }
    }
    func backTouched(){
        if self.selectClubDropper.status != .hidden {
            self.selectClubDropper.hideWithAnimation(0.3)
        }
    }
    func callFindPositionInsideFeature(position:CLLocationCoordinate2D)->String{
        var featureName = "R"
        for data in courseData.numberOfHoles[self.holeIndex].fairway{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "F"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].gb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "GB"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].fb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "FB"
                break
            }
        }
        for data in self.allWaterHazard{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "WH"
                break
            }
        }
        for data in courseData.numberOfHoles[holeIndex].tee{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "T"
                break
            }
        }
        if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature:courseData.numberOfHoles[holeIndex].green)){
            featureName = "G"
        }
        return featureName
    }
    func  clubReco(dist:Double,lie:String)->String {
        if (lie.trim() == "G"){
            return " Pu";
        }else {
            var index = 0
            var i2 = 0
            var minX = 1000000.0
            var preferredClubs = [String]()
            for i in 0..<courseData.clubData.count {
                if (!courseData.clubs.contains(courseData.clubData[i].name)){ continue}
                if (courseData.clubData[i].name == "Pu"){continue}
                if (courseData.clubData[i].name == "Dr") &&
                    (lie != "T"){continue}
                let max = Double(courseData.clubData[i].max)
                let min = Double(courseData.clubData[i].min)
                var x = 0.0
                if (dist >= max) {
                    x = dist - max;
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                } else if (dist <= min) {
                    x = min - dist;
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                } else if (dist >= min && dist <= max) {
                    preferredClubs.append(" \(courseData.clubData[i].name)")
                }
                if (x < minX) {
                    index = i2;
                    minX = x;
                }
                i2 = i2+1
            }
            return preferredClubs[index]
        }
    }
    func updateWindSpeed(latLng:CLLocationCoordinate2D,indexToUpdate:Int){
        let lat = latLng.latitude
        let lng = latLng.longitude
        BackgroundMapStats.getDataFromJson(lattitude: lat , longitude: lng, onCompletion: { response,arg  in
            DispatchQueue.main.async(execute: {
                let headingOfHole = GMSGeometryHeading(self.courseData.centerPointOfTeeNGreen[indexToUpdate].tee,self.courseData.centerPointOfTeeNGreen[indexToUpdate].green)
                for data in response!{
                    if data.key == "wind"{
                        let windSpeed = (data.value as AnyObject).value(forKey: "speed") as! Double
                        let windSpeedWithUnit = windSpeed * 2.23694
                        self.lblWindSpeed.text = " \(windSpeedWithUnit.rounded(toPlaces: 1)) mph"
                        self.lblWindSpeedForeground.text = " \(windSpeedWithUnit.rounded(toPlaces: 1)) mph"
                        if(Constants.distanceFilter == 1){
                            self.lblWindSpeed.text = " \((windSpeedWithUnit*1.60934).rounded(toPlaces: 1)) km/h"
                            self.lblWindSpeedForeground.text = " \((windSpeedWithUnit*1.60934).rounded(toPlaces: 1)) km/h"
                        }
                        if let degree = (data.value as AnyObject).value(forKey: "deg") as? Double{
                            self.windHeading = degree + 90
                        }
                        let rotationAngle = headingOfHole - self.windHeading
                        debugPrint()
                        UIButton.animate(withDuration: 2.0, animations: {
                            self.imgViewWind.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                            self.imgViewWindForeground.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                        })
                        break
                    }
                }
                } as @convention(block) () -> Void)
        })
    }
    
    func showHideViews(isHide:Bool){
        self.btnPlayersStats.isHidden = isHide
        self.imgViewWind.isHidden = isHide
        self.lblWindSpeed.isHidden = isHide
        self.btnCenter.isHidden = isHide
        self.btnClubs.isHidden = isHide
        self.btnSelectClubs.isHidden = isHide
        self.lblShotNumber.isHidden = isHide
        self.lblEditShotNumber.isHidden = isHide
        self.btnTrackShot.isHidden = isHide
        self.btnMoveToMapGround.isHidden = !isHide
        self.viewForground.isHidden = !isHide
    }
    func calculateTotalExtraShots(playerID:String)->Double{
        var index = 0
        for playersdata in self.playersButton{
            if (playersdata.isSelected){
                break
            }
            index += 1
        }
        var slopeIndex = 0
        for data in Constants.teeArr{
            if(data.type.lowercased() == self.teeTypeArr[index].tee.lowercased()) && (data.name.lowercased() == self.teeTypeArr[index].color.lowercased()){
                break
            }
            slopeIndex += 1
        }
        let data = (self.teeTypeArr[index].handicap * Double(Constants.teeArr[slopeIndex].slope)!)
        return (Double(data / 113)).rounded()
    }
    @objc func loadMap(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        if(!self.isHoleByHole){
            self.currentMatchId = Constants.matchId
        }
        statusStableFord()
        let playerData = NSMutableArray()
        for clu in courseData.clubs{
            self.clubsWithFullName.append(BackgroundMapStats.getClubName(club: clu))
        }
        selectClubDropper = Dropper(width: 150, height: 300)
        selectClubDropper.items = clubsWithFullName
        self.btnActionClubSelection(btnSelectClubs)
        self.codeWhenClickToBackView()
        for i in 0..<courseData.numberOfHoles.count{
            for wh in courseData.numberOfHoles[i].wh{
                allWaterHazard.append(wh)
            }
        }
        self.teeTypeArr.removeAll()
        if let players = self.matchDataDict.value(forKey: "player") as? NSMutableDictionary{
            for data in players{
                let v = data.value as! NSMutableDictionary
                var teeOfP = String()
                var teeColorOfP = String()
                var handicapOfP = Double()
                if let tee = v.value(forKeyPath: "tee") as? String{
                    teeOfP = tee
                }
                if let teeColor = v.value(forKeyPath: "teeColor") as? String{
                    teeColorOfP = teeColor
                }
                if let hcp = v.value(forKeyPath: "handicap") as? String{
                    handicapOfP = Double(hcp)!
                }
                if(teeOfP != ""){
                    self.teeTypeArr.append((tee: teeOfP,color:teeColorOfP, handicap: handicapOfP))
                }

            }
        }
        if(!self.teeTypeArr.isEmpty){
            self.topHoleParView.isHidden = true
            self.topHoleParHCPView.isHidden = false
            self.lblHCPHeader.isHidden = false
        }
        if(!isContinue) && (!isAcceptInvite){
            if(self.matchDataDict.object(forKey: "player") != nil){
                let tempArray = self.matchDataDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    playerData.add(dict)
                }
            }
            if(!isHoleByHole){
                self.initilizeScoreNode(playerData:playerData)
            }else{
                setupMultiplayersButton()
            }
        }
        else{
            setupMultiplayersButton()
        }
        
    }
    private func getHCPValue(playerID:String,holeNo:Int)->Int{
        var index = 0
        var hcp = 0
        for playersdata in self.playersButton{
            if (playersdata.id == playerID){
                break
            }
            index += 1
        }
        for tee in self.courseData.holeHcpWithTee{
            if tee.hole == holeNo{
                for data in tee.teeBox {
                    if (data.value(forKey: "teeType") as! String) == (self.teeTypeArr[index].tee).lowercased() && (data.value(forKey: "teeColorType") as! String) == (self.teeTypeArr[index].color).lowercased(){
                        hcp = data.value(forKey:"hcp") as? Int ?? 0
                        break
                    }
                }
                break
            }
        }
        return hcp
    }
    func plotMarker(position:CLLocationCoordinate2D, userData:Int){
        let marker = GMSMarker(position: position)
        marker.title = "Point"
        marker.userData = userData
        marker.icon = #imageLiteral(resourceName: "target")
        if(userData == 0){
            marker.icon = #imageLiteral(resourceName: "fixed_point")
            if(shotCount == 0){
                marker.icon = #imageLiteral(resourceName: "Tee")
            }
        }
        if(!isTracking){
            if(isUserInsideBound) && userData == 0{
                let btnUserSmall = UIButton()
                btnUserSmall.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                btnUserSmall.setCircle(frame: btnUserSmall.frame)
                btnUserSmall.isUserInteractionEnabled = false
                if let img = (Auth.auth().currentUser?.photoURL){
                    btnUserSmall.sd_setImage(with: img, for: .normal, placeholderImage: #imageLiteral(resourceName: "you"),completed: nil)
                }
                else{
                    btnUserSmall.backgroundColor = UIColor.glfWhite
                    let name = Auth.auth().currentUser?.displayName
                    btnUserSmall.setTitle("\(name?.first ?? " ")", for: .normal)
                    btnUserSmall.setTitleColor(UIColor.glfBlack, for: .normal)
                    btnUserSmall.setImage(nil, for: .normal)
                }
                marker.iconView = btnUserSmall
            }
        }
        
        marker.map = mapView
        if(marker.userData as! Int == 44) || (isBotTurn){
            marker.isDraggable = false
        }else{
            marker.isDraggable = false
        }
        if(userData == 2){
            marker.isDraggable = true
        }
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        markers.append(marker)
    }
    func plotSuggestedMarkers(position:[CLLocationCoordinate2D]){
        var markerText = String()
        var markerClub = String()
        var markerText1 = String()
        var markerClub1 = String()
        
        suggestedMarker1.map = nil
        suggestedMarker2.map = nil
        suggestedMarker1.isTappable = false
        suggestedMarker2.isTappable = false
        
        let dict1: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 15)!,
            NSAttributedStringKey.foregroundColor : UIColor.white]
        let dict2:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 15)!,
            NSAttributedStringKey.foregroundColor : UIColor.white]
        if(!holeOutFlag){
            if(BackgroundMapStats.findPositionOfPointInside(position: position.first!, whichFeature:courseData.numberOfHoles[self.holeIndex].green)){
                let distance = GMSGeometryDistance(position.first!, position.last!) * Constants.YARD * 3
                markerText = "  \(Int(distance)) ft "
                if(Constants.distanceFilter == 1){
                    let distance = GMSGeometryDistance(position.first!, position.last!)
                    markerText = "  \(Int(distance)) m "
                }
                markerClub = "Pu"
                if (distance/3 < 100) {
                    if(!isFromPlotLine) || (isDraggingMarker){
                        self.btnSelectClubs.setTitle(BackgroundMapStats.getClubName(club: markerClub.trim()).uppercased(), for: .normal)
                        let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub.trim())!, section: 0)
                        self.btnSelectClubs.tag = indexPath.row
                        self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    }
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText, for: .normal)
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position[0], distance/(6*Constants.YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = self.mapView
                    suggestedMarker2.map = nil
                }
            }else{
                let distance = GMSGeometryDistance(position.first!, position.last!) * Constants.YARD
                if(distance > 100){
                    let dist1 = GMSGeometryDistance(position.first!, position[1]) * Constants.YARD
                    let dist = GMSGeometryDistance(position[1], position.last!) * Constants.YARD
                    
                    markerText1 = "  \(Int(dist1)) yd "
                    markerText = "  \(Int(dist)) yd "
                    if(Constants.distanceFilter == 1){
                        markerText = "  \(Int(dist/(Constants.YARD))) m "
                        markerText1 = "  \(Int(dist1/(Constants.YARD))) m "
                    }
                    let lie = callFindPositionInsideFeature(position: position[1])
                    if(self.shotCount != 0){
                        markerClub1 = clubReco(dist: dist1, lie: "O")
                        markerClub = clubReco(dist: dist, lie: lie)
                    }else{
                        markerClub1 = clubReco(dist: dist1, lie: "T")
                        markerClub = clubReco(dist: dist, lie: lie)
                    }
                    if(dist1 > 250){
                        markerClub1 = " - "
                    }
                    if(dist > 250){
                        markerClub = " - "
                    }
                    if(markerClub1 != " - "){
                        if(!isFromPlotLine) || (isDraggingMarker){
                            self.btnSelectClubs.setTitle(BackgroundMapStats.getClubName(club: markerClub1.trim()).uppercased(), for: .normal)
                            let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub1.trim())!, section: 0)
                            self.btnSelectClubs.tag = indexPath.row
                            self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                        }
                    }
                    
                    let attributedText1 = NSMutableAttributedString()
                    attributedText1.append(NSAttributedString(string: markerClub1, attributes: dict1))
                    attributedText1.append(NSAttributedString(string: markerText1, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText1, for: .normal)
                    //                    debugPrint("str2: \(attributedText1.string)")
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position.first!, dist1/(2*Constants.YARD), GMSGeometryHeading(position.first!, position[1]))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = !isTracking ? self.mapView : nil
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark2.setAttributedTitle(attributedText, for: .normal)
                    
                    //                    debugPrint("str1: \(attributedText.string)")
                    suggestedMarker2.iconView = btnForSuggMark2
                    suggestedMarker2.position = GMSGeometryOffset(position[1], dist/(2*Constants.YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker2.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker2.map = !isTracking ? self.mapView : nil
                }else{
                    let distance = GMSGeometryDistance(position[0], position.last!) * Constants.YARD
                    markerText = " \(Int(distance.rounded())) yd"
                    if(Constants.distanceFilter == 1){
                        markerText = " \(Int((distance/Constants.YARD).rounded())) m"
                    }
                    if(self.shotCount != 0){
                        markerClub = " \(clubReco(dist: distance, lie: "O"))"
                    }else{
                        markerClub = clubReco(dist: distance, lie: "T")
                    }
                    if(!isFromPlotLine) || isDraggingMarker {
                        self.btnSelectClubs.setTitle(BackgroundMapStats.getClubName(club: markerClub.trim()).uppercased(), for: .normal)
                        let indexPath = IndexPath(row: courseData.clubs.index(of: markerClub.trim())!, section: 0)
                        self.btnSelectClubs.tag = indexPath.row
                        self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    }
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText, for: .normal)
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position[0], distance/(2*Constants.YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = !isTracking ? self.mapView : nil
                    suggestedMarker2.map = nil
                }
            }
        }
    }
    var isFromPlotLine = false
    func plotLine(positions:[CLLocationCoordinate2D]){
        if(!positions.isEmpty){
            let path = GMSMutablePath()
            if(self.isOnCourse){
                for i in 0..<positions.count{
                    path.add(positions[i])
                }
            }else{
                for i in 0..<positions.count-1{
                    path.add(positions[i])
                }
            }
            let distance = GMSGeometryDistance(positions.first!, positions.last!) * Constants.YARD
            markers[1].map = self.mapView
            if(distance < 100) && (isOnCourse){
                if(positions.count == 3){
                    path.removeCoordinate(at: 1)
                    markers[1].map = nil
                    suggestedMarker2.map = nil
                }
                
            }
            line.map = nil
            line = GMSPolyline(path: path)
            let lengths:[NSNumber] = [2,2]
            let styles = [GMSStrokeStyle.solidColor(UIColor.glfWhite), GMSStrokeStyle.solidColor(UIColor.clear)]
            line.spans = GMSStyleSpans(line.path!, styles, lengths, GMSLengthKind(rawValue: 1)!)
            line.strokeWidth = 2.0
            line.geodesic = true
            line.map = mapView
            if(isOnCourse){
                isFromPlotLine = true
                self.plotSuggestedMarkers(position: positions)
                isFromPlotLine = false
                if(markers[1].map == nil){
                    self.suggestedMarker2.map = nil
                }
            }else{
                if(btnClose.isHidden){
                    self.plotSuggestedMarkersOffCourse(position: positions)
                }
            }
        }
    }
    
    func getBotPlayersDataFromFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "botPlayers/dJohnson") { (snapshot) in
            let botDataDict = snapshot.value as! [String:Any]
            DispatchQueue.main.async(execute: {
                for (key,value) in botDataDict{
                    if(key == "gir3"){
                        print("Gir3:\(value)")
                        self.gir3Perc = value as! Double
                    }
                    else if (key.contains("pF")){
                        var newKey = key
                        newKey.removeFirst()
                        newKey.removeFirst()
                        self.distanceFairway.setValuesForKeys([newKey : value as! Double])
                    }
                    else if (key.contains("pR")){
                        var newKey = key
                        newKey.removeFirst()
                        newKey.removeFirst()
                        self.distanceRough.setValuesForKeys([newKey : value as! Double])
                    }
                    else if (key.contains("maxDrive")){
                        self.maxDrive = value as! Double
                    }
                    else if (key.contains("avgDrive")){
                        self.avgDrive = value as! Double
                    }
                        
                    else if (key.contains("girWithFairway")){
                        self.girWithFairway = value as! Double
                    }
                    else if (key.contains("girWithoutFairway")){
                        self.girWithoutFairway = value as! Double
                    }
                    else if (key.contains("fairwayHit")){
                        self.fairwayHitPerc = value as! Double
                    }
                    else if (key.contains("fairwayLeft")){
                        self.fairwayLeftPerc = value as! Double
                    }
                    else if (key.contains("fairwayRight")){
                        self.fairwayRightPerc = value as! Double
                    }
                }
            })
        }
    }
    
    // Update Map - removing all markers and features from map and reload map with new Features and details.         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "response9"), object: false)

    func updateMap(indexToUpdate:Int){
        self.calculateSwingDataForCurrentHole()
        var indexToUpdate = indexToUpdate
        if courseData.centerPointOfTeeNGreen.count-1 < indexToUpdate{
            let c = courseData.centerPointOfTeeNGreen.count
            indexToUpdate = indexToUpdate%c
        }


        mapView.clear()
        self.stableFordView.isHidden = true
        self.allMarkers.removeAll()
        self.suggestedMarkerOffCourse.map = nil
        self.suggestedMarker1.map = nil
        self.suggestedMarker2.map = nil
        self.isUpdating = false
        self.isPintMarker = false
        self.btnShareShot.isHidden = true
        self.btnHoleOut.isHidden = true
        self.btnHoleoutLbl.isHidden = true
        self.multiplayerPageControl.isHidden = true
        self.lblRaceToFlagTitle.isHidden = true
        self.barChartParentStackView.isHidden = true
        self.btnAddPenaltyLbl.isHidden = true
        self.btnPenaltyShot.isHidden = true
        self.isTracking = false
        for coord in courseData.numberOfHoles[holeIndex].green{
            self.pathOfGreen.add(coord)
        }
        self.mapTimer.invalidate()
        if(!isOnCourse){
            self.btnTrackShot.backgroundColor = UIColor.glfGreenBlue
        }
        markers.removeAll()
        markersForCurved.removeAll()
        shotCount = 0
        if(self.btnMultiplayer.currentImage == #imageLiteral(resourceName: "cross")){
            self.btnMultiplayer.tag = 0
            for btn in playersButton where btn.isSelected{
                self.btnMultiplayer.setImage(btn.button.currentImage, for: .normal)
            }
            showMultiplayer(hide: true)
        }
        self.lblShotNumber.text =  "  Shot \(shotCount+1)  "
        self.positionsOfDotLine.removeAll()
        self.positionsOfCurveLines.removeAll()
        holeOutFlag = false
        self.shotsDetails.removeAll()
        for subview in stackViewForGreenShots.subviews {
            subview.removeFromSuperview()
        }
        greenStackViewHeight.constant = 0
        btnTotalShotsNumber.layer.borderWidth = 0
        if let layers = btnTotalShotsNumber.layer.sublayers{
            for lay in layers{
                lay.borderWidth = 0
            }
        }
        
        self.penaltyShots.removeAll()
        indexToUpdate = indexToUpdate == -1 ? indexToUpdate+1 : indexToUpdate
        self.lblHoleNumber.text = "\(self.scoring[indexToUpdate].hole)"
        self.lblHoleNumber2.text = "Hole".localized() + " \(self.scoring[indexToUpdate].hole)"
        self.lblParNumber.text = "Par".localized() + " \(self.scoring[indexToUpdate].par)"
        self.lblParNumber2.text = "Par".localized() + " \(self.scoring[indexToUpdate].par)"
        self.lblTopPar.text = "PAR  \(self.scoring[indexToUpdate].par)"
        
        if(!self.teeTypeArr.isEmpty){
            self.lblTopHCP.text = "HCP \(self.getHCPValue(playerID: self.selectedUserId, holeNo: self.scoring[indexToUpdate].hole))"
            self.lblHCPHeader.text = "HCP \(self.getHCPValue(playerID: self.selectedUserId, holeNo: self.scoring[indexToUpdate].hole))"
        }
        self.btnHole.setTitle("Hole".localized() + " \(self.scoring[indexToUpdate].hole)", for: .normal)

        self.shotViseCurve.removeAll()
        self.positionsOfDotLine.append(courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
        if(self.scoring[indexToUpdate].par == 3){
            let heading =  GMSGeometryHeading(courseData.centerPointOfTeeNGreen[indexToUpdate].green, courseData.centerPointOfTeeNGreen[indexToUpdate].tee)
            let fPoint = GMSGeometryOffset(courseData.centerPointOfTeeNGreen[indexToUpdate].green, 10, heading)
            self.positionsOfDotLine.append(fPoint)
        }else{
            let dist = GMSGeometryDistance(self.positionsOfDotLine[0], courseData.centerPointOfTeeNGreen[indexToUpdate].green)*Constants.YARD
            self.positionsOfDotLine.append(courseData.centerPointOfTeeNGreen[indexToUpdate].fairway)
            if(dist > 250){
                self.positionsOfDotLine[1] = GMSGeometryOffset(self.positionsOfDotLine[0], 220, GMSGeometryHeading(self.positionsOfDotLine[0], courseData.centerPointOfTeeNGreen[indexToUpdate].green))
            }
            var areaOfFairway = 0.0
            var indexForFairway = 0
            for f in 0..<courseData.numberOfHoles[indexToUpdate].fairway.count{
                let path = GMSMutablePath()
                for position in courseData.numberOfHoles[indexToUpdate].fairway[f]{
                    path.add(position)
                }
                if areaOfFairway < GMSGeometryArea(path){
                    areaOfFairway = GMSGeometryArea(path)
                    indexForFairway = f
                }
            }
            let pathOfFairway = GMSMutablePath()
            for fairwayCoord in courseData.numberOfHoles[indexToUpdate].fairway[indexForFairway]{
                pathOfFairway.add(fairwayCoord)
            }
            self.positionsOfDotLine[1] = BackgroundMapStats.coordInsideFairway(newPoint: self.positionsOfDotLine[1], array: courseData.numberOfHoles[indexToUpdate].fairway[indexForFairway], path: pathOfFairway)
        }
        if(self.userLocationForClub != nil) && (self.selectedUserId == Auth.auth().currentUser!.uid) && isOnCourse{
            self.positionsOfDotLine[0] = self.userLocationForClub!
            let dist = GMSGeometryDistance(self.positionsOfDotLine[0], courseData.centerPointOfTeeNGreen[indexToUpdate].green)*Constants.YARD
            if(dist > 250){
                self.positionsOfDotLine[1] = GMSGeometryOffset(self.positionsOfDotLine[0], 250, GMSGeometryHeading(self.positionsOfDotLine[0], courseData.centerPointOfTeeNGreen[indexToUpdate].green))
            }
        }
        self.positionsOfDotLine.append(courseData.centerPointOfTeeNGreen[indexToUpdate].green)
        let zoomLevel = BackgroundMapStats.getTheZoomLevel(positionsOfDotLine:self.positionsOfDotLine)
        self.mapView.setMinZoom(zoomLevel.1-1, maxZoom: 22.0)
        //        self.updateWindSpeed(latLng: positionsOfDotLine[1], indexToUpdate: indexToUpdate)
        if(self.btnStylizedMapView.tag == 1){
            self.mapView.animate(toLocation: positionsOfDotLine[1])
        }
        var clubInTrack : String!
        self.pathOfGreen.removeAllCoordinates()
        for coord in courseData.numberOfHoles[holeIndex].green{
            self.pathOfGreen.add(coord)
        }
        if(!scoring[indexToUpdate].players.isEmpty){
            for playerScore in scoring[indexToUpdate].players{
                for (key,value) in playerScore{
                    for activePlay in playersButton{
                        if(activePlay.isSelected && activePlay.id == key as! String){
                            let shots = value as! NSDictionary
                            var shotsArray = NSArray()
//                            var isSwing = false
                            for(key,value)in shots{
                                if(key as! String == "shots"){
                                    shotsArray = value as! NSArray
                                }else if(key as! String == "holeOut"){
                                    holeOutFlag = value as! Bool
                                    self.stableFordView.isHidden = !holeOutFlag || chkStableford
                                    self.imgViewStableFordInfo.isHidden = !self.teeTypeArr.isEmpty
                                    self.lblStblScore.text = "n/a"
                                    self.imgViewRefreshScore.isHidden = self.teeTypeArr.isEmpty
                                    
                                }else if(key as! String == "gir"){
                                    gir = value as! Bool
                                }else if(key as! String == "stableFordPoints"){
                                    self.lblStblScore.text = "\(value)"
                                    self.btnStableScore.setTitle("Stableford Score", for: .normal)
                                }else if(key as! String == "shotTracking"){
                                    if let newDict = value as? NSMutableDictionary{
                                        clubInTrack = newDict.value(forKey: "club") as? String
                                        self.positionsOfDotLine[0].latitude = newDict.value(forKey: "lat1") as! CLLocationDegrees
                                        self.positionsOfDotLine[0].longitude = newDict.value(forKey: "lng1") as! CLLocationDegrees
                                        self.isPintMarker = newDict.value(forKey: "hole") as! Bool
                                        self.isTracking = true
                                        self.btnNext.isHidden = isPintMarker
                                        self.btnPrev.isHidden = isPintMarker
                                        self.btnPenaltyShot.isHidden = isPintMarker
                                        self.btnAddPenaltyLbl.isHidden = isPintMarker
                                    }
                                }
                            }
                            if (self.swingMatchId.count != 0){
                                for i in 0..<shotsArray.count {
                                    let shotLatLng = shotsArray[i] as! NSDictionary
                                    playerShotsArray.append(shotLatLng as! NSMutableDictionary)
                                    self.penaltyShots.append(shotLatLng.value(forKey: "penalty") as! Bool)
                                    positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
                                    self.isTracking = true
                                    if(holeOutFlag) && i == shotsArray.count-1{
                                        if(shotLatLng.value(forKey: "lat2") != nil){
                                              self.isTracking = false
                                            positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat2") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng2") as! CLLocationDegrees))
                                        }else{
                                            self.isTracking = false
                                            positionsOfCurveLines.append(self.positionsOfDotLine.last!)
                                        }
                                    }
                                }
                            }else{
                                for i in 0..<shotsArray.count {
                                    let shotLatLng = shotsArray[i] as! NSDictionary
                                    playerShotsArray.append(shotLatLng as! NSMutableDictionary)
                                    self.penaltyShots.append(shotLatLng.value(forKey: "penalty") as! Bool)
                                    if (i == shotsArray.count-1){
                                        positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
                                        positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat2") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng2") as! CLLocationDegrees))
                                    }else{
                                        positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(isTracking){
                if !self.swingMatchId.isEmpty && self.positionsOfCurveLines.count == 1{
                    
                }else{
                    self.positionsOfCurveLines.append(self.positionsOfDotLine[0])
                }
            }
            if(positionsOfCurveLines.count != 0){
                self.shotsDetails = getShotDataOrdered(indexToUpdate: holeIndex,playerId:selectedUserId)
                shotCount = 0
                if(shotsDetails.count != 0) && isTracking{
                    positionsOfCurveLines.removeLast()
                }
                if(self.positionsOfCurveLines.count > 1){
                    positionsOfCurveLines = BackgroundMapStats.removeRepetedElement(curvedArray: positionsOfCurveLines)
                }
                for i in 0..<positionsOfCurveLines.count-1{
                    plotCurvedPolyline(latLng1: positionsOfCurveLines[i], latLng2: positionsOfCurveLines[i+1], whichLine: false, club: shotsDetails[i].club)
                    self.plotMarkerForCurvedLine(position: positionsOfCurveLines[i], userData: i)
                    curvedLines.userData = i
                    shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo,swingPosition:swingMarker))
                    shotCount = shotCount + 1
                }
                if(!holeOutFlag){
                    
                    positionsOfDotLine[0] = positionsOfCurveLines.last!
                    let dist = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!) * Constants.YARD
                    let heading = GMSGeometryHeading(positionsOfDotLine.first!, positionsOfDotLine.last!)
                    var midPoint = GMSGeometryOffset(positionsOfDotLine.first!, GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)*0.7, heading)
                    if(dist<201 && Int(dist) > 0){
                        for i in 1..<Int(dist){
                            if(BackgroundMapStats.findPositionOfPointInside(position: midPoint, whichFeature: courseData.numberOfHoles[holeIndex].green)){
                                break
                            }else{
                                midPoint = GMSGeometryOffset(midPoint, Double(i), heading)
                            }
                        }
                    }
                    
                    positionsOfDotLine[1] = midPoint
                    for i in 0..<positionsOfDotLine.count{
                        self.plotMarker(position: positionsOfDotLine[i], userData: i)
                    }
                    self.markers.last!.icon = #imageLiteral(resourceName: "holeflag")
                    self.markers.last!.groundAnchor = CGPoint(x:0,y:1)
                    plotLine(positions: positionsOfDotLine)
                    self.lblShotNumber.isHidden = false
                    self.lblShotNumber.text =  "  Shot \(shotCount+1)  "
                    self.lblEditShotNumber.isHidden = true
                    if(!isOnCourse){
                        self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
                    }
                    if(GMSGeometryDistance(self.positionsOfDotLine[1], self.positionsOfDotLine.last!) * Constants.YARD) < 100{
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                            self.btnHoleOut.isHidden = self.isOnCourse
                            self.btnSelectClubs.isHidden = false
                            self.btnClubs.isHidden = false
                        }, completion: nil)
                    }
                    if(isOnCourse){
                        self.centerSV.isHidden = false
                        self.centerSVWidthConstraints.constant = 80
                        self.view.layoutIfNeeded()
                    }
                    self.allMarkers = markers
                    
                }else{
                    self.plotMarkerForCurvedLine(position: positionsOfCurveLines.last!, userData: shotCount)
                    self.btnClubs.isHidden = true
                    self.btnSelectClubs.isHidden = true
                    markersForCurved.last!.icon = #imageLiteral(resourceName: "holeflag")
                    markersForCurved.last!.groundAnchor = CGPoint(x:0,y:1)
                    self.positionsOfDotLine.removeAll()
                    self.lblShotNumber.isHidden = true
                    lblEditShotNumber.text = "\(shotCount)"
                    lblEditShotNumber.isHidden = false
                    self.btnTrackShot.setImage(#imageLiteral(resourceName: "edit_White"), for: .normal)
                    self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
                    self.btnTrackShot.tag = shotCount
                    self.tappedMarker = shotViseCurve.last!.markerPosition
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                        self.btnShareShot.isHidden = false
                        self.btnRestartLbl.isHidden = true
                        self.btnRestartShot.isHidden = true
                    }, completion: nil)
                    if(isOnCourse){
                        self.centerSV.isHidden = true
                        self.centerSVWidthConstraints.constant = 0
                        self.view.layoutIfNeeded()
                    }
                    self.allMarkers = markers
                    
                }
                for i in 0..<penaltyShots.count{
                    if(penaltyShots[i]){
                        markersForCurved[i].icon = #imageLiteral(resourceName: "penalty_shot")
                    }
                }
                for i in 0..<shotViseCurve.count{
                    removeLinesAndMarkers(index: i)
                    if(!penaltyShots[i]){
                        showLinesAndMarker(index: i)
                    }else{
                        shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                    }
                }
                self.noDataLabel.removeFromSuperview()
                self.scoreTableView.isHidden = false
                if(self.playersButton.count > 1){
                    updateRaceToFlag()
                }
                self.btnPlayersStats.isHidden = !self.viewHoleStats.isHidden
            }else{
                if(self.playersButton.count > 1){
                    for play in playersButton{
                        if (play.isSelected){
                            if !self.viewHoleStats.isHidden{
                                self.btnActionPlayerStats(Any.self)
                                self.playersAction(sender: multiplayerButtons[play.button.tag])
                            }
                            break
                        }
                    }
                }else{
                    if !self.viewHoleStats.isHidden{
                        self.btnActionPlayerStats(Any.self)
                    }
                }
                self.btnClubs.isHidden = false
                self.btnSelectClubs.isHidden = false
                self.lblShotNumber.text =  "  Shot \(shotCount+1)  "
                self.lblEditShotNumber.isHidden = true
                self.lblShotNumber.isHidden = false
                if(!isOnCourse){
                    self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
                }
                for i in 0..<positionsOfDotLine.count{
                    self.plotMarker(position: positionsOfDotLine[i], userData: i)
                }
                self.markers.last!.icon = #imageLiteral(resourceName: "holeflag")
                self.markers.last!.groundAnchor = CGPoint(x:0,y:1)
                plotLine(positions: positionsOfDotLine)
                if(isOnCourse){
                    self.centerSV.isHidden = false
                    self.centerSVWidthConstraints.constant = 80
                    self.view.layoutIfNeeded()
                }
                self.allMarkers = markers
            }
            self.scoreTableView.reloadData()
            self.constraintTableHeight.constant = tableViewHeight
        }
        
        if(!holeOutFlag){
            if(!self.positionsOfCurveLines.isEmpty){
                self.letsRotateWithZoom(latLng1: positionsOfCurveLines.first!, latLng2: positionsOfDotLine.last!)
            }else{
                self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
            }
            
        }else{
            if positionsOfCurveLines.count != 0{
                self.letsRotateWithZoom(latLng1: positionsOfCurveLines.first!, latLng2: positionsOfCurveLines.last!)
            }else{
                self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
            }
            
        }
        if(isOnCourse) && !holeOutFlag{
            plotSuggestedMarkers(position: positionsOfDotLine)
        }else if(suggestedMarkerOffCourse.map != nil ) && !holeOutFlag{
            plotSuggestedMarkersOffCourse(position: positionsOfDotLine)
        }
        if let onCourse = self.matchDataDict.value(forKeyPath: "onCourse") as? Bool{
            if(onCourse) && !holeOutFlag && !isHoleByHole{
                if(clubInTrack != nil){
                    self.btnSelectClubs.setTitle(BackgroundMapStats.getClubName(club: clubInTrack.trim()).uppercased(), for: .normal)
                    let indexPath = IndexPath(row: courseData.clubs.index(of: clubInTrack.trim())!, section: 0)
                    self.btnSelectClubs.tag = indexPath.row
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                }
                locationManager.startUpdatingLocation()
                if let currentLocation: CLLocation = self.locationManager.location{
                self.userLocationForClub = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                }
                self.mapView.isMyLocationEnabled = true
                if(self.positionsOfCurveLines.count > 1){
                    self.plotMarkerForCurvedLine(position: self.positionsOfCurveLines.last!, userData: self.positionsOfCurveLines.count-1)
                }
                if(userLocationForClub != nil) && (self.selectedUserId == Auth.auth().currentUser!.uid){
                    mapTimer = Timer.scheduledTimer(withTimeInterval:self.totalTimer, repeats: true, block: { (timer) in
                        if(self.positionsOfDotLine.count > 2){
                            debugPrint(self.totalTimer)
                            self.locationManager.startUpdatingLocation()
                            if self.locationManager.location == nil{
                                self.view.makeToast("Locating you.... please reload hole.", duration: 1, position: .bottom)
                            }
                            
                            if let currentLocation: CLLocation = self.locationManager.location{
                                self.userLocationForClub = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                                let heading = GMSGeometryHeading(currentLocation.coordinate,self.courseData.centerPointOfTeeNGreen[self.holeIndex].green)
                                let rotationAngle = heading - self.windHeading
                                self.imgViewWind.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle) / 180.0 * CGFloat(Double.pi))

                            }
                            let distance  = GMSGeometryDistance(self.positionsOfDotLine.first!,self.userLocationForClub!)
                            if (distance < 15000.0){
                                self.positionsOfDotLine.remove(at: 0)
                                self.positionsOfDotLine.insert(self.userLocationForClub!, at: 0)
                                self.isUserInsideBound = true
                                for i in 0..<self.markers.count{
                                    self.markers[i].map = nil
                                }
                                self.markers.removeAll()
                                self.allMarkers.removeAll()
                                //                                self.updateMid()
                                if(!self.isTracking){
                                    for i in 0..<self.positionsOfDotLine.count{
                                        self.plotMarker(position: self.positionsOfDotLine[i], userData: i)
                                    }
                                    self.plotLine(positions: self.positionsOfDotLine)
                                }else{
                                    for i in 0..<self.positionsOfDotLine.count{
                                        self.plotMarker(position: self.positionsOfDotLine[i], userData: i)
                                        if(self.positionsOfDotLine.count-1 != i){
                                            self.markers[i].map = nil
                                        }
                                    }
                                    self.letsRotateWithZoom(latLng1: self.positionsOfDotLine.first!, latLng2: self.positionsOfDotLine.last!)
                                    self.btnShareShot.isHidden = true
                                }
                                
                                for i in 0..<self.positionsOfCurveLines.count{
                                    if(i == 0){
                                        for mar in self.markersForCurved{
                                            mar.map = nil
                                        }
                                        self.markersForCurved.removeAll()
                                    }
                                    self.plotMarkerForCurvedLine(position: self.positionsOfCurveLines[i], userData: i)
                                }
                                
                                let data = self.setFronBackCenter(ind: indexToUpdate, currentLocation: self.userLocationForClub!)
                                var distanceF = GMSGeometryDistance(data.front,self.userLocationForClub!) * Constants.YARD
                                var distanceC = GMSGeometryDistance(data.center,self.userLocationForClub!) * Constants.YARD
                                var distanceE = GMSGeometryDistance(data.back,self.userLocationForClub!) * Constants.YARD
                                var suffix = "yd"
                                if(Constants.distanceFilter == 1){
                                    suffix = "m"
                                    distanceF = distanceF/Constants.YARD
                                    distanceC = distanceC/Constants.YARD
                                    distanceE = distanceE/Constants.YARD
                                }
                                self.lblFrontDistance.text = "\(Int(distanceF)) \(suffix)"
                                self.lblDistance.text = "\(Int(distanceC)) \(suffix)"
                                self.lblBackDistance.text = "\(Int(distanceE)) \(suffix)"
                                self.lblCenterHeader.text = "\(Int(distanceC)) \(suffix)"
                                debugPrint( "\(Int(distanceF)) \(Int(distanceC)) \(Int(distanceE)) \(Int(distanceC)) \(suffix)")
                                debugPrint("isTracking\(self.isTracking)")
                                if(self.holeOutFlag){
                                    Notification.sendGameDetailsNotification(msg: "Hole \(self.scoring[indexToUpdate].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDict.value(forKey: "courseName") as! String))", title: "You Played \(self.shotCount) shots.", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                                }else{
                                    if(BackgroundMapStats.findPositionOfPointInside(position: self.userLocationForClub!, whichFeature:self.courseData.numberOfHoles[self.holeIndex].green)){
                                        Notification.sendGameDetailsNotification(msg: "Hole \(self.scoring[indexToUpdate].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDict.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distanceC)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                                    }else{
                                        Notification.sendGameDetailsNotification(msg: "Hole \(self.scoring[indexToUpdate].hole) • Par \(self.scoring[self.holeIndex].par) • \((self.matchDataDict.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distanceC)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                                    }
                                    
                                }
                                if(!self.positionsOfCurveLines.isEmpty) && self.isTracking{
                                    for i in 0..<self.penaltyShots.count{
                                        if (self.penaltyShots[i]){
                                            debugPrint(self.positionsOfCurveLines[i])
                                        }
                                    }
                                    self.plotDashedLine(positions: [self.positionsOfCurveLines.last!,self.positionsOfDotLine[0]])
                                }
                                self.btnHoleOut.isHidden = false
                                self.btnHoleoutLbl.isHidden = false
                                self.btnClubs.isHidden = self.isTracking
                                self.btnSelectClubs.isHidden = self.isTracking
                                if(GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!)) < 50{
                                    if(self.isTracking){
                                        if(self.shotCount == 0){
                                            self.btnHoleOut.isHidden = true
                                            self.btnHoleoutLbl.isHidden = true
                                        }
                                        
                                        self.btnHoleoutLbl.setTitle("  In the hole  ", for: .normal)
                                        self.btnTrackShot.setImage(#imageLiteral(resourceName: "stop"),for: .normal)
                                        self.btnTrackShot.backgroundColor = UIColor.glfWhite
                                        
                                        self.btnHoleoutLbl.isHidden = self.isPintMarker
                                        self.btnHoleOut.isHidden = self.isPintMarker
                                        
                                        self.btnRestartLbl.isHidden = false
                                        self.btnRestartShot.isHidden = false
                                    }else{
                                        self.btnHoleoutLbl.setTitle("  Holeout  ", for: .normal)
                                        self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
                                        self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
                                        self.btnRestartLbl.isHidden = true
                                        self.btnRestartShot.isHidden = true
                                        if(!self.isHoleByHole) && (!self.isContinue) && (!self.isShowcase){
                                            self.isShowcase = true
                                            self.showCaseHoleOutShotsOnCourse()
                                        }
                                    }
                                }else{
                                    self.btnHoleOut.isHidden = true
                                    self.btnHoleoutLbl.isHidden = true
                                    if(self.isTracking){
                                        self.btnTrackShot.setImage(#imageLiteral(resourceName: "stop"),for: .normal)
                                        self.btnTrackShot.backgroundColor = UIColor.glfWhite
                                        self.btnRestartLbl.isHidden = false
                                        self.btnRestartShot.isHidden = false
                                        if(self.btnPenaltyShot.isHidden){
                                            self.btnPenaltyShot.isHidden = false
                                            self.btnAddPenaltyLbl.isHidden = false
                                        }
                                    }else{
                                        self.btnTrackShot.setImage(#imageLiteral(resourceName: "track_Shot"), for: .normal)
                                        self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
                                        self.btnRestartLbl.isHidden = true
                                        self.btnRestartShot.isHidden = true
                                        if(!self.btnPenaltyShot.isHidden){
                                            self.btnPenaltyShot.isHidden = true
                                            self.btnAddPenaltyLbl.isHidden = true
                                        }
                                    }
                                }
                                
                                
                                self.suggestedMarker1.map = !self.isTracking ? self.mapView : nil
                                if(!self.isTracking){
                                    if !(!self.markers.isEmpty && self.markers[1].map == nil){
                                        self.suggestedMarker2.map = self.mapView
                                    }else{
                                        self.suggestedMarker2.map = nil
                                    }
                                }else{
                                    self.suggestedMarker2.map = nil
                                }
                                
                                
                                if(!self.holeOutFlag){
                                    self.markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                                    self.markers.last?.groundAnchor = CGPoint(x:0,y:1)
                                }
                            }else{
                                let alert = UIAlertController(title: "Alert" , message: "You are not inside the Hole Boundary Switching Back to GPS OFF Mode" , preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                self.mapTimer.invalidate()
                                self.isUserInsideBound = false
                            }
                            if !self.swingMatchId.isEmpty{
                                self.hideWhenDeviceConnected()
                            }
                        }
                    })
                }
            }
        }
        
        if(selectedUserId == "jpSgWiruZuOnWybYce55YDYGXP62") && (!holeOutFlag){
            for data in playersButton{
                data.button.isUserInteractionEnabled = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            for data in self.playersButton{
                if data.isSelected && data.id == "jpSgWiruZuOnWybYce55YDYGXP62" && self.positionsOfDotLine.count>2{
                    self.isBotTurn = true
                    self.btnTrackShot.isEnabled = false
                    let distance = GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * Constants.YARD
                    if(self.scoring[self.holeIndex].par == 3){
                        self.botPlayerShotForPar3(gir:0,distance:distance, distanceFairwayOrRough: self.distanceFairway)
                        if(distance > 350){
                            self.botPlayerShotForPar4(girWithF:self.girWithFairway,distance:distance)
                        }
                    }
                    else if(self.scoring[self.holeIndex].par == 4 || self.scoring[self.holeIndex].par == 5){
                        self.botPlayerShotForPar4(girWithF:self.girWithFairway,distance:distance)
                    }
                    
                    break
                }else{
                    self.btnTrackShot.isEnabled = true
                    self.isBotTurn = false
                }
            }
        })
        if(isHoleByHole){
            self.setupHoleByHole()
        }
        debugPrint("Curved Lines",self.positionsOfCurveLines)
        debugPrint("Dotted Lines",self.positionsOfDotLine)
        if(self.btnStylizedMapView.tag == 1){
            self.allPolygonOfOneHole.removeAll()
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.updateMapWithColors()
        }
        if !self.swingMatchId.isEmpty{
            self.hideWhenDeviceConnected()
        }
    }
    func plotDashedLine(positions:[CLLocationCoordinate2D]){
        let path = GMSMutablePath()
        for i in 0..<positions.count{
            path.add(positions[i])
        }
        line.map = nil
        line = GMSPolyline(path: path)
        let lengths:[NSNumber] = [2,2]
        let styles = [GMSStrokeStyle.solidColor(UIColor.glfWhite), GMSStrokeStyle.solidColor(UIColor.clear)]
        line.spans = GMSStyleSpans(line.path!,styles , lengths as [NSNumber], GMSLengthKind(rawValue: 1)!)
        line.strokeWidth = 2.0
        line.geodesic = true
        line.map = mapView
        userMarkerView.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        if let img = (Auth.auth().currentUser?.photoURL){
            userMarkerView.btn.sd_setImage(with: img, for: .normal, completed: nil)
        }
        else{
            userMarkerView.btn.backgroundColor = UIColor.glfWhite
            let name = Auth.auth().currentUser?.displayName
            userMarkerView.btn.setTitle("\(name?.first ?? " ")", for: .normal)
            userMarkerView.btn.setTitleColor(UIColor.glfBlack, for: .normal)
            userMarkerView.btn.setImage(nil, for: .normal)
        }
        userMarkerView.lbl.text = "tracking.."
        if(isPintMarker){
            userMarkerView.lbl.text = "tracking hole.."
        }
        
        
        userMarker.position = positions.last!
        userMarker.groundAnchor = CGPoint(x:0.1,y:0.5)
        userMarker.title = "user"
        userMarker.userData = "-1"
        userMarker.iconView = userMarkerView
        userMarker.map = isTracking ? mapView:nil
    }
    
    func updateMapWithColors(){
        let circleCenter = self.mapView.camera.target
        circ = GMSCircle(position: circleCenter, radius: 10000)
        circ.fillColor = self.glfMapBG
        circ.map = self.mapView
        
        for i in 0..<courseData.numberOfHoles[holeIndex].tee.count{
            self.drawPolygonWithColor(polygonArray: (courseData.numberOfHoles[holeIndex].tee)[i], color: UIColor.glfGreenBlue)
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].fairway.count{
            self.drawPolygonWithColor(polygonArray: (courseData.numberOfHoles[holeIndex].fairway)[i],color:UIColor.glfGreenBlue)
        }
        self.drawPolygonWithColor(polygonArray: (courseData.numberOfHoles[holeIndex].green),color:UIColor.glfGreenishTurquoise)
        
        for i in 0..<courseData.numberOfHoles[holeIndex].gb.count{
            self.drawPolygonWithColor(polygonArray: (courseData.numberOfHoles[holeIndex].gb)[i],color:UIColor.glfOffWhite)
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].fb.count{
            self.drawPolygonWithColor(polygonArray: (courseData.numberOfHoles[holeIndex].fb)[i],color:UIColor.glfOffWhite)
        }
        for wh in allWaterHazard{
              self.drawPolygonWithColor(polygonArray:wh,color:UIColor.blue)
        }

        for i in 0..<shotViseCurve.count{
            removeLinesAndMarkers(index: i)
            if(!penaltyShots[i]){
                showLinesAndMarker(index: i)
            }else{
                shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
            }
        }
        if !self.positionsOfDotLine.isEmpty{
            plotLine(positions: self.positionsOfDotLine)
        }
    }
    // For AR view we need all the feature's bezierPath
    var allBezierFeatures = [UIBezierPath]()
    func getBezierPathAllFeatures(){
        allBezierFeatures.removeAll()
        for i in 0..<courseData.numberOfHoles[holeIndex].tee.count{
            allBezierFeatures.append(getBezierPath(polygonArr: (courseData.numberOfHoles[holeIndex].tee[i])))
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].fairway.count{
            allBezierFeatures.append(getBezierPath(polygonArr: (courseData.numberOfHoles[holeIndex].fairway[i])))
        }
        allBezierFeatures.append(getBezierPath(polygonArr: (courseData.numberOfHoles[holeIndex].green)))
        for i in 0..<courseData.numberOfHoles[holeIndex].gb.count{
            allBezierFeatures.append(getBezierPath(polygonArr: (courseData.numberOfHoles[holeIndex].gb[i])))
        }
        for i in 0..<courseData.numberOfHoles[holeIndex].fb.count{
            allBezierFeatures.append(getBezierPath(polygonArr: (courseData.numberOfHoles[holeIndex].fb[i])))
        }
        for wh in allWaterHazard{
            allBezierFeatures.append(getBezierPath(polygonArr: wh))
        }
    }
    
    func getBezierPath(polygonArr:[CLLocationCoordinate2D])->UIBezierPath{
        let breizerPath = UIBezierPath()
        breizerPath.move(to: self.mapView.projection.point(for: polygonArr[0]))
        for i in 1 ..< polygonArr.count{
            breizerPath.addLine(to: self.mapView.projection.point(for: polygonArr[i]))
        }
        breizerPath.close()
        return breizerPath
    }
    func drawPolygonWithColor(polygonArray:[CLLocationCoordinate2D],color:UIColor){
        let path = GMSMutablePath()
        for position in polygonArray{
            path.add(position)
        }
        let polygon = GMSPolygon(path: path)
        polygon.strokeWidth = 1
        polygon.geodesic = true
        polygon.fillColor = color
        polygon.map = mapView
        self.allPolygonOfOneHole.append(polygon)
    }
    func botPlayerShotForPar3(gir:Double,distance:Double,distanceFairwayOrRough:NSMutableDictionary){
        if(self.positionsOfDotLine.count > 2){
            var insideDistance = Double()
            if(Int(distance)/100 == 0){
                if(distance >= 0 && distance < 30){
                    insideDistance = distanceFairwayOrRough.value(forKey: "0") as! Double
                }else if(distance >= 30 && distance < 50){
                    insideDistance = distanceFairwayOrRough.value(forKey: "30") as! Double
                }else if(distance >= 50 && distance < 75){
                    insideDistance = distanceFairwayOrRough.value(forKey: "50") as! Double
                }else{
                    insideDistance = distanceFairwayOrRough.value(forKey: "75") as! Double
                }
            }else if(Int(distance)/100 == 1){
                if(distance >= 100 && distance < 125){
                    insideDistance = distanceFairwayOrRough.value(forKey: "100") as! Double
                }else if(distance >= 125 && distance < 150){
                    insideDistance = distanceFairwayOrRough.value(forKey: "125") as! Double
                }else if(distance >= 150 && distance < 175){
                    insideDistance = distanceFairwayOrRough.value(forKey: "150") as! Double
                }else{
                    insideDistance = distanceFairwayOrRough.value(forKey: "175") as! Double
                }
            }else{
                if(distance < 225 && distance >= 200){
                    insideDistance = distanceFairwayOrRough.value(forKey: "200") as! Double
                }
                else{
                    insideDistance = distanceFairwayOrRough.value(forKey: "225") as! Double
                }
            }
            var girPec = self.gir3Perc
            if(gir == 100){
                girPec = gir
            }
            let shotPoint1 = BackgroundMapStats.getPoints(hole: self.positionsOfDotLine.last!, greenPath: courseData.numberOfHoles[holeIndex].green, gir: girPec, insideDistance: insideDistance)
            if(floor(GMSGeometryDistance(shotPoint1, self.positionsOfDotLine.last!)) == 0){
                self.btnActionHoleOut(self.btnHoleOut)
            }else{
                self.positionsOfDotLine[1] = shotPoint1
                self.btnActionTrackShots(self.btnTrackShot)
            }
            if(!holeOutFlag){
                let newDistance = GMSGeometryDistance(shotPoint1, positionsOfDotLine.last!) * Constants.YARD
                if(BackgroundMapStats.findPositionOfPointInside(position: shotPoint1, whichFeature: courseData.numberOfHoles[holeIndex].green)){
                    var end = "G\(Int(floor(newDistance)))"
                    end = end == "G0" ? "G1" : end
                    self.botStrokesGained = Constants.strokesGainedDict[Constants.skrokesGainedFilter].value(forKey:end ) as! Double
                    getPuttsPoints(strkGained: botStrokesGained-botSGPutting, lastCoord: shotPoint1, holeCoord: positionsOfDotLine.last!)
                }else{
                    var landOnFairwayDict = NSMutableDictionary()
                    if(fairwayDetailsForFirstShot(shot:self.shotCount) == "H"){
                        landOnFairwayDict = distanceFairway
                    }else{
                        landOnFairwayDict = distanceRough
                    }
                    self.botPlayerShotForPar3(gir:100,distance: newDistance, distanceFairwayOrRough: landOnFairwayDict)
                }
                self.btnActionHoleOut(self.btnHoleOut)
            }
        }
    }
    func getScoreFromMatchDataFirebases(){
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(self.selectedUserId)").observe(DataEventType.value, with: { (snapshot) in
            if  let scoreDict = (snapshot.value as? NSMutableDictionary){
                for playerDetails in self.playersButton{
                    if(playerDetails.isSelected){
                        for i in 0..<self.scoring[self.holeIndex].players.count{
                            if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                                let dict = NSMutableDictionary()
                                dict.addEntries(from: [self.selectedUserId:scoreDict])
                                self.scoring[self.holeIndex].players[i] = dict
                                break
                            }
                        }
                    }
                }
            }
        })
        { (error) in
            //            print(error.localizedDescription)
        }
    }
    func botPlayerShotForPar4(girWithF : Double,distance:Double){
        if(self.positionsOfDotLine.count > 2){
            let headingRandom = GMSGeometryHeading(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!)
            var nextPoint = CLLocationCoordinate2D()
            var fairway = ""
            if(distance < self.maxDrive - 50){
                let shotDist = Double(arc4random_uniform(50)) + 1
                let random = Double(arc4random_uniform(100))
                debugPrint("ShotDistance:\(shotDist)")
                debugPrint("Distance:\(distance)")
                debugPrint("MaxDrive : \(self.maxDrive)")
                debugPrint("AvgDrive\(self.avgDrive)")
                nextPoint = GMSGeometryOffset(self.positionsOfDotLine.first!, distance/Constants.YARD - shotDist, headingRandom)
                
                if(random <= self.fairwayHitPerc){
                    fairway = "H"
                }
                else{
                    let newRandom = Double(arc4random_uniform(UInt32(100 - self.fairwayHitPerc)))
                    if(newRandom <= self.fairwayLeftPerc){
                        fairway = "L"
                    }
                    else{
                        fairway = "R"
                    }
                }
            }
            else{
                let random = Double(arc4random_uniform(100))
                let dist = (self.avgDrive + self.maxDrive)/2
                
                let maximumDistance = dist-30 > 30 ? dist-30 : 30
                let minimumDistance = dist-30 < 30 ? dist-30 : 30
                
                let convertInside = Int(maximumDistance-minimumDistance)
                let randomGeneratedDistance = Int(arc4random_uniform(60)) + convertInside
                
                nextPoint = GMSGeometryOffset(self.positionsOfDotLine.first!, Double(randomGeneratedDistance), headingRandom)
                if (random <= self.fairwayHitPerc){
                    fairway = "H"
                }
                else {
                    let newRandom = Double(arc4random_uniform(UInt32(100 - random)))
                    if(newRandom <= self.fairwayLeftPerc){
                        fairway = "L"
                    }
                    else{
                        fairway = "R"
                    }
                }
            }
            debugPrint("Fairway : \(fairway)")
            if(fairway == "L"){
                var nearbyPoint = [CLLocationCoordinate2D]()
                var distance = [Double]()
                if(isFairwayHitOrMiss(position: nextPoint) == "F"){
                    for _ in 0..<50{
                        nextPoint = GMSGeometryOffset(nextPoint, 5, headingRandom-90)
                        if !(isFairwayHitOrMiss(position: nextPoint) == "F"){
                            break;
                        }
                    }
                }
                else if (isFairwayHitOrMiss(position: nextPoint) == "L"){
                    for data in courseData.numberOfHoles[holeIndex].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = GMSGeometryOffset(nearbyPoint[distance.index(of:distance.min()!)!],Double(arc4random_uniform(5)+1),headingRandom-90)
                }
                else{
                    for data in courseData.numberOfHoles[holeIndex].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = nearbyPoint[distance.index(of:distance.min()!)!]
                    for _ in 0..<50{
                        nextPoint = GMSGeometryOffset(nextPoint, 5, headingRandom-90)
                        if !(isFairwayHitOrMiss(position: nextPoint) == "F"){
                            break;
                        }
                    }
                }
            }else if(fairway == "R"){
                var nearbyPoint = [CLLocationCoordinate2D]()
                var distance = [Double]()
                if(isFairwayHitOrMiss(position: nextPoint) == "F"){
                    for _ in 0..<50{
                        nextPoint = GMSGeometryOffset(nextPoint, 5, headingRandom+90)
                        if !(isFairwayHitOrMiss(position: nextPoint) == "F"){
                            break;
                        }
                    }
                }
                else if (isFairwayHitOrMiss(position: nextPoint) == "R"){
                    for data in courseData.numberOfHoles[holeIndex].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = GMSGeometryOffset(nearbyPoint[distance.index(of:distance.min()!)!],Double(arc4random_uniform(5)+1),headingRandom+90)
                }
                else{
                    for data in courseData.numberOfHoles[holeIndex].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = nearbyPoint[distance.index(of:distance.min()!)!]
                    for _ in 0..<50{
                        nextPoint = GMSGeometryOffset(nextPoint, 5, headingRandom+90)
                        if !(isFairwayHitOrMiss(position: nextPoint) == "F"){
                            break;
                        }
                    }
                    
                }
            }
            else{
                let path = GMSMutablePath()
                var fairwayArray = [CLLocationCoordinate2D]()
                for data in courseData.numberOfHoles[holeIndex].fairway{
                    for value in data{
                        path.add(value)
                        fairwayArray.append(value)
                    }
                }
                nextPoint = BackgroundMapStats.coordInsideFairway(newPoint: nextPoint, array: fairwayArray, path: path)
            }
            debugPrint(isFairwayHitOrMiss(position: nextPoint))
            self.positionsOfDotLine[1] = nextPoint
            self.btnActionTrackShots(self.btnTrackShot)
            
            if !(BackgroundMapStats.findPositionOfPointInside(position: nextPoint, whichFeature: courseData.numberOfHoles[holeIndex].green)){
                var landOnFairwayDict = NSMutableDictionary()
                if(fairwayDetailsForFirstShot(shot:self.shotCount) == "H"){
                    landOnFairwayDict = distanceFairway
                }else{
                    landOnFairwayDict = distanceRough
                }
                let newDistance = GMSGeometryDistance(nextPoint, positionsOfDotLine.last!) * Constants.YARD
                self.botPlayerShotForPar3(gir: girWithF, distance: newDistance, distanceFairwayOrRough: landOnFairwayDict)
            }else{
                let newDistance = GMSGeometryDistance(nextPoint, positionsOfDotLine.last!) * Constants.YARD * 3
                let end = "G\(Int(floor(newDistance)))"
                self.botStrokesGained = Constants.strokesGainedDict[Constants.skrokesGainedFilter].value(forKey:end ) as! Double
                getPuttsPoints(strkGained: botStrokesGained-botSGPutting, lastCoord: nextPoint, holeCoord: positionsOfDotLine.last!)
            }
            if(!holeOutFlag){
                self.btnActionHoleOut(self.btnHoleOut)
            }
            
        }
    }
    
    func getPuttsPoints(strkGained:Double,lastCoord:CLLocationCoordinate2D,holeCoord:CLLocationCoordinate2D){
        let distance = GMSGeometryDistance(lastCoord, holeCoord) * 3.28084
        if(distance <= 3){
            self.btnActionHoleOut(self.btnHoleOut)
            return
        }
        else if(strkGained > 1 &&  strkGained < 3){
            let minimumShot = Int(floor(strkGained))
            let maximumShot = Int(ceil(strkGained))
            let minPerc = strkGained - Double(minimumShot)
            let rndmValue = Int(arc4random_uniform(100))
            if(rndmValue <= Int(minPerc*100)){
                for i in 1..<maximumShot{
                    if(i == 1){
                        let heading = Double(arc4random_uniform(360))
                        let rndmDist = Int(arc4random_uniform(3)) + 10
                        let newCoord = GMSGeometryOffset(holeCoord, Double(rndmDist)*0.3048, heading)
                        self.positionsOfDotLine[1] = newCoord
                        self.btnActionTrackShots(self.btnTrackShot)
                        
                    }
                    if(i == 2){
                        let heading = Double(arc4random_uniform(360))
                        let rndmDist = Int(arc4random_uniform(2)) + 1
                        let newCoord = GMSGeometryOffset(holeCoord, Double(rndmDist)*0.3048, heading)
                        self.positionsOfDotLine[1] = newCoord
                        self.btnActionTrackShots(self.btnTrackShot)
                        
                    }
                }
            }else{
                for _ in 1..<minimumShot{
                    let heading = Double(arc4random_uniform(360))
                    let rndmDist = Int(arc4random_uniform(2)) + 1
                    let newCoord = GMSGeometryOffset(holeCoord, Double(rndmDist)*0.3048, heading)
                    self.positionsOfDotLine[1] = newCoord
                    self.btnActionTrackShots(self.btnTrackShot)
                }
            }
        }
    }
    func updateRaceToFlag(){
        var strokesGainedHoleWise = [(user:String,strkgnd:Double,name:String,img:UIImage)]()
        let holeNumber = self.holeIndex
//        self.multiplayerPageControl.isHidden = false
        self.lblRaceToFlagTitle.isHidden = false
        self.barChartParentStackView.isHidden = false
        
        for j in 0..<self.playersButton.count{
            var totalStrokes = 3.0
            for i in 0..<scoring[holeNumber].players.count{
                if let playerDict = (scoring[holeNumber].players[i]).value(forKey: playersButton[j].id) as? NSMutableDictionary{
                    if let score = playerDict.value(forKey: "shots") as? NSArray {
                        for data in score{
                            let score = data as! NSMutableDictionary
                            if let strokGaind = score.value(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double{
                                totalStrokes += strokGaind
                            }
                        }
                    }
                }
            }
            strokesGainedHoleWise.append((user: playersButton[j].id, strkgnd: totalStrokes < 0 ? 0:totalStrokes, name: playersButton[j].name, img: playersButton[j].button.currentImage!))
        }
        debugPrint(strokesGainedHoleWise)
        for views in barChartParentStackView.subviews{
            views.removeFromSuperview()
        }
        for i in 0..<strokesGainedHoleWise.count{
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            
            let progressView = UIView()
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.addConstraint(NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: barChartParentStackView.frame.width-30))
            let imgView = UIButton()
            imgView.setImage(strokesGainedHoleWise[i].img, for: .normal)
            //                imgView.setBackgroundImage(#imageLiteral(resourceName: "me"), for: .normal)
            //                if(urls[i].count > 0){
            //                    imgView.sd_setBackgroundImage(with: URL(string:urls[i]), for: .normal, completed: nil)
            //                }
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
            imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
            let newView = UIView(frame: CGRect(x: imgView.frame.maxX, y: 12, width:barChartParentStackView.frame.width-32, height: 6))
            newView.layer.cornerRadius = 2
            newView.backgroundColor = UIColor.glfWhite
            progressView.addSubview(newView)
            imgView.setCircle(frame: imgView.frame)
            UIView.animate(withDuration: 1.5) {
                newView.frame.size = CGSize(width: (strokesGainedHoleWise[i].strkgnd)*Double(self.barChartParentStackView.frame.width-32)/5, height: 6)
            }
            stackView.addArrangedSubview(imgView)
            stackView.addArrangedSubview(progressView)
            self.barChartParentStackView.addArrangedSubview(stackView)
            self.barChartParentStackView.layoutIfNeeded()
            
        }
        
    }
    func setFronBackCenter(ind:Int,currentLocation:CLLocationCoordinate2D)->GreenData{
        var front = CLLocationCoordinate2D()
        var end = CLLocationCoordinate2D()
        
        var heading = GMSGeometryHeading(courseData.centerPointOfTeeNGreen[ind].green,currentLocation)
        for i in 1..<50{
            let point = GMSGeometryOffset(courseData.centerPointOfTeeNGreen[ind].green,Double(i), heading)
            if(callFindPositionInsideFeature(position:point) != "G"){
                front = point
                break
            }
        }
        heading = GMSGeometryHeading(currentLocation,courseData.centerPointOfTeeNGreen[ind].green)
        for i in 1..<50{
            let point = GMSGeometryOffset(courseData.centerPointOfTeeNGreen[ind].green, Double(i), heading)
            if(callFindPositionInsideFeature(position:point) != "G"){
                end = point
                break
            }
        }
        return GreenData(front: front, center:courseData.centerPointOfTeeNGreen[ind].green , back: end)
    }
    

    func letsRotateWithZoom(latLng1:CLLocationCoordinate2D,latLng2 : CLLocationCoordinate2D,isScreenShot:Bool = false){
        
        let rotationAngle = GMSGeometryHeading(latLng1, latLng2)
        let middlePointWithZoom = getTheZoomLevel(latLng1: latLng1,latLng2: latLng2, isSS: isScreenShot)
        let speedOfZoom = 0.5
        let camera = GMSCameraPosition.camera(withLatitude: middlePointWithZoom.0.latitude,
                                              longitude: middlePointWithZoom.0.longitude,
                                              zoom: middlePointWithZoom.1)
        CATransaction.begin()
        CATransaction.setValue(speedOfZoom, forKey: kCATransactionAnimationDuration)
        self.mapView.animate(to: camera)
        self.mapView.animate(toBearing: rotationAngle)
        CATransaction.commit()
    }
    func getTheZoomLevel(latLng1:CLLocationCoordinate2D,latLng2:CLLocationCoordinate2D,isSS:Bool)->(CLLocationCoordinate2D,Float){
        var distance = 200.0
        var midPoint = CLLocationCoordinate2D()
        var lat = Int()
        var teePoint = CLLocationCoordinate2D()
        if(isSS){
            distance  = GMSGeometryDistance(latLng1,latLng2)
            midPoint = GMSGeometryOffset(latLng1, distance*0.5, GMSGeometryHeading(latLng1,latLng2))
            lat = Int(midPoint.latitude)
            if(holeOutFlag){ teePoint = positionsOfCurveLines.first! }
            else{ teePoint = positionsOfDotLine.first! }
        }else{
            distance  = GMSGeometryDistance(latLng1, latLng2)
            teePoint = latLng1
            let heading = GMSGeometryHeading(latLng1, latLng2)
            midPoint = GMSGeometryOffset(latLng1, distance*0.5, heading)
            lat = Int(midPoint.latitude)
        }
        var zoom = 16.0
        if(lat < 90 && lat > 60){
            if (distance > 0 && distance<5){
                zoom = 21.1
            }else if (distance>5&&distance<10){
                zoom = 20.0
            }else if (distance>10&&distance<20){
                zoom = 19.0
            }else if (distance>20&&distance<50){
                zoom = 18.0
            }else if (distance>50&&distance<70){
                zoom = 17.6
            }else if (distance>70&&distance<100){
                zoom = 17.2;
            }else if (distance>100&&distance<150){
                zoom = 17;
            }else if (distance>150&&distance<200){
                zoom = 16.8;
            }else if (distance>200&&distance<250){
                zoom = 16.5;
            }else if (distance>250&&distance<300){
                zoom = 16.4;
            }else if (distance>300&&distance<350){
                zoom = 16.3;
            }else if (distance>350&&distance<400){
                zoom = 16.0;
            }else if (distance>400&&distance<450){
                zoom = 15.9;
            }else if (distance>450&&distance<500){
                zoom = 15.7;
            }else if (distance>500&&distance<550){
                zoom = 15.5;
            }else if (distance>550&&distance<600){
                zoom = 15.3;
            }else{
                zoom = 15.0;
            }
        }else{
            if(distance>0&&distance<10){
                zoom = 21
            }else if (distance>10&&distance<20){
                zoom = 20.5
            }else if (distance>20&&distance<50){
                zoom = 19.5
            }else if (distance>50&&distance<70){
                zoom = 19.0
            }else if (distance>70&&distance<100){
                zoom = 18.7;
            }else if (distance>100&&distance<150){
                zoom = 18.5;
            }else if (distance>150&&distance<200){
                zoom = 18.3;
            }else if (distance>200&&distance<250){
                zoom = 18;
            }else if (distance>250&&distance<300){
                zoom = 17.6;
            }else if (distance>300&&distance<350){
                zoom = 17.5;
            }else if (distance>350&&distance<400){
                zoom = 17.2;
            }else if (distance>400&&distance<450){
                zoom = 17.1;
            }else if (distance>450&&distance<500){
                zoom = 17;
            }else if (distance>500&&distance<550){
                zoom = 16.8;
            }else if (distance>550&&distance<600){
                zoom = 16.7;
            }else{
                zoom = 16.3
            }
        }
        let middlePointWithZoom = (midPoint,Float(zoom))
        debugPrint(teePoint)
        return middlePointWithZoom
    }
    func setupMultiplayersButton(){
        var playersKey = [String]()
        var keyData = String()
        for (key,value) in self.matchDataDict{
            keyData = key as! String
            if(keyData == "player"){
                var i = 0
                for (k,v) in value as! NSMutableDictionary{
                    playersKey.append(k as! String)
                    let btn = UIButton()
                    btn.frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
                    btn.setCircle(frame: btn.frame)
                    btn.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                    btn.isHidden = true
                    btn.tag = i
                    var btn1 = UIButton()
                    for view in self.stackViewForMultiplayer.arrangedSubviews where view.isKind(of: UIButton.self){
                        if view.isKind(of: UIButton.self) && view.tag == i{
                            btn1 = self.stackViewForMultiplayer.arrangedSubviews[i+1] as! UIButton
                            btn1.isHidden = false
                            break
                        }
                    }
                    self.stackViewSubBtn.insertArrangedSubview(btn, at: 1)
                    let name = (v as! NSMutableDictionary).value(forKeyPath: "name") as! String
                    if let img = (v as! NSMutableDictionary).value(forKeyPath: "image") as? String{
                        if(img.count > 2){
                            btn.sd_setImage(with: URL(string:img), for: .normal, completed:nil)
                            
                            btn1.sd_setImage(with: URL(string:img), for: .normal, completed:nil)
                            do{
                                let img = try Data(contentsOf: URL(string:img)!)
                                btn.setImage(UIImage(data:img), for: .normal)
                                btn1.setImage(UIImage(data:img), for: .normal)
                            }catch{
                                debugPrint("jlkjslkfjdsfsd")
                                btn.setImage(#imageLiteral(resourceName: "multiplayer"), for: .normal)
                                btn1.setImage(#imageLiteral(resourceName: "0_you"), for: .normal)
                            }
                        }else{
                            btn.setImage(#imageLiteral(resourceName: "multiplayer"), for: .normal)
                            btn1.setImage(#imageLiteral(resourceName: "0_you"), for: .normal)
                        }
                    }
                    i += 1
                    if(k as! String == Auth.auth().currentUser!.uid){
                        playersButton.append((button:btn, isSelected: true, id: k as! String,name:name))
                        self.btnMultiplayer.setImage(btn.currentImage, for: .normal)
                        self.btnMultiplayerLbl.setTitle("  \(name)  ", for: .normal)
                        self.selectedUserId = k as! String
                        self.lblPlayersName.text = "Your Score".localized()
                        btn1.setCornerWithCircle(color: UIColor.glfGreen.cgColor)
                        if !isHoleByHole{
                            if let swingKey = (v as! NSMutableDictionary).value(forKeyPath: "swingKey") as? String{
                                self.swingMatchId = swingKey
                                if(swingKey != ""){
                                    self.getGameId(swingKey:self.swingMatchId)
                                }
                            }
                        }
                    }else{
                        playersButton.append((button:btn, isSelected: false, id: k as! String,name:name))
                    }
                    self.holeOutforAppsFlyer.append(0)
                    self.multiplayerButtons.append(btn1)
                }
            }
        }
        self.progressView.hide(navItem: self.navigationItem)
        if(!isHoleByHole) && isOnCourse{
            enableLocationServices()
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            self.mapView.isMyLocationEnabled = true
        }
        
        if(playersButton.count == 1){
            playersButton[0].isSelected = true
            self.btnMultiplayer.isHidden = true
            self.btnMultiplayerLbl.isHidden = true
            self.stackViewForMultiplayer.isHidden = true
            self.lblPlayersName.isHidden = true
        }else{
            self.btnMultiplayer.isHidden = false
            self.btnMultiplayerLbl.isHidden = false
        }
        for i in 0..<courseData.numberOfHoles.count{
            self.scoring[i].hole = courseData.numberOfHoles[i].hole
        }
        var currentHole = self.startingIndex
        if let inde = self.matchDataDict.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as? String{
            currentHole = Int(inde)!
        }
        for i in 0..<self.scoring.count{
            if(self.scoring[i].hole == currentHole){if(!self.isHoleByHole){
                self.startingIndex = Int(self.matchDataDict.value(forKeyPath: "startingHole") as? String ?? "1") ?? 1
                self.gameTypeIndex = self.matchDataDict.value(forKey: "matchType") as! String == "9 holes" ? 9:18
                self.courseData.startingIndex = self.startingIndex
                self.courseData.gameTypeIndex = self.gameTypeIndex
            }else{
                self.courseData.startingIndex = Int(self.matchDataDict.value(forKeyPath: "startingHole") as? String ?? "1") ?? 1
                self.courseData.gameTypeIndex = self.matchDataDict.value(forKey: "matchType") as! String == "9 holes" ? 9:18
                }
                self.holeIndex = i
                break
            }
        }
        self.updateMap(indexToUpdate: self.holeIndex)
        self.updateWindSpeed(latLng: courseData.centerPointOfTeeNGreen[self.holeIndex].green, indexToUpdate: self.holeIndex)
        
        if(!isContinue) && (!isHoleByHole){
            if(!isOnCourse){
                self.showCaseMiddleMarker()
            }else{
                if !self.isDeviceConnected {
                    self.showCaseClubChangeOnCourse()
                }

            }
        }
        self.getScoreFromMatchData()
        if(!isHoleByHole) && !isContinue{
            var centerPointOfTeeNGreen = [(tee:CLLocationCoordinate2D,fairway:CLLocationCoordinate2D,green:CLLocationCoordinate2D,par:Int)]()
            for i in 0..<self.scoring.count{
                if courseData.centerPointOfTeeNGreen.count > i{
                centerPointOfTeeNGreen.append((tee: courseData.centerPointOfTeeNGreen[i].tee, fairway: courseData.centerPointOfTeeNGreen[i].fairway, green: courseData.centerPointOfTeeNGreen[i].green, par: self.scoring[i].par))
                }else{
                    let c = courseData.centerPointOfTeeNGreen.count
                centerPointOfTeeNGreen.append((tee: courseData.centerPointOfTeeNGreen[i%c].tee, fairway: courseData.centerPointOfTeeNGreen[i%c].fairway, green: courseData.centerPointOfTeeNGreen[i%c].green, par: self.scoring[i].par))
                }

            }
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command3"), object: centerPointOfTeeNGreen)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.getActiveRound()
            })
        }
    }
    func getActiveRound(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession") { (snapshot) in
            var activeRoundKeysArray = [String:Bool]()
            if (snapshot.value != nil) {
                activeRoundKeysArray = (snapshot.value as? [String : Bool])!
            }
            DispatchQueue.main.async(execute: {
                for data in activeRoundKeysArray{
                    if(data.value){
                        self.swingMatchId = data.key
                    }
                }
                if(!self.isContinue){
                    if !self.swingMatchId.isEmpty{
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(self.swingMatchId)/playType") { (snapshot) in
                            var matchT = String()
                            if let str = snapshot.value as? String{
                                matchT = str
                            }
                            DispatchQueue.main.async(execute: {
                                if matchT.contains(find: "practice"){
                                    self.swingMatchId = String()
                                }else{
                                    self.hideWhenDeviceConnected()
                                }
                            })
                        }
                    }
                }
                else{
                    self.getGameId(swingKey:self.swingMatchId)
                }
            })
        }
    }
    func hideWhenDeviceConnected(){
        self.btnClubs.isHidden = true
        self.btnTrackShot.isHidden = true
        self.lblShotNumber.isHidden = true
        debugPrint("hiddenWhenDeviceConnected")
        self.btnSelectClubs.isHidden = true
        self.btnClubs.isHidden = true
        self.btnHoleoutLbl.isHidden = true
        self.lblEditShotNumber.isHidden = true
        self.btnClose.isHidden = true
        self.btnCloseLbl.isHidden = true
        self.stackViewSubBtn.isHidden = true
        self.btnAddPenaltyLbl.isHidden = true
        
    }
    var deviceGameID = Int()
    func getGameId(swingKey:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/gameId") { (snapshot) in
            var gameid = 0
            if (snapshot.value != nil) {
                gameid = snapshot.value as! Int
                Constants.ble.currentGameId = gameid
                self.deviceGameID = gameid
            }
            DispatchQueue.main.async(execute: {
                if(self.isContinue){
                    self.isNextPrevBtn = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "response9"), object: false)
                }
            })
        }
    }
    func getSwingData(swingKey:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/") { (snapshot) in
            var swingDa = NSMutableDictionary()
            if (snapshot.value != nil) {
                swingDa = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                if let swingShotArr = swingDa.value(forKey: "swings") as? NSArray{
                    self.swingShotArr = swingShotArr
                    self.calculateSwingDataForCurrentHole()
                }
            })
        }
    }
    func calculateSwingDataForCurrentHole(){
        self.swingData.removeAll()
        for swing in swingShotArr{
            let swing = swing as! NSMutableDictionary
            var tempArr = [Any]()
            var backSwingAngle = 0.0
            if let bckAngle = swing.value(forKey: "backSwingAngle") as? Double{
                backSwingAngle = bckAngle
            }
            let backSwing = swing.value(forKey: "backSwing") as! Double
            let downSwing = swing.value(forKey: "downSwing") as! Double
            let clubSpeed = swing.value(forKey: "clubSpeed") as! Double
            let handSpeed = swing.value(forKey: "handSpeed") as! Double
            let tempo = swing.value(forKey: "tempo") as! Double
            let swingScore = swing.value(forKey: "swingScore") as! Int
            let club = swing.value(forKey: "club") as! String
            let VCArr : [Int] = [(0),(0),(0),Int(clubSpeed)]
            let VHArr : [Int] = [(0),(0),(0),Int(handSpeed)]
            if club != "Pu"{
                tempArr.append("\(Int(swingScore))")
                tempArr.append(VCArr)
                tempArr.append("-")
                tempArr.append("\(tempo.rounded(toPlaces: 1))")
                tempArr.append("\(backSwingAngle)")
                tempArr.append(VHArr)
                if club == ""{
                    tempArr.append("Dr")
                }else{
                    tempArr.append(club)
                }
                
                tempArr.append("\(backSwing)")
                tempArr.append("\(downSwing)")
                let holeNum = swing.value(forKey: "holeNum") as! Int
                if(holeNum == self.holeIndex+1){
                    self.swingData.append(tempArr)
                }
            }
        }
    }
    // MARK :- OFFCourse Tutorials
    func showCaseMiddleMarker(){
        var label2 = UILabel()
        let showCaseTargetLine = CTShowcaseView(title: "", message: "Drag your target marker to get free club recommendations for every shot.".localized(),key:nil){ () -> () in
            label2.removeFromSuperview()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.showCaseClubChange()
            })
        }
        showCaseTargetLine.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showCaseTargetLine.continueButton.isHidden = false
        let highlighterForTargetLine = showCaseTargetLine.highlighter as! CTStaticGlowHighlighter
        highlighterForTargetLine.highlightColor = UIColor.glfWhite
        highlighterForTargetLine.highlightType = .circle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if(self.positionsOfDotLine.count > 1){
                let point = self.mapView.projection.point(for: self.positionsOfDotLine[1])
                label2 = UILabel(frame: CGRect(x: point.x-25, y: point.y-25, width: 50, height: 50))
                self.mapView.addSubview(label2)
                showCaseTargetLine.setup(for:label2 , offset: .zero , margin: 5)
                var timerForMiddleMarker = Timer()
                
                //                debugPrint(self.view.)
                timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    if(self.shotCount == 0) && (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && (self.dragMarkShowCase == nil){
                        if let thePresenter = self.navigationController?.visibleViewController{
                            if (thePresenter.isKind(of:NewMapVC.self)){
                                showCaseTargetLine.show()
                            }
                        }
                        timerForMiddleMarker.invalidate()
                    }
                })
            }
        })
    }
    func showCaseClubChange(){
        let showCaseSelectClub = CTShowcaseView(title: "", message: "This is the club we recommend based on your yardage. Tap to change.".localized(),key:nil){()->() in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.showCaseTrackShots()
            })
        }
        showCaseSelectClub.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showCaseSelectClub.continueButton.isHidden = false
        
        let highlighterCubChange = showCaseSelectClub.highlighter as! CTStaticGlowHighlighter
        highlighterCubChange.highlightColor = UIColor.glfWhite
        showCaseSelectClub.setup(for: self.btnSelectClubs, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && (self.dragMarkShowCase == nil){
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showCaseSelectClub.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseTrackShots(){
        let showcaseTrackShots = CTShowcaseView(title: "", message: "Tap to record this shot.".localized(),key:nil){()->() in}
        showcaseTrackShots.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showcaseTrackShots.continueButton.isHidden = false
        let highlightTrackShot = showcaseTrackShots.highlighter as! CTStaticGlowHighlighter
        highlightTrackShot.highlightColor = UIColor.glfWhite
        showcaseTrackShots.setup(for: self.btnTrackShot, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && (self.dragMarkShowCase == nil){
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showcaseTrackShots.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseHoleOutShots(){
        let showCaseHoleOut = CTShowcaseView(title: "", message: "Use the hole-out button to complete this hole and view score.".localized(),key:nil){()->() in}
        showCaseHoleOut.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showCaseHoleOut.continueButton.isHidden = false
        let highlighterHoleOut = showCaseHoleOut.highlighter as! CTStaticGlowHighlighter
        highlighterHoleOut.highlightColor = UIColor.glfWhite
        showCaseHoleOut.setup(for: self.btnHoleOut, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && self.shotCount != 0 && (self.dragMarkShowCase == nil){
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showCaseHoleOut.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseShareShots(){
        let showcaseShareShots = CTShowcaseView(title: "", message: "Share your hole and stats with friends on Golfication or social media.".localized(),key:nil){()->() in}
        showcaseShareShots.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showcaseShareShots.continueButton.isHidden = false
        let highlightShareStats = showcaseShareShots.highlighter as! CTStaticGlowHighlighter
        highlightShareStats.highlightColor = UIColor.glfWhite
        showcaseShareShots.setup(for: self.btnShareHoleStats, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            if let thePresenter = self.navigationController?.visibleViewController{
                if (thePresenter.isKind(of:NewMapVC.self)){
                    showcaseShareShots.show()
                }
            }
            
        })
    }
    // MARK:- ONCourse Tutorial
    func showCaseClubChangeOnCourse(){
        let showCaseSelectClub = CTShowcaseView(title: "", message: "This is the club we recommend based on your yardage. Tap to change.".localized(),key:nil){()->() in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.showCaseTrackShotsOnCourse()
            })
        }
        showCaseSelectClub.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showCaseSelectClub.continueButton.isHidden = false
        let highlighterCubChange = showCaseSelectClub.highlighter as! CTStaticGlowHighlighter
        highlighterCubChange.highlightColor = UIColor.glfWhite
        showCaseSelectClub.setup(for: self.btnSelectClubs, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && (self.dragMarkShowCase == nil) && !self.centerSV.isHidden{
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showCaseSelectClub.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseTrackShotsOnCourse(){
        let showcaseTrackShots = CTShowcaseView(title: "", message: "Tap here to tee-off from your current GPS location.".localized(),key:nil){()->() in}
        showcaseTrackShots.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showcaseTrackShots.continueButton.isHidden = false
        let highlightTrackShot = showcaseTrackShots.highlighter as! CTStaticGlowHighlighter
        highlightTrackShot.highlightColor = UIColor.glfWhite
        showcaseTrackShots.setup(for: self.btnTrackShot, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if(self.shotCount == 0) && (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && (self.dragMarkShowCase == nil) && !self.centerSV.isHidden{
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showcaseTrackShots.show()
                        }
                    }
                    
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseStopShotsOnCourse(){
        let showcaseTrackShots = CTShowcaseView(title: "", message: "When you reach the location of the ball, tap here to stop tracking this shot.".localized(),key:nil){()->() in}
        showcaseTrackShots.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showcaseTrackShots.continueButton.isHidden = false
        let highlightTrackShot = showcaseTrackShots.highlighter as! CTStaticGlowHighlighter
        highlightTrackShot.highlightColor = UIColor.glfWhite
        showcaseTrackShots.setup(for: self.btnTrackShot, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && !self.centerSV.isHidden{
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showcaseTrackShots.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    func showCaseHoleOutShotsOnCourse(){
        let showCaseHoleOut = CTShowcaseView(title: "", message: "Use the hole-out button to complete this hole and view score.".localized(),key:nil){()->() in}
        showCaseHoleOut.continueButton.setTitle("Ok, Got it.".localized(), for: .normal)
        showCaseHoleOut.continueButton.isHidden = false
        let highlighterHoleOut = showCaseHoleOut.highlighter as! CTStaticGlowHighlighter
        highlighterHoleOut.highlightColor = UIColor.glfWhite
        showCaseHoleOut.setup(for: self.btnHoleOut, offset: .zero, margin: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            var timerForMiddleMarker = Timer()
            timerForMiddleMarker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (!self.btnPlayersStats.isHidden) && (self.selectClubDropper.status == .hidden) && !self.centerSV.isHidden{
                    if let thePresenter = self.navigationController?.visibleViewController{
                        if (thePresenter.isKind(of:NewMapVC.self)){
                            showCaseHoleOut.show()
                        }
                    }
                    timerForMiddleMarker.invalidate()
                }
            })
        })
    }
    
    @objc func buttonAction(sender: UIButton!) {
        for i in 0..<playersButton.count{
            var btn1 = UIButton()
            for view in self.stackViewForMultiplayer.arrangedSubviews where view.isKind(of: UIButton.self){
                if view.tag == i{
                    btn1 = self.stackViewForMultiplayer.arrangedSubviews[i+1] as! UIButton
                    break
                }
            }
            if(i == sender.tag){
                if(!playersButton[i].isSelected){
                    playersButton[i].isSelected = true
                    selectedUserId = playersButton[i].id
                    self.btnMultiplayerLbl.setTitle("  \(playersButton[i].name)  ", for: .normal)
                    self.lblPlayersName.text = "\(playersButton[i].name)'s Score"
                    if(selectedUserId == Auth.auth().currentUser!.uid){
                        self.lblPlayersName.text = "Your Score".localized()
                    }
                    btn1.setCornerWithCircle(color: UIColor.glfGreen.cgColor)
                }
            }
            else{
                playersButton[i].isSelected = false
                btn1.setCornerWithCircle(color: UIColor.clear.cgColor)
                
            }
        }
        
        for i in 0..<playersButton.count{
            if(playersButton[i].isSelected){
                updateMap(indexToUpdate: holeIndex)
                self.btnMultiplayer.setImage(playersButton[i].button.currentImage, for: .normal)
                self.btnMultiplayer.tag = 0
                showMultiplayer(hide: true)
            }
        }
    }
    @objc func playersAction(sender: UIButton!) {
        for i in 0..<multiplayerButtons.count{
            var btn1 = UIButton()
            for view in self.stackViewForMultiplayer.arrangedSubviews where view.isKind(of: UIButton.self){
                if view.tag == i{
                    btn1 = self.stackViewForMultiplayer.arrangedSubviews[i+1] as! UIButton
                    break
                }
            }
            if(i == sender.tag){
                self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex,playerId: playersButton[i].id)
                if(self.shotsDetails.isEmpty){
                    self.scoreTableView.reloadData()
                    self.constraintTableHeight.constant = tableViewHeight
                    self.updateRaceToFlag()
                    for i in 0..<self.scoring[holeIndex].players.count where self.scoring[holeIndex].players[i].value(forKey: playersButton[i].id) != nil{
                        if let scoringDict = (self.scoring[self.holeIndex].players[i].value(forKey: playersButton[i].id) as? NSMutableDictionary){
                            if let isholeout = (scoringDict.value(forKey: "holeOut") as? Bool){
                                self.stableFordView.isHidden =  !isholeout || chkStableford
                                self.lblTopHCP.text = "HCP \(self.getHCPValue(playerID: playersButton[i].id, holeNo: self.scoring[self.holeIndex].hole))"
                            }
                        }
                    }
                    self.btnTotalShotsNumber.isHidden = true
                    self.btnShotRanking.isHidden = true
                }else{
                    self.buttonAction(sender: playersButton[sender.tag].button)
                }
                
                self.lblPlayersName.text = "\(playersButton[i].name)'s Score"
                if(playersButton[i].id == Auth.auth().currentUser!.uid){
                    self.lblPlayersName.text = "Your Score".localized()
                }
                btn1.setCornerWithCircle(color: UIColor.glfGreen.cgColor)
            }
            else{
                btn1.setCornerWithCircle(color: UIColor.clear.cgColor)
            }
        }
    }
    func getScoreFromMatchData(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(Constants.matchId)/scoring/\(self.holeIndex)/") { (snapshot) in
            if  let score = (snapshot.value as? NSDictionary){
                var playersArray = [NSMutableDictionary]()
                for(key,value) in score{
                    if(key as! String != "par"){
                        let dict = NSMutableDictionary()
                        dict.setObject(value, forKey: key as! String as NSCopying)
                        playersArray.append(dict)
                    }
                }
                self.scoring[self.holeIndex].players = playersArray
            }
            DispatchQueue.main.async(execute: {
                self.shotsDetails = self.getShotDataOrdered(indexToUpdate: self.holeIndex, playerId: self.selectedUserId)
                self.progressView.hide(navItem: self.navigationItem)
            })
        }
    }
    func uploadStats(shot:Int,clubName:String,playerKey:String){
        isDraggingMarker = false
        var playerId :String!
        playerArrayWithDetails = NSMutableDictionary()
        for data in scoring[holeIndex].players{
            if let shotsDetails = data.value(forKey: playerKey) as? NSMutableDictionary{
                if let shots = (shotsDetails.value(forKey: "shots") as? [NSMutableDictionary]){
                    self.playerShotsArray = shots
                }
            }
            
        }
        for playerDetails in playersButton{
            if(playerDetails.isSelected){
                playerId = playerDetails.id
                if(shot==1){
                    var drivingDistance = 0.0
                    player = NSMutableDictionary()
                    gir = false
                    playerShotsArray = [NSMutableDictionary]()
                    if(self.scoring[holeIndex].par>3){
                        drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*Constants.YARD
                        playerArrayWithDetails.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
                    }
                    if(self.scoring[holeIndex].par > 3){
                        fairwayHitMisDistance(shot:shot)
                    }
                    if(!holeOutFlag) && self.scoring[holeIndex].par > 3 {
                        playerArrayWithDetails.setObject(fairwayDetailsForFirstShot(shot:shot), forKey: "fairway" as NSCopying)
                    }
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                if(shot == 2)&&(!gir)&&(self.scoring[holeIndex].par>3) && positionsOfCurveLines.count > shot{
                    
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                if(shot == 3)&&(!gir)&&(self.scoring[holeIndex].par>4) && positionsOfCurveLines.count > shot{
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                uploadApproachAndApproachShots(playerId: playerId)
                //                var playerIndex = Int()
                playerArrayWithDetails.setObject(holeOutFlag, forKey: "holeOut" as NSCopying)
                playerArrayWithDetails.setObject(gir, forKey: "gir" as NSCopying)
                playerShotsArray.append(getShotDetails(shot:shot,club:clubName, isPenalty: false))
                playerArrayWithDetails.setObject(playerShotsArray, forKey: "shots" as NSCopying)
                for i in 0..<self.scoring[self.holeIndex].players.count{
                    if let _ = self.scoring[self.holeIndex].players[i].value(forKey: playerKey) as? NSMutableDictionary{
                        self.scoring[self.holeIndex].players[i].setValue(self.playerArrayWithDetails, forKey: playerKey)
                    }
                }
                if(holeOutFlag){
                    uploadChipUpNDown(playerId: playerId)
                    uploadSandUpNDown(playerId: playerId)
                    uploadPutting(playerId: playerId)
                    self.uploadPenalty(playerId: playerId)
                    if(!self.teeTypeArr.isEmpty){
                        self.uploadStableFordPints(playerId: playerId)
                    }
                }
                Notification.sendLocaNotificatonToUser()
                
                ref.child("matchData/\(self.currentMatchId)/scoring/\(holeIndex)/\(playerId!)/").updateChildValues(playerArrayWithDetails as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    self.isProcessing = false
                    self.getScoreFromMatchDataFirebases()
                })
            }
        }
    }
    func uploadStableFordPints(playerId:String){
        var strokes = Int()
        for i in 0..<self.scoring[holeIndex].players.count where self.scoring[holeIndex].players[i].value(forKey: playerId) != nil{
            if let scoringDict = (self.scoring[self.holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary){
                if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                    strokes = scoreShots.count
                }
            }
        }
        let par = scoring[holeIndex].par
        let courseHCP = Int(self.calculateTotalExtraShots(playerID: playerId))
        let temp = courseHCP/18
        var totalShotsInThishole = temp+par
        let hcp = self.getHCPValue(playerID: playerId, holeNo: self.scoring[self.holeIndex].hole)
        if (courseHCP - temp*18 >= hcp) {
            totalShotsInThishole += 1;
        }
        var sbPoint = totalShotsInThishole - strokes + 2
        if sbPoint<0 {
            sbPoint = 0
        }
        let netScore = strokes - (totalShotsInThishole - par)
        self.lblStblScore.text = "\(sbPoint)"
        playerArrayWithDetails.setObject(sbPoint, forKey: "stableFordPoints" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/stableFordPoints").setValue(sbPoint)
        
        playerArrayWithDetails.setObject(netScore, forKey: "netScore" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/netScore").setValue(netScore)
    }
    func updateStrokesButtonWithoutStrokes(strokes:Int,btn:UIButton){
        btn.layer.borderWidth = 0
        if let layers = btn.layer.sublayers{
            for lay in layers{
                lay.borderWidth = 0
            }
        }
        if strokes <= -2 || strokes <= -3{
            //double circle
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = self.glfButtonMapShotRanking.cgColor
            layer.cornerRadius = layer.frame.height/2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = btn.frame.height/2
            btn.layer.borderColor = self.glfButtonMapShotRanking.cgColor
            
        }
            
        else if strokes == -1{
            //single circle
            if let layers = btn.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            btn.titleLabel?.layer.borderWidth = 0
            btn.layer.borderWidth = 1
            btn.layer.borderColor = self.glfButtonMapShotRanking.cgColor
            btn.layer.cornerRadius = btn.frame.size.height/2
        }
            
        else if strokes == 1{
            //single square
            btn.layer.borderWidth = 1
            btn.layer.borderColor = self.glfButtonMapShotRanking.cgColor
            btn.layer.cornerRadius = 2
        }
            
        else if strokes >= 2 || strokes >= 3{
            //double square
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = self.glfButtonMapShotRanking.cgColor
            layer.cornerRadius = 2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 2
            btn.layer.borderColor = self.glfButtonMapShotRanking.cgColor
        }
    }
    func updateCurrentHole(index: Int){
        if !swingMatchId.isEmpty{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "response9"), object: false)
        }
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.scoring[index].hole)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        if(isOnCourse){
            let headTeeToGreen = GMSGeometryHeading(courseData.centerPointOfTeeNGreen[index].tee,courseData.centerPointOfTeeNGreen[index].green)
            let HeadUserToGreen = GMSGeometryHeading(self.userLocationForClub!,courseData.centerPointOfTeeNGreen[index].green)
            
            let rotationAngle = headTeeToGreen - self.windHeading
            let anotherRoationAngle = HeadUserToGreen - self.windHeading
            UIButton.animate(withDuration: 2.0, animations: {
                self.imgViewWind.transform = CGAffineTransform(rotationAngle: (CGFloat(anotherRoationAngle)) / 180.0 * CGFloat(Double.pi))
                self.imgViewWindForeground.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
            })
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if(self.isOnCourse) {
                if(self.positionsOfDotLine.count > 2){
                    self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                }
            }else{
                if(self.positionsOfDotLine.count > 2){
                    self.plotSuggestedMarkersOffCourse(position: self.positionsOfDotLine)
                }
            }
            self.holeOutforAppsFlyer[self.playerIndex] = self.checkHoleOutZero(playerId: Auth.auth().currentUser!.uid)
            if(self.holeOutforAppsFlyer[self.playerIndex] == self.scoring.count){
                debugPrint("open end round pop up")
                // open end round pop up
            }
        })
    }
    
    func fairwayHitMisDistance(shot:Int){
        if(fairwayDetailsForFirstShot(shot:shot) == "H"){
            let coord = positionsOfCurveLines[shot]
            var fairwayCoord = [CLLocationCoordinate2D]()
            for data in courseData.numberOfHoles[holeIndex].fairway{
                if(BackgroundMapStats.findPositionOfPointInside(position: coord, whichFeature: data)){
                    fairwayCoord = data
                    break
                }
            }
            let path = GMSMutablePath()
            for j in 0..<fairwayCoord.count{
                path.add(fairwayCoord[j])
            }
            let nearbyCoord = fairwayCoord[BackgroundMapStats.nearByPoint(newPoint: coord, array: fairwayCoord)]
            let headingAngle = GMSGeometryHeading(coord, nearbyCoord)
            let nextPoint = GMSGeometryOffset(nearbyCoord, 50, headingAngle)
            let prevPoint = GMSGeometryOffset(coord, 50, 180 - headingAngle)
            let linePath = GMSMutablePath()
            linePath.add(nextPoint)
            linePath.add(coord)
            linePath.add(nearbyCoord)
            linePath.add(prevPoint)
            let distanceLineFarway = GMSPolyline(path: linePath)
            distanceLineFarway.strokeWidth = 2.0
            distanceLineFarway.geodesic = true
            //            distanceLineFarway.map = mapView
        }
    }
    func getShotDetails(shot:Int,club:String,isPenalty:Bool)->NSMutableDictionary{
        //        currentShotsDetails.removeAll()
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        var start = String()
        var end = String()
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        if(club == ""){
            shotDictionary.setObject((self.btnSelectClubs.currentTitle!).trim(), forKey: "club" as NSCopying)
        }
        else{
            shotDictionary.setObject(club.trim(), forKey: "club" as NSCopying)
        }
        shotDictionary.setObject(isPenalty, forKey: "penalty" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].latitude, forKey: "lat2" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].longitude, forKey: "lng2" as NSCopying)
        if(shot == 1){
            shotDictionary.setObject("T", forKey: "start" as NSCopying)
            start = "T"
        }
        else{
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot-1]), forKey: "start" as NSCopying)
            start = callFindPositionInsideFeature(position:positionsOfCurveLines[shot-1])
            if(start == "WH" && isOnCourse){
                start = "R"
                shotDictionary.setObject(start, forKey: "start" as NSCopying)
                if((self.btnLandedOnDropDown.titleLabel?.text)!.trim()) == "Water H." || "Water Hazard" == ((self.btnLandedOnDropDown.titleLabel?.text)!.trim()){
                    shotDictionary.setObject("WH", forKey: "start" as NSCopying)
                }
            }
        }
        if(!isDraggingMarker){
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot]), forKey: "end" as NSCopying)
            end = callFindPositionInsideFeature(position:positionsOfCurveLines[shot])
            if(end == "WH" && isOnCourse){
                end = "R"
                shotDictionary.setObject(end, forKey: "end" as NSCopying)
                if((self.btnLandedOnDropDown.titleLabel?.text)!.trim()) == "Water H." || ((self.btnLandedOnDropDown.titleLabel?.text)!.trim()) == "Water Hazard"{
                    shotDictionary.setObject("WH", forKey: "end" as NSCopying)
                }
            }
            if(self.btnTrackShot.tag+1 == shot){
                let landedOn = BackgroundMapStats.returnLandedOnFullName(data:end)
                self.btnLandedOnDropDown.setTitle("\(landedOn.0)", for: .normal)
                self.btnLandedOnDropDown.backgroundColor = landedOn.1
            }
        }
        else{
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot]), forKey: "end" as NSCopying)
            end = callFindPositionInsideFeature(position:positionsOfCurveLines[shot])
            if(end == "WH" && isOnCourse){
                end = "R"
                shotDictionary.setObject(end, forKey: "end" as NSCopying)
                if((self.btnLandedOnDropDown.titleLabel?.text)!.trim()) == "Water H." || ((self.btnLandedOnDropDown.titleLabel?.text)!.trim()) == "Water Hazard"{
                    shotDictionary.setObject("WH", forKey: "end" as NSCopying)
                }
            }
            if(self.btnTrackShot.tag+1 == shot){
                let landedOn = BackgroundMapStats.returnLandedOnFullName(data:end)
                self.btnLandedOnDropDown.setTitle("\(landedOn.0)", for: .normal)
                self.btnLandedOnDropDown.backgroundColor = landedOn.1
            }
        }
        let distanceBwShots = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])
        var distanceBwHole0 = Double()
        var distanceBwHole1 = Double()
        if(!isDraggingMarker){
            if(holeOutFlag){
                distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfCurveLines.last!)
                distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines.last!)
            }
            else{
                distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
                distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfDotLine.last!)
            }
        }else{
            if(holeOutFlag){
                distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfCurveLines.last!)
                distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines.last!)
                
            }
            else{
                distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
                distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfDotLine.last!)
                
            }
        }
        shotDictionary.setObject((distanceBwShots*Constants.YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*Constants.YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*Constants.YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*Constants.YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*Constants.YARD).rounded()))"
        }
        if(Int((distanceBwHole0*Constants.YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*Constants.YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*Constants.YARD).rounded()) < 100) && shotCount == 0{
            start = "\(start)100"
        }
        var numberOfPenalty = 0
        if(shot < penaltyShots.count){
            for i in shot..<penaltyShots.count{
                if (self.penaltyShots[i]){
                    numberOfPenalty += 1
                }else{
                    break
                }
            }
        }
        for i in 0..<Constants.strkGainedString.count{
            var strkG = calculateStrokesGained(start:start,end:end,filterIndex:i)
            strkG = strkG - Double(numberOfPenalty)
            shotDictionary.setObject(strkG, forKey: Constants.strkGainedString[i] as NSCopying)
        }
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot]), forKey: "heading" as NSCopying)
        return shotDictionary
    }
    func uploadApproachAndApproachShots(playerId:String){
        var approachDistance = 0.0
        let appDistDict = NSMutableDictionary()
        for i in 0..<positionsOfCurveLines.count{
            approachDistance = GMSGeometryDistance(positionsOfCurveLines[i],courseData.centerPointOfTeeNGreen[holeIndex].green)*Constants.YARD
            if(approachDistance<200 && approachDistance != 0){
                appDistDict.setObject(approachDistance.rounded(toPlaces: 2), forKey: "approachDistance" as NSCopying)
                break
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/").updateChildValues(appDistDict as! [AnyHashable : Any])
    }
    func uploadSandUpNDown(playerId : String){
        var appDistance = Double()
        var sandUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], courseData.numberOfHoles[holeIndex].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: courseData.numberOfHoles[holeIndex].green)])*Constants.YARD
            if(appDistance<70){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i]) == "GB" ){
                    sandUpDown = true
                }
                else{
                    sandUpDown = false
                }
                break
            }
            else{
                sandUpDown = nil
            }
        }
        if(isDraggingMarker){
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/sandUpDown").setValue(sandUpDown)
        }
        else{
            if(sandUpDown != nil){
                playerArrayWithDetails.setObject(sandUpDown, forKey: "sandUpDown" as NSCopying)
            }
        }
        
    }
    func uploadPutting(playerId:String){
        var putting = Int()
        for i in 0..<self.scoring[holeIndex].players.count where self.scoring[holeIndex].players[i].value(forKey: playerId) != nil{
            if let scoringDict = (self.scoring[self.holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary){
                if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                    for data in scoreShots{
                        let dataDict = data as! NSMutableDictionary
                        if((dataDict.value(forKey: "club") as! String).trim() == "Pu"){
                            putting += 1
                        }
                    }
                    break
                }
            }
            
        }
        playerArrayWithDetails.setObject(putting, forKey: "putting" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/putting").setValue(putting)
    }
    func uploadPenalty(playerId:String){
        var putting = Int()
        for i in 0..<self.scoring[holeIndex].players.count where self.scoring[holeIndex].players[i].value(forKey: playerId) != nil{
            if let scoringDict = (self.scoring[self.holeIndex].players[i].value(forKey: playerId) as? NSMutableDictionary){
                if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                    for data in scoreShots{
                        let dataDict = data as! NSMutableDictionary
                        if((dataDict.value(forKey: "penalty") as! Bool) == true){
                            putting += 1
                        }
                    }
                    break
                }
            }
            
        }
        playerArrayWithDetails.setObject(putting, forKey: "penaltyCount" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.holeIndex)/\(playerId)/penaltyCount").setValue(putting)
    }
    func uploadChipUpNDown(playerId : String){
        var appDistance = Double()
        var chipUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], courseData.numberOfHoles[holeIndex].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: courseData.numberOfHoles[holeIndex].green)])*Constants.YARD
            if(appDistance<70){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i]) != "GB" ){
                    chipUpDown = true
                }
                else{
                    chipUpDown = false
                }
                break
            }
            else{
                chipUpDown = nil
            }
        }
        if(isDraggingMarker){
            ref.child("matchData/\(self.currentMatchId)/scoring/\(holeIndex)/\(playerId)/chipUpDown").setValue(chipUpDown)
        }
        else{
            if(chipUpDown != nil){
                playerArrayWithDetails.setObject(chipUpDown, forKey: "chipUpDown" as NSCopying)
            }
        }
    }
    func fairwayDetailsForFirstShot(shot:Int)->String{
        var fairwayHitOrMiss = ""
        if(callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) != "F"){
            fairwayHitOrMiss = isFairwayHitOrMiss(position: positionsOfCurveLines[shot])
        }
        else{
            fairwayHitOrMiss = "H"
        }
        return fairwayHitOrMiss
    }
    func calculateStrokesGained(start:String,end:String,filterIndex:Int)->Double{
        var strkGnd = Double()
        var startGained = Double()
        var endGained = Double()
        
        if(Constants.strokesGainedDict[filterIndex].value(forKey: start) != nil){
            startGained = Constants.strokesGainedDict[filterIndex].value(forKey: start) as! Double
        }
        if(Constants.strokesGainedDict[filterIndex].value(forKey: end) != nil){
            endGained = Constants.strokesGainedDict[filterIndex].value(forKey: end) as! Double
        }
        
        strkGnd = startGained - endGained - 1
        return strkGnd
    }
    func coordLeftOrRight(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D)->String{
        let leftOrRight : String!
        var headingAngleOfStartingToGreen = 0.0
        if(holeOutFlag){
            headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfCurveLines.last!)
        }
        else{
            if(positionsOfDotLine.count != 0){
                headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfDotLine.last!)
            }
            else{
                headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfCurveLines[1])
            }
        }
        let headingAngleOfStartToEnd = GMSGeometryHeading(start, end)
        
        if(headingAngleOfStartToEnd < headingAngleOfStartingToGreen){
            leftOrRight = "L"
        }
        else{
            leftOrRight = "R"
        }
        return leftOrRight
    }
    func isFairwayHitOrMiss(position:CLLocationCoordinate2D)->String{
        var fairwayDetails = ""
        var headingAngleOfTeeToGreen = 0.0
        if(holeOutFlag){
//            headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfCurveLines.last!)
            headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfCurveLines.first!, position: position)
        }
        else{
            if(positionsOfDotLine.count != 0){
                if(positionsOfCurveLines.isEmpty){
                    headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfDotLine.first!, position: position)
//                    headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfDotLine.first!, positionsOfDotLine.last!)
                }else{
//                    headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfDotLine.last!)
                    headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfCurveLines.first!, position: position)
                }
            }
        }
        
        var headingAngleOfTeeToFairway = 0.0
        if(positionsOfCurveLines.isEmpty){
            headingAngleOfTeeToFairway = GMSGeometryHeading(positionsOfDotLine.first!, position)
        }
        else{
            headingAngleOfTeeToFairway = GMSGeometryHeading(positionsOfCurveLines.first!, position)
        }
        if(headingAngleOfTeeToFairway < headingAngleOfTeeToGreen){
            fairwayDetails = "L"
        }
        else{
            fairwayDetails = "R"
        }
        return fairwayDetails
    }
    func getPointHeading(starting:CLLocationCoordinate2D,position:CLLocationCoordinate2D)->Double{
        var heading = 0.0
        if !((self.courseData.numberOfHoles[self.holeIndex]).fairway).isEmpty{
            var nearPoint = [CLLocationCoordinate2D]()
            var distance = [Double]()
            for data in ((self.courseData.numberOfHoles[self.holeIndex]).fairway){
                nearPoint.append(data[(BackgroundMapStats.nearByPoint(newPoint: position, array: data))])
                distance.append(GMSGeometryDistance(position, nearPoint.last!))
            }
            let min = distance.min()!
            let index = distance.firstIndex(of: min)!
            let finalNearbyPoint = nearPoint[index]
            heading = GMSGeometryHeading(starting, finalNearbyPoint)
        }
        return heading
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        debugPrint("Do Nothing")
        debugPrint(coordinate)
        self.codeWhenClickToBackView()
        if(self.btnTrackShot.currentImage == #imageLiteral(resourceName: "edit_White")) && !holeOutFlag{
            self.btnActionClose(self.btnClose)
        }
        if !self.swingMatchId.isEmpty{
            self.hideWhenDeviceConnected()
        }
    }
    func checkHoleOutZero(playerId:String) -> Int{
        // --------------------------- Check If User has not played game at all ------------------------
        var myVal: Int = 0
        for i in 0..<self.scoring.count{
            for dataDict in self.scoring[i].players{
                for (key,value) in dataDict{
                    let dic = value as! NSDictionary
                    if dic.value(forKey: "holeOut") as! Bool == true{
                        if(key as? String == playerId){
                            for (key,value) in value as! NSMutableDictionary{
                                if (key as! String == "holeOut" && value as! Bool){
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
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if self.selectedUserId != "jpSgWiruZuOnWybYce55YDYGXP62" && !self.markers.contains(marker) && !isTracking && btnClose.isHidden{
            tappedMarker = marker
            
            if (tappedMarker.iconView)?.tag != nil  && !isHoleByHole{
                self.codeWhenClickToBackView()
                self.btnTrackShot.tag = tappedMarker.iconView!.tag
                self.btnTrackShot.setImage(#imageLiteral(resourceName: "edit_White"), for: .normal)
                self.lblShotNumber.isHidden = true
                self.btnHoleOut.isHidden = true
                self.lblEditShotNumber.isHidden = false
                self.btnClubs.isHidden = true
                self.btnSelectClubs.isHidden = true
                self.lblEditShotNumber.text = "\(tappedMarker.iconView!.tag+1)"
                if(isOnCourse){
                    if self.mapTimer.isValid{
                        self.mapTimer.invalidate()
                    }
                }
                for i in 0..<self.scoring[self.holeIndex].players.count{
                    if(self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) != nil){
                        self.tempPlayerData = (self.scoring[self.holeIndex].players[i].value(forKey: self.selectedUserId) as! NSDictionary).mutableCopy() as! NSDictionary
                        break
                    }
                }
            }else if(tappedMarker.userData as! String == "Swing"){
                var index = 0
                for i in 0..<self.shotViseCurve.count{
                    index = i
                    if(self.shotViseCurve[i].swingPosition.position == tappedMarker.position){
                        break
                    }
                }
                if swingData.count > index{
                    let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapShotPopupVC") as! MapShotPopupVC
                    viewCtrl.modalPresentationStyle = .overCurrentContext
                    viewCtrl.testStr = "Shubham"
                    viewCtrl.shotsDetails = self.swingData
                    viewCtrl.pageIndex = index
                    self.present(viewCtrl, animated: true, completion: nil)
                }else{
                    self.view.makeToast("No Swing")
                }
            }
        }else{
            tappedMarker = (tappedMarker == nil) ? nil : tappedMarker
        }
        return false
    }
    func showEditRelated(hide:Bool){
        self.btnNext.isHidden = hide
        self.btnPrev.isHidden = hide
        self.btnSelectClubs.isHidden = !hide
        self.btnClubs.isHidden = !hide
        self.btnPlayersStats.isHidden = hide
        self.btnLandedOnDropDown.isHidden = !hide
        self.btnLandedOnEdit.isHidden = !hide
        self.btnDeleteShot.isHidden = !hide
        self.btnDeleteLbl.isHidden = !hide
        if tappedMarker != nil && (tappedMarker.iconView!.tag+1 == self.shotViseCurve.count) && holeOutFlag{
            self.btnPenaltyShot.isHidden = true
            self.btnAddPenaltyLbl.isHidden = true
        }else{
            self.btnPenaltyShot.isHidden = false
            self.btnAddPenaltyLbl.isHidden = false
        }
        self.btnClose.isHidden = !hide
        self.btnCloseLbl.isHidden = !hide
        self.btnShareShot.isHidden = true
        
        if(playersButton.count > 1){
            self.btnMultiplayer.isHidden = hide
            self.btnMultiplayerLbl.isHidden = hide
        }else{
            self.btnMultiplayer.isHidden = true
            self.btnMultiplayerLbl.isHidden = true
        }
        if(hide){
            self.btnTrackShot.setImage(#imageLiteral(resourceName: "check_mark_fab"), for: .normal)
            self.btnTrackShot.backgroundColor = UIColor.glfWarmGrey
        }else{
            self.btnTrackShot.setImage((holeOutFlag ? #imageLiteral(resourceName: "edit_White"):#imageLiteral(resourceName: "track_Shot") ),for: .normal)
        }
    }
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        debugPrint(overlay)
        setColorToPolyline(color:UIColor.glfBluegreen)
        if let line = overlay as? GMSPolyline {
            debugPrint("Line Tag : \(line.userData ?? "jkfdals")")
            line.strokeColor = UIColor.glfWhite
        }
    }
    func setColorToPolyline(color:UIColor){
        for shot in shotViseCurve{
            shot.line.strokeColor = color
        }
    }
}
extension NewMapVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.mapView.isMyLocationEnabled = false
        let userLocation = locations.last
        userLocationForClub = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
}
extension NewMapVC : DropperDelegate{
    
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        if(clubsWithFullName.contains(contents)){
            self.btnSelectClubs.setTitle("\(contents)", for: .normal)
            self.btnSelectClubs.tag = path.row
            self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
            if isOnCourse{
                if self.isTracking{
                    self.btnTrackShot.backgroundColor = UIColor.glfWhite
                    self.btnTrackShot.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                }else{
                    self.btnTrackShot.backgroundColor = UIColor.glfBluegreen
                }
            }
            self.selectClubDropper.TableMenu.scrollToRow(at: path, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
}
extension NewMapVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.shotsDetails.isEmpty){
            return 1
        }else{
            return self.shotsDetails.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShotsDetailsCell", for: indexPath as IndexPath) as! ShotDetailsTableViewCell
        if(self.shotsDetails.isEmpty){
            noDataLabel.frame = cell.frame
            cell.addSubview(noDataLabel)
        }else{
            cell.backgroundColor = UIColor.glfBlack50
            noDataLabel.removeFromSuperview()
            var suffix = "yd"
            var prefix = "+"
            if(Constants.distanceFilter == 1){
                suffix = "m"
            }
            if(self.shotsDetails[indexPath.row].strokesGained < 0){
                prefix = ""
            }
            let endingPointWithColor = BackgroundMapStats.returnLandedOnFullName(data: self.shotsDetails[indexPath.row].endingPoint)
            if (self.penaltyShots[indexPath.row]){
                cell.initDesign(shot: "\(indexPath.row + 1)", club: "  ", distance: "   ", landedOn: "Penalty",color:UIColor.glfDustyRed ,sg: "    ")
            }else{
                cell.initDesign(shot: "\(indexPath.row + 1)", club: "\(self.shotsDetails[indexPath.row].club)", distance: "\(Int(self.shotsDetails[indexPath.row].distance / (Constants.distanceFilter == 1 ? Constants.YARD:1))) \(suffix)", landedOn: endingPointWithColor.0.localized(),color:endingPointWithColor.1 ,sg: "\(prefix)\(self.shotsDetails[indexPath.row].strokesGained.rounded(toPlaces: 2))")
            }
        }
        self.btnTotalShotsNumber.isHidden = !holeOutFlag
        self.btnShotRanking.isHidden = !holeOutFlag
        self.btnShareHoleStats.isHidden = !holeOutFlag
        
        if(holeOutFlag){
            let newI = self.shotCount - self.scoring[self.holeIndex].par
            self.updateStrokesButtonWithoutStrokes(strokes: newI, btn:self.btnTotalShotsNumber)
            let rankWithColor = BackgroundMapStats.setHoleShotDetails(par: self.scoring[self.holeIndex].par, shots: self.shotCount)
            self.btnShotRanking.setTitle("\(rankWithColor.0)", for: .normal)
            btnTotalShotsNumber.setTitle("  \(shotCount)  ", for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.glfOffWhite
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.glfOffWhite
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.0
    }
}

extension UIView{
    func animShow(){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func animHide(){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
}
extension NewMapVC: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        //annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        return annotationView
    }
}

@IBDesignable
class StackView: UIStackView {
    @IBInspectable private var color: UIColor?
    private var roundedRadius: Int?
    override var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            self.setNeedsLayout()
        }
    }
    
    public lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(rect: self.bounds).cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
        backgroundLayer.cornerRadius = 5
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
extension CLLocationCoordinate2D : Hashable{
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return fabs(lhs.longitude - rhs.longitude) < Double.ulpOfOne &&  fabs(lhs.latitude - rhs.latitude) < Double.ulpOfOne
    }
    public var hashValue: Int {
        get {
            return Int(Int(Float(self.latitude)) << 32)|Int(Float(self.longitude))
        }
    }
}
extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
