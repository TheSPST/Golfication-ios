//
//  MyFeedVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 23/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyFeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var feedTableView: UITableView!
    
    var dataArray = [Feeds]()
    var holeShots = [HoleShotPar]()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    let borderWidth:CGFloat = 2.0
    var cardViewMArray = NSMutableArray()
    var feedKey = String()

    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        feedKey = ""
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getFeedDataFromFirebase()
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: - getFeedDataFromFirebase
    func getFeedDataFromFirebase(){
        if(self.dataArray.count == 0){
            FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "myFeeds") { (snapshot) in
                var dataDic = [String:Bool]()
                if(snapshot.childrenCount > 0){
                    dataDic = (snapshot.value as? [String : Bool])!
                }
                self.dataArray.removeAll()
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
        else{
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
        }
    }
    
    // MARK: - getScoreFromFirebaseMatchData
    func getScoreFromFirebaseMatchData(){
        
        let group = DispatchGroup()
        var feedNumber = [String]()
        for i in 0..<self.dataArray.count{
            if let matchID = dataArray[i].matchId{
                let userID = dataArray[i].userKey!
                let feedID = dataArray[i].feedId!
                
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
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
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
            /*var height = 260
            if(self.dataArray.count > 0){
                for i in 0..<self.dataArray.count{
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
            self.tableHeightConstraint.constant = CGFloat(height)
            self.view.layoutIfNeeded()*/
            
            if self.dataArray.count == 0{
                self.feedTableView.isHidden = true
            }
            else{
                self.feedTableView.isHidden = false
                self.feedTableView.reloadData()
                
                for i in 0..<self.dataArray.count{
                    let feeds = self.dataArray[i]
                    if(feeds.feedId! == self.feedKey){
                        self.feedTableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .middle, animated: true)
                        break
                    }
                }
            }
        }
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
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewHomeFeedViewCell", for: indexPath as IndexPath) as! NewHomeFeedViewCell
        let feeds = dataArray[indexPath.row]

        if(feeds.feedId == self.feedKey){
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
                cell.lblScoreTitle.text =  "\(anoterString) \(shotDetails) \(parSum)"
                if(shotSum-parSum) == 0{
                    cell.lblScoreTitle.text =  "Even par \(parSum)"
                }
           }
        }
        else{
            cell.lblScoreTitle.text = ""
            cell.lblSharedMsg.isHidden = false
            
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
        let gestureCardView = UITapGestureRecognizer(target: self, action:  #selector (self.showFinalScores (_:)))
        cell.stackViewToClick.tag = indexPath.row
        cell.stackViewToClick.addGestureRecognizer(gestureCardView)
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
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchID = dataArray[indexPath.row].matchId!
        self.getScoreFromMatchDataScoring(matchId:matchID)
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
    @objc func showFinalScores(_ sender:UITapGestureRecognizer){
        let index = sender.view?.tag
        if(dataArray.count > Int(index!)){
            if let matchID = dataArray[index!].matchId{
                self.getScoreFromMatchDataScoring(matchId:matchID)
            }
        }
    }
    
    // MARK: - getScoreFromMatchDataScoring
    func getScoreFromMatchDataScoring(matchId:String){
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        self.scoring.removeAll()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            self.view.isUserInteractionEnabled = false
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
