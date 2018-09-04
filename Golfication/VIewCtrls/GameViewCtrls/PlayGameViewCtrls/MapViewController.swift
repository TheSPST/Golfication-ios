//
//  MapViewController.swift
//  Golfication
//
//  Created by IndiRenters on 11/18/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import GoogleMaps
import Dropper
import CTShowcase
import FirebaseAuth
import ActionSheetPicker_3_0
import FirebaseDatabase
import FirebaseAnalytics
import UserNotifications
import FirebaseDynamicLinks

let YARD:Double = 1.09361
var Timestamp: Int64 {
    return Int64(NSDate().timeIntervalSince1970*1000)
}

class MapViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate{

    @IBOutlet weak var youScoredSuperStackView: UIStackView!
    @IBOutlet weak var stackViewForEditShots: UIStackView!
    @IBOutlet weak var btnChangeEndingLocation: UIButton!
    @IBOutlet weak var shotsParentHeight: NSLayoutConstraint!
    @IBOutlet weak var btnEditClub: UIButton!
    @IBOutlet weak var btnShareScore: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var multiplayerStackView: UIStackView!
    @IBOutlet weak var multiplayerPageControl: UIPageControl!
    @IBOutlet weak var btnReviewHoleDownArrow: UIButton!
    @IBOutlet weak var iphoneXBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var imgWindDir: UIImageView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    
    @IBOutlet weak var lblRaceToFlagTitle: UILabel!
    @IBOutlet weak var btnTrackShot: UIButton!
    @IBOutlet weak var btnInTheHole: UIButton!
    @IBOutlet weak var shotDetailsStackView: UIStackView!
    @IBOutlet weak var trackShotStackView: UIStackView!
    @IBOutlet weak var btnClubName: UIButton!
    @IBOutlet weak var btnShotDistance: UIButton!
    @IBOutlet weak var btnShotLandedOn: UIButton!
    @IBOutlet weak var btnShotStrokesGained: UIButton!
    @IBOutlet weak var shotsFooterView: UIView!
    @IBOutlet weak var btnHoleOutInsideFooter: UIButton!
    @IBOutlet weak var holeOutStackView: UIStackView!
    @IBOutlet weak var btnHoleTitle: UIButton!
    @IBOutlet weak var lblHoleSubtitle: UILabel!
    @IBOutlet weak var onOffCourseView: UIView!
    @IBOutlet weak var btnNextHole: UIButton!
    @IBOutlet weak var btnReviewHole: UIButton!
    @IBOutlet weak var heightOfNewView: NSLayoutConstraint!
    @IBOutlet weak var statesStackView: UIStackView!
    @IBOutlet weak var shotParentStackView: StackView!
    @IBOutlet weak var shotStackView: UIStackView!
    
    @IBOutlet weak var btnOnOffCourse: UIButton!
    @IBOutlet weak var btnARView: UIButton!
    @IBOutlet weak var btnMapView: UIButton!
    @IBOutlet weak var backBtnHeader: UIButton!
    @IBOutlet weak var headerViewMap: UIView!
    
    @IBOutlet weak var stackViewForGreenShots: UIStackView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnLeftFooter: UIButton!
    @IBOutlet weak var btnRightFooter: UIButton!
    @IBOutlet weak var btnLeftShot: UIButton!
    @IBOutlet weak var btnRightShot: UIButton!
    @IBOutlet var swipeGuestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var btnEndRoundInBetween: UIButton!
    @IBOutlet weak var btnViewScorecard: UIButton!
    @IBOutlet weak var youScoredLbl: UILabel!
    @IBOutlet weak var btnConfirmClubAndLandedOn: UIButton!
    @IBOutlet weak var barChartParentStackView: UIStackView!
    @IBOutlet weak var stackViewBarCharts: UIStackView!
    @IBOutlet weak var btnHoleOutAchieve: UIButton!
    @IBOutlet weak var lblShotNumber: UILabel!
    @IBOutlet weak var lblTitleHolePar: UILabel!
    @IBOutlet weak var btnGreenDot: UIButton!
    @IBOutlet weak var stackViewMenu: StackView!
    @IBOutlet weak var btnHoleOut: UIButton!
    @IBOutlet weak var btnShotsCount: UIButton!
    @IBOutlet weak var btnSelectClub: UIButton!
    @IBOutlet weak var btnStatsView: UIButton!
    @IBOutlet var swipeGestureRecognizerRight: UISwipeGestureRecognizer!
    @IBOutlet weak var newView: UIView!

    fileprivate var places = [Place]()
    var swingMatchId = String()
    var progressView = SDLoader()
    var newPath = GMSPath()
    var clubData = [(name:String,max:Int,min:Int)]()
    var blockRecursionIssue = 0
    var timer: Timer!
    var startingHole = 0
    var lastHole = 0
    var overlayView = UIView()
    var clubsFullForm = ["Dr":"Driver","w":"Wood","h":"Hybrid","i":"Iron","Pw":"Pitching Wedge","Gw":"Gap Wedge","Sw":"Sand Wedge","Lw":"Lob Wedge","Pu":"Putter"]
    var shotIndex = 0
    let pathOfGreen = GMSMutablePath()
    var isHoleByHole = false
    var isProcessing = false
    var penaltyShots = [Bool]()
    let viewForEditShots = UIView(frame: CGRect.init(x: 0, y: 0, width: 110, height: 25))
    let newMenuView = UIView(frame:CGRect(x: 0, y: 0, width: 90, height: 150))
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var isTracking = false
    var currentShotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
    let distanceFairway = NSMutableDictionary()
    let distanceRough = NSMutableDictionary()
    var holeOutforAppsFlyer = [Int]()
    var playerIndex = 0
    var gir3Perc = Double()
    var fairwayHitPerc = Double()
    var fairwayLeftPerc = Double()
    var fairwayRightPerc = Double()
    var indexForFairway = 0
    var stackView = UIStackView()
    var windHeading = Double()
    var arViewController: ARViewController!
    
    var botStrokesGained = Double()
    var botSGPutting = Double()
    var maxDrive = Double()
    var avgDrive = Double()
    var girWithFairway = Double()
    var girWithoutFairway = Double()
    var isBotTurn = false
    
    var isAcceptInvite = false
    var suggestedMarker1 = GMSMarker()
    var suggestedMarker2 = GMSMarker()
    var btnForSuggMark1 = UIButton()
    var btnForSuggMark2 = UIButton()
    
    
    var selectedUserId = String()
    var userIdWithImage = [(id:String,url:String,name:String)]()
    var approachDistance = 0.0
    var markersForCurved = [GMSMarker]()
    var isDraggingMarker : Bool!
    var player = NSMutableDictionary()
    var isMapViewColor = true
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var currentHole = Int()
    var matchType = Int()
    var playerShotsArray = [NSMutableDictionary]()
    var playerArrayWithDetails = NSMutableDictionary()
    var gir = Bool()
    var isContinueMatch : Bool!
    var playersButton = [(button:UIButton,isSelected:Bool,id:String)]()
    var activePlayerData = [NSDictionary]()
    var locationManager = CLLocationManager()
    var matchDataDictionary = NSMutableDictionary()
    var currentMatchId = String()
    var isSolidLinePloted = false
    var solidLine = GMSPolyline()
    var previousUserLocation = CLLocationCoordinate2D()
    var userMarker = GMSMarker()
    let X_OFFSET:CGFloat = 10
    
    var clubs = ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu","more"]
    var tappedMarker : GMSMarker!
    var userLocationForClub : CLLocationCoordinate2D?
    var positionsOfDotLine = [CLLocationCoordinate2D]()
    var positionsOfCurveLines = [CLLocationCoordinate2D]()
    var draggingMarker = GMSMarker()
    var holeViseAllShots = [(hole:Int,holeShots:[(shot:Int,line:GMSPolyline,markerPosition:GMSMarker)],dotLinePoints:[CLLocationCoordinate2D],curvedLinePoints:[CLLocationCoordinate2D],shotCount:Int,holeOut:Bool)]()
    var shotViseCurve = [(shot:Int,line:GMSPolyline,markerPosition:GMSMarker)]()
    var points = CGPoint()
    var mapView = GMSMapView()
    var markerInfo = GMSMarker()
    var markerInfo2 = GMSMarker()
    var shotMarkerForShowCase = GMSMarker()
    var userId = String()
    var courseId = String()
    
    // MARK: - swipeLeftAction
    @IBAction func swipeLeftAction(_ sender: UISwipeGestureRecognizer) {
        if(playersButton.count > 1){
            print(sender.direction)
            print("left")
            var playerIndexs = 0
            for i in 0..<playersButton.count{
                if playersButton[i].isSelected{
                    playerIndexs = i
                }
            }
            if(playerIndex == 0){
                playerIndexs = playersButton.count - 1
            }else{
                playerIndexs -= 1
            }
            
            for vi in multiplayerStackView.subviews{
                if(vi.isKind(of: UIStackView.self)){
                    for btn in (vi as! UIStackView).arrangedSubviews{
                        if(btn as! UIButton).tag == playerIndexs{
                            self.buttonAction(sender: playersButton[playerIndexs].button)
                            self.leftSwipeAction(tag: playerIndexs)
                        }
                    }
                }
                
            }
            self.multiplayerPageControl.currentPage = playerIndexs
            print("Left\(playerIndex)")
            
        }
    }

    // MARK: - btnActionViewScorecard
    @IBAction func btnActionViewScorecard(_ sender: UIButton) {
        
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = self.scoring
        let players = NSMutableArray()
        if(matchDataDic.object(forKey: "player") != nil){
            let tempArray = matchDataDic.object(forKey: "player")! as! NSMutableDictionary
            for (k,v) in tempArray{
                let dict = v as! NSMutableDictionary
                dict.addEntries(from: ["id":k])
                players.add(dict)
            }
        }
        viewCtrl.playerData = players
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: - swipeAction
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if(playersButton.count > 1){
            print(sender.direction)
            print("Right")
            var playerIndexs = 0
            for i in 0..<playersButton.count{
                if playersButton[i].isSelected{
                    playerIndexs = i
                }
            }
            if(playerIndexs == playersButton.count-1){
                playerIndexs = -1
            }
            
            for vi in multiplayerStackView.subviews{
                if(vi.isKind(of: UIStackView.self)){
                    for btn in (vi as! UIStackView).arrangedSubviews{
                        if(btn as! UIButton).tag == playerIndexs+1{
                            self.buttonAction(sender: playersButton[playerIndexs+1].button)
                            self.leftSwipeAction(tag: playerIndexs+1)
                        }
                    }
                }
            }
            self.multiplayerPageControl.currentPage = playerIndexs+1
            print("Right\(playerIndexs+1)")
            
        }
    }
    
