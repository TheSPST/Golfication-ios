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

var strokesGainedDict = [NSMutableDictionary]()
var isUpdateInfo = false
var isProfileUpdated = false
var strkGainedString = ["strokesGained","strokesGained1","strokesGained2","strokesGained3","strokesGained4"]
var ble: BLE!
var clubWithMaxMin = [(name:String,max:Int,min:Int)]()
var isDevice = Bool()
var isProMode = Bool()

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

class NewHomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomProModeDelegate {
    // MARK: - Set Outlets
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notifStackView: UIStackView!
    @IBOutlet weak var proLabelProfileStackView: UIStackView!
    
    @IBOutlet weak var btnNotif: UIButton!
    @IBOutlet weak var btnProfileImage: UIButton!
    @IBOutlet weak var btnProfileBasic: UIButton!
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnScoreDetail: UIButton!
    @IBOutlet weak var btnPlayFriends: UIButton!
    @IBOutlet weak var btnPractice: UIButton!
    @IBOutlet weak var btnScoreTab: UIButton!
    @IBOutlet weak var btnSGTab: UIButton!
    @IBOutlet weak var btnStatsTab: UIButton!
    @IBOutlet weak var btnGoPRO: UIButton!
    @IBOutlet weak var btnStartGame: UIButton!
    @IBOutlet weak var btnPreOrder: UIButton!
    @IBOutlet weak var btnInvite: UIButton!
    
    @IBOutlet weak var viewScoreStats: UIView!
    @IBOutlet weak var viewMySwing: UIView!
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
    @IBOutlet weak var viewInvite: UIView!
    
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
    
    @IBOutlet weak var playGolfStackView: UIStackView!
    @IBOutlet weak var scoreBarChartView: BarChartView!
    @IBOutlet weak var SGBarChartView: BarChartView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedTableView: UITableView!
    
    // @IBOutlet weak var strokeGainedChartView: CardView!
    let progressView = SDLoader()
    
    // MARK: - Initialize Variables
    var genderData : String!
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
    var profileHandicap: String?
    var profileScoring: Int?
    
    var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
    let catagoryWise = ["Off The Tee","Approach","Around The Green","Putting"]
    let clubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"]
    var clubData = ["Dr":"Driver","w":"Wood","h":"Hybrid","i":"Iron","Pw":"Pitching Wedge","Gw":"Gap Wedge","Sw":"Sand Wedge","Lw":"Lob Wedge","Pu":"Putter"]
    var cardViewMArray = NSMutableArray()
    var cellIndex = 5
    var clubInsideGolfClub = [String]()
    
