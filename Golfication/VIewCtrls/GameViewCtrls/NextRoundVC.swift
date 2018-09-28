//
//  NextRoundVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 20/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseAnalytics

class NextRoundVC: UIViewController {
    @IBOutlet weak var btnPrevClassic: UIButton!
    @IBOutlet weak var btnPrevRf: UIButton!
    @IBOutlet weak var btnPrevShotTrack: UIButton!
    @IBOutlet weak var btnRequestMapping: UIButton!
    
    @IBOutlet weak var btnPrevContainerView: UIView!
    
    @IBOutlet weak var prevClassicBottomView: UIView!
    @IBOutlet weak var prevRfBottomView: UIView!
    @IBOutlet weak var prevShotBottomView: UIView!
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var lblTopSubTitle: UILabel!
    @IBOutlet weak var lblBottomTitle: UILabel!
    @IBOutlet weak var lblBottomSubTitle: UILabel!
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var popUpContainerView: UIView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var overlappingView: UIView!
    @IBOutlet weak var lblOverlapping: UILabel!
    
    @IBOutlet weak var popUpSubView: CardView!
    
    
    let progressView = SDLoader()
    
    var selectedMode = 0
    var selectedTab = 0
    var scoringMode = String()
    var currentLocationOfUser = CLLocationCoordinate2D()
    var finalMatchDic = NSMutableDictionary()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var requestedMatchId = String()
    
    // MARK: backAction
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionForRequestMapping(_ sender: UIButton) {
        if(Auth.auth().currentUser!.uid.count > 1){
            ref.child("unmappedCourseRequest/\(Auth.auth().currentUser!.uid)/").updateChildValues([selectedGolfID:Timestamp] as [AnyHashable:Any])
        }
        //        let alert = UIAlertController(title: "Alert", message: "Thanks for your request. We will notify you when this course is mapped for advanced scoring.", preferredStyle: UIAlertControllerStyle.alert)
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //        self.present(alert, animated: true, completion: nil)
        btnRequestMapping.isHidden = true
        lblOverlapping.text = "Thanks for your request. We will notify you when this course is mapped for advanced scoring."
    }
    let locationManager = CLLocationManager()

