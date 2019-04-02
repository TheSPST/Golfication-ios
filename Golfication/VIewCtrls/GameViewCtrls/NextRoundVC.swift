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
import FirebaseDynamicLinks
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
    @IBOutlet weak var btnStart: UILocalizedButton!
    @IBOutlet weak var overlappingView: UIView!
    @IBOutlet weak var lblOverlapping: UILabel!
    
    @IBOutlet weak var lblStartClassic: UILabel!
    @IBOutlet weak var btnStartClassic: UIButton!
    @IBOutlet weak var mappedProgressView: UIProgressView!
    @IBOutlet weak var lblRequestReceive: UILabel!
    @IBOutlet weak var timerSv: UIStackView!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblMins: UILabel!
    @IBOutlet weak var lblSecs: UILabel!

    @IBOutlet weak var lblAfterMappingRequst: UILabel!
    @IBOutlet weak var popUpSubView: CardView!
    @IBOutlet weak var oopsLbl: UILabel!
    
    @IBOutlet weak var multiplayerStackView: UIStackView!
    @IBOutlet weak var btnAddFriends: UIButton!
    @IBOutlet weak var btnSkip: UIButton!

    @IBOutlet weak var btnPlayBasic: UIButton!
    let progressView = SDLoader()
    
    var selectedMode = 0
    var selectedTab = 0
    var scoringMode = String()
    var currentLocationOfUser = CLLocationCoordinate2D()
    var finalMatchDic = NSMutableDictionary()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var requestedMatchId = String()
    var countdownTimer: Timer!

    // MARK: backAction
    @IBAction func backAction(sender: UIBarButtonItem) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Back")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionInfoForRequest(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click RM3 Info")
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "CourseViewController") as! CourseViewController
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func btnActionForRequestMapping(_ sender: UIButton) {
        var mappingCount = 0
        var mappedTimestamp = Int64()
        FBSomeEvents.shared.singleParamFBEvene(param: "Click RM1 Request")
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "unmappedCourse/\(Constants.selectedGolfID)") { (snapshot) in
            var dataDic = NSDictionary()
            if(snapshot.value != nil){
                dataDic = snapshot.value as! NSDictionary
                if let count = dataDic.value(forKey: "count") as? Int{
                    mappingCount = count
                }
                if let timestamp = dataDic.value(forKey: "timestamp") as? Int64{
                    mappedTimestamp = timestamp
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if mappingCount >= 4{
                    ref.child("unmappedCourse/\(Constants.selectedGolfID)/").updateChildValues(["count":mappingCount+1] as [AnyHashable:Any])
                }
                else{
                    let mappingDic = NSMutableDictionary()
                    mappingDic.setObject(mappingCount+1, forKey: "count" as NSCopying)
                    mappingDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
                    ref.child("unmappedCourse/\(Constants.selectedGolfID)/").updateChildValues(mappingDic as! [AnyHashable:Any])
                }
                
                if(Auth.auth().currentUser!.uid.count > 1){
                    let mappingDic = NSMutableDictionary()
                    mappingDic.setObject(Timestamp, forKey: Constants.selectedGolfID as NSCopying)
                    mappingDic.setObject(Auth.auth().currentUser!.displayName!, forKey: "name" as NSCopying)
                    if self.selectedMode == 0 && self.selectedTab == 1{
                        mappingDic.setObject("rangefinder", forKey: "\(Auth.auth().currentUser!.uid)" as NSCopying)
                    }else if self.selectedMode == 0 && self.selectedTab == 2{
                        mappingDic.setObject("oncourse", forKey: "\(Auth.auth().currentUser!.uid)" as NSCopying)
                    }else if self.selectedMode == 1 && self.selectedTab == 1{
                        mappingDic.setObject("oncourse", forKey: "\(Auth.auth().currentUser!.uid)" as NSCopying)
                    }
                    ref.child("unmappedCourseRequest/\(Auth.auth().currentUser!.uid)/").updateChildValues(mappingDic as! [AnyHashable:Any])
                }
                if mappingCount+1 >= 4{
                    // show timer here
                    self.timerSv.isHidden = false
                    self.btnRequestMapping.isHidden = true
                    self.btnStartClassic.isHidden = false
                    self.lblStartClassic.isHidden = false
                    self.lblRequestReceive.isHidden = true
                    self.mappedProgressView.isHidden = true
                    self.lblAfterMappingRequst.isHidden = true
                    self.oopsLbl.isHidden = false
                    self.btnStartClassic.setCorner(color: UIColor.clear.cgColor)
                    if self.scoringMode.containsIgnoringCase(find: "classic"){
                        self.btnPlayBasic.setTitle("Play in Scorecard Mode", for: .normal)
                    }else{
                        self.btnPlayBasic.setTitle("Play in Rangefinder Mode", for: .normal)
                    }
                    self.lblOverlapping.text = "This course is being mapped. It will be available within:"
                    let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(mappedTimestamp/1000)))
                    let timeEnd = Calendar.current.date(byAdding: .second, value: 2*24*60*60, to: timeStart as Date)
                    let timeNow = NSDate()
                    let calendar = NSCalendar.current
                    var components = calendar.dateComponents([.second], from: timeNow as Date, to: timeEnd!)
                    self.oopsLbl.isHidden = true
                    self.startTimer(totalTime: (components.second!))
                }
                else{
                    self.timerSv.isHidden = true
                    self.btnRequestMapping.isHidden = true
                    self.btnStartClassic.isHidden = false
                    self.lblStartClassic.isHidden = false
                    self.lblRequestReceive.isHidden = false
                    self.mappedProgressView.isHidden = false
                    self.lblAfterMappingRequst.isHidden = false
                    self.oopsLbl.isHidden = true
                    self.btnStartClassic.setCorner(color: UIColor.clear.cgColor)
                    self.mappedProgressView.progress = Float(mappingCount+1)/Float(4)
                    self.lblRequestReceive.text = "BOOSTS RECEIVED: " + "\(mappingCount+1)" + "/" + "4"
                    if self.scoringMode.containsIgnoringCase(find: "classic"){
                        self.btnPlayBasic.setTitle("Play in Classic Mode", for: .normal)
                    }else{
                        self.btnPlayBasic.setTitle("Play in RangeFinder", for: .normal)
                    }
                    
                    let stringAttributed = NSMutableAttributedString.init(string: "Courses are on priority, mapped within 48 hrs when 4 boosts are received.")
                    self.lblOverlapping?.attributedText = stringAttributed
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:)))
                    self.lblOverlapping.addGestureRecognizer(tap)
                    self.lblOverlapping.isUserInteractionEnabled = true
                }
                let alert = UIAlertController(title: "Mapping Request Received!", message: "Our mapping team is working on your course request. You can fast-track your request by asking friends to boost your course.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Know More", style: .cancel, handler: { _ in
                    FBSomeEvents.shared.singleParamFBEvene(param: "Click RM2 Know More")
                    let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "CourseViewController") as! CourseViewController
                    self.navigationController?.pushViewController(viewCtrl, animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Get Boosts", style: .default, handler: { _ in
                    self.startClassicAction2(sender: self.btnStartClassic)
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func startTimer(totalTime : Int) {
        var totalSeconds = totalTime
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            
        let days: Int = (totalSeconds % 31536000) / 86400
        let hour: Int = (totalSeconds % 86400) / 3600
        let minuts: Int = (totalSeconds % 3600) / 60
        let second: Int = totalSeconds % 60
        self.lblDays.text = "\(days)"
        self.lblHours.text = "\(hour)"
        self.lblMins.text = "\(minuts)"
        self.lblSecs.text = "\(second)"
            
            if totalSeconds >= 0 {
                totalSeconds -= 1
            }
            else {
                self.timerSv.isHidden = true
                self.btnRequestMapping.isHidden = true
                self.btnStartClassic.isHidden = false
                self.lblStartClassic.isHidden = false
                self.lblRequestReceive.isHidden = true
                self.mappedProgressView.isHidden = true
                self.lblAfterMappingRequst.isHidden = true
                self.oopsLbl.isHidden = false
                self.countdownTimer.invalidate()
                self.lblOverlapping.isHidden = true
                self.countdownTimer.invalidate()
            }
        })
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        let days: Int = totalSeconds / 86400

        return String(format: "%02d:%02d:%02d:%02d",days, hours, minutes, seconds)
    }
    
    @IBAction func startClassicAction(sender: UIButton) {
        if !self.mappedProgressView.isHidden || !self.timerSv.isHidden{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click RM3 Start")
        }else{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click RM1 Start")
        }
        if self.scoringMode.contains("classic"){
            prevClassicAction(sender: btnPrevClassic)
        }else{
            prevRfAction(sender: btnPrevRf)
        }
    }
    @IBAction func startClassicAction2(sender: UIButton) {
        if !self.mappedProgressView.isHidden || !self.timerSv.isHidden{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click RM3 Boosts")
        }else{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click RM2 Boosts")
        }
        let text = "You were the first person I thought of when I read this. I use this new golf app called Golfication that uses data and AI to help me improve faster! The app is really powerful when your course is fully mapped out - with hazards, bunkers, roughs... the whole nine yards. I have requested for the mapping of \(Constants.selectedGolfName) on priority. It would be great if you can download the app and boost my request: that way it'll get mapped faster. And we can, together, use advanced insights to improve our game. Download and Boost my Request"
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://p5h99.app.goo.gl/mVFa?invitedby=\(uid)")
        let referralLink = DynamicLinkComponents(link: link!, domain: "p5h99.app.goo.gl")
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.khelfie.Khelfie")
        referralLink.iOSParameters?.minimumAppVersion = "1.0.1"
        referralLink.iOSParameters?.appStoreID = "1216612467"
        referralLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.khelfiegolf")
        referralLink.androidParameters?.minimumVersion = 1
        
        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let invitationUrl = shortURL
            let invitationStr = invitationUrl?.absoluteString
            let shareItems = [text, invitationStr] as! [String]
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.message, UIActivityType.mail, UIActivityType.postToFlickr, UIActivityType.postToWeibo, UIActivityType.postToVimeo]
            
            // present the view controller
            
            //https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
            //http://www.rockhoppertech.com/blog/uiactivitycontroller-in-swift/
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    let locationManager = CLLocationManager()

    @IBAction func startGameAction(sender: UIButton) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Start Round")
        FBSomeEvents.shared.singleParamFBEvene(param: "Start Game")
        if self.scoringMode.contains("classic"){
            self.btnStartClassic.tag = 1
        }else if self.scoringMode.contains("Advanced(GPS)"){
            self.btnStartClassic.tag = 0
        }else{
            self.btnStartClassic.tag = 2
        }
        if selectedMode == 0 && (selectedTab == 1 || selectedTab == 2){
            if self.btnStartClassic.tag == 2{
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
                        let location2 = CLLocation(latitude: Double(Constants.selectedLat)!, longitude: Double(Constants.selectedLong)!)
                        let distance : CLLocationDistance = location1.distance(from: location2)
                        debugPrint("distance = \(distance) m")
                        
                        if(distance <= 15000.0){
                            popUpContainerView.isHidden = false
                            if self.btnStartClassic.tag != 0{
                                self.btnSkip.tag = self.btnStartClassic.tag
                            }
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
            }else{
                popUpContainerView.isHidden = false
                if self.btnStartClassic.tag != 0{
                    self.btnSkip.tag = 1
                }
            }
        }
        else{
            popUpContainerView.isHidden = false
            if self.btnStartClassic.tag != 0{
                self.btnSkip.tag = 1
            }
        }
    }
    
    @IBAction func skipAction(sender: UIButton) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Skip")
        Constants.addPlayersArray = NSMutableArray()
        popUpContainerView.isHidden = true
        let gameCompleted = StartGameModeObj()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        if sender.tag == 0{
            if selectedTab == 0{
                // setup Classic Map
                NotificationCenter.default.addObserver(self, selector: #selector(self.classicCompleted(_:)), name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: nil)
                gameCompleted.setUpClassicMap(onCourse:selectedMode)
            }
            else if selectedTab == 1 && selectedMode == 0{
                // setup rangefinder
                NotificationCenter.default.addObserver(self, selector: #selector(self.rfApiCompleted(_:)), name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
                gameCompleted.setUpRFMap(golfId: "course_\(Constants.selectedGolfID)",onCourse:selectedMode)
            }
            else{
                // setup post game short tracker or ultimate short tracking
                NotificationCenter.default.addObserver(self, selector: #selector(self.defaultMapApiCompleted(_:)), name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
                gameCompleted.showDefaultMap(onCourse:selectedMode)
            }
        }else{
            if sender.tag == 1{
                // setup Classic Map
                NotificationCenter.default.addObserver(self, selector: #selector(self.classicCompleted(_:)), name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: nil)
                gameCompleted.setUpClassicMap(onCourse:selectedMode)
            }
            else if sender.tag == 2{
                // setup rangefinder
                NotificationCenter.default.addObserver(self, selector: #selector(self.rfApiCompleted(_:)), name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
                gameCompleted.setUpRFMap(golfId: "course_\(Constants.selectedGolfID)",onCourse:selectedMode)
            }
        }
    }
    
    @objc func classicCompleted(_ notification: NSNotification) {
        let notifScoring = notification.object as! [(hole:Int,par:Int,players:[NSMutableDictionary])]
        self.progressView.hide(navItem: self.navigationItem)
        FBSomeEvents.shared.singleParamFBEvene(param: "Start Classic")
        if(notifScoring.count > 0){
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "BasicScoringVC") as! BasicScoringVC
            viewCtrl.matchDataDict = Constants.matchDataDic
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Start Rangefinder")
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
        viewCtrl.matchDataDic = Constants.matchDataDic
        viewCtrl.isContinueMatch = false
        viewCtrl.matchId = Constants.matchId
        viewCtrl.courseId = notifGolfId
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
    }
    
    @objc func defaultMapApiCompleted(_ notification: NSNotification) {
        let notifScoring = notification.object as! [(hole:Int,par:Int,players:[NSMutableDictionary])]
        self.progressView.hide(navItem: self.navigationItem)
        if let onCourse = Constants.matchDataDic.value(forKeyPath: "onCourse") as? Bool{
            if onCourse{
                FBSomeEvents.shared.singleParamFBEvene(param: "Start On Course ST")
            }else{
                FBSomeEvents.shared.singleParamFBEvene(param: "Start Post Game ST")
            }
        }
        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
        
        viewCtrl.matchDataDict = Constants.matchDataDic
        viewCtrl.isContinue = false
        viewCtrl.currentMatchId = Constants.matchId
        viewCtrl.scoring = notifScoring
        viewCtrl.courseId = "course_\(Constants.selectedGolfID)"
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
    }
    
    @IBAction func addFriendAction(sender: UIButton) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Add Friends")
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        viewCtrl.selectedMode = selectedMode
        viewCtrl.selectedTab = selectedTab
        viewCtrl.requestPop = self.btnStartClassic.tag
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
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_active"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_inactive"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_inactive"), for: .normal)
        if selectedMode == 0{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Course Classic")
        }else{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 OC Classic")
        }

        if selectedMode == 1{
            let rfTitle = NSAttributedString(string: "Post-Game Shot Tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
            btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
            btnPrevRf.setImage(#imageLiteral(resourceName: "post_inactive"), for: .normal)
        }
        
        lblTopTitle.text = "Classic Scorecard".localized()
        lblTopSubTitle.text = "(" + "For Basic Users".localized() + ")"
        lblBottomTitle.text = "Fast and easy".localized()
        lblBottomSubTitle.text = "Record hole-scores, fairways, GIRs and putts for you and your friends.".localized()
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
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_inactive"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_active"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_inactive"), for: .normal)
        
        lblTopTitle.text = "Smart Rangefinder".localized()
        lblTopSubTitle.text = "(" + "Most Popular".localized() + ")"
        lblBottomTitle.text = "Fast and accurate Distances".localized()
        lblBottomSubTitle.text = "FREE distances and club-recommendations.".localized() + " \n" + "Live Scoring available".localized()
        imageVIew.image = #imageLiteral(resourceName: "range_finder")
        if selectedMode == 0{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Rangefinder")
        }
        if selectedMode == 1{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 OC Shot Tracking")
            let rfTitle = NSAttributedString(string: "Post-Game Shot Tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
            btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
            btnPrevRf.setImage(#imageLiteral(resourceName: "post_active"), for: .normal)
            
            lblTopTitle.text = "Post-Game Shot Tracking".localized()
            lblTopSubTitle.text = "(" + "For Advanced Users".localized() + ")"
            lblBottomTitle.text = "Advanced Stats and Analytics".localized()
            lblBottomSubTitle.text = "Time Intensive, but feature packed! Plot each shot as it was actually played, to access unbeateable insights into your own game. Take charge!".localized()
    
            imageVIew.image = #imageLiteral(resourceName: "post_shot")
            if(self.scoringMode != "Advanced(GPS)"){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
//                self.btnStart.isHidden = true
                self.overlappingView.isHidden = false
            }
            
        }else{
            
            self.setBgViewForRequestMaping()
//            mappedProgressView
        }
    }
    func setBgViewForRequestMaping(){
        switch self.scoringMode {
        case "classic":
            if(selectedTab == 1) || (selectedTab == 2){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
                self.overlappingView.isHidden = false
                self.lblAfterMappingRequst.isHidden = self.mappedProgressView.isHidden
                self.oopsLbl.isHidden = !self.mappedProgressView.isHidden
                if mappedProgressView.isHidden{
                    var text = "Shot Tracking "
                    if selectedTab == 1{
                        text = "GPS Rangefinder "
                    }
                    self.btnPlayBasic.setTitle("Play in Scorecard Mode", for: .normal)
                    self.lblOverlapping.text = text + "has not been initialized for this course. If you play this course often, please request for mapping below."
                    self.oopsLbl.isHidden = !self.timerSv.isHidden
                }
            }
            break
        case "rangeFinder":
            if(selectedTab > 1){
                self.btnStart.isEnabled = false
                self.btnStart.backgroundColor = UIColor.glfWarmGrey
                self.overlappingView.isHidden = false
                self.lblAfterMappingRequst.isHidden = self.mappedProgressView.isHidden
                self.oopsLbl.isHidden = !self.mappedProgressView.isHidden
                if mappedProgressView.isHidden{
                    let text = "Shot Tracking "
                    self.btnPlayBasic.setTitle("Play in Rangefinder Mode", for: .normal)
                    self.lblOverlapping.text = text + "has not been initialized for this course. If you play this course often, please request for mapping below."
                    self.oopsLbl.isHidden = !self.timerSv.isHidden
                }
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Click NG2 Course Shot Tracking")
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
        
        let classicTitle = NSAttributedString(string: "Classic Scorecard".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevClassic.setAttributedTitle(classicTitle, for: .normal)
        let rfTitle = NSAttributedString(string: "Smart Rangefinder".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        btnPrevRf.setAttributedTitle(rfTitle, for: .normal)
        let ultimateTitle = NSAttributedString(string: "Ultimate Shot-tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x0E220D)])
        btnPrevShotTrack.setAttributedTitle(ultimateTitle, for: .normal)
        
        btnPrevClassic.setImage(#imageLiteral(resourceName: "classic_inactive"), for: .normal)
        btnPrevRf.setImage(#imageLiteral(resourceName: "rf_inactive"), for: .normal)
        btnPrevShotTrack.setImage(#imageLiteral(resourceName: "ultimate_active"), for: .normal)
        
        lblTopTitle.text = "Ultimate Shot-tracking".localized()
        lblTopSubTitle.text = "(" + "For Advanced Users".localized() + ")"
        lblBottomTitle.text = "Advanced Stats and Analytics".localized()
        lblBottomSubTitle.text = "Time-intensive, but feature-packed! FREE distances and recommendations. Automatic Scoring enabled".localized()
    
        imageVIew.image = #imageLiteral(resourceName: "ultimate_shot")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FBSomeEvents.shared.singleParamFBEvene(param: "View New Game 2")
        btnPlayBasic.setCorner(color: UIColor.clear.cgColor)
        self.title = "New Round".localized()
        btnSkip.setTitle(" " + "Skip".localized() + " ", for: .normal)
        //        overlappingView.makeBlurView(targetView: overlappingView)
        btnRequestMapping.setCorner(color: UIColor.clear.cgColor)
        btnAddFriends.setCornerWithRadius(color: UIColor.clear.cgColor, radius: btnAddFriends.frame.height/2)
        for btn in multiplayerStackView.subviews{
            (btn as? UIButton)?.setCornerWithRadius(color: UIColor.glfGreen.cgColor, radius: btn.frame.height/2)
        }
        popUpContainerView.isHidden = true
        if selectedMode == 1{
            prevShotBottomView.isHidden = true
            btnPrevShotTrack.isHidden = true
            
            let rfTitle = NSAttributedString(string: "Post-Game Shot Tracking".localized(),attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
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
                prevRfAction(sender: btnPrevRf)
            }
        }
        
        btnPrevContainerView.setCornerView(color: UIColor.glfBluegreen.cgColor)
        //        prevClassicAction(sender: btnPrevClassic)
        
        btnPrevClassic.titleLabel?.textAlignment = NSTextAlignment.center
        btnPrevRf.titleLabel?.textAlignment = NSTextAlignment.center
        btnPrevShotTrack.titleLabel?.textAlignment = NSTextAlignment.center
        
        btnPrevClassic.titleLabel?.lineBreakMode = .byWordWrapping
        btnPrevRf.titleLabel?.lineBreakMode = .byWordWrapping
        btnPrevShotTrack.titleLabel?.lineBreakMode = .byWordWrapping
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "unmappedCourseRequest/\(Auth.auth().currentUser!.uid)") { (snapshot) in
            var dataDic = NSDictionary()
            if(snapshot.childrenCount > 0){

                dataDic = snapshot.value as! NSDictionary
                
                for (key,_) in dataDic{
                    if let keyVal = key as? Int{
                        if keyVal == Int(Constants.selectedGolfID){
                            self.checkMappingRequest()
                            self.btnRequestMapping.isHidden = true
                        }
                    }
                    else if let keyVal = key as? String{
                        if keyVal == Constants.selectedGolfID{
                            self.checkMappingRequest()
                            self.btnRequestMapping.isHidden = true
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if self.scoringMode.containsIgnoringCase(find: "classic"){
                    self.btnPlayBasic.setTitle("Play in Classic Mode", for: .normal)
                }else{
                    self.btnPlayBasic.setTitle("Play in RangeFinder", for: .normal)
                }
            })
        }
    }
    var mappingCount = 0
    func checkMappingRequest(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        mappingCount = 0
        var mappedTimestamp = Int64()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "unmappedCourse/\(Constants.selectedGolfID)") { (snapshot) in
            var dataDic = NSDictionary()
            if(snapshot.value != nil){
                dataDic = snapshot.value as! NSDictionary
                if let count = dataDic.value(forKey: "count") as? Int{
                    self.mappingCount = count
                }
                if let timestamp = dataDic.value(forKey: "timestamp") as? Int64{
                    mappedTimestamp = timestamp
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if self.mappingCount >= 4{
                    // show timer here
                    self.timerSv.isHidden = false
                    self.btnRequestMapping.isHidden = true
                    self.btnStartClassic.isHidden = false
                    self.lblStartClassic.isHidden = false
                    self.lblRequestReceive.isHidden = true
                    self.mappedProgressView.isHidden = true
                    self.lblAfterMappingRequst.isHidden = true
                    self.oopsLbl.isHidden = false
                    self.btnStartClassic.setCorner(color: UIColor.clear.cgColor)
//                    self.lblStartClassic.text = "Meanwhile you can play on this course in \(self.scoringMode) mode."
                    self.lblOverlapping.text = "This course is being mapped. It will be available within:"
                    if self.scoringMode.containsIgnoringCase(find: "classic"){
                        self.btnPlayBasic.setTitle("Play in Scorecard Mode", for: .normal)
                    }else{
                        self.btnPlayBasic.setTitle("Play in Rangefinder Mode", for: .normal)
                    }
                    let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(mappedTimestamp/1000)))
                    let timeEnd = Calendar.current.date(byAdding: .second, value: 2*24*60*60, to: timeStart as Date)
                    let timeNow = NSDate()
                    let calendar = NSCalendar.current
                    var components = calendar.dateComponents([.second], from: timeNow as Date, to: timeEnd!)
                    self.oopsLbl.isHidden = true
                    self.startTimer(totalTime: (components.second!))
                }
                else{
                    self.timerSv.isHidden = true
                    self.btnRequestMapping.isHidden = true
                    self.btnStartClassic.isHidden = false
                    self.lblStartClassic.isHidden = false
                    self.lblRequestReceive.isHidden = false
                    self.mappedProgressView.isHidden = false
                    self.lblAfterMappingRequst.isHidden = false
                    self.oopsLbl.isHidden = true
                    self.btnStartClassic.setCorner(color: UIColor.clear.cgColor)
                    
                    self.mappedProgressView.progress = Float(self.mappingCount)/Float(4)
                    self.lblRequestReceive.text = "BOOSTS RECEIVED: " + "\(self.mappingCount)" + "/" + "4"
                    if self.selectedMode == 1{
                        self.scoringMode = "classic"
                    }
//                    self.lblStartClassic.text = "Meanwhile you can play on this course in \(self.scoringMode) mode."
                    if self.scoringMode.containsIgnoringCase(find: "classic"){
                        self.btnPlayBasic.setTitle("Play in Scorecard Mode", for: .normal)
                    }else{
                        self.btnPlayBasic.setTitle("Play in Rangefinder Mode", for: .normal)
                    }
                    let stringAttributed = NSMutableAttributedString.init(string: "Courses are mapped on priority, within 48 hrs when 4 boosts are received.")
                    self.lblOverlapping?.attributedText = stringAttributed                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:)))
                    self.lblOverlapping.addGestureRecognizer(tap)
                    self.lblOverlapping.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        let text = (lblOverlapping.text)!
        let inviteRange = (text as NSString).range(of: "Invite your friends")
        
        if tap.didTapAttributedTextInLabel(label: lblOverlapping, inRange: inviteRange) {
            let text = "Take your golf game further with Live Scoring, GPS, Shot Tracking, Advanced Stats and more. Download Golfication now!"
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let link = URL(string: "https://p5h99.app.goo.gl/mVFa?invitedby=\(uid)")
            let referralLink = DynamicLinkComponents(link: link!, domain: "p5h99.app.goo.gl")
            referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.khelfie.Khelfie")
            referralLink.iOSParameters?.minimumAppVersion = "1.0.1"
            referralLink.iOSParameters?.appStoreID = "1216612467"
            referralLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.khelfiegolf")
            referralLink.androidParameters?.minimumVersion = 1
            
            referralLink.shorten { (shortURL, warnings, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let invitationUrl = shortURL
                let invitationStr = invitationUrl?.absoluteString
                let shareItems = [text, invitationStr] as! [String]
                let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.message, UIActivityType.mail, UIActivityType.postToFlickr, UIActivityType.postToWeibo, UIActivityType.postToVimeo]
                
                // present the view controller
                
                //https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
                //http://www.rockhoppertech.com/blog/uiactivitycontroller-in-swift/
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != popUpSubView {
            popUpContainerView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reqTimeOutTimer.invalidate()
    }
    var reqTimeOutTimer = Timer()
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        
        if self.progressView.isAnimating!{
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        if !(appDelegate.isInternet){
            reqTimeOutTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                let alert = UIAlertController(title: "Request Timeout", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    debugPrint("OK Alert: \(alert?.title ?? "")")
                }))
                timer.invalidate()
                self.reqTimeOutTimer.invalidate()
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
 }
}
