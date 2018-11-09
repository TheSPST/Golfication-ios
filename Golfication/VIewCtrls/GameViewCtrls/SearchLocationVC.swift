//
//  SearchLocationVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 27/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth

class SearchLocationVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    var searchDataArr = [NSMutableDictionary]()
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var golfSearchBar: UISearchBar!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var viewAddCourse: UIView!
    @IBOutlet weak var scrlViewAddCourse: UIScrollView!
    @IBOutlet weak var viewThankYouPopUp: CardView!
    @IBOutlet weak var btnSubmitCourse: UIButton!
    @IBOutlet weak var btnThankYouDone: UIButton!
    @IBOutlet weak var courseTxtField: UITextField!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    
    var locationManager = CLLocationManager()
    
    var fromNewGame = Bool()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if !(searchBar.text == "") {
            self.searchGolfLocation(searchText: searchBar.text!)
        }
        else{
            searchTableView.isHidden = true
        }
    }
    
    @IBAction func submitCourseAction(_ sender: Any) {
        
        if courseTxtField.text == ""{
            let alert = UIAlertController(title: "Alert", message: "Please enter course name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if countryTxtField.text == ""{
            let alert = UIAlertController(title: "Alert", message: "Please enter country.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if cityTxtField.text == ""{
            let alert = UIAlertController(title: "Alert", message: "Please enter city.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            sendCourseDetailToFirebase()
        }
    }
    
    func sendCourseDetailToFirebase() {
        
        let courseDetailDic = NSMutableDictionary()
        let courseDic = NSMutableDictionary()
        let courseId = ref!.child("courseAdditions").childByAutoId().key
        courseDic.setObject(cityTxtField.text!, forKey: "city" as NSCopying)
        courseDic.setObject(countryTxtField.text!, forKey: "country" as NSCopying)
        courseDic.setObject(courseTxtField.text!, forKey: "courseName" as NSCopying)
        courseDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        courseDic.setObject(Auth.auth().currentUser!.uid, forKey: "userKey" as NSCopying)
        courseDic.setObject(Auth.auth().currentUser!.displayName!, forKey: "userName" as NSCopying)
        courseDetailDic.setObject(courseDic, forKey: courseId as NSCopying)
        ref.child("courseAdditions").updateChildValues(courseDetailDic as! [AnyHashable : Any])

        viewAddCourse.isHidden = false
        scrlViewAddCourse.isHidden = true
        viewThankYouPopUp.isHidden = false
        courseTxtField.text = ""
        countryTxtField.text = ""
        cityTxtField.text = ""
        courseTxtField.resignFirstResponder()
        countryTxtField.resignFirstResponder()
        cityTxtField.resignFirstResponder()
    }
    
    @IBAction func thankYouDoneAction(_ sender: Any) {
        viewAddCourse.isHidden = true
        courseTxtField.text = ""
        countryTxtField.text = ""
        cityTxtField.text = ""
    }
    
    @IBAction func dismissCourseAction(_ sender: Any) {
        viewAddCourse.isHidden = true
    }
    
    @IBAction func addCourseAction(_ sender: Any) {
        viewAddCourse.isHidden = false
        scrlViewAddCourse.isHidden = false
        viewThankYouPopUp.isHidden = true
    }
    
    @IBAction func nearByCourseAction(_ sender: Any) {
        
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            let alert = UIAlertController(title: "Alert", message: "Please enable GPS to get your near by courses.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let currentLocation: CLLocation = locationManager.location!
            self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        if playButton != nil{
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search Course"
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        
        golfSearchBar.layer.cornerRadius = 5.0
        golfSearchBar.clipsToBounds = true
        
        let originalImage = #imageLiteral(resourceName: "backArrow")
        let backImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnBack.setBackgroundImage(backImage, for: .normal)
        btnBack.tintColor = UIColor.glfBluegreen
        
        viewAddCourse.isHidden = true
        btnSubmitCourse.layer.cornerRadius = 3.0
        btnThankYouDone.layer.cornerRadius = 3.0
        
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        else{
            let currentLocation: CLLocation = locationManager.location!
            self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
        }
    }
    
    // MARK: getNearByData
    func getNearByData(latitude: Double, longitude: Double, currentLocation: CLLocation){
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    // In case of -1 response
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                    self.searchTableView.isHidden = true
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
                    if($0.key != "99999999"){
                        self.searchDataArr.append(dataDic)
                    }
                    group.leave()
                    group.notify(queue: .main) {
                        
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                    if !self.searchDataArr.isEmpty{
                        self.searchDataArr = BackgroundMapStats.sortAndShow(searchDataArr:self.searchDataArr, myLocation: currentLocation)
                        self.searchTableView.isHidden = false
                        self.searchTableView.reloadData()
                    }
                })
            }
        }
    }

    func searchGolfLocation(searchText: String){
        
        let serverHandler = ServerHandler()
        serverHandler.state = 1
        
        let urlStr = "getData.php?"
        let dataStr =  "text=\(searchText)"
        
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                    self.searchTableView.isHidden = true
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
                    if($0.key != "99999999"){
                        self.searchDataArr.append(dataDic)
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.actvtIndView.isHidden = true
                    self.actvtIndView.stopAnimating()
                    
                    if !self.searchDataArr.isEmpty{
                        self.searchTableView.isHidden = false
                        self.searchTableView.reloadData()
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchDataArr.count>0{
            return searchDataArr.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationTableViewCell", for: indexPath as IndexPath) as! SearchLocationTableViewCell
        if !searchDataArr.isEmpty{
        cell.lblTitle.text = (searchDataArr[indexPath.row] as AnyObject).value(forKey: "Name") as? String
        cell.lblSubTitle.text = "\((searchDataArr[indexPath.row] as AnyObject).value(forKey: "City") as? String ?? ""),\((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Country") as? String ?? "")"
        
        let mappedStatus = (searchDataArr[indexPath.row] as AnyObject).value(forKey: "Mapped") as? String
        cell.lblMapped.textColor = UIColor.lightGray
        
        //        cell.btnMapped.layer.cornerRadius = 3.0
        if mappedStatus == "0"{
            cell.lblMapped.text = "Only Scoring"
            cell.classicImageView.isHidden = false
            cell.rfImageView.isHidden = true
            cell.advanceImageView.isHidden = true
            
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor(rgb: 0xD4D4D4).cgColor, UIColor(rgb: 0xBEBEBE).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.frame = cell.leftModeView.bounds
            cell.leftModeView.layer.addSublayer(gradient)
            
        }
        else if mappedStatus == "1"{
            cell.lblMapped.text = "Only rangefinder and scoring"
            cell.classicImageView.isHidden = false
            cell.rfImageView.isHidden = false
            cell.advanceImageView.isHidden = true
            
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor(rgb: 0x2D6194).cgColor, UIColor(rgb: 0x2D4393).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.frame = cell.leftModeView.bounds
            cell.leftModeView.layer.addSublayer(gradient)
            
        }
        else{
            cell.lblMapped.text = "Supports all features"
            cell.classicImageView.isHidden = false
            cell.rfImageView.isHidden = false
            cell.advanceImageView.isHidden = false
            
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor(rgb: 0xF2A134).cgColor, UIColor(rgb: 0xF8CE49).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.frame = cell.leftModeView.bounds
            cell.leftModeView.layer.addSublayer(gradient)
        }
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = cell.leftModeView.frame
        rectShape.position = cell.leftModeView.center
        rectShape.path = UIBezierPath(roundedRect: cell.leftModeView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        cell.leftModeView.layer.backgroundColor = UIColor.green.cgColor
        cell.leftModeView.layer.mask = rectShape
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Constants.selectedGolfID = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Id") as? String)!
        Constants.selectedGolfName = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Name") as? String)!
        Constants.selectedLat = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Latitude") as? String)!
        Constants.selectedLong = ((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Longitude") as? String)!
        
        if !fromNewGame{
            fromNewGame = false
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["homeCourse":NSNull()])
            let homeCourseDic = NSMutableDictionary()
            homeCourseDic.setObject(Constants.selectedGolfID, forKey: "id" as NSCopying)
            homeCourseDic.setObject(Constants.selectedLat, forKey: "lat" as NSCopying)
            homeCourseDic.setObject(Constants.selectedLong, forKey: "lng" as NSCopying)
            homeCourseDic.setObject(Constants.selectedGolfName, forKey: "name" as NSCopying)
            if(Constants.selectedGolfID == "14513"){
                homeCourseDic.setObject("2", forKey: "mapped" as NSCopying)
            }else{
                homeCourseDic.setObject((searchDataArr[indexPath.row] as AnyObject).value(forKey: "Mapped") as! String, forKey: "mapped" as NSCopying)
            }
            
            let homeCourseDetails = ["homeCourseDetails":homeCourseDic]
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(homeCourseDetails)
            
            UserDefaults.standard.set(Constants.selectedLat, forKey: "HomeLat")
            UserDefaults.standard.set(Constants.selectedLong, forKey: "HomeLng")
            UserDefaults.standard.set(Constants.selectedGolfName, forKey: "HomeCourseName")
            UserDefaults.standard.synchronize()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
