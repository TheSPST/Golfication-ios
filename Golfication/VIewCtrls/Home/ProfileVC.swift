//
//  ProfileVC.swift
//  Golfication
//
//  Created by Khelfie on 17/02/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//vIv5z18F60Wwjn7KCwEZY4wAzKg2

import UIKit
import FirebaseAuth
import ActionSheetPicker_3_0
import FBSDKLoginKit
import FirebaseDynamicLinks
import FirebaseStorage

//var profileGolfName = String()

class ProfileVC: UIViewController {
    
    // MARK: - Set Outlets
    @IBOutlet weak var lblTryPremium: UILabel!
    @IBOutlet weak var lblHomeCorseTitle: UILocalizedLabel!
    @IBOutlet weak var lblHomeCourseName: UILabel!
    @IBOutlet weak var lblGolfBagTitle: UILocalizedLabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblGrip: UILocalizedLabel!
    @IBOutlet weak var lblHandicap: UILocalizedLabel!
    @IBOutlet weak var lblMinimumValue: UILabel!
    @IBOutlet weak var lblMaxValue: UILabel!
    @IBOutlet weak var lblInactivePrice: UILabel!
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var lblDaysLeftTitle: UILocalizedLabel!
    @IBOutlet weak var lblNextBilling: UILabel!
    @IBOutlet weak var lblLastBilling: UILabel!

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderHandicapNumber: UISlider!

    @IBOutlet weak var btnUpdradeNow: UILocalizedButton!
    @IBOutlet weak var btnUserImg: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var btnInactiveIndiegogo: UIButton!
    @IBOutlet weak var btnFreeActiveIndiegogo: UIButton!
    @IBOutlet weak var btnActiveIndiegogo: UIButton!
    @IBOutlet weak var btnInviteNow: UILocalizedButton!

    @IBOutlet weak var handSelection: UISegmentedControl!
    @IBOutlet weak var genderSgmtCtrl: UISegmentedControl!

    @IBOutlet weak var genderCardView: CardView!
    @IBOutlet weak var viewUpgradeInactive: UIView!
    @IBOutlet weak var viewUpgradeActive: UIView!
    @IBOutlet weak var viewUpgradeFreeActive: UIView!
    @IBOutlet weak var viewYearlyBtn: UIView!
    @IBOutlet weak var viewTopWhatIsPro: UIView!
    @IBOutlet weak var viewProMembership: UIView!

    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    var progressView = SDLoader()
    @IBOutlet weak var  whatISProHeightConstraint: NSLayoutConstraint!

    var fromPublicProfile = Bool()
    
    @IBOutlet weak var golfBagContainerView: UIView!
    @IBOutlet weak var golfBagHConstraint: NSLayoutConstraint!

    // MARK: - Initialize Variables
    let imagePicker = UIImagePickerController()
//    var clubs = ["Dr","3w","4w","5w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","3i","4i","5i","6i","7i","8i","9i", "Pw","Gw","Sw","Lw","Pu"]
    //var selectedClubs = ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"]
    var selectedClubs = NSMutableArray()
    
    var clubsBtn = [UIButton]()
    var dataArr = [NSMutableDictionary]()
    var attrs = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13.0),
        NSAttributedStringKey.foregroundColor : UIColor(rgb: 0xFE006B),
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    var attributedString = NSMutableAttributedString(string:"")
    
    var cropVC: PKCCropViewController!

    // MARK: connectBluetoothAction
    @IBAction func connectBluetoothAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: inviteNowAction
    @IBAction func inviteNowAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ReferalViewCtrls") as! ReferalViewCtrls
        self.navigationController?.pushViewController(viewCtrl, animated: true)
