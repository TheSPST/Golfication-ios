//
//  NewHomeVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/02/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import Charts
import Google
import DeviceKit
import FirebaseInstanceID
import CoreData
import UserNotifications
enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
let context = CoreDataStorage.mainQueueContext()
class NewHomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomProModeDelegate{
    // MARK: - Set Outlets
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    var locationManager : CLLocationManager!
    @IBOutlet weak var notifStackView: UIStackView!
    @IBOutlet weak var proLabelProfileStackView: UIStackView!
    
    @IBOutlet weak var btnNotif: UIButton!
    @IBOutlet weak var btnProfileImage: UIButton!
    @IBOutlet weak var btnProfileBasic: UIButton!
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var btnContinue: UILocalizedButton!
    @IBOutlet weak var btnScoreDetail: UILocalizedButton!
    @IBOutlet weak var btnPlayFriends: UILocalizedButton!
    @IBOutlet weak var btnPractice: UIButton!
    @IBOutlet weak var btnScoreTab: UILocalizedButton!
    @IBOutlet weak var btnSGTab: UILocalizedButton!
    @IBOutlet weak var btnStatsTab: UILocalizedButton!
    @IBOutlet weak var btnGoPRO: UIButton!
    @IBOutlet weak var btnStartGame: UILocalizedButton!
//    @IBOutlet weak var btnPreOrder: UILocalizedButton!
    @IBOutlet weak var btnInvite: UILocalizedButton!
    
    @IBOutlet weak var ifDemolblLine: UILabel!
    @IBOutlet weak var ifDemoShowStackView: UIStackView!
    @IBOutlet weak var lblDemoStatsMySwing: UILabel!
    @IBOutlet weak var viewScoreStats: UIView!
//    @IBOutlet weak var viewMySwing: UIView!
    @IBOutlet weak var viewRecentGame: UIView!
    @IBOutlet weak var viewPreviousGame: UIView!
    @IBOutlet weak var viewNewGame: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewMoreStatScore: UIView!
    @IBOutlet weak var viewMoreStatSG: UIView!
    @IBOutlet weak var viewMoreStatClub: UIView!
    @IBOutlet weak var viewMyScoreTab: UIView!
    @IBOutlet weak var viewSGTab: CardView!
    @IBOutlet weak var viewClubTab: UIView!
    @IBOutlet weak var subViewClubImage: UIView!
    //    @IBOutlet weak var viewOnCourse: UIView!
    @IBOutlet weak var viewBecomePro: UIView!
    @IBOutlet weak var viewEddieHConstraint: NSLayoutConstraint!

//    @IBOutlet weak var viewInvite: UIView!
    
    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblContinueGolfName: UILabel!
    @IBOutlet weak var lblStartGolfName: UILabel!
    @IBOutlet weak var lblAvgRound: UILabel!
    @IBOutlet weak var lblClubStatSG: UILabel!
    @IBOutlet weak var lblClubStatAvgDist: UILabel!
    @IBOutlet weak var lblClubStatName: UILabel!
    @IBOutlet weak var lblPreGameGolfName: UILabel!
    @IBOutlet weak var lblPreGameTime: UILabel!
    @IBOutlet weak var lblPreGameScore: UILabel!
    @IBOutlet weak var lblPreGamePar: UILabel!
    @IBOutlet weak var lblPreGameThru: UILabel!
    @IBOutlet weak var lblPreGameStrokes: UILabel!
    @IBOutlet weak var lblProfileHomeCourse: UILabel!
    @IBOutlet weak var lblProfileHandicap: UILabel!
    @IBOutlet weak var lblProfileScoring: UILabel!
    @IBOutlet weak var lblPlayerMode: UILabel!
    @IBOutlet weak var lblTotalSwingTaken: UILabel!
    @IBOutlet weak var lblSwingScore: UILabel!
    @IBOutlet weak var lblBestSwingScore: UILabel!
    @IBOutlet weak var lblBestSwingClub: UILabel!
    
    @IBOutlet weak var playGolfStackView: UIStackView!
    @IBOutlet weak var scoreBarChartView: BarChartView!
    @IBOutlet weak var SGBarChartView: BarChartView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var swingSessionTabImgVw: UIImageView!
    @IBOutlet weak var mySwingTabView: UIView!

    // @IBOutlet weak var strokeGainedChartView: CardView!
    let progressView = SDLoader()
    
    // MARK: - Initialize Variables
    var holeShots = [HoleShotPar]()
    var dataArray = [Feeds]()
    var btnTabsArray = [UIButton]()
    var viewTabsArray = [UIView]()
    let kInnerShadowViewTag = 2639
    var holeType = Int()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var scoringMode = String()
    var players = NSMutableArray()
    var round_time : [String] = []
    var round_score : [Double] = []
    var filteredArray = [NSDictionary]()
    var strokesGainedValue :Double?
    var strokesGained :Double?
    var strokesCount : Double?
    var clubName :String?
    
    var profileHomeCourse: String?
    var selectedHomeGolfID: String = ""
    var selectedHomeGolfName: String = ""
    var mappedStr = ""
    var profileScoring: Int?
    
    var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
    var clubData = ["Dr":"Driver","w":"Wood","h":"Hybrid","i":"Iron","Pw":"Pitching Wedge","Gw":"Gap Wedge","Sw":"Sand Wedge","Lw":"Lob Wedge","Pu":"Putter"]
    var cardViewMArray = NSMutableArray()
    var cellIndex = 5
    var clubInsideGolfClub = [String]()
    
    var totalSwingCount = 0
    var swingMArray = NSMutableArray()
    var isDemoStats = false
    
    var cesPopUpView: UIView!
    var btnCesBuyNow: UIButton!
    var btnCancel:UIButton!
    var minAppVersion = String()

    // MARK: - inviteAction
    @IBAction func inviteAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ReferalViewCtrls") as! ReferalViewCtrls
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - preGameDetailAction
    @IBAction func preGameDetailAction(_ sender: Any) {
        if(dataArray.count > Int(0)){
            let matchID = dataArray[0].matchId!
            self.getScoreFromMatchDataScoring(matchId:matchID)
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Details")
    }
    
    // MARK: - upgradeAction
    @IBAction func upgradeAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Home"
        self.navigationController?.pushViewController(viewCtrl, animated: false)

    }
    
    // MARK: - playFriendsAction
    @IBAction func playFriendsAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Play Golf")
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - NotificationAction
    @IBAction func notifiAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - profileAction
    /*@IBAction func profileAction(_ sender: Any) {
//        Notification.sendLocaNotificatonNearByGolf()
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        viewCtrl.fromPublicProfile = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }*/
    
    // MARK: - tabClicked
    @objc func tabClicked(_ sender:UIButton){
        
        for i in 0..<btnTabsArray.count{
            
            btnTabsArray[i].setTitleColor(UIColor(rgb:0x939393), for: .normal)
            btnTabsArray[i].addBottomBorderWithColor(color: UIColor.white, width: 1.0)
            viewTabsArray[i].isHidden = true
            if sender.tag == i{
                btnTabsArray[i].setTitleColor(UIColor.glfBluegreen, for: .normal)
                btnTabsArray[i].addBottomBorderWithColor(color: UIColor.glfBluegreen, width: 1.0)
                viewTabsArray[i].isHidden = false
                if i == 0{
                    FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Scores")
                }else if i == 1{
                    FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Swings")
                }else{
                    FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Clubs")
                }
            }
        }
    }
    
