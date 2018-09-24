//
//  InviteViewController.swift
//  Golfication
//
//  Created by Khelfie on 11/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks
class InviteViewController: UIViewController {

    @IBOutlet weak var btnPlayer1: UIButton!
    @IBOutlet weak var btnPlayer2: UIButton!
    @IBOutlet weak var btnPlayer3: UIButton!
    @IBOutlet weak var btnGetGoficationX: UIButton!
    @IBOutlet weak var btnWhatIsGolficationX: UIButton!
    @IBOutlet weak var btnInviteFriends: UIButton!
    
    @IBOutlet weak var lblPlayer1Name: UILabel!
    @IBOutlet weak var lblPlayer2Name: UILabel!
    @IBOutlet weak var lblPlayer3Name: UILabel!
    var indiegogoProURL = String()
    @IBOutlet weak var lblFriendsRequired: UILabel!
    var keys = [String]()
    
    
    
    
    
    
    
    
    
    
    @IBAction func btnActionInviteFriends(_ sender: UIButton) {
        let text = "\(Auth.auth().currentUser?.displayName ?? "") wants you to try Golfication."
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
    
    func getURL()  {
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "indiegogo") { (snapshot) in
            if(snapshot.value != nil){
                self.indiegogoProURL = snapshot.value as! String
            }
            DispatchQueue.main.async(execute: {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
                viewCtrl.linkStr = self.indiegogoProURL
                viewCtrl.fromIndiegogo = true
                viewCtrl.fromNotification = false
                self.present(viewCtrl, animated: false, completion: nil)
            })
        }
    }
    
    @IBAction func btnActionGetGolficationX(_ sender: UIButton) {
        self.getURL()
    }
    
    @IBAction func btnActionWhatIsGolficationX(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
        viewCtrl.fromIndiegogo = true
        viewCtrl.fromNotification = false
        self.present(viewCtrl, animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPlayer1.setCircle(frame: self.btnPlayer1.frame)
        btnPlayer2.setCircle(frame: self.btnPlayer2.frame)
        btnPlayer3.setCircle(frame: self.btnPlayer3.frame)
        btnPlayer1.isEnabled = false
        btnPlayer2.isEnabled = false
        btnPlayer3.isEnabled = false
        btnGetGoficationX.layer.cornerRadius = 3
        btnInviteFriends.layer.cornerRadius = 3
        btnGetGoficationX.isEnabled = false
        self.checkHowManySuccessFullReferal()
        // Do any additional setup after loading the view.
    }
    func checkHowManySuccessFullReferal(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "invite") { (snapshot) in
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            let group = DispatchGroup()
            self.keys = [String]()
            for (key,value) in dataDic{
                if value {
                    group.enter()
                    ref.child("userData/\(key)/scoring").observeSingleEvent(of: .value, with: { snapshot in
                        if snapshot.hasChildren(){
                            self.keys.append(key)
                        }
                        group.leave()
                    })
                }
                if(self.keys.count == 3){
                    self.updateButton()
                    break
                }
            }
            group.notify(queue: .main) {
                self.updateButton()
                debugPrint(self.keys)
            }
        }
    }
    func updateButton(){
        let groups = DispatchGroup()

        for i in 0..<keys.count{
            groups.enter()
            ref.child("userList/\(keys[i])").observeSingleEvent(of: .value, with: { snapshot in
                if let dataDict = snapshot.value as? NSMutableDictionary{
                    if(i == 0){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.btnPlayer1.sd_setBackgroundImage(with:URL(string:img), for: .normal, completed: nil)
                        }
                        self.lblPlayer1Name.isHidden = false
                        self.lblPlayer1Name.text = dataDict.value(forKey: "name") as? String
                    }else if(i == 1){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.btnPlayer2.sd_setBackgroundImage(with:URL(string:img), for: .normal, completed: nil)
                        }
                        self.lblPlayer2Name.isHidden = false
                        self.lblPlayer2Name.text = dataDict.value(forKey: "name") as? String
                    }else if(i == 2){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.btnPlayer3.sd_setBackgroundImage(with:URL(string:img), for: .normal, completed: nil)
                        }
                        self.lblPlayer3Name.isHidden = false
                        self.lblPlayer3Name.text = dataDict.value(forKey: "name") as? String
                    }
                }
            })
            groups.leave()
        }
        groups.notify(queue: .main) {
            if(self.keys.count == 3){
                self.btnGetGoficationX.isEnabled = true
                self.btnGetGoficationX.backgroundColor = UIColor.glfFlatBlue
            }
            debugPrint(self.keys)
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
