//
//  SearchPlayerVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 05/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks

var selectedIndex = NSMutableArray()
var addPlayersArray = NSMutableArray()

class SearchPlayerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: Set Outlets
    var invitationUrl : URL!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnAddGuest: UIButton!
    @IBOutlet weak var tablePlayer: UITableView!
    
    @IBOutlet weak var nameSearchBar: UISearchBar!
    
    @IBOutlet weak var btnOneUsr: UIButton!
    @IBOutlet weak var btnTwoUsr: UIButton!
    @IBOutlet weak var btnThreeUsr: UIButton!
    @IBOutlet weak var btnFourUsr: UIButton!
    @IBOutlet weak var btnFiveUsr: UIButton!
    
    @IBOutlet weak var btnInfo: UIButton!

    @IBOutlet weak var lblSelectedPlayer: UILabel!
    
    let progressView = SDLoader()

    // MARK: Data Variables
    
    var userListMArray = NSMutableArray()
    var allUserListMArray = NSMutableArray()
    
    var friendMArray = NSMutableArray()
    var totalFriends: Int = 0
    var isSearching = Bool()
    var selectedBtnArray = [UIButton]()
    //UIFont(name: "SFProDisplay-Regular", size: 19.0)
    var attrs = [
        NSAttributedStringKey.font : UIFont(name: "SFProDisplay-Regular", size: 13.0)!,
        NSAttributedStringKey.foregroundColor : UIColor.glfFlatBlue,
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    var attributedString = NSMutableAttributedString(string:"")

    var selectedMode = 0
    var selectedTab = 0

    @IBAction func infoAction(_ sender: UIButton) {
        let emptyAlert = UIAlertController(title: "Guest Player", message: "Playing with someone not yet using Golfication? Create a guest player! You can later invite them via email or SMS to claim this account.", preferredStyle: UIAlertControllerStyle.alert)
        emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(emptyAlert, animated: true, completion: nil)
    }
    
    // MARK: Remove Selected Players
    
    @IBAction func continueAction(_ sender: UIButton) {
        addPlayersArray.removeAllObjects()
        addPlayersArray = NSMutableArray()
        
        if selectedIndex.count>0{
            
            for i in 0..<self.allUserListMArray.count{
                
                let timestamp = (allUserListMArray[i] as AnyObject).object(forKey:"timestamp")
                
                //                print("timestamp",timestamp ?? "")
                
                if !((timestamp as? String) == "" || timestamp == nil)
                {
                    for j in 0..<selectedIndex.count{
                        
                        if (selectedIndex[j] as? Int == timestamp as? Int) {
                            let tempdic = NSMutableDictionary()
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"name")!, forKey: "name" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"image")!, forKey: "image" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"timestamp")!, forKey: "timestamp" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"id")!, forKey: "id" as NSCopying)
                            
                            addPlayersArray.add(tempdic)
                        }
                    }
                }
            }
        }
        
        // ----- Call APi -------------------
        let gameCompleted = StartGameModeObj()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        if selectedTab == 0{
            // setup Classic Map
            NotificationCenter.default.addObserver(self, selector: #selector(self.classicCompleted(_:)), name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: nil)
            gameCompleted.setUpClassicMap(onCourse: selectedMode)
        }
        else if selectedTab == 1 && selectedMode == 0{
            // setup rangefinder
            NotificationCenter.default.addObserver(self, selector: #selector(self.rfApiCompleted(_:)), name: NSNotification.Name(rawValue: "RFApiCompleted"), object: nil)
            
            let golfId = "course_\(selectedGolfID)"
            var isBot = false
            if addPlayersArray.count>0{
                for data in addPlayersArray{
                    let player = data as! NSMutableDictionary
                    let id = player.value(forKey: "id")
                    if id as! String == "jpSgWiruZuOnWybYce55YDYGXP62"{
                        isBot = true
                        let alert = UIAlertController(title: "Alert", message: "Deejay Bot is only available in Advanced scoring.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    }
                }
                if(!isBot){
                    gameCompleted.setUpRFMap(golfId: golfId, onCourse: selectedMode)
                }
            }else{
                gameCompleted.setUpRFMap(golfId: golfId, onCourse: selectedMode)
            }
        }
        else{
            // setup post game short tracker or ultimate short tracking
            NotificationCenter.default.addObserver(self, selector: #selector(self.defaultMapApiCompleted(_:)), name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: nil)
            gameCompleted.showDefaultMap(onCourse: selectedMode)
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

    @IBAction func removePlayerAction(_ sender: UIButton) {
        
        if selectedIndex.count>0 && !(sender.tag == 0){
            
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to remove this Player?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                // Do Nothing
                //                print("Cancel Alert: \(alert?.title ?? "")")
                
            }))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                //                print("Ok Alert: \(alert?.title ?? "")")
                
                for i in 0..<selectedIndex.count{
                    
                    if !(sender.tag == 0){
                        
                        if sender.tag == selectedIndex[i] as! Int {
                            for i in 0..<addPlayersArray.count{
                                if sender.tag == (addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as! Int {
                                    
                                    addPlayersArray.removeObject(at: i)
                                    break
                                }
                            }

                            sender.tag = 0
                            sender.setTitle("", for: .normal)
                            sender.setBackgroundImage(UIImage(named:""), for: .normal)

                            selectedIndex.removeObject(at: i)
                            
                            self.lblSelectedPlayer.text = "Selected Players (" + String(selectedIndex.count) + ")"
                            self.tablePlayer.reloadData()
                        }
                    }
                }
                
                /*for i in 0..<addPlayersArray.count{
                    if !(sender.tag == 0){
                        if sender.tag == (addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as! Int {
                            
                            addPlayersArray.removeObject(at: i)
                            break
                        }
                    }
                }*/
                // ---- Shift Image Buttons  -------
                
                for i in 0..<self.selectedBtnArray.count{
                    
                    if i != 4{
                        self.selectedBtnArray[i].setTitle("", for: .normal)
                        self.selectedBtnArray[i].setBackgroundImage(UIImage(named:""), for: .normal)

                        self.selectedBtnArray[i].tag = 0
                    }
                }
                
                for i in 0..<selectedIndex.count{
                    
                    for j in 0..<self.allUserListMArray.count{
                        
                        if let timestamp = (self.allUserListMArray[j] as AnyObject).object(forKey:"timestamp") as? Int{
                            if (selectedIndex[i] as! Int == timestamp) {
                                
                                let imgUrl = URL(string:((self.allUserListMArray[j] as AnyObject).object(forKey:"image") as? String)!)
                                if imgUrl == nil{
                                    
                                    let name = (self.allUserListMArray[j] as AnyObject).object(forKey:"name") as? String
                                    self.selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                                }
                                else{
                                    self.selectedBtnArray[i].sd_setBackgroundImage(with: imgUrl, for: .normal, completed: nil)
                                }
                                self.selectedBtnArray[i].tag = timestamp
                            }
                        }
                    }
                }
                //--------------------------
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Add Guest Action
    
    @IBAction func addGuestAction(_ sender: Any) {
        if selectedIndex.count>3 {
            
            let emptyAlert = UIAlertController(title: "Alert", message: "You can choose maximum 4 friends", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Guest Player", message: "", preferredStyle: .alert)
            let userId = ref!.child("friends").childByAutoId().key

            alert.addTextField { (textField) in
                textField.placeholder = "Name"
                textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "Add & Invite", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]

                if textField?.text == ""{
                    
                    let emptyAlert = UIAlertController(title: "Error", message: "Please Enter Name", preferredStyle: UIAlertControllerStyle.alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
                else{
                    let text = "Hi \(textField?.text! ?? ""), \(Auth.auth().currentUser?.displayName ?? "") wants you to try Golfication."
//                    var link = NSURL(string: "https://itunes.apple.com/in/app/golfication-scorecard-stats-and-golf-social/id1216612467?mt=8")
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    let link = URL(string: "https://p5h99.app.goo.gl/mVFa?invitedby=\(uid)//\(userId)")
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
                        activityViewController.completionWithItemsHandler = {
                            (s, ok, items, error) in
                            if ok{
                                self.sendFriendDataToFirebase(usrName: (textField?.text)!, userId: userId)
                            }
                        }

                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                //                print("Add: \(textField?.text ?? "")")
                
                if textField?.text == ""{
                    
                    let emptyAlert = UIAlertController(title: "Error", message: "Please Enter Name", preferredStyle: UIAlertControllerStyle.alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
                else{
                    
                    self.sendFriendDataToFirebase(usrName: (textField?.text)!, userId: userId)
                    
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func sendFriendDataToFirebase(usrName: String,userId:String){
        
        let userDataDic = NSMutableDictionary()
        let userIdDic = NSMutableDictionary()
        let userListDic = NSMutableDictionary()
        
        
        userDataDic.setObject(usrName , forKey: "name" as NSCopying)
        userDataDic.setObject("" , forKey: "image" as NSCopying)
        userDataDic.setObject(self.Timestamp , forKey: "timestamp" as NSCopying)
        userDataDic.setObject(userId , forKey: "id" as NSCopying)
        
        let myAuthId = Auth.auth().currentUser?.uid
        
        userIdDic.setObject(true, forKey: userId as NSCopying)
        ref.child("userData/\(myAuthId!)/friends").updateChildValues(userIdDic as! [AnyHashable : Any])
        ref.child("userData/\(myAuthId!)/invite").updateChildValues([userId:false])
        userListDic.setObject(userDataDic, forKey: userId as NSCopying)
        ref.child("userList").updateChildValues(userListDic as! [AnyHashable : Any])
        
        // ----- update table first row & Selected Player -------//
        
        self.friendMArray.insert(userDataDic, at: 0)
        self.totalFriends = self.friendMArray.count
        
        //selectedIndex.insert(self.Timestamp, at: 0)
        selectedIndex.insert((self.friendMArray[0] as AnyObject).object(forKey:"timestamp")!, at: 0)
        
        let tempdic = NSMutableDictionary()
        tempdic.setObject((self.friendMArray[0] as AnyObject).object(forKey:"name")!, forKey: "name" as NSCopying)
        tempdic.setObject((self.friendMArray[0] as AnyObject).object(forKey:"image")!, forKey: "image" as NSCopying)
        tempdic.setObject((self.friendMArray[0] as AnyObject).object(forKey:"timestamp")!, forKey: "timestamp" as NSCopying)
        tempdic.setObject((self.friendMArray[0] as AnyObject).object(forKey:"id")!, forKey: "id" as NSCopying)
        addPlayersArray.insert(tempdic, at: 0)
        
//        addPlayersArray.insert((self.friendMArray[0] as AnyObject).object(forKey:"timestamp")!, at: 0)
//        addPlayersArray.insert((self.friendMArray[0] as AnyObject).object(forKey:"name")!, at: 0)
//        addPlayersArray.insert((self.friendMArray[0] as AnyObject).object(forKey:"image")!, at: 0)
//        addPlayersArray.insert((self.friendMArray[0] as AnyObject).object(forKey:"id")!, at: 0)
        
        for i in 0..<selectedIndex.count{
            
            if self.selectedBtnArray[i].tag == 0 {
                
                let timestamp = (self.friendMArray[0] as AnyObject).object(forKey:"timestamp")!
                
                self.selectedBtnArray[i].setTitle((self.friendMArray[0] as AnyObject).object(forKey:"name") as? String, for: .normal)
                
                self.selectedBtnArray[i].tag = timestamp as! Int
                
            }
        }
        self.lblSelectedPlayer.text = "Selected Players (" + String(selectedIndex.count) + ")"
        
        self.tablePlayer.reloadData()
    }
    
    var Timestamp: Int {
        return Int(NSDate().timeIntervalSince1970*1000)
    }
    
    // MARK: Done Action
    /*@IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        addPlayersArray.removeAllObjects()
        addPlayersArray = NSMutableArray()
        
        if selectedIndex.count>0{
            
            for i in 0..<self.allUserListMArray.count{
                
                let timestamp = (allUserListMArray[i] as AnyObject).object(forKey:"timestamp")
                
                //                print("timestamp",timestamp ?? "")
                
                if !((timestamp as? String) == "" || timestamp == nil)
                {
                    for j in 0..<selectedIndex.count{
                        
                        if (selectedIndex[j] as? Int == timestamp as? Int) {
                            let tempdic = NSMutableDictionary()
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"name")!, forKey: "name" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"image")!, forKey: "image" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"timestamp")!, forKey: "timestamp" as NSCopying)
                            tempdic.setObject((allUserListMArray[i] as AnyObject).object(forKey:"id")!, forKey: "id" as NSCopying)
                            
                            addPlayersArray.add(tempdic)
                        }
                    }
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }*/
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        self.title = "Add Friend"
        // Do any additional setup after loading the view.
        btnInfo.setCircle(frame: btnInfo.frame)
        btnContinue.setCorner(color: UIColor.clear.cgColor)
        
        let buttonTitleStr = NSMutableAttributedString(string: "Add Guest Player", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnAddGuest.setAttributedTitle(attributedString, for: .normal)

        //btnFiveUsr.backgroundColor = UIColor.clear
        selectedBtnArray = [btnOneUsr, btnTwoUsr, btnThreeUsr, btnFourUsr, btnFiveUsr]
        for btn in selectedBtnArray{
            btn.setCircle(frame: btn.frame)
        }
        if let img = Auth.auth().currentUser?.photoURL{
            selectedBtnArray[4].sd_setBackgroundImage(with: img, for: .normal, completed: nil)
        }
        else{
            if let name = Auth.auth().currentUser?.displayName{
                selectedBtnArray[4].setTitle(String(name[0]), for: .normal)
            }
        }
        selectedBtnArray[4].tag = 0
        self.tablePlayer.allowsMultipleSelection = true
        for i in 0..<addPlayersArray.count{
            if let img = (addPlayersArray[i] as AnyObject).object(forKey: "image") as? String{
                if(img != ""){
                    let imgUrl = URL(string:img)
                    selectedBtnArray[i].sd_setBackgroundImage(with:imgUrl, for: .normal, completed: nil)
                }
                else{
                    let name = (addPlayersArray[i] as AnyObject).object(forKey: "name") as? String
                    selectedBtnArray[i].setTitle("\(String(name![0]))", for: .normal)
                }
            }
        }
        self.getFriendDataFromFireBase()
    }
    
    func getFriendDataFromFireBase() {
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "\(Auth.auth().currentUser?.uid ?? "user2")/friends") { (snapshot) in

            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            let group = DispatchGroup()
            
            for (key, _) in dataDic{
                group.enter()
                
                self.friendMArray.removeAllObjects()
                self.friendMArray = NSMutableArray()
                
                ref.child("userList/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        let dataDic = (snapshot.value as? NSDictionary)!
                        let tempdic = NSMutableDictionary()
                        tempdic.setObject(key , forKey: "id" as NSCopying)
                        tempdic.setObject(dataDic.value(forKey: "name") ?? "", forKey: "name" as NSCopying)
                        tempdic.setObject(dataDic.value(forKey: "image") ?? "", forKey: "image" as NSCopying)
                        tempdic.setObject(dataDic.value(forKey: "timestamp") ?? "", forKey: "timestamp" as NSCopying)
                        self.friendMArray.add(tempdic)
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main, execute: {
                self.progressView.hide(navItem: self.navigationItem)

                let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                let array: NSArray = self.friendMArray.sortedArray(using: [sortDescriptor]) as NSArray
                
                self.friendMArray.removeAllObjects()
                self.friendMArray = NSMutableArray()
                self.friendMArray = array.mutableCopy() as! NSMutableArray
                
                self.totalFriends = self.friendMArray.count
                
                // ----- Set Selected Players if any --------
                if addPlayersArray.count>0{
                    
                    selectedIndex.removeAllObjects()
                    selectedIndex = NSMutableArray()
                    
                    for i in 0..<self.selectedBtnArray.count{
                        
                        if i != 4{
                            self.selectedBtnArray[i].setTitle("", for: .normal)
                            self.selectedBtnArray[i].tag = 0
                        }
                    }
                    
                    for i in 0..<addPlayersArray.count{
                        
                        let timeStamp = (addPlayersArray[i] as AnyObject).object(forKey:"timestamp")!
                        
                        //                        ((self.selectedBtnArray[i]) as! UIButton).setTitle((addPlayersArray[i] as AnyObject).object(forKey:"name") as? String, for: .normal)
                        
                        self.selectedBtnArray[i].tag = timeStamp as! Int
                        
                        selectedIndex.add(timeStamp)
                    }
                    self.lblSelectedPlayer.text = "Selected Players (" + String(addPlayersArray.count) + ")"
                }
                else{
                    selectedIndex.removeAllObjects()
                    selectedIndex = NSMutableArray()
                }
                self.tablePlayer.reloadData()
                
                self.getUserListData()
            })
        }
    }
    
    func getUserListData() {
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userList") { (snapshot) in
            let matchDic = (snapshot.value as? NSDictionary)!
            
            self.allUserListMArray.removeAllObjects()
            self.allUserListMArray = NSMutableArray()
            
            //            self.allUserListMArray.addObjects(from: matchDic.allValues)
            
            for (key, value)in matchDic{
                let allValues = value as! NSDictionary
                
                if((key as! String) != Auth.auth().currentUser!.uid){
                    if let tmstmap = allValues.value(forKey: "timestamp") as? Int{
                        let tempdic = NSMutableDictionary()
                        tempdic.setObject(key as! String, forKey: "id" as NSCopying)
                        tempdic.setObject(allValues.value(forKey: "name") ?? "", forKey: "name" as NSCopying)
                        tempdic.setObject(allValues.value(forKey: "image") ?? "", forKey: "image" as NSCopying)
                        tempdic.setObject(tmstmap,forKey:"timestamp" as NSCopying)
                        self.allUserListMArray.add(tempdic)
                    }
                }
            }
            self.totalFriends = self.allUserListMArray.count
            //            print("allUserListMArray== ",self.allUserListMArray)
            
        }
    }
    
    // MARK: Refresh Friends
    
    @objc func refreshFriends(_ sender: UIButton!) {
        
        isSearching = false
        nameSearchBar.resignFirstResponder()
        nameSearchBar.text = ""
        
        self.getFriendDataFromFireBase()
    }
    
    // MARK: Table View Data Source & Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return userListMArray.count;
        }
        else{
            return friendMArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame: CGRect = tableView.frame
        
        let lblFriends = UILabel()
        lblFriends.frame = CGRect(x: 10, y: 0, width: 150, height: 28)
        lblFriends.font = UIFont.systemFont(ofSize: 15)
        lblFriends.backgroundColor = UIColor.clear
        if (isSearching) {
            lblFriends.text = "Search Results (" + String(totalFriends) + ")"
            
        }
        else{
            lblFriends.text = "Your Friends (" + String(totalFriends) + ")"
        }
        
        
        let btnFriends: UIButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 80, y: 0, width: 70, height: 28))
        btnFriends.setTitle("Friends", for: .normal)
        btnFriends.setTitleColor(UIColor(rgb: 0x008F63), for: .normal)
        btnFriends.backgroundColor = UIColor.clear
        btnFriends.addTarget(self, action: #selector(SearchPlayerVC.refreshFriends(_:)), for: .touchUpInside)
        
        let viewHeader = UIView()
        viewHeader.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 30)
        viewHeader.backgroundColor = UIColor.white
        viewHeader.isUserInteractionEnabled = true
        
        viewHeader.addSubview(lblFriends)
        viewHeader.addSubview(btnFriends)
        
        return viewHeader
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let  cell = tableView.dequeueReusableCell(withIdentifier: "TogetherTopVIewCell") as! TogetherTopVIewCell!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playersTableViewCell", for: indexPath as IndexPath) as! PlayersTableViewCell
        
        cell.isSelected = false
        cell.tintColor = UIColor.gray
        tableView.deselectRow(at: indexPath, animated: true)
        let timestamp: Int64
        if (isSearching) {
            
            timestamp = (userListMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")! as! Int64
            
        }
        else{
            timestamp = (friendMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")! as! Int64
        }
        
        for i in 0..<selectedIndex.count{
            if (selectedIndex[i] as! Int == timestamp) {
                cell.isSelected = true
                cell.tintColor = UIColor.green
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        
        if selectedIndex.count == 0 {
            cell.isSelected = false
            cell.tintColor = UIColor.gray
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if (isSearching) {
            if let str = (userListMArray[indexPath.row] as AnyObject).object(forKey:"image") as? String{
                cell.playerImage.sd_setImage(with: URL(string:str), placeholderImage: #imageLiteral(resourceName: "you"), options: .continueInBackground, completed: nil)
            }
            cell.playerName?.text = (userListMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
        }
        else{
            if let str = (friendMArray[indexPath.row] as AnyObject).object(forKey:"image") as? String{
                cell.playerImage.sd_setImage(with: URL(string:str), placeholderImage: #imageLiteral(resourceName: "you"), options: .continueInBackground, completed: nil)
            }


            cell.playerName?.text = (friendMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
        }
        cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedIndex.count>3 {
            
            let emptyAlert = UIAlertController(title: "Alert", message: "You can choose maximum 4 friends", preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(emptyAlert, animated: true, completion: nil)
            
            let cell = tableView.cellForRow(at: indexPath)
            
            cell?.tintColor = UIColor.gray
            cell?.isSelected = false
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.deselectRow(at: indexPath, animated: true)
            
        }

        else{
            let cell = tableView.cellForRow(at: indexPath)
            
            cell?.tintColor = UIColor.green
            cell?.isSelected = true
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            
            let timestamp:Int
            var name = String()
            var image = String()
            var playerId = String()
            
            if (isSearching) {
                timestamp = (userListMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")!  as! Int
                name = (userListMArray[indexPath.row] as AnyObject).object(forKey:"name") as! String
                image = (userListMArray[indexPath.row] as AnyObject).object(forKey:"image") as! String
                playerId = (userListMArray[indexPath.row] as AnyObject).object(forKey:"id") as! String
            }
            else{
                timestamp = (friendMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")!  as! Int
                name = ((friendMArray[indexPath.row] as AnyObject).object(forKey:"name")) as? String ?? ""
                image = ((friendMArray[indexPath.row] as AnyObject).object(forKey:"image")) as? String ?? ""
                playerId = ((friendMArray[indexPath.row] as AnyObject).object(forKey:"id"))  as? String ?? ""
            }
            
            selectedIndex.add(timestamp)
            
            let tempdic = NSMutableDictionary()
            tempdic.setObject(name, forKey: "name" as NSCopying)
            tempdic.setObject(image, forKey: "image" as NSCopying)
            tempdic.setObject(timestamp, forKey: "timestamp" as NSCopying)
            tempdic.setObject(playerId, forKey: "id" as NSCopying)
            
            addPlayersArray.add(tempdic)
            
            lblSelectedPlayer.text = "Selected Players (" + String(selectedIndex.count) + ")"
            
            for i in 0..<selectedIndex.count{
                
                if selectedBtnArray[i].tag == 0 {
                    if (isSearching) {
                        
                        if let img = (userListMArray[indexPath.row] as AnyObject).object(forKey:"image") as? String{
                            let imgUrl = URL(string:img)
                            selectedBtnArray[i].sd_setBackgroundImage(with: imgUrl, for: .normal, completed: nil)
                            if img == ""{
                                let name = (userListMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
                                selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                            }
                        }
                        else{
                            let name = (userListMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
                            selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                        }
                    }
                    else{
                        if let img = (friendMArray[indexPath.row] as AnyObject).object(forKey:"image") as? String{
                            let imgUrl = URL(string:img)
                            selectedBtnArray[i].sd_setBackgroundImage(with: imgUrl, for: .normal, completed: nil)
                            if img == ""{
                                let name = (friendMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
                                selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                            }
                        }
                        else{
                            let name = (friendMArray[indexPath.row] as AnyObject).object(forKey:"name") as? String
                            selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                        }
                    }
                    selectedBtnArray[i].tag = timestamp
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.tintColor = UIColor.gray
        cell?.isSelected = false
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        let timestamp: Int
        if (isSearching) {
            timestamp = (userListMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")! as! Int
        }
        else{
            timestamp = (friendMArray[indexPath.row] as AnyObject).object(forKey:"timestamp")! as! Int
        }
        
        
        /*for i in 0..<selectedIndex.count{
         
         if selectedIndex[i] as! Int == timestamp {
         
         for j in 0..<selectedBtnArray.count{
         
         if ((selectedBtnArray[j]) as! UIButton).tag == selectedIndex[i]  as! Int{
         
         ((selectedBtnArray[j]) as! UIButton).setTitle("", for: .normal)
         ((selectedBtnArray[j]) as! UIButton).tag = 0
         }
         }
         }
         }*/
        
        selectedIndex.remove(timestamp)
        
        for i in 0..<addPlayersArray.count{
            
            if timestamp == (addPlayersArray[i] as AnyObject).object(forKey:"timestamp") as! Int{
                addPlayersArray.removeObject(at: i)
                break
            }
        }
        
        // ---- Shift Image Buttons  -------
        
        for i in 0..<self.selectedBtnArray.count{
            if i != 4{
                self.selectedBtnArray[i].setTitle("", for: .normal)
                self.selectedBtnArray[i].setBackgroundImage(UIImage(named:""), for: .normal)
                self.selectedBtnArray[i].tag = 0
                self.selectedBtnArray[i].setBackgroundImage(nil, for: .normal)
            }
        }
        
        for i in 0..<selectedIndex.count{
            
            for j in 0..<self.allUserListMArray.count{
                
                let timestamp = (self.allUserListMArray[j] as AnyObject).object(forKey:"timestamp")
                
                //                print("timestamp",timestamp ?? "")
                
                if !((timestamp as? String) == "" || timestamp == nil){
                    if (selectedIndex[i] as? Int == timestamp as? Int) {
                        
                        let imgUrl = URL(string:((self.allUserListMArray[j] as AnyObject).object(forKey:"image") as? String)!)
                        if imgUrl == nil{
                            let name = (self.allUserListMArray[j] as AnyObject).object(forKey:"name") as? String
                            self.selectedBtnArray[i].setTitle(String(name![0]), for: .normal)
                        }
                        else{
                            self.selectedBtnArray[i].sd_setBackgroundImage(with: imgUrl, for: .normal, completed: nil)
                        }
                        self.selectedBtnArray[i].tag = timestamp as! Int
                    }
                }
            }
        }
        
        //------------------------------
        
        lblSelectedPlayer.text = "Selected Players (" + String(selectedIndex.count) + ")"
        
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
    }
    
    /*func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        
        if(!(searchText.count == 0)) {
            self.isSearching = true
            //if searchText.count >= 3{
            userListMArray.removeAllObjects()
            userListMArray = NSMutableArray()
            self.searchTableList()
            //}
        }
        else {
            self.isSearching = false
        }
        self.tablePlayer.reloadData()
    }*/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.count == 0) {
            isSearching = true
            userListMArray.removeAllObjects()
            userListMArray = NSMutableArray()
            self.searchTableList()
        }
        searchBar.resignFirstResponder()
        self.tablePlayer.reloadData()
    }
    
    // MARK: Search Table List Function
    func searchTableList() {
        
        let predicate: NSPredicate = NSPredicate(format: "name contains[c] %@", nameSearchBar.text!)
        
        for j in 0..<self.allUserListMArray.count{
            userListMArray.add(self.allUserListMArray[j])
        }
        let filtered = userListMArray.filtered(using: predicate)
        
        if filtered.count>0 {
            userListMArray.removeAllObjects()
            userListMArray = NSMutableArray()
            userListMArray.addObjects(from: filtered)
        }
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
}
}