//        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "InviteViewController") as! InviteViewController
//        self.navigationController?.push(viewController: viewCtrl)
//        self.present(viewCtrl, animated: false, completion: nil)
        
    }
    
    // MARK: indiegogoAction
    @IBAction func activeIndiegogoAction(_ sender: UIButton) {
        
        var valid: Bool  = true
        
        if ((valid) && ((lblHomeCourseName.text == "") || (lblHomeCourseName.text == "-"))) {
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select home course", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        if((valid) && (selectedClubs.count == 0)){
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select golf bag", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(valid){
            
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "EnterFreeProCodeVC") as! EnterFreeProCodeVC
//            let navCtrl = UINavigationController(rootViewController: viewCtrl)
//            navCtrl.modalPresentationStyle = .overCurrentContext
            self.present(viewCtrl, animated: false, completion: nil)
        }
    }
    // MARK: indiegogoAction
    @IBAction func indiegogoAction(_ sender: UIButton) {
        
        var valid: Bool  = true
        
        if ((valid) && ((lblHomeCourseName.text == "") || (lblHomeCourseName.text == "-"))) {
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select home course", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        if((valid) && (selectedClubs.count == 0)){
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select golf bag", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(valid){
            
//            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as! ProfileProMemberPopUPVC
//            viewCtrl.fromUpgrade = true
//            viewCtrl.modalPresentationStyle = .overCurrentContext
//            present(viewCtrl, animated: true, completion: nil)

            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "EnterFreeProCodeVC") as! EnterFreeProCodeVC
//            let navCtrl = UINavigationController(rootViewController: viewCtrl)
//            navCtrl.modalPresentationStyle = .overCurrentContext
            self.present(viewCtrl, animated: false, completion: nil)
            
            /*viewUpgradeInactive.isHidden = true
            viewUpgradeFreeActive.isHidden = false
            viewUpgradeActive.isHidden = true
            
            let timeNow = NSDate()
            let calendar = NSCalendar.current
            let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(beginTimestamp)))
            let timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
            let expiryStr = formatter.string(from: timeEnd!)
            let trnStr = formatter.string(from: timeStart as Date)
            
            let membershipDict = NSMutableDictionary()
            membershipDict.setObject(0, forKey: "isMembershipActive" as NSCopying)
            membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
            membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
            membershipDict.setObject("Free_Membership", forKey: "productID" as NSCopying)
            membershipDict.setObject(beginTimestamp, forKey: "timestamp" as NSCopying)
            
            let proMembership = ["proMembership":membershipDict]
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
            
            UserDefaults.standard.set(false, forKey: "isNewUser")
            UserDefaults.standard.synchronize()
            //lblDaysLeft.text = "You have 29 days remaining on your Pro Membership"
            let components = calendar.dateComponents([.day], from: timeNow as Date, to: timeEnd!)
            self.lblDaysLeft.text = "You have " + "\(components.day!)" + " days remaining on your Pro Membership"
            
            self.viewTopWhatIsPro.isHidden = true
            isProfileUpdated = true
            
            whatISProHeightConstraint.constant = 0.0
            self.view.layoutIfNeeded()*/
        }
    }
    
    // MARK: genderChanged
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        switch genderSgmtCtrl.selectedSegmentIndex {
        case 0:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gender":"male"] as [AnyHashable:Any])
        case 1:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gender":"female"] as [AnyHashable:Any])
        default:
            break;
        }
    }
    
    // MARK: gripChanged
    @IBAction func gripChanged(_ sender: UISegmentedControl) {
        switch handSelection.selectedSegmentIndex {
        case 0:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Left"] as [AnyHashable:Any])
        case 1:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
        default:
            break;
        }
    }
    
    // MARK: btnActionWhatIsPro
    @IBAction func btnActionWhatIsPro(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as! ProfileProMemberPopUPVC
        viewCtrl.fromUpgrade = false
        viewCtrl.fromNewUserPopUp = false
        viewCtrl.modalPresentationStyle = .overCurrentContext
        present(viewCtrl, animated: true, completion: nil)
    }
    
    // MARK: yearlyPlanAction
    @IBAction func yearlyPlanAction(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)