    // MARK: - btnActionInTheHole
    @IBAction func btnActionInTheHole(_ sender: UIButton) {
        suggestedMarker1.map = nil
        suggestedMarker2.map = nil
        
        if(!holeOutFlag){
            isUpdating = false
            positionsOfCurveLines.removeLast()
            positionsOfCurveLines.append(positionsOfDotLine.last!)
            markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
            markersForCurved.last?.groundAnchor = CGPoint(x:0,y:1)
            markersForCurved.last?.position = positionsOfDotLine.last!
            
            for marker in markers{
                marker.map = nil
            }
            line.map = nil
            markers[markers.count-2].map = nil
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
            holeOutFlag = true
            
            btnShotsCount.isEnabled = false
            positionsOfDotLine.removeAll()
            updateStateWhileDragging(marker:markersForCurved.last!)
            if mode>0{
                self.holeOutforAppsFlyer[self.playerIndex] += 1
                Analytics.logEvent("mode\(mode)_holeout\(holeOutforAppsFlyer[self.playerIndex])", parameters: [:])
            }
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(self.selectedUserId)/").updateChildValues(["holeOut":true] as [AnyHashable : Any])
        }
        
        self.btnHoleOutInsideFooter.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
            let btn = UIButton()
            btn.tag = self.shotCount-1
            btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
            self.shotCheck(btn)
            self.shotDetailsStackView.isHidden = true
            self.trackShotStackView.isHidden = false
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.btnStatsView.tag = 0
            if(!isShowCase){
                self.btnStatsAction(self.btnStatsView)
            }
        })
        self.btnInTheHole.isHidden = true
    }

    // MARK: - btnActionMenu
    @IBAction func btnActionMenu(_ sender: UIButton) {
        var j = 0
        for player in playersButton{
            self.holeOutforAppsFlyer[j] = self.checkHoleOutZero(playerId: player.id)
            j += 1
        }
        
        if(stackViewMenu.isHidden){
            stackViewMenu.isHidden = false
        }else{
            stackViewMenu.isHidden = true
        }
    }
    
    // MARK: - btnActionFinishRound
    @IBAction func btnActionFinishRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        if(self.holeOutforAppsFlyer[self.playerIndex] != self.scoring.count){
            let emptyAlert = UIAlertController(title: "Finish Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to finish the Round ?", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "Finish Round", style: .default, handler: { (action: UIAlertAction!) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
                if(self.holeOutforAppsFlyer[self.playerIndex] > 8){
                    self.saveAndviewScore()
                }else{
                    self.exitWithoutSave()
                }
            }))
            emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }else{
            self.saveAndviewScore()
        }
        
    }
    
    // MARK: - btnActionConfirmEditShots
    @IBAction func btnActionConfirmEditShots(_ sender: UIButton) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        self.stackViewForEditShots.isHidden = true
        let clubName = (self.btnEditClub.titleLabel?.text)?.trim()
        let landedOn = (self.btnChangeEndingLocation.titleLabel?.text)!.trim()
        let spString = landedOn.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        var finalStr = "\(landedOn.first!)"
        if(spString.count > 1){
            finalStr = "\(spString[0].first!)\(spString[1].first!)"
        }
        if(finalStr == "B"){
           finalStr = "GB"
        }
        let shotDetails = self.getShotDataOrdered(indexToUpdate: self.index)
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
                    shotData.club = clubName!
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
                            
                            if(self.scoring[self.index].par>3){
                                drivingDistance = GMSGeometryDistance(self.positionsOfCurveLines[shot-1], self.positionsOfCurveLines[shot])*YARD
                                self.playerArrayWithDetails.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
                            }
                            if(!self.holeOutFlag){
                                self.playerArrayWithDetails.setObject(self.fairwayDetailsForFirstShotWithLandedOn(shot:shot,landedOn:landedOnACtoProgram), forKey: "fairway" as NSCopying)
                            }
                            self.gir = landedOnACtoProgram == "G" ? true:false
                        }
                        if(shot == 2)&&(!self.gir)&&(self.scoring[self.index].par>3){
                            self.gir = landedOnACtoProgram == "G" ? true:false
                        }
                        if(shot == 3)&&(!self.gir)&&(self.scoring[self.index].par>4){
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
                        }

                    }
                }
            }
            Notification.sendLocaNotificatonToUser()
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(self.selectedUserId)/").updateChildValues(self.playerArrayWithDetails as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                self.isProcessing = false
                self.getScoreFromMatchDataFirebases()
                self.updateMap(indexToUpdate: self.index)
                self.progressView.hide(navItem: self.navigationItem)
    
            })
        })
    }

    // MARK: - btnActionRestartRound
    @IBAction func btnActionRestartRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            if !(self.newView.isHidden){
                self.btnStatsAction(self.btnStatsView)
            }
            if(self.playersButton.count > 1){
                self.checkIfMuliplayerJoined(matchID:self.currentMatchId)
            }else{
                self.resetScoreNodeForMe()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.updateMap(indexToUpdate: self.index)
                self.progressView.hide(navItem: self.navigationItem)
            })
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
    }
    
    // MARK: - btnActionDiscardRound
    @IBAction func btnActionDiscardRound(_ sender: Any) {
        stackViewMenu.isHidden = true
        let emptyAlert = UIAlertController(title: "Discard Round", message: "You Played \(self.holeOutforAppsFlyer[self.playerIndex])/\(scoring.count) Holes. Are you sure you want to Discard the Round ?", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "Discard Round", style: .default, handler: { (action: UIAlertAction!) in
            self.exitWithoutSave()
        }))
        emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
        
    }
    
    func exitWithoutSave(){
        self.updateFeedNode()

        if(matchId.count > 1){
            if(Auth.auth().currentUser!.uid.count > 1){
                ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":0])
            }
            if(matchId.count > 1){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId)").removeValue()
            }
            matchId.removeAll()
            isUpdateInfo = true
            self.navigationController!.popToRootViewController(animated: true)
            addPlayersArray.removeAllObjects()
            if(self.swingMatchId.count > 0){
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
            }
            if mode>0{
                Analytics.logEvent("mode\(mode)_game_discarded", parameters: [:])
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                //center.removePendingNotificationRequests(withIdentifiers: ["UYLLocalNotification"])
            }
        }

        self.scoring.removeAll()
        scoring.removeAll()
    }
    
    func saveAndviewScore(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.statsCompleted(_:)), name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        if(self.swingMatchId.count > 0){
            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
        }
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        let generateStats = GenerateStats()
        generateStats.matchKey = matchId
        generateStats.generateStats()
    }
    
    @objc func statsCompleted(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
        self.progressView.hide(navItem: self.navigationItem)
        
        if(matchId.count > 1){
            ref.child("userData/\(Auth.auth().currentUser?.uid ?? "user1")/activeMatches/\(matchId)").removeValue()
        }
        self.sendMatchFinishedNotification()
        if(Auth.auth().currentUser!.uid.count>1) &&  (matchId.count > 1){
            ref.child("matchData/\(matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["status":4])
        }
        addPlayersArray = NSMutableArray()
        self.updateFeedNode()
        isUpdateInfo = true
        if mode>0{
            Analytics.logEvent("mode\(mode)_game_completed", parameters: [:])
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        if(matchId.count > 1){
            self.gotoFeedBackViewController(mID: matchId,mode:mode)
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
                Notification.sendNotification(reciever: data.key, message: "\(Auth.auth().currentUser?.displayName ?? "guest") just finished a round at \(selectedGolfName).", type: "8", category: "finishedGame", matchDataId: self.currentMatchId, feedKey:"")
                group.leave()
            }
            
            group.notify(queue: .main){
                self.progressView.hide(navItem: self.navigationItem)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.mapView.isMyLocationEnabled = true
        let userLocation = locations.last
        userLocationForClub = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        //        print("ErrorNotGettingLocation : \(error)")
    }
    func updateFeedNode(){
        let feedDict = NSMutableDictionary()
        feedDict.setObject(Auth.auth().currentUser?.displayName as Any, forKey: "userName" as NSCopying)
        feedDict.setObject(Auth.auth().currentUser?.uid as Any, forKey: "userKey" as NSCopying)
        feedDict.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        feedDict.setObject(matchId, forKey: "matchKey" as NSCopying)
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
            if(matchDataDic.object(forKey: "player") != nil){
                let tempArray = matchDataDic.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    players.add(dict)
                }
            }
            viewCtrl.finalPlayersData = players
            viewCtrl.finalScoreData = self.scoring
            viewCtrl.currentMatchId = mID
            viewCtrl.justFinishedTheMatch = true
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.scoring.removeAll()
            matchId.removeAll()
            
        }
        self.present(viewCtrl, animated: true, completion: nil)
    }

    @IBAction func showARController(_ sender: Any) {
        
        if self.places.count>0{
            self.places.removeAll()
            places = [Place]()
        }
        
        if(userLocationForClub != nil){
            //https://www.raywenderlich.com/146436/augmented-reality-ios-tutorial-location-based-2
            var teeCoord = [CLLocationCoordinate2D]()
            var gbCoord = [CLLocationCoordinate2D]()
            var fbCoord = [CLLocationCoordinate2D]()
            
            for i in 0..<self.numberOfHoles[index].tee.count{
                let address = self.matchDataDictionary.value(forKey: "courseName")
                let holeIndex = (index+1) % coordBound.count
                let name = " Hole \(holeIndex+1) Tee"
                teeCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: self.numberOfHoles[holeIndex].tee[i]))
                let flagCoordinates = teeCoord[i]
                let latitude = flagCoordinates.latitude
                let longitude = flagCoordinates.longitude
                let reference = "CmRRAAAA1ImMeBfqBlsMF9wcVZintvDjhn4lkBeDbqjajyL63tq48YIzS8TJ7kP3JHMVWlwLlaf-NVBrbo3ZmuCBZwY4G1xWDholdXgio3F35eow4nXQAjZkb0ydfmTi5AxPOl0JEhCOwmRWBu46PILZvxewngswGhQRcfpMXW3b2mdsZHkbnOHSrp65Hg"
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let place = Place(location: location, reference: reference, name: name, address: address as! String)
                self.places.append(place)
                break
            }
            for i in 0..<self.numberOfHoles[index].gb.count{
                let name = " Bunker"
                let address = self.matchDataDictionary.value(forKey: "courseName")
                gbCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: self.numberOfHoles[index].gb[i]))
                let flagCoordinates = gbCoord[i]
                let latitude = flagCoordinates.latitude
                let longitude = flagCoordinates.longitude
                let reference = "CmRRAAAA1ImMeBfqBlsMF9wcVZintvDjhn4lkBeDbqjajyL63tq48YIzS8TJ7kP3JHMVWlwLlaf-NVBrbo3ZmuCBZwY4G1xWDholdXgio3F35eow4nXQAjZkb0ydfmTi5AxPOl0JEhCOwmRWBu46PILZvxewngswGhQRcfpMXW3b2mdsZHkbnOHSrp65Hg"
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let place = Place(location: location, reference: reference, name: name, address: address as! String)
                self.places.append(place)
            }
            for i in 0..<self.numberOfHoles[index].fb.count{
                let name = " Bunker"
                let address = self.matchDataDictionary.value(forKey: "courseName")
                fbCoord.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: self.numberOfHoles[index].fb[i]))
                let flagCoordinates = fbCoord[i]
                let latitude = flagCoordinates.latitude
                let longitude = flagCoordinates.longitude
                let reference = "CmRRAAAA1ImMeBfqBlsMF9wcVZintvDjhn4lkBeDbqjajyL63tq48YIzS8TJ7kP3JHMVWlwLlaf-NVBrbo3ZmuCBZwY4G1xWDholdXgio3F35eow4nXQAjZkb0ydfmTi5AxPOl0JEhCOwmRWBu46PILZvxewngswGhQRcfpMXW3b2mdsZHkbnOHSrp65Hg"
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let place = Place(location: location, reference: reference, name: name, address: address as! String)
                self.places.append(place)
            }
            
            
            
            let flagCoordinates = self.centerPointOfTeeNGreen[index].green
            let name = " Flag# \(index+1)"
            let address = self.matchDataDictionary.value(forKey: "courseName")
            let latitude = flagCoordinates.latitude
            let longitude = flagCoordinates.longitude
            let reference = "CmRRAAAA1ImMeBfqBlsMF9wcVZintvDjhn4lkBeDbqjajyL63tq48YIzS8TJ7kP3JHMVWlwLlaf-NVBrbo3ZmuCBZwY4G1xWDholdXgio3F35eow4nXQAjZkb0ydfmTi5AxPOl0JEhCOwmRWBu46PILZvxewngswGhQRcfpMXW3b2mdsZHkbnOHSrp65Hg"
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let place = Place(location: location, reference: reference, name: name, address: address as! String)
            
            self.places.append(place)
            
            DispatchQueue.main.async {
                self.arViewController = ARViewController()
                self.arViewController.dataSource = self
                self.arViewController.maxDistance = 0
                self.arViewController.maxVisibleAnnotations = 30
                self.arViewController.maxVerticalLevel = 5
                self.arViewController.headingSmoothingFactor = 0.05
                
                self.arViewController.trackingManager.userDistanceFilter = 25
                self.arViewController.trackingManager.reloadDistanceFilter = 75
                self.arViewController.setAnnotations(self.places)
                self.arViewController.uiOptions.debugEnabled = false
                self.arViewController.uiOptions.closeButtonEnabled = true
                
                self.navigationController?.pushViewController(self.arViewController, animated: true)
            }
        }
        else{
            let alert = UIAlertController(title: "Alert" , message: "Please enable GPS to view Course in AR Mode.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        arViewController.present(alert, animated: true, completion: nil)
    }
    @IBAction func backButtonAction(_ sender: Any) {
        if isShowCase{
            backBtnHeader.isEnabled = false
        }
        else{
            backBtnHeader.isEnabled = true
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: NewGameVC.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: !isAcceptInvite)
                    break
                }
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(self.selectedUserId)").removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        if(selectClubDropper.status != .hidden){
            selectClubDropper.hide()
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(self.selectedUserId)").removeAllObservers()
    }
    var mapTimer = Timer()
    func getScoreFromMatchDataFirebases(){
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(self.selectedUserId)").observe(DataEventType.value, with: { (snapshot) in
            if  let scoreDict = (snapshot.value as? NSMutableDictionary){
                for playerDetails in self.playersButton{
                    if(playerDetails.isSelected){
                        for i in 0..<self.scoring[self.index].players.count{
                            if(self.scoring[self.index].players[i].value(forKey: self.selectedUserId) != nil){
                                self.playerIndex = i
                                let dict = NSMutableDictionary()
                                dict.addEntries(from: [self.selectedUserId:scoreDict])
                                self.scoring[self.index].players[i] = dict
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
    @IBAction func btnMVAction(_ sender: Any) {
        
        if(isMapViewColor){
            isMapViewColor = false
        }
        else{
            isMapViewColor = true
        }
        self.updateMap(indexToUpdate: index)
//        let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
//        self.navigationController?.pushViewController(viewCtrl, animated: true)

//        self.FindUser()
//        self.GetProMode()
        
    }
    func FindUser(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            var userData = NSMutableDictionary()
            if(snapshot.value != nil){
                userData = snapshot.value as! NSMutableDictionary
                for (key,value) in userData{
                    if let v = value as? NSMutableDictionary{
                        if((v.value(forKey: "iosToken")) != nil) && (v.value(forKey: "proMode") as! Bool) {
                            debugPrint("ios Key: \(key)")
//                            debugPrint("proMembership",v.value(forKey: "proMembership"))
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
            })
        }
    }


    @IBAction func btnStatsAction(_ sender: UIButton) {
        if(shotCount>0){
            if(newView.isHidden){
                self.lblWindSpeed.isHidden = true
                self.imgWindDir.isHidden = true
                self.stackViewForGreenShots.isHidden = true
                if(sender.tag == 1){
                    self.updateMapView(holeNumber:self.index,isRemove:true, isLeftRight: false)
                }else{
                    self.updateMapView(holeNumber:self.index,isRemove:false, isLeftRight: false)
                }
                self.statesStackView.isHidden = false
                newView.isHidden = false
                self.shotsFooterView.isHidden = true
                UIButton.animate(withDuration: 0.5, animations: {
                    self.heightOfNewView.constant =  self.statesStackView.frame.height + 32
                    self.newView.layoutIfNeeded()
                })
            }else{
                self.lblWindSpeed.isHidden = false
                self.imgWindDir.isHidden = false
                self.statesStackView.isHidden = true
                self.stackViewForGreenShots.isHidden = false
                self.newView.isHidden = true
                self.shotsFooterView.isHidden = false
                self.updateMap(indexToUpdate: self.index)
            }
        }else{
            let alertController = UIAlertController(title: "Alert", message: "Please play at least one shot to View your Stats", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    var isUserInsideBound = false
    var line = GMSPolyline()
    var isUpdating :Bool!
    var curvedLines = GMSPolyline()
    var curvedLine2 = GMSPolyline()
    var coordBound = Array<GMSCoordinateBounds>()
    var markers = [GMSMarker]()
    var dataDic = NSDictionary()
//    var actvtIndView: UIActivityIndicatorView!
    var index = 0
    var polygonArray = [[CLLocationCoordinate2D]]()
    var numberOfHoles = [(hole: Int,tee:[[CLLocationCoordinate2D]] ,fairway:[[CLLocationCoordinate2D]], green:[CLLocationCoordinate2D],fb:[[CLLocationCoordinate2D]],gb:[[CLLocationCoordinate2D]],wh:[[CLLocationCoordinate2D]])]()
    var bounds = [Bounds]()
    var centerPointOfTeeNGreen = [(tee:CLLocationCoordinate2D ,fairway:CLLocationCoordinate2D, green:CLLocationCoordinate2D,par:Int)]()
    var propertyArray = [Properties]()
    var shotCount:Int!
    var selectClubDropper :Dropper!
    var holeOutFlag : Bool!
    var isPintMarker = false

    var isInTheHole = false
    @IBAction func btnActionHoleOut(_ sender: Any) {
        self.isProcessing = true
        self.viewForEditShots.isHidden = true
        self.shotsFooterView.isUserInteractionEnabled = false
        var clubName = (self.btnSelectClub.titleLabel?.text)?.trim()
        if(isInTheHole){
            clubName = (currentShotsDetails[0].club).trim()
        }
        if(isPintMarker){
            if(BackgroundMapStats.findPositionOfPointInside(position: userLocationForClub!, whichFeature: self.numberOfHoles[index].green)){
                let emptyAlert = UIAlertController(title: "Confirmation", message: "Are you sure You want to update HoleFlag To your Current Location", preferredStyle: UIAlertControllerStyle.alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    let flagMarkers = self.markersForCurved.last!
                    flagMarkers.position = self.userLocationForClub!
                    self.updateLine(mapView: self.mapView, marker: flagMarkers)
                    self.isDraggingMarker = true
                    self.updateStateWhileDragging(marker:flagMarkers)
                    
                }))
                emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(emptyAlert, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController(title: "Alert", message: "You should be inside the Green.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        if(!holeOutFlag){
            if(isUserInsideBound){
                self.btnActionShots()
                isPintMarker = true
            }
                isUpdating = false
                self.penaltyShots.append(false)
                plotCurvedPolyline(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!,whichLine: false, club: clubName!)
                shotViseCurve.append((shot: shotCount, line: curvedLines, markerPosition: markerInfo))
                plotMarkerForCurvedLine(position: positionsOfDotLine.first!,userData: shotCount)
                plotMarkerForCurvedLine(position: positionsOfDotLine.last!,userData: shotCount+1)
                
                markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
                markersForCurved.last?.groundAnchor = CGPoint(x:0,y:1)
                positionsOfCurveLines.append(positionsOfDotLine.first!)
                positionsOfCurveLines.append(positionsOfDotLine.last!)
                if(shotCount>0){
                    positionsOfCurveLines = removeRepetedElement(curvedArray: positionsOfCurveLines)
                }
                for marker in markers{
                    marker.map = nil
                }
                line.map = nil
                markers[markers.count-2].map = nil
                for subview in stackViewForGreenShots.subviews {
                    subview.removeFromSuperview()
                }
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
                self.shotIndex = shotCount
                self.uploadStats(shot: shotCount, clubName: clubName!)
                if(!isBotTurn){
                    self.letsRotateWithZoom(latLng1: positionsOfCurveLines.first!, latLng2: positionsOfCurveLines.last!)
                    updateStateWhileDragging(marker:markersForCurved.last!)
                }
                if mode>0{
                    self.holeOutforAppsFlyer[self.playerIndex] += 1
                    Analytics.logEvent("mode\(mode)_holeout\(holeOutforAppsFlyer[self.playerIndex])", parameters: [:])
                }
        }
        suggestedMarker1.map = nil
        suggestedMarker2.map = nil
        var isBotAvailable = false
        for players in playersButton{
            if(players.id == "jpSgWiruZuOnWybYce55YDYGXP62"){
                isBotAvailable = true
            }
        }
        if(isBotAvailable) && !isBotTurn{
            var holeOutCount = 1
            for players in playersButton{
                for i in 0..<self.scoring[self.index].players.count{
                    if let shotsArray = self.scoring[self.index].players[i].value(forKey: "\(players.id)") as? NSMutableDictionary{
                        if(shotsArray.value(forKey: "holeOut") as! Bool){
                            holeOutCount += 1
                            print(holeOutCount)
                        }
                    }
                }
            }
            if(holeOutCount == playersButton.count){
                self.btnHoleOutInsideFooter.isHidden = true
                let btn = UIButton()
                btn.tag = self.shotCount
                btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
                self.shotCheck(btn)
                self.shotDetailsStackView.isHidden = true
                self.trackShotStackView.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.btnStatsView.tag = 0
                    if(!isShowCase){
                        self.btnStatsAction(self.btnStatsView)
                    }
                    
                    self.shotsFooterView.isUserInteractionEnabled = true
                    for data in self.playersButton{
                        data.button.isUserInteractionEnabled = true
                    }
                    for btn in self.playersButton{
                        if(btn.id == Auth.auth().currentUser!.uid){
                            self.buttonAction(sender: btn.button)
                            break
                        }
                    }
                })
                self.btnInTheHole.isHidden = true
            }else{
                self.btnHoleOutInsideFooter.isHidden = true
                let btn = UIButton()
                btn.tag = self.shotCount
                btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
                self.shotCheck(btn)
                self.shotDetailsStackView.isHidden = true
                self.trackShotStackView.isHidden = false
                
                
                self.shotsFooterView.isUserInteractionEnabled = true
                if(selectedUserId == Auth.auth().currentUser!.uid) && isBotAvailable{
                    for i in 0..<playersButton.count{
                        if(playersButton[i].id == "jpSgWiruZuOnWybYce55YDYGXP62"){
                            self.progressView.show(atView: self.view, navItem: self.navigationItem)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.progressView.hide(navItem: self.navigationItem)
                                self.buttonAction(sender:self.playersButton[i].button)
                            })
                            break
                        }
                    }
                }else{
                    for data in self.playersButton{
                        data.button.isUserInteractionEnabled = true
                    }
                }
            }
        }else{
            self.btnHoleOutInsideFooter.isHidden = true
            let btn = UIButton()
            btn.tag = self.shotCount
            btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
            self.shotCheck(btn)
            self.shotDetailsStackView.isHidden = true
            self.trackShotStackView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.btnStatsView.tag = 0
                if(!isShowCase){
                    self.btnStatsAction(self.btnStatsView)
                }
                self.shotsFooterView.isUserInteractionEnabled = true
            })
            self.btnInTheHole.isHidden = true
        }
        self.view.isUserInteractionEnabled = true
        //        self.mapView.settings.consumesGesturesInView = true
    }
    
    @IBAction func btnActionSelectClub(_ sender: UIButton) {
        selectClubDropper.maxHeight = 200
        if selectClubDropper.status == .hidden {
            selectClubDropper.theme = Dropper.Themes.white
            selectClubDropper.cornerRadius = 3
            self.view.bringSubview(toFront: selectClubDropper)
            selectClubDropper.showWithAnimation(0.15, options: Dropper.Alignment.left, position: .top, button: self.shotsFooterView)
        } else {
            selectClubDropper.hideWithAnimation(0.1)
        }
    }
    @IBAction func btnActionShotsCount(_ sender: Any) {
        isProcessing = true
        viewForEditShots.isHidden = true
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        self.suggestedMarker1.map = nil
        self.suggestedMarker2.map = nil
        let shotClub = self.btnSelectClub.titleLabel?.text
        if(!holeOutFlag){
            if(isUserInsideBound){
                self.btnActionShots()
            }
            else{
                if(!holeOutFlag){
                    isUpdating = false
                    self.penaltyShots.append(false)
                    plotCurvedPolyline(latLng1: positionsOfDotLine[0], latLng2: positionsOfDotLine[1],whichLine: false,club:shotClub!)
                    positionsOfCurveLines.append(positionsOfDotLine[0])
                    positionsOfCurveLines.append(positionsOfDotLine[1])
                    
                    let heading = GMSGeometryHeading(positionsOfDotLine[1], positionsOfDotLine[2])
                    let dist = GMSGeometryDistance(positionsOfDotLine[1], positionsOfDotLine[2])*YARD
                    var midPoint = GMSGeometryOffset(positionsOfDotLine[1], GMSGeometryDistance(positionsOfDotLine[1], positionsOfDotLine[2])*0.7, heading)
                    if(dist<201) && Int(dist)>0{
                        for i in 1..<Int(dist){
                            if(BackgroundMapStats.findPositionOfPointInside(position: midPoint, whichFeature: self.numberOfHoles[index].green)){
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
                        positionsOfCurveLines = removeRepetedElement(curvedArray: positionsOfCurveLines)
                    }
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
                    shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo))
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
                    if(isBotTurn){
                        for marker in markersForCurved{
                            marker.map = nil
                        }
                    }
                }
                shotCount = shotCount+1
                self.shotIndex = shotCount
                self.btnShotsCount.setTitle("Shot \(shotCount!+1)", for: .normal)
                self.lblHoleSubtitle.text = "Shot \(shotCount!+1)"
                self.btnTrackShot.setTitle("Take Shot \(shotCount!+1)", for: .normal)
                self.uploadStats(shot: shotCount,clubName:shotClub!)
                if(!self.isBotTurn){
                    self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.plotLine(positions: self.positionsOfDotLine)
                        self.viewForEditShots.bringSubview(toFront: self.view)
                        self.viewForEditShots.frame.origin = CGPoint(x: self.view.frame.width - self.viewForEditShots.frame.width , y: 134)
                        self.tappedMarker = self.shotViseCurve.last?.markerPosition
                        self.viewForEditShots.isHidden = false

                    })
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        let btn = UIButton()
                        btn.tag = 44
                        btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
                        self.shotCheck(btn)
                        self.shotDetailsStackView.isHidden = true
                        self.trackShotStackView.isHidden = false
                        self.btnLeftShot.isEnabled = true
                        self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
                        self.btnRightShot.isEnabled = false
                        self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.shotDetailsStackView.isHidden = false
                            self.trackShotStackView.isHidden = true
                            self.btnHoleOutInsideFooter.isHidden = true
                            self.progressView.hide(navItem: self.navigationItem)
                            if GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!)*YARD < 100{
                                self.btnHoleOutInsideFooter.isHidden = false
                            }
                        })
                    })
                    
                }else{
                    self.progressView.hide(navItem: self.navigationItem)
                }

            }
        }
    }
    
    func btnActionShots() {
        let clubName = (self.btnSelectClub.titleLabel?.text)?.trim()
        
        if(!holeOutFlag){
            isUpdating = false
            for view in (self.btnTrackShot.superview as! UIStackView).arrangedSubviews{
                if view.tag == 22{
                    view.removeFromSuperview()
                    break
                }
            }
            var invisibleBtn = UIButton()
            if(btnTrackShot.currentTitle?.contains("Shot"))!{
                //                self.btnShotsCount.setTitle("Stop & Score", for: .normal)
                self.btnTrackShot.setTitle("Stop Tracking", for: .normal)
                lblHoleSubtitle.text = "Shot \(shotCount!+1) Tracking...."
                if(isPintMarker){
                    lblHoleSubtitle.text = "Shot \(shotCount!+1)"
                }
                self.btnHoleOutInsideFooter.isHidden = true
                
                lblHoleSubtitle.textColor = UIColor.glfWarmGrey
                solidLine.map = nil
                let newDict = NSMutableDictionary()
                newDict.setObject(clubName!, forKey: "club" as NSCopying)
                newDict.setObject(self.previousUserLocation.latitude, forKey: "lat1" as NSCopying)
                newDict.setObject(self.previousUserLocation.longitude, forKey: "lng1" as NSCopying)
                newDict.setObject(self.positionsOfDotLine[0].latitude, forKey: "lat2" as NSCopying)
                newDict.setObject(self.positionsOfDotLine[0].longitude, forKey: "lng2" as NSCopying)
                newDict.setObject(self.shotCount, forKey: "shot_no" as NSCopying)
                if(shotCount > 0){
                    newDict.setObject(self.previousUserLocation.latitude, forKey: "lat1" as NSCopying)
                    newDict.setObject(self.previousUserLocation.longitude, forKey: "lng1" as NSCopying)
                    
                }else{
                    positionsOfCurveLines.append(positionsOfDotLine[0])
                    self.previousUserLocation = positionsOfDotLine[0]
                    for i in 1..<markers.count-1{
                        markers[i].map = nil
                    }
                    markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                    markers.last?.groundAnchor = CGPoint(x:0,y:1)
                    
                }
                ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(Auth.auth().currentUser!.uid)/shotTracking").updateChildValues(newDict as! [AnyHashable : Any])
                ref.child("matchData/\(self.currentMatchId)/player/\(Auth.auth().currentUser!.uid)/").updateChildValues(["mode":"On Course"] as [AnyHashable : Any])
                var distance = GMSGeometryDistance(self.positionsOfCurveLines.last! ,self.positionsOfDotLine.last!)
                var suffix = "meter"
                if(distanceFilter != 1){
                    distance = distance*YARD
                    suffix = "yard"

                }

                self.isTracking = true
                for view in (self.btnTrackShot.superview as! UIStackView).arrangedSubviews{
                    if view.isKind(of: UIButton.self){
                        if(view as! UIButton).currentTitle == "b"{
                            invisibleBtn = view as! UIButton
                            view.removeFromSuperview()
                        }
                    }
                }
                let btn = UIButton()
                btn.setBackgroundImage(#imageLiteral(resourceName: "cross"), for: .normal)
                btn.backgroundColor = UIColor.glfWarmGrey
                btn.addTarget(self, action: #selector(self.cancelAction(_:)), for: .touchUpInside)
                btn.tag = 22
                self.shotDetailsStackView.insertArrangedSubview(btn, at: 3)
                if(isPintMarker){
                    lblHoleSubtitle.text = "Shot \(shotCount!+1)"
                }
            }
            else{
                self.isTracking = false
                (self.btnTrackShot.superview as! UIStackView).insertArrangedSubview(invisibleBtn, at: (self.btnTrackShot.superview as! UIStackView).arrangedSubviews.count-2)
                self.penaltyShots.append(false)
                positionsOfCurveLines.append(self.positionsOfDotLine[0])
                solidLine.map = nil
                let midPoint = BackgroundMapStats.middlePointOfListMarkers(listCoords: [positionsOfDotLine[1], positionsOfDotLine[2]])
                positionsOfDotLine[0]  = positionsOfCurveLines.last!
                positionsOfDotLine[1] = midPoint
                isUpdating = false
                plotCurvedPolyline(latLng1: positionsOfCurveLines[shotCount], latLng2: positionsOfCurveLines[shotCount+1],whichLine: false, club: clubName!)
                plotMarkerForCurvedLine(position:positionsOfCurveLines[shotCount+1] ,userData: shotCount+1)
                if(shotCount>1){
                    positionsOfCurveLines = removeRepetedElement(curvedArray: positionsOfCurveLines)
                }
                for marker in markers{
                    marker.map = nil
                }
                markers.removeAll()
                for i in 0..<positionsOfDotLine.count{
                    plotMarker(position: positionsOfDotLine[i], userData: i)
                }
                markers.last?.icon = #imageLiteral(resourceName: "holeflag")
                markers.last?.groundAnchor = CGPoint(x:0,y:1)
                markers.last?.map = self.mapView
                let mid = markers.count/2
                markers[mid].icon = #imageLiteral(resourceName: "target")
                
                plotLine(positions: positionsOfDotLine)
                shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo))
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
                self.shotIndex = shotCount
                
                self.uploadStats(shot: shotCount,clubName: clubName!)
                self.btnShotsCount.setTitle("Shot \(shotCount!+1)", for: .normal)
                self.lblHoleSubtitle.text = "Shot \(shotCount!+1)"
                self.btnTrackShot.setTitle("Track Shot \(shotCount!+1)", for: .normal)
                
                self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
                self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                
                var distance = GMSGeometryDistance(self.positionsOfCurveLines.last! ,self.positionsOfDotLine.last!)
                var suffix = "meter"
                if(distanceFilter != 1){
                    distance = distance*YARD
                    suffix = "yard"
                }

                if(!self.isBotTurn){
                    self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.plotLine(positions: self.positionsOfDotLine)
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        let btn = UIButton()
                        btn.tag = 44
                        btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
                        self.shotCheck(btn)
                        self.shotDetailsStackView.isHidden = true
                        self.trackShotStackView.isHidden = false
                        self.btnLeftShot.isEnabled = true
                        self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
                        self.btnRightShot.isEnabled = false
                        self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.shotDetailsStackView.isHidden = false
                            self.trackShotStackView.isHidden = true
                            self.btnHoleOutInsideFooter.isHidden = true
                            if !(self.holeOutFlag){
                                if GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!)*YARD < 100{
                                    self.btnHoleOutInsideFooter.isHidden = false
                                }
                            }
                        })
                    })
                    
                }
            }
            self.progressView.hide(navItem: self.navigationItem)
        }
    }
    @objc func cancelAction(_ sender: UIButton){
        debugPrint("Cancle Pressed")
        self.positionsOfDotLine.remove(at: 0)
        for view in (self.btnTrackShot.superview as! UIStackView).arrangedSubviews{
            if view.tag == 22{
                view.removeFromSuperview()
                break
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(Auth.auth().currentUser!.uid)/shotTracking").setValue(nil)

        if(self.positionsOfCurveLines.count > 0){
            self.positionsOfDotLine.insert(positionsOfCurveLines.last! , at: 0)
        }else{
            self.positionsOfDotLine.insert( self.centerPointOfTeeNGreen[self.index].tee, at: 0)
        }
        
        self.updateMap(indexToUpdate: self.index)
    }
    
    func getPoints(hole:CLLocationCoordinate2D,greenPath:[CLLocationCoordinate2D],gir:Double,insideDistance:Double)->CLLocationCoordinate2D{
        var latLngArray = greenPath
        var greenHeadingAngle = 0.0
        var distance = 0.0
        var maxDistance = 0.0
        let generatedDistance = 0.0
        var distanceArray = [Double]()
        var offsetLatLong = CLLocationCoordinate2D()
        for i in 0..<latLngArray.count{
            distance = GMSGeometryDistance(hole,latLngArray[i])
            distanceArray.append(distance)
            if(maxDistance < distance){
                maxDistance = distance;
            }
        }
        var dX = 20.0
        if(insideDistance < 5){
            dX = 2.0 * insideDistance
        }
        let maximumDistance = insideDistance-dX > dX ? insideDistance-dX : dX
        let minimumDistance = insideDistance-dX < dX ? insideDistance-dX : dX
        
        let convertInside = Int(maximumDistance-minimumDistance)
        let randomGeneratedDistance = Int(arc4random_uniform(UInt32(convertInside))) + Int(minimumDistance)
        let randomGir = Double(arc4random_uniform(100))
        
        for _ in 0..<latLngArray.count{
            var randomHeading = Int(arc4random_uniform(UInt32(latLngArray.count - 1)))
            randomHeading += 1
            if(randomHeading == latLngArray.count){
                randomHeading = 0
            }
            if(randomGir<gir) {
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                if (insideDistance - maxDistance > 20) {
                    offsetLatLong = GMSGeometryOffset(hole,insideDistance, greenHeadingAngle)
                    break
                }
                
                if(generatedDistance<maxDistance){
                    if(distanceArray[randomHeading] > Double(randomGeneratedDistance)) {
                        greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                        offsetLatLong = GMSGeometryOffset(hole,Double(randomGeneratedDistance), greenHeadingAngle)
                        break
                    }
                }
                
                if (generatedDistance > maxDistance) {
                    greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                    offsetLatLong = GMSGeometryOffset(hole,(maxDistance - Double(arc4random_uniform(5)) > 0 ? 2:maxDistance -  Double(arc4random_uniform(5))), greenHeadingAngle)
                    break
                }
            }else{
                distance = GMSGeometryDistance(hole,latLngArray[randomHeading])
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                offsetLatLong = GMSGeometryOffset(hole,Double(distance) + Double(arc4random_uniform(20)), greenHeadingAngle)
                break
            }
        }
        if(offsetLatLong.latitude == 0){
            offsetLatLong = GMSGeometryOffset(hole,insideDistance, Double(arc4random_uniform(360)))
        }
        return offsetLatLong
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
                        self.btnActionShotsCount(self.btnShotsCount)
                        
                    }
                    if(i == 2){
                        let heading = Double(arc4random_uniform(360))
                        let rndmDist = Int(arc4random_uniform(2)) + 1
                        let newCoord = GMSGeometryOffset(holeCoord, Double(rndmDist)*0.3048, heading)
                        self.positionsOfDotLine[1] = newCoord
                        self.btnActionShotsCount(self.btnShotsCount)
                    }
                }
            }else{
                for _ in 1..<minimumShot{
                    let heading = Double(arc4random_uniform(360))
                    let rndmDist = Int(arc4random_uniform(2)) + 1
                    let newCoord = GMSGeometryOffset(holeCoord, Double(rndmDist)*0.3048, heading)
                    self.positionsOfDotLine[1] = newCoord
                    self.btnActionShotsCount(self.btnShotsCount)
                }
            }
        }
    }
    
    func updateMapWithColors(){
        let circleCenter = self.mapView.camera.target
        let circ = GMSCircle(position: circleCenter, radius: 10000)
        circ.fillColor = UIColor.glfBluegreen
        circ.map = self.mapView
        
        for i in 0..<self.numberOfHoles[index].tee.count{
            self.drawPolygonWithColor(polygonArray: (self.numberOfHoles[index].tee)[i], color: UIColor.glfGreenBlue)
        }
        for i in 0..<self.numberOfHoles[index].fairway.count{
            self.drawPolygonWithColor(polygonArray: (self.numberOfHoles[index].fairway)[i],color:UIColor.glfGreenBlue)
        }
        self.drawPolygonWithColor(polygonArray: (self.numberOfHoles[index].green),color:UIColor.glfGreenishTurquoise)
        
        for i in 0..<self.numberOfHoles[index].gb.count{
            self.drawPolygonWithColor(polygonArray: (self.numberOfHoles[index].gb)[i],color:UIColor.glfOffWhite)
        }
        for i in 0..<self.numberOfHoles[index].fb.count{
            self.drawPolygonWithColor(polygonArray: (self.numberOfHoles[index].fb)[i],color:UIColor.glfOffWhite)
        }
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "CustomStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    func removeRepetedElement(curvedArray : [CLLocationCoordinate2D] )->[CLLocationCoordinate2D]{
        var uniqueArray = [CLLocationCoordinate2D]()
        
        if(curvedArray.count > 1){
            var lat = [CLLocationDegrees]()
            var lng = [CLLocationDegrees]()
            for i in 0..<curvedArray.count{
                lat.append(curvedArray[i].latitude)
                lng.append(curvedArray[i].longitude)
            }
            lat = lat.removeDuplicates()
            lng = lng.removeDuplicates()
            for i in 0..<lng.count{
                uniqueArray.append(CLLocationCoordinate2D(latitude: lat[i], longitude: lng[i]))
            }
        }
        return uniqueArray
    }
    //    func removeRepetedByDistanceZero(arr:[CLLocationCoordinate2D])->[CLLocationCoordinate2D]{
    //        let uniqueArray = [CLLocationCoordinate2D]()
    //        for i in 1..<arr.count{
    //
    //        }
    //        return uniqueArray
    //    }
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
        marker.isDraggable = !isBotTurn
        marker.isTappable = false //for first version of golfication add penalty shots
        markersForCurved.append(marker)
    }
    
    @IBAction func btnActionShotMenu(_ sender: UIButton) {
        if(tappedMarker != nil) && selectedUserId != "jpSgWiruZuOnWybYce55YDYGXP62"{
            var j = 0
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            for i in 0..<penaltyShots.count{
                if(penaltyShots[i])&&(j==i){
                    //                    self.newMenuView.frame.size.height = 35
                    for view in self.newMenuView.subviews{
                        if !(view.tag == 1){
                           (view as! UIButton).isHidden = true
                        }else{
//                           (view as! UIButton).center = self.newMenuView.center
                        }
                    }
                    break
                }else{
                    for view in self.newMenuView.subviews where !(view.tag == 1){
                        (view as! UIButton).isHidden = false
                    }
                }
                
            }
            if(newMenuView.isHidden){
                newMenuView.isHidden = false
            }else{
                newMenuView.isHidden = true
            }
            newMenuView.frame.origin = CGPoint(x:self.view.frame.width-98,y:self.shotsFooterView.frame.minY - 145)
            if(sender.tag > 0){
                self.newMenuView.isHidden = true
                var array = ["Add","Delete","Penalty","Edit","Share"]
                for data in shotViseCurve{
                    tappedMarker = nil
                    if data.shot == sender.tag-1{
                        tappedMarker = data.markerPosition
                        break
                    }
                }
                for k in 0..<penaltyShots.count{
                    if(penaltyShots[k]) && sender.tag-1 == k{
                        array = ["Delete"]
                        break
                    }
                }
                ActionSheetStringPicker.show(withTitle: "Select Options", rows: array, initialSelection: 0, doneBlock: { (picker, value, index) in
                    print(sender.tag)
                    print(value)
                    if(array.count > 1){
                        switch  value{
                        case 0:
                            self.addShot(sender)
                            break
                        case 1:
                            self.deleteShot(sender)
                            break
                        case 2:
                            self.penaltyShot(sender)
                            break
                        case 3:
                            self.editShot(sender)
                            break
                        case 4:
                            self.shareShot(sender)
                            break
                        default:
                            break
                        }
                    }else{
                        self.deleteShot(sender)
                    }
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin:sender)
            }
            
        }

    }
    func plotCTShowCase(){
    
        var newPoint = CLLocationCoordinate2D()
        let continueButton = UIButton()
        continueButton.frame = CGRect(x: 16, y:0, width: 100, height: 44)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setCorner(color: UIColor.white.cgColor)
        continueButton.isHidden = true
        continueButton.backgroundColor = UIColor.glfBluegreen
        self.mapView.addSubview(continueButton)
        
        let btnEndTutorial = UIButton()
        btnEndTutorial.frame = CGRect(x: self.statesStackView.frame.width/2 - 50, y:self.view.frame.height-100, width: 100, height: 44)
        btnEndTutorial.setTitle("End Tutorial", for: .normal)
        btnEndTutorial.setCorner(color: UIColor.white.cgColor)
        btnEndTutorial.isHidden = true
        btnEndTutorial.backgroundColor = UIColor.glfBluegreen
        self.mapView.addSubview(btnEndTutorial)
        
        //        let viewForSG = UIView(frame: CGRect(x: self.statesStackView.frame.width * 0.65, y:self.statesStackView.frame.origin.y, width: statesStackView.frame.width*0.38, height: (self.shotDetailsStackView.frame.height + 16)*3))
        
        let showcaseEnd = CTShowcaseView(title: "", message: "You're good to go! Use Golfication on-course with GPS, or simply track your stats post-fame.\n Tap End Tutorial to get your Free Pro Membership.", key:nil) { () -> () in
            ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatch/\(self.currentMatchId)").removeValue()
            if(self.currentMatchId.count > 1){
                ref.child("matchData/\(self.currentMatchId)").removeValue()
                matchId = ""
                self.shotsFooterView.isUserInteractionEnabled = true
                self.mapView.settings.scrollGestures = true
            }
            isShowCase = false// Do something for New User
            addPlayersArray.removeAllObjects()
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: NewGameVC.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: false)
                    break
                }
            }
            continueButton.removeFromSuperview()
            if UserDefaults.standard.object(forKey: "isNewUser") as? Bool != nil{
                let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
                if newUser{
                    let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "NewUserProPopUPVC") as! NewUserProPopUPVC
//                    viewCtrl.modalPresentationStyle = .overCurrentContext
//                    //let proNavCtrl = UINavigationController(rootViewController: viewCtrl)
//                    self.present(viewCtrl, animated: true, completion: nil)
                    
                    let navCtrl = UINavigationController(rootViewController: viewCtrl)
                    navCtrl.modalPresentationStyle = .overCurrentContext
                    self.present(navCtrl, animated: false, completion: nil)
                }
            }
            
        }
        showcaseEnd.continueButton.isEnabled = true
        showcaseEnd.continueButton.setTitle("End Round", for: .normal)
        let highlighterForEnd = showcaseEnd.highlighter as! CTStaticGlowHighlighter
        highlighterForEnd.highlightColor = UIColor.glfFlatBlue
        let showcaseBarChart = CTShowcaseView(title: "", message: "This is how you fared against DeeJay, Our A.I. bot of the month.Not bad!", key:nil) { () -> () in
            btnEndTutorial.isHidden = false
            showcaseEnd.setup(for : btnEndTutorial , offset:.zero, margin : 5)
            showcaseEnd.show()
        }
        let highlighterForBarChart = showcaseBarChart.highlighter as! CTStaticGlowHighlighter
        highlighterForBarChart.highlightColor = UIColor.glfFlatBlue
        
        let showcaseStrokesGained = CTShowcaseView(title: "", message: "Your strokes gained versus the PGA Tour.", key:"strokesGained") { () -> () in
            //            viewForSG.removeFromSuperview()
            showcaseBarChart.setup(for:self.barChartParentStackView, offset: .zero , margin: 5)
            showcaseBarChart.show()
        }
        let highlighterForStrokesGained = showcaseStrokesGained.highlighter as! CTStaticGlowHighlighter
        highlighterForStrokesGained.highlightColor = UIColor.glfWhite
        //        self.newView.addSubview(viewForSG)
        let showCaseStatsView = CTShowcaseView(title: "", message: "Check out your stats for this hole.", key:"statsView") { () -> () in
            continueButton.removeFromSuperview()
            self.btnStatsAction(self.btnStatsView)
            showcaseStrokesGained.setup(for:self.shotParentStackView, offset: .zero , margin: 0)
            showcaseStrokesGained.show()
        }
        let highlighterForStatsView = showCaseStatsView.highlighter as! CTStaticGlowHighlighter
        highlighterForStatsView.highlightColor = UIColor.glfWhite
        
        let showCaseHoleOut = CTShowcaseView(title: "", message: "It's your lucky day. Hole-out with one-putt, and make a Birdie.", key:"holeOut") { () -> () in
            showCaseStatsView.setup(for:self.btnStatsView , offset: .zero , margin: 5)
            self.btnActionHoleOut(self.btnHoleOut)
            showCaseStatsView.show()
        }
        let highlighterForHoleOut = showCaseHoleOut.highlighter as! CTStaticGlowHighlighter
        highlighterForHoleOut.highlightColor = UIColor.glfWhite
        highlighterForHoleOut.highlightType = .rect
        
        
        let showCaseDJon = CTShowcaseView(title:"", message:"DeeJay is taking his second shot.", key:"p1"){()->() in
            continueButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.plotCurvedPolylineShowCase(latLng1: newPoint, latLng2: self.positionsOfDotLine.last!, ind: 2)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                showCaseHoleOut.setup(for:self.btnHoleOutInsideFooter , offset: .zero , margin: 5)
                showCaseHoleOut.show()
            })
        }
        let highliterForDJ = showCaseDJon.highlighter as! CTStaticGlowHighlighter
        highliterForDJ.highlightColor = UIColor.clear
        showCaseDJon.continueButton.isHidden = false
        
        let showCasePressShot = CTShowcaseView(title: "", message: "Approach the Green with your second shot.", key:"pressShot") { () -> () in
            self.btnActionShotsCount(self.btnTrackShot)
            self.markerInfo.map = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                showCaseDJon.setup(for:continueButton , offset: .zero , margin: 0)
                showCaseDJon.show()
            })
        }
        let highlighterForShots = showCasePressShot.highlighter as! CTStaticGlowHighlighter
        highlighterForShots.highlightColor = UIColor.glfWhite
        highlighterForShots.highlightType = .rect
        
        let showCasePress = CTShowcaseView(title:"", message:"DeeJay's turn to tee-off.", key:"p"){()->() in
            let distance = GMSGeometryDistance(self.positionsOfCurveLines[0], self.positionsOfCurveLines[1])
            let heading = GMSGeometryHeading(self.positionsOfCurveLines[0], self.positionsOfCurveLines[1])
            newPoint = GMSGeometryOffset(self.positionsOfCurveLines[0], distance*1.1, heading)
            continueButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.plotCurvedPolylineShowCase(latLng1: self.positionsOfCurveLines[0], latLng2: newPoint, ind: 1)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                showCasePressShot.setup(for:self.btnTrackShot , offset: .zero , margin: 5)
                showCasePressShot.show()
            })
            
        }
        let highliter = showCasePress.highlighter as! CTStaticGlowHighlighter
        highliter.highlightColor = UIColor.clear
        showCasePress.continueButton.isHidden = false
        let showCasePressShot1 = CTShowcaseView(title: "", message: "Tap Shot 1 to record your tee-shot.", key:"preshShot1") { () -> () in
            self.btnActionShotsCount(self.btnTrackShot)
            continueButton.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                showCasePress.setup(for:continueButton , offset: .zero , margin: 0)
                showCasePress.show()
            })
        }
        let highlighterForShots1 = showCasePressShot1.highlighter as! CTStaticGlowHighlighter
        highlighterForShots1.highlightColor = UIColor.glfWhite
        
        
        let showCaseSelectClubFromDropper = CTShowcaseView(title: "", message: "Select your preferred club.", key:"clubDropper") { () -> () in
            if((self.selectClubDropper.status == .shown ) || (self.selectClubDropper.status == .displayed)){
                self.selectClubDropper.hide()
            }
            showCasePressShot1.setup(for:self.btnTrackShot , offset: .zero , margin: 5)
            showCasePressShot1.show()
            
        }
        let highlighterSelectClubDropper = showCaseSelectClubFromDropper.highlighter as! CTStaticGlowHighlighter
        highlighterSelectClubDropper.highlightColor = UIColor.glfWhite
        
        let showCaseSelectClub = CTShowcaseView(title: "", message: "\((self.btnSelectClub.titleLabel?.text)!) is recommended. Tap here to change club.", key:"selectClub") { () -> () in
            self.btnActionSelectClub(self.btnSelectClub)
            showCaseSelectClubFromDropper.setup(for:self.selectClubDropper , offset: .zero , margin: 0)
            showCaseSelectClubFromDropper.show()
        }
        let highlighter = showCaseSelectClub.highlighter as! CTStaticGlowHighlighter
        highlighter.highlightColor = UIColor.glfWhite
        
        var label2 = UILabel()
        let showCaseTargetLine = CTShowcaseView(title: "", message: "Tap anywhere on the fairway to get free club recommendations for your shot.", key:"targetLine") { () -> () in
            label2.removeFromSuperview()
            showCaseSelectClub.setup(for:self.btnSelectClub , offset: .zero , margin: 5)
            showCaseSelectClub.show()
        }
        
        let highlighterForTargetLine = showCaseTargetLine.highlighter as! CTStaticGlowHighlighter
        highlighterForTargetLine.highlightColor = UIColor.glfWhite
        highlighterForTargetLine.highlightType = .circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            if(self.positionsOfDotLine.count > 1){
                let point = self.mapView.projection.point(for: self.positionsOfDotLine[1])
                label2 = UILabel(frame: CGRect(x: point.x-25, y: point.y-35, width: 50, height: 50))
                self.mapView.addSubview(label2)
                showCaseTargetLine.setup(for:label2 , offset: .zero , margin: 5)
                showCaseTargetLine.show()
                self.shotsFooterView.isUserInteractionEnabled = false
                self.mapView.settings.scrollGestures = false
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isHoleByHole){
           startingHole =  Int(matchDataDictionary.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as! String)!
        }else{
            startingHole = Int(self.matchDataDictionary.value(forKey: "startingHole") as! String)!
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.doAfterResponse(_:)), name: NSNotification.Name(rawValue: "response9"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getMatchId"), object: matchId)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.sendNotificationOnCourse(_:)), name: NSNotification.Name(rawValue: "updateLocation"),object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.stopTrackingFromNotification(_:)), name: NSNotification.Name(rawValue: "shotTracking"),object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHoleFromNotification(_:)), name: NSNotification.Name(rawValue: "holeChange"),object: nil)
        self.btnViewScorecard.setCorner(color: UIColor.glfFlatBlue.cgColor)
        self.btnEndRoundInBetween.setCorner(color: UIColor.glfWarmGrey.cgColor)
        if UIDevice.current.iPhoneX {
            self.iphoneXBottomConstraints.constant = -24
        }
        let imgArr = [#imageLiteral(resourceName: "trash"),#imageLiteral(resourceName: "penalty"),#imageLiteral(resourceName: "edit"),#imageLiteral(resourceName: "share_green")]
        self.viewForEditShots.layer.cornerRadius = 5.0
        self.viewForEditShots.backgroundColor = UIColor.glfWhite
        var tag = 0
        for i in imgArr{
            let btn = UIButton(frame:CGRect(x:tag*28,y:0,width:25,height:25))
            btn.setImage(i, for: .normal)
            btn.tag = tag
            if(tag == 0){
                btn.addTarget(self, action: #selector(deleteShot(_:)), for: .touchUpInside)
            }else if(tag == 1){
                btn.addTarget(self, action: #selector(penaltyShot(_:)), for: .touchUpInside)
            }else if(tag == 2){
                btn.addTarget(self, action: #selector(editShot(_:)), for: .touchUpInside)
            }else{
                btn.addTarget(self, action: #selector(shareShot(_:)), for: .touchUpInside)
            }
            tag += 1
            
            self.viewForEditShots.addSubview(btn)
        }
        let imgArr1 = [#imageLiteral(resourceName: "add"),#imageLiteral(resourceName: "trash"),#imageLiteral(resourceName: "penalty"),#imageLiteral(resourceName: "edit"),#imageLiteral(resourceName: "share_green")]
        newMenuView.backgroundColor = UIColor.glfWhite
        let str = [" Add"," Delete"," Penalty"," Edit"," Share"]
        var tg = 0
        for i in imgArr1{
            let btn = UIButton(frame:CGRect(x: 8, y: (tg*30), width: 80, height: 25))
            btn.setImage(i, for: .normal)
            btn.setTitle(str[tg], for: .normal)
            btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 14)
            btn.setTitleColor(UIColor.glfBlack, for: .normal)
            btn.contentHorizontalAlignment = .left
            btn.tag = tg
            if(tg == 0){
                btn.addTarget(self, action: #selector(addShot(_:)), for: .touchUpInside)
            }else if(tg == 1){
                btn.addTarget(self, action: #selector(deleteShot(_:)), for: .touchUpInside)
            }else if(tg == 2){
                btn.addTarget(self, action: #selector(penaltyShot(_:)), for: .touchUpInside)
            }else if(tg == 3){
                btn.addTarget(self, action: #selector(editShot(_:)), for: .touchUpInside)
            }else{
                btn.addTarget(self, action: #selector(shareShot(_:)), for: .touchUpInside)
            }
            tg += 1
            newMenuView.addSubview(btn)
        }
        
        
        btnForSuggMark1.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
        let layer1 = CAGradientLayer()
        layer1.frame.size = btnForSuggMark1.frame.size
        layer1.startPoint = .zero
        layer1.endPoint = CGPoint(x: 1, y: 0)
        layer1.colors = [UIColor.glfFlatBlue.cgColor, UIColor.glfFlatBlue.cgColor, UIColor.glfWhite.cgColor, UIColor.glfWhite.cgColor]
        layer1.locations = [0.0,0.25 ,0.25,1.0]
        layer1.cornerRadius = 5

        btnForSuggMark1.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark1.layer.insertSublayer(layer1, at: 0)
        btnForSuggMark1.titleLabel?.textColor = UIColor.glfBlack
        btnForSuggMark1.imageView?.layer.zPosition = 1
        btnForSuggMark1.addTarget(self, action: #selector(markerAction), for: .touchUpInside)

        
        btnForSuggMark2.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
        let layer2 = CAGradientLayer()
        layer2.frame.size = btnForSuggMark1.frame.size
        layer2.startPoint = .zero
        layer2.endPoint = CGPoint(x: 1, y: 0)
        layer2.colors = [UIColor.glfFlatBlue.cgColor, UIColor.glfFlatBlue.cgColor, UIColor.glfWhite.cgColor, UIColor.glfWhite.cgColor]
        layer2.locations = [0.0,0.25 ,0.25,1.0]
        layer2.cornerRadius = 5
        btnForSuggMark2.setImage(#imageLiteral(resourceName: "club_map"), for: .normal)
        btnForSuggMark2.layer.insertSublayer(layer2, at: 0)
        btnForSuggMark2.titleLabel?.textColor = UIColor.glfBlack
        btnForSuggMark2.imageView?.layer.zPosition = 1
        btnForSuggMark2.addTarget(self, action: #selector(markerAction), for: .touchUpInside)
        
        
        newMenuView.layer.cornerRadius = 5
        self.btnShotsCount.isHidden = true
        self.btnHoleOut.isHidden = true
        self.multiplayerPageControl.numberOfPages = playersButton.count
        self.multiplayerPageControl.hidesForSinglePage = true
        self.btnReviewHoleDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.lblHoleSubtitle.text = "     "
        self.btnTrackShot.layer.cornerRadius = 3
        self.btnHoleOutInsideFooter.layer.cornerRadius = 3
        let originalImage =  #imageLiteral(resourceName: "backArrow")
        let backBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backBtnHeader.setBackgroundImage(backBtnImage, for: .normal)
        backBtnHeader.tintColor = UIColor.glfWhite
        
        self.navigationController?.navigationBar.isHidden = true
        self.statesStackView.isHidden = true
        self.overlayView = UIView(frame:self.mapView.frame)
        self.overlayView.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        
        self.btnNextHole.layer.cornerRadius = 3
        
        self.btnReviewHole.setTitleColor(UIColor.glfWarmGrey, for: .normal)
        if(!isHoleByHole){
            let onCourse = matchDataDic.value(forKeyPath: "onCourse") as! Bool
            if !(onCourse){
                self.btnOnOffCourse.setImage(#imageLiteral(resourceName: "gray_dot"), for: .normal)
                self.btnGreenDot.setImage(#imageLiteral(resourceName: "gray_dot"), for: .normal)
                self.btnOnOffCourse.setTitle(" Off Course Mode ", for: .normal)
                self.btnOnOffCourse.tag = 0
                self.btnARView.isHidden = true
            }else{
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                self.mapView.isMyLocationEnabled = true
                self.btnOnOffCourse.tag = 1
                self.btnGreenDot.setImage(#imageLiteral(resourceName: "green_dot"), for: .normal)
                
            }
        }

        self.btnSelectClub.setTitle(clubs[0], for: .normal)
        
        btnSelectClub.setCorner(color: UIColor.glfWarmGrey.cgColor)
        btnSelectClub.titleLabel?.textColor = UIColor.glfWarmGrey
        self.view.isUserInteractionEnabled = false
//        getClubDataFromFirebase()

        self.getBotPlayersDataFromFirebase()

    }
    @objc func sendNotificationOnCourse(_ notification:NSNotification){
        self.locationManager.startUpdatingLocation()
        var distance  = GMSGeometryDistance(self.positionsOfDotLine.last!,self.userLocationForClub!)
        var suffix = "meter"
        if(distanceFilter != 1){
            distance = distance*YARD
            suffix = "yard"
        }
        debugPrint("isTracking\(self.isTracking)")
        Notification.sendGameDetailsNotification(msg: "Hole \(self.index+1) • Par \(self.scoring[self.index].par) • \((self.matchDataDictionary.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking,isHole: self.holeOutFlag)
        debugPrint("distance",distance)
    }
    @objc func stopTrackingFromNotification(_ notification:NSNotification){
        self.btnActionShotsCount(UIButton())
        self.sendNotificationOnCourse(notification)
    }
    @objc func changeHoleFromNotification(_ notification:NSNotification){
        if let nextOrPrev = notification.object as? String{
            if(nextOrPrev == "next"){
                self.nextAction(self.btnNextHole)
            }else{
                self.previousAction(self.btnLeftFooter)
            }
        }
    }
    @objc func doAfterResponse(_ notification:NSNotification){
        if (notification.object as? Bool) != nil{
            getScoreFromMatchDataFirebase(keyId:self.currentMatchId , hole: self.index, playerId: Auth.auth().currentUser!.uid,playerIndex: 0)
            
                for markers in markersForCurved{
                    isDraggingMarker = true
                    updateStateWhileDragging(marker:markers)
                }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                self.updateMap(indexToUpdate: self.index)
            })
        }

    }
    // MARK: - shareClicked
    @IBAction func shareClicked(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ShareMapScoreVC") as! ShareMapScoreVC
        viewCtrl.shareMapView = self.mapView
        viewCtrl.isVertical = false
        debugPrint("shotsCount: \(self.shotParentStackView.arrangedSubviews.count)")
        
        let tempView = UIView(frame:self.mapView.frame)
        let imgView = UIImageView(image: self.shotParentStackView.screenshot())
        let youSc = UIImageView(image: self.youScoredSuperStackView.screenshot())
        let title = UIImageView(image: self.lblTitleHolePar.screenshot())
        
        let lbl = UILabel(frame:CGRect(x: 0, y: 0, width: tempView.frame.width, height: 30))
        lbl.text = (self.matchDataDictionary.value(forKey: "courseName") as! String)
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
    func plotMarker(position:CLLocationCoordinate2D, userData:Int){
        let marker = GMSMarker(position: position)
        marker.title = "Point"
        marker.userData = userData
        marker.icon = #imageLiteral(resourceName: "target")
//        if(isUserInsideBound) && userData == 0{
//            let btn = UIButton()
//            btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//            btn.setCircle(frame: btn.frame)
//            btn.isUserInteractionEnabled = false
//            if let img = (Auth.auth().currentUser?.photoURL){
//                btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
//            }
//            else{
//                btn.backgroundColor = UIColor.glfWhite
//                let name = Auth.auth().currentUser?.displayName
//                btn.setTitle("\(name?.first ?? " ")", for: .normal)
//                btn.setTitleColor(UIColor.glfBlack, for: .normal)
//            }
//            marker.iconView = btn
//        }
        marker.map = mapView
        if(marker.userData as! Int == 44) || (isBotTurn){
            marker.isDraggable = false
        }
        else{
            marker.isDraggable = true
        }
        
        marker.groundAnchor = CGPoint(x:0.5,y:0.5)
        let dist = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!) * YARD
        if(dist < 100 && userData == 1){
            marker.isDraggable = false
            marker.map = nil
        }
        markers.append(marker)
    }
    
    func plotLine(positions:[CLLocationCoordinate2D]){
        if(positions.count > 0){
            let path = GMSMutablePath()
            let distance = GMSGeometryDistance(positions.first!, positions.last!) * YARD
            for i in 0..<positions.count{
                path.add(positions[i])
            }
            markers[1].map = self.mapView
            if(distance < 100){
                if(positions.count == 3){
                    path.removeCoordinate(at: 1)
                    markers[1].map = nil
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
            //        if(isDraggingMarker){
            self.plotSuggestedMarkers(position: positions)
            //        }
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
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn.setCircle(frame: btn.frame)
        btn.isUserInteractionEnabled = false
        if let img = (Auth.auth().currentUser?.photoURL){
            btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
        }
        else{
            btn.backgroundColor = UIColor.glfWhite
            let name = Auth.auth().currentUser?.displayName
            btn.setTitle("\(name?.first ?? " ")", for: .normal)
            btn.setTitleColor(UIColor.glfBlack, for: .normal)
            
        }
        
        userMarker.position = positions.first!
        userMarker.title = "user"
        userMarker.userData = "-1"
        userMarker.iconView = btn
        userMarker.map = mapView
    }
    func plotSolidLine(positions:[CLLocationCoordinate2D]){
        isSolidLinePloted = true
        let path = GMSMutablePath()
        for position in positions{
            path.add(position)
        }
        solidLine.map = nil
        solidLine = GMSPolyline(path: path)
        solidLine.strokeWidth = 2.0
        solidLine.strokeColor = UIColor.glfWhite
        solidLine.geodesic = true
        solidLine.map = mapView
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn.setCircle(frame: btn.frame)
        btn.isUserInteractionEnabled = false
        if let img = (Auth.auth().currentUser?.photoURL){
            btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
        }
        else{
            btn.backgroundColor = UIColor.glfWhite
            let name = Auth.auth().currentUser?.displayName
            btn.setTitle("\(name?.first ?? " ")", for: .normal)
            btn.setTitleColor(UIColor.glfBlack, for: .normal)
            
        }
        
        userMarker.position = positions.first!
        userMarker.title = "user"
        userMarker.userData = "-1"
        userMarker.iconView = btn
        userMarker.map = mapView
        
    }
    
    func plotCurvedPolylineShowCase(latLng1:CLLocationCoordinate2D,latLng2:CLLocationCoordinate2D,ind:Int){
        let height = 0.30
        let path = GMSMutablePath()
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
        let labelPosition = CLLocationCoordinate2D()
        
        let step = (headingBwLastToCenterPoint-headingBwFirstToCenterPoint)/100
        var curvedLatLng:CLLocationCoordinate2D!
        var btn: UIButton!
        
        for i in 0..<101{
            curvedLatLng = GMSGeometryOffset(newLatLng, r, headingBwFirstToCenterPoint+(Double(i)*step))
            path.add(curvedLatLng)
            if(i==50){
                btn = UIButton(frame:CGRect(x: 0, y: 0, width: 70, height: 25))
                btn.setCorner(color: UIColor.clear.cgColor)
                let layer = CAGradientLayer()
                layer.frame.size = btn.frame.size
                layer.startPoint = .zero
                layer.endPoint = CGPoint(x: 1, y: 0)
                layer.colors = [UIColor.glfBluegreen.cgColor, UIColor.glfBluegreen.cgColor, UIColor.glfWhite.cgColor, UIColor.glfWhite.cgColor]
                layer.locations = [0.0 ,0.25, 0.25, 1.0]
                layer.cornerRadius = 5
                btn.layer.insertSublayer(layer, at: 0)
                btn.titleEdgeInsets.left = 5
                btn.titleLabel?.textColor = UIColor.glfBlack
                let dict: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Regular", size: 14)!,
                    NSAttributedStringKey.foregroundColor : UIColor.white
                ]
                
                let dict2:[NSAttributedStringKey:Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 14)!,
                    ]
                
                let attributedText = NSMutableAttributedString()
                
                var distanceInYrd = distance * YARD
                var suffix = "yd"
                if(distanceInYrd<30){
                    distanceInYrd = 3 * distanceInYrd
                    suffix = "ft"
                }
                if(distanceFilter == 1){
                    distanceInYrd = distance
                    suffix = "m"
                }
                distanceInYrd = distanceInYrd.rounded()
                attributedText.append(NSAttributedString(string: " \(shotCount!) ", attributes: dict))
                attributedText.append(NSAttributedString(string: " \(distanceInYrd) \(suffix) ", attributes: dict2))
                btn.setAttributedTitle(attributedText, for: .normal)
                btn.contentHorizontalAlignment = .left
            }
        }
        
        if(ind == 1){
            let marker = GMSMarker(position:latLng2)
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            btn.setCircle(frame: btn.frame)
            btn.isUserInteractionEnabled = false
            btn.setBackgroundImage(#imageLiteral(resourceName: "dJohnson"), for: .normal)
            marker.iconView = btn
            marker.map = self.mapView
            
        }
        
        shotMarkerForShowCase.map = nil
        shotMarkerForShowCase = GMSMarker(position:labelPosition)
        shotMarkerForShowCase.iconView = btn
        shotMarkerForShowCase.map = self.mapView
        let curvedLine = GMSPolyline(path:path)
        curvedLine.strokeColor = UIColor.yellow
        curvedLine.strokeWidth = 2.0
        curvedLine.geodesic = true
        curvedLine.map = mapView
        
    }
    func getNewCurvedCoordinates(latLng1:CLLocationCoordinate2D,latLng2:CLLocationCoordinate2D)->[CLLocationCoordinate2D]{
        let distance = GMSGeometryDistance(latLng1, latLng2)
        let heading = GMSGeometryHeading(latLng1, latLng2)
        let centerPoint = GMSGeometryOffset(latLng1, distance/2, heading)
        var newLatLng = CLLocationCoordinate2D()
        let height = 0.10
        let  x = (1-height*height)*distance*0.5/(2*height);
        let  r = (1+height*height)*distance*0.5/(2*height);
        if(heading > 180){
            newLatLng = GMSGeometryOffset(centerPoint, x, heading+90)
        }
        else{
            newLatLng = GMSGeometryOffset(centerPoint, x, heading-90)
        }
        let headingBwFirstToCenterPoint = GMSGeometryHeading(newLatLng, latLng1)
        let headingBwLastToCenterPoint = GMSGeometryHeading(newLatLng, latLng2)
        let step = (headingBwLastToCenterPoint-headingBwFirstToCenterPoint)/20
        var curvedLatLngArr = [CLLocationCoordinate2D]()
        for i in 0..<21{
            curvedLatLngArr.append(GMSGeometryOffset(newLatLng, r, headingBwFirstToCenterPoint+(Double(i)*step)))
        }
        return curvedLatLngArr
    }
    func plotCurvedPolyline(latLng1:CLLocationCoordinate2D,latLng2:CLLocationCoordinate2D,whichLine:Bool,club:String){
        var isInside = false
        let height = 0.30
        let pathGreen = GMSMutablePath()
        for coord in self.numberOfHoles[self.index].green{
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
        //        var label = UILabel()
        let btn = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 25))
        
        //
        var labelPosition = CLLocationCoordinate2D()
        
        for i in 0..<101{
            curvedLatLng = GMSGeometryOffset(newLatLng, r, headingBwFirstToCenterPoint+(Double(i)*step))
            curvedLatLngArr.append(curvedLatLng)
            path.add(curvedLatLng)
            if(i==50){
                btn.setCorner(color: UIColor.clear.cgColor)
                btn.addTarget(self, action: #selector(shotMenu(_:)), for: .touchUpInside)
                btn.tag = shotCount
                let layer = CAGradientLayer()
                layer.frame.size = btn.frame.size
                layer.startPoint = .zero
                layer.endPoint = CGPoint(x: 1, y: 0)
                layer.colors = [UIColor.glfBluegreen.cgColor, UIColor.glfBluegreen.cgColor, UIColor.glfWhite.cgColor, UIColor.glfWhite.cgColor]
                layer.locations = [0.0 ,0.25, 0.25, 1.0]
                layer.cornerRadius = 5
                btn.layer.insertSublayer(layer, at: 0)
                //                btn.titleEdgeInsets.left = 3
                btn.titleLabel?.textColor = UIColor.glfBlack
//                btn.setImage(#imageLiteral(resourceName: "menu_black"), for: .normal)
//                btn.semanticContentAttribute = .forceRightToLeft
//                btn.imageView?.layer.zPosition = 1
                let dict: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Regular", size: 14)!,
                    NSAttributedStringKey.foregroundColor : UIColor.white]
                
                let dict2:[NSAttributedStringKey:Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 14)!,
                    ]
                let dict1: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 14)!,
                    ]
                let attributedText = NSMutableAttributedString()
                
                var distanceInYrd = distance * YARD
                var suffix = "yd"
                let isLatLng1InsideGreen = BackgroundMapStats.findPositionOfPointInside(position: latLng1, whichFeature: self.numberOfHoles[index].green)
                let isLatLng2InsideGreen = BackgroundMapStats.findPositionOfPointInside(position: latLng2, whichFeature: self.numberOfHoles[index].green)
                if(isLatLng1InsideGreen) && (isLatLng2InsideGreen){
                    distanceInYrd = 3 * distanceInYrd
                    suffix = "ft"
                }
                if(distanceFilter == 1){
                    distanceInYrd = distance
                    suffix = "m"
                }
                distanceInYrd = distanceInYrd.rounded()
                if(isUpdating){
                    var ind = draggingMarker.userData as! Int
                    if(whichLine){
                        if(draggingMarker.title == "PointWithCurved"){
                            attributedText.append(NSAttributedString(string: "  \(shotCount!)  ", attributes: dict))
                            attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                            attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                        }
                        else{
                            attributedText.append(NSAttributedString(string: "  \(ind + 1)  ", attributes: dict))
                            attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                            attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                        }
                        
                    }else{
                        if(ind == 0 && draggingMarker.title != "PointWithCurved"){
                            ind = ind + 1
                        }
                        else if(ind == 0 && draggingMarker.title == "PointWithCurved"){
                            ind = shotCount
                        }
                        attributedText.append(NSAttributedString(string: "  \(ind)  ", attributes: dict))
                        attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                        attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                    }
                }
                else{
                    attributedText.append(NSAttributedString(string: "  \(shotCount!+1)  ", attributes: dict))
                    attributedText.append(NSAttributedString(string: " \(club) ", attributes: dict1))
                    attributedText.append(NSAttributedString(string: " \(Int(distanceInYrd)) \(suffix) ", attributes: dict2))
                }
                btn.setAttributedTitle(attributedText, for: .normal)
                btn.titleLabel?.textAlignment = .left
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
            markerInfo2.iconView = btn
            if(isInside){
                markerInfo2.userData = 0
                path = GMSMutablePath()
                path.add(latLng1)
                path.add(latLng2)
            }else{
                markerInfo2.userData = 1
            }
            curvedLine2.map = nil
            curvedLine2 = GMSPolyline(path:path)
            curvedLine2.strokeColor = .white
            curvedLine2.strokeWidth = 2.0
            curvedLine2.geodesic = true
        }
        else{
            markerInfo.map = nil
            markerInfo = GMSMarker(position: labelPosition)
            markerInfo.groundAnchor = CGPoint(x:0.02,y:0.5)
            markerInfo.infoWindowAnchor = CGPoint(x:0,y:1)
            markerInfo.iconView = btn
            if(isInside){
                markerInfo.userData = 0
                path = GMSMutablePath()
                path.add(latLng1)
                path.add(latLng2)
            }else{
                markerInfo.userData = 1
            }
            curvedLines.map = nil
            curvedLines = GMSPolyline(path:path)
            curvedLines.strokeColor = .white
            curvedLines.strokeWidth = 2.0
            curvedLines.geodesic = true
        }
    }
    @objc func shotMenu(_ sender:UIButton){
//        self.view.addSubview(viewForEditShots)
        if(selectedUserId != "jpSgWiruZuOnWybYce55YDYGXP62"){
            print(sender.tag)
            let inde = stackViewForGreenShots.arrangedSubviews.index(of: sender)
            if(inde != nil){
                self.viewForEditShots.frame.origin = CGPoint(x:sender.frame.maxX+10,y:sender.frame.maxY+55)
                if !(self.viewForEditShots.isHidden){
                    self.viewForEditShots.isHidden = true
                }else{
                    self.viewForEditShots.isHidden = false
                }
            }
            for data in shotViseCurve{
                tappedMarker = nil
                if data.shot == sender.tag{
                    tappedMarker = data.markerPosition
                    break
                }
            }
            self.stackViewForGreenShots.layoutIfNeeded()
        }

    }

    func isPositionAvailable(latLng:CLLocationCoordinate2D, latLngArray:[CLLocationCoordinate2D]) ->Int{
        var availableAtIndex = -1
        for i in 0..<latLngArray.count{
            if(latLng.latitude == latLngArray[i].latitude && latLng.longitude == latLngArray[i].longitude ){
                availableAtIndex = i
                break
            }
        }
        return availableAtIndex
    }
    func updateLine(mapView:GMSMapView, marker:GMSMarker){
        
        isUpdating = true
        draggingMarker = marker
        let ind = marker.userData as! Int
        var indexForDot = -1
        var indexForCur = -1
        if(isPositionAvailable(latLng: marker.position, latLngArray: positionsOfDotLine) != -1){
            indexForDot = isPositionAvailable(latLng: marker.position, latLngArray: positionsOfDotLine)
        }
        if isPositionAvailable(latLng: marker.position, latLngArray: positionsOfCurveLines) != -1 {
            indexForCur = isPositionAvailable(latLng: marker.position, latLngArray: positionsOfCurveLines)
        }
        if(indexForCur != -1 && indexForDot != -1 ){
            marker.title = "PointWithCurved"
        }
        for i in 0..<shotViseCurve.count{
            removeLinesAndMarkers(index: i)
        }
        let shotsDetail = getShotDataOrdered(indexToUpdate: self.index)
        //        print("ShotDetails  :\(shotsDetail)")
        
        if(positionsOfDotLine.count > 0 && marker.title == "Point" ){
            positionsOfDotLine.remove(at: marker.userData as! Int)
            positionsOfDotLine.insert(marker.position, at: marker.userData as! Int)
            plotLine(positions: positionsOfDotLine)
        }else if(positionsOfCurveLines.count > 0 && marker.title == "Curved"){
            
            if(shotCount > 1 && marker.userData as! Int > 0){
                if(positionsOfDotLine.count == 0 && shotCount == ind){
                    plotCurvedPolyline(latLng1: positionsOfCurveLines[ind-1], latLng2: positionsOfCurveLines[ind],whichLine: false, club: shotsDetail[ind-1].club)
                    shotViseCurve[ind-1] = (shot: ind-1, line: curvedLines , markerPosition:markerInfo)
                }
                else{
                    plotCurvedPolyline(latLng1: positionsOfCurveLines[ind-1], latLng2: marker.position,whichLine: false, club: shotsDetail[ind-1].club)
                    plotCurvedPolyline(latLng1: marker.position, latLng2: positionsOfCurveLines[ind+1],whichLine: true, club: shotsDetail[ind].club)
                    shotViseCurve[ marker.userData as! Int] = (shot:  marker.userData as! Int, line: curvedLine2 , markerPosition:markerInfo2)
                    shotViseCurve[ marker.userData as! Int-1] = (shot:  marker.userData as! Int - 1, line: curvedLines , markerPosition:markerInfo)
                }
            }
            else{
                plotLine(positions: positionsOfDotLine)
                plotCurvedPolyline(latLng1: positionsOfCurveLines[0], latLng2: positionsOfCurveLines[1],whichLine: false,club:shotsDetail[0].club)
                shotViseCurve[0] = (shot: 0, line: curvedLines , markerPosition:markerInfo)
            }
            positionsOfCurveLines.remove(at: ind)
            positionsOfCurveLines.insert(marker.position, at: ind)
        }
        else if(marker.title == "PointWithCurved"){
            positionsOfDotLine.remove(at: 0)
            positionsOfDotLine.insert(marker.position, at: 0)
            
            debugPrint("Moving Line Together : \(marker.userData as! Int)")
            updateMid()
            plotLine(positions: positionsOfDotLine)
            //-------------------//
            debugPrint("Moving Curved Together")
            debugPrint(positionsOfCurveLines.count)
            plotCurvedPolyline(latLng1: positionsOfCurveLines[shotCount-1], latLng2: marker.position,whichLine: true,club:(shotsDetail.last?.club)!)
            shotViseCurve[shotCount-1] = (shot:  shotCount-1, line: curvedLine2 , markerPosition:markerInfo2)
            positionsOfCurveLines.remove(at: shotCount)
            positionsOfCurveLines.insert(marker.position, at: shotCount)
        }
        for subview in stackViewForGreenShots.subviews {
            subview.removeFromSuperview()
        }
        for i in 0..<shotViseCurve.count{
            if(!penaltyShots[i]){
                showLinesAndMarker(index: i)
            }else{
                shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
            }
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
    func removeLinesAndMarkers(index:Int){
        if(index < shotViseCurve.count){
            shotViseCurve[index].markerPosition.map = nil
            shotViseCurve[index].line.map = nil
        }
    }
    func showLinesAndMarker(index:Int){
        if(index < shotViseCurve.count){
            if(shotViseCurve[index].markerPosition.userData as! Int) != 0{
                shotViseCurve[index].markerPosition.map = mapView
            }
            else{
                stackViewForGreenShots.addArrangedSubview(shotViseCurve[index].markerPosition.iconView!)
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
    func mapView (_ mapView:GMSMapView, didBeginDragging didBeginDraggingMarker:GMSMarker){
        isDraggingMarker = true
        
    }
    
    func mapView (_ mapView: GMSMapView, didDrag didDragMarker:GMSMarker){
        
        updateLine(mapView: mapView, marker: didDragMarker)
        isDraggingMarker = true
        
    }
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker){
        if(didEndDraggingMarker.title == "Curved" || didEndDraggingMarker.title == "PointWithCurved"){
            isDraggingMarker = true
            updateStateWhileDragging(marker:didEndDraggingMarker)
        }
    }
    func mapView(_ mapView: GMSMapView,  marker:GMSMarker)->Bool{
        marker.map = nil
        return true
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    @IBAction func btnActionChangeEndingLocation(_ sender: UIButton) {
        ActionSheetStringPicker.show(withTitle: "Landed On", rows: ["Fairway","Green","Bunker","Rough","WaterHazard"], initialSelection: sender.tag, doneBlock: { (picker, value, index) in
            sender.setTitle("\(index!)", for: .normal)
            // update on firebase
            // calculate strokesgained againe
            //more work to do
            
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin:sender)
    }
    // Mark :- Add Shot
    @objc func addShot(_ sender:UIButton){
        if(tappedMarker != nil){
            if !(self.newView.isHidden){
                self.btnStatsAction(self.btnStatsView)
            }
            let playerShotsData = NSMutableDictionary()
            var j = 0
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            let indexOfMarker = j
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.penaltyShots = [Bool]()
            var playerDict = NSMutableDictionary()
            var scoreArray = [NSMutableDictionary]()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    for i in 0..<self.scoring[index].players.count{
                        if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                            self.playerIndex = i
                            playerDict = self.scoring[index].players[i].value(forKey: self.selectedUserId) as! NSMutableDictionary
                            scoreArray = playerDict.value(forKey: "shots") as! [NSMutableDictionary]
                            break
                        }
                    }
                }
            }
            for m in markersForCurved{
                m.map = nil
            }
            markersForCurved.removeAll()
            let coordStart = positionsOfCurveLines[indexOfMarker]
            let coordEnd = positionsOfCurveLines[indexOfMarker+1]
            let distance = GMSGeometryDistance(coordStart, coordEnd)
            let heading = GMSGeometryHeading(coordStart, coordEnd)
            let shotsDict = self.scoring[index].players[self.playerIndex].value(forKey: self.selectedUserId) as! NSMutableDictionary
            var shotsValue = shotsDict.value(forKey: "shots") as! [NSMutableDictionary]
            let clubValue = shotsValue[indexOfMarker].value(forKey: "club") as! String
            
            let nextMarkerCoord = GMSGeometryOffset(coordStart, distance*0.70, heading)
            positionsOfCurveLines.insert(nextMarkerCoord, at: indexOfMarker+1)
            plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker], latLng2: positionsOfCurveLines[indexOfMarker+1],whichLine: false, club: clubValue)
            shotViseCurve[indexOfMarker] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo)
            plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker+1], latLng2: positionsOfCurveLines[indexOfMarker+2], whichLine: false, club: clubValue)
            shotViseCurve.insert((shot:  indexOfMarker+1, line: curvedLines , markerPosition:markerInfo), at: indexOfMarker+1)
            
            var dict = getShotDetails(shot:indexOfMarker+1,club:clubValue,isPenalty: false)
            scoreArray.insert(dict, at: indexOfMarker)
            dict = getShotDetails(shot:indexOfMarker+2,club:clubValue,isPenalty: false)
            scoreArray.insert(dict, at: indexOfMarker+1)
            scoreArray.remove(at: indexOfMarker+2)
            playerDict.setValue(scoreArray, forKey: "shots")
            playerShotsData.setObject(playerDict, forKey: self.selectedUserId as NSCopying)
            
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/").updateChildValues(playerShotsData as! [AnyHashable : Any])
            shotCount = shotCount+1
            
            for i in 0..<self.scoring[index].players.count{
                if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                    self.scoring[index].players[i] = playerShotsData
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
            for i in 0..<shotViseCurve.count{
                if !self.penaltyShots[i]{
                    showLinesAndMarker(index: i)
                }else{
                    shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                }
                
            }
//            self.getScoreFromMatchDataFirebaseWholeData(keyId: self.currentMatchId)
            
            self.progressView.show(atView: self.view, navItem: self.navigationItem)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 , execute: {
                self.updateMap(indexToUpdate: self.index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                    self.progressView.hide(navItem: self.navigationItem)
                    self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                })
            })
        }
    }
    // Mark :- Delete Shot
    @objc func deleteShot(_ sender:UIButton){
        if(tappedMarker != nil){
            if !(self.newView.isHidden){
                self.btnStatsAction(self.btnStatsView)
            }
            let playerShotsData = NSMutableDictionary()
            var j = 0
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            var indexOfMarker = j
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.penaltyShots = [Bool]()
            var playerDict = NSMutableDictionary()
            var scoreArray = [NSMutableDictionary]()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    for i in 0..<self.scoring[index].players.count{
                        if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                            self.playerIndex = i
                            playerDict = self.scoring[index].players[i].value(forKey: self.selectedUserId) as! NSMutableDictionary
                            scoreArray = playerDict.value(forKey: "shots") as! [NSMutableDictionary]
                            break
                        }
                    }
                }
            }
            for m in markersForCurved{
                m.map = nil
            }
            markersForCurved.removeAll()
            let shotsDict = self.scoring[index].players[playerIndex].value(forKey: self.selectedUserId) as! NSMutableDictionary
            var shotsValue = shotsDict.value(forKey: "shots") as! [NSMutableDictionary]
            if(indexOfMarker+1 == positionsOfCurveLines.count){
                indexOfMarker -= 1
            }
            let tempLocation = positionsOfCurveLines[indexOfMarker+1]
            positionsOfCurveLines.remove(at: indexOfMarker+1)
            var clubValue = shotsValue[indexOfMarker].value(forKey: "club") as! String
            shotCount = shotCount-1
            for i in 0..<scoreArray.count{
                for (key,value) in scoreArray[i]{
                    if(key as! String == "penalty"){
                        self.penaltyShots.append(value as! Bool)
                    }
                }
            }
            if(shotCount!+1 == indexOfMarker+1){
                if(positionsOfDotLine.count == 0){
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
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker-1], latLng2: positionsOfCurveLines[nextIndex-1],whichLine: false,club:clubValue)
                shotViseCurve[indexOfMarker-1] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo)
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
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker], latLng2: positionsOfCurveLines[nextIndex],whichLine: false,club:clubValue)
                shotViseCurve[indexOfMarker] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo)
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
            self.scoring[self.index].players[playerIndex] = playerShotsData
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/").updateChildValues(playerShotsData as! [AnyHashable : Any])
            
            for i in 0..<self.scoring[index].players.count{
                if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                    self.scoring[index].players[i] = playerShotsData
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
            for i in 0..<shotViseCurve.count{
                if !self.penaltyShots[i]{
                    showLinesAndMarker(index: i)
                }else{
                    shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                }
            }
            
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 , execute: {
                self.updateMap(indexToUpdate: self.index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                    self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                    self.progressView.hide(navItem: self.navigationItem)

                })
            })
        }
    }
    // Mark :- PenaltyShot
    @objc func penaltyShot(_ sender:UIButton){
        if(tappedMarker != nil){
            if !(self.newView.isHidden){
                self.btnStatsAction(self.btnStatsView)
            }
            let playerShotsData = NSMutableDictionary()
            var j = 0
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            let indexOfMarker = j
            for i in 0..<shotViseCurve.count{
                removeLinesAndMarkers(index: i)
            }
            self.penaltyShots = [Bool]()
            var playerDict = NSMutableDictionary()
            var scoreArray = [NSMutableDictionary]()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    for i in 0..<self.scoring[index].players.count{
                        if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                            self.playerIndex = i
                            playerDict = self.scoring[index].players[i].value(forKey: self.selectedUserId) as! NSMutableDictionary
                            scoreArray = playerDict.value(forKey: "shots") as! [NSMutableDictionary]
                        }
                    }
                }
            }
            for m in markersForCurved{
                m.map = nil
            }
            var tryPenalty = true
            if(holeOutFlag){
                if (shotCount! == indexOfMarker+1){
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
                let shotsDict = self.scoring[index].players[playerIndex].value(forKey: self.selectedUserId) as! NSMutableDictionary
                var shotsValue = shotsDict.value(forKey: "shots") as! [NSMutableDictionary]

                
                let clubValue = shotsValue[indexOfMarker].value(forKey: "club") as! String
                numberOfPenalty = (numberOfPenalty == 0) ? 1 : numberOfPenalty
                let nextMarkerCoord = GMSGeometryOffset(coordEnd, 10*Double(numberOfPenalty), heading+90)
                if(positionsOfCurveLines.count-1 == indexOfMarker+1){
                    self.positionsOfCurveLines.append(nextMarkerCoord)
                }else{
                    positionsOfCurveLines.insert(nextMarkerCoord, at: indexOfMarker+2)
                }
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker], latLng2: positionsOfCurveLines[indexOfMarker+1],whichLine: false, club: clubValue)
                shotViseCurve[indexOfMarker] = (shot:indexOfMarker, line: curvedLines , markerPosition:markerInfo)
                plotCurvedPolyline(latLng1: positionsOfCurveLines[indexOfMarker+1], latLng2: positionsOfCurveLines[indexOfMarker+2], whichLine: false, club: clubValue)
                shotViseCurve.insert((shot:  indexOfMarker+1, line: curvedLines , markerPosition:markerInfo), at: indexOfMarker+1)
                
                var dict = getShotDetails(shot:indexOfMarker+1,club:clubValue,isPenalty: false)
                scoreArray.insert(dict, at: indexOfMarker)
                dict = getShotDetails(shot:indexOfMarker+2,club:clubValue,isPenalty: true)
                scoreArray.insert(dict, at: indexOfMarker+1)
                scoreArray.remove(at: indexOfMarker+2)
                playerDict.setValue(scoreArray, forKey: "shots")
                playerShotsData.setObject(playerDict, forKey: self.selectedUserId as NSCopying)
                
                ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/").updateChildValues(playerShotsData as! [AnyHashable : Any])
                shotCount = shotCount+1
                for i in 0..<self.scoring[index].players.count{
                    if(self.scoring[index].players[i].value(forKey: self.selectedUserId) != nil){
                        self.scoring[index].players[i] = playerShotsData
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
            for i in 0..<shotViseCurve.count{
                if !self.penaltyShots[i]{
                    showLinesAndMarker(index: i)
                }else{
                    shotViseCurve[i-1].line.strokeColor = UIColor.glfRosyPink
                }
                
            }
//            self.getScoreFromMatchDataFirebaseWholeData(keyId: self.currentMatchId)
            
            self.progressView.show(atView: self.view, navItem: self.navigationItem)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 , execute: {
                self.updateMap(indexToUpdate: self.index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                    self.progressView.hide(navItem: self.navigationItem)
                    self.plotSuggestedMarkers(position: self.positionsOfDotLine)
                })
            })
        }
    }
    
    // Mark :- EditShot
    @objc func editShot(_ sender:UIButton){
        // change Club and change bunker also
        
        if !(self.newMenuView.isHidden){
            self.newMenuView.isHidden = true
        }
        if !(self.newView.isHidden){
            self.btnStatsAction(self.btnStatsView)
        }
        if(tappedMarker != nil){
            var playerId = String()
            var j = 0
            
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            let indexOfMarker = j
            
            let btn = UIButton()
            btn.tag = j
            btn.addTarget(self, action: #selector(self.shotCheck(_:)), for: .touchUpInside)
            self.shotCheck(btn)
            
            shotDetailsStackView.isHidden = true
            trackShotStackView.isHidden = true
            holeOutStackView.isHidden = true
            stackViewForEditShots.isHidden = false
            btnConfirmClubAndLandedOn.tag = indexOfMarker
            var landingLocation = String()
            var scoreArray = [NSMutableDictionary]()
            var playerDict = NSMutableDictionary()
            for playerDetails in playersButton{
                if(playerDetails.isSelected){
                    playerId = playerDetails.id
                    for i in 0..<self.scoring[index].players.count{
                        if(self.scoring[index].players[i].value(forKey: playerId) != nil){
                            playerDict = self.scoring[index].players[i].value(forKey: playerId) as! NSMutableDictionary
                            scoreArray = playerDict.value(forKey: "shots") as! [NSMutableDictionary]
                        }
                    }
                }
            }
            
            if let endingLocation = scoreArray[indexOfMarker].value(forKey: "end") as? String{
                switch endingLocation {
                case "F":
                    landingLocation = "Fairway"
                    break
                case "G":
                    landingLocation = "Green"
                    break
                case "GB":
                    landingLocation = "Green Bunker"
                    break
                case "FB":
                    landingLocation = "Fairway Bunker"
                    break
                case "T":
                    landingLocation = "Tee"
                    break
                case "R":
                    landingLocation = "Rough"
                    break
                default:
                    landingLocation = "Water Hazard"
                }
            }
            if let club = scoreArray[indexOfMarker].value(forKey: "club") as? String{
                btnEditClub.setTitle(club, for: .normal)
            }
            btnChangeEndingLocation.setTitle(landingLocation, for: .normal)
        }
    }
    
    // Mark :- ShareShot
    @objc func shareShot(_ sender:UIButton){
        if(tappedMarker != nil){
            let shotDetails = self.getShotDataOrdered(indexToUpdate: self.index)
            var j = 0
            for data in shotViseCurve{
                if(data.markerPosition.position == tappedMarker!.position){
                    break
                }
                j += 1
            }
            print(j)
            self.letsRotateWithZoom(latLng1: positionsOfCurveLines[j], latLng2: positionsOfCurveLines[j+1],isScreenShot: true)
            var head = GMSGeometryHeading(positionsOfCurveLines[j], positionsOfCurveLines[j+1])
            if(head < 0) {
                head = head + 360;
            }
            debugPrint("Heading : \(head)")
            self.tappedMarker.rotation = head - 90

            self.newMenuView.isHidden = true
            self.viewForEditShots.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                debugPrint("After Rotation : \(head)")
                let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ShareMapScoreVC") as! ShareMapScoreVC
                viewCtrl.shareMapView = self.mapView
                viewCtrl.isVertical = true
                debugPrint("shotsCount: \(self.shotParentStackView.arrangedSubviews.count)")
                
                let frame = self.mapView.frame
                let tempView = UIView(frame:CGRect(x: 0, y: 0, width: frame.height, height: frame.width))

                let lbl = UILabel(frame:CGRect(x: 0, y: 16, width: tempView.frame.width, height: 30))
                lbl.text = (self.matchDataDictionary.value(forKey: "courseName") as! String)
                lbl.textAlignment = .center
                lbl.textColor = UIColor.glfWarmGrey
                lbl.font = UIFont(name:"SFProDisplay-Bold", size: 18)!
                tempView.addSubview(lbl)
                
                let lbl1 = UILabel(frame:CGRect(x: 0, y: lbl.frame.maxY, width: tempView.frame.width, height: 30))
                lbl1.text = "Hole \(self.index+1) - par \(self.scoring[self.index].par)"
                lbl1.textAlignment = .center
                lbl1.textColor = UIColor.glfGreen
                lbl1.font = UIFont(name:"SFProDisplay-Regular", size: 22)!
                tempView.addSubview(lbl1)
                
                
                let lbl2 = UILabel(frame:CGRect(x: 0, y: lbl1.frame.maxY+16, width: tempView.frame.width, height: 30))
                lbl2.textAlignment = .center
                lbl2.textColor = UIColor.glfBlack
                lbl2.font = UIFont(name:"SFProDisplay-Regular", size: 18)!

                var distanceInYrd = shotDetails[j].distance
                var suffix = "yd"
                if(distanceFilter == 1){
                    distanceInYrd = shotDetails[j].distance/YARD
                    suffix = "m"
                }
                if(shotDetails[j].swingScore == "G" && shotDetails[j].endingPoint == "G"){
                    distanceInYrd = 3 * distanceInYrd
                    suffix = "ft"
                    if(distanceFilter == 1){
                        distanceInYrd = shotDetails[j].distance/(YARD)
                        suffix = "m"
                    }
                }
                lbl2.text = "\(Int(distanceInYrd.rounded())) \(suffix)"
                tempView.addSubview(lbl2)
                
                let lbl3 = UILabel(frame:CGRect(x: 0, y: lbl2.frame.maxY+16, width: tempView.frame.width, height: 30))
                lbl3.text = shotDetails[j].club
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
                let start = UIImageView(image: self.imageOfButton(endingPoint: shotDetails[j].swingScore))
                stkView.addArrangedSubview(start)
                stkView.addArrangedSubview(lblForLine)
                let end = UIImageView(image: self.imageOfButton(endingPoint: shotDetails[j].endingPoint))
                stkView.addArrangedSubview(end)
                stkView.center.x = tempView.frame.width/2
                stkView.center.y = lbl2.frame.maxY + 4
                tempView.addSubview(stkView)
                var remainingDistance = Double()
                if(self.positionsOfCurveLines.count != j+1){
                    if(!self.holeOutFlag){
                        remainingDistance = GMSGeometryDistance(self.positionsOfCurveLines[j+1], self.positionsOfDotLine.last!)
                    }else{
                        remainingDistance = GMSGeometryDistance(self.positionsOfCurveLines[j+1], self.positionsOfCurveLines.last!)
                    }
                    suffix = "yd"
                    if(distanceFilter == 1){
                        remainingDistance = shotDetails[j].distance/YARD
                        suffix = "m"
                    }
                    if(shotDetails[j].swingScore == "G" && shotDetails[j].endingPoint == "G"){
                        remainingDistance = 3 * distanceInYrd
                        suffix = "ft"
                        if(distanceFilter == 1){
                            remainingDistance = shotDetails[j].distance/(YARD)
                            suffix = "m"
                        }
                    }
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
                self.letsRotateWithZoom(latLng1: self.positionsOfCurveLines.first!, latLng2: self.positionsOfCurveLines.last!)
                self.tappedMarker.rotation = head
            })
        }
    }
    
    
    func imageOfButton(endingPoint: String)->UIImage{
        let btn = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 16)
        btn.setTitleColor(UIColor.glfWhite, for: .normal)
        btn.layer.cornerRadius = self.btnShotLandedOn.frame.height/2
        
        if endingPoint == "G"{
            btn.backgroundColor = UIColor.glfGreen
            btn.setTitle("Green", for: .normal)
        }else if endingPoint == "F" {
            btn.backgroundColor = UIColor.glfFairway
            btn.setTitle("Fairway", for: .normal)
        }else if endingPoint == "GB" || endingPoint == "FB"{
            btn.setTitle("Bunker", for: .normal)
            btn.backgroundColor = UIColor.glfBunker
        }else{
            btn.setTitle("Rough", for: .normal)
            btn.backgroundColor = UIColor.glfRough
        }
        return btn.screenshot()
    }
    
   /* func GetProMode()  {
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "codes") { (snapshot) in
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            var codes = NSMutableDictionary()
            if(snapshot.value != nil){
                codes = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
//                var i = 0
//                for (key,value) in codes{
//                    if(value  as! String) == "N" {
//                        if(i > 300){
//                            let link = URL(string: "https://p5h99.app.goo.gl/adcj?promocode=\(key)")
//                            let promotionalLink = DynamicLinkComponents(link: link!, domain: "p5h99.app.goo.gl")
//                            promotionalLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.khelfie.Khelfie")
//                            promotionalLink.iOSParameters?.minimumAppVersion = "1.0.1"
//                            promotionalLink.iOSParameters?.appStoreID = "1216612467"
//                            promotionalLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.khelfiegolf")
//                            promotionalLink.androidParameters?.minimumVersion = 1
//                            promotionalLink.shorten { (shortURL, warnings, error) in
//                                if let error = error {
//                                    print(error.localizedDescription)
//                                    return
//                                }
//                                let invitationUrl = shortURL
//                                let invitationStr = invitationUrl?.absoluteString
//                                debugPrint("\(key):\(invitationStr!)")
//                                //                            debugPrint(invitationStr!)
//                            }
//                        }
//                        i += 1
//                        if(i == 400){
//                            break
//                        }
//                    }else{
//                        debugPrint(key)
//                        debugPrint(value)
//                    }
//                }
               
                let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
                self.navigationController?.pushViewController(viewCtrl, animated: true)

            })
        }
    } */
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if(tappedMarker != nil){
            let point = mapView.projection.point(for: tappedMarker.position)
            self.viewForEditShots.center = CGPoint(x:point.x+53,y:point.y+90)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.viewForEditShots.isHidden = true
        self.newMenuView.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if(!isHoleByHole) && self.selectedUserId != "jpSgWiruZuOnWybYce55YDYGXP62"{
            tappedMarker = marker
            if (tappedMarker.iconView as? UIButton) != nil && (tappedMarker.iconView as? UIButton)?.tag != nil {
                self.viewForEditShots.isHidden = true
                let point = mapView.projection.point(for: tappedMarker.position)
                self.viewForEditShots.center = CGPoint(x: point.x+53, y: point.y+100); // set center
                self.viewForEditShots.isHidden = false
            }
            if(!self.newView.isHidden){
                self.newView.isHidden = true
            }
        }else{
            tappedMarker = nil
        }
        return false
    }
    
    func getPlayersList(){
        self.activePlayerData.removeAll()
        for (key,value) in self.matchDataDictionary{
            if(key as! String == "player"){
                for (k,v) in value as! NSMutableDictionary{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    self.activePlayerData.append(dict)
                    if(isContinueMatch){
                        if let sKeys = dict.value(forKey:"swingKey") as? String{
                            self.swingMatchId = sKeys
                        }
                    }
                }
            }
            if(key as! String == "matchType"){
                let matchType = value as! String
                self.matchType = (matchType.count == 7 ? 9 : 18 )
                
            }
            if(key as! String == "currentHole"){
                if let v = value as? String{
                    self.currentHole = v == "" ? 1 : Int(v)!
                }
            }
        }
        self.setUpPlayerButton(totalPlayers: self.activePlayerData.count)
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
                if(!self.isContinueMatch){
                    ref.child("matchData/\(self.currentMatchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["swingKey":self.swingMatchId])
                }else{
                    self.getGameId(swingKey:self.swingMatchId)
                }
            })
        }
    }
    
    func getGameId(swingKey:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/gameId") { (snapshot) in
            var gameid = 0
            if (snapshot.value != nil) {
                gameid = snapshot.value as! Int
            }
            DispatchQueue.main.async(execute: {
                if(self.isContinueMatch){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: gameid)
                }
            })
        }
    }
    func getGolfCourseDataFromFirebase(){
        if(isShowCase){
            self.courseId = "course_14513"
        }
//        self.courseId = "course_9999999"
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseGolf(addedPath: self.courseId) { (snapshot) in
            var par = [Int]()
            let group = DispatchGroup()
            let completeDataDict = (snapshot.value as? NSDictionary)!
            self.getPlayersList()
            for(key,value) in completeDataDict{
                group.enter()
                
                if((key as! String) == "bounds"){
                    let dataDic = (value as? NSArray)!
                    var count = 1
                    for data in dataDic {
                        let bound = Bounds()
                        if let data = data as? NSMutableDictionary{
                            if let minLat = data.value(forKey: "minLat") as? Double{
                                bound.minLat = minLat
                            }
                            if let minLng = data.value(forKey: "minLng") as? Double{
                                bound.minLng = minLng
                            }
                            if let maxLat = data.value(forKey: "maxLat") as? Double{
                                bound.maxLat = maxLat
                            }
                            if let maxLng = data.value(forKey: "maxLng") as? Double{
                                bound.maxLng = maxLng
                            }
                        }
                        
                        let minLatLng = CLLocationCoordinate2D(latitude: bound.minLat ?? Double(), longitude: bound.minLng  ?? Double())
                        let maxLatLng = CLLocationCoordinate2D(latitude: bound.maxLat ?? Double(), longitude: bound.maxLng  ?? Double())
                        
                        let oneBound = GMSCoordinateBounds(coordinate: minLatLng, coordinate: maxLatLng)
                        self.bounds.append(bound)
                        self.coordBound.append(oneBound)
                        self.numberOfHoles.append((count,[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]](),[CLLocationCoordinate2D](),[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]]()))
                        count += 1
                    }
                }
                else if ((key as! String) == "par"){
                    let dataDic = (value as? NSArray)!
                    for i in 0..<dataDic.count{
                        if let parS = (dataDic[i] as AnyObject).value(forKey: "par") as? String{
                            par.append(Int(parS)!)
                        }else if let parI = (dataDic[i] as AnyObject).value(forKey: "par") as? Int{
                            par.append(parI)
                        }
                    }
                }
                else if ((key as! String) == "coordinates"){
                    let coordinatesArray = (value as? NSArray)!
                    var types = [String]()
                    for data in coordinatesArray{
                        let coordinateDict = (data as? NSDictionary)!
                        for(key,value) in coordinateDict{
                            if((key as! String) == "type"){
                                types.append(value as! String)
                            }
                            else if((key as! String) == "geometry"){
                                let geometryDict = value as! NSDictionary
                                for(key,value) in geometryDict{
                                    if((key as! String)=="type" ){
                                        let _ = value as! String
                                        //                                        print(geoType)
                                    }
                                    else if((key as! String) == "coordinates"){
                                        let coordArray = value as! NSArray
                                        var polygon = [CLLocationCoordinate2D]()
                                        for data in coordArray{
                                            let latlongArray = data as! NSArray
                                            for position in latlongArray{
                                                let positionArray = position as! NSArray
                                                polygon.append(CLLocationCoordinate2D(latitude: positionArray[1] as! CLLocationDegrees,longitude: positionArray[0] as! CLLocationDegrees))
                                            }
                                        }
                                        self.polygonArray.append(polygon)
                                    }
                                }
                            }
                            else if((key as! String) == "properties"){
                                let property = Properties()
                                if let hole = (value as AnyObject).object(forKey:"hole") as? String{
                                    property.hole = Int(hole)
                                }
                                else if let hole = (value as AnyObject).object(forKey:"hole") as? Int{
                                    property.hole = hole
                                }
                                property.label = (value as AnyObject).object(forKey:"label") as? String
                                property.type = (value as AnyObject).object(forKey:"type") as? String
                                self.propertyArray.append(property)
                            }
                        }
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main){
                self.progressView.hide(navItem: self.navigationItem)
                self.view.isUserInteractionEnabled = true
                self.mapView = GMSMapView()
                self.mapView.frame = CGRect(x:0,y:64,width:self.view.frame.width, height: self.view.frame.height)
                self.mapView.moveCamera(GMSCameraUpdate.fit(self.coordBound[0], withPadding: 0))
                //                self.mapView.settings.compassButton = true
                self.mapView.delegate = self
                self.mapView.mapType = GMSMapViewType.satellite
                for j in 0..<self.numberOfHoles.count{
                    self.bounds[j].par = par[j]
                    for i in 0..<self.polygonArray.count{
                        if(self.propertyArray[i].hole == self.numberOfHoles[j].hole){
                            if(self.propertyArray[i].type == "T"){
                                self.numberOfHoles[j].tee.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "G"){
                                self.numberOfHoles[j].green = self.polygonArray[i]
                            }
                            if(self.propertyArray[i].type == "F"){
                                self.numberOfHoles[j].fairway.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "FB"){
                                self.numberOfHoles[j].fb.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "GB"){
                                self.numberOfHoles[j].gb.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "WH"){
                                self.numberOfHoles[j].wh.append(self.polygonArray[i])
                            }
                        }
                    }
                }
                for data in self.numberOfHoles{
                    var centerOfTee = [CLLocationCoordinate2D]()
                    var indexOfMaxDistanceTee = 0
                    var areaOfFairway = 0.0
                    var distanceBwGreenNHole = 0.0
                    for tee in data.tee{
                        centerOfTee.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: tee))
                    }
                    
                    for f in 0..<data.fairway.count{
                        let path = GMSMutablePath()
                        for position in data.fairway[f]{
                            path.add(position)
                        }
                        if areaOfFairway < GMSGeometryArea(path){
                            areaOfFairway = GMSGeometryArea(path)
                            self.indexForFairway = f
                        }
                    }
                    for t in 0..<centerOfTee.count{
                        if(distanceBwGreenNHole < GMSGeometryDistance(centerOfTee[t], BackgroundMapStats.middlePointOfListMarkers(listCoords: data.green))){
                            distanceBwGreenNHole = GMSGeometryDistance(centerOfTee[t], BackgroundMapStats.middlePointOfListMarkers(listCoords: data.green))
                            indexOfMaxDistanceTee = t
                        }
                    }
                    if(data.fairway.count == 0){
                        let distance = GMSGeometryDistance(centerOfTee[indexOfMaxDistanceTee], BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green))
                        let heading = GMSGeometryHeading(centerOfTee[indexOfMaxDistanceTee], BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green))
                        let fairwayPoint = GMSGeometryOffset(centerOfTee[indexOfMaxDistanceTee], distance*0.90, heading)
                        self.centerPointOfTeeNGreen.append((tee:centerOfTee[indexOfMaxDistanceTee],fairway:fairwayPoint ,green:BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green),par:par[data.hole-1]))
                    }
                    else{
                        let pathOfFairway = GMSMutablePath()
                        for fairwayCoord in data.fairway[self.indexForFairway]{
                            pathOfFairway.add(fairwayCoord)
                        }
                        let centerOfTee = centerOfTee[indexOfMaxDistanceTee]
                        let centerOfGreen = BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green)
                        let distance = GMSGeometryDistance(centerOfTee, centerOfGreen)
                        let headingAngle = GMSGeometryHeading(centerOfTee, centerOfGreen)
                        var fairWayPoint = GMSGeometryOffset(centerOfTee, distance*0.75, headingAngle)
                        var middlePointArray = [CLLocationCoordinate2D]()
                        for f in 0..<data.fairway.count{
                            middlePointArray.append(BackgroundMapStats.middlePointOfListMarkers(listCoords:data.fairway[f]))
                        }
                        self.indexForFairway = BackgroundMapStats.nearByPoint(newPoint: fairWayPoint,array: middlePointArray)
                        
                        if(GMSGeometryContainsLocation(fairWayPoint, pathOfFairway, true)){
                            fairWayPoint = GMSGeometryOffset(centerOfTee, distance*0.75, headingAngle)
                            if !(distance*0.75 < 300){
                                fairWayPoint = GMSGeometryOffset(centerOfTee, distance*0.65, headingAngle)
                            }
                        }
                        else{
                            if !(distance*0.75 < 300){
                                fairWayPoint = GMSGeometryOffset(centerOfTee, distance*0.65, headingAngle)
                            }
                            fairWayPoint = BackgroundMapStats.coordInsideFairway(newPoint: fairWayPoint, array: data.fairway[self.indexForFairway], path: pathOfFairway)
                        }
                        self.centerPointOfTeeNGreen.append((tee: centerOfTee,fairway:fairWayPoint ,green: centerOfGreen,par:par[data.hole-1]))
                    }
                }
                for i in 0..<self.numberOfHoles.count{
                    self.holeViseAllShots.append((hole: i, holeShots: self.shotViseCurve,dotLinePoints:self.positionsOfDotLine,curvedLinePoints:self.positionsOfCurveLines,shotCount:0,holeOut:false))
                }
                self.mapView.isUserInteractionEnabled = true
                self.view.addSubview(self.mapView)
                
                if(!isShowCase){
                    self.locationManager.requestAlwaysAuthorization()
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                }
                if(self.playersButton.count > 1){
                    for i in 0..<self.playersButton.count{
                        self.view.addSubview(self.playersButton[i].button)
                    }
                }
                if(self.scoring.count == 0){
                    if(!isShowCase){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command3"), object: self.centerPointOfTeeNGreen)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                            self.getActiveRound()
                        })
                    }
                    self.initilizeScoreNode()
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.getActiveRound()
                    })
                }
                self.index = (self.currentHole - 1)  % self.numberOfHoles.count
                BackgroundMapStats.getDataFromJson(lattitude: self.centerPointOfTeeNGreen[0].green.latitude , longitude: self.centerPointOfTeeNGreen[0].green.longitude,onCompletion: { response,arg  in
                    DispatchQueue.main.async(execute: {
                        let headingOfHole = GMSGeometryHeading(self.centerPointOfTeeNGreen[self.index].tee,self.centerPointOfTeeNGreen[self.index].green)
                        debugPrint(response!)
                        for data in response!{
                            debugPrint(data.key)
                            if data.key == "wind"{
                                let windSpeed = (data.value as AnyObject).value(forKey: "speed") as! Double
                                let windSpeedWithUnit = windSpeed * 2.23694
                                self.lblWindSpeed.text = " \(windSpeedWithUnit.rounded(toPlaces: 1)) mph"
                                if(distanceFilter == 1){
                                    self.lblWindSpeed.text = " \((windSpeedWithUnit*1.60934).rounded(toPlaces: 1)) km/h"
                                }
                                
                                if let degree = (data.value as AnyObject).value(forKey: "deg") as? Double{
                                    self.windHeading = degree + 90
                                }
                                
                                debugPrint("headingOfHole: \(headingOfHole)")
                                debugPrint("WindHeading: \(self.windHeading-90)")
                                let rotationAngle = headingOfHole - self.windHeading
                                debugPrint("rotationAngle: \(rotationAngle)")
                                
                                UIButton.animate(withDuration: 2.0, animations: {
                                    self.imgWindDir.transform = CGAffineTransform(rotationAngle: (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
                                })
                                break
                            }
                        }
                        } as @convention(block) () -> Void)
                })
                if(!self.isHoleByHole){
                    self.mapView.settings.consumesGesturesInView = true
                    for gestureRecognizer in self.mapView.gestureRecognizers! {
                        if #available(iOS 11.0, *) {
                            debugPrint(gestureRecognizer.name as Any)
                        } else {
                            // Fallback on earlier versions
                        }

                        if !gestureRecognizer.isKind(of: UITapGestureRecognizer.self){
                            gestureRecognizer.addTarget(self, action: #selector(MapViewController.handleTap(_:)))
                        }
                    }
                }
                self.lastHole = self.coordBound.count
                self.btnOnOffCourse.layer.cornerRadius = 3
                self.newView.backgroundColor = UIColor.glfWhite
                self.newView.isHidden = true
                self.btnOnOffCourse.isUserInteractionEnabled = false
//                self.btnOnOffCourse.addTarget(self, action: #selector(self.onCourseViewTapped),for: .touchUpInside)
                if(self.isHoleByHole){
                    self.index = 0
                    self.btnEndRoundInBetween.isUserInteractionEnabled = false
                    self.btnNextHole.isUserInteractionEnabled = false
                }
                if(self.swingMatchId.count != 0){
                    self.btnOnOffCourse.tag = 0
                }
                if(self.isContinueMatch){
                    if let current = self.matchDataDictionary.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).currentHole") as? String{
                        self.index = Int(current)!-1
                    }else{
                        self.index = Int(self.matchDataDictionary.value(forKeyPath: "currentHole") as! String)! - 1
                    }
                    if let data = self.matchDataDictionary.value(forKeyPath: "player.\(Auth.auth().currentUser!.uid).gpsMode") as? String{
                        if data == "phone"{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command11"), object:nil)
                        }
                    }
                }
                
                self.updateMap(indexToUpdate: self.index)
                self.shotsFooterView.roundCorners([UIRectCorner.topLeft,UIRectCorner.topRight], radius: 5)
                self.newView.roundCorners([UIRectCorner.allCorners], radius: 5)
                self.btnShotLandedOn.layer.cornerRadius = self.btnShotLandedOn.frame.height/2
                self.btnShotDistance.setCorner(color: UIColor.glfBorder.cgColor)
                self.btnClubName.setCorner(color: UIColor.glfBorder.cgColor)
                self.btnTrackShot.setCorner(color: UIColor.clear.cgColor)
                self.btnHoleOutInsideFooter.setCorner(color: UIColor.clear.cgColor)
                self.btnInTheHole.setCorner(color: UIColor.clear.cgColor)
                self.btnSelectClub.semanticContentAttribute = .forceRightToLeft
                
                self.btnClubName.translatesAutoresizingMaskIntoConstraints = false
                self.btnClubName.addConstraint(NSLayoutConstraint(item: self.btnClubName, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
                self.btnClubName.addConstraint(NSLayoutConstraint(item: self.btnClubName, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                self.btnStatsView.tag = 1
                self.stackViewMenu.isHidden = true
                self.stackViewMenu.backgroundLayer.cornerRadius = 5
                self.newMenuView.isHidden = true
                
                self.view.addSubview(self.newView)
                self.view.addSubview(self.stackViewForGreenShots)
                self.view.addSubview(self.stackViewMenu)
                self.view.addSubview(self.btnHoleOut)
                self.view.addSubview(self.btnShotsCount)
                self.view.addSubview(self.headerViewMap)
                self.view.addSubview(self.shotsFooterView)
                self.view.addSubview(self.imgWindDir)
                self.view.addSubview(self.lblWindSpeed)
                self.view.addSubview(self.newMenuView)
                self.view.addSubview(self.viewForEditShots)
            
                self.setLeftRightButtonView()
                self.progressView.hide(navItem: self.navigationItem)
            }
        }
    }
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func setRange(){
        let gameType = self.matchDataDictionary.value(forKey: "matchType") as! String == "9 holes" ? 9:18
        
        if(gameType < coordBound.count){
            if(self.startingHole+8 <= coordBound.count){
                self.lastHole = self.startingHole+8
            }else if(self.startingHole+8 > coordBound.count){
                self.lastHole = self.startingHole+8 - coordBound.count
            }
        }else if(gameType > coordBound.count){
            let newCoordBound = coordBound
            for newCoord in newCoordBound{
                coordBound.append(newCoord)
            }
            self.startingHole = 1
            self.lastHole = coordBound.count
        }else{
            self.startingHole = 1
            self.lastHole = coordBound.count
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
        self.btnMenu.isHidden = true
        btnTrackShot.isUserInteractionEnabled = holeOutFlag
        btnInTheHole.isUserInteractionEnabled = holeOutFlag
        btnHoleOutInsideFooter.isUserInteractionEnabled = holeOutFlag
        btnLeftShot.isUserInteractionEnabled = holeOutFlag
        btnRightShot.isUserInteractionEnabled = holeOutFlag
        //        shotDetailsStackView.isHidden = !holeOutFlag
        //        shotStackView.isUserInteractionEnabled = !holeOutFlag
        suggestedMarker1.map = nil
        suggestedMarker2.map = nil
        
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        //        self.mapView.setMinZoom(21, maxZoom: 16)
        if !(self.isProcessing){
            self.viewForEditShots.isHidden = true
            self.newMenuView.isHidden = true
            
            for coord in self.numberOfHoles[self.index].green{
                self.pathOfGreen.add(coord)
            }
            if !(self.stackViewMenu.isHidden){
                self.stackViewMenu.isHidden = true
            }
            self.mapView.settings.scrollGestures = true
            var allMarkers = markers
            for i in 0..<markersForCurved.count{
                if(i == 0) && markers.count>0 && !holeOutFlag{
                    allMarkers[0].title = "PointWithCurved"
                    allMarkers[0].userData = shotCount-1
                }
                allMarkers.append(markersForCurved[i])
            }
            if(sender.numberOfTouches == 1){
                var positions = CGPoint()
                var newPosition = CLLocationCoordinate2D()
                let currentZoom = self.mapView.camera.zoom
                
                switch (sender.state){
                case .began:
                    positions = sender.location(in: self.mapView)
                    //                positions = sender.location(ofTouch: 0, in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = self.getNearbymarkers(position: newPosition,markers:allMarkers)
                    
                    print(ind)
                    if(self.positionsOfDotLine.count>1 && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < self.getDistanceWithZoom(zoom: currentZoom)){
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
                            mapView(self.mapView, didBeginDragging: allMarkers[ind])
                            self.mapView.settings.scrollGestures = true
                        }
                    }
                    break
                    
                case .ended:
                    
                    positions = sender.location(in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = self.getNearbymarkers(position: newPosition,markers:allMarkers)
                    print(ind)
                    if(self.positionsOfDotLine.count>1 && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < self.getDistanceWithZoom(zoom: currentZoom)){
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
                            mapView(self.mapView, didEndDragging: allMarkers[ind])
                            self.mapView.settings.scrollGestures = true
                        }
                    }
                    break
                case .changed:
                    positions = sender.location(in: self.mapView)
                    newPosition = self.mapView.projection.coordinate(for: positions)
                    let ind = self.getNearbymarkers(position: newPosition,markers:allMarkers)
                    print(ind)
                    if(self.positionsOfDotLine.count>1 && allMarkers[ind].map != nil){
                        let distance = GMSGeometryDistance(allMarkers[ind].position, newPosition)
                        if(distance < self.getDistanceWithZoom(zoom: currentZoom)) && sender.numberOfTouches != 2{
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
                            mapView(self.mapView, didDrag: allMarkers[ind])
                            self.mapView.settings.scrollGestures = true
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
        
    }
    func getNearbymarkers(position:CLLocationCoordinate2D,markers:[GMSMarker])->Int{
        
        var distanceArray = [Double]()
        for markers in markers{
            let distance = GMSGeometryDistance(markers.position, position)
            distanceArray.append(distance)
            debugPrint(markers.title!)
        }
        return distanceArray.index(of: distanceArray.min()!) ?? 0
    }
    
    func getDistanceWithZoom(zoom:Float)->Double{
        var checkDistance:Double = 20
        if (zoom > 20) {
            checkDistance = 1
        } else if (zoom > 19.8 && zoom < 20) {
            checkDistance = 2
        } else if (zoom > 19.6 && zoom < 19.8) {
            checkDistance = 2
        } else if (zoom > 19.4 && zoom < 19.6) {
            checkDistance = 3
        } else if (zoom > 19.2 && zoom < 19.4) {
            checkDistance = 4
        } else if (zoom > 19 && zoom < 19.2) {
            checkDistance = 5
        } else if (zoom > 18.8 && zoom < 19) {
            checkDistance = 6
        } else if (zoom > 18.6 && zoom < 18.8) {
            checkDistance = 7
        } else if (zoom > 18.4 && zoom < 18.6) {
            checkDistance = 8
        } else if (zoom > 18.2 && zoom < 18.4) {
            checkDistance = 9
        } else if (zoom > 17 && zoom < 18.2) {
            checkDistance = 10
        } else if (zoom > 17.8 && zoom < 18) {
            checkDistance = 11
        } else if (zoom > 17.6 && zoom < 17.8) {
            checkDistance = 12
        } else if (zoom > 17.4 && zoom < 17.6) {
            checkDistance = 13
        } else if (zoom > 17.2 && zoom < 17.4) {
            checkDistance = 14
        } else if (zoom > 17 && zoom < 17.2) {
            checkDistance = 15
        } else if (zoom > 16.8 && zoom < 17) {
            checkDistance = 16
        } else if (zoom > 16.6 && zoom < 16.8) {
            checkDistance = 17
        } else if (zoom > 16.4 && zoom < 16.6) {
            checkDistance = 18
        } else if (zoom > 16.2 && zoom < 16.4) {
            checkDistance = 19
        } else if (zoom > 16 && zoom < 16.2) {
            checkDistance = 20
        }
        return checkDistance*3
    }

    func initilizeScoreNode(){
        self.scoring.removeAll()
        let scoring = NSMutableDictionary()
        var holeArray = [NSMutableDictionary]()
        for i in 0..<coordBound.count{
            self.scoring.append((hole: i, par: 0,players:[NSMutableDictionary]()))
            let player = NSMutableDictionary()
            for j in 0..<playersButton.count{
                let playerScore = NSMutableDictionary()
                let playerData = ["holeOut":false]
                player.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                playerScore.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                self.scoring[i].players.append(playerScore)
            }
            self.scoring[i].par = self.bounds[i].par!
            player.setObject(self.bounds[i].par!, forKey: "par" as NSCopying)
            holeArray.append(player)
        }
        scoring.setObject(holeArray, forKey: "scoring" as NSCopying)
        if(!isAcceptInvite){
            ref.child("matchData/\(self.currentMatchId)/").updateChildValues(scoring as! [AnyHashable : Any])
        }
    }
    func resetScoreNodeForMe(){
        for i in 0..<coordBound.count{
            let player = NSMutableDictionary()
            for j in 0..<playersButton.count{
                if(playersButton[j].id == Auth.auth().currentUser?.uid) || (playersButton[j].id == "jpSgWiruZuOnWybYce55YDYGXP62"){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: playersButton[j].id as NSCopying)
                    ref.child("matchData/\(self.currentMatchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoring[i].players[j].addEntries(from: playerData)
                }
            }
        }
    }
    
    func drawAllPolygon(indexToUpdate:Int){
        for i in 0..<self.numberOfHoles[indexToUpdate].tee.count{
            self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].tee)[i], color: UIColor.yellow)
        }
        for i in 0..<self.numberOfHoles[indexToUpdate].fairway.count{
            self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].fairway)[i], color: UIColor.black)
        }
        self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].green), color: UIColor.green)

        for i in 0..<self.numberOfHoles[indexToUpdate].gb.count{
            self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].gb)[i], color: UIColor.white)
        }
        for i in 0..<self.numberOfHoles[indexToUpdate].fb.count{
            self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].fb)[i],color:UIColor.white)
        }
