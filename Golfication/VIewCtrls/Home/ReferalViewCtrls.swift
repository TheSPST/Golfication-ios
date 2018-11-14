//
//  ReferalViewCtrls.swift
//  Golfication
//
//  Created by Khelfie on 07/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks

class ReferalViewCtrls: UIViewController {
    
    @IBOutlet weak var ReferalFrontCardView: CardView!
    @IBOutlet weak var ReferalCardView: CardView!
    @IBOutlet weak var btnOfferTimer: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var referalUserImg1: UIImageView!
    @IBOutlet weak var referalUserImg2: UIImageView!
    @IBOutlet weak var referalUserImg3: UIImageView!
    @IBOutlet weak var deviceImg: UIImageView!
    
    @IBOutlet weak var btnInvite1: UILocalizedButton!
    @IBOutlet weak var btnInvite2: UILocalizedButton!
    @IBOutlet weak var btnInvite3: UILocalizedButton!
    
    @IBOutlet weak var lblPlayer1Name: UILocalizedLabel!
    @IBOutlet weak var lblPlayer2Name: UILocalizedLabel!
    @IBOutlet weak var lblPlayer3Name: UILocalizedLabel!
    
    @IBOutlet weak var overlappingView1: UIView!
    @IBOutlet weak var overlappingView2: UIView!
    @IBOutlet weak var overlappingView3: UIView!

    @IBOutlet weak var btnGet20PerDiscount: UILocalizedButton!
    var indiegogoProURL : String!
    var countdownTimer: Timer!
    var newTimer : Int64!
    @IBOutlet weak var btnEnter: UIButton!
    