    @IBAction func btnBuyNow(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Buy GX")
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    // MARK: - myScoreClick
    @IBAction func myScoreClick(_ sender: UIButton!) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let myScoreParentVC = storyboard.instantiateViewController(withIdentifier: "MyScoreParentVC") as! MyScoreParentVC
        self.navigationController?.pushViewController(myScoreParentVC, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: - clickStrocksGained
    @IBAction func clickStrocksGained(_ sender: UIButton!) {
        if swingMArray.count>0{
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "SwingSessionVC") as! SwingSessionVC
            viewCtrl.dataMArray = self.swingMArray
            viewCtrl.isDemoStats = isDemoStats
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    
    @IBAction func smartCaddieAction(_ sender: UIButton){
        // do other task
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "SmartCaddieVC") as! SmartCaddieVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: - continueAction
    @IBAction func continueAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Continue")
        let viewCtrl = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - startGameAction
    @IBAction func startGameAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Start")
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - goProAction
    @IBAction func goProAction(_ sender: Any) {
        
//        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
             FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Unlock")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Home"
        self.navigationController?.pushViewController(viewCtrl, animated: false)

        /*let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "HomeFreeProMemberVC") as! HomeFreeProMemberVC
         viewCtrl.modalPresentationStyle = .overCurrentContext
         present(viewCtrl, animated: true, completion: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(self.free30DaysProActivated(_:)), name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)*/
    }
    
    @objc func free30DaysProActivated(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
        
        self.btnUpgrade.isHidden = true
        self.proLabelProfileStackView.isHidden = true
        self.viewBecomePro.isHidden = true
        viewEddieHConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        self.btnProfileBasic.setTitle("PRO", for: .normal)
        self.btnProfileBasic.backgroundColor = UIColor(rgb: 0xFFC700)
        self.btnProfileBasic.setTitleColor(UIColor.white, for: .normal)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        locationUpdate()
        if let iosToken = (InstanceID.instanceID().token()){
            if Auth.auth().currentUser != nil{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["iosToken" :iosToken] as [AnyHashable:String])
            }else{
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GolficationGuideVC") as! GolficationGuideVC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
                return
            }
        }
        if Auth.auth().currentUser == nil{
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GolficationGuideVC") as! GolficationGuideVC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterResponseEditRound(_:)), name: NSNotification.Name(rawValue: "editRoundHome"), object: nil)
        
        //grodvLE1bLdGBRNrA97R0DBlrSv2 -Alish
        //        Notification.sendNotification(reciever: "YCUJckKEhXWqbFGtqfRfpiOzBdp2", message: "Amit just finished a round at Qutab.", type: "8", category: "finishedGame", matchDataId: "-LEEX_IIesOFOyZWkiu-", feedKey:"")
        
        self.feedTableView.isHidden = true
        self.view.layoutIfNeeded()
        // ------------------------ Set User Name & Profile Image ------------------------------
        lblUserName.text = "Hi".localized() + " " + (Auth.auth().currentUser?.displayName ?? "Guest")
        if Auth.auth().currentUser?.photoURL == nil{
            btnProfileImage.setBackgroundImage(UIImage(named:"you"), for: .normal)
        }
        else{
            btnProfileImage.sd_setBackgroundImage(with: Auth.auth().currentUser?.photoURL ?? URL(string:""), for: .normal, completed: nil)
        }
        //-------------------------------------------------------------------
        //---------------------------- Update Versin details to Firebase --------------------------
        //https://github.com/dennisweissmann/DeviceKit
        let versionInfo = NSMutableDictionary()
        versionInfo.setObject("iOS \(UIDevice.current.systemVersion)", forKey: "osVersion" as NSCopying)
        versionInfo.setObject("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!) Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)", forKey: "appVersion" as NSCopying)
        versionInfo.setObject("\(Device())", forKey: "model" as NSCopying)
        
        let versionDetails = ["info":versionInfo]
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(versionDetails)
        
        //-----------------------------------------------------------------------------------------
        btnTabsArray = [btnScoreTab, btnSGTab, btnStatsTab]
        viewTabsArray = [viewMyScoreTab, viewSGTab, viewClubTab]
        for i in 0..<btnTabsArray.count{
            btnTabsArray[i].tag = i
            btnTabsArray[i].setTitleColor(UIColor(rgb:0x939393), for: .normal)
            btnTabsArray[i].addTarget(self, action: #selector(self.tabClicked(_:)), for: .touchUpInside)
            
            btnTabsArray[i].setCorner(color: UIColor.clear.cgColor)
            viewTabsArray[i].isHidden = true
        }
        btnTabsArray[0].setTitleColor(UIColor.glfBluegreen, for: .normal)
        btnTabsArray[0].addBottomBorderWithColor(color: UIColor.glfBluegreen, width: 1.0)
        viewTabsArray[0].isHidden = false

        self.btnUpgrade.isHidden = true
        
//        let gestureViewProfile = UITapGestureRecognizer(target: self, action:  #selector (self.profileAction (_:)))
//        viewProfile.addGestureRecognizer(gestureViewProfile)
        
//        let gestureMySwing = UITapGestureRecognizer(target: self, action:  #selector (self.mySwingAction (_:)))
//        viewMySwing.addGestureRecognizer(gestureMySwing)
        
        let gestureMyScoreTab = UITapGestureRecognizer(target: self, action:  #selector (self.myScoreClick (_:)))
        viewMoreStatScore.addGestureRecognizer(gestureMyScoreTab)
        
        let gestureSGTab = UITapGestureRecognizer(target: self, action:  #selector (self.clickStrocksGained (_:)))
        viewMoreStatSG.addGestureRecognizer(gestureSGTab)
        
        let gestureClubTab = UITapGestureRecognizer(target: self, action:  #selector (self.smartCaddieAction (_:)))
        viewMoreStatClub.addGestureRecognizer(gestureClubTab)
        
        let gestureNotif = UITapGestureRecognizer(target: self, action:  #selector (self.notifiAction (_:)))
        notifStackView.addGestureRecognizer(gestureNotif)
        
        viewRecentGame.isHidden = true
        viewPreviousGame.isHidden = true
        viewNewGame.isHidden = true
        
//        let rndom = Int(arc4random_uniform(100))
//        viewInvite.isHidden = rndom < 40 ? false : true
        btnPractice.isHidden = true

        self.setInitialUI()
        
        self.getStrokesGainedFirebaseData()
        
        //        let promocodeArr = ["GOLFYKQ98","GOLFYKR34","GOLFYKS56","GOLFYKT20","GOLFYKT41","GOLFYKT52","GOLFYKU29","GOLFYKU32","GOLFYKU34","GOLFYKU45","GOLFYKZ2","GOLFYLA37","GOLFYLA91","GOLFYLB40","GOLFYLB42","GOLFYLB80","GOLFYLC72","GOLFYLC94","GOLFYLC96","GOLFYLD14","GOLFYLD17","GOLFYLE33","GOLFYLF77","GOLFYLG22","GOLFYLG39","GOLFYLH65","GOLFYLH92","GOLFYLI84","GOLFYLJ0","GOLFYLJ28","GOLFYLK27","GOLFYLK45","GOLFYLK51","GOLFYLM17","GOLFYLM20","GOLFYLN12","GOLFYLN28","GOLFYLN43","GOLFYLN75","GOLFYLQ71","GOLFYLR65","GOLFYLT0","GOLFYLT62","GOLFYLU37","GOLFYLU97","GOLFYLV61","GOLFYLW8","GOLFYLX20","GOLFYLX46","GOLFYLY18"]
        //        for data in promocodeArr{
        //            BackgroundMapStats.getDynamicLinkFromPromocode(code: data)
        //        }
        
//                self.FindUser()
//        setCesPopupCount()
        getMinIOSVersion()
        FBSomeEvents.shared.singleParamFBEvene(param: "View Home")
    }
    func getMinIOSVersion(){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "appVersion/iOS/version") { (snapshot) in
            if(snapshot.value != nil){
                self.minAppVersion = snapshot.value as! String
            }
            DispatchQueue.main.async(execute: {
                //--------- Check if new version available -------------------------
                let currentAppVer =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                if currentAppVer < self.minAppVersion{
                   NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
                   self.checkNewVersion()
                }
                //-------------------------------------------------------------------------
            })
        }
    }
    
    @objc func appDidEnterForeground(){
          checkNewVersion()
    }
    
    func checkNewVersion(){
        _ = try? self.isUpdateAvailable { (newVersion, update, error) in
            if let error = error {
                debugPrint(error)
            }
            else if let update = update {
                if update{
                    if !(Auth.auth().currentUser!.email == "spsttomar@gmail.com"){
                        self.showNewVersionPopup(newVersion:newVersion!)
                        
                        /*if UserDefaults.standard.object(forKey: "isNewVersion") as? Bool != nil{
                         let isNewVersion = UserDefaults.standard.object(forKey: "isNewVersion") as! Bool
                         if !isNewVersion{
                         self.showNewVersionPopup(newVersion:newVersion!)
                         }
                         }
                         else{
                         self.showNewVersionPopup(newVersion:newVersion!)
                         }*/
                    }
                }
            }
        }
    }
    
    func showNewVersionPopup(newVersion: String) {
        
        //UserDefaults.standard.set(true, forKey: "isNewVersion")
        //UserDefaults.standard.synchronize()
        
        let alertMessage = "A new version of Golfication is available, Please update to version " + newVersion
        
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/in/app/golfication/id1216612467?mt=8"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        //let skipBtn = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        //})
        alert.addAction(okBtn)
        //alert.addAction(skipBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setCesPopupCount(){
        var cesPopupCount = 0
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "cesPopupCount") { (snapshot) in
            if(snapshot.value != nil){
                cesPopupCount = snapshot.value as! Int
                if cesPopupCount == 1{
                    cesPopupCount = 2
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["cesPopupCount":2] as [AnyHashable:Any])
                }
                else{
                    cesPopupCount = 0
                }
            }
            else{
                cesPopupCount = 1
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["cesPopupCount":1] as [AnyHashable:Any])
            }
            
            DispatchQueue.main.async(execute: {
                if UserDefaults.standard.object(forKey: "isNewUser") as? Bool != nil{
                    let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
                    if (newUser && (cesPopupCount == 1 || cesPopupCount == 2)){
                        self.setupCesUI()
                    }
                }
            })
        }
    }
    func setupCesUI(){
        if cesPopUpView != nil{
            cesPopUpView.removeFromSuperview()
        }
        self.cesPopUpView = (Bundle.main.loadNibNamed("CesPopUpView", owner: self, options: nil)![0] as! UIView)
        self.cesPopUpView.frame = self.view.bounds
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self.cesPopUpView)

        btnCesBuyNow = (cesPopUpView.viewWithTag(222) as! UIButton)
        btnCesBuyNow.addTarget(self, action: #selector(self.buyCesAction(_:)), for: .touchUpInside)
        btnCesBuyNow.layer.cornerRadius = 3.0
        
        btnCancel = (cesPopUpView.viewWithTag(333) as! UIButton)
        btnCancel.addTarget(self, action: #selector(self.cancelCesAction(_:)), for: .touchUpInside)
    }
    @objc func cancelCesAction(_ sender: UIButton!) {
        cesPopUpView.removeFromSuperview()
    }
    @objc func buyCesAction(_ sender: UIButton) {
        cesPopUpView.removeFromSuperview()

        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.title = ""
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }

    // Get user details which have Pro membership
//        func FindUser(){
//            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData") { (snapshot) in
//                self.progressView.show(atView: self.view, navItem: self.navigationItem)
//                var userData = NSMutableDictionary()
//                if(snapshot.value != nil){
//                    userData = snapshot.value as! NSMutableDictionary
//                    for (key,value) in userData{
//                        if let v = value as? NSMutableDictionary{
//                            //(((v.value(forKey: "deviceInfo") as? NSMutableDictionary) != nil))
//                            if ((v.value(forKey: "iosToken")) != nil){
////                                debugPrint((v.value(forKey: "deviceInfo") as! NSMutableDictionary).value(forKey: "OAD")as? NSMutableDictionary)
////                                debugPrint("ios Key: \(key)")
////                                debugPrint("OAD Key: \((v.value(forKey: "OAD") as? NSMutableDictionary))")
//                                if let pro = v.value(forKey: "proMembership") as? NSMutableDictionary{
////                                    if pro.value(forKey: "productID") as? String == "pro_subscription_trial_monthly" || pro.value(forKey: "productID") as? String == "pro_subscription_trial_yearly" || pro.value(forKey: "productID") as? String == "pro_subscription_yearly" || pro.value(forKey: "productID") as? String == "pro_subscription_monthly"{
//                                        debugPrint("ios Key: \(key)")
//                                        debugPrint("proMembership",pro)
//
////                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                DispatchQueue.main.async(execute: {
//                    self.progressView.hide(navItem: self.navigationItem)
//                })
//            }
//        }
    
    func getGolficationXVersion(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "firmwareVersion") { (snapshot) in
            let firmware = snapshot.value as! NSMutableDictionary
            DispatchQueue.main.async(execute: {
                if let vNumber = firmware.value(forKey: "version") as? Int{
                    Constants.firmwareVersion = vNumber
                }
                if let canSkip = firmware.value(forKey: "canSkip") as? Bool{
                    Constants.canSkip = canSkip
                }
                if let fileName = firmware.value(forKey: "fileName") as? String{
                    Constants.fileName = fileName
                }
            })
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
    
    func getClubDataFromFirebase(isShow:Bool){
        if Constants.clubWithMaxMin.count == 0{
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "clubsData") { (snapshot) in
                let clubDataDict = snapshot.value as! [String:NSMutableDictionary]
                DispatchQueue.main.async(execute: {
                    Constants.clubWithMaxMin.removeAll()
                    for (key, value) in clubDataDict{
                        Constants.clubWithMaxMin.append((name: key, max: value.value(forKey: "max") as! Int, min: value.value(forKey: "min") as! Int))
                    }
                    Constants.clubWithMaxMin.append((name: "Pu", max: 22, min: 1))
                    self.setSGAndSmartCaddieData(isShow:isShow)
                })
            }
        }else{
            self.setSGAndSmartCaddieData(isShow:isShow)
        }
    }
    
    func updateCard4(path:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: path) { (snapshot) in
            var dataDic = NSDictionary()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? NSDictionary)!
            }
            DispatchQueue.main.async( execute: {
                if let card4 = dataDic["card4"] as? NSDictionary{
                    self.round_score = []
                    self.round_time = []
                    var allRounds = card4.allValues
                    allRounds = allRounds.sorted{
                        (($1 as AnyObject).value(forKey: "timestamp")) as! Double > (($0 as AnyObject).value(forKey: "timestamp")) as! Double
                    }
                    var count = 0
                    for round in allRounds.reversed() {
                        let score:Double! = (round as AnyObject).value(forKey: "score") as? Double
                        let timeStamp:Double! = (round as AnyObject).value(forKey: "timestamp") as? Double
                        let today = NSDate(timeIntervalSince1970:(timeStamp)!/1000)
                        if(score > 0) && (count < 10){
                            self.round_score.append(score)
                            self.round_time.append(today.toString(dateFormat: "dd-MMM"))
                            count += 1
                        }else if(count > 10 ){
                            break
                        }
                    }
                }
                let demolbl = DemoLabel()
                demolbl.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
                demolbl.center = ((self.scoreBarChartView.superview)?.center)!
                self.scoreBarChartView.addSubview(demolbl)
                self.scoreBarChartView.setBarChart(dataPoints: self.round_time.reversed(), values: self.round_score.reversed(), chartView: self.scoreBarChartView, color: UIColor.glfSeafoamBlue, barWidth: 0.2, leftAxisMinimum: 0, labelTextColor: UIColor.glfWarmGrey, unit: "", valueColor: UIColor.glfWarmGrey)
            })
        }
    }
    
    func getClubName(club:String)->String{
        var clubToShow = String()
        if(club.count > 0){
            if let fullName = clubData[club]{
                clubToShow =  fullName
            }
            else if let fullName = clubData["\(club.last!)"]{
                clubToShow =  "\(club.first!) \(fullName)"
            }
        }
        return clubToShow
    }
    
    func setSGAndSmartCaddieData(isShow:Bool) {
        let clubDict = self.transferDataIntoClasses(myDataArray: self.filteredArray)
        if totalCaddie == 0{
            
        }
        self.createSmartDataWith(clubDict: clubDict)
        strokesGainedData.removeAll()
        strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
        var smartCaddieAvg = [(clubName: String,clubTotalDistance: Double,clubStrokesGained: Double,clubDistanceArray:[Double])]()
        for data in Constants.catagoryWise{
            self.strokesGainedData.append((data,0.0,0.0,0,0.0))
            
        }
        for data in Constants.allClubs{
            smartCaddieAvg.append((data,0.0,0.0,[0.0]))
        }
        for i in 0..<Constants.allClubs.count{
            var distanceArray = [Double]()
            var value = 0.0
            var strokesGained = 0.0
            var index = 0
            for j in 0..<clubDict.count{
                if(smartCaddieAvg[i].clubName  == clubDict[j].0){
                    value = smartCaddieAvg[i].clubTotalDistance
                    strokesGained = smartCaddieAvg[i].clubStrokesGained
                    let clubClass = clubDict[j].1 as Club
                    value += clubClass.distance
                    distanceArray.append(clubClass.distance)
                    strokesGained += clubClass.strokesGained
                    index = i
                    smartCaddieAvg[index] = (clubDict[j].0,value,strokesGained,distanceArray)
                }
            }
        }
        var dataPointsClub = [String]()
        var strokeGainedAvg = [Double]()
        var clubDistance = [Double]()
        for i in 0..<smartCaddieAvg.count{
            if(smartCaddieAvg[i].1 != 0){
                dataPointsClub.append(smartCaddieAvg[i].clubName)
                strokeGainedAvg.append((smartCaddieAvg[i].clubStrokesGained)/Double((smartCaddieAvg[i].clubDistanceArray).count))
                let sum = smartCaddieAvg[i].clubDistanceArray.reduce(0,+)
                clubDistance.append(sum/Double((smartCaddieAvg[i].clubDistanceArray).count))
            }
        }
        if !strokeGainedAvg.isEmpty{
            let bestClubIndex = strokeGainedAvg.firstIndex(of: strokeGainedAvg.max()!)!
            self.lblClubStatAvgDist.text = "\(Int(clubDistance[bestClubIndex].rounded())) \(Constants.distanceFilter == 1 ? "meter":"yards")"
            self.lblClubStatSG.text = "\((strokeGainedAvg[bestClubIndex]).rounded(toPlaces: 2))"
            self.lblClubStatName.text = dataPointsClub[bestClubIndex]
        }
        
        // StroesGaned BARGraph
        for i in 0..<clubDict.count{
            let clubClass = clubDict[i].1 as Club
            if(clubClass.type >= 0 && clubClass.type < 4){
                self.strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                self.strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                self.strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                self.strokesGainedData[clubClass.type].clubCount += 1
            }
        }
        // set SG data
        var dataPoints = [String]()
        var dataValues = [Double]()
        for data in self.strokesGainedData{
            dataPoints.append(data.clubType.localized())
            dataValues.append((data.clubStrokesGained / Double(totalCaddie)).rounded(toPlaces: 2))
        }
        let demolbl = DemoLabel()
        demolbl.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        demolbl.center = ((self.SGBarChartView.superview)?.center)!
        
        let demoClublbl = DemoLabel()
        demoClublbl.frame = CGRect(x: 10, y: 0, width: 200, height: 40)
        demoClublbl.textAlignment = .left
        
        if(isShow){
            self.SGBarChartView.addSubview(demolbl)
            self.viewClubTab.addSubview(demoClublbl)
        }
        self.progressView.hide(navItem: self.navigationItem)
        SGBarChartView.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: SGBarChartView, color: UIColor.glfSeafoamBlue, barWidth: 0.4,valueColor: UIColor.glfWarmGrey.withAlphaComponent(0.5))
        SGBarChartView.leftAxis.gridColor = UIColor.glfWarmGrey.withAlphaComponent(0.25)
        SGBarChartView.leftAxis.labelTextColor  = UIColor.glfWarmGrey.withAlphaComponent(0.5)
        SGBarChartView.xAxis.labelTextColor = UIColor.glfWarmGrey.withAlphaComponent(0.5)
        SGBarChartView.isUserInteractionEnabled = false
        SGBarChartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: 10.0)!
    }
    
