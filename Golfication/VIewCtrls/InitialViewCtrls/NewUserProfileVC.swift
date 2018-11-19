//
//  NewUserProfileVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class NewUserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    
    // MARK: Set Outlets
    let progressView = SDLoader()

    @IBOutlet weak var lblHandicap: UILabel!
    @IBOutlet weak var lblHandiLeft: UILocalizedLabel!
    @IBOutlet weak var lblHandiRight: UILocalizedLabel!
    
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var btnNext: UILocalizedButton!
    @IBOutlet weak var btnHandiLeft: UIButton!
    @IBOutlet weak var btnHandiRight: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnSkip: UILocalizedButton!

    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchContainerSV: UIView!
    @IBOutlet weak var nearMeContainerView: UIView!
    @IBOutlet weak var leftModeView: UIView!
    @IBOutlet weak var handiContainerView: UIView!
    @IBOutlet weak var handiLeftView: UIView!
    @IBOutlet weak var handiRightView: UIView!
    
    @IBOutlet weak var tblViewHConstraint: NSLayoutConstraint!
    @IBOutlet weak var golfTblHConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomStackSV: UIStackView!
    @IBOutlet weak var thirdSV: UIStackView!
    @IBOutlet weak var handiOrientContainerSV: UIStackView!

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var sliderHandicapNumber: UISlider!
    @IBOutlet weak var newProfileScrlView: UIScrollView!

    @IBOutlet weak var golfBagTblView: UITableView!
    @IBOutlet weak var courseTblView: UITableView!
    
    // MARK: Set Variables
    let kHeaderSectionTag: Int = 6900
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    var searchDataArr = [NSMutableDictionary]()
    var golfDataMArray = [NSMutableDictionary]()
    
    var dataArr = [NSMutableDictionary]()
    var selectedClubs = NSMutableArray()
    var clubsBtn = [UIButton]()
    var currentPageIndex = 0

    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        if (!(scrollView.contentOffset.y>0 || scrollView.contentOffset.y<0)){
            let pageWidth: CGFloat =  scrollView.frame.size.width
            let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
            
            self.pageControl.currentPage = Int(currentPage)
            
            let x =  CGFloat(self.pageControl.currentPage) * (pageWidth)
            scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
            
            btnNext.setTitle(" " + "Next".localized() + " ", for: .normal)
            if pageControl.currentPage == 2 {
                btnNext.setTitle("Done", for: .normal)
            }
            currentPageIndex = self.pageControl.currentPage
            if pageControl.currentPage == 1 || pageControl.currentPage == 2 {
                searchTxtField.resignFirstResponder()
            }
        }
    }
    
    // MARK: – TextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.leftModeView.bounds
        self.leftModeView.layer.addSublayer(gradient)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.leftModeView.frame
        rectShape.position = self.leftModeView.center
        rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
        self.leftModeView.layer.mask = rectShape
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        tblViewHConstraint.constant = 0
        nearMeContainerView.isHidden = false
        if !(textField.text == "") {
            self.searchGolfLocation(searchText: textField.text!)
        }
        return true
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSkip.setTitle(" " + "Skip".localized() + " ", for: .normal)
        btnNext.setTitle(" " + "Next".localized() + " ", for: .normal)

        btnNext.layer.cornerRadius = 15.0
        self.btnCheckbox.setCorner(color: UIColor.white.cgColor)
        self.btnCheckbox.tintColor = UIColor.clear
        
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
        
        self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
        self.btnCheckbox.imageView?.sizeToFit()
        self.btnCheckbox.isSelected = true
        self.btnCheckbox.setCorner(color: UIColor.white.cgColor)
