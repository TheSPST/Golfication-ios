//
//  NewUserProPopUPVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewUserProPopUPVC: UIViewController {
    
    // MARK: Set Outlets
    @IBOutlet weak var btnUpgrdeNow: UIButton!
    @IBOutlet weak var btnCheckbox: UIButton!
    
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblHandicap: UILabel!
    @IBOutlet weak var lblHomeCourseName: UILabel!

    @IBOutlet weak var handSelection: UISegmentedControl!
    @IBOutlet weak var sliderHandicapNumber: UISlider!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!

    @IBOutlet weak var golfBagContainerView: UIView!
    @IBOutlet weak var golfBagHConstraint: NSLayoutConstraint!

    // MARK: Set Variables
    var clubs = ["Dr","3w","4w","5w","7w","1h","2h","3h","4h","5h","6h","7h","1i","2i","3i","4i","5i","6i","7i","8i","9i", "Pw","Gw","Sw","Lw","Pu"]
//    var selectedClubs = ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu"]
    var clubsBtn = [UIButton]()
    var dataArr = NSMutableArray()
    var selectedClubs = NSMutableArray()

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnUpgrdeNow.layer.cornerRadius = 3.0

        self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
        self.btnCheckbox.tintColor = UIColor.clear
        
        self.handSelection.selectedSegmentIndex = 1
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
        
        self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "path15"), for: .normal)
        self.btnCheckbox.imageView?.sizeToFit()
        self.btnCheckbox.isSelected = true
        self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
        self.sliderHandicapNumber.isEnabled = false
    }

    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "homeCourseDetails/name") { (snapshot) in
            var homecourseName = String()
            if(snapshot.value != nil){
                homecourseName = (snapshot.value as? String)!
                self.lblHomeCourseName.text = homecourseName
            }
            else{
                self.lblHomeCourseName.text = "-"
            }
        }
        
        /*self.lblClub.text = "\(selectedClubs.count) Clubs"
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["golfBag":self.selectedClubs] as [AnyHashable:Any])
        var i = 0
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
                        (btn as! UIButton).addTarget(self, action: #selector(clubButtonClick), for: .touchUpInside)
                        clubsBtn.append(btn as! UIButton)
                        i += 1
                    }
                }
            }
        }*/
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
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
                self.setGolfBagUI()
            })
        }
    }
    
    // MARK: setGolfBagUI
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
            //golfBagContainerView.addSubview(btnTag)
            
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
    
    // MARK: editGolfBagAction
    @IBAction func editGolfBagAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "GolfBagVC") as! GolfBagVC
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        //        self.present(viewCtrl, animated: true, completion: nil)
    }

    // MARK: btnCheckBoxAction
    @IBAction func btnCheckBoxAction(_ sender: Any) {
        if(self.btnCheckbox.isSelected){
            self.btnCheckbox.isSelected = false
            self.btnCheckbox.setBackgroundImage(nil, for: .normal)
            self.btnCheckbox.setCorner(color: UIColor.glfWarmGrey.cgColor)
            self.sliderHandicapNumber.isEnabled = true
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\(Int(self.sliderHandicapNumber.value))"] as [AnyHashable:Any])
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
    
    // MARK: sliderChangedAction
    @IBAction func sliderChangedAction(_ sender: Any) {
        self.lblHandicap.text = "Handicap \(Int(self.sliderHandicapNumber.value))"
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\(Int(self.sliderHandicapNumber.value))"] as [AnyHashable:Any])
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
    
    // MARK: btnActionChangeCourse
    @IBAction func btnActionChangeCourse(_ sender: Any) {
        
        let latitude = Double("64.830673")!
        let longitude = Double("-147.576172")!
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
            else{
                self.dataArr =  NSMutableArray()
                
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
                    
                    self.dataArr.add(dataDic)
                    group.leave()
                    
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                    
                    let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
                    if self.dataArr.count>0 {
                        viewCtrl.searchDataArr = self.dataArr
                    }


                   self.navigationController?.pushViewController(viewCtrl, animated: true)
                })
            }
        }
    }
    
    // MARK: skipAction
    @IBAction func skipAction(_ sender: Any) {
//        UserDefaults.standard.set(false, forKey: "isNewUser")
//        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: upgradeAction
    @IBAction func upgradeAction(_ sender: Any) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as! ProfileProMemberPopUPVC
        viewCtrl.fromNewUserPopUp = true
        viewCtrl.modalPresentationStyle = .overCurrentContext
        present(viewCtrl, animated: true, completion: nil)
        
        let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(self.beginTimestamp/1000)))
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
        membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
        membershipDict.setObject("ios", forKey: "device" as NSCopying)

        let proMembership = ["proMembership":membershipDict]
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
        UserDefaults.standard.set(false, forKey: "isNewUser")
        UserDefaults.standard.synchronize()
    }
    
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970) * 1000
    }
}