//        for i in 0..<self.numberOfHoles[indexToUpdate].wh.count{
//            self.drawPolygonWithStrokesColor(polygonArray: (self.numberOfHoles[indexToUpdate].wh)[i],color:UIColor.blue)
//        }
    }
    
    func updateMap(indexToUpdate:Int){
        var indexToUpdate = indexToUpdate
        self.isTracking = false
        for coord in self.numberOfHoles[indexToUpdate].green{
            self.pathOfGreen.add(coord)
        }
        if !(stackViewMenu.isHidden){
            stackViewMenu.isHidden = true
        }
        locationManager.startUpdatingLocation()
        self.penaltyShots = [Bool]()
        newMenuView.isHidden = true
        self.viewForEditShots.isHidden = true
        isSolidLinePloted = false
        mapView.clear()
        mapTimer.invalidate()
        approachDistance = 0.0
        isDraggingMarker = false
        btnShotsCount.isEnabled = true
        shotCount = 0
        shotIndex = 0
        shotViseCurve = [(shot:Int,line:GMSPolyline,markerPosition:GMSMarker)]()
        isUpdating = false
        holeOutFlag = false
        btnSelectClub.isHidden = false
        curvedLines.map = nil
        if(selectClubDropper == nil){
            selectClubDropper = Dropper(width: 75, height: 200)
            selectClubDropper.items = clubs
            selectClubDropper.delegate = self
        }
        if(selectClubDropper.status == .shown) || (selectClubDropper.status == .displayed){
            selectClubDropper.hideWithAnimation(0.15)
        }
        playerShotsArray = [NSMutableDictionary]()
        if(!isMapViewColor){
            self.updateMapWithColors()
            self.isMapViewColor = false
        }
        
        positionsOfCurveLines.removeAll()
        indexToUpdate = indexToUpdate == -1 ? indexToUpdate+1 : indexToUpdate
//        self.drawAllPolygon(indexToUpdate: indexToUpdate)
        self.btnHoleTitle.setTitle("Hole \(indexToUpdate+1) - Par \(bounds[indexToUpdate].par!)", for: .normal)
        self.positionsOfDotLine.removeAll()
        
        
        self.markers.removeAll()
        let path = self.getPathFromBounds(index:indexToUpdate)
        
        let minBound = CLLocationCoordinate2D(latitude: bounds[indexToUpdate].minLat! , longitude:bounds[indexToUpdate].minLng!)
        let maxMinBound = CLLocationCoordinate2D(latitude: bounds[indexToUpdate].maxLat! , longitude:bounds[indexToUpdate].minLng!)
        let maxBound = CLLocationCoordinate2D(latitude: bounds[indexToUpdate].maxLat! , longitude:bounds[indexToUpdate].maxLng!)
        let minMaxBound = CLLocationCoordinate2D(latitude: bounds[indexToUpdate].minLat! , longitude:bounds[indexToUpdate].maxLng!)
        let headingMax = GMSGeometryHeading(maxBound, minMaxBound)
        let headingMinMax = GMSGeometryHeading(maxBound, minMaxBound)
        
        let newMin = GMSGeometryOffset(minBound, 100, headingMax+45)
        let newMaxMin = GMSGeometryOffset(maxMinBound, -100, headingMinMax-45)
        let newMax = GMSGeometryOffset(maxBound, -100, headingMax+45)
        let newMinMax = GMSGeometryOffset(minMaxBound, 100, headingMax-45)
        
        let newPath = GMSMutablePath()
        newPath.add(newMin)
        newPath.add(newMaxMin)
        newPath.add(newMax)
        newPath.add(newMinMax)
        
        //        let newPathBecauseFooterView = GMSMutablePath()
        if(userLocationForClub != nil && selectedUserId == Auth.auth().currentUser?.uid){
            if (GMSGeometryContainsLocation(userLocationForClub!,path ,true)){
                self.positionsOfDotLine.append(userLocationForClub!)
                self.previousUserLocation = self.userLocationForClub!
            }
            else{
                self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[indexToUpdate].tee)
                self.isUserInsideBound = false
            }
        }
        else{
            self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[indexToUpdate].tee)
        }
        
        self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[indexToUpdate].fairway)
        self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[indexToUpdate].green)
        
        //        self.mapView.animate(with: GMSCameraUpdate.fit(self.coordBound[indexToUpdate], withPadding: 0))
        //        var boundaryPoint = centerPointOfTeeNGreen[self.index].tee
        //        let heading = GMSGeometryHeading(centerPointOfTeeNGreen[self.index].green, centerPointOfTeeNGreen[self.index].tee)
        //        boundaryPoint = GMSGeometryOffset(boundaryPoint, 180, heading)
        
        // Next Time Update
        self.letsRotateWithZoom(latLng1: positionsOfDotLine.first!, latLng2: positionsOfDotLine.last!)
