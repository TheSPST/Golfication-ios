//
//  SignInVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 20/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseAuth
import FirebaseInstanceID
import FBSDKCoreKit
import FBSDKLoginKit
import Google

//private let dataURL = "https://golficationtest.firebaseio.com"


class SignInVC: UIViewController, IndicatorInfoProvider {
    var isNewUser = Bool()
    var progressView = SDLoader()
    var userDetails = NSMutableDictionary()
    var friendsDetails = NSMutableDictionary()
    var userList = NSMutableDictionary()
    var appDelegate: AppDelegate!

    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPswd: UITextField!

    @IBOutlet weak var btnFb: UILocalizedButton!
    @IBOutlet weak var btnSignIn: UILocalizedButton!

    @IBAction func fbLoginAction(_ sender: UIButton) {
        
        if !(self.appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //https://www.appcoda.com/firebase-facebook-login/
            let fbLoginManager = FBSDKLoginManager()
            
            fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
                if let error = error {
                    debugPrint("Failed to login: \(error.localizedDescription)")
                    return
                }
                guard let accessToken = FBSDKAccessToken.current() else {
                    debugPrint("Failed to get access token")
                    return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                debugPrint(result!)
                // Perform login by calling Firebase APIs
                self.progressView.show()
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        //print("Login error: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        return
                    }
                    
                    let params = ["fields": "id, first_name, last_name, name, email, picture,gender"]
                    
                    var graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                        if ((error) != nil){
                            //print("Error: \(String(describing: error))")
                        }else{
                            let result = result as! NSDictionary
                            let fbId = result.value(forKey: "id") as! String
                            if let email = user?.email{
                                self.userDetails.setObject(email, forKey: "email" as NSCopying)
                            }
                            self.userDetails.setObject((user?.displayName)!, forKey: "name" as NSCopying)
                            self.userDetails.setObject(fbId, forKey: "fb_id" as NSCopying)
                            if let gender = result.value(forKey: "gender") as? String{
                                self.userDetails.setObject(gender, forKey: "gender" as NSCopying)
                            }
                            self.userDetails.setObject("\((user?.photoURL)!)", forKey: "image" as NSCopying)
                            if let iosToken = (InstanceID.instanceID().token()){
                                self.userDetails.setObject(iosToken,forKey: "iosToken" as NSCopying)
                            }
                            else{
                                self.userDetails.setObject("",forKey: "iosToken" as NSCopying)
                            }
                            self.userList.setObject("\((user?.photoURL)!)", forKey: "image" as NSCopying)
                            self.userList.setObject((user?.displayName)!, forKey: "name" as NSCopying)
                            self.userList.setObject(Int64(NSDate().timeIntervalSince1970*1000), forKey: "timestamp" as NSCopying)
                        }
                    })
                    
                    graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
                    let connection = FBSDKGraphRequestConnection()
                    connection.add(graphRequest, completionHandler: { (connection, result, error) in
                        if error == nil {
                            guard let userData = result as? [String : Any] else { return }
                            guard let jsonData = userData["data"] as? [[String : Any]] else { return }
                            debugPrint("facebook data", jsonData)
                            do {
                                _ = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)
                                for friends in jsonData{
                                    //print(" Id : \(friends["id"]!)")
                                    self.friendsDetails.setObject(true, forKey: "\(friends["id"]!)" as NSCopying)
                                }
                                // self.updateUserDataIntoFirebase(uid: (user?.uid)!)
                                
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        } else {
                            //print("Error Getting Friends \(String(describing: error))");
                        }
                    })
                    
                    connection.start()
                    
