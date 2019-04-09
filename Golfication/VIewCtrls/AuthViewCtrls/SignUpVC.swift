//
//  SignUpVC.swift
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

class SignUpVC: UIViewController, IndicatorInfoProvider {
    var isNewUser = Bool()

    var userDetails = NSMutableDictionary()
    var friendsDetails = NSMutableDictionary()
    var userList = NSMutableDictionary()
    var progressView = SDLoader()

    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPswd: UITextField!
    @IBOutlet weak var txtFieldCnfrmPswd: UITextField!
        
    @IBOutlet weak var btnFb: UILocalizedButton!
    @IBOutlet weak var btnSignUp: UILocalizedButton!
    var appDelegate: AppDelegate!

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
                
                // Perform login by calling Firebase APIs
                self.progressView.show()
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        debugPrint("Login error: \(error.localizedDescription)")
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
                            debugPrint("Error: \(String(describing: error))")
                        }else{
                            let result = result as! NSDictionary
                            let fbId = result.value(forKey: "id") as! String
                            if let email = user?.email{
                                self.userDetails.setObject(email, forKey: "email" as NSCopying)
                            }
                            self.userDetails.setObject((user?.displayName)!, forKey: "name" as NSCopying)
                            self.userDetails.setObject((fbId), forKey: "fb_id" as NSCopying)
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
                            self.userList.setObject(Int(NSDate().timeIntervalSince1970*1000), forKey: "timestamp" as NSCopying)
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
                                self.friendsDetails.setObject(true, forKey: "jpSgWiruZuOnWybYce55YDYGXP62" as NSCopying)
                                
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        } else {
                            debugPrint("Error Getting Friends \(String(describing: error))");
                        }
                    })
                    
                    connection.start()
                    self.updateUserDataIntoFirebase(uid: (user?.uid)!, fbEmail: (user?.email ?? ""), fbName: (user?.displayName ?? ""))
                    Constants.userName = (user?.displayName)!
                    
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
                            if !fbName.isEmpty{
                                self.userDetails.setObject(fbName, forKey: "name" as NSCopying)
                                self.userList.setObject(fbName, forKey: "name" as NSCopying)
                            }
                            if !fbEmail.isEmpty{
                                self.userDetails.setObject(fbEmail, forKey: "email" as NSCopying)
                                self.userList.setObject(fbEmail, forKey: "email" as NSCopying)
                            }
                            if let locale = Locale.current.regionCode {
                                self.userList.setObject(locale, forKey:"country" as NSCopying)
                            }
                            self.userList.setObject(Int(NSDate().timeIntervalSince1970*1000), forKey: "timestamp" as NSCopying)
                            if(uid.count>1){
                                ref.child("userData/\(uid)").updateChildValues(self.userDetails as! [AnyHashable : Any])
                                ref.child("userList/\(uid)").updateChildValues(self.userList as! [AnyHashable : Any])
                                self.getUserDataFromFirebase(uid: uid, isFirst:isFirst)
                            }
                            let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
                            if newUser{
                                if(referedBy != nil){
                                    let referralNotification = NotificationForReferral()
                                    referralNotification.checkReferralTimestampWithInvite(){ success in
                                        ref.child("userData/\(referedBy!)/friends").updateChildValues([(Auth.auth().currentUser?.uid)!:true])
                                        ref.child("userData/\(referedBy!)/invite").updateChildValues([(Auth.auth().currentUser?.uid)!:true])
                                        ref.child("userData/\((Auth.auth().currentUser?.uid)!)/friends").updateChildValues([referedBy!:true])
                                    }
                                }
                                let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewUserProfileVC") as! NewUserProfileVC
                                self.navigationController?.pushViewController(viewCtrl, animated: false)
                                BackgroundMapStats.sendMailingRequestToServer(uName: fbName,uEmail: fbEmail)
                                if let _ = self.userDetails.value(forKey: "fb_id") as? String{
                                    FBSomeEvents.shared.logCompleteRegistrationEvent(registrationMethod: "Facebook")
                                }else{
                                    FBSomeEvents.shared.logCompleteRegistrationEvent(registrationMethod: "Email")
                                }
                                self.progressView.hide()
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
    
    func getUserDataFromFirebase(uid:String, isFirst:Bool) {
        let friendListDict = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData\(uid)") { (snapshot) in
            if let dataDic = snapshot.value as? NSMutableDictionary{
                for (key, value) in dataDic{
                    if let fb_id = (value as? NSMutableDictionary)?.value(forKey: "fb_id"){
                        if((self.friendsDetails.value(forKey: "\(fb_id)")) != nil){
                            friendListDict.setObject(true, forKey: "\(key)" as NSCopying)
                        }
                    }
                }
            }

            DispatchQueue.main.async(execute: {
                let friendsNode = ["friends":friendListDict]
                if(uid.count > 1){
                    ref.child("userData/\(uid)/").updateChildValues(friendsNode)
                }
                if isFirst{
                    let ids = friendListDict.allKeys
                    for id in ids{
                        Notification.sendNotification(reciever: id as! String, message: "\(Auth.auth().currentUser?.displayName ?? "guest") joined Golfication", type: "6", category: "First Login", matchDataId: Constants.matchId, feedKey: "")
                    }
                    
                    let userDataDic = NSMutableDictionary()
                    userDataDic.setObject("advanced", forKey: "defaultScoringMode" as NSCopying)
                    userDataDic.setObject(true, forKey: "gameTypePopUp" as NSCopying)
                    Notification.sendNotification(reciever: "Golfication", message: "Welcome to Golfication! Start a round, track your stats, and play against your friends or A.I.", type: "5", category: "First Notification", matchDataId: "", feedKey: "")
                    if(uid.count > 1){
                        ref.child("userData/\(uid)/").updateChildValues(userDataDic as! [AnyHashable : Any])
                    }
                }
                
            })
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        if !(self.appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            var valid: Bool  = true
            
            if ((valid) && (txtFieldName.text == "")) {
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please enter your name", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            if((valid) && (txtFieldEmail.text == "")){
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please enter your email address", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            if((valid) && (!(txtFieldEmail.text == ""))) {
                valid = self.validateEmail(usrEmail: txtFieldEmail.text!)
            }
            if ((valid) && (txtFieldPswd.text == "")) {
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please enter a password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            if ((valid) && (txtFieldCnfrmPswd.text == "")) {
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Please confirm your password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            if ((valid) && ((!(txtFieldPswd.text == ""))&&(!(txtFieldCnfrmPswd.text == ""))&&(!(txtFieldPswd.text == txtFieldCnfrmPswd.text)))) {
                valid = false
                
                let alert = UIAlertController(title: "Alert", message: "Your password and confirmation password do not match", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            if(valid){
                
                self.sendRegistrationDetailToFirebase()
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
            let alert = UIAlertController(title: "Alert", message: "Enter a valid email address", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        return emailTest.evaluate(with:usrEmail)
    }
    
    func sendRegistrationDetailToFirebase(){
        
        progressView.show()
        Auth.auth().createUser(withEmail: txtFieldEmail.text!, password: txtFieldPswd.text!) { (user, error) in
            self.progressView.hide(navItem: self.navigationItem)
            if let error = error {
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if (user != nil){
                let changeRequest = user?.createProfileChangeRequest()
                debugPrint("self.txtFieldName.text",self.txtFieldName.text)
                changeRequest?.displayName = self.txtFieldName.text!
                changeRequest?.photoURL = URL(string: "")
                Auth.auth().signIn(withEmail: self.txtFieldEmail.text!, password: self.txtFieldPswd.text!, completion: { (user, error) in
                    user?.sendEmailVerification(completion: { (error) in
                        debugPrint("Successfully Mailed")
                    })
                })
                changeRequest?.commitChanges(completion: { error in
                    if let error = error {
                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
//                    let alert = UIAlertController(title: "Verify Email", message: "We have just sent you a verification email. Please verify your email address by clicking the verification link.", preferredStyle: UIAlertControllerStyle.alert)
                    let alert = UIAlertController(title: "Registration Successful", message: "You will be logged in automatically to start tracking your rounds. This may take a few seconds.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [alert] (_) in
                        
//                        https://golfication.us15.list-manage.com/subscribe/post?u=61aa993cd19d0fb238ab03ae0&amp;id=b8bdae75ef&EMAIL=rishabh.sood@gmail.com&FULLNAME=Rishabh Sood
                        UserDefaults.standard.set(self.isNewUser, forKey: "isNewUser")
                        UserDefaults.standard.synchronize()
                        Constants.userName = self.txtFieldName.text!
                        self.updateUserDataIntoFirebase(uid: (user?.uid)!, fbEmail: self.txtFieldEmail.text!, fbName: self.txtFieldName.text!)

//                        Constants.userEmail = self.txtFieldEmail.text!
//                            
//                        self.txtFieldName.text = ""
//                        self.txtFieldEmail.text = ""
//                        self.txtFieldPswd.text = ""
//                        self.txtFieldCnfrmPswd.text = ""
//                        let vc = self.parent as! ButtonBarPagerTabStripViewController
//                        vc.moveToViewController(at: 1)
                    }))
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                    debugPrint("Auth.auth().currentUser?.displayName",Auth.auth().currentUser?.displayName)
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)

        btnSignUp.backgroundColor = UIColor.clear
        btnSignUp.setTitleColor(UIColor(rgb: 0x008A64), for: .normal)
        btnSignUp.layer.cornerRadius = 3.0
        btnSignUp.layer.borderWidth = 1.0
        btnSignUp.layer.borderColor = UIColor(rgb: 0x008A64).cgColor
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SIGN UP".localized())
    }
}
