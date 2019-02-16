//
//  SettingVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SettingVC: UITableViewController {
    
    var sectionOne:[Int] = [0, 1]
    var sectionTwo:[Int] = [0, 1, 2, 3, 4]
    var sectionThree:[Int] = [0, 1]
    
    var progressView = SDLoader()
    @IBOutlet weak var versionLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Settings".localized()
        self.navigationItem.rightBarButtonItem?.title = "Logout".localized()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.checkVersion()
        self.checkFilterValuesFromFirebase()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.hide()
    }
    func checkVersion(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "info") { (snapshot) in
            if(snapshot.childrenCount > 0){
                if let dic = snapshot.value as? NSDictionary{
                    if let appVersion = dic["appVersion"] as? String{
                        self.versionLbl.text = "Version".localized() + " " + "\(appVersion.dropLast(8))"
                    }
                }
            }
            else{
                self.versionLbl.text = ""
            }
        }
    }
    
    func checkFilterValuesFromFirebase(){
        self.progressView.show()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "unit") { (snapshot) in
            if snapshot.exists(){
                if let index = snapshot.value as? Int{
                    Constants.distanceFilter = index
                }
            }
            else{
                Constants.distanceFilter = 0
            }
            DispatchQueue.main.async( execute: {
                FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "strokesGained") { (snapshot) in
                    
                    if snapshot.exists(){
                        if let index = snapshot.value as? Int{
                            Constants.skrokesGainedFilter = index
                        }
                    }
                    else{
                        Constants.skrokesGainedFilter = 0
                    }
                    DispatchQueue.main.async( execute: {
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "notification") { (snapshot) in
                            if snapshot.exists(){
                                if let index = snapshot.value as? Int{
                                    Constants.onCourseNotification = index
                                }
                            }
                            else{
                                Constants.onCourseNotification = 0
                            }
                            DispatchQueue.main.async( execute: {
                                self.progressView.hide()
                                self.navigationItem.rightBarButtonItem?.isEnabled = true
                                
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                
                            })
                        }
                    })
                }
            })
        }
    }
    
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: btnLogoutAction
    @IBAction func btnLogoutAction(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to Logout.".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { [weak alert] (_) in
            // Do Nothing
            debugPrint("Cancel Alert: \(alert?.title ?? "")")
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            //("Ok Alert: \(alert?.title ?? "")")
            debugPrint("ok :\(alert?.title ?? "")")
            
            if Auth.auth().currentUser != nil{
                //print("fb display name== ",Auth.auth().currentUser?.displayName ?? "")
                Constants.isDevice = Bool()
                Constants.isProMode = Bool()
                Constants.section5 = [String]()
                Constants.selectedGolfID = ""
                Constants.selectedGolfName = ""
                //profileGolfName = ""
                Constants.selectedLat = ""
                Constants.selectedLong = ""
                Constants.matchDataDic = NSMutableDictionary()
                Constants.gameType = ""
                Constants.startingHole = ""
                Constants.matchId = ""
                Constants.skrokesGainedFilter = 0
                Constants.distanceFilter = 0
                Constants.onCourseNotification = 0
                Constants.deviceGolficationX = nil
                Constants.ble = nil
                
                Constants.deviceGameType = 0
                Constants.tempGolfBagArray = NSMutableArray()
                Constants.isTagSetupModified = false
                Constants.baselineDict =  nil
                Constants.strokesGainedDict = [NSMutableDictionary]()
                Constants.isUpdateInfo = false
                Constants.isProfileUpdated = false
                Constants.clubWithMaxMin = [(name:String,max:Int,min:Int)]()
                Constants.firmwareVersion = nil
                Constants.oldFirmwareVersion = nil
                Constants.canSkip = nil
                Constants.gender = ""
                Constants.handed = ""
                Constants.handicap = ""
                Constants.trial = false
                Constants.tagClubNumber = [(tag:Int ,club:Int,clubName:String)]()
                Constants.syncdArray = NSMutableArray()
                Constants.tagClubNum = [(tag:Int, club: Int, clubName: String)]()
                Constants.back9 = false
                Constants.macAddress = nil
                Constants.ResponseData = nil
                Constants.charctersticsGlobalForWrite = nil
                Constants.charctersticsGlobalForRead = nil
                Constants.allMacAdrsDic = NSMutableDictionary()
                Constants.OADFeedback = false
                Constants.bleObserver = 0
                Constants.fileName = String()
                Constants.swingSessionKey = String()
                Constants.fromStatsPost = false
                Constants.benchmark_Key = String()
                self.signOutCurrentUser()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func signOutCurrentUser() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        FBSDKLoginManager().logOut()
        let firebaseAuth = Auth.auth()
        do {
            //try! Auth.auth().signOut()
            try firebaseAuth.signOut()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            var navCtrl = self.navigationController!
            self.progressView.hide()
            let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthParentVC") as! AuthParentVC
            navCtrl = UINavigationController(rootViewController: viewCtrl)
            self.present(navCtrl, animated: false, completion: nil)
        }
            
        catch let signOutError as NSError {
            
            let alert = UIAlertController(title: "Alert", message: signOutError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Distance".localized()
        }
        else if section == 1{
            return "Strokes Gained".localized()
        }
        else{
            return "Rangefinder Distance Notification"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        if indexPath.section == 0{
            if Constants.distanceFilter == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else
            {
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
            case 0: cell.textLabel?.text = "Imperial (feet,yards,miles)".localized()
            case 1: cell.textLabel?.text = "Metric(metres,kilometres)".localized()
            
            default: break
            }
        }
        else if indexPath.section == 1{
            if Constants.skrokesGainedFilter == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }
            else
            {
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
            case 0: cell.textLabel?.text = "PGA Tour".localized()
            case 1: cell.textLabel?.text = "Men's - Scratch".localized()
            case 2: cell.textLabel?.text = "Men's - 18 Handicap".localized()
            case 3: cell.textLabel?.text = "Women's - Scratch".localized()
            case 4: cell.textLabel?.text = "Women's - 18 Handicap".localized()
            default: break
            }
        }else{
            if Constants.onCourseNotification == indexPath.row{
                cell.isSelected = true
                cell.tintColor = UIColor.glfGreen
                cell.accessoryType = cell.isSelected ? .checkmark : .checkmark
            }else{
                cell.isSelected = false
                cell.tintColor = UIColor.clear
                cell.accessoryType = cell.isSelected ? .none : .none
            }
            switch indexPath.row{
                case 0: cell.textLabel?.text = "Off - Less battery consumption"
                case 1: cell.textLabel?.text = "On - More battery consumption"
            default: break
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)!
        cell.tintColor = UIColor.glfGreen

        if indexPath.section == 0{
            if !sectionOne.isEmpty{
                for i in 0..<sectionOne.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionOne.count{
                    if sectionOne[i] == indexPath.row{
                        tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.distanceFilter = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["unit" :Constants.distanceFilter] as [AnyHashable:Any])
        }
        else if indexPath.section == 1{
            if !sectionTwo.isEmpty{
                for i in 0..<sectionTwo.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionTwo.count{
                    if sectionTwo[i] == indexPath.row{
                        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.skrokesGainedFilter = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["strokesGained" :Constants.skrokesGainedFilter] as [AnyHashable:Any])
        }else{
            if !sectionThree.isEmpty{
                for i in 0..<sectionThree.count{
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
                for i in 0..<sectionThree.count{
                    if sectionThree[i] == indexPath.row{
                        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        break
                    }
                }
            }
            Constants.onCourseNotification = indexPath.row
            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["notification" :Constants.onCourseNotification] as [AnyHashable:Any])
        }
    }
}