    var isTrial = false
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
    }
    
    // MARK: - upgradeAction
    @IBAction func upgradeAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.05)
    }
    
    // MARK: - playFriendsAction
    @IBAction func playFriendsAction(_ sender: Any) {
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // \
    @IBAction func notifiAction(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "UpdateDeviceFrameworkViewCtrl") as! UpdateDeviceFrameworkViewCtrl
//        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "MultiplayerTeeSelectionVC") as! MultiplayerTeeSelectionVC
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - profileAction
    @IBAction func profileAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        viewCtrl.fromPublicProfile = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
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
            }
        }
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
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let strockesGainedVC = storyboard.instantiateViewController(withIdentifier: "StrokesGainedVC") as! StrokesGainedVC
        self.navigationController?.pushViewController(strockesGainedVC, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
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
        let viewCtrl = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - startGameAction
    @IBAction func startGameAction(_ sender: Any) {
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - goProAction
    @IBAction func goProAction(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "HomeFreeProMemberVC") as! HomeFreeProMemberVC
        viewCtrl.modalPresentationStyle = .overCurrentContext
        present(viewCtrl, animated: true, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.free30DaysProActivated(_:)), name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
    }
    
    @objc func free30DaysProActivated(_ notification: NSNotification) {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
        
        self.btnUpgrade.isHidden = true
        self.proLabelProfileStackView.isHidden = true
        self.viewBecomePro.isHidden = true
        self.view.layoutIfNeeded()
        
        self.btnProfileBasic.setTitle("PRO", for: .normal)
        self.btnProfileBasic.backgroundColor = UIColor(rgb: 0xFFC700)
        self.btnProfileBasic.setTitleColor(UIColor.white, for: .normal)
    }
    

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterResponseEditRound(_:)), name: NSNotification.Name(rawValue: "editRound"), object: nil)

        //        Notification.sendNotification(reciever: "UhEPp4X2cAaPNOKdY6OOsoZ348L2", message: "Amit just finished a round at Qutab Golf Course.", type: "8", category: "finishedGame", matchDataId: "-LEEX_IIesOFOyZWkiu-", feedKey:"")
        
        //---------------------------- Update Versin details to Firebase --------------------------
        //https://github.com/dennisweissmann/DeviceKit
        let versionInfo = NSMutableDictionary()
        versionInfo.setObject("iOS \(UIDevice.current.systemVersion)", forKey: "osVersion" as NSCopying)
        versionInfo.setObject("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!) Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)", forKey: "appVersion" as NSCopying)
        versionInfo.setObject("\(Device())", forKey: "model" as NSCopying)
        
        let versionDetails = ["info":versionInfo]
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(versionDetails)
        //-----------------------------------------------------------------------------------------
        
        self.feedTableView.isHidden = true
        self.view.layoutIfNeeded()
        // ------------------------ Set User Name & Profile Image ------------------------------
        lblUserName.text = "Hi \(Auth.auth().currentUser?.displayName ?? "Guest")"
        if Auth.auth().currentUser?.photoURL == nil{
            btnProfileImage.setBackgroundImage(UIImage(named:"you"), for: .normal)
        }
        else{
            btnProfileImage.sd_setBackgroundImage(with: Auth.auth().currentUser?.photoURL ?? URL(string:""), for: .normal, completed: nil)
        }
        //-------------------------------------------------------------------
        
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
        
        let gestureViewProfile = UITapGestureRecognizer(target: self, action:  #selector (self.profileAction (_:)))
        viewProfile.addGestureRecognizer(gestureViewProfile)
        
        let gestureMySwing = UITapGestureRecognizer(target: self, action:  #selector (self.mySwingAction (_:)))
        viewMySwing.addGestureRecognizer(gestureMySwing)
        
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
        
        let rndom = Int(arc4random_uniform(100))
        viewInvite.isHidden = rndom < 40 ? false : true
        
        self.setInitialUI()
        self.getStrokesGainedFirebaseData()
    }
    
    func getClubDataFromFirebase(isShow:Bool){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "clubsData") { (snapshot) in
            let clubDataDict = snapshot.value as! [String:NSMutableDictionary]
            DispatchQueue.main.async(execute: {
                clubWithMaxMin.removeAll()
                for (key, value) in clubDataDict{
                    clubWithMaxMin.append((name: key, max: value.value(forKey: "max") as! Int, min: value.value(forKey: "min") as! Int))
                }
                clubWithMaxMin.append((name: "Pu", max: 22, min: 1))
                self.setSGAndSmartCaddieData(isShow:isShow)
            })
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
                (self.scoreBarChartView.superview)?.addSubview(demolbl)
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
        
        lblClubStatName.text = "-"
        if let club = clubName{
            lblClubStatName.text = getClubName(club: club)
        }
        
        if(strokesGainedValue == -100){
            lblClubStatSG.text = "--"
        }else{
            lblClubStatSG.text = "\(strokesGainedValue?.rounded(toPlaces: 2) ?? 0.0)"
        }
        
        if((strokesCount) != nil && strokesCount! > 0.0){
            let strokesGainedAvg = strokesGained! / strokesCount!
            lblClubStatAvgDist.text = "\(strokesGainedAvg.rounded(toPlaces: 2))"
        }
        
        let clubDict = self.transferDataIntoClasses(myDataArray: self.filteredArray)
        self.createSmartDataWith(clubDict: clubDict)
        strokesGainedData.removeAll()
        strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
        
        for data in self.catagoryWise{
            self.strokesGainedData.append((data,0.0,0.0,0,0.0))
        }
        
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
            dataPoints.append(data.clubType)
            dataValues.append(data.clubStrokesGained / Double(data.clubCount))
        }
        
        let demolbl = DemoLabel()
        demolbl.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        demolbl.center = ((self.SGBarChartView.superview)?.center)!
        if(isShow){
            (self.SGBarChartView.superview)?.addSubview(demolbl)
        }
        self.progressView.hide(navItem: self.navigationItem)
        SGBarChartView.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: SGBarChartView, color: UIColor.glfSeafoamBlue, barWidth: 0.2,valueColor: UIColor.glfWarmGrey.withAlphaComponent(0.5))
        SGBarChartView.leftAxis.gridColor = UIColor.glfWarmGrey.withAlphaComponent(0.25)
        SGBarChartView.leftAxis.labelTextColor  = UIColor.glfWarmGrey.withAlphaComponent(0.5)
        SGBarChartView.xAxis.labelTextColor = UIColor.glfWarmGrey.withAlphaComponent(0.5)
        SGBarChartView.isUserInteractionEnabled = false
        SGBarChartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: 10.0)!
    }
    
    func createSmartDataWith(clubDict:[(String,Club)]){
        var clubWithAllDistance = [(club:String,arr:[Double])]()
        for club in self.clubs{
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
                for j in 0..<clubWithMaxMin.count where clubWithMaxMin[j].name == clubWithAllDistance[i].club{
                    clubWithMaxMin[j].max  = Int(clubWithAllDistance[i].arr.max()!)
                    clubWithMaxMin[j].min  = Int(clubWithAllDistance[i].arr.min()!)
                }
            }
        }
    }
    
    func transferDataIntoClasses(myDataArray:[NSDictionary])->[(String,Club)]{
        var clubDict = [(String,Club)]()
        for i in 0..<myDataArray.count{
            if let smartCaddieDic = ((myDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                for key in self.clubs{
                    let keysArray = smartCaddieDic.value(forKeyPath: "\(key)")
                    if((keysArray) != nil){
                        let valueArray = keysArray as! NSArray
                        for j in 0..<valueArray.count{
                            let clubData = Club()
                            let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing")
                            if((backSwing) != nil){
                                clubData.backswing = backSwing as! Double
                            }
                            let distance = (valueArray[j] as AnyObject).object(forKey: "distance")
                            if((distance) != nil){
                                clubData.distance = distance as! Double
                            }
                            
                            var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                            if let strk = (valueArray[j] as AnyObject).object(forKey: strkGainedString[skrokesGainedFilter]) as? Double{
                                strokesGained = strk
                            }
                            clubData.strokesGained = strokesGained
                            
                            let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore")
                            if((swingScore) != nil){
                                clubData.swingScore = swingScore as! Double
                            }
                            let type = (valueArray[j] as AnyObject).object(forKey: "type")
                            if((type) != nil){
                                clubData.type = type as! Int
                            }
                            let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity")
                            if((proximity) != nil){
                                clubData.proximity = proximity as! Double
                            }
                            let holeout = (valueArray[j] as AnyObject).object(forKey: "holeout")
                            if((holeout) != nil){
                                clubData.holeout = holeout as! Double
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
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.2)
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: - mySwingAction
    @objc func mySwingAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
//        getSwingData()
    }
    
    func getSwingData() {
        var swingMArray = NSMutableArray()
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession") { (snapshot) in
            
            if(snapshot.value != nil){
                
                if let dataDic = snapshot.value as? [String:Bool]{
                    let group = DispatchGroup()
                    for (key, value) in dataDic{
                        group.enter()
                        
                        if value == false{
                            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                                if(snapshot.value != nil){
                                    if let data = snapshot.value as? NSDictionary{
                                        if data.value(forKey: "swings") != nil{
                                        swingMArray.add(data)
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
                        
                        let storyboard = UIStoryboard(name: "Home", bundle: nil)
                        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "SwingSessionVC") as! SwingSessionVC
                        viewCtrl.dataMArray = swingMArray
                        self.navigationController?.pushViewController(viewCtrl, animated: true)
                    })
                }
            }
        }
    }
    
    // MARK: - setInitialUI
    func setInitialUI(){
        btnPreOrder.layer.cornerRadius = 3.0
        btnPreOrder.setTitle("Pre order Now!", for: .normal)
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
        
        btnContinue.layer.borderWidth = 1.0
        btnContinue.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnContinue.layer.cornerRadius = 3.0
        
        btnScoreDetail.layer.borderWidth = 1.0
        btnScoreDetail.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnScoreDetail.layer.cornerRadius = 3.0
        
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
        
        let gradient = CAGradientLayer()
        gradient.frame = btnPlayFriends.bounds
        gradient.colors = [UIColor(rgb: 0x2E6594).cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnPlayFriends.layer.insertSublayer(gradient, at: 0)
        btnPlayFriends.layer.cornerRadius = 3.0
        btnPlayFriends.layer.masksToBounds = true
        
        btnPractice.layer.cornerRadius = 3.0
        btnPractice.layer.masksToBounds = true
        
        btnInvite.layer.cornerRadius = 3.0
    }
    
    // MARK: - startGameAction
    @IBAction func practiceAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "ScanningVC") as! ScanningVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - mySwingAction
    @IBAction func mySwingBtnAction(_ sender: UIButton) {
        self.mySwingAction(sender)
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        // ---------------- Google Analytics --------------------------------------
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Home Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        getUserDataFromFireBase()
    }
    // MARK: getStrokesGainedFirebaseData
    func getStrokesGainedFirebaseData(){
        strokesGainedDict.removeAll()
        let group = DispatchGroup()
        for i in 0..<strkGainedString.count{
            group.enter()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: strkGainedString[i]) { (snapshot) in
                strokesGainedDict.append(snapshot.value as! NSMutableDictionary)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            debugPrint("strockesGainedReaded")
        }
    }
    // MARK: getUserDataFromFireBase
    func getUserDataFromFireBase() {
        matchId.removeAll()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            if(snapshot.childrenCount > 0){
                var userData = NSDictionary()
                userData = snapshot.value as! NSDictionary
                
                if let unit = userData.object(forKey: "unit") as? Int{
                    distanceFilter = unit
                }
                if let notification = userData.object(forKey: "notification") as? Int{
                    onCourseNotification = notification
                }
                if let strokesGained = userData.object(forKey: "strokesGained") as? Int{
                    skrokesGainedFilter = strokesGained
                }
                if let device = userData.object(forKey: "device") as? Bool{
                    isDevice = device
                }
                if let trial = userData.value(forKey: "trial") as? Bool{
                    self.isTrial = trial
                }
                if let proMode = userData.value(forKey: "proMode") as? Bool{
                    isProMode = proMode
                    self.btnUpgrade.isHidden = false
                    
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
                                if (proMembership.value(forKey: "productID") as! String == "pro_subscription_monthly") || (proMembership.value(forKey: "productID") as! String == "pro_subscription_trial_monthly") || (proMembership.value(forKey: "productID") as! String == "Free_Membership"){
                                    
                                    timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
//                                    timeEnd = Calendar.current.date(byAdding: .minute, value: 5, to: timeStart as Date)
                                 }
                                
                                let timeNow = NSDate()
                                let calendar = NSCalendar.current
                                let components = calendar.dateComponents([.day], from: timeNow as Date, to: timeEnd!)
                                if components.day == 0 || components.day! < 0{
                            if let device = proMembership.value(forKey: "device") as? String{
                                        
                                    if (device == "ios") || ((device == "android") && (proMembership.value(forKey: "productID") as! String == "Free_Membership")){
                                        
                                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["trial" :true] as [AnyHashable:Any])
                                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMembership" :NSNull()] as [AnyHashable:Any])
                                    
                                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :false] as [AnyHashable:Any])
                                    isProMode = false
                                    
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
                                        
                                        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
                                        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.05)
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
                    // Data for card 5
                    if (statistics["card5"] as? NSDictionary) != nil{
                        //self.homeVCModel.card4AchievDic = card5
                    }
                }
                if let scoring = userData.value(forKey: "scoring") as? NSDictionary{
                    self.profileScoring = Int(scoring.count)
                    let dataArray = scoring.allValues as NSArray
                    self.filteredArray = [NSDictionary]()
                    self.filteredArray = dataArray as! [NSDictionary]
                }
                if let activeMatches = userData["activeMatches"] as? [String:Bool]{
                    for data in activeMatches{
                        if(data.value){
                            matchId = data.key
                        }
                        else if(!data.value){
                            
                        }
                    }
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
                }
                if let lastCourseDic = userData["lastCourseDetails"] as? NSDictionary{
                    if let mapped = lastCourseDic.object(forKey: "mapped") as? String{
                        self.mappedStr = mapped
                    }
                }
                if let handicap = userData["handicap"] as? String{
                    self.profileHandicap = handicap
                }
                if let gender = userData["gender"] as? String{
                    self.genderData = gender
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
                                golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                                
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
                self.setMyData()
                if(self.round_score.count == 0){
                    self.updateCard4(path: "userData/user1/statistics")
                }
                if self.profileScoring == nil{
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/user1/scores") { (snapshot) in
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
            })
        }
    }
    
    func getFeedDataFromFirebase(key: String, group:DispatchGroup){
        
        if(self.dataArray.count == 0) || isUpdateInfo{
            
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
        
        if !isProMode {
            self.setProLockedUI(targetView: self.viewSGTab)
        }
        lblProfileHomeCourse.text = self.profileHomeCourse ?? "-"
        lblProfileHandicap.text = "\(self.profileHandicap ?? "0")"
        lblProfileScoring.text = "\(self.profileScoring ?? 0)"
        
        self.btnProfileBasic.setTitle("Basic", for: .normal)
        self.btnProfileBasic.backgroundColor = UIColor.white
        self.btnProfileBasic.setTitleColor(UIColor(rgb: 0x003D33), for: .normal)
        
        if UserDefaults.standard.object(forKey: "isNewUser") as? Bool != nil{
            let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
            if (newUser && !isProMode){
                if (self.profileHomeCourse != nil && self.profileHomeCourse != "") || (mappedStr == "2"){
                    if !isTrial{
                    self.viewBecomePro.isHidden = false
                    self.view.layoutIfNeeded()
                    }
                }
            }
        }
        if isProMode{
            self.btnUpgrade.isHidden = true
            self.proLabelProfileStackView.isHidden = true
            self.viewBecomePro.isHidden = true
            self.view.layoutIfNeeded()
            
            self.btnProfileBasic.setTitle("PRO", for: .normal)
            self.btnProfileBasic.backgroundColor = UIColor(rgb: 0xFFC700)
            self.btnProfileBasic.setTitleColor(UIColor.white, for: .normal)
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
                                selectedGolfName = value as! String
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
                                    holeShotPar.par = value as! Int
                                    par = value as! Int
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
                                            holeShotPar.shot = dict.value(forKey: "strokes") as! Int
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
            //            feedNumber = feedNumber.sorted()
            //            for j in 0..<feedNumber.count{
            //                self.dataArray.remove(at: feedNumber[j]-j)
            //
            //            }
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
                
                //--------- Check if new version available -------------------------
                _ = try? self.isUpdateAvailable { (newVersion, update, error) in
                    if let error = error {
                        debugPrint(error)
                    }
                    else if let update = update {
                        if update{
                            if UserDefaults.standard.object(forKey: "isNewVersion") as? Bool != nil{
                                let isNewVersion = UserDefaults.standard.object(forKey: "isNewVersion") as! Bool
                                if !isNewVersion{
                                    self.showNewVersionPopup(newVersion:newVersion!)
                                }
                            }
                            else{
                                self.showNewVersionPopup(newVersion:newVersion!)
                            }
                        }
                    }
                }
                //-------------------------------------------------------------------------

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
    
    func showNewVersionPopup(newVersion: String) {
        UserDefaults.standard.set(true, forKey: "isNewVersion")
        UserDefaults.standard.synchronize()
        
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
        let skipBtn = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(skipBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - setData
    func setData() {
        // ------- check active match ------------------
        var isActiveMatch = false
        if(matchId.count > 0){
            isActiveMatch = true
        }
        
        if isActiveMatch{
            if(!isShowCase){
                if(matchId.count > 1){
                    
                    self.getScoreFromMatchDataFirebase(keyId:matchId)
                    lblGameStatus.text = "Current Round"
                    viewRecentGame.isHidden = false
                    viewPreviousGame.isHidden = true
                    viewNewGame.isHidden = true
                }
            }
        }
        else{
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
                    lblGameStatus.text = "Start Game"
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
                lblGameStatus.text = "Start Game"
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
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        btnScoreDetail.isEnabled = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(keyId)/") { (snapshot) in
            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                matchDataDic = matchDict as! NSMutableDictionary
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
                        selectedLat = value as! String
                    }
                    if(keyData == "lng"){
                        selectedLong = value as! String
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
                            par = value as! Int
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
                
                self.progressView.hide(navItem: self.navigationItem)
                
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
            
            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                matchDataDic = matchDict as! NSMutableDictionary
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
                        selectedLat = value as! String
                    }
                    if(keyData == "lng"){
                        selectedLong = value as! String
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
                            par = value as! Int
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
                self.players.removeAllObjects()
                self.players = NSMutableArray()
                if(matchDataDic.object(forKey: "player") != nil){
                    let tempArray = matchDataDic.object(forKey: "player")! as! NSMutableDictionary
                    for (k,v) in tempArray{
                        if let dict = v as? NSMutableDictionary{
                            dict.addEntries(from: ["id":k])
                            self.players.add(dict)
                        }
                    }
                    self.progressView.hide(navItem: self.navigationItem)
                    self.btnContinue.isEnabled = true
                    self.lblContinueGolfName.text = self.selectedHomeGolfName + " - \(self.holeType)" + " holes"
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
    @objc func btnActionEditRound(_ sender:UIButton){
        let editThisRound = EditPreviousGame()
        editThisRound.continuePreviousMatch(matchId: dataArray[sender.tag].matchId!, userId: Auth.auth().currentUser!.uid)
    }
    // Mark: afterResponseEditRound
    @objc func afterResponseEditRound(_ notification:NSNotification){
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "editRound"))
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
                }
            }
            for i in 0..<scoreArray.count {
                var playersArray = [NSMutableDictionary]()
                var par:Int!
                let score = scoreArray[i] as! NSDictionary
                for(key,value) in score{
                    if(key as! String == "par"){
                        par = value as! Int
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