//        let zoomLevel = getTheZoomLevel()
//        if(GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!) < 1000){
//            self.mapView.setMinZoom(zoomLevel.1-1, maxZoom:22 )
//        }
        
        var shotsArr = NSArray()
        if(indexToUpdate > scoring.count){
            self.index = 0
            indexToUpdate = 0
        }
        
        if(scoring[indexToUpdate].players.count>0){
            for playerScore in scoring[indexToUpdate].players{
                for (key,value) in playerScore{
                    for activePlay in playersButton{
                        if(activePlay.isSelected && activePlay.id == key as! String){
                            
                            let shots = value as! NSDictionary
                            var shotsArray = NSArray()
                            for(key,value)in shots{
                                if(key as! String == "shots"){
                                    shotsArray = value as! NSArray
                                    shotsArr = shotsArray
                                }
                                if(key as! String == "holeOut"){
                                    holeOutFlag = value as! Bool
                                }
                                if(key as! String == "gir"){
                                    gir = value as! Bool
                                }
                                if(key as! String == "shotTracking"){
                                    if let newDict = value as? NSMutableDictionary{
//                                        newDict.setObject(clubName!, forKey: "club" as NSCopying)
                                        self.previousUserLocation.latitude = newDict.value(forKey: "lat1") as! CLLocationDegrees
                                        self.previousUserLocation.longitude = newDict.value(forKey: "lng1") as! CLLocationDegrees
                                        self.positionsOfDotLine[0].latitude = newDict.value(forKey: "lat2") as! CLLocationDegrees
                                        self.positionsOfDotLine[0].longitude = newDict.value(forKey: "lng2") as! CLLocationDegrees
                                        self.isTracking = true
                                    }
                                }
                            }
                            if(self.swingMatchId.count != 0) {
                                for i in 0..<shotsArray.count {
                                    let shotLatLng = shotsArray[i] as! NSDictionary
                                    playerShotsArray.append(shotLatLng as! NSMutableDictionary)
                                    self.penaltyShots.append(shotLatLng.value(forKey: "penalty") as! Bool)
                                    positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
                                    if(holeOutFlag) && i == shotsArray.count-1{
                                        if(shotLatLng.value(forKey: "lat2") != nil){
                                            positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat2") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng2") as! CLLocationDegrees))
                                        }else{
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
                            shotCount = shotsArray.count
                            shotIndex = shotsArray.count
                        }
                    }
                }
            }
            if(positionsOfCurveLines.count != 0){
                positionsOfDotLine[0] = positionsOfCurveLines.last!
                let dist = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!) * YARD
                let heading = GMSGeometryHeading(positionsOfDotLine.first!, positionsOfDotLine.last!)
                var midPoint = GMSGeometryOffset(positionsOfDotLine.first!, GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)*0.7, heading)
                if(dist<201 && Int(dist) > 0){
                    for i in 1..<Int(dist){
                        if(BackgroundMapStats.findPositionOfPointInside(position: midPoint, whichFeature: self.numberOfHoles[index].green)){
                            break
                        }else{
                            midPoint = GMSGeometryOffset(midPoint, Double(i), heading)
                        }
                    }
                }
                positionsOfDotLine[1] = midPoint
            }
        }
        
        var shotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
        for data in shotsArr{
            let score = data as! NSMutableDictionary
            let distance = score.value(forKey: "distance") as? Double
            let club = score.value(forKey: "club") as! String
            var strokGaind = score.value(forKey: strkGainedString[0]) as? Double
            if let strk = score.value(forKey: strkGainedString[skrokesGainedFilter]) as? Double{
                strokGaind = strk
            }
            let endingPoints = score.value(forKey: "end") as? String
            let isPenalty = score.value(forKey: "penalty") as! Bool
            shotsDetails.append((club: club, distance: distance ?? 0.0, strokesGained: strokGaind ?? 0.0, swingScore: "N/A",endingPoint:endingPoints ?? "Calculating",penalty:isPenalty))
        }
        if(holeOutFlag){
            //            self.lblHoleSubtitle.text = "Score \(self.shotCount!)"
            self.btnInTheHole.isHidden = true
            self.trackShotStackView.isHidden = true
            self.shotDetailsStackView.isHidden = true
            self.holeOutStackView.isHidden = false
            self.btnLeftShot.isEnabled = true
            self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
            self.btnRightShot.isEnabled = false
            btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
            self.shotIndex = shotsDetails.count
            var tag = 0
            for view in holeOutStackView.subviews{
                view.removeFromSuperview()
            }
            self.setHoleShotDetails(par: self.scoring[index].par, shots: shotsDetails.count,isStates:true)
            for data in shotsDetails{
                let btn = UIButton()
                btn.tag = tag
                btn.addTarget(self, action: #selector(shotCheck(_:)), for: .touchUpInside)
                btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 12)
                btn.setTitle(data.club, for: .normal)
                if(data.strokesGained > 0){
                    btn.setTitleColor(UIColor.glfWhite, for: .normal)
                    btn.setCorner(color: UIColor.clear.cgColor)
                    btn.backgroundColor = UIColor.glfGreen
                }else{
                    btn.setTitleColor(UIColor.glfNegativeClub, for: .normal)
                    btn.setCorner(color: UIColor.glfNegativeClub.cgColor)
                    btn.backgroundColor = UIColor.glfWhite
                }
                if(data.penalty){
                    btn.setTitle("", for: .normal)
                    btn.setImage(#imageLiteral(resourceName: "penalty"), for: .normal)
                }
                tag += 1
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.addConstraint(NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                btn.addConstraint(NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                holeOutStackView.addArrangedSubview(btn)
            }
            let newBtn = UIButton()
            newBtn.backgroundColor = UIColor.clear
            holeOutStackView.addArrangedSubview(newBtn)
            
        }else if(shotsDetails.count > 0){
            self.lblHoleSubtitle.text = "Shot \(self.shotCount!)"
            self.btnLeftShot.isEnabled = true
            self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
            self.btnRightShot.isEnabled = false
            self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
            self.shotIndex = shotsDetails.count
            
            self.lblHoleSubtitle.textColor = UIColor.glfBluegreen
            //            self.lblHoleSubtitle.text = "Shot \(shotsDetails.count)"
            self.trackShotStackView.isHidden = false
            self.shotDetailsStackView.isHidden = true
            self.holeOutStackView.isHidden = true
            
            var suffix = "\(shotsDetails.last!.distance.rounded()) yd"
            if(distanceFilter == 1){
                suffix = "\((shotsDetails.last!.distance/YARD).rounded()) m"
            }
            if((shotsDetails.last!.distance) < 20.0){
                suffix = "\((shotsDetails.last!.distance * 3).rounded()) ft"
                if(distanceFilter == 1){
                    suffix = "\((shotsDetails.last!.distance/(YARD*3)).rounded()) m"
                }
            }
            
            self.btnShotDistance.setTitle(suffix, for: .normal)
            self.btnShotDistance.setCorner(color: UIColor.clear.cgColor)
            self.btnShotStrokesGained.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 14)
            self.btnShotStrokesGained.setCorner(color: UIColor.clear.cgColor)
            self.btnShotStrokesGained.backgroundColor = UIColor.glfStrokesNbg
            self.btnShotStrokesGained.setTitleColor(UIColor.glfBlack, for: .normal)
            if(shotsDetails.last!.strokesGained > 0){
                self.btnShotStrokesGained.backgroundColor = UIColor.glfStrokesPbg
            }
            self.btnShotStrokesGained.setTitle("\(shotsDetails.last!.strokesGained.rounded(toPlaces: 2)) S.G", for: .normal)
            
            self.btnClubName.setTitle(shotsDetails.last!.club, for: .normal)
            self.btnClubName.setCorner(color: UIColor.clear.cgColor)
            self.btnShotLandedOn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 12)
            self.btnShotLandedOn.setTitleColor(UIColor.glfWhite, for: .normal)
            self.btnShotLandedOn.layer.cornerRadius = self.btnShotLandedOn.frame.height/2
            
            if shotsDetails.last!.endingPoint == "G"{
                self.btnShotLandedOn.backgroundColor = UIColor.glfGreen
                self.btnShotLandedOn.setTitle("Green", for: .normal)
                if(shotsDetails.count-1 == self.shotIndex){
                    self.btnInTheHole.isHidden = false
                }
            }else if shotsDetails.last!.endingPoint == "F" {
                self.btnShotLandedOn.backgroundColor = UIColor.glfFairway
                self.btnShotLandedOn.setTitle("Fairway", for: .normal)
            }else if shotsDetails.last!.endingPoint == "GB" || shotsDetails.last!.endingPoint == "FB"{
                self.btnShotLandedOn.setTitle("Bunker", for: .normal)
                self.btnShotLandedOn.backgroundColor = UIColor.glfBunker
            }else{
                self.btnShotLandedOn.setTitle("Rough", for: .normal)
                self.btnShotLandedOn.backgroundColor = UIColor.glfRough
            }
            
            if(!holeOutFlag){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.btnHoleOutInsideFooter.isHidden = true
                    if(self.positionsOfDotLine.count > 0){
                        if(GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * YARD) < 100{
                            self.btnHoleOutInsideFooter.isHidden = false
                        }
                    }
                    self.trackShotStackView.isHidden = true
                    self.shotDetailsStackView.isHidden = false
                    self.holeOutStackView.isHidden = true
                })
            }
        }else{
            if(GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * YARD) < 100{
                self.btnHoleOutInsideFooter.isHidden = false
            }
            self.trackShotStackView.isHidden = true
            self.shotDetailsStackView.isHidden = false
            self.holeOutStackView.isHidden = true
            self.btnLeftShot.isEnabled = false
            self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot"), for: .disabled)
            self.btnRightShot.isEnabled = false
            btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
            self.shotIndex = shotsDetails.count
        }
        for marker in markersForCurved{
            marker.map = nil
        }
        markersForCurved = [GMSMarker]()
        if(holeOutFlag){
            positionsOfDotLine.removeAll()
        }
        for i in 0..<positionsOfDotLine.count{
            self.plotMarker(position: positionsOfDotLine[i], userData: i)
        }
        self.overlayView.removeFromSuperview()
        
        if(positionsOfDotLine.count > 2){
            markers.last?.icon = #imageLiteral(resourceName: "holeflag")
            markers.last?.groundAnchor = CGPoint(x:0,y:1)
            
            var icon = #imageLiteral(resourceName: "Tee")
            if(positionsOfCurveLines.count > 1){
                if (isPositionAvailable(latLng: positionsOfCurveLines.last!, latLngArray: positionsOfDotLine) != -1){
                    icon = #imageLiteral(resourceName: "target")
                }
            }
            let btn = UIButton()
            
            if(isUserInsideBound){
                if let img = (Auth.auth().currentUser?.photoURL){
                    btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
                }
                else{
                    btn.backgroundColor = UIColor.glfWhite
                    let name = Auth.auth().currentUser?.displayName
                    btn.setTitle("\(name?.first ?? " ")", for: .normal)
                    btn.setTitleColor(UIColor.glfBlack, for: .normal)
                    
                }
                markers.first?.iconView = btn
            }else{
                //                if let img = (Auth.auth().currentUser?.photoURL){
                //                    btn.sd_setBackgroundImage(with: img, for: .normal, completed: nil)
                //                    icon = btn.currentBackgroundImage!
                //                }
                markers.first?.icon = icon
            }
            
            plotLine(positions: positionsOfDotLine)
            
            if(GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)*YARD < 100){
                self.btnHoleOutInsideFooter.isHidden = false
            }else{
                self.btnHoleOutInsideFooter.isHidden = true
            }
        }
        
        //remove below line while testing is done
        //        if(self.positionsOfDotLine.first != nil){
        //            userLocationForClub = self.positionsOfDotLine.first!
        //        }
        var flag = true
        var counter = 30
        if(userLocationForClub != nil && self.btnOnOffCourse.tag == 1){
            self.btnTrackShot.setTitle("Track Shot \(shotCount!+1)", for: .normal)

            mapTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                self.locationManager.startUpdatingLocation()
                if(self.positionsOfDotLine.count > 2){
                    var distance  = GMSGeometryDistance(self.positionsOfDotLine.last!,self.userLocationForClub!)
                    if (distance < 15000){
                        //                    if (GMSGeometryContainsLocation(self.userLocationForClub!,newPath ,true)) && (!self.holeOutFlag){
                        self.btnOnOffCourse.tag = 1
                        self.positionsOfDotLine.remove(at: 0)
                        self.positionsOfDotLine.insert(self.userLocationForClub!, at: 0)
                        self.isUserInsideBound = true
                        self.markers[0].position = self.userLocationForClub!
                        var suffix = "meter"
                        if(distanceFilter != 1){
                            distance = distance*YARD
                            suffix = "yard"
                        }
/*                        if(counter%10 == 0){
                            debugPrint("isTracking\(self.isTracking)")
                            if(self.holeOutFlag){
                                Notification.sendGameDetailsNotification(msg: "Hole \(self.index+1) • Par \(self.scoring[self.index].par) • \((self.matchDataDictionary.value(forKey: "courseName") as! String))", title: "You Played \(self.shotCount!) shots.", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                            }else{
                                if(BackgroundMapStats.findPositionOfPointInside(position: self.userLocationForClub!, whichFeature:self.numberOfHoles[self.index].green)){
                                    Notification.sendGameDetailsNotification(msg: "Hole \(self.index+1) • Par \(self.scoring[self.index].par) • \((self.matchDataDictionary.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                                }else{
                                    Notification.sendGameDetailsNotification(msg: "Hole \(self.index+1) • Par \(self.scoring[self.index].par) • \((self.matchDataDictionary.value(forKey: "courseName") as! String))", title: "Distance to Pin: \(Int(distance)) \(suffix)", subtitle:"",timer:1.0,isStart:self.isTracking, isHole: self.holeOutFlag)
                                }

                            }
                            
                        }*/
                        counter += 2
                        debugPrint("distance",distance)
                        
                        if(self.positionsOfCurveLines.count > 0){
                            self.plotDashedLine(positions: [self.positionsOfCurveLines.last!,self.positionsOfDotLine[0]])
                        }
                        if(flag){
                            self.updateLine(mapView: self.mapView, marker: self.markers[1])
                            flag = false
                        }
                        self.btnARView.isHidden = false
                    }
                    else{
                        let alert = UIAlertController(title: "Alert" , message: "Your location is not near the tee. Switching round to Off Course mode." , preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        timer.invalidate()
                        self.btnOnOffCourse.tag = 0
                        self.btnOnOffCourse.setTitle(" Off Course Mode ", for: .normal)
                        self.btnOnOffCourse.setImage(#imageLiteral(resourceName: "gray_dot"), for: .normal)
                        self.btnGreenDot.setImage(#imageLiteral(resourceName: "gray_dot"), for: .normal)
                        self.btnHoleTitle.setImage(#imageLiteral(resourceName: "gray_dot"), for: .normal)
                        self.btnARView.isHidden = true
                    }
                }
            })
        }
        if(positionsOfCurveLines.count != 0){
            shotCount = 0
            for i in 0..<positionsOfCurveLines.count-1{
                plotCurvedPolyline(latLng1: positionsOfCurveLines[i], latLng2: positionsOfCurveLines[i+1], whichLine: false, club: shotsDetails[i].club)
                self.plotMarkerForCurvedLine(position: positionsOfCurveLines[i], userData: i)
                shotViseCurve.append((shot: shotCount, line: curvedLines , markerPosition:markerInfo))
                shotCount = shotCount + 1
            }
            //            markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
        }
        
        if(holeOutFlag){
            btnShotsCount.isEnabled = false
            btnSelectClub.isHidden = true
            self.plotMarkerForCurvedLine(position: positionsOfCurveLines.last!, userData: positionsOfCurveLines.count-1)
            markersForCurved.last?.icon = #imageLiteral(resourceName: "holeflag")
            markersForCurved.last?.groundAnchor = CGPoint(x: 0, y: 1)
            for view in (self.btnTrackShot.superview as! UIStackView).arrangedSubviews{
                if view.tag == 22{
                    view.removeFromSuperview()
                    break
                }
            }
            
        }else{
            self.btnRightShot.isEnabled = false
            self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
            if(positionsOfCurveLines.count == 0){
                self.lblHoleSubtitle.text = "Shot 1"
                self.btnLeftShot.isEnabled = false
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot"), for: .disabled)
            }else{
                self.btnLeftShot.isEnabled = true
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .disabled)
            }
            
            self.btnTrackShot.setTitle("Take Shot \(shotCount+1)", for: .normal)

            plotSuggestedMarkers(position: positionsOfDotLine)
            
        }
        for i in 0..<penaltyShots.count{
            if(penaltyShots[i]){
                markersForCurved[i].icon = #imageLiteral(resourceName: "penalty_shot")
            }
        }
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
        if(isShowCase){
            self.plotCTShowCase()
        }
        if(isUserInsideBound && positionsOfCurveLines.count == 0){
            self.btnTrackShot.setTitle("Track Shot \(shotCount!+1)", for: .normal)
            btnShotsCount.titleLabel?.font = UIFont(name:"SFProDisplay-Light", size: 15)
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
                    self.btnShotsCount.isEnabled = false
                    self.btnHoleOut.isEnabled = false
                    let distance = GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!) * YARD
                    if(self.scoring[self.index].par == 3){
                        self.botPlayerShotForPar3(gir:0,distance:distance, distanceFairwayOrRough: self.distanceFairway)
                        if(distance > 350){
                            self.botPlayerShotForPar4(girWithF:self.girWithFairway,distance:distance)
                        }
                    }
                    else if(self.scoring[self.index].par == 4 || self.scoring[self.index].par == 5){
                        self.botPlayerShotForPar4(girWithF:self.girWithFairway,distance:distance)
                    }
                    
                    break
                }else{
                    self.btnShotsCount.isEnabled = true
                    self.btnHoleOut.isEnabled = true
                    self.isBotTurn = false
                }
            }
        })
        if(isHoleByHole){
            self.setupHoleByHole()
        }
    }
    
    // MARK: - btnActionLeftShot
    @IBAction func btnActionLeftShot(_ sender: Any) {
        self.newMenuView.isHidden = true
        self.stackViewForEditShots.isHidden = true
        if(shotIndex > -1){
            shotIndex -= 1
            self.lblHoleSubtitle.text = "Shot \(shotIndex+1)"
            let btn = UIButton()
            btn.tag = self.shotIndex
            btn.addTarget(self, action: #selector(shotCheck(_:)), for: .touchUpInside)
            self.shotCheck(btn)
            self.btnRightShot.isEnabled = true
            self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot_sel"), for: .normal)
            if(shotIndex == 0){
                self.btnLeftShot.isEnabled = false
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot"), for: .disabled)
            }
            for data in shotViseCurve{
                tappedMarker = nil
                if data.shot == shotIndex{
                    tappedMarker = data.markerPosition
                    break
                }
            }
        }
    }
    
    // MARK: - btnActionRightShot
    @IBAction func btnActionRightShot(_ sender: Any) {
        let shotsDetails = getShotDataOrdered(indexToUpdate:self.index)
        self.newMenuView.isHidden = true
        self.stackViewForEditShots.isHidden = true
        if(shotsDetails.count > self.shotIndex){
            self.shotIndex += 1
            print(shotIndex)
            
            if(self.shotIndex < shotsDetails.count){
                if(!self.btnLeftShot.isEnabled){
                    self.btnLeftShot.isEnabled = true
                    self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
                }
                self.lblHoleSubtitle.text = "Shot \(shotIndex+1)"
                
                let btn = UIButton()
                btn.tag = self.shotIndex
                btn.addTarget(self, action: #selector(shotCheck(_:)), for: .touchUpInside)
                self.shotCheck(btn)
            }else if(shotsDetails.count == self.shotIndex){
                if(holeOutFlag){
                    self.btnInTheHole.isHidden = true
                    self.lblHoleSubtitle.text = "          "
                    self.trackShotStackView.isHidden = true
                    self.shotDetailsStackView.isHidden = true
                    self.holeOutStackView.isHidden = false
                    self.btnRightShot.isEnabled = false
                    self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
                    var tag = 0
                    for view in holeOutStackView.subviews{
                        view.removeFromSuperview()
                    }
                    self.setHoleShotDetails(par: self.scoring[index].par, shots: shotsDetails.count,isStates:true)
                    for data in shotsDetails{
                        let btn = UIButton()
                        btn.tag = tag
                        btn.addTarget(self, action: #selector(shotCheck(_:)), for: .touchUpInside)
                        btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 12)
                        btn.setTitle(data.club, for: .normal)
                        if(data.strokesGained > 0){
                            btn.setTitleColor(UIColor.glfWhite, for: .normal)
                            btn.setCorner(color: UIColor.clear.cgColor)
                            btn.backgroundColor = UIColor.glfGreen
                        }else{
                            btn.setTitleColor(UIColor.glfNegativeClub, for: .normal)
                            btn.setCorner(color: UIColor.glfNegativeClub.cgColor)
                            btn.backgroundColor = UIColor.clear
                        }
                        if(data.penalty){
                            btn.setTitle("", for: .normal)
                            btn.setImage(#imageLiteral(resourceName: "penalty"), for: .normal)
                        }
                        tag += 1
                        btn.translatesAutoresizingMaskIntoConstraints = false
                        btn.addConstraint(NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                        btn.addConstraint(NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                        holeOutStackView.addArrangedSubview(btn)
                    }
                    let newBtn = UIButton()
                    newBtn.backgroundColor = UIColor.clear
                    holeOutStackView.addArrangedSubview(newBtn)
                }else{
                    self.lblHoleSubtitle.text = "Shot \(self.shotIndex+1)"
                    self.shotDetailsStackView.isHidden = false
                    self.trackShotStackView.isHidden = true
                    self.btnHoleOutInsideFooter.isHidden = true
                    self.btnRightShot.isEnabled = false
                    self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .disabled)
                    self.btnLeftShot.isEnabled = true
                    self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .normal)
                    if GMSGeometryDistance(self.positionsOfDotLine.first!, self.positionsOfDotLine.last!)*YARD < 100{
                        self.btnHoleOutInsideFooter.isHidden = false
                    }
                    if(shotsDetails.last?.endingPoint == "G") && shotIndex == shotsDetails.count-1{
                        self.btnInTheHole.isHidden = false
                    }
                }
                self.shotIndex = shotsDetails.count
            }
            for data in shotViseCurve{
                tappedMarker = nil
                if data.shot == shotIndex{
                    tappedMarker = data.markerPosition
                    break
                }
            }
        }
    }
    
    func getShotDataOrdered(indexToUpdate:Int)->[(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]{
        var shotsArr = NSArray()
        var shotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
        for playerScore in scoring[indexToUpdate].players{
            for (key,value) in playerScore{
                for activePlay in playersButton{
                    if(activePlay.isSelected && activePlay.id == key as! String){
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
        }
        if(shotsArr.count > 0){
            for data in shotsArr{
                let score = data as! NSMutableDictionary
                let distance = score.value(forKey: "distance") as? Double
                let club = score.value(forKey: "club") as! String
                let strokGaind = score.value(forKey: strkGainedString[skrokesGainedFilter]) as? Double
                let endingPoints = score.value(forKey: "end") as? String
                let penalty = score.value(forKey: "penalty") as! Bool
                let startingPoint = score.value(forKey: "start") as? String
                shotsDetails.append((club: club, distance: distance ?? 0.0, strokesGained: strokGaind ?? 0.0, swingScore: startingPoint ?? "calculating",endingPoint:endingPoints ?? "calculationg ",penalty:penalty))
            }
        }
        return shotsDetails
    }
    
    @objc func shotCheck(_ sender: UIButton!){
        let shotsDetail = getShotDataOrdered(indexToUpdate: index)
        if(sender.tag < shotsDetail.count) || sender.tag == 44 {
            self.btnInTheHole.isHidden = true
            let tagIndex = sender.tag == -1 ? 0 : sender.tag
            if(tagIndex == 0) && self.shotCount > 1{
                self.btnLeftShot.isEnabled = false
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot"), for: .disabled)
                self.btnRightShot.isEnabled = true
                self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot_sel"), for: .normal)
            }else if(tagIndex > 0) && self.shotCount > 2 {
                self.btnLeftShot.isEnabled = true
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .disabled)
                self.btnRightShot.isEnabled = true
                self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot_sel"), for: .normal)
            }else if (tagIndex == self.shotCount){
                self.btnLeftShot.isEnabled = true
                self.btnLeftShot.setBackgroundImage(#imageLiteral(resourceName: "prev shot_sel"), for: .disabled)
                self.btnRightShot.isEnabled = false
                self.btnRightShot.setBackgroundImage(#imageLiteral(resourceName: "next shot"), for: .normal)
            }
            self.trackShotStackView.isHidden = false
            self.shotDetailsStackView.isHidden = true
            self.holeOutStackView.isHidden = true
            var shot = (club: String(), distance: Double(), strokesGained: Double(), swingScore: String(),endingPoint:String(),penalty:Bool())
            if(sender.tag != 44){
                shot = shotsDetail[tagIndex]
                self.shotIndex = tagIndex
            }else{
                shot = currentShotsDetails.first!
            }
            var suffix = "\(Int(shot.distance.rounded())) yd"
            if((shot.distance) < 20.0){
                suffix = "\(Int((shot.distance * 3).rounded())) ft"
            }
            if(distanceFilter == 1){
                suffix = "\((shot.distance/(YARD)).rounded()) m"
            }
            print("ShotIndex  :\(shotIndex)")
            print("Shot  :\(shot)")
            
            self.btnShotDistance.setTitle(suffix, for: .normal)
            self.btnShotDistance.setCorner(color: UIColor.clear.cgColor)
            
            self.btnShotStrokesGained.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 14)
            self.btnShotStrokesGained.setCorner(color: UIColor.clear.cgColor)
            self.btnShotStrokesGained.backgroundColor = UIColor.glfStrokesNbg
            self.btnShotStrokesGained.setTitleColor(UIColor.glfBlack, for: .normal)
            if(shot.strokesGained > 0){
                self.btnShotStrokesGained.backgroundColor = UIColor.glfStrokesPbg
            }
            self.btnShotStrokesGained.setTitle("\(shot.strokesGained.rounded(toPlaces: 2)) S.G", for: .normal)
            self.btnClubName.setTitle(shot.club, for: .normal)
            self.btnClubName.setCorner(color: UIColor.clear.cgColor)
            self.btnShotLandedOn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 12)
            self.btnShotLandedOn.titleLabel?.textColor = UIColor.glfWhite
            self.btnShotLandedOn.layer.cornerRadius = 15
            self.btnInTheHole.frame.size = CGSize(width:80,height:self.btnInTheHole.frame.height)
            self.btnInTheHole.layoutIfNeeded()
            var isGreen = false
            if shot.endingPoint == "G"{
                self.btnShotLandedOn.backgroundColor = UIColor.glfGreen
                self.btnShotLandedOn.setTitle("Green", for: .normal)
                isGreen  = true
            }else if shot.endingPoint == "F" {
                self.btnShotLandedOn.backgroundColor = UIColor.glfFairway
                self.btnShotLandedOn.setTitle("Fairway", for: .normal)
            }else if shot.endingPoint == "GB" || shot.endingPoint == "FB"{
                self.btnShotLandedOn.setTitle("Bunker", for: .normal)
                self.btnShotLandedOn.backgroundColor = UIColor.glfBunker
            }else{
                self.btnShotLandedOn.setTitle("Rough", for: .normal)
                self.btnShotLandedOn.backgroundColor = UIColor.glfRough
            }
            if(!holeOutFlag) && (tagIndex == shotsDetail.count - 1){
                self.btnInTheHole.isHidden = false
                self.btnInTheHole.tag = self.shotIndex
                self.btnInTheHole.layer.cornerRadius = 3
            }
            self.btnShotStrokesGained.layer.cornerRadius = 3

//            (self.btnShotDistance.superview as! UIStackView).insertArrangedSubview(tempBtn, at: (self.btnShotDistance.superview as! UIStackView).arrangedSubviews.count)
            if(isGreen) && !holeOutFlag{
                if(shotsDetail.count-1 == self.shotIndex){
//                    tempBtn.removeFromSuperview()
//                    (self.btnShotDistance.superview as! UIStackView).insertArrangedSubview(tempBtn, at: (self.btnShotDistance.superview as! UIStackView).arrangedSubviews.count-1)
                    self.btnInTheHole.isHidden = false
                    self.currentShotsDetails.removeAll()
                    self.currentShotsDetails.append(shot)
                    self.btnShotStrokesGained.setTitle("\(shot.strokesGained.rounded(toPlaces: 2))", for: .normal)
//                    if UIDevice.current.iPhone5 {
//                        tempBtn.removeFromSuperview()
//                    }
                }
            }else{
                self.btnInTheHole.isHidden = true
            }
            if(sender.tag != 44){
                for data in shotViseCurve{
                    tappedMarker = nil
                    if data.shot == shotIndex{
                        tappedMarker = data.markerPosition
                        break
                    }
                }
            }
            self.btnShotStrokesGained.isHidden = false
            self.btnClubName.isHidden = false
            self.btnShotDistance.isHidden = false
            if(shot.penalty){
                self.btnShotLandedOn.backgroundColor = UIColor.glfRosyPink
                self.btnShotLandedOn.setTitle("Penalty", for: .normal)
//                self.btnShotStrokesGained.isHidden = true
                self.btnShotStrokesGained.backgroundColor = UIColor.clear
                self.btnShotStrokesGained.setTitleColor(UIColor.clear, for: .normal)
                self.btnClubName.isHidden = true
                self.btnShotDistance.isHidden = true
            }
        }
    }
    
    func getClubName(club:String)->String{
        var clubToShow = String()
        let trimmedclub = club.trimmingCharacters(in: .whitespaces)
        
        if(club.count > 0){
            if let fullName = clubsFullForm[trimmedclub]{
                clubToShow =  fullName
            }
            else if let fullName = clubsFullForm["\(club.last!)"]{
                clubToShow =  "\(club.first!) \(fullName)"
            }
        }
        return clubToShow
    }
    
    func updateMapView(holeNumber:Int,isRemove:Bool,isLeftRight:Bool){
        self.lblShotNumber.isHidden = isRemove
        self.newMenuView.isHidden = true
        
        var j = 0
        for player in playersButton{
            self.holeOutforAppsFlyer[j] = self.checkHoleOutZero(playerId: player.id)
            j += 1
        }
        
        
        if(isHoleByHole){
            self.btnEndRoundInBetween.isHidden = true
            self.btnNextHole.isHidden = true
        }
        var ind = 0
        for btn in playersButton{
            if(btn.id == Auth.auth().currentUser?.uid){
                break
            }
            ind += 1
        }
        
        if(self.holeOutforAppsFlyer[ind] == self.scoring.count){
            self.btnNextHole.setTitle("  Finish Round  ", for: .normal)
            self.btnEndRoundInBetween.isHidden = true
        }else{
            self.btnNextHole.setTitle("  Continue  ", for: .normal)
        }
        if(isRemove){
            self.btnReviewHole.setTitle("  Player Stats  ", for: .normal)
        }
        if(holeOutFlag){
            self.btnHoleOutAchieve.isHidden = false
            self.setHoleShotDetails(par: self.scoring[holeNumber].par, shots: shotCount, isStates: false)
        }
        //        self.lblShotNumber.text = "Score \(shotCount!)"
        self.lblShotNumber.isHidden = true
        if(shotCount == 0){
            self.lblShotNumber.text = "Please complete hole to show stats"
        }
        self.lblTitleHolePar.text = "Hole \(holeNumber+1) - par \(self.scoring[holeNumber].par)"
        var tableScoreTuple = [(startingPoint:String,club:String,distance:Double,strokesGained:Double,swingScore:String,endingPoint:String,penalty:Bool)]()
        var strokesGainedHoleWise = [(user:String,strkgnd:Double)]()
        var allPoints = [CLLocationCoordinate2D]()
        self.title = "Hole \(holeNumber+1) - Par \(scoring[holeNumber].par)"
        tableScoreTuple.removeAll()
        var playerIndexs = 0
        for i in 0..<playersButton.count{
            if playersButton[i].isSelected{
                playerIndexs = i
            }
        }
        if playersButton[playerIndexs].id != Auth.auth().currentUser!.uid {
            let name = activePlayerData[playerIndexs].value(forKey:"name") as! String
            let spString = name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            youScoredLbl.text = "\(spString.first!) scored a"
        }else{
            youScoredLbl.text = "You scored a"
        }
        for i in 0..<scoring[holeNumber].players.count{
            if((scoring[holeNumber].players[i]).value(forKey: playersButton[playerIndexs].id) != nil && ((scoring[holeNumber].players[i]).value(forKey: playersButton[playerIndexs].id) as! NSDictionary).count > 2){
                let playerDict = (scoring[holeNumber].players[i]).value(forKey: playersButton[playerIndexs].id) as! NSMutableDictionary
                if let score = playerDict.value(forKey: "shots") as? NSArray {
                    for data in score{
                        let score = data as! NSMutableDictionary
                        let startingPoint = CLLocationCoordinate2D(latitude: score.value(forKey: "lat1") as! CLLocationDegrees, longitude: score.value(forKey: "lng1") as! CLLocationDegrees)
                        allPoints.append(startingPoint)
                        let endingPoint = CLLocationCoordinate2D(latitude: score.value(forKey: "lat2") as! CLLocationDegrees, longitude: score.value(forKey: "lng2") as! CLLocationDegrees)
                        let distance = GMSGeometryDistance(startingPoint, endingPoint)*YARD
                        let started = score.value(forKey: "start") as! String
                        let club = score.value(forKey: "club") as! String
                        var strokGaind = score.value(forKey: strkGainedString[skrokesGainedFilter]) as? Double
                        if(strokGaind == nil){
                            strokGaind = score.value(forKey: strkGainedString[0]) as? Double
                        }
                        let isPenalty = score.value(forKey: "penalty") as! Bool
                        let endingPoints = score.value(forKey: "end") as! String
                        tableScoreTuple.append((startingPoint: started, club: club, distance: distance, strokesGained: strokGaind!, swingScore: "N/A",endingPoint:endingPoints,penalty:isPenalty))
                    }
                }
            }
            for(key,value) in scoring[holeNumber].players[i]{
                if let data = ((value as AnyObject).value(forKey: "strokesGainedOfAllShots") as? Double){
                    strokesGainedHoleWise.append((user: key as! String, strkgnd: data))
                }
            }
        }
        self.updatePlayersShots(tableScoreTuple: tableScoreTuple)
        var barValue = [Double]()
        var urls = [String]()
        if(isShowCase){
            userIdWithImage.append((id: "jpSgWiruZuOnWybYce55YDYGXP62", url: "http://www.golfication.com/assets/DJ%20256PNG.png", name: "Deejay"))
            strokesGainedHoleWise.insert((user: "jpSgWiruZuOnWybYce55YDYGXP62", strkgnd: 1.8),at: 0)
        }
        for i in 0..<strokesGainedHoleWise.count{
            for data in userIdWithImage{
                if(strokesGainedHoleWise[i].user) == data.id {
                    barValue.append(strokesGainedHoleWise[i].strkgnd+3)
                    urls.append(data.url)
                }
            }
        }
        for views in barChartParentStackView.subviews{
            views.removeFromSuperview()
        }
        lblRaceToFlagTitle.isHidden = true
        if(barValue.count > 1){
            lblRaceToFlagTitle.isHidden = false
            for i in 0..<barValue.count{
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.distribution = .fillProportionally
                
                let progressView = UIView()
                progressView.translatesAutoresizingMaskIntoConstraints = false
                progressView.addConstraint(NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: barChartParentStackView.frame.width-30))
                let imgView = UIButton()
                imgView.setBackgroundImage(#imageLiteral(resourceName: "me"), for: .normal)
                if(urls[i].count > 0){
                    imgView.sd_setBackgroundImage(with: URL(string:urls[i]), for: .normal, completed: nil)
                }
                imgView.translatesAutoresizingMaskIntoConstraints = false
                imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
                let newView = UIView(frame: CGRect(x: imgView.frame.maxX, y: 12, width:barChartParentStackView.frame.width-32, height: 6))
                newView.layer.cornerRadius = 2
                newView.backgroundColor = UIColor.glfFlatBlue
                progressView.addSubview(newView)
                imgView.setCircle(frame: imgView.frame)
                
                
                UIView.animate(withDuration: 1.5) {
                    newView.frame.size = CGSize(width: (barValue[i])*Double(self.barChartParentStackView.frame.width-32)/5, height: 6)
                }
                stackView.addArrangedSubview(imgView)
                stackView.addArrangedSubview(progressView)
                self.barChartParentStackView.addArrangedSubview(stackView)
                self.barChartParentStackView.layoutIfNeeded()
                
            }
        }
        self.multiplayerStackView.layoutIfNeeded()
        self.shotParentStackView.layoutIfNeeded()
        self.multiplayerPageControl.layoutIfNeeded()
        self.statesStackView.layoutIfNeeded()
        self.newView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.heightOfNewView.constant = self.statesStackView.frame.height + 32
            self.newView.frame.size = CGSize(width:self.newView.frame.width,height:self.heightOfNewView.constant)
        }
        self.newView.layoutIfNeeded()
        if(selectClubDropper.status != .hidden){
            selectClubDropper.hideWithAnimation(0.1)
        }
        debugPrint(self.newView.frame)
    }
    
    func checkIfMuliplayerJoined(matchID:String){
        var isJoined = false
    
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(self.currentMatchId)/player") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)

            var playerDict = NSMutableDictionary()
            if(snapshot.value != nil){
                print(snapshot.value as! NSMutableDictionary)
                playerDict = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                if(snapshot.value != nil){
                    for (key,value) in playerDict{
                        if(key as! String != Auth.auth().currentUser!.uid){
                            let data = value as! NSMutableDictionary
                            for (k,v) in data{
                                if(k as! String == "status"){
                                    if(v as! Int) > 1{
                                        isJoined =  true
                                        break
                                    }
                                }
                            }
                        }
                    }
                    if(isJoined){
                        self.resetScoreNodeForMe()
                    }else{
                        self.initilizeScoreNode()
                    }
                    self.index = 0
                    self.newView.isHidden = true
                    self.shotsFooterView.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2 , execute: {
                        self.updateCurrentHole(index: self.index+1)
                        self.updateMap(indexToUpdate: self.index)
                        self.progressView.hide(navItem: self.navigationItem)
                    })
                }
            })
        }
    }
    
    func updatePlayersShots(tableScoreTuple:[(startingPoint:String,club:String,distance:Double,strokesGained:Double,swingScore:String,endingPoint:String,penalty:Bool)]){
        var i = 1
        for views in shotParentStackView.subviews{
            views.removeFromSuperview()
        }
        var fontSize:CGFloat = 14.0
        if UIDevice.current.iPhone5 {
            fontSize = 12.0
        }
        
        for data in tableScoreTuple{
            let newStackView = StackView()
            newStackView.backgroundColor = UIColor.glfStackBackColor
            newStackView.axis = .horizontal
            newStackView.alignment = .center
            newStackView.distribution = .fillProportionally
            newStackView.spacing = 8
            newStackView.layer.cornerRadius = 5
            
            let btn1 = UIButton()
            btn1.translatesAutoresizingMaskIntoConstraints = false
            btn1.addConstraint(NSLayoutConstraint(item: btn1, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
            btn1.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            btn1.setTitle("\(i)", for: .normal)
            btn1.backgroundColor = UIColor.glfBluegreen
            btn1.layer.cornerRadius = 5
            
            let btn2 = UIButton()
            btn2.translatesAutoresizingMaskIntoConstraints = false
            btn2.addConstraint(NSLayoutConstraint(item: btn2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
            btn2.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            btn2.setImage(#imageLiteral(resourceName: "club_1"), for: .normal)
            btn2.imageEdgeInsets.right = 4
            btn2.setTitleColor(UIColor.glfBlack, for: .normal)
            btn2.isUserInteractionEnabled = false
            btn2.setTitle(data.club, for: .normal)
            
            let btn3 = UIButton()
            btn3.translatesAutoresizingMaskIntoConstraints = false
            btn3.addConstraint(NSLayoutConstraint(item: btn3, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 55))
            btn3.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            btn3.setTitleColor(UIColor.glfWhite, for: .normal)
            if data.endingPoint == "G"{
                btn3.backgroundColor = UIColor.glfGreen
                btn3.setTitle("Green", for: .normal)
                
            }else if data.endingPoint == "F" {
                btn3.backgroundColor = UIColor.glfFairway
                btn3.setTitle("Fairway", for: .normal)
            }else if data.endingPoint == "GB" || data.endingPoint == "FB"{
                btn3.setTitle("Bunker", for: .normal)
                btn3.backgroundColor = UIColor.glfBunker
            }
            else{
                btn3.setTitle("Rough", for: .normal)
                btn3.backgroundColor = UIColor.glfRough
            }
            
            btn3.layer.cornerRadius = 15
            btn3.titleEdgeInsets.left = 2
            btn3.titleEdgeInsets.right = 2
            let btn4 = UIButton()
            btn4.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            //            var suffix = "\(data.distance) yd"
            
            var distanceInYrd = data.distance
            var suffix = "yd"
            if(distanceFilter == 1){
                distanceInYrd = data.distance/YARD
                suffix = "m"
            }
            if(data.startingPoint == "G" && data.endingPoint == "G"){
                distanceInYrd = 3 * distanceInYrd
                suffix = "ft"
                if(distanceFilter == 1){
                    distanceInYrd = data.distance/(YARD)
                    suffix = "m"
                }
            }
            
            btn4.setTitle("\(Int(distanceInYrd.rounded())) \(suffix)", for: .normal)
            btn4.setTitleColor(UIColor.glfBlack, for: .normal)
            
            let btn5 = UIButton()
            btn5.translatesAutoresizingMaskIntoConstraints = false
            btn5.addConstraint(NSLayoutConstraint(item: btn5, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:80))
            btn5.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            btn5.backgroundColor = UIColor.glfStrokesNbg
            btn5.setTitleColor(UIColor.glfStrokesNtc, for: .normal)
            if(data.strokesGained > 0){
                btn5.backgroundColor = UIColor.glfStrokesPbg
                btn5.setTitleColor(UIColor.glfStrokesPtc, for: .normal)
                
            }
            btn5.setTitle("\(data.strokesGained.rounded(toPlaces: 2)) S.G", for: .normal)
            btn5.layer.cornerRadius = 5
            btn5.sizeToFit()
            btn5.titleEdgeInsets.left = 2
            btn5.titleEdgeInsets.right = 2
            
            let btn6 = UIButton()
            btn6.translatesAutoresizingMaskIntoConstraints = false
            btn6.addConstraint(NSLayoutConstraint(item: btn6, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:30))
            btn6.setImage(#imageLiteral(resourceName: "menu_black"), for: .normal)
            btn6.tag = i
            btn6.addTarget(self, action: #selector(self.btnActionShotMenu(_:)), for: .touchUpInside)

            let btn7 = UIButton()
            btn7.setTitle("Penalty", for: .normal)
            btn7.backgroundColor = UIColor.glfRosyPink
            btn7.titleLabel?.textColor = UIColor.glfWhite
            btn7.layer.cornerRadius = 15
            btn7.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: fontSize)
            btn7.isHidden = true
            btn2.isHidden = false
            btn4.isHidden = false
            if (self.penaltyShots.count > i) && (self.penaltyShots[i-1]){
                btn2.isHidden = true
                btn4.isHidden = true
                btn7.isHidden = false
                btn3.setTitle("-", for: .normal)
                btn5.setTitle("-", for: .normal)

            }

            newStackView.addArrangedSubview(btn1)
            newStackView.addArrangedSubview(btn7)
            newStackView.addArrangedSubview(btn2)
            newStackView.addArrangedSubview(btn4)
            newStackView.addArrangedSubview(btn3)
            newStackView.addArrangedSubview(btn5)
            newStackView.addArrangedSubview(btn6)
            i = i+1
            newStackView.roundCorners([UIRectCorner.allCorners], radius: 3)
            self.shotParentStackView.addArrangedSubview(newStackView)
        }
        self.shotsParentHeight.constant = CGFloat(33*i)
        self.shotParentStackView.layoutIfNeeded()
    }
    
    func setHoleShotDetails(par:Int,shots:Int,isStates:Bool?){
        var holeFinishStatus = String()
        var color = UIColor()
        switch shots-par{
        case -1:
            holeFinishStatus = "  Birdie  "
            color = UIColor.glfFlatBlue
            break
        case -2:
            holeFinishStatus = "  Eagle  "
            color = UIColor.glfFlatBlue
            break
        case -3:
            holeFinishStatus = "  Albatross  "
            color = UIColor.glfFlatBlue
            break
        case 1:
            holeFinishStatus = "  Bogey  "
            color = UIColor.glfWarmGrey
            break
        case 2:
            holeFinishStatus = "  D. Bogey  "
            color = UIColor.glfWarmGrey
            break
        case 0:
            holeFinishStatus = "  Par  "
            color = UIColor.glfFlatBlue
            break
        default:
            holeFinishStatus = ""
            color = UIColor.glfRosyPink
        }
        
        let button = UIButton()
        button.setTitleColor(UIColor.glfWhite, for: .normal)
        button.setTitle(holeFinishStatus.uppercased(), for: .normal)
        button.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 14)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.tag = 2233
        
        self.btnHoleOutAchieve.setTitleColor(UIColor.glfWhite, for: .normal)
        self.btnHoleOutAchieve.setTitle(holeFinishStatus.uppercased(), for: .normal)
        self.btnHoleOutAchieve.backgroundColor = color
        self.btnHoleOutAchieve.layer.cornerRadius = 10
        if isStates! && holeFinishStatus.count > 0{
            btnHoleOutAchieve.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 12)
            holeOutStackView.addArrangedSubview(button)
            
        }else{
            button.superview?.isHidden = false
        }
    }
    
    // --------------------------- Check If User has not played game at all ------------------------
    func checkHoleOutZero(playerId:String) -> Int{
        var myVal: Int = 0
        for i in 0..<self.scoring.count{
            for dataDict in self.scoring[i].players{
                for (key,value) in dataDict{
                    if let dic = value as? NSDictionary{
                        if dic.value(forKey: "holeOut") as! Bool == true{
                            if(key as? String == playerId){
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
        }
        return myVal
    }
    
    func  clubReco(dist:Double,lie:String)->String {
        if (lie.trim() == "G"){
            return " Pu";
        }else {
            var index = 0
            var i2 = 0
            var minX = 1000000.0
            var preferredClubs = [String]()
            for i in 0..<self.clubData.count {
                if (!clubs.contains(self.clubData[i].name)){ continue}
                if (self.clubData[i].name == "Pu"){continue}
                if (self.clubData[i].name == "Dr") &&
                    (lie != "T"){continue}
                let max = Double(self.clubData[i].max)
                let min = Double(self.clubData[i].min)
                var x = 0.0
                if (dist >= max) {
                    x = dist - max;
                    preferredClubs.append(" \(self.clubData[i].name)")
                } else if (dist <= min) {
                    x = min - dist;
                    preferredClubs.append(" \(self.clubData[i].name)")
                } else if (dist >= min && dist <= max) {
                    preferredClubs.append(" \(self.clubData[i].name)")
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
            ]
        let dict2:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 15)!,
            ]
        if(!holeOutFlag){
            if(BackgroundMapStats.findPositionOfPointInside(position: position.first!, whichFeature:self.numberOfHoles[index].green)){
                let distance = GMSGeometryDistance(position.first!, position.last!) * YARD * 3
                markerText = "  \(Int(distance)) ft "
                if(distanceFilter == 1){
                    let distance = GMSGeometryDistance(position.first!, position.last!)
                    markerText = "  \(Int(distance)) m "
                }
                markerClub = clubReco(dist: distance, lie: "G")
                if (distance/3 < 100) {
                    let indexPath = IndexPath(row: self.clubs.index(of: markerClub.trim())!, section: 0)
                    self.btnSelectClub.setTitle(markerClub, for: .normal)
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText, for: .normal)
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position[0], distance/(6*YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = self.mapView
                }
            }else{
                let distance = GMSGeometryDistance(position.first!, position.last!) * YARD
                if(distance > 100){
                    let dist1 = GMSGeometryDistance(position.first!, position[1]) * YARD
                    let dist = GMSGeometryDistance(position[1], position.last!) * YARD
                    
                    markerText1 = "  \(Int(dist1)) yd "
                    markerText = "  \(Int(dist)) yd "
                    if(distanceFilter == 1){
                        markerText = "  \(Int(dist/(YARD))) m "
                        markerText1 = "  \(Int(dist1/(YARD))) m "
                    }
                    let lie = callFindPositionInsideFeature(position: position[1])
                    if(self.shotCount != 0){
                        markerClub1 = clubReco(dist: dist1, lie: "O")
                        markerClub = clubReco(dist: dist, lie: lie)
                    }else{
                        markerClub1 = clubReco(dist: dist1, lie: "T")
                        markerClub = clubReco(dist: dist, lie: lie)
                    }
                    if(dist > 250){
                        markerClub = " - "
                    }else if (dist < 250 && dist > 225){
                        markerClub = "  3w"
                    }
                    self.btnSelectClub.setTitle(markerClub1, for: .normal)
                    let indexPath = IndexPath(row: self.clubs.index(of: markerClub1.trim())!, section: 0)
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    
                    let attributedText1 = NSMutableAttributedString()
                    attributedText1.append(NSAttributedString(string: markerClub1, attributes: dict1))
                    attributedText1.append(NSAttributedString(string: markerText1, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText1, for: .normal)
//                    debugPrint("str2: \(attributedText1.string)")
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position.first!, dist1/(2*YARD), GMSGeometryHeading(position.first!, position[1]))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = self.mapView
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark2.setAttributedTitle(attributedText, for: .normal)
                    
//                    debugPrint("str1: \(attributedText.string)")
                    suggestedMarker2.iconView = btnForSuggMark2
                    suggestedMarker2.position = GMSGeometryOffset(position[1], dist/(2*YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker2.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker2.map = self.mapView
                }else{
                    let distance = GMSGeometryDistance(position[0], position.last!) * YARD
                    markerText = " \(Int(distance.rounded())) yd"
                    if(distanceFilter == 1){
                        markerText = " \(Int((distance/YARD).rounded())) m"
                    }
                    if(self.shotCount != 0){
                        markerClub = " \(clubReco(dist: distance, lie: "O"))"
                    }else{
                        markerClub = clubReco(dist: distance, lie: "T")
                    }
                    self.btnSelectClub.setTitle(markerClub, for: .normal)
                    let indexPath = IndexPath(row: self.clubs.index(of: markerClub.trim())!, section: 0)
                    self.selectClubDropper.TableMenu.delegate?.tableView!(self.selectClubDropper.TableMenu, didSelectRowAt: indexPath)
                    
                    let attributedText = NSMutableAttributedString()
                    attributedText.append(NSAttributedString(string: markerClub, attributes: dict1))
                    attributedText.append(NSAttributedString(string: markerText, attributes: dict2))
                    btnForSuggMark1.setAttributedTitle(attributedText, for: .normal)
                    suggestedMarker1.iconView = btnForSuggMark1
                    suggestedMarker1.position = GMSGeometryOffset(position[0], distance/(2*YARD), GMSGeometryHeading(position[1], position.last!))
                    suggestedMarker1.groundAnchor = CGPoint(x:-0.02,y:0.5)
                    suggestedMarker1.map = self.mapView
//                    debugPrint("str1: \(attributedText.string)")
                    
                }
            }
        }
    }

    @objc func markerAction(_ sender:UIButton){
        debugPrint(sender.tag)
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
    
    //----------------------------------Draw Polygon------------------------------//
    
    func drawPolygonWithStrokesColor(polygonArray:[CLLocationCoordinate2D],color:UIColor){
        let path = GMSMutablePath()
        let newPath = GMSMutablePath()
        for i in 0..<polygonArray.count-1{
            let coord = getNewCurvedCoordinates(latLng1: polygonArray[i],latLng2: polygonArray[i+1])
            for latlng in coord{
                path.add(latlng)
            }
        }
        for position in polygonArray{
            newPath.add(position)
        }
        let polygon = GMSPolyline(path: path)
        polygon.strokeWidth = 2
        polygon.geodesic = true
//        let lengths:[NSNumber] = [1,0.5]
//        let styles = [GMSStrokeStyle.solidColor(color), GMSStrokeStyle.solidColor(UIColor.clear)]
//        polygon.spans = GMSStyleSpans(polygon.path!,styles , lengths as [NSNumber], GMSLengthKind(rawValue: 1)!)
        polygon.strokeColor = color
        polygon.map = mapView
        let newLine = GMSPolyline(path:newPath)
        newLine.strokeWidth = 0.5
        newLine.strokeColor = UIColor.glfRosyPink
        polygon.map = mapView

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
    }
    
    func updateStateWhileDragging(marker:GMSMarker){
        var playerIndex : Int!
        var playerId : String!
        for players in playersButton{
            if(players.isSelected){
                playerId = players.id
                for i in 0..<self.scoring[index].players.count{
                    if((self.scoring[index].players[i].value(forKey: playerId)) != nil){
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
            else if(marker.userData as! Int == shotCount!){
                for i in 1..<markersForCurved.count{
                    uploadStatsWithDragging(shot: markersForCurved[i].userData as! Int, playerId: playerId, playerIndex: playerIndex)
                }
            }
            else{
                uploadStatsWithDragging(shot: marker.userData as! Int, playerId: playerId, playerIndex: playerIndex)
                uploadStatsWithDragging(shot: marker.userData as! Int + 1, playerId: playerId, playerIndex: playerIndex)
            }
        }else if(marker.title == "PointWithCurved"){
            uploadStatsWithDragging(shot: marker.userData as! Int + 1, playerId: playerId, playerIndex: playerIndex)
        }
        getScoreFromMatchDataFirebase(keyId:self.currentMatchId , hole: index, playerId: playerId,playerIndex: playerIndex)
    }
    
    
    
    func uploadStatsWithDragging(shot:Int,playerId:String,playerIndex:Int){
        let girDict = NSMutableDictionary()
        let faiDict = NSMutableDictionary()
        var shotDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
        if(!isDraggingMarker){
            shotDetails = self.getShotDataOrdered(indexToUpdate: self.index)
        }

        if(shot==1) && (positionsOfCurveLines.count > 1){
            gir = false
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotDetails.count > shot-1{
                gir = shotDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
            faiDict.setObject(fairwayDetailsForFirstShot(shot:shot), forKey: "fairway" as NSCopying)
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(faiDict as! [AnyHashable : Any])
            let drivDistDict = NSMutableDictionary()
            if(self.scoring[index].par>3){
                let drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*YARD
                drivDistDict.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
            }
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(drivDistDict as! [AnyHashable : Any])
            
        }
        else if(shot == 2)&&(!gir)&&(self.scoring[index].par>3){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotDetails.count > shot-1{
                gir = shotDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        else if(shot == 3)&&(!gir)&&(self.scoring[index].par>4){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
            if(!isDraggingMarker) && shotDetails.count > shot-1{
                gir = shotDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        if(holeOutFlag) && shot == self.shotCount{
            uploadChipUpNDown(playerId: playerId)
            uploadSandUpNDown(playerId: playerId)
            uploadPutting(playerId: playerId)
        }
        
        uploadApproachAndApproachShots(playerId: playerId)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(girDict as! [AnyHashable : Any])
        let shotsDict = self.scoring[index].players[playerIndex].value(forKey: playerId) as! NSMutableDictionary
        if var shotsValue = shotsDict.value(forKey: "shots") as? [NSMutableDictionary]{
            if(shot-1 < shotsValue.count){
                let clubValue = shotsValue[shot-1].value(forKey: "club") as! String
                let isPenaltyShot = shotsValue[shot-1].value(forKey: "penalty") as! Bool
                shotsValue[shot-1] = getShotDetails(shot:shot,club:clubValue,isPenalty: isPenaltyShot)
                if(!isDraggingMarker) && shotDetails.count > shot-1{
                    shotsValue[shot-1] = self.reCalculateStats(shot: shot, club: shotDetails[shot-1].club, isPenalty: shotDetails[shot-1].penalty, end: shotDetails[shot-1].endingPoint, start: shotDetails[shot-1].swingScore)
                }
                shotsDict.setValue(shotsValue, forKey: "shots")
                //        print(shotsDict)
                self.scoring[index].players[playerIndex].setValue(shotsDict, forKey: playerId)
                
                ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/shots/\(shot-1)").updateChildValues(shotsValue[shot-1] as! [AnyHashable : Any])
            }
        }
    }
    func uploadApproachAndApproachShots(playerId:String){
        approachDistance = 0.0
        let appDistDict = NSMutableDictionary()
        for i in 0..<positionsOfCurveLines.count{
            approachDistance = GMSGeometryDistance(positionsOfCurveLines[i],self.centerPointOfTeeNGreen[index].green)*YARD
            if(approachDistance<200 && approachDistance != 0){
                appDistDict.setObject(approachDistance.rounded(toPlaces: 2), forKey: "approachDistance" as NSCopying)
                break
            }
            else{
                appDistDict.setObject("N/A", forKey: "approachDistance" as NSCopying)
            }
            
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(appDistDict as! [AnyHashable : Any])
    }
    func uploadSandUpNDown(playerId : String){
        var appDistance = Double()
        var sandUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], numberOfHoles[index].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: numberOfHoles[index].green)])*YARD
            if(appDistance<50){
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
            ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(playerId)/sandUpDown").setValue(sandUpDown)
        }
        else{
            if(sandUpDown != nil){
                playerArrayWithDetails.setObject(sandUpDown, forKey: "sandUpDown" as NSCopying)
            }
        }
        
    }
    func uploadPutting(playerId:String){
        var putting = Int()
        for i in 0..<self.scoring[index].players.count where self.scoring[index].players[i].value(forKey: playerId) != nil{
            if let scoringDict = (self.scoring[index].players[i].value(forKey: playerId) as? NSMutableDictionary){
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
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/putting").setValue(putting)
    }
    
    func uploadChipUpNDown(playerId : String){
        var appDistance = Double()
        var chipUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], numberOfHoles[index].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: numberOfHoles[index].green)])*YARD
            if(appDistance<50){
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
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/chipUpDown").setValue(chipUpDown)
        }
        else{
            if(chipUpDown != nil){
                playerArrayWithDetails.setObject(chipUpDown, forKey: "chipUpDown" as NSCopying)
            }
        }
    }
    
    func uploadTotalStrokesGained(playerId : String){
        for i in 0..<self.scoring[index].players.count{
            var strokesGainedDistance = Double()
            if let playerDict = self.scoring[index].players[i].value(forKey: playerId) as? NSMutableDictionary{
                if let scoreArray = playerDict.value(forKey: "shots") as? [NSMutableDictionary]{
                    for i in 0..<scoreArray.count{
                        if let sg = scoreArray[i].value(forKey: "strokesGained") as? Double{
                            strokesGainedDistance += sg
                        }
                    }
                    playerArrayWithDetails.setObject(strokesGainedDistance, forKey: "strokesGainedOfAllShots" as NSCopying)
                    ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(["strokesGainedOfAllShots":strokesGainedDistance] as [AnyHashable : Any])
                }
                
            }
        }
    }
    
    func getScoreFromMatchDataFirebase(keyId:String,hole:Int,playerId:String,playerIndex:Int){
        ref.child("matchData/\(keyId)/scoring/\(hole)/\(playerId)").observeSingleEvent(of: .value, with: { (snapshot) in
            let playerDict = NSMutableDictionary()
            if let dict = snapshot.value as? NSMutableDictionary{
                playerDict.setObject(dict, forKey: playerId as NSCopying)
                self.scoring[self.index].players[playerIndex] = playerDict
                if(self.holeOutFlag){
                    self.uploadPutting(playerId: playerId)
                }
            }
            self.uploadTotalStrokesGained(playerId: playerId)
        })
        { (error) in
        }
    }
    
    func getGolfBagData(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            if(snapshot.value != nil){
                let golfBagArray = snapshot.value as! NSMutableArray
                if golfBagArray.count > 0{
                    self.clubs.removeAll()
                    
                    for i in 0..<golfBagArray.count{
                        if let dict = golfBagArray[i] as? NSDictionary{
                            self.clubs.append((dict.value(forKey: "clubName") as! String))
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
                                golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                                golfBagArray.replaceObject(at: i, with: golfBagDict)
                                golfBagData = ["golfBag": golfBagArray]
                                
                                self.clubs.append(tempArray[i] as! String)
                            }
                            if golfBagData.count>0{
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            }
                            break
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.clubs.append("Pu")
                self.clubs.append("More")
                self.clubs = self.clubs.removeDuplicates()
                self.updateMaxMin()
                self.getGolfCourseDataFromFirebase()
            })
        }
    }
    
    func updateMaxMin(){
        self.clubData.removeAll()
        for data in clubWithMaxMin{
            if clubs.contains(data.name){
                self.clubData.append((name: data.name, max: data.max, min: data.min))
            }
        }
        self.clubData.sort{($0).max > ($1).max}
        for i in 0..<clubData.count-1{
            if !(clubData[i].min == clubData[i+1].max+1) && (clubData[i].min>clubWithMaxMin[i+1].max+1){
                let diff = clubData[i].min - clubData[i+1].max+1
                clubData[i].max += diff/2
                clubData[i+1].min -= diff/2
                if(clubData[i+1].min < 0){
                    clubData[i+1].min = 0
                }
            }
        }
        debugPrint("clubs \(clubData)")
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
                self.getGolfBagData()
            })
        }
    }
    
    func uploadStats(shot:Int,clubName:String){
        isDraggingMarker = false
        var playerId :String!
        playerArrayWithDetails = NSMutableDictionary()
        for data in scoring[self.index].players{
            if let shotsDetails = data.value(forKey: self.selectedUserId) as? NSMutableDictionary{
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
                    if(self.scoring[index].par>3){
                        drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*YARD
                        playerArrayWithDetails.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
                    }
                    //                    else{
                    //                        playerArrayWithDetails.setObject(drivingDistance, forKey: "drivingDistance" as NSCopying)
                    //                    }
                    if(self.scoring[index].par > 3){
                        fairwayHitMisDistance(shot:shot)
                    }
                    if(!holeOutFlag){
                        playerArrayWithDetails.setObject(fairwayDetailsForFirstShot(shot:shot), forKey: "fairway" as NSCopying)
                    }
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                if(shot == 2)&&(!gir)&&(self.scoring[index].par>3) && positionsOfCurveLines.count > shot{
                    
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                if(shot == 3)&&(!gir)&&(self.scoring[index].par>4) && positionsOfCurveLines.count > shot{
                    gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot]) == "G" ? true:false
                }
                uploadApproachAndApproachShots(playerId: playerId)
                
                //                var playerIndex = Int()
                playerArrayWithDetails.setObject(holeOutFlag, forKey: "holeOut" as NSCopying)
                playerArrayWithDetails.setObject(gir, forKey: "gir" as NSCopying)
                playerShotsArray.append(getShotDetails(shot:shot,club:clubName, isPenalty: false))
                playerArrayWithDetails.setObject(playerShotsArray, forKey: "shots" as NSCopying)
                for i in 0..<self.scoring[index].players.count{
                    if(self.scoring[index].players[i].value(forKey: playerId) != nil){
                        playerIndex = i
                        break;
                    }
                }
                if(holeOutFlag){
                    uploadChipUpNDown(playerId: playerId)
                    uploadSandUpNDown(playerId: playerId)
                    uploadPutting(playerId: playerId)
                }
                Notification.sendLocaNotificatonToUser()
                ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId!)/").updateChildValues(playerArrayWithDetails as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    self.isProcessing = false
                    self.getScoreFromMatchDataFirebases()
                })
            }
        }
    }
    
    func fairwayHitMisDistance(shot:Int){
        if(fairwayDetailsForFirstShot(shot:shot) == "H"){
            let coord = positionsOfCurveLines[shot]
            var fairwayCoord = [CLLocationCoordinate2D]()
            for data in self.numberOfHoles[index].fairway{
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
    
    func getShotDetails(shot:Int,club:String,isPenalty:Bool)->NSMutableDictionary{
        currentShotsDetails.removeAll()
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        var start = String()
        var end = String()
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        if(club == ""){
            shotDictionary.setObject((self.btnSelectClub.currentTitle!).trim(), forKey: "club" as NSCopying)
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
        }
        if(!isDraggingMarker){
            //            if(holeOutFlag){
            //                shotDictionary.setObject("G", forKey: "end" as NSCopying)
            //                end = "G"
            //            }
            //            else{
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot]), forKey: "end" as NSCopying)
            end = callFindPositionInsideFeature(position:positionsOfCurveLines[shot])
            //            }
        }
        else{
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot]), forKey: "end" as NSCopying)
            end = callFindPositionInsideFeature(position:positionsOfCurveLines[shot])
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
        shotDictionary.setObject((distanceBwShots*YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*YARD).rounded()))"
        }
        if(Int((distanceBwHole0*YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*YARD).rounded()) < 100) && shotCount == 0{
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
        for i in 0..<strkGainedString.count{
            var strkG = calculateStrokesGained(start:start,end:end,filterIndex:i)
            strkG = strkG - Double(numberOfPenalty)
            shotDictionary.setObject(strkG, forKey: strkGainedString[i] as NSCopying)
        }
        
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot]), forKey: "heading" as NSCopying)
        currentShotsDetails.append((club: shotDictionary.value(forKey: "club") as! String, distance: shotDictionary.value(forKey: "distance") as! Double, strokesGained: shotDictionary.value(forKey: "strokesGained") as! Double, swingScore: "N/A", endingPoint: shotDictionary.value(forKey: "end") as! String,penalty:isPenalty))
        return shotDictionary
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
    private func reCalculateStats(shot:Int,club:String,isPenalty:Bool,end:String,start:String)->NSMutableDictionary{
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        if(club == ""){
            shotDictionary.setObject(self.btnSelectClub.currentTitle!, forKey: "club" as NSCopying)
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
        if(distanceBwHole1 == 0) && positionsOfDotLine.count>0{
            distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
        }
        shotDictionary.setObject((distanceBwShots*YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*YARD).rounded()))"
        }
        if(Int((distanceBwHole0*YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*YARD).rounded()) < 100) && shot == 0{
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

        for i in 0..<strkGainedString.count{
            var strkG = calculateStrokesGained(start:start,end:end,filterIndex:i)
            strkG = strkG - Double(numberOfPenalty)
            shotDictionary.setObject(strkG, forKey: strkGainedString[i] as NSCopying)
        }
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot]), forKey: "heading" as NSCopying)
        return shotDictionary
    }

    func calculateStrokesGained(start:String,end:String,filterIndex:Int)->Double{
        var strkGnd = Double()
        var startGained = Double()
        var endGained = Double()
        
        if(strokesGainedDict[filterIndex].value(forKey: start) != nil){
            startGained = strokesGainedDict[filterIndex].value(forKey: start) as! Double
        }
        if(strokesGainedDict[filterIndex].value(forKey: end) != nil){
            endGained = strokesGainedDict[filterIndex].value(forKey: end) as! Double
        }
        
        strkGnd = startGained - endGained - 1
        return strkGnd
    }
    
    func isFairwayHitOrMiss(position:CLLocationCoordinate2D)->String{
        var fairwayDetails = ""
        var headingAngleOfTeeToGreen = 0.0
        if(holeOutFlag){
            headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfCurveLines.last!)
        }
        else{
            if(positionsOfDotLine.count != 0){
                if(positionsOfCurveLines.count == 0){
                    headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfDotLine.first!, positionsOfDotLine.last!)
                }else{
                    headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfDotLine.last!)
                }
            }
            else{
                headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfCurveLines[1])
            }
        }
        var headingAngleOfTeeToFairway = 0.0
        if(positionsOfCurveLines.count == 0){
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
    
    func callFindPositionInsideFeature(position:CLLocationCoordinate2D)->String{
        var featureName = "R"
        for data in self.numberOfHoles[index].fairway{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "F"
                break
            }
        }
        for data in self.numberOfHoles[index].gb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "GB"
                break
            }
        }
        for data in self.numberOfHoles[index].fb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "FB"
                break
            }
        }
        for data in self.numberOfHoles[index].wh{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "WH"
                break
            }
        }
        for data in self.numberOfHoles[index].tee{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "T"
                break
            }
        }
        if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature:self.numberOfHoles[index].green)){
            featureName = "G"
        }
        return featureName
    }
}

