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

class ProfileVC: UIViewController, BluetoothDelegate {
    
    // MARK: - Set Outlets
    @IBOutlet weak var lblHomeCourseName: UILabel!
    @IBOutlet weak var lblGolfBagTitle: UILocalizedLabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblHandicap: UILocalizedLabel!
    @IBOutlet weak var lblMinimumValue: UILabel!
    @IBOutlet weak var lblMaxValue: UILabel!
    @IBOutlet weak var lblNextBilling: UILabel!
    @IBOutlet weak var lblLastBilling: UILabel!

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderHandicapNumber: UISlider!

    @IBOutlet weak var btnUserImg: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnCheckbox: UIButton!

    @IBOutlet weak var handSelection: UISegmentedControl!
    @IBOutlet weak var genderSgmtCtrl: UISegmentedControl!

    @IBOutlet weak var viewProMembership: UIView!
    var golfBagArray = NSMutableArray()
    var progressView = SDLoader()

    var fromPublicProfile = Bool()
    
    @IBOutlet weak var golfBagContainerView: UIView!
    @IBOutlet weak var golfBagHConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnConnectGolfX: UIButton!
    
    @IBOutlet weak var editSV: UIStackView!
    @IBOutlet weak var defaultSV: UIStackView!
    @IBOutlet weak var editProfileBtnSV: UIStackView!
    @IBOutlet weak var changeCourseBtnSV: UIStackView!
    @IBOutlet weak var btnSaveProfile: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var lblDefaultHandicap: UILabel!
    @IBOutlet weak var lblGrip: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var btnUpgradeToPro: UIButton!
    @IBOutlet weak var lblProStatus: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnChangeCourse: UIButton!

    var appDelegate: AppDelegate!

    // MARK: - Initialize Variables
    let imagePicker = UIImagePickerController()
    var selectedClubs = NSMutableArray()
    
