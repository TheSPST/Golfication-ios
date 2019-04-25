//
//  NotificationVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 02/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var notifTableView: UITableView!

    var notifMArray = NSMutableArray()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    let progressView = SDLoader()
    
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !(appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Notifications"
        let userId = Auth.auth().currentUser?.uid
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "notifications/\(userId ?? "")") { (snapshot) in
            var dataDic = NSDictionary()
            if let data = (snapshot.value as? NSDictionary){
                dataDic = data
            }
            
            
            self.notifMArray.removeAllObjects()
            self.notifMArray = NSMutableArray()
            for i in 0..<dataDic.allValues.count{
                if (((dataDic.allValues[i] as AnyObject).value(forKey: "timestamp") as? String) != nil) {
                    self.notifMArray.add(dataDic.allValues[i])
                }
            }
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            let array: NSArray = self.notifMArray.sortedArray(using: [sortDescriptor]) as NSArray
            
            self.notifMArray.removeAllObjects()
            self.notifMArray = NSMutableArray()
            self.notifMArray = array.mutableCopy() as! NSMutableArray
            
                let group = DispatchGroup()
                for i in 0..<self.notifMArray.count{
                    group.enter()
                    let dic = self.notifMArray[i] as! NSMutableDictionary
                    
                    if dic.value(forKey: "sender") as! String != "golfication"{
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userList/\((dic.value(forKey: "sender") as! String))/image") { (snapshot) in
                            if(snapshot.value != nil){
                                dic.setValue(snapshot.value as! String, forKey: "image")
                                self.notifMArray.replaceObject(at: i, with: dic)
                            }
                            else{
                                dic.setValue("you", forKey: "image")
                                self.notifMArray.replaceObject(at: i, with: dic)
                            }
                            group.leave()
                        }
                    }
                    else{
                        dic.setValue("golfication", forKey: "image")
                        self.notifMArray.replaceObject(at: i, with: dic)
                        group.leave()
                    }
                }
            group.notify(queue: .main) {
                
                if(self.notifMArray.count > 0){
                    self.notifTableView.delegate = self
                    self.notifTableView.dataSource = self

                    self.notifTableView.reloadData()
                }else{
                    let label = UILabel(frame:CGRect(x:0,y:0,width:200,height:30))
                    label.text = "No Notification Available"
                    label.center = self.view.center
                    self.view.addSubview(label)
                }
                self.progressView.hide(navItem: self.navigationItem)
            }
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "View Notification")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 105.0 + 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifMArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: "notificationViewCell") as! NotificationViewCell
        cell.backgroundColor = UIColor.clear
        
        let checkRead = ((notifMArray[indexPath.row] as AnyObject) .object(forKey:"read") as! String)
        
        if checkRead == "0"{
            
            cell.bgView.layer.borderWidth = 1.0
            cell.bgView.layer.borderColor = UIColor.glfGreen.cgColor
        }
        else{
            cell.bgView.layer.borderColor = UIColor.clear.cgColor
        }
        
        let image = ((notifMArray[indexPath.row] as AnyObject).object(forKey:"image") as? String)?.trim()
        if(image == "golfication"){
                cell.userImageView.image = UIImage(named: ((notifMArray[indexPath.row] as AnyObject).object(forKey:"image") as! String))
        }
        else if(image == "you"){
            cell.userImageView.image = UIImage(named: ((notifMArray[indexPath.row] as AnyObject).object(forKey:"image") as! String))
        }
        else{
            cell.userImageView.sd_setImage(with: URL(string: ((notifMArray[indexPath.row] as AnyObject).object(forKey:"image") as! String)), placeholderImage:#imageLiteral(resourceName: "you"), completed: nil)
            if image == ""{
                cell.userImageView.image = #imageLiteral(resourceName: "you")
            }
        }
        cell.notifiactionMsg.text = ((self.notifMArray[indexPath.row] as AnyObject).object(forKey:"message") as! String)
        if let timeStamp = (notifMArray[indexPath.row] as AnyObject) .object(forKey:"timestamp") as? String {
            cell.timeAgoLbl.text = NSDate(timeIntervalSince1970:(Double(timeStamp)!/1000)).timeAgoSinceNow
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let readData = (self.notifMArray[indexPath.row] as AnyObject).object(forKey:"read") as? String{
            if readData == "0"{
                if let key = (self.notifMArray[indexPath.row] as AnyObject).object(forKey:"notificationKey") as? String{
                    ref.child("notifications/\(Auth.auth().currentUser!.uid)/\(key)/").updateChildValues(["read":"1"] as [AnyHashable:Any])
                    let obj = self.notifMArray[indexPath.row] as! NSMutableDictionary
                    obj.setValue("1", forKey: "read")
                    self.notifMArray.replaceObject(at: indexPath.row, with: obj)
                    self.notifTableView.reloadData()
                }
            }
        }
        
        let type = ((notifMArray[indexPath.row] as AnyObject).object(forKey:"type") as! String)
        if type == "8" {
            if let matchKey = (notifMArray[indexPath.row] as AnyObject).object(forKey:"swingKey") as? String{
                getScoreFromMatchDataScoring(matchId: matchKey)
            }
        }
        else if type == "9" {
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
            viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
            viewCtrl.fromIndiegogo = false
            viewCtrl.fromNotification = false
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else if type == "10" {
            
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MyFeedVC") as! MyFeedVC
            viewCtrl.feedKey = ((notifMArray[indexPath.row] as AnyObject).object(forKey:"feedKey") as! String)
            self.navigationController?.pushViewController(viewCtrl, animated: true)

        }
        else if type == "11" || type == "6" {
            
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileVC
            viewCtrl.userKey = ((self.notifMArray[indexPath.row] as AnyObject).object(forKey:"sender") as! String)
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else if type == "12" {
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            
            friendNotifFeedId = ((notifMArray[indexPath.row] as AnyObject).object(forKey:"feedKey") as! String)
            tabBarCtrl.selectedIndex = 1
        }
        else if type == "3" || type == "7"{
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            let gameController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            
            var playNavCtrl = UINavigationController()
            playNavCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            playNavCtrl.pushViewController(gameController, animated: true)
        }
        else{
            debugPrint("type",type)
        }
    }
    
    // MARK: - getScoreFromMatchDataScoring
    func getScoreFromMatchDataScoring(matchId:String){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        self.scoring.removeAll()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
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
                if(!self.scoring.isEmpty){
                    let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
                    viewCtrl.finalPlayersData = players
                    viewCtrl.finalScoreData = self.scoring
                    viewCtrl.isManualScoring = isManualScoring
                    viewCtrl.matchDataDict = matchDataDiction
                    viewCtrl.currentMatchId = matchId
                    self.navigationController?.pushViewController(viewCtrl, animated: true)
                }
            })
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView1: UIScrollView, willDecelerate decelerate: Bool)
    {
        let visibleIndexPaths: [IndexPath] = self.notifTableView.indexPathsForVisibleRows!
        for indexPath in visibleIndexPaths{
            let row = indexPath.row
            debugPrint("row==", row)
            
            if let readData = (self.notifMArray[row] as AnyObject).object(forKey:"read") as? String{
                if readData == "0"{
                    if let key = (self.notifMArray[row] as AnyObject).object(forKey:"notificationKey") as? String{
                        ref.child("notifications/\(Auth.auth().currentUser!.uid)/\(key)/").updateChildValues(["read":"1"] as [AnyHashable:Any])
                        let obj = self.notifMArray[row] as! NSMutableDictionary
                        obj.setValue("1", forKey: "read")
                        self.notifMArray.replaceObject(at: row, with: obj)
                        self.notifTableView.reloadData()
                    }
                }
            }
        }
    }
}