                    self.updateUserDataIntoFirebase(uid: (user!.uid), fbEmail: (user!.email ?? ""), fbName: (user!.displayName ?? ""))
                })
            }
        }
    }
    
    func updateUserDataIntoFirebase(uid:String, fbEmail:String, fbName:String){
        var device = false
        var proMode = false
        var isFirst = true
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "device") { (snapshot) in
            self.isNewUser = true
            if(snapshot.value != nil){
                device = (snapshot.value as? Bool)!
                self.isNewUser = false
            }
            UserDefaults.standard.set(self.isNewUser, forKey: "isNewUser")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async(execute: {
                FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMode") { (snapshot) in
                    self.isNewUser = true

                    if(snapshot.value != nil){
                        proMode = (snapshot.value as? Bool)!
                        isFirst = false
                        self.isNewUser = false
                    }
                    UserDefaults.standard.set(self.isNewUser, forKey: "isNewUser")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async(execute: {
                        self.userDetails.setObject(device, forKey: "device" as NSCopying)
                        self.userDetails.setObject(proMode, forKey: "proMode" as NSCopying)
                        if let locale = Locale.current.regionCode {
                            //self.userDetails.setObject(locale, forKey:"country" as NSCopying)
                            self.userList.setObject(locale, forKey:"country" as NSCopying)
                        }

                        if(uid.count > 1){
                            ref.child("userData/\(uid)").updateChildValues(self.userDetails as! [AnyHashable : Any])
                            ref.child("userList/\(uid)").updateChildValues(self.userList as! [AnyHashable : Any])
                            self.getUserDataFromFirebase(uid: uid, isFirst:isFirst)
                        }
                        
                       let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
                        if newUser{
                            if(referedBy != nil){
                                let referralNotification = NotificationForReferral()
                                referralNotification.checkReferralTimestampWithInvite(){success in
                                    ref.child("userData/\(referedBy!)/friends").updateChildValues([(Auth.auth().currentUser?.uid)!:true])
                                    ref.child("userData/\(referedBy!)/invite").updateChildValues([(Auth.auth().currentUser?.uid)!:true])
                                    ref.child("userData/\((Auth.auth().currentUser?.uid)!)/friends").updateChildValues([referedBy!:true])
                                }

                            }
                            let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewUserProfileVC") as! NewUserProfileVC
                            self.navigationController?.pushViewController(viewCtrl, animated: true)
                            self.progressView.hide()
                            self.sendMailingRequestToServer(uName: fbName,uEmail: fbEmail)
                        }
                        else{
                            self.progressView.hide()
                            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                            self.navigationController?.pushViewController(tabBarCtrl, animated: true)
                        }
                    })
                }
            })
        }
    }
    
    func sendMailingRequestToServer(uName: String, uEmail: String) {
        
        let serverHandler = ServerHandler()
        serverHandler.state = 2
        let urlStr = "https://golfication.us15.list-manage.com/subscribe/post?"
        let dataStr =  "u=" + "61aa993cd19d0fb238ab03ae0&amp;" + "id=" + "b8bdae75ef&" + "EMAIL=" + "\(uEmail)&" + "FULLNAME=" + "\(uName)"
        
        serverHandler.sendMailingRequest(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            debugPrint("arg0_&_error==", arg0 ?? "", error ?? "")
        }
    }
    
    func getUserDataFromFirebase(uid:String, isFirst:Bool) {
        let friendListDict = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "") { (snapshot) in
            let dataDic = (snapshot.value as? NSMutableDictionary)!
            //print("Data From User : \(dataDic)")
            
            for (key, value) in dataDic{
                if let fb_id = (value as? NSMutableDictionary)?.value(forKey: "fb_id"){
                    if((self.friendsDetails.value(forKey: "\(fb_id)")) != nil){
                        friendListDict.setObject(true, forKey: "\(key)" as NSCopying)
                    }
                }

//                group.leave()
            }
            DispatchQueue.main.async(execute: {
                friendListDict.setObject(true, forKey: "jpSgWiruZuOnWybYce55YDYGXP62" as NSCopying)
                let friendsNode = ["friends":friendListDict]
                if(uid.count > 1){
                    ref.child("userData/\(uid)/").updateChildValues(friendsNode)
                }
                if isFirst{
                    let ids = friendListDict.allKeys
                    for id in ids{
                    Notification.sendNotification(reciever: id as! String, message: "\(Auth.auth().currentUser?.displayName ?? "guest") joined Golfication", type: "6", category: "First Login", matchDataId: Constants.matchId, feedKey:"")
                    }
                    let userDataDic = NSMutableDictionary()
                    userDataDic.setObject("advanced", forKey: "defaultScoringMode" as NSCopying)
                    userDataDic.setObject(true, forKey: "gameTypePopUp" as NSCopying)
//                    userDataDic.setObject(["jpSgWiruZuOnWybYce55YDYGXP62":true], forKey: "friends" as NSCopying)
                    
                    Notification.sendNotification(reciever: "Golfication", message: "Welcome to Golfication! Start a round, track your stats, and play against your friends or A.I.", type: "5", category: "First Notification", matchDataId: "", feedKey: "")
                    if(uid.count > 1){
                        ref.child("userData/\(uid)/").updateChildValues(userDataDic as! [AnyHashable : Any])
                    }
                }
                
            })
        }
    }
    
    @IBAction func forgotPswdAction(_ sender: UIButton) {
        
        if !(self.appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Confirm your email address", message: "", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Please enter email"
                textField.text = self.txtFieldEmail.text
            }
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                
                if textField?.text == ""{
                    
                    let emptyAlert = UIAlertController(title: "Error", message: "Please Enter Email", preferredStyle: UIAlertControllerStyle.alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
                else{
                    self.progressView.show(atView: self.view, navItem: self.navigationItem)
                    Auth.auth().sendPasswordReset(withEmail: (textField?.text!)!) { error in
                        self.progressView.hide(navItem: self.navigationItem)
                        if error != nil {
                            if !(self.appDelegate.isInternet){
                                let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            //                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            //                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            //                        self.present(alert, animated: true, completion: nil)
                            return
                        }
                        self.txtFieldEmail.text = textField?.text
                        
                        let alert = UIAlertController(title: "Alert", message: "Please reset your password by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                textField?.text = ""
                //print("Cancelled")
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        if !(self.appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            self.txtFieldEmail.resignFirstResponder()
            self.txtFieldPswd.resignFirstResponder()
            
            var valid: Bool  = true
            
            if((valid) && (txtFieldEmail.text == "")){
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please enter email", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            if((valid) && (!(txtFieldEmail.text == ""))) {
                valid = self.validateEmail(usrEmail: txtFieldEmail.text!)
            }
            if ((valid) && (txtFieldPswd.text == "")) {
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please enter password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            if(valid){
                self.sendLoginDetailToFirebase()
            }
        }
    }
    
    func validateEmail(usrEmail: String)-> Bool{
        
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if (emailTest.evaluate(with: txtFieldEmail.text) == true){
            
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Enter valid email id", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        return emailTest.evaluate(with:usrEmail)
    }
    
    func sendLoginDetailToFirebase(){
        //if !(self.appDelegate.isInternet){

        progressView.show()
        Auth.auth().signIn(withEmail: txtFieldEmail.text!, password: txtFieldPswd.text!) {(user, error) in
            
            if error != nil {
                if !(self.appDelegate.isInternet){
                    let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                 }
                else{
                    let alert = UIAlertController(title: "Alert", message: "Invalid User Name or Password.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                self.progressView.hide(navItem: self.navigationItem)
                return
            }
              self.checkEmailVerification(currentUser: user!)
        }
    }
    
    @IBAction func reVerifyEmailAction(_ sender: UIButton) {
        if !(self.appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            progressView.show()
            if self.txtFieldPswd.text!.count > 0{
                Auth.auth().signIn(withEmail: txtFieldEmail.text!, password: txtFieldPswd.text!) {(user, error) in
                    if let error = error {
                        self.progressView.hide(navItem: self.navigationItem)
                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }else if(Auth.auth().currentUser != nil){
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            self.progressView.hide(navItem: self.navigationItem)
                            if let error = error {
                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            let alert = UIAlertController(title: "Alert", message: "Please verify your email by clicking the confirmation link sent in your email.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }else{
                let alert = UIAlertController(title: "Alert", message: "Please Enter your password to resend email.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.progressView.hide(navItem: self.navigationItem)
            }
        }
    }
    
    func checkEmailVerification(currentUser: User) {
        
        /*if !(currentUser.isEmailVerified){
            currentUser.sendEmailVerification { (error) in
                self.progressView.hide(navItem: self.navigationItem)

                if let error = error {
                    
                    let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let alert = UIAlertController(title: "Alert", message: "Please verify your email by confirming the sent link.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{*/

            // -------------------------------- Check If New User ----------------------------
            FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "device") { (snapshot) in
                
                self.isNewUser = true
                if(snapshot.value != nil){
                    self.isNewUser = false
                }
                UserDefaults.standard.set(self.isNewUser, forKey: "isNewUser")
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async(execute: {
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMode") { (snapshot) in
                        self.progressView.show(atView: self.view ,navItem: self.navigationItem)
                        self.isNewUser = true
                        if(snapshot.value != nil){
                            self.isNewUser = false
                        }
                        UserDefaults.standard.set(self.isNewUser, forKey: "isNewUser")
                        UserDefaults.standard.synchronize()
                        // --------------------------------------------------------------------------------
                        if(currentUser.uid.count>1){
                            let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
                                if newUser{
                                    
                                    var imagUrl =  ""
                                    if(currentUser.photoURL != nil){
                                        imagUrl = "\(currentUser.photoURL!)"
                                    }
                                    let userDataDic = NSMutableDictionary()
                                    userDataDic.setObject("advanced", forKey: "defaultScoringMode" as NSCopying)
                                    userDataDic.setObject(true, forKey: "gameTypePopUp" as NSCopying)
                                    
                                    ref.child("userData/\(currentUser.uid)/").updateChildValues(userDataDic as! [AnyHashable : Any])
                                    
                                    let userDetails = NSMutableDictionary()
                                    userDetails.setObject(["jpSgWiruZuOnWybYce55YDYGXP62":true], forKey: "friends" as NSCopying)
                                    userDetails.setObject((currentUser.email)!, forKey: "email" as NSCopying)
                                    userDetails.setObject((currentUser.displayName)!, forKey: "name" as NSCopying)
                                    userDetails.setObject(imagUrl, forKey: "image" as NSCopying)
                                    userDetails.setObject(false, forKey: "device" as NSCopying)
                                    userDetails.setObject(false, forKey: "proMode" as NSCopying)
                                    if let iosToken = (InstanceID.instanceID().token()){
                                        userDetails.setObject(iosToken,forKey: "iosToken" as NSCopying)
                                    }
                                    else{
                                        userDetails.setObject("",forKey: "iosToken" as NSCopying)
                                    }
                                    if(referedBy != nil){
                                        let referralNotification = NotificationForReferral()
                                        referralNotification.checkReferralTimestampWithInvite(){ success in
                                            ref.child("userData/\(referedBy!)/friends").updateChildValues([currentUser.uid:true])
                                            ref.child("userData/\(referedBy!)/invite").updateChildValues([currentUser.uid:true])
                                        }

                                    }
                                    ref.child("userData/\(currentUser.uid)/").updateChildValues(userDetails as! [AnyHashable : Any])
                                    
                                    userDetails.removeAllObjects()
                                    userDetails.setObject((currentUser.displayName)!, forKey: "name" as NSCopying)
                                    userDetails.setObject(imagUrl, forKey: "image" as NSCopying)
                                    userDetails.setObject(Int64(NSDate().timeIntervalSince1970*1000), forKey: "timestamp" as NSCopying)
                                    if let locale = Locale.current.regionCode {
                                        userDetails.setObject(locale, forKey:"country" as NSCopying)
                                    }
                                    
                                    ref.child("userList/\(currentUser.uid)").updateChildValues(userDetails as! [AnyHashable : Any])

                                    self.progressView.hide(navItem: self.navigationItem)
                                    let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewUserProfileVC") as! NewUserProfileVC
                                    self.navigationController?.pushViewController(viewCtrl, animated: false)
                                }
                                else{
                                    self.progressView.hide(navItem: self.navigationItem)
                                    let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                                    self.navigationController?.pushViewController(tabBarCtrl, animated: true)
                                }
                            self.txtFieldEmail.text = ""
                            self.txtFieldPswd.text = ""
                            Constants.userEmail = ""
                        }
                    }
                })
            }
        //}
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        // ---------------- Google Analytics --------------------------------------
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Login Screen")

        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        // ------------------------------------------------------------------
        
        if Constants.userEmail != ""{
            txtFieldEmail.text = Constants.userEmail
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnSignIn.backgroundColor = UIColor.clear
        btnSignIn.setTitleColor(UIColor(rgb: 0x008A64), for: .normal)
        btnSignIn.layer.cornerRadius = 3.0
        btnSignIn.layer.borderWidth = 1.0
        btnSignIn.layer.borderColor = UIColor(rgb: 0x008A64).cgColor
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "LOGIN".localized())
    }
    
}