    var clubsBtn = [UIButton]()
    var dataArr = [NSMutableDictionary]()
    var attrs = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13.0),
        NSAttributedStringKey.foregroundColor : UIColor(rgb: 0xFE006B),
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    var attributedString = NSMutableAttributedString(string:"")
    
    var connectAttrs = [
        NSAttributedStringKey.font : UIFont(name: "SFProDisplay-Medium", size: 15.0)!,
        NSAttributedStringKey.foregroundColor : UIColor.glfBluegreen,
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]

    var cropVC: PKCCropViewController!

    var sharedInstance: BluetoothSync!
    var bluetoothStatus: Bool!
    var bluetoothMessage = String()

    @IBAction func supportAction(_ sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        self.present(navCtrl, animated: true, completion: nil)
    }

    // MARK: editProfileAction
    @IBAction func editProfileAction(_ sender: Any){

        editSV.isHidden = false
        defaultSV.isHidden = true
        
        editProfileBtnSV.isHidden = true
        changeCourseBtnSV.isHidden = false
        btnCamera.isHidden = false
    }
    
    // MARK: editProfileAction
    @IBAction func saveProfileAction(_ sender: Any){
        editSV.isHidden = true
        defaultSV.isHidden = false
        
        editProfileBtnSV.isHidden = false
        changeCourseBtnSV.isHidden = true
        btnCamera.isHidden = true
    }

    // MARK: topProAction
    @IBAction func topProAction(_ sender: Any){

    let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
    viewCtrl.source = "Profile"
    self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    
    // MARK: connectBluetoothAction
    @IBAction func connectBluetoothAction(_ sender: Any) {
        if bluetoothStatus{
            Constants.tempGolfBagArray = NSMutableArray()
            Constants.tempGolfBagArray = NSMutableArray(array: self.golfBagArray)

            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
            viewCtrl.golfBagArr = self.golfBagArray
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else{
            let alertVC = UIAlertController(title: "Alert", message: bluetoothMessage, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func didUpdateState(_ state: CBManagerState) {
        debugPrint("state== ",state)
        var alert = String()
        
        switch state {
        case .poweredOff:
            alert = "Make sure that your bluetooth is turned on."
            break
        case .poweredOn:
            debugPrint("State : Powered On")
            bluetoothStatus = true
            
            let atrString = NSMutableAttributedString(string:"")
            let buttonTitleStr = NSMutableAttributedString(string: "Connect Now", attributes:connectAttrs)
            atrString.append(buttonTitleStr)
            btnConnectGolfX.setAttributedTitle(atrString, for: .normal)

            if(Constants.deviceGolficationX != nil){
                let atrString = NSMutableAttributedString(string:"")
                let buttonTitleStr = NSMutableAttributedString(string: "Paired", attributes:connectAttrs)
                atrString.append(buttonTitleStr)
                btnConnectGolfX.setAttributedTitle(atrString, for: .normal)
            }
            return
            
        case .unsupported:
            alert = "This device is unsupported."
            break
        default:
            alert = "Try again after restarting the device."
            break
        }
        self.bluetoothStatus = false
        bluetoothMessage = alert
        
        let atrString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string: "Connect Now", attributes:connectAttrs)
        atrString.append(buttonTitleStr)
        btnConnectGolfX.setAttributedTitle(atrString, for: .normal)
    }
    
    // MARK: genderChanged
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        switch genderSgmtCtrl.selectedSegmentIndex {
        case 0:
            lblGender.text = "Male"
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gender":"male"] as [AnyHashable:Any])
            Constants.gender = "male"
        case 1:
            lblGender.text = "Female"
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gender":"female"] as [AnyHashable:Any])
            Constants.gender = "female"
        default:
            break;
        }
    }
    
    // MARK: gripChanged
    @IBAction func gripChanged(_ sender: UISegmentedControl) {
        switch handSelection.selectedSegmentIndex {
        case 0:
            lblGrip.text = "Left Handed"
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Left"] as [AnyHashable:Any])
            Constants.handed = "Left"
        case 1:
            lblGrip.text = "Right Handed"
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
            Constants.handed = "Right"
        default:
            break;
        }
    }
    
    // MARK: backAction
   /* @IBAction func backAction(_ sender: UIBarButtonItem) {
        if fromPublicProfile{
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
    }*/
    
    @IBAction func settingAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        viewCtrl.golfBagArray = self.golfBagArray
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Profile Change Image")
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Profile Change Course")
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
                    self.progressView.hide(navItem: self.navigationItem)
                    if !(self.appDelegate.isInternet){
                        let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
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
        FBSomeEvents.shared.singleParamFBEvene(param: "Profile Change HCP")
        self.lblHandicap.text = "Handicap".localized() + " \((self.slider.value*10).rounded()/10)"//(value as! NSString).floatValue
        self.lblDefaultHandicap.text = "\((self.slider.value*10).rounded()/10)"//(value as! NSString).floatValue

        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\((self.slider.value*10).rounded()/10)"] as [AnyHashable:Any])
        Constants.handicap = "\((self.slider.value*10).rounded()/10)"
    }
    
    // MARK: btnCheckBoxAction
    @IBAction func btnCheckBoxAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Profile Change HCP")
        if(self.btnCheckbox.isSelected){
            self.btnCheckbox.isSelected = false
            self.btnCheckbox.setBackgroundImage(nil, for: .normal)
            self.btnCheckbox.setCorner(color: UIColor.darkGray.cgColor)
            self.sliderHandicapNumber.isEnabled = true
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\(Int(self.slider.value))"] as [AnyHashable:Any])
            Constants.handicap = "\(Int(self.slider.value))"
        }
        else{
            self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
            self.btnCheckbox.imageView?.sizeToFit()
            self.btnCheckbox.isSelected = true
            self.btnCheckbox.setCorner(color: UIColor.darkGray.cgColor)
            self.sliderHandicapNumber.isEnabled = false
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
            Constants.handicap = "-"
        }
    }
    
    @IBAction func editGolfBagAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Profile Edit Bag")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "GolfBagVC") as! GolfBagVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile".localized()
        
        let originalImage = UIImage(named:"text_edit_blue")!
        let courseImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnEditProfile.tintColor = UIColor(rgb:0x3A7CA5).withAlphaComponent(0.75)
        btnEditProfile.setImage(courseImage, for: .normal)

        btnChangeCourse.tintColor = UIColor(rgb:0x3A7CA5).withAlphaComponent(0.75)
        btnChangeCourse.setImage(courseImage, for: .normal)

        lblProStatus.layer.cornerRadius = 3.0
        lblProStatus.layer.masksToBounds = true
        lblProStatus.backgroundColor = UIColor.glfFlatBlue
        lblProStatus.text = "Basic"
        if Constants.isProMode{
            btnUpgradeToPro.isHidden = true
            lblProStatus.text = "PRO"
            lblProStatus.backgroundColor = UIColor(rgb:0xFFC700)
        }
        btnUpgradeToPro.setCorner(color: UIColor(rgb:0xFFC700).cgColor)
        btnSaveProfile.setCorner(color: UIColor.clear.cgColor)
        saveProfileAction(btnSaveProfile)
        
        viewProMembership.isHidden = true
        
        imagePicker.delegate=self
        PKCCropHelper.shared.degressBeforeImage = UIImage(named: "pkc_crop_rotate_left.png")
        PKCCropHelper.shared.degressAfterImage = UIImage(named: "pkc_crop_rotate_right.png")

//        if Constants.gender == ""{
//            self.genderCardView.isHidden = false
//        }
//        else{
//            self.genderCardView.isHidden = true
            if Constants.gender == "male"{
                self.genderSgmtCtrl.selectedSegmentIndex = 0
                lblGender.text = "Male"
            }
            else{
                self.genderSgmtCtrl.selectedSegmentIndex = 1
                lblGender.text = "Female"
            }
        //}
        
        if Constants.handed == ""{
            lblGrip.text = "Right Handed"
            self.handSelection.selectedSegmentIndex = 1
        }
        else{
            lblGrip.text = "Right Handed"
            self.handSelection.selectedSegmentIndex = 1
            if(Constants.handed == "Left"){
                lblGrip.text = "Left Handed"
                self.handSelection.selectedSegmentIndex = 0
            }
        }
        
        if Constants.handicap == ""{
            self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
            self.btnCheckbox.imageView?.sizeToFit()
            self.btnCheckbox.isSelected = true
            self.btnCheckbox.setCorner(color: UIColor.darkGray.cgColor)
            self.sliderHandicapNumber.isEnabled = false
        }
        else{
            if Constants.handicap == "-"{
                self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
                self.btnCheckbox.imageView?.sizeToFit()
                self.btnCheckbox.isSelected = true
                self.btnCheckbox.setCorner(color: UIColor.darkGray.cgColor)
                self.sliderHandicapNumber.isEnabled = false
            }
            self.sliderHandicapNumber.value = (Constants.handicap as NSString).floatValue
            self.lblHandicap.text = "Handicap".localized() + " \(self.sliderHandicapNumber.value)"
            self.lblDefaultHandicap.text = "\(self.sliderHandicapNumber.value)"
        }
        getData()
        FBSomeEvents.shared.singleParamFBEvene(param: "View My Profile")
    }
    
    // MARK: getData
    func getData()  {
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMembership") { (snapshot) in

            if(snapshot.value != nil){
                var proData = NSDictionary()
                proData = snapshot.value as! NSDictionary
                
                self.viewProMembership.isHidden = false
                
                if proData.value(forKey: "productID") as! String == Constants.PROMO_CODE_YEARLY_PRODUCT_ID{
                    self.lblNextBilling.isHidden = true
                }
                
                let timeNow = NSDate()
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en")
                formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                let currentDateStr = formatter.string(from: timeNow as Date)
                let currentDate = formatter.date(from: currentDateStr)
                
                let expiryDF = DateFormatter()
                expiryDF.locale = Locale(identifier: "en")
                expiryDF.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                
//                let expDate = expiryDF.date(from: proData.value(forKey: "expiryDate") as! String)
                //let expDateStr = formatter.string(from: expDate!)
                
                if (proData.value(forKey: "expiryDate") != nil){
//                    let locale = NSLocale.current.identifier
//                    expiryDF.locale = Locale(identifier: locale)
//                    let myDateStr = expiryDF.string(from: expDate!)
                    
                    self.lblNextBilling.text = "Next Billing " + (proData.value(forKey: "expiryDate") as! String)
                }
                if (proData.value(forKey: "transactionDate") != nil){
//                    let df = DateFormatter()
//                    df.locale = Locale(identifier: "en")
//                    df.dateFormat = "dd-MMM-yyyy HH:mm:ss"
//                    let myDate = df.date(from: proData.value(forKey: "transactionDate") as! String)
//                    df.dateFormat = "dd-MMM-yyyy"
                    var trnDateStr = proData.value(forKey: "transactionDate") as! String
                    trnDateStr.removeLast(8)
//                    let locale = NSLocale.current.identifier
//                    df.locale = Locale(identifier: locale)
//                    let myDateStr = df.string(from: myDate!)
                    
                    self.lblLastBilling.text = "Member since " + " \(trnDateStr)"
                }
                
                var timeEnd: Date!
                if let expTimestamp = proData.value(forKey: "timestamp") as? Int{
                    
                    let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(expTimestamp/1000)))
                    
                     timeEnd = Calendar.current.date(byAdding: .day, value: 365, to: timeStart as Date)
                    if proData.value(forKey: "productID") as? String != nil{
                        if (proData.value(forKey: "productID") as! String == Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID) || (proData.value(forKey: "productID") as! String == Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID) || (proData.value(forKey: "productID") as! String == Constants.FREE_MONTHLY_PRODUCT_ID) || (proData.value(forKey: "productID") as! String == Constants.AUTO_RENEW_EDDIE_MONTHLY_PRODUCT_ID){
                            
                            timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
                        }
                    }
                }
                
                switch currentDate?.compare(timeEnd!) {
                case .orderedAscending?    :   debugPrint("currentDate is earlier than expDate")

                case .orderedDescending?    :   debugPrint("currentDate is later than expDate")
                self.viewProMembership.isHidden = true
                case .orderedSame?         :   debugPrint("Both dates are same")
                self.viewProMembership.isHidden = true
                case .none: break
                }
            }
            else{
                self.viewProMembership.isHidden = true
            }
            self.setupInitialUI()
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false

        self.sharedInstance = BluetoothSync.getInstance()
        self.sharedInstance.delegate = self
        self.sharedInstance.initCBCentralManager()
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
                        self.golfBagArray = snapshot.value as! NSMutableArray
                        if self.golfBagArray.count > 0{
                            self.selectedClubs = NSMutableArray()
                            for i in 0..<self.golfBagArray.count{
                                if let dict = self.golfBagArray[i] as? NSDictionary{
                                    self.selectedClubs.add(dict)
                                    for data in Constants.clubWithMaxMin where data.name == dict.value(forKey: "clubName") as! String{
                                        if (data.name).contains("Pu"){
                                            dict.setValue(30, forKey: "avgDistance")
                                            self.golfBagArray[i] = dict
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":30])
                                        }else if(dict.value(forKey: "avgDistance") == nil){
                                            let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                            dict.setValue(avgDistance, forKey: "avgDistance")
                                            self.golfBagArray[i] = dict
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/golfBag/\(i)").updateChildValues(["avgDistance":avgDistance])
                                        }

                                    }
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
                                        golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                                        for data in Constants.clubWithMaxMin where data.name == tempArray[i] as! String{
                                            if (data.name).contains("Pu"){
                                                golfBagDict.setObject(30, forKey: "avgDistance" as NSCopying)
                                            }else{
                                                let avgDistance = BackgroundMapStats.getDataInTermOf5(data:Int((data.max + data.min)/2))
                                                golfBagDict.setObject(avgDistance, forKey: "avgDistance" as NSCopying)
                                            }
                                        }
                                        self.golfBagArray.replaceObject(at: i, with: golfBagDict)
                                        golfBagData = ["golfBag": self.golfBagArray]
                                        
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
                        golfBagDict.setObject("", forKey: "tagNum" as NSCopying)

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
            titleLbl.font = UIFont(name: "SFProDisplay-Regular", size: 9.0)
            
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
    
    // MARK: setupInitialUI
    func setupInitialUI(){
        self.btnUserImg.setCornerWithCircle(color: UIColor.glfBluegreen.cgColor)
        self.btnUserImg.sd_setBackgroundImage(with: Auth.auth().currentUser?.photoURL ?? URL(string:""), for: .normal, completed: nil)
        if Auth.auth().currentUser?.photoURL == nil{
            btnUserImg.setBackgroundImage(UIImage(named:"you"), for: .normal)
        }
//        self.btnUserImg.isEnabled = false //change in next build
        self.btnUserName.setTitle("\(Auth.auth().currentUser?.displayName ?? "Guest")", for: .normal)
        self.btnUserName.isEnabled = false //change in next build
        self.btnCheckbox.setCorner(color: UIColor.darkGray.cgColor)
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