    @IBAction func btnEnterAction(_ sender: Any) {
        self.ReferalCardView.isHidden = false
        self.ReferalFrontCardView.isHidden  = true
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["referralTimestamp":Timestamp] as [AnyHashable:Any])
        self.newTimer = Timestamp
        self.updateTimer()
    }
    var keys = [String]()
    var progressView = SDLoader()
    @IBAction func btnActionRefer(_ sender: Any) {
        
    }
    
    @IBAction func btnActionBack(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pop()
    }
    
    @IBAction func btnActionAvailNow(_ sender: Any) {

    }
    @IBAction func btnActionInviteFriends(_ sender: UIButton) {
//        let text = "\(Auth.auth().currentUser?.displayName ?? "") wants you to try Golfication."
        let text = "Take your golf game further with Live Scoring, GPS, Shot Tracking, Advanced Stats and more. Download Golfication now!"
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
    func checkHowManySuccessFullReferal(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "invite") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            var dataDic = [String:Bool]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Bool])!
            }
            let group = DispatchGroup()
            self.keys = [String]()
            for (key,value) in dataDic{
                if value {
                    group.enter()
//                    ref.child("userData/\(key)/scoring").observeSingleEvent(of: .value, with: { snapshot in
//                        if snapshot.hasChildren(){
                            self.keys.append(key)
//                        }
                        group.leave()
//                    })
                }
            }
            group.notify(queue: .main) {
                self.updateButton()
                if(self.keys.count == 3){
                    self.ReferalFrontCardView.isHidden = true
                    self.ReferalCardView.isHidden = false
                }else{
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "referralTimestamp") { (snapshot) in
                        if(snapshot.value != nil){
                            self.newTimer = snapshot.value as! Int64
                        }
                        DispatchQueue.main.async( execute: {
                            self.ReferalFrontCardView.isHidden = false
                            if(self.newTimer != nil){
                                self.updateTimer()
                            }
                        })
                    }
                }
                self.progressView.hide(navItem: self.navigationItem)

            }
        }
    }
    func updateButton(){
        let groups = DispatchGroup()
        let dict2:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Light", size: 14)!]
        let dict1: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name:"SFProDisplay-Bold", size: 14)!,
            NSAttributedStringKey.foregroundColor : UIColor.glfBlueyGreen]
        
        var attText = NSMutableAttributedString()

        for i in 0..<keys.count{
            groups.enter()
            ref.child("userList/\(keys[i])").observeSingleEvent(of: .value, with: { snapshot in
                if let dataDict = snapshot.value as? NSMutableDictionary{
                    if(i == 0){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.referalUserImg1.sd_setImage(with:URL(string:img), placeholderImage:#imageLiteral(resourceName: "Rgreen") , completed: nil)
                        }else{
                            self.referalUserImg1.image = #imageLiteral(resourceName: "Rgreen")
                        }
                        self.btnInvite1.isHidden = true//" Referral 1;"
                        attText.append(NSAttributedString(string: " " + "Referral".localized() + " 1;" , attributes: dict2))
                        if let name = dataDict.value(forKey: "name") as? String{
                            let spString = name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                            if(spString.count > 1){
                                attText.append(NSAttributedString(string: "\(spString[0])", attributes: dict1))
                            }else{
                                attText.append(NSAttributedString(string: "\(name)", attributes: dict1))
                            }
                        }
                        self.lblPlayer1Name.attributedText = attText
                        attText = NSMutableAttributedString()
                    }else if(i == 1){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.referalUserImg2.sd_setImage(with:URL(string:img), placeholderImage:#imageLiteral(resourceName: "Rgreen"), completed: nil)
                        }else{
                            self.referalUserImg2.image = #imageLiteral(resourceName: "Rgreen")
                        }
                        self.btnInvite2.isHidden = true
                        attText.append(NSAttributedString(string: " " + "Referral".localized() + " 2;" , attributes: dict2))
                        if let name = dataDict.value(forKey: "name") as? String{
                            let spString = name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                            if(spString.count > 1){
                                attText.append(NSAttributedString(string: "\(spString[0])", attributes: dict1))
                            }else{
                                attText.append(NSAttributedString(string: "\(name)", attributes: dict1))
                            }
                        }
                        self.lblPlayer2Name.attributedText = attText
                        attText = NSMutableAttributedString()
                    }else if(i == 2){
                        if let img = dataDict.value(forKey: "image") as? String{
                            self.referalUserImg3.sd_setImage(with:URL(string:img), placeholderImage:#imageLiteral(resourceName: "Rgreen"), completed: nil)
                        }else{
                            self.referalUserImg3.image = #imageLiteral(resourceName: "Rgreen")
                        }
                        self.btnInvite3.isHidden = true
                        attText.append(NSAttributedString(string: " " + "Referral".localized() + " 3;" , attributes: dict2))
                        if let name = dataDict.value(forKey: "name") as? String{
                            let spString = name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                            if(spString.count > 1){
                                attText.append(NSAttributedString(string: "\(spString[0])", attributes: dict1))
                            }else{
                                attText.append(NSAttributedString(string: "\(name)", attributes: dict1))
                            }
                        }
                        self.lblPlayer3Name.attributedText = attText
                    }
                }
            })
            groups.leave()
        }
        groups.notify(queue: .main) {
            debugPrint(self.keys)
            switch self.keys.count{
            case 1:
                self.referalUserImg2.image = #imageLiteral(resourceName: "Rblue")
                self.btnInvite2.isHidden = false
                break
            case 2:
                self.referalUserImg3.image = #imageLiteral(resourceName: "Rblue")
                self.btnInvite3.isHidden = false
                break
            case 3:
                self.btnGet20PerDiscount.isEnabled = true
                self.btnGet20PerDiscount.setTitleColor(UIColor.glfWhite, for: .normal)
                self.btnGet20PerDiscount.backgroundColor = UIColor.glfFlatBlue
                self.btnOfferTimer.isHidden = true
                break
            default:
                self.referalUserImg1.image = #imageLiteral(resourceName: "Rblue")
                self.btnInvite1.isHidden = false
                self.btnInvite2.isHidden = true
                self.btnInvite3.isHidden = true
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        if(self.countdownTimer != nil){
            self.countdownTimer.invalidate()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //  + Invite friends
        btnInvite1.setTitle("  " + "+ " + "Invite Friends".localized(), for: .normal)
        btnInvite2.setTitle("  " + "+ " + "Invite Friends".localized(), for: .normal)
        btnInvite3.setTitle("  " + "+ " + "Invite Friends".localized(), for: .normal)

        btnGet20PerDiscount.setTitle("  " + "Get $50 off".localized(), for: .normal)
    
        self.initialSetup()
        self.checkHowManySuccessFullReferal()
        // Do any additional setup after loading the view.
    }
    func updateTimer(){
//        self.ReferalCardView.isHidden = false
        let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(newTimer/1000)))
        let timeEnd = Calendar.current.date(byAdding: .second, value: 2*24*60*60, to: timeStart as Date)
        let timeNow = NSDate()
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.second], from: timeNow as Date, to: timeEnd!)
        if components.second! <= 0{
            if(keys.count < 3){
                for key in keys{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/invitePrevious").updateChildValues([key:true] as [AnyHashable:Any])
                }
                ref.child("userData/\(Auth.auth().currentUser!.uid)/invite").setValue(NSNull())
                
                self.btnOfferTimer.isHidden = true
                self.ReferalCardView.isHidden = true
                self.ReferalFrontCardView.isHidden = false
            }
        }
        else{
            if(self.keys.count < 3){
                self.btnOfferTimer.isHidden = false
                startTimer(totalTime: (components.second!))
            }
            self.ReferalCardView.isHidden = false
            self.ReferalFrontCardView.isHidden = true
        }
    }
    func startTimer(totalTime : Int) {
        var totalTime = totalTime
        self.btnOfferTimer.setTitle("  Offer ends in \(self.timeFormattedDays(totalTime))  ", for: .normal)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.btnOfferTimer.setTitle("  Offer ends in \(self.timeFormattedDays(totalTime))  ", for: .normal)
            if totalTime != 0 {
                totalTime -= 1
            }
            else {
                if(self.keys.count < 3){
                    for key in self.keys{
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/invitePrevious").updateChildValues([key:true] as [AnyHashable:Any])
                    }
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/invite").setValue(NSNull())
                    self.btnOfferTimer.isHidden = true
                    self.ReferalCardView.isHidden = true
                    self.ReferalFrontCardView.isHidden = false
                    self.keys.removeAll()
                }else{
                    self.btnOfferTimer.isHidden = true
                    self.ReferalCardView.isHidden = false
                }
                self.countdownTimer.invalidate()
            }
        })
    }
    
    @IBAction func btnGetDiscountAction(_ sender: Any) {
        
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
    func timeFormattedDays(_ totalSeconds: Int) -> String {
        let hour: Int = (totalSeconds / 3600)
        let minuts: Int = (totalSeconds/60) - hour*60
        let second: Int = (totalSeconds) - hour*60*60 - minuts*60
        return String(format:"%02d:%02d:%02d",hour,minuts,second)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initialSetup(){
        self.referalUserImg1.setCircle(frame: referalUserImg1.frame)
        self.referalUserImg2.setCircle(frame: referalUserImg2.frame)
        self.referalUserImg3.setCircle(frame: referalUserImg3.frame)
        self.deviceImg.setCircle(frame: deviceImg.frame)
        
        overlappingView1.layer.cornerRadius = overlappingView1.frame.height/2
        overlappingView2.layer.cornerRadius = overlappingView2.frame.height/2
        overlappingView3.layer.cornerRadius = overlappingView3.frame.height/2

        btnInvite1.setCorner(color: UIColor.clear.cgColor)
        btnInvite2.setCorner(color: UIColor.clear.cgColor)
        btnInvite3.setCorner(color: UIColor.clear.cgColor)

        
        let gradient1 = CAGradientLayer()
        gradient1.frame = btnInvite1.bounds
        gradient1.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient1.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient1.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnInvite1.layer.insertSublayer(gradient1,at:0)
        btnInvite1.layer.masksToBounds = true

        let gradient2 = CAGradientLayer()
        gradient2.frame = btnInvite2.bounds
        gradient2.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient2.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnInvite2.layer.addSublayer(gradient2)
        btnInvite2.layer.masksToBounds = true

        let gradient3 = CAGradientLayer()
        gradient3.frame = btnInvite3.bounds
        gradient3.colors = [UIColor(rgb: 0x2E6594).cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient3.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient3.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnInvite3.layer.insertSublayer(gradient3, at: 0)
        btnInvite3.layer.masksToBounds = true

        self.btnEnter.layer.masksToBounds = true
        let gradient4 = CAGradientLayer()
        gradient4.colors = [UIColor.glfFlatBlue.cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient4.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient4.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient4.frame = btnEnter.bounds
        gradient4.cornerRadius = 5.0
        btnEnter.layer.addSublayer(gradient4)
        
        self.btnGet20PerDiscount.setCorner(color: UIColor.clear.cgColor)
        btnGet20PerDiscount.isEnabled = false
        self.btnOfferTimer.setCorner(color: UIColor.clear.cgColor)
        self.ReferalCardView.cornerRadius = 8.0
        self.ReferalFrontCardView.cornerRadius = 8.0
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