    @IBAction func startGameAction(sender: UIButton) {
        if selectedMode == 0 && (selectedTab == 1 || selectedTab == 2){
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestAlwaysAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
                    let location2 = CLLocation(latitude: Double(selectedLat)!, longitude: Double(selectedLong)!)
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
        else{
            popUpContainerView.isHidden = false
        }
    }
    
    @IBAction func skipAction(sender: UIButton) {
        addPlayersArray = NSMutableArray()
        
        popUpContainerView.isHidden = true
        let gameCompleted = StartGameModeObj()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        if selectedTab == 0{
            // setup Classic Map
            NotificationCenter.default.addObserver(self, selector: #selector(self.classicCompleted(_:)), name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: nil)
            gameCompleted.setUpClassicMap(onCourse:selectedMode)
        }
        else if selectedTab == 1 && selectedMode == 0{
            // setup rangefinder
            NotificationCenter.default.addObserver(self, selector: #selector(self.rfApiCompleted(_:)), name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
            gameCompleted.setUpRFMap(golfId: "course_\(selectedGolfID)",onCourse:selectedMode)
        }
        else{
            // setup post game short tracker or ultimate short tracking
            NotificationCenter.default.addObserver(self, selector: #selector(self.defaultMapApiCompleted(_:)), name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
            gameCompleted.showDefaultMap(onCourse:selectedMode)
        }
    }
    
    @objc func classicCompleted(_ notification: NSNotification) {
        let notifScoring = notification.object as! [(hole:Int,par:Int,players:[NSMutableDictionary])]
        self.progressView.hide(navItem: self.navigationItem)
        
        if(notifScoring.count > 0){
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "BasicScoringVC") as! BasicScoringVC
            viewCtrl.matchDataDict = matchDataDic
            viewCtrl.scoreData = notifScoring
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else{
            let emptyAlert = UIAlertController(title: "Alert", message: "This golf course is not available right now", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: nil)
    }
    
    @objc func rfApiCompleted(_ notification: NSNotification) {
        let notifGolfId = notification.object as! String
        self.progressView.hide(navItem: self.navigationItem)
        
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
        viewCtrl.matchDataDic = matchDataDic
        viewCtrl.isContinueMatch = false
        viewCtrl.matchId = matchId
        viewCtrl.courseId = notifGolfId
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
    }
    
    @objc func defaultMapApiCompleted(_ notification: NSNotification) {
        let notifScoring = notification.object as! [(hole:Int,par:Int,players:[NSMutableDictionary])]
        self.progressView.hide(navItem: self.navigationItem)
        
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
        
        viewCtrl.matchDataDict = matchDataDic
        viewCtrl.isContinue = false
        viewCtrl.currentMatchId = matchId
        viewCtrl.scoring = notifScoring
        viewCtrl.courseId = "course_\(selectedGolfID)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
    }
    
    @IBAction func addFriendAction(sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        viewCtrl.selectedMode = selectedMode
        viewCtrl.selectedTab = selectedTab
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        popUpContainerView.isHidden = true
    }
    
    @IBAction func prevClassicAction(sender: UIButton) {
        selectedTab = 0
        btnPrevClassic.setCorner(color: UIColor.glfBluegreen.cgColor)
        btnPrevRf.setCorner(color: UIColor.clear.cgColor)
        btnPrevShotTrack.setCorner(color: UIColor.clear.cgColor)
        
        prevClassicBottomView.backgroundColor = UIColor.white
        prevRfBottomView.backgroundColor = UIColor.glfBluegreen
        prevShotBottomView.backgroundColor = UIColor.glfBluegreen
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard",attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-Tracking",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_active"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_inactive"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_inactive"), for: .normal)
        
        if selectedMode == 1{
            let rfTitle = NSAttributedString(string: "Post-Game Shot-Tracker",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
            btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
            btnPrevRf.setImage(#imageLiteral(resourceName: "post_inactive"), for: .normal)
        }
        
        lblTopTitle.text = "Classic Scorecard"
        lblTopSubTitle.text = "(For Basic Users)"
        lblBottomTitle.text = "Fast and easy"
        lblBottomSubTitle.text = "Record hole-scores, fiarways, GIRs and\nputts for you and your friends."
        imageVIew.image = #imageLiteral(resourceName: "classic_score")
        
        
        self.btnStart.isEnabled = true
        self.btnStart.backgroundColor = UIColor.glfBluegreen
        self.overlappingView.isHidden = true
    }
    
    @IBAction func prevRfAction(sender: UIButton) {
        selectedTab = 1
        btnPrevClassic.setCorner(color: UIColor.clear.cgColor)
        btnPrevRf.setCorner(color: UIColor.glfBluegreen.cgColor)
        btnPrevShotTrack.setCorner(color: UIColor.clear.cgColor)
        
        prevClassicBottomView.backgroundColor = UIColor.glfBluegreen
        prevRfBottomView.backgroundColor = UIColor.white
        prevShotBottomView.backgroundColor = UIColor.glfBluegreen
        
        btnPrevClassic.setTitleColor(UIColor.darkGray, for: .normal)
        btnPrevRf.setTitleColor(UIColor(rgb: 0x0E220D), for: .normal)
        btnPrevShotTrack.setTitleColor(UIColor.darkGray, for: .normal)
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder",attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-Tracking",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_inactive"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_active"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_inactive"), for: .normal)
        
        lblTopTitle.text = "Smart Rangefinder"
        lblTopSubTitle.text = "(Most Popular)"
        lblBottomTitle.text = "Fast and accurate distances."
        lblBottomSubTitle.text = "Free distances and club-recommendations.\nLive scoring availabe."
        imageVIew.image = #imageLiteral(resourceName: "range_finder")
        
        if selectedMode == 1{
            let rfTitle = NSAttributedString(string: "Post-Game Shot-Tracker",attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
            btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
            btnPrevRf.setImage(#imageLiteral(resourceName: "post_active"), for: .normal)
            
            lblTopTitle.text = "Post-Game Shot-Tracking"
            lblTopSubTitle.text = "(For Advanced Users)"
            lblBottomTitle.text = "Advanced Stats and Analytics"
            lblBottomSubTitle.text = "Time-intensive, but feature-packed! Plot each shot as it was actually played, to access unbeatable insights."
            imageVIew.image = #imageLiteral(resourceName: "post_shot")
            if(self.scoringMode != "Advanced(GPS)"){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
                self.overlappingView.isHidden = false
                //                btnRequestMapping.isHidden = false
                //                lblOverlapping.text = "Shot tracking is currently unavailable for this course. If you play on this course often let us know and we'll work on it."
            }
            
        }else{
            self.setBgViewForRequestMaping()
        }
    }
    func setBgViewForRequestMaping(){
        switch self.scoringMode {
        case "classic":
            if(selectedTab != 0){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
                self.overlappingView.isHidden = false
                //                btnRequestMapping.isHidden = false
                //                lblOverlapping.text = "Shot tracking is currently unavailable for this course. If you play on this course often let us know and we'll work on it."
                
            }
            break
        case "rangeFinder":
            if(selectedTab > 1){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
                self.overlappingView.isHidden = false
                //                btnRequestMapping.isHidden = false
                //                lblOverlapping.text = "Shot tracking is currently unavailable for this course. If you play on this course often let us know and we'll work on it."
                
                
            }else{
                self.btnStart.isEnabled = true
                self.btnStart.backgroundColor = UIColor.glfBluegreen
                self.overlappingView.isHidden = true
            }
            break
        default:
            self.btnStart.isEnabled = true
            self.btnStart.backgroundColor = UIColor.glfBluegreen
            self.overlappingView.isHidden = true
            break
        }
    }
    
    @IBAction func prevShotTrackAction(sender: UIButton) {
        selectedTab = 2
        self.setBgViewForRequestMaping()
        btnPrevClassic.setCorner(color: UIColor.clear.cgColor)
        btnPrevRf.setCorner(color: UIColor.clear.cgColor)
        btnPrevShotTrack.setCorner(color: UIColor.glfBluegreen.cgColor)
        
        prevClassicBottomView.backgroundColor = UIColor.glfBluegreen
        prevRfBottomView.backgroundColor = UIColor.glfBluegreen
        prevShotBottomView.backgroundColor = UIColor.white
        
        btnPrevClassic.setTitleColor(UIColor.darkGray, for: .normal)
        btnPrevRf.setTitleColor(UIColor.darkGray, for: .normal)
        btnPrevShotTrack.setTitleColor(UIColor(rgb: 0x0E220D), for: .normal)
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-Tracking",attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_inactive"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_inactive"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_active"), for: .normal)
        
        lblTopTitle.text = "Ultimate Shot-Tracking"
        lblTopSubTitle.text = "(For Advanced Users)"
        lblBottomTitle.text = "Advanced Stats and Analytics"
        lblBottomSubTitle.text = "Time-intensive, but feature-packed! Free distances and recommendations. Automatic Scoring enabled."
        imageVIew.image = #imageLiteral(resourceName: "ultimate_shot")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        overlappingView.makeBlurView(targetView: overlappingView)
        btnRequestMapping.setCorner(color: UIColor.clear.cgColor)
        
        popUpContainerView.isHidden = true
        if selectedMode == 1{
            prevShotBottomView.isHidden = true
            btnPrevShotTrack.isHidden = true
            
            let rfTitle = NSAttributedString(string: "Post-Game Shot-Tracker",attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
            btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
            btnPrevRf.setImage(#imageLiteral(resourceName: "post_inactive"), for: .normal)
            
            if scoringMode == "classic"{
                prevClassicAction(sender: btnPrevClassic)
            }
            else{
                prevRfAction(sender: btnPrevRf)
            }
        }
        else{
            if scoringMode == "classic"{
                prevClassicAction(sender: btnPrevClassic)
            }else{
                //            else if scoringMode == "rangeFinder"{
                prevRfAction(sender: btnPrevRf)
            }
            //            else{
            //                prevShotTrackAction(sender: btnPrevShotTrack)
            //            }
        }
        
        btnPrevContainerView.setCornerView(color: UIColor.glfBluegreen.cgColor)
        //        prevClassicAction(sender: btnPrevClassic)
        
        btnPrevClassic.titleLabel?.textAlignment = NSTextAlignment.center
        btnPrevRf.titleLabel?.textAlignment = NSTextAlignment.center
        btnPrevShotTrack.titleLabel?.textAlignment = NSTextAlignment.center
        
        btnPrevClassic.titleLabel?.lineBreakMode = .byWordWrapping
        btnPrevRf.titleLabel?.lineBreakMode = .byWordWrapping
        btnPrevShotTrack.titleLabel?.lineBreakMode = .byWordWrapping
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "unmappedCourseRequest/\(Auth.auth().currentUser!.uid)") { (snapshot) in
            var dataDic = NSDictionary()
            if(snapshot.childrenCount > 0){
                dataDic = snapshot.value as! NSDictionary
                
                for (key,_) in dataDic{
                    if let keyVal = key as? Int{
                        if keyVal == Int(selectedGolfID){
                            self.btnRequestMapping.isHidden = true
                        }
                    }
                    else if let keyVal = key as? String{
                        if keyVal == selectedGolfID{
                            self.btnRequestMapping.isHidden = true
                        }
                    }
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != popUpSubView {
            popUpContainerView.isHidden = true
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
}