extension MapViewController{
    func setUpPlayerButton(totalPlayers:Int){
        playersButton.removeAll()
        var namesOfPlayers = [String]()
        for i in 0..<totalPlayers{
            playersButton.append((button: UIButton(), isSelected: false,id:activePlayerData[i].value(forKey:"id") as! String))
            self.userIdWithImage.append((id: activePlayerData[i].value(forKey:"id") as! String, url: activePlayerData[i].value(forKey: "image") as! String,name:activePlayerData[i].value(forKey:"name") as! String))
            namesOfPlayers.append(activePlayerData[i].value(forKey:"name") as! String)
            holeOutforAppsFlyer.append(0)
        }
        userId = Auth.auth().currentUser!.uid
        var padding:CGFloat = 0.0
        var selectedIndex : Int!
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        for i in 0..<playersButton.count{
            padding += 50
            let frame = CGRect(x:self.view.frame.size.width-60, y:self.view.frame.size.height-150-padding, width: 40, height: 40)
            let btn: UIButton = UIButton(frame: frame)
            let newBtn = UIButton(frame: CGRect(x:0,y:0,width:40,height:40))
            btn.setCircle(frame: frame)
            newBtn.setCircle(frame:newBtn.frame)
            newBtn.setTitleColor(UIColor.glfWhite, for: .normal)
            newBtn.backgroundColor = UIColor.glfFlatBlue75
            btn.backgroundColor = UIColor.glfFlatBlue75
            if let url = activePlayerData[i].value(forKey: "image") as? String{
                if(url.count > 2){
                    btn.sd_setImage(with: URL(string:url), for: .normal, completed:nil)
                    newBtn.sd_setImage(with: URL(string:url), for: .normal, completed:nil)
                }else{
                    btn.setTitle("\(namesOfPlayers[i].first!)", for: .normal)
                    newBtn.setTitle("\(namesOfPlayers[i].first!)", for: .normal)
                }
            }
            btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            newBtn.contentMode = .scaleAspectFit
            newBtn.tag = i
            newBtn.translatesAutoresizingMaskIntoConstraints = false
            newBtn.addConstraint(NSLayoutConstraint(item: newBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
            newBtn.addConstraint(NSLayoutConstraint(item: newBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
            stackView.insertArrangedSubview(newBtn, at: i)
            
            newBtn.addTarget(self, action: #selector(newButtonAction), for: .touchUpInside)
            
            
            btn.contentMode = .scaleAspectFit
            btn.tag = i
            playersButton[i].button = btn
            
            playersButton[i].isSelected = false
            if(activePlayerData[i].value(forKey: "id") as! String == userId){
                let frame = CGRect(x:self.view.frame.size.width-60, y:self.view.frame.size.height-150-padding, width: 50, height: 50)
                btn.frame = frame
                btn.setCircle(frame: frame)
                playersButton[i].button = btn
                playersButton[i].isSelected = true
                selectedUserId = playersButton[i].id
                selectedIndex = i
                newBtn.setCornerWithCircle(color: UIColor.glfDarkGreen.cgColor)
            }
            if(playersButton.count == 1){
                btn.isHidden = true
            }
        }
        self.multiplayerStackView.insertArrangedSubview(stackView, at: 1)
        if(totalPlayers > 1){
            self.multiplayerStackView.isHidden = false
            self.multiplayerPageControl.isHidden = false
            self.multiplayerPageControl.numberOfPages = totalPlayers
            self.multiplayerPageControl.currentPage = selectedIndex
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let sizeForSelected = CGSize(width: sender.frame.size.width+10.0, height: sender.frame.size.height+10.0)
        for i in 0..<playersButton.count{
            let sizeForDeselected = CGSize(width: playersButton[i].button.frame.size.width-10.0, height: playersButton[i].button.frame.size.height-10.0)
            if(i == sender.tag){
                if(!playersButton[i].isSelected){
                    playersButton[i].button.setCircle(frame:CGRect(origin: sender.frame.origin, size: sizeForSelected))
                    playersButton[i].isSelected = true
                    selectedUserId = playersButton[i].id
                }
            }
            else{
                if(playersButton[i].isSelected){
                    playersButton[i].button.setCircle(frame: CGRect(origin: playersButton[i].button.frame.origin, size: sizeForDeselected))
                }
                playersButton[i].isSelected = false
            }
        }
        
        for i in 0..<playersButton.count{
            if(playersButton[i].isSelected){
                self.playerIndex = i
                updateMap(indexToUpdate: index)
            }
        }
    }
    
    @objc func newButtonAction(sender:UIButton){
        if(!isHoleByHole){
            self.shotsFooterView.isHidden = true
        }
        let currentIndex = self.multiplayerPageControl.currentPage
        if(currentIndex > sender.tag){
            for _ in 0..<currentIndex-sender.tag{
                self.leftSwipeAction(tag: self.multiplayerPageControl.currentPage-1)
                self.multiplayerPageControl.currentPage -= 1
            }
        }else{
            for _ in 0..<sender.tag-currentIndex{
                self.rightSwipeAction(tag: self.multiplayerPageControl.currentPage+1)
                self.multiplayerPageControl.currentPage += 1
            }
        }
    }
    
    func leftSwipeAction(tag:Int){
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.shotParentStackView.frame = self.shotParentStackView.frame.offsetBy(dx: -self.view.frame.width, dy: 0)
        }
        animator.startAnimation()
        self.updateMapView(holeNumber: self.index, isRemove: false, isLeftRight: true)
        for vi in self.multiplayerStackView.arrangedSubviews{
            if(vi.isKind(of: UIStackView.self)){
                for btn in (vi as! UIStackView).arrangedSubviews{
                    if(btn.isKind(of: UIButton.self)){
                        (btn as! UIButton).setCornerWithCircle(color: UIColor.clear.cgColor)
                        if btn.tag == tag{
                            (btn as! UIButton).setCornerWithCircle(color: UIColor.glfDarkGreen.cgColor)
                        }
                    }
                }
            }
        }
    }
    func rightSwipeAction(tag:Int){
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.shotParentStackView.frame = self.shotParentStackView.frame.offsetBy(dx: self.view.frame.width, dy: 0)
        }
        animator.startAnimation()
        self.updateMapView(holeNumber: self.index, isRemove: false, isLeftRight: true)
        for vi in self.multiplayerStackView.arrangedSubviews{
            if(vi.isKind(of: UIStackView.self)){
                for btn in (vi as! UIStackView).arrangedSubviews{
                    if(btn.isKind(of: UIButton.self)){
                        (btn as! UIButton).setCornerWithCircle(color: UIColor.clear.cgColor)
                        if btn.tag == tag{
                            (btn as! UIButton).setCornerWithCircle(color: UIColor.glfDarkGreen.cgColor)
                        }
                    }
                }
            }
        }
    }
}
extension CALayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }
}
extension MapViewController{
    //-----------------------SetLeftRightButtonWithFunctionality------------------//
    func setLeftRightButtonView(){
        btnLeft.addTarget(self, action: #selector(MapViewController.previousAction(_:)), for: .touchUpInside)
        btnLeftFooter.addTarget(self, action: #selector(MapViewController.previousAction(_:)), for: .touchUpInside)
        btnRight.addTarget(self, action: #selector(MapViewController.nextAction(_:)), for: .touchUpInside)
        self.btnNextHole.addTarget(self, action: #selector(MapViewController.nextAction(_:)), for: .touchUpInside)
        btnRightFooter.addTarget(self, action: #selector(MapViewController.nextAction(_:)), for: .touchUpInside)
    }
    
    func updateCurrentHole(index: Int){
        self.currentHole = index
        self.stackViewForEditShots.isHidden = true
        if(shotCount > 0) && !(self.newView.isHidden){
            self.updateMapView(holeNumber: index-1,isRemove:false, isLeftRight: false)
        }else{
            self.newView.isHidden = true
            self.statesStackView.isHidden = true
            self.shotsFooterView.isHidden = false
        }
        let currentHoleWhilePlaying = NSMutableDictionary()
        currentHoleWhilePlaying.setObject("\(self.currentHole)", forKey: "currentHole" as NSCopying)
        ref.child("matchData/\(self.currentMatchId)/player/\(self.selectedUserId)").updateChildValues(currentHoleWhilePlaying as! [AnyHashable : Any])
        let headingOfHole = GMSGeometryHeading(self.centerPointOfTeeNGreen[index-1].tee,self.centerPointOfTeeNGreen[index-1].green)
        let rotationAngle = headingOfHole - self.windHeading

        UIButton.animate(withDuration: 2.0, animations: {() -> Void in
            self.imgWindDir.transform = CGAffineTransform(rotationAngle:  (CGFloat(rotationAngle)) / 180.0 * CGFloat(Double.pi))
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if(self.positionsOfDotLine.count > 2){
                self.plotSuggestedMarkers(position: self.positionsOfDotLine)
            }
        })
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
            let shotPoint1 = self.getPoints(hole: self.positionsOfDotLine.last!, greenPath: self.numberOfHoles[index].green, gir: girPec, insideDistance: insideDistance)
            if(floor(GMSGeometryDistance(shotPoint1, self.positionsOfDotLine.last!)) == 0){
                self.btnActionHoleOut(self.btnHoleOut)
            }else{
                self.positionsOfDotLine[1] = shotPoint1
                self.btnActionShotsCount(self.btnShotsCount)
            }
            if(!holeOutFlag){
                let newDistance = GMSGeometryDistance(shotPoint1, positionsOfDotLine.last!) * YARD
                if(BackgroundMapStats.findPositionOfPointInside(position: shotPoint1, whichFeature: self.numberOfHoles[index].green)){
                    var end = "G\(Int(floor(newDistance)))"
                    end = end == "G0" ? "G1" : end
                    self.botStrokesGained = strokesGainedDict[skrokesGainedFilter].value(forKey:end ) as! Double
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
                nextPoint = GMSGeometryOffset(self.positionsOfDotLine.first!, distance/YARD - shotDist, headingRandom)
                
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
                    for data in self.numberOfHoles[index].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = GMSGeometryOffset(nearbyPoint[distance.index(of:distance.min()!)!],Double(arc4random_uniform(5)+1),headingRandom-90)
                }
                else{
                    for data in self.numberOfHoles[index].fairway{
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
                    for data in self.numberOfHoles[index].fairway{
                        nearbyPoint.append(data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)])
                        distance.append(GMSGeometryDistance(nextPoint, data[BackgroundMapStats.nearByPoint(newPoint: nextPoint, array: data)]))
                    }
                    nextPoint = GMSGeometryOffset(nearbyPoint[distance.index(of:distance.min()!)!],Double(arc4random_uniform(5)+1),headingRandom+90)
                }
                else{
                    for data in self.numberOfHoles[index].fairway{
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
                for data in self.numberOfHoles[index].fairway{
                    for value in data{
                        path.add(value)
                        fairwayArray.append(value)
                    }
                }
                nextPoint = BackgroundMapStats.coordInsideFairway(newPoint: nextPoint, array: fairwayArray, path: path)
            }
            debugPrint(isFairwayHitOrMiss(position: nextPoint))
            self.positionsOfDotLine[1] = nextPoint
            self.btnActionShotsCount(self.btnShotsCount)
            
            if !(BackgroundMapStats.findPositionOfPointInside(position: nextPoint, whichFeature: self.numberOfHoles[index].green)){
                var landOnFairwayDict = NSMutableDictionary()
                if(fairwayDetailsForFirstShot(shot:self.shotCount) == "H"){
                    landOnFairwayDict = distanceFairway
                }else{
                    landOnFairwayDict = distanceRough
                }
                let newDistance = GMSGeometryDistance(nextPoint, positionsOfDotLine.last!) * YARD
                self.botPlayerShotForPar3(gir: girWithF, distance: newDistance, distanceFairwayOrRough: landOnFairwayDict)
            }else{
                let newDistance = GMSGeometryDistance(nextPoint, positionsOfDotLine.last!) * YARD * 3
                let end = "G\(Int(floor(newDistance)))"
                self.botStrokesGained = strokesGainedDict[skrokesGainedFilter].value(forKey:end ) as! Double
                getPuttsPoints(strkGained: botStrokesGained-botSGPutting, lastCoord: nextPoint, holeCoord: positionsOfDotLine.last!)
            }
            if(!holeOutFlag){
                self.btnActionHoleOut(self.btnHoleOut)
            }
            
        }
    }
    
    @objc func nextAction(_ sender: UIButton!) {
        if(sender.currentTitle == "  Finish Round  "){
            self.btnActionFinishRound(UIButton.self)
        }else{
            if(shotViseCurve.count > 0){
                holeViseAllShots[index] = ((hole: index, holeShots: self.shotViseCurve,dotLinePoints:self.positionsOfDotLine,curvedLinePoints:self.positionsOfCurveLines,shotCount:self.shotCount,holeOut:self.holeOutFlag))
            }
            index += 1
            if(index == coordBound.count){
                index = 0
            }
            for i in 0..<playersButton.count{
                if(playersButton[i].id == Auth.auth().currentUser!.uid){
                    self.buttonAction(sender:playersButton[i].button)
                    self.newButtonAction(sender: playersButton[i].button)
                    break
                }
            }
            if(isHoleByHole){
                self.updateMap(indexToUpdate: index)
            }else{
                self.updateCurrentHole(index: index+1)
            }
        }
    }
    
    @objc func previousAction(_ sender: UIButton!) {
//        self.currentHole
//        let startingHole = Int(self.matchDataDictionary.value(forKey: "startingHole") as! String)
//        let gameType = self.matchDataDictionary.value(forKey: "matchType") as! String == "9 holes" ? 9:18
//        let totalHolesInsideThisCourse = coordBound.count
        if(shotViseCurve.count > 0){
            holeViseAllShots[index] = ((hole: index, holeShots: self.shotViseCurve,dotLinePoints:self.positionsOfDotLine,curvedLinePoints:self.positionsOfCurveLines,shotCount:self.shotCount,holeOut:self.holeOutFlag))
        }
        index -= 1
        if(index == -1){
            index = coordBound.count-1
        }
//
//        debugPrint("index : \(index+1)")
//        if(index < startingHole!-1){
//            var diff = 0
//            if(startingHole!+8 < coordBound.count){
//                diff = coordBound.count - (startingHole!+8)
//            }
//            index = coordBound.count - diff - 1
//        }
        
        for i in 0..<playersButton.count{
            if(playersButton[i].id == Auth.auth().currentUser!.uid){
                self.buttonAction(sender:playersButton[i].button)
                self.newButtonAction(sender: playersButton[i].button)
                break
            }
        }
        if(isHoleByHole){
            self.updateMap(indexToUpdate: index)
        }else{
            self.updateCurrentHole(index: index+1)
        }
    }
    //------------getPathFromBound----------------//
    func getPathFromBounds(index:Int)->GMSMutablePath{
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: bounds[index].minLat! , longitude:bounds[index].minLng! ))
        path.add(CLLocationCoordinate2D(latitude: bounds[index].maxLat! , longitude:bounds[index].minLng! ))
        path.add(CLLocationCoordinate2D(latitude: bounds[index].maxLat! , longitude:bounds[index].maxLng! ))
        path.add(CLLocationCoordinate2D(latitude: bounds[index].minLat! , longitude:bounds[index].maxLng! ))
        return path
    }
    //------------getCoordinateFromBound----------------//
    
    func getCoordinateFromBounds(index:Int)->[CLLocationCoordinate2D]{
        var path = [CLLocationCoordinate2D]()
        path.append(CLLocationCoordinate2D(latitude: bounds[index].minLat! , longitude:bounds[index].minLng! ))
        path.append(CLLocationCoordinate2D(latitude: bounds[index].maxLat! , longitude:bounds[index].minLng! ))
        path.append(CLLocationCoordinate2D(latitude: bounds[index].maxLat! , longitude:bounds[index].maxLng! ))
        path.append(CLLocationCoordinate2D(latitude: bounds[index].minLat! , longitude:bounds[index].maxLng! ))
        return path
    }
    //------------getZoomLevel------------------//
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
            if(holeOutFlag){
                distance  = GMSGeometryDistance(positionsOfCurveLines.first!, positionsOfCurveLines.last!)
                teePoint = positionsOfCurveLines.first!
                midPoint = BackgroundMapStats.middlePointOfListMarkers(listCoords: [positionsOfCurveLines.first!, positionsOfCurveLines.last!])
                lat = Int(midPoint.latitude)
            }
            else{
                distance  = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)
                teePoint = positionsOfDotLine.first!
                midPoint = BackgroundMapStats.middlePointOfListMarkers(listCoords: [positionsOfDotLine.first!, positionsOfDotLine.last!])
                lat = Int(midPoint.latitude)
            }
        }
        var zoom = 16.0
        if(lat < 90 && lat > 60){
            zoom = 21.1
            if (distance>5&&distance<10){
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
            }
        }else{
            zoom = 21
            if (distance>10&&distance<20){
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
            }
        }
        let heading = GMSGeometryHeading(midPoint, teePoint)
        let newMidPoint = GMSGeometryOffset(midPoint, distance*0.20, heading)
        let middlePointWithZoom = (newMidPoint,Float(zoom))
        return middlePointWithZoom
    }   
    

}
extension MapViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        //annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension MapViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
                
                if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
                    annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    annotation.website = infoDict.object(forKey: "website") as? String
                    
                    self.showInfoView(forPlace: annotation)
                }
            }
            
        }
    }
}

extension MapViewController :DropperDelegate{
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        if(clubs.contains(contents)){
            //            var club = String()
            if(contents == "more"){
                ActionSheetStringPicker.show(withTitle: "More Clubs", rows: ["4w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","Gw"], initialSelection: 1, doneBlock: { (picker, value, index) in
                    if(!self.clubs.contains(index as! String)){
                        self.clubs.insert(index as! String, at: self.clubs.count-1)
                        self.selectClubDropper.items = self.clubs// Item displayed
                    }
                    self.btnSelectClub.setTitle("\(index!)", for: .normal)
//                    self.btnEditClub.setTitle("\(index!)", for: .normal)
                    
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.btnSelectClub)
            }
            else{
                self.btnSelectClub.setTitle("\(contents)", for: .normal)
//                self.btnEditClub.setTitle("\(contents)", for: .normal)
                self.selectClubDropper.TableMenu.scrollToRow(at: path, at: UITableViewScrollPosition.middle, animated: true)
            }
        }
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
