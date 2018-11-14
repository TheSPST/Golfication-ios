//
//  TogetherVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import Charts

class TogetherVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblAvrgFromLastRounds: UILabel!
    @IBOutlet weak var cardViewScore: CardView!
    @IBOutlet weak var swingsRankValue: UILabel!
    @IBOutlet weak var roundPlayerRankValue: UILabel!
    @IBOutlet weak var strokesGainedPuttingRankValue: UILabel!
    @IBOutlet weak var totalScorePercentileBar: BarChartView!
    @IBOutlet weak var togetherTblView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    let progressView = SDLoader()

    var scoring  = [HoleShotPar]()
    var drivingRank = Int()
    var roundsRank = Int()
    var puttingRank = Int()
    var percentile = 11.0
    var drivingRankStr = String()
    var roundsRankStr = String()
    var puttingRankStr = String()
    var percentileRankDict = NSMutableDictionary()
    var drivingRankDict = NSMutableDictionary()
    var roundsRankDict = NSMutableDictionary()
    var puttPerHoleRankDict = NSMutableDictionary()
    var cardViewMArray = NSMutableArray()
    let borderWidth:CGFloat = 2.0

//    var feedData = [(image:String,name:String,timestamp:Int,course:String,scores:[HoleShotPar],type:Int)]()
    var dataArray = [Feeds]()
    var holeShots = [HoleShotPar]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        if(dataArray.count == 0){
            getFeedData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        
        swingsRankValue.text = ""
        roundPlayerRankValue.text = ""
        strokesGainedPuttingRankValue.text = ""
        
        /*var friendsList = [String]()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/\(Auth.auth().currentUser!.uid)/friends") { (snapshot) in
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String:Bool])!
            }
            friendsList.append(Auth.auth().currentUser!.uid)
            for (key,value) in dataDic{
                if(value){
                    friendsList.append(key)
                }
            }
            for key in friendsList{
                ref.child("userData/\(key)/myFeeds").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists(){
                        let dataDic = (snapshot.value as? [String:Bool])!
                        let group = DispatchGroup()
                        for (key,_) in dataDic{
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
                                }
                                group.leave()
                            })
                        }
                        group.notify(queue: .main){
                            self.getScoreFromFirebaseMatchData()
                        }
                    }

                })
            }
            DispatchQueue.main.async(execute: {
                self.getRank()
            })
        }*/
    }
    func getFeedData(){
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        ref.child("feedData").queryOrderedByKey().queryLimited(toLast: 100).observeSingleEvent(of: .value, with: { snapshot in
            var feedDic = NSDictionary()
            if snapshot.value != nil{
                feedDic = snapshot.value as! NSDictionary

                for (key, value) in feedDic{
                    let feed = Feeds()

                    let feedData = value as! NSDictionary
                    debugPrint("snapshot ==", feedData)
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
                        feed.deleted = false
                        if let deleted = feedData["deleted"] as? Bool {
                            feed.deleted = deleted
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
                        feed.deleted = false
                        if let deleted = feedData["deleted"] as? Bool {
                            feed.deleted = deleted
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
                    feed.feedId = key as! String
                    if (feed.deleted!) {
                        // do not add
                    }
                    else{
                        self.dataArray.append(feed)
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                debugPrint("dataArray ==", self.dataArray.count)

                self.getScoreFromFirebaseMatchData()
                self.getRank()
            })
        })
    }
    
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
                self.getRankData()
            })
        }
    }
    func getRankData(){
        var roundData = 0
        var puttingData = 0.0
        var percentileData = 1
        var drivingAvgData = 0.0
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "statistics") { (snapshot) in
            var statisticsDict = NSMutableDictionary()
            
            if(snapshot.value != nil){
                statisticsDict = snapshot.value as! NSMutableDictionary
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
                                if(par != 0){
                                    sum += (score * 72)/par
                                }
                                
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
                        if(count>0){
                            puttingData = Double(distance)/Double(count)
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
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
    
    func setData()  {
        
        let stringData = self.percentile == 11 ? "Please play one game to see your ranks" : "You scored better than \(self.percentile)% of Golfers"
        self.lblAvrgFromLastRounds.text = stringData
        self.swingsRankValue.text = String(self.drivingRankStr)
        self.roundPlayerRankValue.text = "-"
        if(roundsRank != 0){
            self.roundPlayerRankValue.text = self.roundsRankStr
        }
        self.strokesGainedPuttingRankValue.text = String(self.puttingRankStr)
        let value = [10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0]
        self.totalScorePercentileBar.setBarChartForTogether(dataPoints: [String](), values: value, chartView: (self.totalScorePercentileBar)!, color: UIColor.glfWhite, barWidth: 0.2, whichValue: Int(self.percentile)/10)
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
    
    
    func getScoreFromFirebaseMatchData(){
        var feedNumber = [String]()
        let group = DispatchGroup()
        
        for i in 0..<dataArray.count{
            //, matchID.count > 1
            if let matchID = dataArray[i].matchId {
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
                    for (key,value) in matchDict{
                        keyData = key as! String
                        if(keyData == "scoring"){
                            scoreArray = (value as! NSArray)
                        }
                        if(keyData == "courseName"){
                            self.dataArray[i].location = (value as! String)
                        }
                    }
                    self.dataArray[i].isShow = true
                    for j in 0..<scoreArray.count {
                        let holeShotPar = HoleShotPar()
                        holeShotPar.hole = j
                        let score = scoreArray[j] as! NSDictionary
                        for(key,value) in score{
                            if(key as! String == "par"){
                                holeShotPar.par = value as! Int
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
                    }
                    if(holeCount>8){
                        self.dataArray[i].holeShotsArray = self.holeShots
                    }
                    else{
                        feedNumber.append(feedID)
                    }
                    group.leave()
                    
                }
            }
        }
        
        //        DispatchQueue.main.async( execute: {
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
            
            var height = 0
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
            
            self.togetherTblView.delegate = self
            self.togetherTblView.dataSource = self
            self.togetherTblView.reloadData()
            
            self.progressView.hide(navItem: self.navigationItem)
            
            var yOffset = 0
            for i in 0..<self.dataArray.count{
                let feeds = self.dataArray[i]
                if(feeds.location == nil){
                    yOffset += 440
                }else if ((feeds.holeShotsArray?.count == 9)){
                    yOffset += 190
                }else{
                    yOffset += 260
                }
                if(feeds.feedId! == friendNotifFeedId){
                    self.scrollView.scrollRectToVisible(CGRect(x: self.scrollView.frame.origin.x, y: CGFloat(yOffset), width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height), animated: true)
                    break
                }
            }
        }
    }
    
    // MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        friendNotifFeedId = ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
    }
    
        func numberOfSections(in tableView: UITableView) -> Int{
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
//            if section == 0 {
//                return 1
//            }
//            else{
                return dataArray.count
           // }
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
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            if indexPath.section == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "TogetherTopVIewCell", for: indexPath as IndexPath) as! TogetherTopVIewCell
//
//                let stringData = self.percentile == 11 ? "Please play one game to see your ranks" : "You scored better than \(self.percentile)% of Golfers"
//                cell.lblAvrgFromLastRounds.text = stringData
//                cell.swingsRankValue.text = String(self.drivingRankStr)
//                cell.roundPlayerRankValue.text = "-"
//                if(roundsRank != 0){
//                    cell.roundPlayerRankValue.text = self.roundsRankStr
//                }
//
//                cell.strokesGainedPuttingRankValue.text = String(self.puttingRankStr)
//                let value = [10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0]
//                cell.totalScorePercentileBar.setBarChartForTogether(dataPoints: [String](), values: value, chartView: (cell.totalScorePercentileBar)!, color: UIColor.glfWhite, barWidth: 0.2, whichValue: Int(self.percentile)/10)
//                return cell
//            }
//            else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TogetherFeedViewCell", for: indexPath as IndexPath) as! TogetherFeedViewCell

            let imageGesture = UITapGestureRecognizer(target: self, action: #selector(self.usrProfileImageTapped(_:)))
            cell.userImg.isUserInteractionEnabled = true
            cell.userImg.tag = indexPath.row
            cell.userImg.addGestureRecognizer(imageGesture)
            
                //cell.backgroundColor = UIColor.glfBluegreen
               // if(dataArray.count > 0){
                let feeds = dataArray[indexPath.row]
            
            if(feeds.feedId! == friendNotifFeedId){
                cell.cardView.layer.borderWidth = 1.0
                cell.cardView.layer.borderColor = UIColor.glfGreen.cgColor
            }
            else{
                cell.cardView.layer.borderColor = UIColor.clear.cgColor
            }
            
            cell.userName.text = feeds.userName
            cell.userImg.setCircle(frame: cell.userImg.frame)
            cell.userImg.image = UIImage(named:"you")
            cell.userImg.backgroundColor = UIColor.lightGray
            if (feeds.userImage != nil) {
                cell.userImg.sd_setImage(with: URL(string: feeds.userImage!), placeholderImage:#imageLiteral(resourceName: "you"), completed: nil)
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
                        cell.lblSharedMsg.isHidden = false

                        let subtitle = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
//                        if((feeds.location) != nil){
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
                //btnScoreCard
                    // ------------------------------------------------------------------------------------------------------
//                    let gestureCardView = UITapGestureRecognizer(target: self, action:  #selector (self.showFinalScores (_:)))
//                    cell.stackViewToClick.tag = indexPath.row
//                    cell.stackViewToClick.addGestureRecognizer(gestureCardView)
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
                    cell.btnDelete.tag = indexPath.row
            
                    cell.btnLike.addTarget(self, action: #selector(self.btnActionLike(_:)), for: .touchUpInside)
                    cell.btnShare.addTarget(self, action: #selector(self.btnActionShare(_:)), for: .touchUpInside)
                    cell.btnDelete.addTarget(self, action: #selector(self.btnActionDelete(_:)), for: .touchUpInside)

                if (feeds.userKey == Auth.auth().currentUser!.uid) {
                    cell.btnDelete.isHidden = false
                  }
                else
                 {
                    cell.btnDelete.isHidden = true
                 }
                    self.cardViewMArray.add(cell.cardView)
                //}
                return cell
            //}
        }
    
    // MARK: - usrProfileImageTapped
    @objc func usrProfileImageTapped(_ sender:UITapGestureRecognizer){
        let index = (sender.view?.tag)!
        let feeds = dataArray[index]

        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileVC
        viewCtrl.userKey = feeds.userKey!
        self.navigationController?.pushViewController(viewCtrl, animated: true)
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
    //MARK: - Like, Share & Delete
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
            
            
        }else{
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
    
    @objc func btnActionShare(_ sender:UIButton){
        let tagVal = sender.tag
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ShareStatsVC") as! ShareStatsVC
        viewCtrl.shareCardView = (cardViewMArray[tagVal] as! CardView)
        viewCtrl.fromFeed = true
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        navCtrl.modalPresentationStyle = .overCurrentContext
        self.present(navCtrl, animated: false, completion: nil)
    }
    @objc func btnActionDelete(_ sender:UIButton){
        
        // Remove from Friend List
        let alert = UIAlertController(title: "Alert", message: "Are you sure to remove this post from public feeds?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            // Do Nothing
            debugPrint("Cancel Alert: \(alert?.title ?? "")")
            
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [weak alert] (_) in
            debugPrint("ok :\(alert?.title ?? "")")
            
            let tagVal = sender.tag
            debugPrint("feedId",self.dataArray[tagVal].feedId)
            ref.child("feedData/\(self.dataArray[tagVal].feedId!)/").updateChildValues(["deleted" :true] as [AnyHashable:Any])
            
            self.dataArray.remove(at: tagVal)
            self.togetherTblView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func showFinalScores(_ sender:UIButton){
        // do other task
         let index = sender.tag//{
            if(dataArray.count > Int(index)){

            if let matchID = dataArray[index].matchId{
                debugPrint(matchID)
                self.getScoreFromMatchDataScoring(matchId:matchID)
                }
            }
        //}
    }

    func getScoreFromMatchDataScoring(matchId:String){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
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
                self.progressView.hide(navItem: self.navigationItem)

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
}