//        self.sliderHandicapNumber.isEnabled = false
        
        golfBagTblView.layer.cornerRadius = 3.0
        handiContainerView.layer.cornerRadius = 3.0
        
        tblViewHConstraint.constant = 0
        nearMeContainerView.isHidden = false
        
        sectionNames = ["Drivers", "Hybrids", "Woods", "Irons", "Wedges", "Putters"]
        sectionItems = [["Dr"],
                        ["1h","2h","3h","4h","5h","6h","7h"],
                        ["3w","4w","5w","7W"],
                        ["1i","2i","3i","4i","5i","6i","7i","8i","9i"],
                        ["Pw","Gw","Sw","Lw"],
                        ["Pu"]
        ];
        self.golfBagTblView!.tableFooterView = UIView()
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.leftModeView.bounds
        self.leftModeView.layer.addSublayer(gradient)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.leftModeView.frame
        rectShape.position = self.leftModeView.center
        rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
        self.leftModeView.layer.mask = rectShape
        
        let originalImage1 = #imageLiteral(resourceName: "search")
        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnSearch.tintColor = UIColor.glfBluegreen
        btnSearch.setImage(backBtnImage1, for: .normal)
        
        handiLeftView.layer.cornerRadius = 10.0
        handiRightView.layer.cornerRadius = 10.0
        
        // ------ update golf bag 14 data to firbase ------------------
        self.progressView.show()
        golfBagTblView.isHidden = true
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.hide()
            
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
                self.golfBagTblView.isHidden = false
                self.golfBagTblView.delegate = self
                self.golfBagTblView.dataSource = self
                self.golfBagTblView.reloadData()
                
                if UIDevice.current.iPad{
                    self.golfTblHConstraint.constant = (4.5 * 44)
                    self.thirdSV.spacing = 5
                    self.handiOrientContainerSV.spacing = 5
                    self.bottomStackSV.spacing = 0
                }
            })
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: nearestCourseAction
    let locationManager = CLLocationManager()
    @IBAction func nearestCourseAction(_ sender: Any) {
        searchTxtField.resignFirstResponder()
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break
            
        case .restricted, .denied:
            
            // Disable location features
            let alert = UIAlertController(title: "Need Authorization or Enable GPS from Privacy Settings", message: "Please enable GPS to get your nearest course.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            if let currentLocation: CLLocation = locationManager.location{
                
                self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "Unable to get your current location. ", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            break
        }
    }
    
    // MARK: searchBtnTapped
    @IBAction func searchBtnTapped(_ sender: Any) {
        searchTxtField.resignFirstResponder()
        tblViewHConstraint.constant = 0
        nearMeContainerView.isHidden = false
        if !(searchTxtField.text == "") {
            self.searchGolfLocation(searchText: searchTxtField.text!)
        }
    }
    
    // MARK: getNearByData
    func getNearByData(latitude: Double, longitude: Double, currentLocation: CLLocation){
        
        self.progressView.show()

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.leftModeView.bounds
        self.leftModeView.layer.addSublayer(gradient)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.leftModeView.frame
        rectShape.position = self.leftModeView.center
        rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
        self.leftModeView.layer.mask = rectShape
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            if (arg0 == nil) && (error != nil){
                DispatchQueue.main.async(execute: {
                    // In case of -1 response
                    debugPrint("Error", error ?? "")
                })
            }
            else{
                self.golfDataMArray =  [NSMutableDictionary]()
                
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
                    dataDic.setObject($0.value.Mapped, forKey : "Mapped" as NSCopying)
                    if($0.key != "99999999"){
                        self.golfDataMArray.append(dataDic)
                    }
                    group.leave()
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.progressView.hide()
                    if !self.golfDataMArray.isEmpty{
                        self.golfDataMArray = BackgroundMapStats.sortAndShow(searchDataArr: self.golfDataMArray, myLocation: currentLocation)
                        let golfID = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Id") as? String)!
                        let golfName = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Name") as? String)!
                        let golfLong = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Longitude") as? String)!
                        let golfLat = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Latitude") as? String)!
                        let golfMapped = ((self.golfDataMArray[0] as AnyObject).value(forKey: "Mapped") as? String)!
                        
                        if golfMapped == "0"{
                            let gradient = CAGradientLayer()
                            gradient.colors = [UIColor(rgb: 0xD4D4D4).cgColor, UIColor(rgb: 0xBEBEBE).cgColor]
                            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                            gradient.frame = self.leftModeView.bounds
                            self.leftModeView.layer.addSublayer(gradient)
                        }
                        else if golfMapped == "1"{
                            let gradient = CAGradientLayer()
                            gradient.colors = [UIColor(rgb: 0x2D6194).cgColor, UIColor(rgb: 0x2D4393).cgColor]
                            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                            gradient.frame = self.leftModeView.bounds
                            self.leftModeView.layer.addSublayer(gradient)
                        }
                        else{
                            let gradient = CAGradientLayer()
                            gradient.colors = [UIColor(rgb: 0xF2A134).cgColor, UIColor(rgb: 0xF8CE49).cgColor]
                            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                            gradient.frame = self.leftModeView.bounds
                            self.leftModeView.layer.addSublayer(gradient)
                        }
                        let rectShape = CAShapeLayer()
                        rectShape.bounds = self.leftModeView.frame
                        rectShape.position = self.leftModeView.center
                        rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
                        self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
                        self.leftModeView.layer.mask = rectShape
                        
                        self.searchTxtField.text = golfName
                        
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["homeCourse":NSNull()])
                        
                        let homeCourseDic = NSMutableDictionary()
                        homeCourseDic.setObject(golfID, forKey: "id" as NSCopying)
                        homeCourseDic.setObject(golfLat, forKey: "lat" as NSCopying)
                        homeCourseDic.setObject(golfLong, forKey: "lng" as NSCopying)
                        homeCourseDic.setObject(golfName, forKey: "name" as NSCopying)
                        let homeCourseDetails = ["homeCourseDetails":homeCourseDic]
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(homeCourseDetails)
                        
                        UserDefaults.standard.set(golfLat, forKey: "HomeLat")
                        UserDefaults.standard.set(golfLong, forKey: "HomeLng")
                        UserDefaults.standard.set(golfName, forKey: "HomeCourseName")
                        UserDefaults.standard.synchronize()
                    }
                })
            }
        }
    }
    
    // MARK: searchGolfLocation
    func searchGolfLocation(searchText: String){
        let serverHandler = ServerHandler()
        serverHandler.state = 1
        
        let urlStr = "getData.php?"
        let dataStr =  "text=\(searchText)"
        
        self.progressView.show()

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = self.leftModeView.bounds
        self.leftModeView.layer.addSublayer(gradient)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.leftModeView.frame
        rectShape.position = self.leftModeView.center
        rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
        self.leftModeView.layer.mask = rectShape
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            
            if (arg0 == nil) && (error != nil){
                DispatchQueue.main.async(execute: {
                    self.progressView.hide()
                    self.tblViewHConstraint.constant = 0
                    self.nearMeContainerView.isHidden = false
                })
            }
            else{
                self.searchDataArr =  [NSMutableDictionary]()
                
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
                    dataDic.setObject($0.value.Mapped, forKey : "Mapped" as NSCopying)
                    
                    self.searchDataArr.append(dataDic)
                    group.leave()
                    
                    group.notify(queue: .main) {
                        
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.progressView.hide()

                    if !self.searchDataArr.isEmpty{
                        self.tblViewHConstraint.constant = self.view.frame.size.height - (self.searchContainerSV.frame.origin.y + self.searchContainerView.frame.size.height + self.bottomStackSV.frame.size.height + 20 + 30)
                        self.view.layoutIfNeeded()
                        
                        self.nearMeContainerView.isHidden = true
                        
                        self.courseTblView.delegate = self
                        self.courseTblView.dataSource = self
                        self.courseTblView.reloadData()
                    }
                })
            }
        }
    }
    
    
    // MARK: btnCheckBoxAction
    @IBAction func btnCheckBoxAction(_ sender: Any) {
        if(self.btnCheckbox.isSelected){
            self.btnCheckbox.isSelected = false
            self.btnCheckbox.setBackgroundImage(nil, for: .normal)
            self.btnCheckbox.setCorner(color: UIColor.white.cgColor)
//            self.sliderHandicapNumber.isEnabled = true
            self.lblHandicap.text = "Handicap \((self.sliderHandicapNumber.value*10).rounded()/10)"//(value as! NSString).floatValue
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\((self.sliderHandicapNumber.value*10).rounded()/10)"] as [AnyHashable:Any])
        }
        else{
            self.btnCheckbox.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
            self.btnCheckbox.imageView?.sizeToFit()
            self.btnCheckbox.isSelected = true
            self.btnCheckbox.setCorner(color: UIColor.white.cgColor)
//            self.sliderHandicapNumber.isEnabled = false
            
            self.lblHandicap.text = "-"
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"-"] as [AnyHashable:Any])
        }
    }
    
    // MARK: sliderChangedAction
    @IBAction func sliderChangedAction(_ sender: Any) {
        self.lblHandicap.text = "\(Int(self.sliderHandicapNumber.value))"
        
        self.btnCheckbox.isSelected = false
        self.btnCheckbox.setBackgroundImage(nil, for: .normal)
        self.btnCheckbox.setCorner(color: UIColor.white.cgColor)

        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handicap":"\(Int(self.sliderHandicapNumber.value))"] as [AnyHashable:Any])
    }
    
    // MARK: handiChangedAction
    @IBAction func handiChangedAction(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Left"] as [AnyHashable:Any])
            btnHandiLeft.setImage(#imageLiteral(resourceName: "handiLeftDark"), for: .normal)
            btnHandiRight.setImage(#imageLiteral(resourceName: "handiRIghtLight"), for: .normal)
            lblHandiLeft.textColor = UIColor.black
            lblHandiRight.textColor = UIColor(rgb: 0x133022)
            
        case 1:
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":"Right"] as [AnyHashable:Any])
            btnHandiRight.setImage(#imageLiteral(resourceName: "handiRIghtDark"), for: .normal)
            btnHandiLeft.setImage(#imageLiteral(resourceName: "handiLeftLight"), for: .normal)
            lblHandiLeft.textColor = UIColor(rgb: 0x133022)
            lblHandiRight.textColor = UIColor.black
            
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
        
        self.progressView.show()
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
                    self.progressView.hide()

                    let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
                    if !self.dataArr.isEmpty{
                        viewCtrl.searchDataArr = self.dataArr
                    }
                    
                    self.navigationController?.pushViewController(viewCtrl, animated: true)
                })
            }
        }
    }
    
    // MARK: skipAction
    @IBAction func skipAction(_ sender: UIButton) {

        currentPageIndex = self.pageControl.currentPage + 1
        pageControl.currentPage += 1
        
        let x = CGFloat(pageControl.currentPage) * (newProfileScrlView.frame.size.width)
        newProfileScrlView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        btnNext.setTitle(" " + "Next".localized() + " ", for: .normal)
        if currentPageIndex == 2 {
            btnNext.setTitle("Done", for: .normal)
        }
        if currentPageIndex == 3{
            currentPageIndex = 0
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
    }
    
    // MARK: nextAction
    @IBAction func nextAction(_ sender: UIButton) {
        
        currentPageIndex = self.pageControl.currentPage + 1
        pageControl.currentPage += 1
        
        let x = CGFloat(pageControl.currentPage) * (newProfileScrlView.frame.size.width)
        newProfileScrlView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        btnNext.setTitle(" " + "Next".localized() + " ", for: .normal)
        if currentPageIndex == 2 {
            btnNext.setTitle("Done", for: .normal)
        }
        if currentPageIndex == 3{
            currentPageIndex = 0
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
    }
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1{
            if sectionNames.count > 0 {
                tableView.backgroundView = nil
                return sectionNames.count
            } else {
                let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                messageLabel.text = "Retrieving data.\nPlease wait."
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
                messageLabel.sizeToFit()
                self.golfBagTblView.backgroundView = messageLabel;
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1{
            if (self.expandedSectionHeaderNumber == section) {
                let arrayOfItems = self.sectionItems[section] as! NSArray
                //            return arrayOfItems.count
                return 1
            }
        }
        else{
            if searchDataArr.count>0{
                return searchDataArr.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1{
            return 44.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1{
            
            let selectedItemCount = self.sectionItems[section] as! NSArray
            
            let header = UIView()
            header.backgroundColor = UIColor.white
            
            let label = UILabel()
            label.frame = CGRect(x: 10, y: 13, width: 80, height: 15)
            label.text = self.sectionNames[section] as? String
            label.textColor = UIColor(rgb: 0x133022)
            label.sizeToFit()
            header.addSubview(label)
            
            let countLbl = UILabel(frame: CGRect(x: (label.frame.origin.x + label.frame.size.width + 10), y: 13, width: 30, height: 18))
            countLbl.text = "-"
            
            let golfBagArray = NSMutableArray()
            for i in 0..<selectedClubs.count{
                let dict = selectedClubs[i] as! NSDictionary
                golfBagArray.add(dict.value(forKey: "clubName") as! String)
            }
            let tempArr = NSMutableArray()
            for i in 0..<selectedItemCount.count{
                if golfBagArray.contains(selectedItemCount[i]){
                    tempArr.add(selectedItemCount[i])
                    countLbl.text = "\(tempArr.count)"
                }
            }
            countLbl.textColor = UIColor(rgb: 0x133022)
            countLbl.textAlignment = .center
            countLbl.layer.borderWidth = 1.0
            countLbl.layer.borderColor = UIColor.glfLightGreyBlue.cgColor
            countLbl.layer.cornerRadius = 9
            countLbl.layer.masksToBounds = true
            header.addSubview(countLbl)
            
            if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                viewWithTag.removeFromSuperview()
            }
            let headerFrame = self.golfBagTblView.frame.size
            
            let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
            theImageView.image = UIImage(named: "Chevron-Dn-Wht")
            theImageView.tag = kHeaderSectionTag + section
            header.addSubview(theImageView)
            
            header.tag = section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
            header.addGestureRecognizer(headerTapGesture)
            
            return header
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if tableView.tag == 1{
            if indexPath.section == 1 || indexPath.section == 3 {
                return 90
            }
            return 50
        }
        else
        {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as UITableViewCell
            let section = self.sectionItems[indexPath.section] as! NSArray
            
            for subV in cell.contentView.subviews{
                subV.removeFromSuperview()
            }
            let golfBagContainerView = UIView(frame: CGRect(x: 10, y: 0, width: self.golfBagTblView.frame.size.width - 20, height: cell.frame.size.height))
            
            let numOfCoulmn = 5
            let btnWidth = 40.0
            let btnHeight = 30.0
            var xOffset = 0.0
            var yOffset = 10.0
            var incr = 0
            let horzSpace = (golfBagContainerView.frame.size.width - CGFloat(btnWidth * Double(numOfCoulmn))) / CGFloat(numOfCoulmn-1)
            let bottomSpace = 10.0
            for i in 0..<section.count{
                if CGFloat(xOffset + btnWidth) > golfBagContainerView.frame.size.width{
                    yOffset += btnHeight + bottomSpace
                    xOffset = 0.0
                    incr = 0
                }
                let btns = UIButton()
                btns.frame = CGRect(x: xOffset, y: yOffset, width: btnWidth, height: btnHeight)
                btns.setCornerWithRadius(color: UIColor.glfLightGreyBlue.cgColor, radius: 15.0)
                btns.setTitle(section[i] as? String, for: .normal)
                btns.setTitleColor(UIColor.red, for: .normal)
                btns.imageView?.sizeToFit()
                debugPrint(btns.tag)
                btns.addTarget(self, action: #selector(clubButtonTapped), for: .touchUpInside)
                golfBagContainerView.addSubview(btns)
                
                incr = incr + 1
                xOffset = Double(CGFloat(incr) * (CGFloat(btnWidth) + horzSpace))
                
                let golfBagArray = NSMutableArray()
                for i in 0..<selectedClubs.count{
                    let dict = selectedClubs[i] as! NSDictionary
                    golfBagArray.add(dict.value(forKey: "clubName") as! String)
                }
                if golfBagArray.contains(section[i]){
                    btns.isSelected = true
                    btns.backgroundColor = UIColor.glfFlatBlue
                    btns.setTitleColor(UIColor.white, for: .normal)
                }
                else{
                    btns.isSelected = false
                    btns.backgroundColor = UIColor.white
                    btns.setTitleColor(UIColor.glfLightGreyBlue, for: .normal)
                }
            }
            cell.contentView.addSubview(golfBagContainerView)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationTableViewCell", for: indexPath as IndexPath) as! SearchLocationTableViewCell
            
            cell.lblTitle.text = (searchDataArr[indexPath.row] as AnyObject).value(forKey: "Name") as? String
            cell.lblSubTitle.text = "\((searchDataArr[indexPath.row] as AnyObject).value(forKey: "City") as? String ?? ""),\((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Country") as? String ?? "")"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            let golfID = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Id") as? String)!
            let golfName = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Name") as? String)!
            let golfLat = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Latitude") as? String)!
            let golfLong = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Longitude") as? String)!
            let golfMapped = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Mapped") as? String)!
            
            if golfMapped == "0"{
                let gradient = CAGradientLayer()
                gradient.colors = [UIColor(rgb: 0xD4D4D4).cgColor, UIColor(rgb: 0xBEBEBE).cgColor]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradient.frame = self.leftModeView.bounds
                self.leftModeView.layer.addSublayer(gradient)
            }
            else if golfMapped == "1"{
                let gradient = CAGradientLayer()
                gradient.colors = [UIColor(rgb: 0x2D6194).cgColor, UIColor(rgb: 0x2D4393).cgColor]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradient.frame = self.leftModeView.bounds
                self.leftModeView.layer.addSublayer(gradient)
            }
            else{
                let gradient = CAGradientLayer()
                gradient.colors = [UIColor(rgb: 0xF2A134).cgColor, UIColor(rgb: 0xF8CE49).cgColor]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradient.frame = self.leftModeView.bounds
                self.leftModeView.layer.addSublayer(gradient)
            }
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.leftModeView.frame
            rectShape.position = self.leftModeView.center
            rectShape.path = UIBezierPath(roundedRect: self.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
            self.leftModeView.layer.backgroundColor = UIColor.white.cgColor
            self.leftModeView.layer.mask = rectShape
            
            self.searchTxtField.text = golfName
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["homeCourse":NSNull()])
            
            let homeCourseDic = NSMutableDictionary()
            homeCourseDic.setObject(golfID, forKey: "id" as NSCopying)
            homeCourseDic.setObject(golfLat, forKey: "lat" as NSCopying)
            homeCourseDic.setObject(golfLong, forKey: "lng" as NSCopying)
            homeCourseDic.setObject(golfName, forKey: "name" as NSCopying)
            let homeCourseDetails = ["homeCourseDetails":homeCourseDic]
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(homeCourseDetails)
            
            UserDefaults.standard.set(golfLat, forKey: "HomeLat")
            UserDefaults.standard.set(golfLong, forKey: "HomeLng")
            UserDefaults.standard.set(golfName, forKey: "HomeCourseName")
            UserDefaults.standard.synchronize()
            
            searchTxtField.resignFirstResponder()
            
            tblViewHConstraint.constant = 0
            nearMeContainerView.isHidden = false
        }
    }
    
    // MARK: clubButtonTapped
    @objc func clubButtonTapped(_ sender: UIButton!) {
        if(sender.isSelected){
            for i in 0..<selectedClubs.count{
                let dict = selectedClubs[i] as! NSDictionary
                if (dict.value(forKey: "clubName") as? String == sender.titleLabel?.text){
                    
                    selectedClubs.removeObject(at: i)
                    let golfBagData = ["golfBag": selectedClubs]
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                    
                    sender.isSelected = false
                    sender.backgroundColor = UIColor.white
                    sender.setTitleColor(UIColor.glfLightGreyBlue, for: .normal)
                    break
                }
            }
        }
        else{
            let tempBagArray = NSMutableArray()
            for i in 0..<selectedClubs.count{
                let dict = selectedClubs[i] as! NSDictionary
                tempBagArray.add(dict.value(forKey: "clubName") as! String)
            }
            if !(tempBagArray.contains(sender.titleLabel!.text!)){
                
                let golfBagDict = NSMutableDictionary()
                golfBagDict.setObject("", forKey: "brand" as NSCopying)
                golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                golfBagDict.setObject(sender.titleLabel!.text!, forKey: "clubName" as NSCopying)
                golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                golfBagDict.setObject(0, forKey: "tagNum" as NSCopying)
                
                selectedClubs.insert(golfBagDict, at: 0)
                let golfBagData = ["golfBag": selectedClubs]
                
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                
                sender.isSelected = true
                sender.backgroundColor = UIColor.glfFlatBlue
                sender.setTitleColor(UIColor.white, for: .normal)
            }
        }
        self.golfBagTblView.reloadData()
    }
    
    // MARK: - Expand / Collapse Methods
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view
        let section    = headerView?.tag
        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section!
            tableViewExpandSection(section!, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section!, imageView: eImageView!)
            }
            else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section!, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            let index = IndexPath(row: 0, section: section)
            indexesPath.append(index)
            
            self.golfBagTblView!.beginUpdates()
            self.golfBagTblView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.golfBagTblView!.endUpdates()
            golfTblHConstraint.constant = (6 * 44)
            if UIDevice.current.iPad{
                golfTblHConstraint.constant = (4.5 * 44)
            }
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            let index = IndexPath(row: 0, section: section)
            indexesPath.append(index)
            
            self.expandedSectionHeaderNumber = section
            self.golfBagTblView!.beginUpdates()
            self.golfBagTblView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.golfBagTblView!.endUpdates()
            
            golfTblHConstraint.constant = (6 * 44) + 50
            if section == 1 || section == 3 {
                golfTblHConstraint.constant = (6 * 44) + 90
            }
            
            if UIDevice.current.iPhone5 {
                golfTblHConstraint.constant = (6 * 44) + 35
            }
            else if UIDevice.current.iPad{
                golfTblHConstraint.constant = (4.5 * 44)
            }
        }
    }
}
