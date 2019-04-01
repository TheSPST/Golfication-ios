//
//  PublicProfileVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Charts
import FirebaseAuth

class PublicProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblProfileScoring: UILabel!
    @IBOutlet weak var lblProfileHandicap: UILabel!
    @IBOutlet weak var lblProfileHomeCourse: UILabel!
    @IBOutlet weak var btnProfileImage: UIButton!
    @IBOutlet weak var btnProfileBasic: UIButton!
    @IBOutlet weak var lblAvrgFromLastRounds: UILabel!
    @IBOutlet weak var swingsRankValue: UILabel!
    @IBOutlet weak var roundPlayedRankValue: UILabel!
    @IBOutlet weak var strokesGainedPuttingRankValue: UILabel!
    @IBOutlet weak var lblClub: UILabel!

    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var btnAddFriend: UIButton!

    @IBOutlet weak var stackViewAddNInvite: UIStackView!

    @IBOutlet weak var totalScorePercentileBar: BarChartView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var golfBagHConstraint: NSLayoutConstraint!

    @IBOutlet weak var feedTableView: UITableView!

    @IBOutlet weak var settingBarBtn: UIBarButtonItem!

    var rightBarButton: UIBarButtonItem!
    
    @IBOutlet weak var golfBagContainerView: UIView!
    @IBOutlet weak var golfBagCardView: CardView!

    var userKey = String()
    var profileScoring: Int?
    var profileHandicap: Int?
    var profileHomeCourse: String?
    var percentile = 11.0
    var drivingRankStr = String()
    var roundsRank = Int()
    var roundsRankStr = String()
    var puttingRankStr = String()
    var drivingRank = Int()
    var drivingRankDict = NSMutableDictionary()
    var percentileRankDict = NSMutableDictionary()
    var roundsRankDict = NSMutableDictionary()
    var puttPerHoleRankDict = NSMutableDictionary()
    var puttingRank = Int()
    var clubs = ["Dr","3w","4w","5w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","3i","4i","5i","6i","7i","8i","9i", "Pw","Gw","Sw","Lw","Pu"]