//        viewUpgradeInactive.isHidden = true
//        viewUpgradeFreeActive.isHidden = true
//        viewUpgradeActive.isHidden = false
    }
    
    // MARK: upgradeNowAction
    @IBAction func upgradeNowAction(_ sender: Any) {

        var valid: Bool  = true
        
        if ((valid) && ((lblHomeCourseName.text == "") || (lblHomeCourseName.text == "-"))) {
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select home course", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        if((valid) && (selectedClubs.count == 0)){
            valid = false
            
            let alert = UIAlertController(title: "Alert", message: "Please select golf bag", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(valid){
            
//            checkTrialPreriod()
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
            self.navigationController?.pushViewController(viewCtrl, animated: true)

            /*let timeNow = NSDate()
            let calendar = NSCalendar.current
            let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(beginTimestamp/1000)))
            let timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
            let expiryStr = formatter.string(from: timeEnd!)
            let trnStr = formatter.string(from: timeStart as Date)

            let membershipDict = NSMutableDictionary()
            membershipDict.setObject(0, forKey: "isMembershipActive" as NSCopying)
            membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
            membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
            membershipDict.setObject("Free_Membership", forKey: "productID" as NSCopying)
            membershipDict.setObject(beginTimestamp, forKey: "timestamp" as NSCopying)

            let proMembership = ["proMembership":membershipDict]
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
            
            let subDic = NSMutableDictionary()
            subDic.setObject("Free_Membership", forKey: "productID" as NSCopying)
            subDic.setObject(beginTimestamp, forKey: "timestamp" as NSCopying)
            subDic.setObject("purchase", forKey: "type" as NSCopying)
            let subKey = ref!.child("\(Auth.auth().currentUser!.uid)").childByAutoId().key
            let subscriptionDict = NSMutableDictionary()
            subscriptionDict.setObject(subDic, forKey: subKey as NSCopying)
            ref.child("subscriptions/\(Auth.auth().currentUser!.uid)/").updateChildValues(subscriptionDict as! [AnyHashable : Any])*/

        }
    }
    
    func checkTrialPreriod(){
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        var trial = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "trial") { (snapshot) in
            if(snapshot.value != nil){
                trial = snapshot.value as! Bool
            }
            else{
                trial = false
            }
            DispatchQueue.main.async( execute: {
                self.progressView.hide(navItem: self.navigationItem)

                let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as! ProfileProMemberPopUPVC
                viewCtrl.fromUpgrade = true
                viewCtrl.isTrial = trial
                viewCtrl.modalPresentationStyle = .overCurrentContext
                self.present(viewCtrl, animated: true, completion: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.free30DaysProActivated(_:)), name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
            })
        }
    }
    @objc func free30DaysProActivated(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
        
        var productID = String()
        var startTime = Int()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMembership") { (snapshot) in
            if(snapshot.childrenCount > 0){
                let dataDic = snapshot.value as! NSDictionary
                if let prodID = dataDic.value(forKey: "productID") as? String{
                    productID = prodID
                }
                if let timestamp = dataDic.value(forKey: "timestamp") as? Int{
                    startTime = timestamp
                }
            }
            DispatchQueue.main.async( execute: {
                self.progressView.hide(navItem: self.navigationItem)
                
                let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(startTime/1000)))
                var timeEnd = Calendar.current.date(byAdding: .day, value: 365, to: timeStart as Date)
                if (productID == Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID) || (productID == Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID) || (productID == Constants.FREE_MONTHLY_PRODUCT_ID){
                    timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
                }
                let expiryDF = DateFormatter()
                expiryDF.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                let expDateStr = expiryDF.string(from: timeEnd!)
                self.lblNextBilling.text = "Next Billing " + " \(expDateStr)"
                
                let df = DateFormatter()
                df.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                df.dateFormat = "dd-MMM-yyyy"
                let myDateStr = df.string(from: timeStart as Date)
                self.lblLastBilling.text = "Member since " + " \(myDateStr)"
                
                self.viewUpgradeInactive.isHidden = true
                self.viewUpgradeFreeActive.isHidden = true
                self.viewUpgradeActive.isHidden = false
                
                self.viewTopWhatIsPro.isHidden = true
                Constants.isProfileUpdated = true
                
                self.whatISProHeightConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970) * 1000
    }
    
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        if fromPublicProfile{
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
    }

    // MARK: btnLogoutAction
    
    @IBAction func settingAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    // MARK: editImageAction
    @IBAction func editImageAction(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select a source:", rows: ["Camera", "Gallery"], initialSelection: 0, doneBlock: {
         picker, value, index in
         if value == 0 {
         if UIImagePickerController.isSourceTypeAvailable(.camera) {
         self.imagePicker.allowsEditing = false
         self.imagePicker.sourceType = .camera
         self.imagePicker.cameraCaptureMode = .photo
         self.imagePicker.modalPresentationStyle = .fullScreen
         self.present(self.imagePicker,animated: true,completion: nil)
         }
         else {
         self.noCamera()
         }
         }
         else{
         self.imagePicker.allowsEditing = false
         self.imagePicker.sourceType = .photoLibrary
         self.present(self.imagePicker, animated: true, completion: nil)
         }
         return
         }, cancel: { ActionStringCancelBlock in
         return
         }, origin: sender)
    }
    
    // MARK: btnActionChangeImage
    @IBAction func btnActionChangeImage(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfilePhotoDetailVC") as! ProfilePhotoDetailVC
        viewCtrl.modalPresentationStyle = .overCurrentContext
        viewCtrl.modalTransitionStyle = .crossDissolve
        self.present(viewCtrl, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func uploadImageInFirebase(chosenImage: UIImage) {
        cropVC.showIndicator()
        let imageRef = Storage.storage().reference().child("profileImages").child("\(Auth.auth().currentUser!.uid)-\(Timestamp)-ios-profileImage.png")

        self.uploadImage(chosenImage, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["image" :urlString] as [AnyHashable:String])
            ref.child("userList/\(Auth.auth().currentUser!.uid)/").updateChildValues(["image" :urlString] as [AnyHashable:String])

            let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
            changeRequest.photoURL = URL(string: urlString)
            changeRequest.commitChanges { (error) in
                self.cropVC.hideIndicator()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        })
    }
    
    // MARK: btnActionChangeName
    @IBAction func btnActionChangeName(_ sender: Any) {
        
        let alert = UIAlertController(title: "Please enter name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name".localized()
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            debugPrint("cancelled---", textField?.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            if textField?.text == ""{
                let emptyAlert = UIAlertController(title: "Error", message: "Please Enter Name", preferredStyle: UIAlertControllerStyle.alert)
                emptyAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(emptyAlert, animated: true, completion: nil)
            }
            else{
                self.btnUserName.setTitle(textField?.text, for: .normal)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: btnActionChangeCourse
    @IBAction func btnActionChangeCourse(_ sender: Any) {
        
        let latitude = Double("64.830673")!
        let longitude = Double("-147.576172")!
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            if (arg0 == nil) && (error != nil){
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else{
                self.dataArr =  [NSMutableDictionary]()
                
                let (courses) = arg0
                let group = DispatchGroup()
                
                courses?.forEach {
                    group.enter()
                    
                    let dataDic = NSMutableDictionary()
                    dataDic.setObject($0.key, forKey:"Id"  as NSCopying)
                    dataDic.setObject($0.value.Name, forKey : "Name" as NSCopying)
                    dataDic.setObject($0.value.City, forKey : "City" as NSCopying)
                    dataDic.setObject($0.value.Country, forKey : "Country" as NSCopying)
                    dataDic.setObject($0.value.Latitude, forKey : "Latitude" as NSCopying)
                    dataDic.setObject($0.value.Longitude, forKey : "Longitude" as NSCopying)
                    
                    self.dataArr.append(dataDic)
                    group.leave()
                    
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.progressView.hide(navItem: self.navigationItem)
                    let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
                    if !self.dataArr.isEmpty {
                        viewCtrl.searchDataArr = self.dataArr
                    }
                    self.navigationController?.pushViewController(viewCtrl, animated: true)
                })
            }
        }
    }
    
    // MARK: sliderChangedAction
    @IBAction func sliderChangedAction(_ sender: Any) {
        self.lblHandicap.text = "Handicap \((self.slider.value*10).rounded()/10)"//(value as! NSString).floatValue
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\((self.slider.value*10).rounded()/10)"] as [AnyHashable:Any])
    }
    
    // MARK: btnCheckBoxAction
    @IBAction func btnCheckBoxAction(_ sender: Any) {
        if(self.btnCheckbox.isSelected){
            self.btnCheckbox.isSelected = false
            self.btnCheckbox.setBackgroundImage(nil, for: .normal)
            self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
            self.sliderHandicapNumber.isEnabled = true
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\(Int(self.slider.value))"] as [AnyHashable:Any])
        }
        else{
            self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
            self.btnCheckbox.imageView?.sizeToFit()
            self.btnCheckbox.isSelected = true
            self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
            self.sliderHandicapNumber.isEnabled = false
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
        }
    }
    
    @IBAction func editGolfBagAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "GolfBagVC") as! GolfBagVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile".localized()
        
        self.viewTopWhatIsPro.isHidden = true
        whatISProHeightConstraint.constant = 0.0
        self.view.layoutIfNeeded()
        
        btnUpdradeNow.layer.cornerRadius = 3.0
        viewYearlyBtn.layer.cornerRadius = 3.0
        btnInviteNow.layer.cornerRadius = 3.0
        
        viewProMembership.isHidden = true
        viewUpgradeInactive.isHidden = true
        viewUpgradeFreeActive.isHidden = true
        viewUpgradeActive.isHidden = true
        
        let buttonTitleStr = NSMutableAttributedString(string: "Have Indiegogo promo code?", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnInactiveIndiegogo.setAttributedTitle(attributedString, for: .normal)
        btnFreeActiveIndiegogo.setAttributedTitle(attributedString, for: .normal)
        btnActiveIndiegogo.setAttributedTitle(attributedString, for: .normal)
        btnInactiveIndiegogo.isHidden = true
        btnFreeActiveIndiegogo.isHidden = true
        
        imagePicker.delegate=self
        PKCCropHelper.shared.degressBeforeImage = UIImage(named: "pkc_crop_rotate_left.png")
        PKCCropHelper.shared.degressAfterImage = UIImage(named: "pkc_crop_rotate_right.png")

        getData()
        
    }
    
    // MARK: getData
    func getData()  {
        btnUpdradeNow.isEnabled = false
        progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            
            var userData = NSMutableDictionary()
            if(snapshot.value != nil){
                userData = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                
                if (userData.value(forKey: "golfBag") == nil){
//                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["golfBag":self.selectedClubs] as [AnyHashable:Any])
                }
                if (userData.value(forKey: "gender") == nil){
                    self.genderCardView.isHidden = false
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gender":"male"] as [AnyHashable:Any])
                }
                if (userData.value(forKey: "handed") == nil){
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
                    self.handSelection.selectedSegmentIndex = 1
                }
                if (userData.value(forKey: "handicap") == nil){
//                    if ((userData.value(forKey: "handicap") as! String) == "-"){
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
                        self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
                        self.btnCheckbox.imageView?.sizeToFit()
                        self.btnCheckbox.isSelected = true
                        self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
                        self.sliderHandicapNumber.isEnabled = false
//                    }
                }
                if (userData.value(forKey: "proMembership") == nil){
                    self.viewTopWhatIsPro.isHidden = false
                    self.whatISProHeightConstraint.constant = 57.0

                    self.lblInactivePrice.text = "free for 30 days".localized()
                    if (userData.value(forKey: "trial") as? Bool) != nil{
                        self.lblInactivePrice.text = "Your Pro Membership has been expired"
                        self.viewTopWhatIsPro.isHidden = true
                        self.whatISProHeightConstraint.constant = 0.0
                    }
                    self.viewUpgradeInactive.isHidden = false
                    self.viewUpgradeFreeActive.isHidden = true
                    self.viewUpgradeActive.isHidden = true
                }
                for (key,value) in userData{
                    let keys = key as! String
                     if (keys == "handed"){
                        self.handSelection.selectedSegmentIndex = 1
                        if(value as! String == "Left"){
                            self.handSelection.selectedSegmentIndex = 0
                        }
                    }else if (keys == "handicap"){
                        if (value as! NSString) == "-"{
                            self.sliderHandicapNumber.isEnabled = false
                            self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
                            self.btnCheckbox.imageView?.sizeToFit()
                            self.btnCheckbox.isSelected = true
                            self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
                        }

                        self.sliderHandicapNumber.value = (value as! NSString).floatValue
                        self.lblHandicap.text = "Handicap \(self.sliderHandicapNumber.value)"
                    }
                    else if(keys == "gender"){
                        self.genderCardView.isHidden = true
                        if value as? String == "male"{
                            self.genderSgmtCtrl.selectedSegmentIndex = 0
                        }
                        else{
                            self.genderSgmtCtrl.selectedSegmentIndex = 1
                        }
                    }
                    else if(keys == "proMembership"){
                        self.viewTopWhatIsPro.isHidden = true
                        self.whatISProHeightConstraint.constant = 0.0
                        self.view.layoutIfNeeded()
                        
                    let dic  = value as! NSDictionary
                            self.viewUpgradeInactive.isHidden = true
                            self.viewUpgradeFreeActive.isHidden = true
                            self.viewUpgradeActive.isHidden = false
                            
                            if dic.value(forKey: "productID") as! String == Constants.PROMO_CODE_YEARLY_PRODUCT_ID{
                                self.btnActiveIndiegogo.isHidden = true
                                self.lblNextBilling.isHidden = true
                            }
                            
                            let timeNow = NSDate()
                            let formatter = DateFormatter()
                                formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                            let currentDateStr = formatter.string(from: timeNow as Date)
                            let currentDate = formatter.date(from: currentDateStr)
                            
                            let expiryDF = DateFormatter()
                                expiryDF.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                            let expDate = expiryDF.date(from: dic.value(forKey: "expiryDate") as! String)
                            //let expDateStr = formatter.string(from: expDate!)

                            if (dic.value(forKey: "expiryDate") != nil){
                                self.lblNextBilling.text = "Next Billing " + " \((dic.value(forKey: "expiryDate")!))"
                            }
                            if (dic.value(forKey: "transactionDate") != nil){
                                let df = DateFormatter()
                                    df.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                                let myDate = df.date(from: dic.value(forKey: "transactionDate") as! String)
                                    df.dateFormat = "dd-MMM-yyyy"
                                let myDateStr = df.string(from: myDate!)

                                self.lblLastBilling.text = "Member since " + " \(myDateStr)"
                            }
                            
                            switch currentDate?.compare(expDate!) {
                            case .orderedAscending?     :   debugPrint("currentDate is earlier than expDate")
                                
                            case .orderedDescending?    :   debugPrint("currentDate is later than expDate")
                                                            self.viewUpgradeInactive.isHidden = false
                                                            self.viewUpgradeFreeActive.isHidden = true
                                                            self.viewUpgradeActive.isHidden = true
                                                            self.lblInactivePrice.text = "Your Pro Membership has been expired"
                            case .orderedSame?          :   debugPrint("Both dates are same")
                                                            self.viewUpgradeInactive.isHidden = false
                                                            self.viewUpgradeFreeActive.isHidden = true
                                                            self.viewUpgradeActive.isHidden = true
                                                            self.lblInactivePrice.text = "Your Pro Membership has been expired"
                            case .none: break
                            }
                    }
                }
                self.btnUpdradeNow.isEnabled = true
                self.setupInitialUI()
                self.progressView.hide(navItem: self.navigationItem)
                self.viewProMembership.isHidden = false
            })
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "homeCourseDetails/name") { (snapshot) in

            var homecourseName = String()
            if(snapshot.value != nil){
                homecourseName = (snapshot.value as? String)!
                self.lblHomeCourseName.text = homecourseName
            }
            else{
                self.lblHomeCourseName.text = "-"
            }
            DispatchQueue.main.async(execute: {
                FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
                    if(snapshot.value != nil){
                        let golfBagArray = snapshot.value as! NSMutableArray
                        if golfBagArray.count > 0{
                            self.selectedClubs = NSMutableArray()
                            for i in 0..<golfBagArray.count{
                                if let dict = golfBagArray[i] as? NSDictionary{
                                    self.selectedClubs.add(dict)
                                }
                                else{
                                    let tempArray = snapshot.value as! NSMutableArray
                                    var golfBagData = [String: NSMutableArray]()
                                    for i in 0..<tempArray.count{
                                        let golfBagDict = NSMutableDictionary()
                                        golfBagDict.setObject("", forKey: "brand" as NSCopying)
                                        golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                                        golfBagDict.setObject(tempArray[i], forKey: "clubName" as NSCopying)
                                        golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                                        golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                                        golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                                        golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)

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
                        }
                    }
                    else{
                        let golfBagArray = NSMutableArray()
                        golfBagArray.addObjects(from: ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"])
                        var golfBagData = [String: NSMutableArray]()
                        self.selectedClubs = NSMutableArray()
                        let tempArray = NSMutableArray()

                        for i in 0..<golfBagArray.count{
                        let golfBagDict = NSMutableDictionary()
                        golfBagDict.setObject("", forKey: "brand" as NSCopying)
                        golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                        golfBagDict.setObject(golfBagArray[i], forKey: "clubName" as NSCopying)
                        golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                        golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                        golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                        golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)

                        tempArray.insert(golfBagDict, at: i)
                        golfBagData = ["golfBag": tempArray]
                            
                        self.selectedClubs.add(golfBagDict)
                        }
                        if golfBagData.count>0{
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.progressView.hide(navItem: self.navigationItem)
                        
                        let golfBagArray = NSMutableArray()
                        golfBagArray.addObjects(from: ["Dr","3w","4w","5w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","3i","4i","5i","6i","7i","8i","9i", "Pw","Gw","Sw","Lw","Pu"])
                        let tempArray = NSMutableArray()
                        
                            for j in 0..<golfBagArray.count{
                            for i in 0..<self.selectedClubs.count{
                            let dict = self.selectedClubs[i] as! NSDictionary
                            if golfBagArray[j] as! String == (dict.value(forKey: "clubName") as! String){
                                tempArray.add(dict)
                            }
                        }
                    }
                        self.selectedClubs = NSMutableArray()
                        self.selectedClubs.addObjects(from: tempArray as! [Any])
                        self.setGolfBagUI()
                    })
                }
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.hide()
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
//            golfBagContainerView.addSubview(btnTag)

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
                    titleLbl.text = String(firstChar) + " Woods"
                }
            }
            golfBagContainerView.addSubview(titleLbl)

            incr = incr + 1
            xOffset = Double(CGFloat(incr) * (CGFloat(btnWidth) + horzSpace))
        }
        golfBagHConstraint.constant = CGFloat(yOffset + btnHeight + lblHeight)
        self.view.layoutIfNeeded()
    }
    
    // MARK: setupInitialUI
    func setupInitialUI(){
        self.lblTryPremium.text = "Get your 30 days membership absolutely FREE".localized()
        self.btnUserImg.setCornerWithCircle(color: UIColor.glfBluegreen.cgColor)
        self.btnUserImg.sd_setBackgroundImage(with: Auth.auth().currentUser?.photoURL ?? URL(string:""), for: .normal, completed: nil)
        if Auth.auth().currentUser?.photoURL == nil{
            btnUserImg.setBackgroundImage(UIImage(named:"you"), for: .normal)
        }
//        self.btnUserImg.isEnabled = false //change in next build
        self.btnUserName.setTitle("\(Auth.auth().currentUser?.displayName ?? "Guest")", for: .normal)
        self.btnUserName.isEnabled = false //change in next build
        self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
        self.btnCheckbox.tintColor = UIColor.clear
        self.lblMinimumValue.text = "0"
        
        /*var i = 0
        for view in self.stackViewForClubs.subviews{
            if view.isKind(of: UIStackView.self){
                for btn in view.subviews{
                    if btn.isKind(of: UIButton.self){
                        (btn as! UIButton).setCornerWithCircleWidthOne(color: UIColor.glfWarmGrey.cgColor)
                        (btn as! UIButton).setTitle(clubs[i], for: .normal)
                        (btn as! UIButton).isSelected = false
                        if(selectedClubs.contains(clubs[i])){
                            (btn as! UIButton).isSelected = true
                            (btn as! UIButton).setCornerWithCircleWidthOne(color: UIColor.glfFlatBlue.cgColor)
                            (btn as! UIButton).tintColor = UIColor.glfFlatBlue
                            (btn as! UIButton).backgroundColor = UIColor.glfFlatBlue
                        }
                        (btn as! UIButton).tag = i
//                        (btn as! UIButton).addTarget(self, action: #selector(clubButtonClick), for: .touchUpInside)
                        clubsBtn.append(btn as! UIButton)
                        i += 1
                    }
                }
            }
        }*/
    }

    /*// MARK: clubButtonClick
    @objc func clubButtonClick(_ sender: UIButton!) {
        if(sender.isSelected){
            sender.isSelected = false
            sender.setCornerWithCircleWidthOne(color: UIColor.glfWarmGrey.cgColor)
            sender.backgroundColor = UIColor.clear
            selectedClubs.remove(at:selectedClubs.index(of: (sender.titleLabel?.text!)!)!)
        }else{
            sender.isSelected = true
            sender.setCornerWithCircleWidthOne(color: UIColor.glfFlatBlue.cgColor)
            sender.tintColor = UIColor.glfFlatBlue
            sender.backgroundColor = UIColor.glfFlatBlue
            selectedClubs.append((sender.titleLabel?.text!)!)
        }
        self.lblClub.text = "\(selectedClubs.count) Clubs"
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["golfBag":self.selectedClubs] as [AnyHashable:Any])
    }*/
}

extension UIImage {
    //https://stackoverflow.com/questions/43256005/swift-ios-reduce-image-size-before-upload
    
    func resizeWithPercent(width: CGFloat, percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width * percentage, height: width * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
}
}

extension ProfileVC: PKCCropDelegate{
    //return Crop Image & Original Image
    func pkcCropImage(_ image: UIImage?, originalImage: UIImage?) {
        if let image = image{
            //let compressedImage = image.resizeWithPercent(width: 70, percentage: 60)!
            //let compressedImage = image.resizeWithWidth(width: 210)!
            btnUserImg.setBackgroundImage(image, for: .normal)
            uploadImageInFirebase(chosenImage: image)
        }
    }
    
    //If crop is canceled
    func pkcCropCancel(_ viewController: PKCCropViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Successful crop
    func pkcCropComplete(_ viewController: PKCCropViewController) {
//        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            return
        }
        //https://github.com/pikachu987/PKCCrop
        PKCCropHelper.shared.isNavigationBarShow = false
        cropVC = PKCCropViewController(image, tag: 1)
        cropVC.delegate = self
        picker.present(cropVC, animated: true, completion: nil)
    }
}
