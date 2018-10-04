//
//  StartNewGameVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 18/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
class StartNewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    var matchId : String!
    @IBAction func btnActionStartNewGame(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message:"Decline request to start New Game" , preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBOutlet weak var btnStartNewGame: UIButton!
    @IBOutlet weak var tblAwaitingPlayer: UITableView!
    @IBOutlet weak var btnAcceptInvite : UIButton!
    @IBOutlet weak var btnDeclineGame : UIButton!

    @IBOutlet weak var mapViewGame: MKMapView!
    var mapLat = Double()
    var mapLng = Double()
    var playersKey = [String]()
    var playersStatus = [Int]()
    var playersName = [String]()
    var playersImage = [String]()
    let courseName = UILabel()
    var courseId = String()
    let status = ["Decline","Awaiting....","Joined","Finished","Finished"]
    var isCustomGame = false
    var playersData = NSMutableArray()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    let lblStartingHole = UILabel()
    var isAccept = false
    var scoringMode = String()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(isAccept){
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDeclineGame.backgroundColor = UIColor.clear
        btnDeclineGame.setCorner(color: UIColor.white.cgColor)
        btnAcceptInvite.setCorner(color: UIColor.white.cgColor)
        btnAcceptInvite.backgroundColor = UIColor.glfBluegreen

        
        courseName.textColor = UIColor.glfWhite
        courseName.frame = CGRect(x: 10, y: 10, width: self.mapViewGame.frame.width - 20, height: 33)
        lblStartingHole.frame = CGRect(x: 10, y: 40, width: self.mapViewGame.frame.width - 20, height: 33)
        lblStartingHole.font = UIFont(name: "SFProDisplay-Medium", size: 14)
        lblStartingHole.text = ""
        lblStartingHole.textColor = UIColor.glfWhite
        //        courseName.backgroundColor = UIColor.glfBluegreen
        courseName.font = UIFont(name: "SFProDisplay-Medium", size: 21)
        courseName.text = ""
        mapViewGame.addSubview(courseName)
        mapViewGame.addSubview(lblStartingHole)
        btnDeclineGame.addTarget(self, action: #selector(btnActionDecline(_:)), for: .touchUpInside)
        btnAcceptInvite.addTarget(self, action: #selector(btnActionInvite(_:)), for: .touchUpInside)
        
        mapViewGame.addSubview(btnDeclineGame)
        mapViewGame.addSubview(btnAcceptInvite)
        getScoreFromMatchDataFirebase(matchID:self.matchId)
    }
    
    @objc func btnActionDecline(_ sender: Any) {
        ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId!)").removeValue()
        ref.child("matchData/\(matchId!)/player/\(Auth.auth().currentUser!.uid)/status").setValue(0)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnActionInvite(_ sender: Any) {
        ref.child("matchData/\(matchId!)/player/\(Auth.auth().currentUser!.uid)/status").setValue(2)
        ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/\(matchId!)").setValue(true)
        isAccept = true
        self.getScoreFromMatchDataScoring()
    }
    
    func loadMapView(){
        let annotation = MKPointAnnotation()
        annotation.title = self.courseName.text
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: mapLat,
            longitude: mapLng)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: mapLat, longitude: mapLng), 1000, 1000)
        let adjustedRegion = self.mapViewGame.regionThatFits(viewRegion)
        self.mapViewGame.setRegion(adjustedRegion, animated: true)
        self.mapViewGame.removeAnnotations(self.mapViewGame.annotations)
        self.mapViewGame.addAnnotation(annotation)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getScoreFromMatchDataFirebase(matchID:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchID)/player") { (snapshot) in
            var playerDict = NSMutableDictionary()
            if(snapshot.value != nil){
                print(snapshot.value as! NSMutableDictionary)
                playerDict = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                if(snapshot.value != nil){
                    for (key,value) in playerDict{
                        let data = value as! NSMutableDictionary
                        for (k,v) in data{
                            if(k as! String == "status"){
                                self.playersStatus.append(v as! Int)
                            }
                            if(k as! String  == "image"){
                                self.playersImage.append(v as! String)
                                
                            }
                            if(k as! String  == "name"){
                                self.playersName.append(v as! String)
                            }
                        }
                        self.playersKey.append(key as! String)
                        
                    }
                    ref?.child("matchData").child(matchID)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                            let userDict = snapshot.value as! [String: Any]
                            self.courseName.text = (userDict["courseName"] as! String)
                            self.mapLat = Double(userDict["lat"] as! String)!
                            self.mapLng = Double(userDict["lng"] as! String)!
                            self.courseId = (userDict["courseId"] as! String)
                            self.checkRangeFinderHoleData(courseId:self.courseId)
                            self.lblStartingHole.text = "Starting Hole : " + (userDict["startingHole"] as! String)
                            if((userDict["scoringMode"]) != nil){
                                self.scoringMode = userDict["scoringMode"] as! String
                                self.isCustomGame = true
                                if(self.scoringMode == "advanced"){
                                    self.isCustomGame = false
                                }
                            }
                            self.loadMapView()
                        })
                    self.tblAwaitingPlayer.reloadData()
                    
                }
            })
        }
    }
    // MARK: selectedGameTypeFromFirebase
    func checkRangeFinderHoleData(courseId:String) {
        teeArr.removeAll()
        let golfId = "course_\(courseId)"
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
            teeArr.append((name: teeName.capitalizingFirstLetter(), type: teeType.capitalizingFirstLetter(),rating:ratin, slope:"\(slope)"))
        }
        if(!teeArr.isEmpty){
            selectedSlope = Int(teeArr[0].slope)!
            selectedRating = teeArr[0].rating
            selectedTee = teeArr[0].type
            selectedTeeColor = teeArr[0].name
        }else{
            selectedTee = ""
            selectedTeeColor = ""
            selectedSlope = 113
            selectedRating = ""
        }
    }
    let locationManager = CLLocationManager()

    func getScoreFromMatchDataScoring(){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId!)") { (snapshot) in
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            self.view.isUserInteractionEnabled = false
            let matchDict = (snapshot.value as? NSDictionary)!
            var scoreArray = NSArray()
            var keyData = String()
            var playersKey = [String]()
            var isOnCourse = Bool()
            for (key,value) in matchDict{
                keyData = key as! String
                if(keyData == "player"){
                    for (k,_) in value as! NSMutableDictionary{
                        playersKey.append(k as! String)
                    }
                }
                if (keyData == "scoring"){
                    scoreArray = (value as! NSArray)
                }
                if(keyData == "onCourse"){
                    isOnCourse = (value as! Bool)
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
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if(isOnCourse){
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
                        if let currentLocation: CLLocation = self.locationManager.location{
                            
                            var currentCoord = CLLocationCoordinate2D()
                            currentCoord = currentLocation.coordinate
                            
                            let location1 = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
                            let location2 = CLLocation(latitude: Double(selectedLat)!, longitude: Double(selectedLong)!)
                            let distance : CLLocationDistance = location1.distance(from: location2)
                            debugPrint("distance = \(distance) m")
                            if(distance <= 15000.0){
                                self.openSuitableGameMode(matchDict:matchDict as! NSMutableDictionary,players:players)
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
                    self.openSuitableGameMode(matchDict:matchDict as! NSMutableDictionary,players:players)
                }
            })
        }
    }
    
    func openSuitableGameMode(matchDict:NSMutableDictionary,players:NSMutableArray){
        if(!self.isCustomGame){
            ref.child("userData/\(Auth.auth().currentUser!.uid)/activeMatches/").updateChildValues([self.matchId!:true] as [AnyHashable:Any])
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
            viewCtrl.matchDataDict = matchDict
            viewCtrl.isContinue = false
            viewCtrl.currentMatchId = self.matchId!
            viewCtrl.isAcceptInvite = true
            viewCtrl.scoring = self.scoring
            viewCtrl.courseId = "course_\(self.courseId)"
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }else{
            if(self.scoringMode == "classic"){
                let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "BasicScoringVC") as! BasicScoringVC
                viewCtrl.playerData = players
                viewCtrl.matchDataDict = matchDict
                viewCtrl.scoreData = self.scoring
                viewCtrl.isAccept = true
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }else{
                let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "RFMapVC") as! RFMapVC
                viewCtrl.matchDataDic = matchDict
                viewCtrl.isContinueMatch = false
                viewCtrl.matchId = self.matchId!
                viewCtrl.isAcceptInvite = true
                viewCtrl.courseId = "course_\(self.courseId)"
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersKey.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "acceptInviteCell") as! AcceptInviteCell
        cell.btnPlayerImage.sd_setImage(with: URL(string:playersImage[indexPath.row]), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
        cell.lblPlayerName.text = (playersName[indexPath.row])
        let states = playersStatus[indexPath.row]
        switch states {
        case 0:
            cell.lblPlayerStatus.textColor = UIColor.glfRosyPink
            break
        case 1:
            cell.lblPlayerStatus.textColor = UIColor.glfFlatBlue
            break
        case 2:
            cell.lblPlayerStatus.textColor = UIColor.glfBluegreen
            break
        default:
            cell.lblPlayerStatus.textColor = UIColor.glfBlack75
        }
        cell.lblPlayerStatus.text = status[states]
        return cell
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