//    var selectedClubs = ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"]
    var selectedClubs = NSMutableArray()

    var clubsBtn = [UIButton]()
    var dataArray = [Feeds]()
    var holeShots = [HoleShotPar]()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    let borderWidth:CGFloat = 2.0
    var cardViewMArray = NSMutableArray()
    var userName = String()
    var userImage = String()

    var progressView = SDLoader()

    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        FBSomeEvents.shared.singleParamFBEvene(param: "View User Profile")
        // Do any additional setup after loading the view.
        self.btnAddFriend.isUserInteractionEnabled = false

        setInitialUI()
        getDataFromFirebase()
    }
    
    // MARK: - setInitialUI
    func setInitialUI(){
        self.feedTableView.isHidden = true
        
        // Image needs to be added to project.
        rightBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.settingAction(_:)))
        rightBarButton.image = #imageLiteral(resourceName: "setting")
        rightBarButton.tintColor = UIColor.glfBluegreen
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        stackViewAddNInvite.isHidden = true
        if userKey != Auth.auth().currentUser!.uid{
            self.navigationItem.rightBarButtonItem = nil
            stackViewAddNInvite.isHidden = false
        }
        roundPlayedRankValue.text = ""
        swingsRankValue.text = ""
        strokesGainedPuttingRankValue.text = ""
        btnProfileImage.layer.borderWidth = 3.0
        btnProfileImage.layer.borderColor = UIColor.white.cgColor
        btnProfileImage.layer.cornerRadius = btnProfileImage.frame.size.height/2
        btnProfileImage.layer.masksToBounds = true
        
        btnProfileBasic.layer.cornerRadius = 3.0
        btnInvite.layer.cornerRadius = 3.0
        btnAddFriend.layer.cornerRadius = 3.0
    }
    
    @objc func settingAction(_ sender: UIBarButtonItem){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        viewCtrl.fromPublicProfile = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: inviteAction
    @IBAction func inviteAction(_ sender: UIButton) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userList/\(userKey)/timestamp") { (snapshot) in
            
            if(snapshot.value != nil){
                let timestamp = (snapshot.value as? Int)
                
                let tempdic = NSMutableDictionary()
                tempdic.setObject(self.userKey, forKey: "id" as NSCopying)
                tempdic.setObject(self.userName, forKey: "name" as NSCopying)
                tempdic.setObject(self.userImage, forKey: "image" as NSCopying)
                tempdic.setObject(1, forKey: "status" as NSCopying)
                tempdic.setObject(timestamp!, forKey: "timestamp" as NSCopying)
                Constants.addPlayersArray.add(tempdic)
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)

                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
                
                let gameController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
                var playNavCtrl = UINavigationController()
                playNavCtrl.automaticallyAdjustsScrollViewInsets = false
                playNavCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
                playNavCtrl.pushViewController(gameController, animated: false)
                playButton.contentView.isHidden = true
                playButton.floatButton.isHidden = true
            })
        }
    }
    
    // MARK: addFriendAction
    @IBAction func addFriendAction(_ sender: UIButton) {
        if btnAddFriend.titleLabel?.text == "Follow"{
            // Add to Firend List
            btnAddFriend.backgroundColor = UIColor.clear
            btnAddFriend.layer.borderWidth = 1.0
            btnAddFriend.layer.borderColor = UIColor.glfBluegreen.cgColor
            let originalImage1 = #imageLiteral(resourceName: "path15")
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btnAddFriend.tintColor = UIColor.glfBluegreen
            btnAddFriend.setImage(backBtnImage1, for: .normal)
            btnAddFriend.setTitle("Unfollow", for: .normal)
            btnAddFriend.setTitleColor(UIColor.glfBluegreen, for: .normal)
            
            let userIdDic = NSMutableDictionary()
            userIdDic.setObject(true, forKey: userKey as NSCopying)
            ref.child("userData/\(Auth.auth().currentUser!.uid)/friends").updateChildValues(userIdDic as! [AnyHashable : Any])

            let myIdDic = NSMutableDictionary()
            myIdDic.setObject(true, forKey: Auth.auth().currentUser!.uid as NSCopying)
            ref.child("userData/\(userKey)/friends").updateChildValues(myIdDic as! [AnyHashable : Any])
            
            Notification.sendNotification(reciever: self.userKey, message: "\(Auth.auth().currentUser!.displayName ?? "") has started following you.", type: "11", category: "Follow", matchDataId: "", feedKey:"")
        }
        else{
            // Remove from Friend List
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to unfollow \(self.userName)?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                // Do Nothing
                debugPrint("Cancel Alert: \(alert?.title ?? "")")
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                debugPrint("ok :\(alert?.title ?? "")")
                
                self.btnAddFriend.backgroundColor = UIColor.glfBluegreen
                self.btnAddFriend.layer.borderWidth = 0.0
                self.btnAddFriend.layer.borderColor = UIColor.clear.cgColor
                let originalImage1 = UIImage(named: "")
                let backBtnImage1 = originalImage1?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                self.btnAddFriend.tintColor = UIColor.clear
                self.btnAddFriend.setImage(backBtnImage1, for: .normal)
                self.btnAddFriend.setTitle("Follow", for: .normal)
                self.btnAddFriend.setTitleColor(UIColor.white, for: .normal)
                
                let userIdDic = NSMutableDictionary()
                userIdDic.setObject(true, forKey: self.userKey as NSCopying)
                ref.child("userData/\(Auth.auth().currentUser!.uid)/friends/\(self.userKey)").removeValue()
                
                let myIdDic = NSMutableDictionary()
                myIdDic.setObject(true, forKey: Auth.auth().currentUser!.uid as NSCopying)
                ref.child("userData/\(self.userKey)/friends/\(Auth.auth().currentUser!.uid)").removeValue()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getDataFromFirebase(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser!.uid)/friends") { (snapshot) in
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
                for (key, _) in dataDic{
                    if (key == self.userKey){
                        
                        self.btnAddFriend.backgroundColor = UIColor.clear
                        self.btnAddFriend.layer.borderWidth = 1.0
                        self.btnAddFriend.layer.borderColor = UIColor.glfBluegreen.cgColor
                        let originalImage1 = #imageLiteral(resourceName: "path15")
                        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                        self.btnAddFriend.tintColor = UIColor.glfBluegreen
                        self.btnAddFriend.setImage(backBtnImage1, for: .normal)
                        self.btnAddFriend.setTitle("Unfollow", for: .normal)
                        self.btnAddFriend.setTitleColor(UIColor.glfBluegreen, for: .normal)
                        
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.btnAddFriend.isUserInteractionEnabled = true
                self.getRank()
            })
        }
    }
    
    // MARK: - getRank
    func getRank(){

        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "ranks") { (snapshot) in
            var dataRankDic = NSMutableDictionary()
            
            if(snapshot.value != nil){
                dataRankDic = snapshot.value as! NSMutableDictionary
                for (key,value) in dataRankDic{
                    if(key as! String == "rank1"){
                        self.percentileRankDict = value as! NSMutableDictionary
                    }
                    else if(key as! String == "rank2"){
                        self.drivingRankDict = value as! NSMutableDictionary
                    }
                    else if(key as! String == "rank3"){
                        self.roundsRankDict = value as! NSMutableDictionary
                    }
                    else if(key as! String == "rank4"){
                        self.puttPerHoleRankDict = value as! NSMutableDictionary
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.getUserProfileData()
            })
        }
    }

    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    func getUserProfileData(){
        var roundData = 0
        var puttingData = 0.0
        var percentileData = 1
        var drivingAvgData = 0.0
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(userKey)") { (snapshot) in
            
            var dataDic = NSDictionary()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? NSDictionary)!
                
                self.btnProfileImage.setBackgroundImage(UIImage(named:"you"), for: .normal)
                if let image = dataDic["image"] as? String{
                    self.userImage = image
                    if image == "" {
                        self.btnProfileImage.setBackgroundImage(UIImage(named:"you"), for: .normal)
                    }
                    else{
                        let url = URL(string: image)
//                        self.btnProfileImage.sd_setBackgroundImage(with: url ?? URL(string:""), for: .normal, completed: nil)
                        self.btnProfileImage.sd_setBackgroundImage(with: url ?? URL(string:""), for: .normal, placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)

                    }
                }
                if let name = dataDic["name"] as? String{
                    self.userName = name
                    self.title = self.userName
                }
                if let proMode = dataDic["proMode"] as? Bool{
                    self.btnProfileBasic.setTitle("Basic", for: .normal)
                    self.btnProfileBasic.backgroundColor = UIColor.white
                    self.btnProfileBasic.setTitleColor(UIColor(rgb: 0x003D33), for: .normal)
                    if proMode{
                        self.btnProfileBasic.setTitle("PRO", for: .normal)
                        self.btnProfileBasic.backgroundColor = UIColor(rgb: 0xFFC700)
                        self.btnProfileBasic.setTitleColor(UIColor.white, for: .normal)
                    }
                }

                if let homeCourseDic = dataDic["homeCourseDetails"] as? NSDictionary{
                    if let courseName = homeCourseDic.object(forKey: "name"){
                        self.profileHomeCourse = courseName as? String
                    }
                }
                if  dataDic["golfBag"] != nil{
                    self.golfBagCardView.isHidden = false
                    //self.selectedClubs = golfBag
                    let golfBagArray = dataDic["golfBag"] as! NSMutableArray

                    self.selectedClubs = NSMutableArray()

                    for i in 0..<golfBagArray.count{
                        if let dict = golfBagArray[i] as? NSDictionary{
                            self.selectedClubs.add(dict)
                        }
                        else{
                            let tempArray = dataDic["golfBag"] as! NSMutableArray
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

                                golfBagArray.replaceObject(at: i, with: golfBagDict)
                                golfBagData = ["golfBag": golfBagArray]
                                
                                self.selectedClubs.add(golfBagDict)
                            }
                            if golfBagData.count>0{
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            }
                            break
                        }
                    }
                    let golfBagTempArray = NSMutableArray()
                    golfBagTempArray.addObjects(from: ["Dr","3w","4w","5w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","3i","4i","5i","6i","7i","8i","9i", "Pw","Gw","Sw","Lw","Pu"])
                    let tempArray = NSMutableArray()
                    
                    for j in 0..<golfBagTempArray.count{
                        for i in 0..<self.selectedClubs.count{
                            let dict = self.selectedClubs[i] as! NSDictionary
                            if golfBagTempArray[j] as! String == (dict.value(forKey: "clubName") as! String){
                                tempArray.add(dict)
                            }
                        }
                    }
                    self.selectedClubs = NSMutableArray()
                    self.selectedClubs.addObjects(from: tempArray as! [Any])
                    self.setGolfBagUI()
                }
                else{
                    self.golfBagCardView.isHidden = true
                }
                if let handicap = dataDic["handicap"] as? Int{
                    self.profileHandicap = Int(handicap)
                }
                if let scoring = dataDic["scoring"] as? NSDictionary{
                   self.profileScoring = Int(scoring.count)
                }
                if let statisticsDict = dataDic["statistics"] as? NSMutableDictionary{

                    for (key,value) in statisticsDict{
                        if(key as! String == "card4"){
                            roundData = (value as! NSMutableDictionary).count
                            let dict = value as! NSMutableDictionary
                            var par = 72
                            var score = 0
                            var sum = 0
                            for (_,v) in dict{
                                let newDic = v as! NSMutableDictionary
                                for (ke,va) in newDic{
                                    if(ke as! String == "score"){
                                        score = va as! Int
                                    }
                                    else if(ke as! String == "par"){
                                        par = va as! Int
                                    }
                                }
                                if(par != 0){
                                    sum += (score * 72)/par
                                }
                            }
                            percentileData = sum
                        }
                        else if(key as! String == "card6"){
                            let dict = value as! NSMutableDictionary
                            var count = 0
                            var distance = 0.0
                            for (k,v) in dict{
                                if(k as! String == "driveCount"){
                                    count = v as! Int
                                }
                                else if(k as! String == "driveDistance"){
                                    distance = v as! Double
                                }
                            }
                            drivingAvgData = count == 0 ? 0:distance/Double(count)
                        }
                        else if(key as! String == "card7"){
                            let dict = value as! NSMutableDictionary
                            var count = 0
                            var distance = 0
                            for (k,v) in dict{
                                if(k as! String == "holeCount"){
                                    count = v as! Int
                                }
                                else if(k as! String == "puttCount"){
                                    distance = v as! Int
                                }
                            }
                            if(count > 0){
                                puttingData = Double(distance)/Double(count)
                            }

                        }
                    }
                }
                if let myFeeds = dataDic["myFeeds"] as? [String : Bool]{
                    self.dataArray.removeAll()
                    let group = DispatchGroup()
                    for (key,_) in myFeeds{
                        group.enter()
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
                                debugPrint(feed)
                            }
                            group.leave()
                        })
                    }
                    group.notify(queue: .main) {
                         self.getScoreFromFirebaseMatchData()
                    }
                }
            }
            
            DispatchQueue.main.async( execute: {
                self.setProfileData()

                //------------------------ setStaticData ----------------------------
                debugPrint("putting")
                debugPrint(puttingData)
                debugPrint(drivingAvgData)
                debugPrint(percentileData)
                debugPrint(roundData)
                
                self.drivingRank = self.generateRankForDrivingDistance(data: Int(drivingAvgData), rangeDict: self.drivingRankDict)
                if(roundData != 0){
                    percentileData = Int(percentileData/roundData)
                    self.percentile = self.generateRankForPercentile(data: percentileData, rangeDict: self.percentileRankDict)
                    self.roundsRank = self.generateRankForRoundRank(data: roundData, rangeDict: self.roundsRankDict)
                    self.puttingRank = self.generateRankForPuttsPerHole(data: 100*(puttingData), rangeDict: self.puttPerHoleRankDict)
                }
                debugPrint(self.percentile)
                self.drivingRankStr = self.drivingRank == 0 ? "-":"\(self.drivingRank)"
                if(self.drivingRank > 1000){
                    self.drivingRankStr = "\(self.drivingRank/1000)k+"
                }
                self.puttingRankStr = self.puttingRank == 0 ? "-":"\(self.puttingRank)"
                if(self.puttingRank > 1000){
                    self.puttingRankStr = "\(self.puttingRank/1000)k+"
                }
                self.roundsRankStr = self.roundsRank == 0 ? "-":"\(self.roundsRank)"
                if(self.roundsRank > 1000){
                    self.roundsRankStr = "\(self.roundsRank/1000)k+"
                }
                self.setData()
            })
        }
    }
    
    func generateRankForPercentile(data:Int,rangeDict:NSMutableDictionary)->Double{
        var rank = Double()
        if(data < 80){
            rank = rangeDict.value(forKey: "80") as! Double
        }else if(data >= 80 && data < 90){
            rank = ((rangeDict.value(forKey: "90") as! Double)*Double(data-80)+(rangeDict.value(forKey: "80") as! Double)*Double(90-data))/10
        }else if(data >= 90 && data < 100){
            rank = ((rangeDict.value(forKey: "100") as! Double)*Double(data-90)+(rangeDict.value(forKey: "90") as! Double)*Double(100-data))/10
        }else if(data >= 110 && data < 120){
            rank = ((rangeDict.value(forKey: "120") as! Double)*Double(data-110)+(rangeDict.value(forKey: "110") as! Double)*Double(120-data))/10
        }else if(data >= 120 && data < 200){
            rank = ((rangeDict.value(forKey: "200") as! Double)*Double(data-120)+(rangeDict.value(forKey: "120") as! Double)*Double(200-data))/80
        }else{
            rank = rangeDict.value(forKey: "200") as! Double
        }
        return rank
    }
    func generateRankForRoundRank(data:Int,rangeDict:NSMutableDictionary)->Int{
        var rank = Double()
        var rankInString = String()
        if(data<10){
            rankInString = rangeDict.value(forKey: "\(data)") as! String
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 10 && data < 20){
            //Double(rangeDict.value(forKey: "10") as! String)
            rank = (1000*Double(data-10)+Double(rangeDict.value(forKey: "20") as! String)!*Double(20-data))/10
        }else if(data >= 20 && data < 30){
            rank = (Double(rangeDict.value(forKey: "20") as! String)!*Double(data-20)+Double(rangeDict.value(forKey: "30") as! String)!*Double(30-data))/10
        }else if(data >= 30 && data < 40){
            rank = (Double(rangeDict.value(forKey: "30") as! String)!*Double(data-30)+Double(rangeDict.value(forKey: "40") as! String)!*Double(40-data))/10
        }else if(data>=40 && data < 50){
            rank = (Double(rangeDict.value(forKey: "40") as! String)!*Double(data-40)+Double(rangeDict.value(forKey: "50") as! String)!*Double(50-data))/10
        }else if(data>=50 && data < 75){
            rank = (Double(rangeDict.value(forKey: "50") as! String)!*Double(data-50)+Double(rangeDict.value(forKey: "75") as! String)!*Double(75-data))/25
        }else{
            rank = 1
        }
        return Int(rank)
    }
    
    func generateRankForPuttsPerHole(data:Double,rangeDict:NSMutableDictionary)->Int{
        var rank = Double()
        var rankInString = String()
        if(data < 150){
            rank = Double(rangeDict.value(forKey: "150") as! String)!
        }
        else if(data >= 150 && data < 160){
            rank = (Double(rangeDict.value(forKey: "160") as! String)!*Double(data-150)+Double(rangeDict.value(forKey: "150") as! String)!*Double(160-data))/10
        }else if(data >= 160 && data < 170){
            rank = (Double(rangeDict.value(forKey: "170") as! String)!*Double(data-160)+Double(rangeDict.value(forKey: "160") as! String)!*Double(170-data))/10
        }else if(data >= 170 && data < 180){
            rank = (Double(rangeDict.value(forKey: "180") as! String)!*Double(data-170)+Double(rangeDict.value(forKey: "170") as! String)!*Double(180-data))/10
        }else if(data>=180 && data < 190){
            rankInString = rangeDict.value(forKey: "190") as! String
            rankInString = String(rankInString.dropLast(2))
            rank = (Double(rankInString)!*1000*Double(data-180)+Double(rangeDict.value(forKey: "180") as! String)!*Double(190-data))/10
        }else if(data >= 190 && data < 200){
            rankInString = rangeDict.value(forKey: "190") as! String
            if(200 - data)<5{
                rankInString = rangeDict.value(forKey: "200") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 200 && data < 210){
            rankInString = rangeDict.value(forKey: "200") as! String
            if(210 - data)<5{
                rankInString = rangeDict.value(forKey: "210") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 210 && data < 220){
            rankInString = rangeDict.value(forKey: "210") as! String
            if(220 - data)<5{
                rankInString = rangeDict.value(forKey: "220") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 220 && data < 240){
            rankInString = rangeDict.value(forKey: "220") as! String
            if(240 - data)<10{
                rankInString = rangeDict.value(forKey: "240") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data>=240 && data < 250){
            rankInString = rangeDict.value(forKey: "240") as! String
            if(250 - data)<5{
                rankInString = rangeDict.value(forKey: "250") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data>=250 && data < 300){
            rankInString = rangeDict.value(forKey: "250") as! String
            if(300 - data)<25{
                rankInString = rangeDict.value(forKey: "300") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else{
            rank = 10000
        }
        return Int(rank)
    }
    
    
    func generateRankForDrivingDistance(data:Int,rangeDict:NSMutableDictionary)->Int{
        var rank = Double()
        var rankInString = String()
        if(data < 220){
            rankInString = rangeDict.value(forKey: "220") as! String
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
        }
        else if(data >= 220 && data < 250){
            rankInString = rangeDict.value(forKey: "220") as! String
            if(250 - data)<15{
                rankInString = rangeDict.value(forKey: "250") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 250 && data < 270){
            rankInString = rangeDict.value(forKey: "250") as! String
            if(270 - data)<10{
                rankInString = rangeDict.value(forKey: "270") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 270 && data < 280){
            rankInString = rangeDict.value(forKey: "270") as! String
            if(280 - data)<5{
                rankInString = rangeDict.value(forKey: "280") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
            
        }else if(data >= 280 && data < 290){
            rankInString = rangeDict.value(forKey: "280") as! String
            if(290 - data)<5{
                rankInString = rangeDict.value(forKey: "290") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
        }else if(data>=290 && data < 300){
            rankInString = rangeDict.value(forKey: "290") as! String
            if(300 - data)<5{
                rankInString = rangeDict.value(forKey: "300") as! String
            }
            rankInString = String(rankInString.dropLast(2))
            rank = Double(rankInString)! * 1000
        }else if(data >= 300 && data < 310){
            rank = (1000.0*Double(data-300)+Double(rangeDict.value(forKey: "310") as! String)!*Double(310-data))/10
        }else if(data >= 310 && data < 320){
            rank = (Double(rangeDict.value(forKey: "310") as! String)!*Double(data-310)+Double(rangeDict.value(forKey: "320") as! String)!*Double(320-data))/10
        }else if(data >= 320 && data < 330){
            rank = (Double(rangeDict.value(forKey: "320") as! String)!*Double(data-320)+Double(rangeDict.value(forKey: "330") as! String)!*Double(330-data))/10
        }else if(data>=330 && data < 340){
            rank = (Double(rangeDict.value(forKey: "330") as! String)!*Double(data-330)+Double(rangeDict.value(forKey: "340") as! String)!*Double(340-data))/10
        }else if(data>=340 && data < 350){
            rank = (Double(rangeDict.value(forKey: "340") as! String)!*Double(data-340)+Double(rangeDict.value(forKey: "350") as! String)!*Double(350-data))/10
        }else{
            rank = 1
        }
        return Int(rank)
    }
    
    func setData()  {
        let stringData = self.percentile == 11 ? "Please play one game to see your ranks" : "You scored better than \(self.percentile)% of Golfers"
        self.lblAvrgFromLastRounds.text = stringData
        self.swingsRankValue.text = String(self.drivingRankStr)
        self.roundPlayedRankValue.text = "-"
        if(roundsRank != 0){
            self.roundPlayedRankValue.text = self.roundsRankStr
        }
        self.strokesGainedPuttingRankValue.text = String(self.puttingRankStr)
        let value = [10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0]
        self.totalScorePercentileBar.setBarChartForTogether(dataPoints: [String](), values: value, chartView: (self.totalScorePercentileBar)!, color: UIColor.glfWhite, barWidth: 0.2, whichValue: Int(self.percentile)/10)
    }
    
    // MARK: - setProfileData
    func setProfileData(){
        lblProfileHomeCourse.text = self.profileHomeCourse ?? "-"
        lblProfileHandicap.text = "\(self.profileHandicap ?? 0)"
        lblProfileScoring.text = "\(self.profileScoring ?? 0)"
        
        /*let numOfCoulmn = 7
        let btnWidth = 30.0
        let btnHeight = 30.0
        var xOffset = 0.0
        var yOffset = 0.0
        var incr = 0
        let horzSpace = (golfBagContainerView.frame.size.width - CGFloat(btnWidth * Double(numOfCoulmn))) / CGFloat(numOfCoulmn-1)
        let bottomSpace = 8.0
        for i in 0..<selectedClubs.count{
            
            if CGFloat(xOffset + btnWidth) > golfBagContainerView.frame.size.width{
                yOffset += btnHeight + bottomSpace
                xOffset = 0.0
                incr = 0
            }
            let btns = UIButton()
            btns.frame = CGRect(x: xOffset, y: yOffset, width: btnWidth, height: btnHeight)
            btns.setCornerWithCircleWidthOne(color: UIColor.glfWarmGrey.cgColor)
            btns.setTitle(selectedClubs[i], for: .normal)
            btns.titleLabel?.font = UIFont(name: "SFProDisplay-Light", size: 14.0)
            btns.isSelected = true
            btns.tintColor = UIColor.glfFlatBlue
            btns.backgroundColor = UIColor.glfFlatBlue
            btns.isHidden = false
            golfBagContainerView.addSubview(btns)
            
            incr = incr + 1
            xOffset = Double(CGFloat(incr) * (CGFloat(btnWidth) + horzSpace))
        }
        golfBagHConstraint.constant = CGFloat(yOffset+btnHeight)
        self.view.layoutIfNeeded()*/
    }
    
    func setGolfBagUI() {
        for subV in golfBagContainerView.subviews{
            subV.removeFromSuperview()
        }
        self.lblClub.text = "\(selectedClubs.count) Clubs"
        
        let teeWidth = 15.0
        let teeHeight = 15.0
        
        let numOfCoulmn = 4
        let btnWidth = 60.0
        let btnHeight = 60.0
        let lblHeight = 20.0
        var xOffset = 0.0
        var yOffset = 0.0
        var incr = 0
        let horzSpace = (golfBagContainerView.frame.size.width - CGFloat(btnWidth * Double(numOfCoulmn))) / CGFloat(numOfCoulmn-1)
        let bottomSpace = 25.0
        for i in 0..<selectedClubs.count{
            let dict = selectedClubs[i] as! NSDictionary
            if CGFloat(xOffset + btnWidth) > golfBagContainerView.frame.size.width{
                yOffset += btnHeight + bottomSpace
                xOffset = 0.0
                incr = 0
            }
            let btns = UIButton()
            btns.frame = CGRect(x: xOffset, y: yOffset, width: btnWidth, height: btnHeight)
            btns.setCornerWithCircleWidthOne(color: UIColor(rgb: 0xF7F7F7).cgColor)
//            btns.setBackgroundImage(#imageLiteral(resourceName: "TempBag"), for: .normal)
            btns.imageView?.sizeToFit()
            golfBagContainerView.addSubview(btns)
            
            let btnTag = UIButton()
            btnTag.frame = CGRect(x: xOffset + btnWidth - 9, y: yOffset, width: teeWidth, height: teeHeight)
            btnTag.setCornerWithCircleWidthOne(color: UIColor.clear.cgColor)
            btnTag.backgroundColor = UIColor.glfBluegreen75
            if (dict.value(forKey: "tag") as! Bool) == false{
                btnTag.backgroundColor = UIColor.glfWarmGrey
            }
            btnTag.setTitleColor(UIColor.white, for: .normal)
            btnTag.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 10.0)
            btnTag.setTitle("T", for: .normal)
            //golfBagContainerView.addSubview(btnTag)
            
            let titleLbl = UILabel()
            titleLbl.frame = CGRect(x: xOffset, y: (Double(btns.frame.size.height + CGFloat(yOffset))), width: btnWidth, height: lblHeight)
            titleLbl.textColor = UIColor.glfFlatBlue
            titleLbl.textAlignment = .center
            titleLbl.font = UIFont(name: "SFProDisplay-Light", size: 9.0)
            
            let lastChar = (dict.value(forKey: "clubName") as! String).last!
            let firstChar = (dict.value(forKey: "clubName") as! String).first!
            
            btns.setBackgroundImage(UIImage(named: String(firstChar)+String(lastChar)), for: .normal)

            if lastChar == "i"{
                titleLbl.text = String(firstChar) + " Iron"
            }
            else if lastChar == "h"{
                titleLbl.text = String(firstChar) + " Hybrid"
            }
            else if lastChar == "r"{
                titleLbl.text = "Driver"
            }
            else if lastChar == "u"{
                titleLbl.text = "Putter"
            }
            else if lastChar == "w"{
                if (dict.value(forKey: "clubName") as! String) == "Pw"{
                    titleLbl.text =  "Pitching Wedge"
                }
                else if (dict.value(forKey: "clubName") as! String) == "Sw"{
                    titleLbl.text =  "Sand Wedge"
                }
                else if (dict.value(forKey: "clubName") as! String) == "Gw"{
                    titleLbl.text =  "Gap Wedge"
                }
                else if (dict.value(forKey: "clubName") as! String) == "Lw"{
                    titleLbl.text =  "Lob Wedge"
                }
                else{
                    titleLbl.text = String(firstChar) + " Wood"
                }
            }
            golfBagContainerView.addSubview(titleLbl)
            
            incr = incr + 1
            xOffset = Double(CGFloat(incr) * (CGFloat(btnWidth) + horzSpace))
        }
        golfBagHConstraint.constant = CGFloat(yOffset + btnHeight + lblHeight)
        self.view.layoutIfNeeded()
    }
    
    // MARK: - getScoreFromFirebaseMatchData
    func getScoreFromFirebaseMatchData(){
        
        let group = DispatchGroup()
        var feedNumber = [String]()
        for i in 0..<self.dataArray.count{
            if let matchID = dataArray[i].matchId{
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
            self.progressView.hide(navItem: self.navigationItem)
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
                    let feeds = self.dataArray[i]
                    //if !(feeds.holeShotsArray?.count == nil) || !(feeds.holeShotsArray?.count == 0){
                        if(feeds.location == nil){
                            height += 440
                        }else if ((feeds.holeShotsArray?.count == 9)){
                            height += 190
                        }else{
                            height += 260
                        }
                    //}
                }
            }
            self.tableHeightConstraint.constant = CGFloat(height)
            self.view.layoutIfNeeded()
            self.setData()
            if self.dataArray.count == 0{
                self.feedTableView.isHidden = true
            }
            else{
                self.feedTableView.isHidden = false
                self.feedTableView.reloadData()
            }
        }
    }
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Activity"
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
//            else if feeds.holeShotsArray?.count == nil || feeds.holeShotsArray?.count == 0{
//                height = 0.0
//            }
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
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewHomeFeedViewCell", for: indexPath as IndexPath) as! NewHomeFeedViewCell
        
        let feeds = dataArray[indexPath.row]
        
        cell.userName.text = feeds.userName
        cell.userImg.setCircle(frame: cell.userImg.frame)
        cell.userImg.image = UIImage(named:"you")
        cell.userImg.backgroundColor = UIColor.lightGray
        if (feeds.userImage != nil) {
            cell.userImg.sd_setImage(with: URL(string: feeds.userImage!), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
        }
        if(feeds.type == "2"){
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
                self.view.layoutIfNeeded()
                
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
            cell.lblScoreTitle.text = ""
            cell.lblSharedMsg.isHidden = false
            
            let subtitle = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
                cell.lblSubtitle.text = "\(subtitle)"
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
        cell.btnLike.addTarget(self, action: #selector(self.btnActionLike(_:)), for: .touchUpInside)
        cell.btnShare.addTarget(self, action: #selector(self.btnActionShare(_:)), for: .touchUpInside)
        //}
        self.cardViewMArray.add(cell.cardView)
        
        return cell
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
            
            Notification.sendNotification(reciever: self.userKey, message: "\(Auth.auth().currentUser!.displayName ?? "") liked your post.", type: "10", category: "Like", matchDataId: "", feedKey: dataArray[sender.tag].feedId!)
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
    
    @objc func showFinalScores(_ sender:UIButton){
        // do other task
         let index = sender.tag //{
            if(dataArray.count > Int(index)){
                
                if let matchID = dataArray[index].matchId{
                    debugPrint(matchID)
                    self.getScoreFromMatchDataScoring(matchId:matchID)
                }
            }
        //}
    }
    
    func getScoreFromMatchDataScoring(matchId:String){
        var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
            self.progressView.hide(navItem: self.navigationItem)

            let matchDict = (snapshot.value as? NSDictionary)!
            
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
                if (keyData == "scoring"){
                    scoreArray = (value as! NSArray)
                }
                if(keyData == "scoringMode"){
                    isManualScoring = true
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
                scoring.append((hole: i, par:par,players:playersArray))
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
                let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
                viewCtrl.finalPlayersData = players
                viewCtrl.finalScoreData = scoring
                viewCtrl.isManualScoring = isManualScoring
                viewCtrl.matchDataDict = matchDataDiction
                viewCtrl.currentMatchId = matchId
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            })
        }
    }
    
    func updateButtons(allScore:Int,holeLbl:UIButton){
        
        if allScore < -1{
            //double square
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = borderWidth
                    layer.borderColor = UIColor.glfRosyPink.cgColor
                    layer.cornerRadius = 0
                }
            }
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfRosyPink.cgColor
            holeLbl.titleLabel?.layer.borderWidth = 0
            holeLbl.layer.cornerRadius = 0
            
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
        }
        else{
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.layer.borderWidth = 0
            holeLbl.titleLabel?.layer.borderWidth = 0
        }
    }
}