    func createSmartDataWith(clubDict:[(String,Club)]){
        var clubWithAllDistance = [(club:String,arr:[Double])]()
        for club in Constants.allClubs{
            clubWithAllDistance.append((club: club, arr: [Double()]))
        }
        for data in clubDict{
            if let index = self.clubInsideGolfClub.index(of: data.0) {
                clubWithAllDistance[index].arr.append(data.1.distance)
            }
        }
        for i in 0..<clubWithAllDistance.count{
            clubWithAllDistance[i].arr = clubWithAllDistance[i].arr.sorted()
            clubWithAllDistance[i].arr = clubWithAllDistance[i].arr.removeDuplicates()
            clubWithAllDistance[i].arr.remove(at: 0)
            if clubWithAllDistance[i].arr.count > 9{
                let remove:Int = clubWithAllDistance[i].arr.count/10
                clubWithAllDistance[i].arr.removeFirst(remove)
                clubWithAllDistance[i].arr.removeLast(remove)
                for j in 0..<Constants.clubWithMaxMin.count where Constants.clubWithMaxMin[j].name == clubWithAllDistance[i].club{
                    Constants.clubWithMaxMin[j].max  = Int(clubWithAllDistance[i].arr.max()!)
                    Constants.clubWithMaxMin[j].min  = Int(clubWithAllDistance[i].arr.min()!)
                }
            }
        }
    }
    var totalCaddie = Int()
    func transferDataIntoClasses(myDataArray:[NSDictionary])->[(String,Club)]{
        var clubDict = [(String,Club)]()
        self.totalCaddie = 0
        for i in 0..<myDataArray.count{
            if let smartCaddieDic = ((myDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                self.totalCaddie += 1
                for key in Constants.allClubs{
                    let keysArray = smartCaddieDic.value(forKeyPath: "\(key)")
                    if((keysArray) != nil){
                        let valueArray = keysArray as! NSArray
                        for j in 0..<valueArray.count{
                            let clubData = Club()
                            if let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing") as? Double{
                                clubData.backswing = backSwing
                            }
                            if let distance = (valueArray[j] as AnyObject).object(forKey: "distance") as? Double{
                                clubData.distance = distance
                            }
                            var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                            if let strk = (valueArray[j] as AnyObject).object(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double{
                                strokesGained = strk
                            }
                            clubData.strokesGained = strokesGained
                            
                            if let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore") as? Double{
                                clubData.swingScore = swingScore
                            }
                            if let type = (valueArray[j] as AnyObject).object(forKey: "type") as? Int{
                                clubData.type = type
                            }
                            if let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity") as? Double{
                                clubData.proximity = proximity
                            }
                            if let holeout = (valueArray[j] as AnyObject).object(forKey: "holeout") as? Double{
                                clubData.holeout = holeout
                            }
                            clubWiseArray.append(clubData)
                            clubDict.append((key,clubData))
                        }
                    }
                }
            }
        }
        return clubDict
    }
    func setProLockedUI(targetView:UIView?) {
        
        let customProModeView = CustomProModeView()
        customProModeView.frame =  CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!-16-4, height: (targetView?.frame.size.height)!)
        customProModeView.delegate = self
        customProModeView.btnDevice.isHidden = true
        customProModeView.btnPro.isHidden = false
        
        customProModeView.proImageView.frame.size.width = 45
        customProModeView.proImageView.frame.size.height = 45
        customProModeView.proImageView.frame.origin.x = (customProModeView.frame.size.width)-45-4
        customProModeView.proImageView.frame.origin.y = 0
        
        customProModeView.label.frame.size.width = (customProModeView.bounds.width)-80
        customProModeView.label.frame.size.height = 50
        customProModeView.label.center = CGPoint(x: (customProModeView.bounds.midX), y: (customProModeView.bounds.midY)-40)
        customProModeView.label.backgroundColor = UIColor.clear
        
        customProModeView.btnPro.frame.size.width = (customProModeView.label.frame.size.width/2)+10
        customProModeView.btnPro.frame.size.height = 40
        customProModeView.btnPro.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 20)
        
        customProModeView.titleLabel.frame = CGRect(x: customProModeView.frame.origin.x + 16, y: customProModeView.frame.origin.y + 16, width: customProModeView.bounds.width, height: 30)
        customProModeView.titleLabel.backgroundColor = UIColor.clear
        customProModeView.titleLabelText = ""
        
        customProModeView.labelText = "Pro members only"
        customProModeView.btnTitle = "Become a Pro"
        //customProModeView.backgroundColor = UIColor.clear
        customProModeView.backgroundColor = UIColor(red:110.0/255.0, green:185.0/255.0, blue:165.0/255.0, alpha:1.0)
        
        targetView?.addSubview(customProModeView)
    }
    
    func proLockBtnPressed(button:UIButton) {
//        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Home"
        self.navigationController?.pushViewController(viewCtrl, animated: false)

        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: - mySwingAction
    @objc func mySwingAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.title = "Golfication X"
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - setInitialUI
    func setInitialUI(){

        swingSessionTabImgVw.setCircleWithColor(frame: swingSessionTabImgVw.frame, color: UIColor.glfBluegreen.cgColor)
        
//        btnPreOrder.layer.cornerRadius = 3.0
//        btnPreOrder.setTitle(" " + "Pre order Now!".localized() + " ", for: .normal)
        //        viewOnCourse.layer.cornerRadius = 3.0
        
        lblAvgRound.setCorner(color: UIColor(rgb:0x939393).cgColor)
        
        viewMoreStatScore.layer.borderWidth = 1.0
        viewMoreStatScore.layer.borderColor = UIColor.glfBluegreen.cgColor
        viewMoreStatScore.layer.cornerRadius = 3.0
        
        viewMoreStatSG.layer.borderWidth = 1.0
        viewMoreStatSG.layer.borderColor = UIColor.glfBluegreen.cgColor
        viewMoreStatSG.layer.cornerRadius = 3.0
        
        viewMoreStatClub.layer.borderWidth = 1.0
        viewMoreStatClub.layer.borderColor = UIColor.glfBluegreen.cgColor
        viewMoreStatClub.layer.cornerRadius = 3.0
        
        btnNotif.layer.cornerRadius = btnNotif.frame.size.height/2
        
        btnGoPRO.layer.borderWidth = 1.0
        btnGoPRO.layer.borderColor = UIColor.darkGray.cgColor
        btnGoPRO.layer.cornerRadius = 3.0
        
        btnProfileImage.layer.borderWidth = 3.0
        btnProfileImage.layer.borderColor = UIColor.white.cgColor
        btnProfileImage.layer.cornerRadius = btnProfileImage.frame.size.height/2
        btnProfileImage.layer.masksToBounds = true
        
        subViewClubImage.layer.borderWidth = 0.5
        subViewClubImage.layer.borderColor = UIColor.glfBluegreen.cgColor
        subViewClubImage.layer.masksToBounds = true
        
        btnProfileBasic.layer.cornerRadius = 3.0
        btnUpgrade.layer.cornerRadius = 3.0
        
        btnContinue.setTitle(" " + "Continue".localized() + " ", for: .normal)
        btnContinue.layer.borderWidth = 1.0
        btnContinue.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnContinue.layer.cornerRadius = 3.0
        
        btnScoreDetail.layer.borderWidth = 1.0
        btnScoreDetail.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnScoreDetail.layer.cornerRadius = 3.0
        
        btnStartGame.setTitle(" " + "Start".localized() + " ", for: .normal)
        btnStartGame.layer.borderWidth = 1.0
        btnStartGame.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnStartGame.layer.cornerRadius = 3.0
        
        viewRecentGame.layer.borderWidth = 1.0
        viewRecentGame.layer.borderColor = UIColor(rgb:0xE6E6E6).cgColor
        viewRecentGame.layer.cornerRadius = 3.0
        
        viewNewGame.layer.borderWidth = 1.0
        viewNewGame.layer.borderColor = UIColor(rgb:0xE6E6E6).cgColor
        viewNewGame.layer.cornerRadius = 3.0
        
        viewPreviousGame.layer.borderWidth = 1.0
        viewPreviousGame.layer.borderColor = UIColor(rgb:0xE6E6E6).cgColor
        viewPreviousGame.layer.cornerRadius = 3.0
        
        btnPlayFriends.setTitle("  " + "PLAY GOLF".localized(), for: .normal)
        let gradient = CAGradientLayer()
//        gradient.frame = btnPlayFriends.bounds
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: btnPlayFriends.frame.size.width, height: btnPlayFriends.frame.size.height)
        gradient.colors = [UIColor(rgb: 0x2E6594).cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnPlayFriends.layer.insertSublayer(gradient, at: 0)
        btnPlayFriends.layer.cornerRadius = 3.0
        btnPlayFriends.layer.masksToBounds = true
        
        btnPractice.layer.cornerRadius = 3.0
        btnPractice.layer.masksToBounds = true
        
        btnInvite.setTitle(" " + "Invite Now".localized() + " ", for: .normal)
        
        btnInvite.layer.cornerRadius = 3.0
    }
    var sharedInstance: BluetoothSync!
    // MARK: - startGameAction
    @IBAction func practiceAction(_ sender: Any) {
//        sharedInstance = BluetoothSync.getInstance()
//        sharedInstance.delegate = self
//        sharedInstance.initCBCentralManager()
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Home Practice")
        let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "ScanningVC") as! ScanningVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
//    func didUpdateState(_ state: CBManagerState) {
//        debugPrint("state== ",state)
//        var alert = String()
//
//        switch state {
//        case .poweredOff:
//            alert = "Make sure that your bluetooth is turned on."
//            break
//        case .poweredOn:
//            debugPrint("State : Powered On")
//
//            if Constants.macAddress != nil{
//                let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "ScanningVC") as! ScanningVC
//                self.navigationController?.pushViewController(viewCtrl, animated: true)
//                sharedInstance.delegate = nil
//            }
//            else{
//                let alertVC = UIAlertController(title: "Alert", message: "Please finish the device setup first.", preferredStyle: UIAlertControllerStyle.alert)
//                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
////                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
////                    let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
////                    viewCtrl.fromPublicProfile = false
////                    self.navigationController?.pushViewController(viewCtrl, animated: true)
//                    self.getGolfBagUpdate()
//                })
//                alertVC.addAction(action)
//                self.present(alertVC, animated: true, completion: nil)
//            }
//            return
//
//        case .unsupported:
//            alert = "This device is unsupported."
//            break
//        default:
//            alert = "Try again after restarting the device."
//            break
//        }
//
//        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
//        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
//            self.dismiss(animated: true, completion: nil)
//            self.sharedInstance.delegate = nil
//        })
//        alertVC.addAction(action)
//        self.present(alertVC, animated: true, completion: nil)
//    }
    // MARK: - golfBaagAction
    func getGolfBagUpdate(){

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            var golfBagArray = NSMutableArray()
            var selectedClubs = NSMutableArray()
            if let glfbag = snapshot.value as? NSMutableArray{
                golfBagArray = glfbag
                for i in 0..<golfBagArray.count{
                    if let dict = golfBagArray[i] as? NSDictionary{
                        selectedClubs.add(dict)
                        for data in Constants.clubWithMaxMin where data.name == dict.value(forKey: "clubName") as! String{
                            if (data.name).contains("Pu"){
                                dict.setValue(30, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":30])
                            }else if(dict.value(forKey: "avgDistance") == nil){
                                let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                dict.setValue(avgDistance, forKey: "avgDistance")
                                golfBagArray[i] = dict
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":avgDistance])
                            }
                            
                        }
                    }
                    else{
                        let tempArray = snapshot.value as! NSMutableArray
                        var golfBagData = [String: NSMutableArray]()
                        for i in 0..<tempArray.count{
                            let golfBagDict = NSMutableDictionary()
                            golfBagDict.setObject("", forKey: "brand" as NSCopying)
                            golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                            golfBagDict.setObject(tempArray[i], forKey: "clubName" as NSCopying)
                            golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                            golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                            golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                            for data in Constants.clubWithMaxMin where data.name == tempArray[i] as! String{
                                if (data.name).contains("Pu"){
                                    golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                                }else{
                                    let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                    golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                                }
                            }
                            golfBagArray.replaceObject(at: i, with: golfBagDict)
                            golfBagData = ["golfBag": golfBagArray]
                            
                            selectedClubs.add(golfBagDict)
                        }
                        if golfBagData.count>0{
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                        }
                        break
                    }
                }
            }
            else{
                let golfBagArray = NSMutableArray()
                golfBagArray.addObjects(from: ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"])
                var golfBagData = [String: NSMutableArray]()
                selectedClubs = NSMutableArray()
                let tempArray = NSMutableArray()
                
                for i in 0..<golfBagArray.count{
                    let golfBagDict = NSMutableDictionary()
                    golfBagDict.setObject("", forKey: "brand" as NSCopying)
                    golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                    golfBagDict.setObject(golfBagArray[i], forKey: "clubName" as NSCopying)
                    golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                    golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                    golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                    for data in Constants.clubWithMaxMin where data.name == golfBagArray[i] as! String{
                        if (data.name).contains("Pu"){
                            golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                        }else{
                            let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                            golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                        }
                    }
                    tempArray.insert(golfBagDict, at: i)
                    golfBagData = ["golfBag": tempArray]
                    
                    selectedClubs.add(golfBagDict)
                }
                if golfBagData.count>0{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                Constants.tempGolfBagArray = NSMutableArray()
                Constants.tempGolfBagArray = NSMutableArray(array: golfBagArray)
                let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
                debugPrint("golfBagArray.count:",golfBagArray.count)
                viewCtrl.golfBagArr = golfBagArray
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            })
        }
    }
    // MARK: - mySwingAction
    @IBAction func mySwingBtnAction(_ sender: UIButton) {
        self.mySwingAction(sender)
    }
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(editWithTag != nil){
            editWithTag = nil
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "editRoundHome"))
    }
    
    // MARK: - networkStatusChanged
    @objc func networkStatusChanged(_ notification: NSNotification) {
        let userInfo = (notification as NSNotification).userInfo
        if userInfo!["Status"] as? String == "Offline"{
            _ = Timer.scheduledTimer(withTimeInterval: 7, repeats: false, block: { (timer) in
                let alert = UIAlertController(title: "Request Timeout.", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    debugPrint("OK Alert: \(alert?.title ?? "")")
                    timer.invalidate()
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        //----------------- Check Internet Connection ---------------------------------
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.fromNewUserProfile{
            appDelegate.fromNewUserProfile = false
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
            viewCtrl.source = "NewUser"
            self.navigationController?.pushViewController(viewCtrl, animated: false)
            NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
            Reach().monitorReachabilityChanges()
        }
        storeAllMacAddress()
        // ---------------- Google Analytics --------------------------------------
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Home Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        getUserDataFromFireBase()
        self.getGolficationXVersion()
    }
    
    func storeAllMacAddress(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "golficationX") { (snapshot) in
            var golficationX = NSDictionary()
            if snapshot.value != nil{
                golficationX = snapshot.value as! NSDictionary
            }
            DispatchQueue.main.async(execute: {
                if golficationX.count>0{
                    Constants.allMacAdrsDic.addEntries(from: golficationX as! [AnyHashable : Any])
                }
            })
        }
    }
    
    // MARK: getStrokesGainedFirebaseData
    func getStrokesGainedFirebaseData(){
        Constants.strokesGainedDict.removeAll()
        let group = DispatchGroup()
        for i in 0..<Constants.strkGainedString.count{
            group.enter()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: Constants.strkGainedString[i]) { (snapshot) in
                Constants.strokesGainedDict.append(snapshot.value as! NSMutableDictionary)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            debugPrint("strockesGainedReaded")
        }
    }
    // MARK: getUserDataFromFireBase
    func getUserDataFromFireBase() {
        Constants.matchId.removeAll()
        var hcp : Double!
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            if(snapshot.childrenCount > 0){
                var userData = NSDictionary()
                userData = snapshot.value as! NSDictionary
                if (userData.value(forKey: "handed") == nil){
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
                    Constants.handed = "Right"
                }
                if (userData.value(forKey: "handicap") == nil){
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
                    Constants.handicap = "-"
                }
                if let unit = userData.object(forKey: "unit") as? Int{
                    Constants.distanceFilter = unit
                    if let counter = NSManagedObject.findAllForEntity("DistanceUnitEntity", context: context){
                        counter.forEach { counter in
                            context.delete(counter as! NSManagedObject)
                        }
                    }
                    if let distanceUnit = NSEntityDescription.insertNewObject(forEntityName: "DistanceUnitEntity", into: context) as? DistanceUnitEntity{
                        distanceUnit.unit = Int16(unit)
                        CoreDataStorage.saveContext(context)
                    }
                }
                if let nam = userData.object(forKey: "name") as? String{
                    if Auth.auth().currentUser!.displayName == nil || Auth.auth().currentUser!.displayName == ""{
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = nam
                        changeRequest?.commitChanges { (error) in}
                    }
                }
                if let notification = userData.object(forKey: "notification") as? Int{
                    Constants.onCourseNotification = notification
                }
                if let strokesGained = userData.object(forKey: "strokesGained") as? Int{
                    Constants.skrokesGainedFilter = strokesGained
                }
                if let device = userData.object(forKey: "device") as? Bool{
                    Constants.isDevice = device
                }
                if let trial = userData.value(forKey: "trial") as? Bool{
                    Constants.trial = trial
                }
                if let handed = userData.value(forKey: "handed") as? String{
                    Constants.handed = handed
                }
                if let deviceInfo = userData.value(forKey: "deviceInfo") as? NSMutableDictionary{
                    if let setup = deviceInfo.value(forKey: "setup") as? Bool{
                        if setup{
                            if let macAdd = deviceInfo.value(forKey: "macAddress") as? String{
                                Constants.macAddress = macAdd
                            }
                        }
                    }
                    if let oad = deviceInfo.value(forKey: "OAD") as? NSDictionary{
                        if let oadVal = oad.allValues as? [Int] {
                            Constants.OADVersion = oadVal.max()!
                        }
                    }
                }
                if let proMode = userData.value(forKey: "proMode") as? Bool{
                    Constants.isProMode = proMode
                    if let counter = NSManagedObject.findAllForEntity("ProModeEntity", context: context){
                        counter.forEach { counter in
                            context.delete(counter as! NSManagedObject)
                        }
                    }
                    if let proModeEntity = NSEntityDescription.insertNewObject(forEntityName: "ProModeEntity", into: context) as? ProModeEntity{
                        proModeEntity.isProMode = Constants.isProMode
                        CoreDataStorage.saveContext(context)
                    }
                    if let proMembership = userData.value(forKey: "proMembership") as? NSDictionary{
                        if let device  = proMembership.value(forKey: "device") as? String{
                            if (device == "ios"){
                                let refreshManager = RefreshSubscriptionManager.shared
                                refreshManager.loadDataIfNeeded() { success in
                                    debugPrint("refreshManager==",success)
                                }
                            }
                        }
                        if let expTimestamp = proMembership.value(forKey: "timestamp") as? Int{
                            
                            let number = "\(expTimestamp)"
                            let array = number.compactMap{Int(String($0))}
                            var newTimestamp = Int()
                            newTimestamp = expTimestamp
                            if array.count != 13{
                                newTimestamp = expTimestamp * 1000
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/proMembership/").updateChildValues(["timestamp": newTimestamp])
                            }
                            
                            let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(newTimestamp/1000)))
                            
                            var timeEnd = Calendar.current.date(byAdding: .day, value: 365, to: timeStart as Date)
                            if proMembership.value(forKey: "productID") as? String != nil{
                                if (proMembership.value(forKey: "productID") as! String == Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID) || (proMembership.value(forKey: "productID") as! String == Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID) || (proMembership.value(forKey: "productID") as! String == Constants.FREE_MONTHLY_PRODUCT_ID) || (proMembership.value(forKey: "productID") as! String == Constants.AUTO_RENEW_EDDIE_MONTHLY_PRODUCT_ID){
                                    
                                    timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
                                    //timeEnd = Calendar.current.date(byAdding: .minute, value: 5, to: timeStart as Date)
                                }
                                
                                let timeNow = NSDate()
                                let calendar = NSCalendar.current
                                let components = calendar.dateComponents([.day], from: timeNow as Date, to: timeEnd!)
                                if components.day == 0 || components.day! < 0{
                                    if let device = proMembership.value(forKey: "device") as? String{
                                        
                                        if (device == "ios") || ((device == "android") && (proMembership.value(forKey: "productID") as! String == Constants.FREE_MONTHLY_PRODUCT_ID)){
                                            
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["trial" :true] as [AnyHashable:Any])
                                            Constants.trial = true
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMembership" :NSNull()] as [AnyHashable:Any])
                                            
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :false] as [AnyHashable:Any])
                                            Constants.isProMode = false
                                            
                                            let subDic = NSMutableDictionary()
                                            subDic.setObject(proMembership.value(forKey: "productID") as! String, forKey: "productID" as NSCopying)
                                            subDic.setObject(expTimestamp, forKey: "timestamp" as NSCopying)
                                            subDic.setObject("expire", forKey: "type" as NSCopying)
                                            let subKey = ref!.child("\(Auth.auth().currentUser!.uid)").childByAutoId().key
                                            let subscriptionDict = NSMutableDictionary()
                                            subscriptionDict.setObject(subDic, forKey: subKey as NSCopying)
                                            ref.child("subscriptions/\(Auth.auth().currentUser!.uid)/").updateChildValues(subscriptionDict as! [AnyHashable : Any])
                                            
                                            let alert = UIAlertController(title: "", message: "Your pro membership subscription has expired. Would you like to renew it now?", preferredStyle: .alert)
                                            
                                            alert.addAction(UIAlertAction(title: "LATER", style: .default, handler: { [weak alert] (_) in
                                                // Do Nothing
                                                debugPrint("LATER Alert: \(alert?.title ?? "")")
                                            }))
                                            alert.addAction(UIAlertAction(title: "RENEW", style: .default, handler: { [weak alert] (_) in
                                                debugPrint("RENEW Alert: \(alert?.title ?? "")")
                                                
//                                                let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
//                                                self.navigationController?.pushViewController(viewCtrl, animated: true)
                                                let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
                                                viewCtrl.source = "Renew"
                                                self.navigationController?.pushViewController(viewCtrl, animated: false)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                        if proMembership.value(forKey: "isMembershipActive") as? Int != nil{
                            UserDefaults.standard.set(false, forKey: "isNewUser")
                            UserDefaults.standard.synchronize()
                            self.btnUpgrade.isHidden = true
                        }
                    }
                }
                if let statistics = userData.value(forKey: "statistics") as? NSDictionary{
                    //data for card1
                    if let card = statistics["card1"] as? NSDictionary{
                        if let clubNameStr = card["club"] as? String{
                            self.clubName = clubNameStr
                        }
                        
                        if let distance = card["distance"] as? Double {
                            debugPrint(distance)
                            // self.homeVCModel.distanceWithUnit = String(Int(distance))
                            //self.homeVCModel.distanceWithUnit.append(" yds")
                        }
                        
                        self.strokesGainedValue = card["strokesGained"] as? Double
                        //self.homeVCModel.totalScore = card["score"] as? Double
                    }
                    
                    // Data for Card2
                    if let card = statistics["card2"] as? NSDictionary{
                        debugPrint(card)
                        //self.homeVCModel.swingScore = card["swingScore"] as? Double
                    }
                    
                    //Data for Card3
                    
                    //self.homeVCModel.card3PieDic = dataDic["card3"] as? NSDictionary
                    
                    //Data for Card 3,5
                    if let card = statistics["card3,5"] as? NSDictionary{
                        self.strokesGained = card["strokesGainedData"] as? Double
                        self.strokesGained = self.strokesGained?.rounded(toPlaces: 2)
                        self.strokesCount = card["strokesCount"] as? Double
                    }
                    
                    //Data for Rounds Linear Chart
                    if let card4 = statistics["card4"] as? NSDictionary{
                        self.round_score = []
                        self.round_time = []
                        var allRounds = card4.allValues
                        allRounds = allRounds.sorted{
                            (($1 as AnyObject).value(forKey: "timestamp")) as! Double > (($0 as AnyObject).value(forKey: "timestamp")) as! Double
                        }
                        var count = 0
                        for round in allRounds.reversed() {
                            let score:Double! = (round as AnyObject).value(forKey: "score") as? Double
                            let timeStamp:Double! = (round as AnyObject).value(forKey: "timestamp") as? Double
                            let today = NSDate(timeIntervalSince1970:(timeStamp)!/1000)
                            if(score > 0) && (count < 10){
                                self.round_score.append(score)
                                self.round_time.append(today.toString(dateFormat: "dd-MMM"))
                                count += 1
                            }else if(count > 10 ){
                                break
                            }
                        }
                    }
                }
                if let scoring = userData.value(forKey: "scoring") as? NSDictionary{
                    self.profileScoring = Int(scoring.count)
                    let dataArray = scoring.allValues as NSArray
                    self.filteredArray = [NSDictionary]()
                    self.filteredArray = dataArray as! [NSDictionary]
                    self.totalCaddie = 0
                    for i in 0..<self.filteredArray.count{
                        if let _ = ((self.filteredArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                            self.totalCaddie += 1
                        }
                    }
                }
                if let activeMatches = userData["activeMatches"] as? [String:Bool]{
                    for data in activeMatches{
                        if(data.value){
                            Constants.matchId = data.key
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["my.game","my.elevation","my.newUser","my.newUser3","my.newUser5","my.newUser7"])
                        }
                        else if(!data.value){
                            Constants.matchId = ""
                        }
                    }
                }
                var swingKeys = NSDictionary()
                self.totalSwingCount = 0
                self.swingMArray = NSMutableArray()
                if let swing = userData.value(forKey: "swingSession") as? NSDictionary{
                    swingKeys = swing
                }
                if let dataDic = swingKeys as? [String:Bool]{
                    let group = DispatchGroup()
                    for (key, value) in dataDic{
                        group.enter()
                        if !value{
                            Constants.deviceGameType = 0
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                                if(snapshot.value != nil){
                                    if let data = snapshot.value as? NSDictionary{
                                        //debugPrint(data.value(forKey: "matchKey"))
                                        if let swing = data.value(forKey: "swings") as? NSMutableArray{
                                            self.totalSwingCount = self.totalSwingCount + swing.count
                                            self.swingMArray.add(data)
                                        }
                                    }
                                }
                                group.leave()
                            }
                        }
                        else{
                            Constants.swingSessionKey = key
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                                if(snapshot.value != nil){
                                    if let data = snapshot.value as? NSDictionary{
                                        //debugPrint(data.value(forKey: "matchKey"))
                                        if let playType = data.value(forKey: "playType") as? String{
                                            if playType == "match"{
                                                Constants.deviceGameType = 1
                                            }
                                            else{
                                                Constants.deviceGameType = 2
                                            }
                                        }
                                    }
                                }
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: .main, execute: {
                        if self.swingMArray.count == 0{
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/user1") { (snapshot) in
                                if(snapshot.childrenCount > 0){
                                    var userData = NSDictionary()
                                    userData = snapshot.value as! NSDictionary
                                    if let swingKeys = userData.value(forKey: "swingSession") as? NSDictionary{
                                        self.totalSwingCount = 0
                                        self.swingMArray = NSMutableArray()
                                        if let dataDic = swingKeys as? [String:Bool]{
                                            let group = DispatchGroup()
                                            for (key, value) in dataDic{
                                                group.enter()
                                                
                                                if !value{
                                                    FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                                                        if(snapshot.value != nil){
                                                            if let data = snapshot.value as? NSDictionary{
                                                                //debugPrint(data.value(forKey: "matchKey"))
                                                                if let swing = data.value(forKey: "swings") as? NSMutableArray{
                                                                    self.totalSwingCount = self.totalSwingCount + swing.count
                                                                    self.swingMArray.add(data)
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
                                                self.lblDemoStatsMySwing.isHidden = false
                                                self.isDemoStats = true
                                                let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                                                let array: NSArray = self.swingMArray.sortedArray(using: [sortDescriptor]) as NSArray
                                                self.swingMArray.removeAllObjects()
                                                self.swingMArray = NSMutableArray()
                                                self.swingMArray = array.mutableCopy() as! NSMutableArray
                                                
                                                self.setSwingSessionUI()
                                            })
                                        }
                                    }
                                }
                            }
                        }else{
                            self.lblDemoStatsMySwing.isHidden = true
                            self.isDemoStats = false
                            self.progressView.hide(navItem: self.navigationItem)
                            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                            let array: NSArray = self.swingMArray.sortedArray(using: [sortDescriptor]) as NSArray
                            self.swingMArray.removeAllObjects()
                            self.swingMArray = NSMutableArray()
                            self.swingMArray = array.mutableCopy() as! NSMutableArray
                            self.setSwingSessionUI()
                        }
                    })
                }
                if let homeCourseDic = userData["homeCourseDetails"] as? NSDictionary{
                    if let courseName = homeCourseDic.object(forKey: "name"){
                        self.profileHomeCourse = courseName as? String
                        UserDefaults.standard.set(courseName, forKey: "HomeCourseName")
                        UserDefaults.standard.synchronize()
                    }
                    if let courseLat = homeCourseDic.object(forKey: "lat"){
                        UserDefaults.standard.set(courseLat, forKey: "HomeLat")
                        UserDefaults.standard.synchronize()
                    }
                    if let courseLng = homeCourseDic.object(forKey: "lng"){
                        UserDefaults.standard.set(courseLng, forKey: "HomeLng")
                        UserDefaults.standard.synchronize()
                    }
                    if let courseID = homeCourseDic.object(forKey: "id"){
                        UserDefaults.standard.set(courseID, forKey: "HomeCourseId")
                        UserDefaults.standard.synchronize()
                    }
                }
                if let lastCourseDic = userData["lastCourseDetails"] as? NSDictionary{
                    if let mapped = lastCourseDic.object(forKey: "mapped") as? String{
                        self.mappedStr = mapped
                    }
                }
                if let handicap = userData["handicap"] as? String{
                    Constants.handicap = handicap
                    if handicap != "-"{
                        hcp = Double(handicap)?.rounded() ?? 0
                    }
                }
                if let gameGoal = userData["goals"] as? NSMutableDictionary{
                    if let value = gameGoal.value(forKey: "birdie") as? Int{
                        Constants.targetGoal.Birdie = value
                    }
                    if let value = gameGoal.value(forKey: "fairway") as? Int{
                        Constants.targetGoal.fairwayHit = value
                    }
                    if let value = gameGoal.value(forKey: "par") as? Int{
                        Constants.targetGoal.par = value
                    }
                    if let value = gameGoal.value(forKey: "gir") as? Int{
                        Constants.targetGoal.gir = value
                    }
                }else{
                    if let handi = userData["handicap"] as? String{
                        var handicap : Int = 18
                        if !handi.contains(find: "-"){
                            handicap = Int((Double(handicap).rounded()))
                        }
                        var goalsDic = NSMutableDictionary()
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "target/\(handicap)") { (snapshot) in
                            if let targetDic = snapshot.value as? NSMutableDictionary{
                                goalsDic = targetDic
                                
                                let goalsDict = NSMutableDictionary()
                                goalsDict.setObject(Int((goalsDic.value(forKey: "birdie") as! Double).rounded()), forKey: "birdie" as NSCopying)
                                goalsDict.setObject(Int((goalsDic.value(forKey: "fairway") as! Double).rounded()), forKey: "fairway" as NSCopying)
                                goalsDict.setObject(Int((goalsDic.value(forKey: "gir") as! Double).rounded()), forKey: "gir" as NSCopying)
                                goalsDict.setObject(Int((goalsDic.value(forKey: "par") as! Double).rounded()), forKey: "par" as NSCopying)
                                Constants.targetGoal.Birdie = Int((goalsDic.value(forKey: "birdie") as! Double).rounded())
                                Constants.targetGoal.fairwayHit = Int((goalsDic.value(forKey: "fairway") as! Double).rounded())
                                Constants.targetGoal.gir = Int((goalsDic.value(forKey: "gir") as! Double).rounded())
                                Constants.targetGoal.par = Int((goalsDic.value(forKey: "par") as! Double).rounded())

                                if Int((goalsDic.value(forKey: "birdie") as! Double).rounded()) < 1{
                                    goalsDict.setObject(1, forKey: "birdie" as NSCopying)
                                    Constants.targetGoal.Birdie = 1
                                }
                                else if Int((goalsDic.value(forKey: "fairway") as! Double).rounded()) < 1{
                                    goalsDict.setObject(1, forKey: "fairway" as NSCopying)
                                    Constants.targetGoal.fairwayHit = 1
                                }
                                else if Int((goalsDic.value(forKey: "gir") as! Double).rounded()) < 1{
                                    goalsDict.setObject(1, forKey: "gir" as NSCopying)
                                    Constants.targetGoal.gir = 1
                                }
                                else if Int((goalsDic.value(forKey: "par") as! Double).rounded()) < 1{
                                    goalsDict.setObject(1, forKey: "par" as NSCopying)
                                    Constants.targetGoal.par = 1
                                }
                                //----------------------------------------------------------------------
                                if Int((goalsDic.value(forKey: "birdie") as! Double).rounded()) > 18{
                                    goalsDict.setObject(18, forKey: "birdie" as NSCopying)
                                    Constants.targetGoal.Birdie = 18
                                }
                                else if Int((goalsDic.value(forKey: "fairway") as! Double).rounded()) > 14{
                                    goalsDict.setObject(14, forKey: "fairway" as NSCopying)
                                    Constants.targetGoal.fairwayHit = 14
                                }
                                else if Int((goalsDic.value(forKey: "gir") as! Double).rounded()) > 18{
                                    goalsDict.setObject(18, forKey: "gir" as NSCopying)
                                    Constants.targetGoal.gir = 18
                                }
                                else if Int((goalsDic.value(forKey: "par") as! Double).rounded()) > 18{
                                    goalsDict.setObject(18, forKey: "par" as NSCopying)
                                    Constants.targetGoal.par = 18
                                }
                                goalsDic = goalsDict
                                let golfFinalDic = ["goals":goalsDict]
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfFinalDic)
                            }
                        }
                    }
                }
                if let gender = userData["gender"] as? String{
                    Constants.gender = gender
                }
                if let myFeeds = userData["myFeeds"] as? [String : Bool]{
                    self.dataArray.removeAll()
                    
                    let group = DispatchGroup()
                    for (key,_) in myFeeds{
                        group.enter()
                        self.getFeedDataFromFirebase(key:key, group:group)
                    }
                    group.notify(queue: .main) {
                        self.progressView.hide(navItem: self.navigationItem)
                        self.getScoreFromFirebaseMatchData()
                    }
                }else{
                    self.getScoreFromFirebaseMatchData()
                }
                if let golfBag = userData["golfBag"] as? NSMutableArray{
                    for i in 0..<golfBag.count{
                        if let dict = golfBag[i] as? NSDictionary{
                            debugPrint("dict ==", dict)
                            self.clubInsideGolfClub.append(dict.value(forKey: "clubName") as! String)
                            if dict.value(forKey: "tagNum") != nil{
                                if let tagNum = dict.value(forKey: "tagNum") as? Int{
                                    if tagNum == 0{
                                        ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["tagNum":""])
                                    }
                                }
                            }
                        }
                        else{
                            let tempArray = golfBag
                            var golfBagData = [String: NSMutableArray]()
                            for i in 0..<tempArray.count{
                                let golfBagDict = NSMutableDictionary()
                                golfBagDict.setObject("", forKey: "brand" as NSCopying)
                                golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                                golfBagDict.setObject(tempArray[i], forKey: "clubName" as NSCopying)
                                self.clubInsideGolfClub.append(tempArray[i] as! String)
                                golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                                golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                                golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                                golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                                
                                golfBag.replaceObject(at: i, with: golfBagDict)
                                golfBagData = ["golfBag": golfBag]
                                
                            }
                            if golfBagData.count>0{
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            }
                            break
                        }
                    }
                }
            }
            DispatchQueue.main.async( execute: {
                if hcp != nil{
                    self.getBaseLine(hcp: Int(hcp))
                }
                self.setMyData()
                if(self.round_score.count == 0){
                    self.updateCard4(path: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/statistics")
                }
                if self.profileScoring == nil || self.totalCaddie == 0{
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/scoring") { (snapshot) in
                        var dataDic = NSDictionary()
                        dataDic = (snapshot.value as? NSDictionary)!
                        
                        let dataArray = dataDic.allValues as NSArray
                        self.filteredArray = [NSDictionary]()
                        self.filteredArray = dataArray as! [NSDictionary]
                        
                        self.getClubDataFromFirebase(isShow:true)
                    }
                }else{
                    self.getClubDataFromFirebase(isShow:false)
                }
                self.getBenchmarkKey()
            })
        }
    }
    func setSwingSessionUI() {
        let swingTempArray = NSMutableArray()
        var numOfItems = 0
        var swingScoreSum = 0.0
        var clubArray = [String]()
        var clubName: String
        var bestValArray = NSMutableArray()
        
        for i in 0..<self.swingMArray.count{
            let dataDic = self.swingMArray[i] as! NSDictionary
            let tempSwingArray = dataDic.value(forKey: "swings") as! NSMutableArray
            for j in 0..<tempSwingArray.count{
                if let dic = tempSwingArray[j] as? NSDictionary{
                    clubArray.append(dic.value(forKey: "club") as! String)
                    swingTempArray.add(dic)
                }
            }
        }
        clubArray = Array(Set(clubArray))
        
        let tempArray = ["Dr", "3w", "1i", "1h", "2h", "3h", "2i", "4w", "4h", "3i", "5w", "5h", "4i", "7w", "6h", "5i", "7h", "6i", "7i", "8i", "9i", "Pw", "Gw", "Sw", "Lw"]
        var tempArray2 = [String]()
        for j in 0..<tempArray.count{
            if clubArray.contains(tempArray[j]){
                tempArray2.append(tempArray[j])
            }
        }
        clubArray.removeAll()
        clubArray = [String]()
        clubArray = tempArray2
        
        for q in 0..<clubArray.count{
            var bestNumOfItems = 0
            var bestSwingScoreSum = 0.0
            clubName = String()
            let bestValDic = NSMutableDictionary()
            
            for i in 0..<swingTempArray.count{
                let dataDic = swingTempArray[i] as! NSDictionary
                if clubArray[q] == (dataDic.value(forKey: "club") as! String){
                    bestNumOfItems = bestNumOfItems + 1
                    let swingScore = (dataDic.value(forKey: "swingScore") as! Double)
                    bestSwingScoreSum += swingScore
                    clubName = clubArray[q]
                }
                numOfItems = numOfItems + 1
                let swingScore = (dataDic.value(forKey: "swingScore") as! Double)
                swingScoreSum += swingScore
            }
            if bestNumOfItems>0{
                let avgBestSwing = bestSwingScoreSum/Double(bestNumOfItems)
                bestValDic.setObject(clubName , forKey: "clubName" as NSCopying)
                bestValDic.setObject(avgBestSwing, forKey: "avgBestSwing" as NSCopying)
                bestValArray.add(bestValDic)
            }
        }
        let sortDescriptor = NSSortDescriptor(key: "avgBestSwing", ascending: false)
        let array: NSArray = bestValArray.sortedArray(using: [sortDescriptor]) as NSArray
        bestValArray.removeAllObjects()
        bestValArray = NSMutableArray()
        bestValArray = array.mutableCopy() as! NSMutableArray
        
        lblBestSwingScore.text = "-"
        lblBestSwingClub.text = "-"
        lblSwingScore.text = "-"
        lblTotalSwingTaken.text = "-"
        if let maxDic =  bestValArray.firstObject as? NSDictionary{
            if maxDic.count>0{
                lblBestSwingScore.text = "\(Int((maxDic.value(forKey: "avgBestSwing")) as! Double))"
                lblBestSwingClub.text = getFullClubName(clubName:(maxDic.value(forKey: "clubName") as! String))
            }
        }
        if numOfItems > 0{
            let avgSwing = swingScoreSum/Double(numOfItems)
            self.lblSwingScore.text = "\(Int(avgSwing))"
        }
        if totalSwingCount > 0{
            self.lblTotalSwingTaken.text = "\(self.totalSwingCount)"
        }
    }
    func getBenchmarkKey(){
        var benchmark_Key = String()
        if Constants.gender == "male"{
            if Constants.handicap == "-"{
                benchmark_Key = "M6";
            }else if Constants.handicap >= "0" && Constants.handicap < "6"{
                benchmark_Key = "M0";
            }else if Constants.handicap >= "6" && Constants.handicap < "20"{
                benchmark_Key = "M6";
            }else{
                benchmark_Key = "M20";
            }
        }else{
            if Constants.handicap == "-"{
                benchmark_Key = "F6";
            }else if Constants.handicap >= "0" && Constants.handicap < "6"{
                benchmark_Key = "F0";
            }else if Constants.handicap >= "6" && Constants.handicap < "20"{
                benchmark_Key = "F6";
            }else{
                benchmark_Key = "F20";
            }
        }
        Constants.benchmark_Key = benchmark_Key
    }
    
    func getBaseLine(hcp:Int){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "baseline/\(hcp)") { (snapshot) in
            if let baseline = snapshot.value as? NSDictionary{
                Constants.baselineDict = baseline
            }
        }
    }
    
    func getFeedDataFromFirebase(key: String, group:DispatchGroup){
        
        if(self.dataArray.count == 0) || Constants.isUpdateInfo{
            
            let feed = Feeds()
            ref.child("feedData/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    let feedData = (snapshot.value as? NSDictionary)!
                    if(feedData["type"] as! String == "2"){
                        if let location = feedData["location"] as? String {
                            feed.location = location
                        }
                        if let taggedUsers = feedData["taggedUsers"] as? NSDictionary {
                            feed.taggedUsers = taggedUsers
                        }
                        if let timestamp = feedData["timestamp"] as? Double {
                            feed.timeStamp = timestamp
                        }
                        if let type = feedData["type"] as? String {
                            feed.type = type
                        }
                        if let userImage = feedData["userImage"] as? String {
                            feed.userImage = userImage
                        }
                        if let userKey = feedData["userKey"] as? String {
                            feed.userKey = userKey
                        }
                        if let userName = feedData["userName"] as? String {
                            feed.userName = userName
                        }
                        if let matchId = feedData["matchKey"] as? String {
                            feed.matchId = matchId
                        }
                    }
                    else if (feedData["type"] as! String == "1"){
                        if let message = feedData["message"] as? String {
                            feed.message = message
                        }
                        if let shareImage = feedData["shareImage"] as? String {
                            feed.locationKey = shareImage
                        }
                        if let timestamp = feedData["timestamp"] as? Double {
                            feed.timeStamp = timestamp
                        }
                        if let type = feedData["type"] as? String {
                            feed.type = type
                        }
                        if let userImage = feedData["userImage"] as? String {
                            feed.userImage = userImage
                        }
                        if let userKey = feedData["userKey"] as? String {
                            feed.userKey = userKey
                        }
                        if let userName = feedData["userName"] as? String {
                            feed.userName = userName
                        }
                    }
                    feed.likesCount = 0
                    feed.isLikedByMe = false
                    if let likes = feedData["likes"] as? [String:Bool]{
                        feed.likesCount = likes.count
                        if(likes["\(Auth.auth().currentUser!.uid)"]) != nil{
                            feed.isLikedByMe = true
                        }
                    }
                    feed.feedId = key
                    self.dataArray.append(feed)
                }
                group.leave()
            })
        }
        else{
            self.progressView.hide(navItem: self.navigationItem)
        }
    }
    
    func setMyData() {
        
//        if !Constants.isProMode {
//            self.setProLockedUI(targetView: self.viewSGTab)
//        }
        self.ifDemolblLine.isHidden = Constants.isDevice
        self.ifDemoShowStackView.isHidden = Constants.isDevice
        self.btnPractice.isHidden = !Constants.isDevice
        
        mySwingTabView.isHidden = !Constants.isDevice

//        self.lblDemoStatsMySwing.isHidden = Constants.isDevice
//        else if Constants.isProMode{
//            self.setDeviceLockedUI(targetView: self.viewSGTab, title: "My Swings")
//        }
//        else if !Constants.isDevice {
//            self.viewSGTab.makeBlurView(targetView: self.viewSGTab)
//            self.setDeviceLockedUI(targetView: self.viewSGTab, title: "My Swings")
//        }
//        else if !Constants.isProMode{
//            self.setProLockedUI(targetView: self.viewSGTab)
//        }

//        else if !Constants.isProMode{
//            self.setProLockedUI(targetView: self.viewSGTab)
//        }

        lblProfileHomeCourse.text = self.profileHomeCourse ?? "-"
        lblProfileHandicap.text = Constants.handicap
        lblProfileScoring.text = "\(self.profileScoring ?? 0)"
        
        self.btnProfileBasic.setTitle("Basic", for: .normal)
        self.btnProfileBasic.backgroundColor = UIColor.white
        self.btnProfileBasic.setTitleColor(UIColor(rgb: 0x003D33), for: .normal)
        
        if UserDefaults.standard.object(forKey: "isNewUser") as? Bool != nil{
            let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
            if (newUser && !Constants.isProMode){
                if (self.profileHomeCourse != nil && self.profileHomeCourse != "") || (mappedStr == "2"){
                    if !(Constants.trial){
                        self.viewBecomePro.isHidden = false
                        viewEddieHConstraint.constant = 120
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        if Constants.isProMode{
            self.btnUpgrade.isHidden = true
            self.proLabelProfileStackView.isHidden = true
            self.viewBecomePro.isHidden = true
            viewEddieHConstraint.constant = 0
            self.view.layoutIfNeeded()
            
            self.btnProfileBasic.setTitle("PRO", for: .normal)
            self.btnProfileBasic.backgroundColor = UIColor(rgb: 0xFFC700)
            self.btnProfileBasic.setTitleColor(UIColor.white, for: .normal)
        }
        else{
            self.viewBecomePro.isHidden = false
            viewEddieHConstraint.constant = 120
            self.view.layoutIfNeeded()
        }
        
        // ----------------------------- Set My Score Chart -------------------------------------
        if self.round_time.count > 0{
            for view in ((self.scoreBarChartView.superview)?.subviews)!{
                if(view.isKind(of: DemoLabel.self)){
                    view.removeFromSuperview()
                }
            }
            self.scoreBarChartView.setBarChart(dataPoints: self.round_time.reversed(), values: self.round_score.reversed(), chartView: self.scoreBarChartView, color: UIColor.glfSeafoamBlue, barWidth: 0.2, leftAxisMinimum: 0, labelTextColor: UIColor.glfWarmGrey, unit: "", valueColor: UIColor.glfWarmGrey)
        }
        //--------------------------------------------------------------------------------------
    }
    
    func setDeviceLockedUI(targetView:UIView?, title: String) {
        
        let customProModeView = CustomProModeView()
        customProModeView.frame =  CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!-16, height: (targetView?.frame.size.height)!)
        customProModeView.delegate = self
        customProModeView.btnDevice.isHidden = false
        customProModeView.btnPro.isHidden = true
        
        customProModeView.proImageView.frame.size.width = 45
        customProModeView.proImageView.frame.size.height = 45
        customProModeView.proImageView.frame.origin.x = (customProModeView.frame.size.width)-45-4
        customProModeView.proImageView.frame.origin.y = 0
        
        customProModeView.label.frame.size.width = (customProModeView.bounds.width)-80
        customProModeView.label.frame.size.height = 50
        customProModeView.label.center = CGPoint(x: (customProModeView.bounds.midX), y: (customProModeView.bounds.midY)-40)
        customProModeView.label.backgroundColor = UIColor.clear
        
        customProModeView.btnDevice.frame.size.width = (customProModeView.label.frame.size.width/2)+10
        customProModeView.btnDevice.frame.size.height = 40
        customProModeView.btnDevice.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 20)
        
        customProModeView.titleLabel.frame = CGRect(x: customProModeView.frame.origin.x + 16, y: customProModeView.frame.origin.y + 16, width: customProModeView.bounds.width, height: 30)
        customProModeView.titleLabel.backgroundColor = UIColor.clear
        customProModeView.titleLabelText = title
        customProModeView.titleLabel.textColor = UIColor.darkGray
        
        customProModeView.labelText = "Golfication X required"
        customProModeView.btnDeviceTitle = "Visit our store"
        customProModeView.proImageView.image = UIImage(named: "device")
        customProModeView.backgroundColor = UIColor.clear
        targetView?.addSubview(customProModeView)
    }
    
    func deviceLockBtnPressed(button:UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        debugPrint("touched")
    //    }
    
    
    // MARK: - getScoreFromFirebaseMatchData
    func getScoreFromFirebaseMatchData(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        let group = DispatchGroup()
        var feedNumber = [String]()
        for i in 0..<self.dataArray.count{
            if let matchID = dataArray[i].matchId, matchID.count > 1{
                let userID = dataArray[i].userKey!
                let feedID = dataArray[i].feedId!
                debugPrint("MatchID : \(matchID)")
                debugPrint("FeedID : \(feedID)")
                group.enter()
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchID)") { (snapshot) in
                    var matchDict = NSMutableDictionary()
                    self.holeShots = [HoleShotPar]()
                    if(snapshot.childrenCount > 0){
                        matchDict = (snapshot.value as? NSMutableDictionary)!
                    }
                    var scoreArray = NSArray()
                    var keyData = String()
                    var holeCount = 0
                    if(self.dataArray.count > 0){
                        for (key,value) in matchDict{
                            keyData = key as! String
                            
                            if(keyData == "scoring"){
                                scoreArray = (value as! NSArray)
                            }
                            if(keyData == "courseName"){
                                self.dataArray[i].location = (value as! String)
                                Constants.selectedGolfName = value as! String
                            }
                        }
                        self.dataArray[i].isShow = true
                        for j in 0..<scoreArray.count {
                            let holeShotPar = HoleShotPar()
                            let playersArray = [NSMutableDictionary]()
                            var par:Int!
                            
                            holeShotPar.hole = j
                            let score = scoreArray[j] as! NSDictionary
                            for(key,value) in score{
                                if(key as! String == "par"){
                                    holeShotPar.par = (value as! Int)
                                    par = (value as! Int)
                                }
                                if(key as! String == userID){
                                    let playersShotsDic = score.value(forKey: userID) as! NSMutableDictionary
                                    if(playersShotsDic.value(forKey: "holeOut") as! Bool){
                                        self.dataArray[i].isShow = false
                                        let dict = value as! NSMutableDictionary
                                        holeCount += 1
                                        if (dict.value(forKey: "shots") != nil){
                                            holeShotPar.shot = (dict.value(forKey: "shots") as! NSArray).count
                                        }
                                        else if (dict.value(forKey: "strokes") != nil){
                                            holeShotPar.shot = (dict.value(forKey: "strokes") as! Int)
                                        }
                                    }
                                }
                            }
                            self.holeShots.append(holeShotPar)
                            self.scoring.append((hole: j, par:par,players:playersArray))
                        }
                        if(holeCount>0){
                            self.dataArray[i].holeShotsArray = self.holeShots
                        }else{
                            feedNumber.append(feedID)
                        }
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            for feed in feedNumber{
                for i in 0..<self.dataArray.count{
                    if(feed == self.dataArray[i].feedId){
                        self.dataArray.remove(at: i)
                        break
                    }
                }
            }
            self.dataArray = self.dataArray.sorted{
                ($0.timeStamp!) > ($1.timeStamp!)
            }
            //https://stackoverflow.com/questions/18498098/how-to-make-uitableviews-height-dynamic-with-autolayout-feature
            var height = 260
            if(self.dataArray.count > 0){
                for i in 0..<self.dataArray.count{
                    if i < self.cellIndex{
                        let feeds = self.dataArray[i]
                        if(feeds.location == nil){
                            height += 440
                        }else if ((feeds.holeShotsArray?.count == 9)){
                            height += 190
                        }else{
                            height += 260
                        }
                    }
                }
            }
            self.tableHeightConstraint.constant = CGFloat(height+35)
            self.view.layoutIfNeeded()
            self.setData()
            
            if self.dataArray.count == 0{
                self.feedTableView.isHidden = true
            }
            else{
                self.feedTableView.isHidden = false
                
                self.feedTableView.delegate = self
                self.feedTableView.dataSource = self
                self.feedTableView.reloadData()
                //self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.frame.origin.x, y: self.feedTableView.frame.origin.y, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height), animated: true)
            }
            self.progressView.hide(navItem: self.navigationItem)
        }
    }
    
    func isUpdateAvailable(completion: @escaping (String?, Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        //https://stackoverflow.com/questions/6256748/check-if-my-app-has-a-new-version-on-appstore
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version, version != currentVersion, nil)
            } catch {
                completion(nil,nil, error)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - setData
    func setData() {
        // ------- check active match ------------------
        var isActiveMatch = false
        if(Constants.matchId.count > 0){
            isActiveMatch = true
        }
        
        if isActiveMatch{
            if(!isShowCase){
                if(Constants.matchId.count > 1){
                    
                    self.getScoreFromMatchDataFirebase(keyId:Constants.matchId)
                    lblGameStatus.text = "Current Round"
                    viewRecentGame.isHidden = false
                    viewPreviousGame.isHidden = true
                    viewNewGame.isHidden = true
                }
            }
        }
        else{
            if let counter = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: context){
                counter.forEach { counter in
                    context.delete(counter as! NSManagedObject)
                }
            }
            if(dataArray.count > 0){
                if let matchIDs = dataArray[0].matchId{
                    self.getScoreFromMatchData(keyId:matchIDs)
                    
                    lblGameStatus.text = "Latest Round"
                    viewRecentGame.isHidden = true
                    viewPreviousGame.isHidden = false
                    viewNewGame.isHidden = true
                }
                else
                {
                    lblGameStatus.text = "Start a new Round"
                    lblStartGolfName.text = "Chena Bend Golf Course"
                    if !(profileHomeCourse == "" || profileHomeCourse == nil){
                        lblStartGolfName.text = profileHomeCourse
                    }
                    viewRecentGame.isHidden = true
                    viewPreviousGame.isHidden = true
                    viewNewGame.isHidden = false
                }
            }
            else{
                lblGameStatus.text = "Start a new Round"
                lblStartGolfName.text = "Chena Bend Golf Course"
                if !(profileHomeCourse == "" || profileHomeCourse == nil){
                    lblStartGolfName.text = profileHomeCourse
                }
                viewNewGame.isHidden = false
                viewRecentGame.isHidden = true
                viewPreviousGame.isHidden = true
            }
        }
        
        //------------------------------- for previous game ---------------------------------------
        if(dataArray.count > 0){
            let feeds = dataArray[0]
            if let holesData = (feeds.holeShotsArray){
                var shotSum = 0
                var parSum = 0
                for i in 0..<holesData.count{
                    if(holesData[i].shot != 0){
                        
                        shotSum += holesData[i].shot
                        parSum += holesData[i].par
                    }
                }
                let timeAgo = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
                if((feeds.location) != nil){
                    //self.lblSubtitle.text = "\(timeAgo) at \(feeds.location!)"
                    lblPreGameGolfName.text = feeds.location!
                    lblPreGameTime.text = "\(timeAgo)"
                }
                let shotDetails = shotSum > parSum ? "-over":"-under"
                let anoterString = shotSum > parSum ? "\(shotSum-parSum)":"\(parSum-shotSum)"
                lblPreGameScore.text =  "You finished \(anoterString) \(shotDetails) \(shotSum)"
                if(parSum) == 0{
                    lblPreGameScore.text =  "You finished Even par \(shotSum)"
                }
            }
        }
        
        // ------------------------------------------  Set Player Mode ----------------------------
        
        if players.count>0{
            if players.count == 1{
                self.lblPlayerMode.isHidden = true
            }
            else if players.count > 1{
                self.lblPlayerMode.text = "with Friends"
                
                for i in 0..<players.count{
                    self.lblPlayerMode.isHidden = false
                    if (players[i] as! NSMutableDictionary).value(forKey: "id") as! String == "jpSgWiruZuOnWybYce55YDYGXP62"{
                        self.lblPlayerMode.text = "with AI"
                        break
                    }
                    else if (players[i] as! NSMutableDictionary).value(forKey: "id") as? String == Auth.auth().currentUser!.uid{
                        self.lblPlayerMode.isHidden = true
                    }
                }
            }
        }
        else{
            self.lblPlayerMode.isHidden = true
        }
    }
    
    func getScoreFromMatchData(keyId:String){
//        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        btnScoreDetail.isEnabled = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(keyId)/") { (snapshot) in
            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                Constants.matchDataDic = matchDict as! NSMutableDictionary
                Constants.gameType = matchDict.value(forKey: "matchType") as? String ?? Constants.gameType
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,_) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                        }
                    }
                    if(keyData == "scoringMode"){
                        self.scoringMode = value as! String
                    }
                    if(keyData == "courseId"){
                        self.selectedHomeGolfID = value as! String
                    }
                    if(keyData == "courseName"){
                        self.selectedHomeGolfName = value as! String
                        
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
                    if(keyData == "currentHole"){
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
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = (value as! Int)
                        }
                        if(key as! String)==Auth.auth().currentUser!.uid{
                            let dict = NSMutableDictionary()
                            dict.setObject(value, forKey: key as! String as NSCopying)
                            if((key as! String) == Auth.auth().currentUser!.uid){
                                if(((value as! NSMutableDictionary).value(forKey: "holeOut")) as! Bool){
                                    
                                }
                            }
                            playersArray.append(dict)
                        }
                    }
                    self.scoring.append((hole: i, par:par,players:playersArray))
                }
            }
            DispatchQueue.main.async(execute: {
//                self.progressView.hide(navItem: self.navigationItem)
                var finalPar: Int = 0
                var myVal: Int = 0
                var finalStroke: Int = 0
                
                for i in 0..<self.scoring.count{
                    for dataDict in self.scoring[i].players{
                        for (key,value) in dataDict{
                            let dic = value as! NSDictionary
                            if dic.value(forKey: "holeOut") as! Bool == true{
                                if(key as? String == Auth.auth().currentUser!.uid){
                                    for (key,value) in value as! NSMutableDictionary
                                    {
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            let allScore  = shotsArray.count - (self.scoring[i].par)
                                            finalPar = finalPar + allScore
                                        }
                                        if (key as! String == "holeOut" && value as! Bool){
                                            myVal = myVal + (value as! Int)
                                        }
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            let allScore  = shotsArray.count
                                            finalStroke = finalStroke + allScore
                                        }else if (key as! String == "strokes"){
                                            var allScore  = value as! Int
                                            finalStroke = finalStroke + allScore
                                            allScore  = allScore - (self.scoring[i].par)
                                            finalPar = finalPar + allScore
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.lblPreGamePar.text = "\(finalPar)"
                if finalPar>0{
                    self.lblPreGamePar.text = "+\(finalPar)"
                }
                //                self.lblPreGameThru.text = "\(myVal)"
                self.lblPreGameThru.text = "F"
                self.lblPreGameStrokes.text = "\(finalStroke)"
                self.btnScoreDetail.isEnabled = true
            })
        }
    }
    
    func getScoreFromMatchDataFirebase(keyId:String){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        self.btnContinue.isEnabled = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(keyId)/") { (snapshot) in
            var isOnCourse = false
            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                Constants.matchDataDic = matchDict as! NSMutableDictionary
                Constants.gameType = matchDict.value(forKey: "matchType") as? String ?? Constants.gameType
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,_) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                        }
                    }
                    if(keyData == "scoringMode"){
                        self.scoringMode = value as! String
                    }
                    if(keyData == "onCourse"){
                        isOnCourse = value as! Bool
                    }
                    if(keyData == "courseId"){
                        self.selectedHomeGolfID = value as! String
                    }
                    if(keyData == "courseName"){
                        self.selectedHomeGolfName = value as! String
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
                    if(keyData == "currentHole"){
                        
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
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = (value as! Int)
                        }
                        if(key as! String)==Auth.auth().currentUser!.uid{
                            let dict = NSMutableDictionary()
                            dict.setObject(value, forKey: key as! String as NSCopying)
                            playersArray.append(dict)
                        }
                    }
                    self.scoring.append((hole: i, par:par,players:playersArray))
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.players.removeAllObjects()
                self.players = NSMutableArray()
                if let counter = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: context){
                    counter.forEach { counter in
                        context.delete(counter as! NSManagedObject)
                    }
                }
                if isOnCourse{
                    var inde = 0
                    for data in self.scoring{
                        for usr in data.players{
                            if let play = usr.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSMutableDictionary{
                                let holeOut = play.value(forKey: "holeOut") as? Bool ?? false
                                if !holeOut{
                                    break
                                }else{
                                    inde += 1
                                }
                            }
                        }
                    }
                    if let curHoleEntity = NSEntityDescription.insertNewObject(forEntityName: "CurrentHoleEntity", into: context) as? CurrentHoleEntity{
                        curHoleEntity.timestamp = Timestamp
                        curHoleEntity.holeIndex = Int16(inde)
                        CoreDataStorage.saveContext(context)
                    }
                    if let calledByUserEntity = NSManagedObject.findAllForEntity("CalledByUserEntity", context: context) as? [CalledByUserEntity],!calledByUserEntity.isEmpty{
                        let timeStampDict = NSMutableDictionary()
                        let holeWiseDict = NSMutableDictionary()
                        for data in calledByUserEntity{
                            let dict = NSMutableDictionary()
                            dict.addEntries(from: ["lat":data.lat])
                            dict.addEntries(from: ["lng":data.lng])
                            timeStampDict.addEntries(from: ["\(data.timestamp)":dict])
                            holeWiseDict.addEntries(from: ["\(data.hole)":timeStampDict])
                        }
                        holeWiseDict.addEntries(from: ["courseId" : self.selectedHomeGolfID])
                        holeWiseDict.addEntries(from: ["courseName" : self.selectedHomeGolfName])
                        debugPrint(holeWiseDict)
                        ref.child("siriEvent/\(Auth.auth().currentUser!.uid)/\(keyId)").updateChildValues(holeWiseDict as! [AnyHashable:Any])
                    }
                }
                if(Constants.matchDataDic.object(forKey: "player") != nil){
                    let tempArray = Constants.matchDataDic.object(forKey: "player")! as! NSMutableDictionary
                    for (k,v) in tempArray{
                        if let dict = v as? NSMutableDictionary{
                            dict.addEntries(from: ["id":k])
                            self.players.add(dict)
                        }
                    }
                    self.progressView.hide(navItem: self.navigationItem)
                    self.btnContinue.isEnabled = true
                    self.lblContinueGolfName.text = self.selectedHomeGolfName + " - \(self.holeType) " + "Holes".localized()
                }
            })
        }
    }
    
    // MARK: - viewAllFeedAction
    @objc func viewAllFeedAction(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MyFeedVC") as! MyFeedVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Recent Activity"
    //    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor(rgb: 0xFBFBFB)
        
        let lblPlayer = UILabel()
        lblPlayer.frame = CGRect(x: 10, y: 0, width: 150, height: 25)
        lblPlayer.text = "Recent Activity"
        lblPlayer.textColor = UIColor.black
        lblPlayer.backgroundColor = UIColor.clear
        lblPlayer.textAlignment = NSTextAlignment.left
        lblPlayer.font = UIFont(name: "SFProDisplay-Medium", size: 17.0)
        header.addSubview(lblPlayer)
        
        let btnViewAll = UIButton()
        btnViewAll.frame = CGRect(x: tableView.frame.size.width-70-10, y: 0, width: 70, height: 25)
        btnViewAll.backgroundColor = UIColor.clear
        btnViewAll.setTitleColor(UIColor.glfBluegreen, for: .normal)
        btnViewAll.setTitle("View All", for: .normal)
        btnViewAll.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 13.0)
        btnViewAll.addTarget(self, action: #selector(self.viewAllFeedAction(_:)), for: .touchUpInside)
        if dataArray.count>cellIndex{
            header.addSubview(btnViewAll)
        }
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        var height = CGFloat()
        let feeds = dataArray[indexPath.row]
        
        if feeds.type == "2"{
            if (feeds.holeShotsArray?.count) == 9{
                height = 250.0 - 60
            }
            else{
                height = 250.0
            }
        }
        else {
            height = 250.0 + (300 - 108)
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if dataArray.count <= cellIndex{
            return dataArray.count
        }
        else
        {
            return cellIndex
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewHomeFeedViewCell", for: indexPath as IndexPath) as! NewHomeFeedViewCell
        
        let feeds = dataArray[indexPath.row]
        cell.userName.text = feeds.userName
        cell.userImg.setCircle(frame: cell.userImg.frame)
        cell.userImg.image = UIImage(named:"you")
        cell.userImg.backgroundColor = UIColor.lightGray
        if (feeds.userImage != nil) {
            cell.userImg.sd_setImage(with: URL(string: feeds.userImage!), placeholderImage:#imageLiteral(resourceName: "you"), completed: nil)
        }
        
        if(feeds.type == "2"){
            cell.btnEditRound.isHidden = false
            cell.lblSharedMsg.isHidden = true
            let subtitle = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
            if((feeds.location) != nil){
                cell.lblSubtitle.text = "\(subtitle) at \(feeds.location!)"
            }
            if let holesData = (feeds.holeShotsArray){
                var shotSum = 0
                var parSum = 0
                for i in 0..<holesData.count{
                    
                    if(i < 9){
                        
                        var index1 = 0
                        for btn in cell.scoreView1Shots.subviews{
                            if btn.isKind(of: UIButton.self){
                                if index1 == i{
                                    (btn as! UIButton).setTitleColor(UIColor.glfBlack, for: .normal)
                                    (btn as! UIButton).titleLabel?.font = UIFont(name: "SFProDisplay-Heavy", size: FONT_SIZE)
                                    (btn as! UIButton).setTitle("-", for: .normal)
                                    
                                    let layer = CALayer()
                                    layer.frame = CGRect(x: 3, y:  3, width: (btn as! UIButton).frame.width - 6, height: (btn as! UIButton).frame.height - 6)
                                    layer.borderColor = UIColor.clear.cgColor
                                    (btn as! UIButton).layer.addSublayer(layer)
                                    (btn as! UIButton).layer.borderColor = UIColor.clear.cgColor
                                    
                                    if(holesData[i].shot == 0){
                                        
                                        (btn as! UIButton).setTitle("-", for: .normal)
                                        self.updateButtons(allScore: 0, holeLbl: (btn as! UIButton))
                                    }
                                    else{
                                        (btn as! UIButton).setTitle("\(holesData[i].shot!)", for: .normal)
                                        self.updateButtons(allScore: holesData[i].par-holesData[i].shot, holeLbl: (btn as! UIButton))
                                        
                                        shotSum += holesData[i].shot
                                        parSum += holesData[i].par
                                        
                                    }
                                    break
                                }
                                index1 = index1 + 1
                            }
                        }
                        var index2 = 0
                        for btn in cell.scoreView1Par.subviews{
                            if btn.isKind(of: UIButton.self){
                                if index2 == i{
                                    (btn as! UIButton).setTitleColor(UIColor.glfFlatBlue, for: .normal)
                                    (btn as! UIButton).titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)
                                    (btn as! UIButton).setTitle("\(holesData[i].par!)", for: .normal)
                                    break
                                }
                                index2 = index2 + 1
                            }
                        }
                    }
                    else{
                        var index3 = 9
                        for btn in cell.scoreView2Shots.subviews{
                            if btn.isKind(of: UIButton.self){
                                if index3 == i{
                                    
                                    (btn as! UIButton).setTitleColor(UIColor.glfBlack, for: .normal)
                                    (btn as! UIButton).titleLabel?.font = UIFont(name: "SFProDisplay-Heavy", size: FONT_SIZE)
                                    (btn as! UIButton).setTitle("-", for: .normal)
                                    
                                    let layer = CALayer()
                                    layer.frame = CGRect(x: 3, y:  3, width: (btn as! UIButton).frame.width - 6, height: (btn as! UIButton).frame.height - 6)
                                    layer.borderColor = UIColor.clear.cgColor
                                    (btn as! UIButton).layer.addSublayer(layer)
                                    (btn as! UIButton).layer.borderColor = UIColor.clear.cgColor
                                    
                                    if(holesData[i].shot == 0){
                                        
                                        (btn as! UIButton).setTitle("-", for: .normal)
                                        self.updateButtons(allScore: 0, holeLbl: (btn as! UIButton))
                                    }
                                    else{
                                        (btn as! UIButton).setTitle("\(holesData[i].shot!)", for: .normal)
                                        self.updateButtons(allScore: holesData[i].par-holesData[i].shot, holeLbl: (btn as! UIButton))
                                        
                                        shotSum += holesData[i].shot
                                        parSum += holesData[i].par
                                    }
                                    break
                                }
                                index3 = index3 + 1
                            }
                        }
                        var index4 = 9
                        for btn in cell.scoreView2Par.subviews{
                            if btn.isKind(of: UIButton.self){
                                if index4 == i{
                                    (btn as! UIButton).setTitleColor(UIColor.glfFlatBlue, for: .normal)
                                    (btn as! UIButton).titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)
                                    (btn as! UIButton).setTitle("\(holesData[i].par!)", for: .normal)
                                    break
                                }
                                index4 = index4 + 1
                            }
                        }
                    }
                }
                cell.scoreView2.isHidden = false
                cell.scoreView1.isHidden = false
                cell.shareImageView.isHidden = true
                
                cell.shareImageHConstraint.constant = cell.frame.size.height
                //                self.view.layoutIfNeeded()
                
                if(holesData.count == 9){
                    cell.scoreView2.isHidden = true
                    
                    cell.shareImageHConstraint.constant = cell.frame.size.height - 60
                    self.view.layoutIfNeeded()
                }
                let shotDetails = shotSum > parSum ? "-over":"-under"
                let anoterString = shotSum > parSum ? "\(shotSum-parSum)":"\(parSum-shotSum)"
                cell.lblScoreTitle.text =  "\(anoterString) \(shotDetails) \(shotSum)"
                if(parSum) == 0{
                    cell.lblScoreTitle.text =  "Even par \(shotSum)"
                }
            }
        }
        else{
            cell.lblSharedMsg.isHidden = false
            cell.btnEditRound.isHidden = true
            let subtitle = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
            //if((feeds.location) != nil){
            cell.lblSubtitle.text = "\(subtitle)"
            //}
            if((feeds.message) != nil){
                cell.lblSharedMsg.text = "\(feeds.message!)"
            }
            cell.scoreView2.isHidden = true
            cell.scoreView1.isHidden = true
            cell.shareImageView.isHidden = false
            
            if (feeds.locationKey != nil) {
                
                cell.shareImageView.sd_setImage(with: URL(string: feeds.locationKey!), completed: nil)
                cell.shareImageHConstraint.constant = 300
                self.view.layoutIfNeeded()
            }
        }
        
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(self.usrProfileImageTapped(_:)))
        cell.userImg.isUserInteractionEnabled = true
        cell.userImg.tag = indexPath.row
        cell.userImg.addGestureRecognizer(imageGesture)
        // ------------------------------------------------------------------------------------------------------
        //        let gestureCardView = UITapGestureRecognizer(target: self, action:  #selector (self.showFinalScores (_:)))
        //        cell.stackViewToClick.tag = indexPath.row
        //        cell.stackViewToClick.addGestureRecognizer(gestureCardView)
        cell.btnScoreCard.addTarget(self, action: #selector(self.showFinalScores(_:)), for: .touchUpInside)
        cell.btnScoreCard.tag = indexPath.row
        
        var suffix = "Likes"
        if let likesCount = dataArray[indexPath.row].likesCount{
            
            if(likesCount == 0){
                suffix = "Like"
            }else if(likesCount == 1){
                suffix = "1 Like"
            }else{
                suffix = "\(likesCount) Likes"
            }
            cell.btnLike.setTitle("\(suffix)", for: .normal)
        }
        cell.btnLike.isSelected = false
        if(dataArray[indexPath.row].isLikedByMe)!{
            cell.btnLike.setImage(#imageLiteral(resourceName: "like_red"), for: .selected)
            cell.btnLike.isSelected = true
        }
        cell.btnLike.tag = indexPath.row
        cell.btnShare.tag = indexPath.row
        cell.btnEditRound.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(self.btnActionLike(_:)), for: .touchUpInside)
        cell.btnShare.addTarget(self, action: #selector(self.btnActionShare(_:)), for: .touchUpInside)
        cell.btnEditRound.addTarget(self, action: #selector(self.btnActionEditRound(_:)), for: .touchUpInside)
        //}
        self.cardViewMArray.add(cell.cardView)
        
        return cell
    }
    
    let borderWidth:CGFloat = 2.0
    func updateButtons(allScore:Int,holeLbl:UIButton){
        
        if allScore < -1{
            //double square
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = borderWidth
                    layer.borderColor = UIColor.glfRosyPink.cgColor
                }
            }
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfRosyPink.cgColor
            holeLbl.titleLabel?.layer.borderWidth = 0
            
        }
            
        else if allScore == -1{
            //single square
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfRosyPink.cgColor
            holeLbl.titleLabel?.layer.borderWidth = 0
        }
        else if allScore == 1{
            //single circle
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.titleLabel?.layer.borderWidth = 0
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfPaleTeal.cgColor
            holeLbl.layer.cornerRadius = holeLbl.frame.size.height/2
        }
        else if allScore > 1{
            //double circle
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = borderWidth
                    layer.borderColor = UIColor.glfPaleTeal.cgColor
                    layer.cornerRadius = layer.frame.height/2
                }
            }
            holeLbl.titleLabel?.layer.borderWidth = 0
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfPaleTeal.cgColor
            holeLbl.layer.cornerRadius = holeLbl.frame.size.height/2
        }else{
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.layer.borderWidth = 0
            holeLbl.titleLabel?.layer.borderWidth = 0
        }
    }
    
    //MARK: - Like and Share
    @objc func btnActionLike(_ sender:UIButton){
        var suffix = "Likes"
        if(sender.isSelected){
            dataArray[sender.tag].isLikedByMe = false
            sender.isSelected = false
            if(dataArray[sender.tag].likesCount != 0){
                dataArray[sender.tag].likesCount = dataArray[sender.tag].likesCount!-1
            }
            sender.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            ref.child("userData/\(Auth.auth().currentUser!.uid)/likes").updateChildValues([dataArray[sender.tag].feedId! :NSNull()] as [AnyHashable:Any])
            ref.child("feedData/\(dataArray[sender.tag].feedId!)/likes").updateChildValues([Auth.auth().currentUser!.uid :NSNull()] as [AnyHashable:Any])
            debugPrint("feedData/\(dataArray[sender.tag].feedId!)/likes/\(Auth.auth().currentUser!.uid)")
        }
        else{
            sender.isSelected = true
            dataArray[sender.tag].likesCount = dataArray[sender.tag].likesCount! + 1
            dataArray[sender.tag].isLikedByMe = true
            sender.setImage(#imageLiteral(resourceName: "like_red"), for: .selected)
            ref.child("userData/\(Auth.auth().currentUser!.uid)/likes").updateChildValues([dataArray[sender.tag].feedId! :true] as [AnyHashable:Any])
            ref.child("feedData/\(dataArray[sender.tag].feedId!)/likes").updateChildValues([Auth.auth().currentUser!.uid :true] as [AnyHashable:Any])
            debugPrint("feedData/\(dataArray[sender.tag].feedId!)/likes/\(Auth.auth().currentUser!.uid)")
        }
        if let likesCount = dataArray[sender.tag].likesCount{
            if(likesCount == 0){
                suffix = "Like"
            }else if(likesCount == 1){
                suffix = "1 Like"
            }else{
                suffix = "\(likesCount) Likes"
            }
            sender.setTitle("\(suffix)", for: .normal)
        }
    }
    //MARK: - btnActionEditRound
    var editWithTag:Int!
    @objc func btnActionEditRound(_ sender:UIButton){
        let editThisRound = EditPreviousGame()
        self.editWithTag = sender.tag
        editThisRound.continuePreviousMatch(matchId: dataArray[sender.tag].matchId!, userId: Auth.auth().currentUser!.uid)
        
    }
    // Mark: afterResponseEditRound
    @objc func afterResponseEditRound(_ notification:NSNotification){
        if(editWithTag != nil){
            self.dataArray.remove(at: editWithTag)
            self.feedTableView.reloadData()
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "editRoundHome"))
    }
    // MARK: - btnActionShare
    @objc func btnActionShare(_ sender:UIButton){
        let tagVal = sender.tag
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ShareStatsVC") as! ShareStatsVC
        viewCtrl.shareCardView = (cardViewMArray[tagVal] as! CardView)
        viewCtrl.fromFeed = true
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        navCtrl.modalPresentationStyle = .overCurrentContext
        self.present(navCtrl, animated: false, completion: nil)
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchID = dataArray[indexPath.row].matchId!
        self.getScoreFromMatchDataScoring(matchId:matchID)
    }
    
    // MARK: - usrProfileImageTapped
    @objc func usrProfileImageTapped(_ sender:UITapGestureRecognizer){
        let index = (sender.view?.tag)!
        if(index < dataArray.count){
            let feeds = dataArray[index]
            
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileVC
            viewCtrl.userKey = feeds.userKey!
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    // MARK: - showFinalScores
    @objc func showFinalScores(_ sender:UIButton){
        let index = sender.tag
        if(dataArray.count > Int(index)){
            if let matchID = dataArray[index].matchId{
                self.getScoreFromMatchDataScoring(matchId:matchID)
            }
        }
    }
    
    // MARK: - getScoreFromMatchDataScoring
    func getScoreFromMatchDataScoring(matchId:String){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        self.scoring.removeAll()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
            //            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            var matchDict = NSDictionary()
            if(snapshot.childrenCount > 1){
                matchDict = (snapshot.value as? NSDictionary)!
            }
            var scoreArray = NSArray()
            var keyData = String()
            var playersKey = [String]()
            for (key,value) in matchDict{
                keyData = key as! String
                if(keyData == "player"){
                    for (k,_) in value as! NSMutableDictionary{
                        playersKey.append(k as! String)
                    }
                }
                else if (keyData == "scoring"){
                    scoreArray = (value as! NSArray)
                }
                else if(keyData == "scoringMode"){
                    isManualScoring = false
                    if(value as! String) != "advanced"{
                        isManualScoring = true
                    }
                }else if(keyData == "courseId"){
                    matchDataDiction.setObject(value, forKey: "courseId" as NSCopying)
                }else if (keyData == "courseName"){
                    matchDataDiction.setObject(value, forKey: "courseName" as NSCopying)
                }else if(keyData == "startingHole"){
                    matchDataDiction.setObject(value, forKey: "startingHole" as NSCopying)
                }else if (keyData == "matchType"){
                    matchDataDiction.setObject(value, forKey: "matchType" as NSCopying)
                }
            }
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
                            playersArray.append(dict)
                        }
                    }
                }
                self.scoring.append((hole: i, par:par,players:playersArray))
            }
            let players = NSMutableArray()
            if(matchDict.object(forKey: "player") != nil){
                let tempArray = matchDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    players.add(dict)
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
                viewCtrl.finalPlayersData = players
                viewCtrl.finalScoreData = self.scoring
                viewCtrl.isManualScoring = isManualScoring
                viewCtrl.matchDataDict = matchDataDiction
                viewCtrl.currentMatchId = matchId
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            })
        }
    }
}

extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}
extension NewHomeVC:CLLocationManagerDelegate{
    func locationUpdate(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.startMonitoringSignificantLocationChanges()
//        self.locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation = locations.last!
        let userLocationForClub = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

        if Constants.matchId.isEmpty{
            self.getNearByData(latitude: userLocationForClub.latitude, longitude: userLocationForClub.longitude, currentLocation: userLocation)
        }
    }
    func getNearByData(latitude: Double, longitude: Double,currentLocation: CLLocation){
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    // In case of -1 response
                })
            }
            else{
                var dataArr =  [NSMutableDictionary]()
                
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
                        dataArr.append(dataDic)
                    }
                    group.leave()
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    if !dataArr.isEmpty{
                        dataArr = BackgroundMapStats.sortAndShow(searchDataArr: dataArr, myLocation: currentLocation)
                        let golfName = (dataArr[0].value(forKey: "Name") as? String) ?? ""
                        let golfDistance = (dataArr[0].value(forKey: "Distance") as? Double) ?? 0.0
                        
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/nearByGolfClub").updateChildValues(["\(Timestamp)":golfDistance])
                        if golfDistance < 1500.0 && golfName != ""{
                            UserDefaults.standard.set(golfName, forKey: "NearByGolfClub")
                            UserDefaults.standard.synchronize()
                            FBSomeEvents.shared.logFindLocationEvent()
                            Notification.sendLocaNotificatonNearByGolf()
                        }
                    }
                })
            }
        }
    }
}
