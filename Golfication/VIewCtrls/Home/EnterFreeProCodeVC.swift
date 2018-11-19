//
//  EnterFreeProCodeVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 09/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class EnterFreeProCodeVC: UIViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var btnAnualProMember: UIButton!
    @IBOutlet weak var dismissView: UIView!

    var isValidCode = false
    var isSuccess = false
    var attrs = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0),
        NSAttributedStringKey.foregroundColor : UIColor.blue,
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    var attributedString = NSMutableAttributedString(string:"")

    // MARK: indiegogoWebViewAction
    @IBAction func indiegogoWebViewAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
        viewCtrl.fromIndiegogo = true
        viewCtrl.fromNotification = false

        self.present(viewCtrl, animated: false, completion: nil)
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
       playButton.contentView.isHidden = true
       playButton.floatButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.title = "Enter Free Pro Membership Code"
        codeTextField.becomeFirstResponder()
        
        let buttonTitleStr = NSMutableAttributedString(string: "Get your annual pro membership for only $25. NOW!", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnAnualProMember.setAttributedTitle(attributedString, for: .normal)
        
        btnAnualProMember.titleLabel?.lineBreakMode = .byWordWrapping
        btnAnualProMember.titleLabel?.textAlignment = .center
        btnAnualProMember.setTitle("Get your annual pro membership for only $25. NOW!",for: .normal)
        
        let gestureView = UITapGestureRecognizer(target: self, action:  #selector (self.dismissView (_:)))
        dismissView.addGestureRecognizer(gestureView)
    }
    
    // MARK: - dismissView
    @objc func dismissView(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func submtCodeAction(_ sender: UIButton) {
        if codeTextField.text == ""{
            let alert = UIAlertController(title: "Alert", message: "Please Enter Pro Membership Code", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            self.actvtIndView.isHidden = false
            self.actvtIndView.startAnimating()
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "codes") { (snapshot) in
                
                var codeData = NSMutableDictionary()
                if(snapshot.value != nil){
                    codeData = snapshot.value as! NSMutableDictionary
                    
                    let valArr = codeData.allValues
                    for i in 0..<valArr.count{
                        let codeVal = valArr[i] as! String
                        if  codeVal == Auth.auth().currentUser!.uid{
                            self.actvtIndView.isHidden = true
                            self.actvtIndView.stopAnimating()
                            let alert = UIAlertController(title: "Alert", message: "You have already become a pro member.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    }
                    for (keys,value) in codeData{
                                if(keys as? String == self.codeTextField.text)
                                {
                                    self.isValidCode = true
                                    if !(value as? String == Auth.auth().currentUser!.uid){
                                        if value as? String == "N"{
                                            self.isSuccess = true
                                            ref.child("codes/").updateChildValues(["\(keys)" : Auth.auth().currentUser!.uid] as [AnyHashable:Any])
                                            break
                                        }
                                        else{
                                            self.isSuccess = false
                                            break
                                        }
                                    }
                                    else{
                                        let alert = UIAlertController(title: "Alert", message: "You have already applied this code.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        break
                        }
                     }
                  }
                }
                DispatchQueue.main.async(execute: {
                    
                    if self.isValidCode == false{
                        let alert = UIAlertController(title: "Alert", message: "Please Enter Valid Code", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if  self.isValidCode && self.isSuccess == false{
                        self.isValidCode = false
                        let alert = UIAlertController(title: "Alert", message: "Code expired", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if self.isValidCode && self.isSuccess == true{
                        self.isValidCode = false
                        self.isSuccess = false
                        //let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
                          //  alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                                
//                                viewUpgradeInactive.isHidden = true
//                                viewUpgradeFreeActive.isHidden = false
//                                viewUpgradeActive.isHidden = true

                                //self.dismiss(animated: true, completion: nil)

                                let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(self.beginTimestamp/1000)))
                                let timeEnd = Calendar.current.date(byAdding: .month, value: 12, to: timeStart as Date)
                                let formatter = DateFormatter()
                                formatter.locale = Locale(identifier: "en")
                                formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"

                                let expiryStr = formatter.string(from: timeEnd!)
                                let trnStr = formatter.string(from: timeStart as Date)
                                
                                let membershipDict = NSMutableDictionary()
                                membershipDict.setObject(0, forKey: "isMembershipActive" as NSCopying)
                                membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
                                membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
                                membershipDict.setObject(Constants.PROMO_CODE_YEARLY_PRODUCT_ID, forKey: "productID" as NSCopying)
                                membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
                                membershipDict.setObject("ios", forKey: "device" as NSCopying)

                                let proMembership = ["proMembership":membershipDict]
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
                                
                                UserDefaults.standard.set(false, forKey: "isNewUser")
                                UserDefaults.standard.synchronize()
                                //lblDaysLeft.text = "You have 29 days remaining on your Pro Membership"
//                                let components = calendar.dateComponents([.day], from: timeNow as Date, to: timeEnd!)
//                                self.lblDaysLeft.text = "You have " + "\(components.day!)" + " days remaining on your Pro Membership"
                                
//                              self.viewTopWhatIsPro.isHidden = true
                                Constants.isProfileUpdated = true
                        
                        if let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as? ProfileProMemberPopUPVC{
                        viewCtrl.fromUpgrade = true
                        Constants.fromIndiegogo = true
                        viewCtrl.modalPresentationStyle = .overCurrentContext
                        self.present(viewCtrl, animated: true, completion: nil)
                        }
                        

//                                whatISProHeightConstraint.constant = 0.0
//                                self.view.layoutIfNeeded()
                        //}))
                        //self.present(alert, animated: true, completion: nil)
                    }
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                })
            }
        }
    }
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970) * 1000
    }
}
