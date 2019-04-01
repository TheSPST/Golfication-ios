//
//  GoalsVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 18/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class GoalsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var progressView = SDLoader()

    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    let kHeaderSectionTag: Int = 6900

    var golfBagArray = NSMutableArray()
    var clubMArray = NSMutableArray()
    var swingGoalsDic = NSMutableDictionary()
    var goalsDic = NSMutableDictionary()
    var barBtnBLE: UIBarButtonItem!

    var titleStr = String()
    // MARK: backAction
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleStr
        if titleStr.containsIgnoringCase(find: "Swing Goals"){
            FBSomeEvents.shared.singleParamFBEvene(param: "View Swing Goals")
        }else{
            FBSomeEvents.shared.singleParamFBEvene(param: "View Goals")
        }
        
        let originalImage = #imageLiteral(resourceName: "icon_info_grey")
        let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

//        if titleStr != "Scoring Goals"{
            barBtnBLE = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.headerInfoClicked))
            barBtnBLE.image = infoBtnImage
            barBtnBLE.tintColor = UIColor.glfFlatBlue
            self.navigationItem.rightBarButtonItem = barBtnBLE
        //}
        let clubTempArr = NSMutableArray()
        clubTempArr.add("Swing Tempo")
        clubTempArr.add("Back Swing")
        clubTempArr.add("Driver")
        clubTempArr.add("Woods")
        clubTempArr.add("Hybrids")
        clubTempArr.add("Irons")
        clubTempArr.add("Wedges")

        /*for j in 0..<Constants.allClubs.count{
            for i in 0..<golfBagArray.count{
                let dic = golfBagArray[i] as! NSMutableDictionary
                if let clubName  = (dic.value(forKey: "clubName") as? String){
                    if Constants.allClubs[j] == clubName{
                        if clubName != "Pu"{
                            clubTempArr.add(clubName)
                        }
                    }
                }
            }
        }*/
        self.getBenchMark(clubTempArr:clubTempArr)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0)
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0

        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.checkFilterValuesFromFirebase()
    }
    
    @objc func headerInfoClicked(_ sender: UIBarButtonItem){
        if titleStr == "Scoring Goals"{
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = "Scoring Goals"
            viewCtrl.desc = StatsIntoConstants.swingGoals
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else{
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = "Clubhead Speed"
            viewCtrl.desc = StatsIntoConstants.clubheadSpeed
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    func getBenchMark(clubTempArr:NSMutableArray){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "benchmarks/" + Constants.benchmark_Key) { (snapshot) in
            let benchMarkVal = snapshot.value as! NSMutableDictionary
            
            DispatchQueue.main.async(execute: {
                self.clubMArray = NSMutableArray()
                for i in 0..<clubTempArr.count{
                    let clubMDic = NSMutableDictionary()
                    let clubName = clubTempArr[i] as! String
                    if clubName == "Swing Tempo"{
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        clubMDic.setObject(1, forKey: "minVal" as NSCopying)
                        clubMDic.setObject(6, forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(3, forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Back Swing"{
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        clubMDic.setObject(90, forKey: "minVal" as NSCopying)
                        clubMDic.setObject(300, forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(195, forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Driver"{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "Dr") as! String)!
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Woods"{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "3w") as! String)!
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Hybrids"{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "1h") as! String)!
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Irons"{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "1i") as! String)!
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    else if clubName == "Wedges"{
                        let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "Pw") as! String)!
                        clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                        let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                        let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                        clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                        clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                        clubMDic.setObject(Int(clubSpeedTemp*0.9), forKey: "defaultVal" as NSCopying)
                    }
                    self.clubMArray.add(clubMDic)
                }
                self.getSwingGoalsData(benchMarkVal:benchMarkVal)
            })
        }
    }
    func getSwingGoalsData(benchMarkVal:NSMutableDictionary){
        swingGoalsDic = NSMutableDictionary()

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingGoals") { (snapshot) in
            if snapshot.value != nil{
                self.clubMArray = NSMutableArray()
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.swingGoalsDic = goalsDic
                    
                    let clubTempArr = NSMutableArray()
                    for (key,val) in goalsDic{
                        let clubMDic = NSMutableDictionary()
                        let clubName = key as! String
                        
                        if clubName == "tempo"{
                            clubMDic.setObject("Swing Tempo", forKey: "clubName" as NSCopying)
                            clubMDic.setObject(1, forKey: "minVal" as NSCopying)
                            clubMDic.setObject(6, forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "backSwing"{
                            clubMDic.setObject("Back Swing", forKey: "clubName" as NSCopying)
                            clubMDic.setObject(90, forKey: "minVal" as NSCopying)
                            clubMDic.setObject(300, forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "driver"{
                            let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "Dr") as! String)!
                            clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                            let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                            let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                            clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                            clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "wood"{
                            let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "3w") as! String)!
                            clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                            let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                            let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                            clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                            clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "hybrid"{
                            let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "1h") as! String)!
                            clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                            let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                            let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                            clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                            clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "iron"{
                            let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "1i") as! String)!
                            clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                            let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                            let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                            clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                            clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }
                        else if clubName == "wedge"{
                            let clubSpeedTemp:Double = Double(benchMarkVal.value(forKey: "Pw") as! String)!
                            clubMDic.setObject(clubName, forKey: "clubName" as NSCopying)
                            let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                            let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                            clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                            clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                            clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                        }

                        /*else{
                            if let clubTemp = benchMarkVal.value(forKey: clubName) as? String{
                                let clubSpeedTemp:Double = Double(clubTemp)!
                                let min = clubSpeedTemp*0.9 - (clubSpeedTemp*0.9)/2.0
                                let max = clubSpeedTemp*0.9 + (clubSpeedTemp*0.9)/2.0
                                
                                clubMDic.setObject(self.getFullClubName(clubName:clubName), forKey: "clubName" as NSCopying)
                                clubMDic.setObject(Int(min), forKey: "minVal" as NSCopying)
                                clubMDic.setObject(Int(max), forKey: "maxVal" as NSCopying)
                                clubMDic.setObject(val, forKey: "defaultVal" as NSCopying)
                            }
                        }*/
                        clubTempArr.add(clubMDic)
//                        self.clubMArray.add(clubMDic)
                    }
                    
                    for i in 0..<clubTempArr.count{
                        let dic = clubTempArr[i] as! NSMutableDictionary
                        if (dic.value(forKey: "clubName") as! String) == "Swing Tempo"{
                            self.clubMArray.add(dic)
                            break
                        }
                    }
                    for i in 0..<clubTempArr.count{
                        let dic = clubTempArr[i] as! NSMutableDictionary
                        if (dic.value(forKey: "clubName") as! String) == "Back Swing"{
                            self.clubMArray.add(dic)
                            break
                        }
                    }
                    for j in 0..<Constants.allClubs.count{
                        for i in 0..<clubTempArr.count{
                            let dic = clubTempArr[i] as! NSMutableDictionary
                            let clubName = dic.value(forKey: "clubName") as! String
                            var shortName = String()
                            if clubName == "driver"{
                                shortName = "Dr"
                            }
                            else if clubName == "wood"{
                                shortName = "3w"
                            }
                            else if clubName == "hybrid"{
                                shortName = "1h"
                            }
                            else if clubName == "iron"{
                                shortName = "1i"
                            }
                            else if clubName == "wedge"{
                                shortName = "Pw"
                            }
                            if Constants.allClubs[j] == shortName{
                                self.clubMArray.add(dic)
                            }
                        }
                    }
                    debugPrint("clubMArray",self.clubMArray)
                }
            }
            else{
                debugPrint("clubMArray",self.clubMArray)
                let swingDict = NSMutableDictionary()
                for i in 0..<self.clubMArray.count{
                    let dic = self.clubMArray[i] as! NSMutableDictionary
                    if (dic.value(forKey: "clubName") as! String) == "Swing Tempo"{
                        let defaultVal =  dic.value(forKey: "defaultVal") as! Int
                        swingDict.setObject(defaultVal, forKey: "tempo" as NSCopying)
                        break
                    }
                }
                for i in 0..<self.clubMArray.count{
                    let dic = self.clubMArray[i] as! NSMutableDictionary
                    if (dic.value(forKey: "clubName") as! String) == "Back Swing"{
                        let defaultVal =  dic.value(forKey: "defaultVal") as! Int
                        swingDict.setObject(defaultVal, forKey: "backSwing" as NSCopying)
                        break
                    }
                }
                for j in 0..<Constants.allClubs.count{
                    for i in 0..<self.clubMArray.count{
                        let dic = self.clubMArray[i] as! NSMutableDictionary
                        var clubName = dic.value(forKey: "clubName") as! String
                        var shortName = String()
                        if clubName == "Driver"{
                            clubName = "driver"
                            shortName = "Dr"
                        }
                        else if clubName == "Woods"{
                            clubName = "wood"
                            shortName = "3w"
                        }
                        else if clubName == "Hybrids"{
                            clubName = "hybrid"
                            shortName = "1h"
                        }
                        else if clubName == "Irons"{
                            clubName = "iron"
                            shortName = "1i"
                        }
                        else if clubName == "Wedges"{
                            clubName = "wedge"
                            shortName = "Pw"
                        }
                        if Constants.allClubs[j] == shortName{
                            let defaultVal =  dic.value(forKey: "defaultVal") as! Int
                            swingDict.setObject(defaultVal, forKey: clubName as NSCopying)
                        }
                    }
                }
                
                /*for i in 0..<self.clubMArray.count{
                    let dic = self.clubMArray[i] as! NSMutableDictionary
                    var clubName = dic.value(forKey: "clubName") as! String
                    if clubName == "Back Swing" || clubName == "Swing Tempo"{
                        clubName = dic.value(forKey: "clubName") as! String
                    }
                    else{
                        if clubName == "Driver"{
                            clubName = "driver"
                        }
                        else if clubName == "Woods"{
                            clubName = "wood"
                        }
                        else if clubName == "Hybrids"{
                            clubName = "hybrid"
                        }
                        else if clubName == "Irons"{
                            clubName = "iron"
                        }
                        else if clubName == "Wedges"{
                            clubName = "wedge"
                        }
                    }
                    let defaultVal =  dic.value(forKey: "defaultVal") as! Int
                    
                    if clubName == "Back Swing" {
                        swingDict.setObject(defaultVal, forKey: "backSwing" as NSCopying)
                    }
                    else if clubName == "Swing Tempo" {
                        swingDict.setObject(defaultVal, forKey: "tempo" as NSCopying)
                    }
                    else{
                        swingDict.setObject(defaultVal, forKey: clubName as NSCopying)
                    }
                }*/
                self.swingGoalsDic = swingDict
                let golfFinalDic = ["swingGoals":swingDict]
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfFinalDic)
            }
            DispatchQueue.main.async( execute: {
                debugPrint("swingGoalsDic",self.swingGoalsDic)
                self.progressView.hide(navItem: self.navigationItem)
            })
        }
    }
    func checkFilterValuesFromFirebase(){
        self.progressView.show()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var hand = 18
        if Constants.handicap != "-"{
            hand = Int(Double(Constants.handicap)!.rounded())
        }
        goalsDic = NSMutableDictionary()
        debugPrint("handicap == ",hand)
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "goals") { (snapshot) in
            if snapshot.value != nil{
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.goalsDic = goalsDic
                }
            }
            else{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "target/\(hand)") { (snapshot) in
                    if let targetDic = snapshot.value as? NSMutableDictionary{
                        self.goalsDic = targetDic
                        
                        let goalsDict = NSMutableDictionary()
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()), forKey: "birdie" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()), forKey: "fairway" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()), forKey: "gir" as NSCopying)
                        goalsDict.setObject(Int((self.goalsDic.value(forKey: "par") as! Double).rounded()), forKey: "par" as NSCopying)
                        
                        if Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "birdie" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "fairway" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "gir" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "par") as! Double).rounded()) < 1{
                            goalsDict.setObject(1, forKey: "par" as NSCopying)
                        }
                        //----------------------------------------------------------------------
                        if Int((self.goalsDic.value(forKey: "birdie") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "birdie" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "fairway") as! Double).rounded()) > 14{
                            goalsDict.setObject(14, forKey: "fairway" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "gir") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "gir" as NSCopying)
                        }
                        else if Int((self.goalsDic.value(forKey: "par") as! Double).rounded()) > 18{
                            goalsDict.setObject(18, forKey: "par" as NSCopying)
                        }
                        self.goalsDic = goalsDict
                        let golfFinalDic = ["goals":goalsDict]
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfFinalDic)
                    }
                }
            }
            DispatchQueue.main.async( execute: {
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
                                        
//                                        let imgView = UIImageView()
//                                        self.expandedSectionHeaderNumber = 0
//                                        self.tableViewExpandSection(0, imageView: imgView)
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    func getShortClubName(clubName: String) -> String{
        var shortClubName = String()
        
        var lastChar = String()
        
        if clubName.contains(find: "Iron"){
            lastChar = String(clubName.dropLast(5))
            shortClubName = lastChar + "i"
        }
        else if clubName.contains(find: "Hybrid"){
            lastChar = String(clubName.dropLast(7))
            shortClubName = lastChar + "h"
        }
        else if clubName.contains(find: "Driver"){
            shortClubName = "Dr"
        }
        else if clubName.contains(find: "Wedge"){
            let firstChar = clubName.first!
            if firstChar == "P"{
                shortClubName = "Pw"
            }
            else if firstChar == "S"{
                shortClubName = "Sw"
            }
            else if firstChar == "G"{
                shortClubName = "Gw"
            }
            else if firstChar == "L"{
                shortClubName = "Lw"
            }
        }
        else if clubName.contains(find: "Wood"){
            lastChar = String(clubName.dropLast(5))
            shortClubName = lastChar + "w"
        }
        else if clubName.contains(find: "Putter"){
            lastChar = String(clubName.dropLast(6))
            shortClubName = lastChar + "Pu"
        }
        return shortClubName
    }
    func getFullClubName(clubName: String) -> String{
        var fullClubName = String()
        
        let lastChar = clubName.last!
        let firstChar = clubName.first!
        
        if lastChar == "i"{
            fullClubName = String(firstChar) + " Iron"
        }
        else if lastChar == "h"{
            fullClubName = String(firstChar) + " Hybrid"
        }
        else if lastChar == "r"{
            fullClubName = "Driver"
        }
        else if lastChar == "u"{
            fullClubName = "Putter"
        }
        else if lastChar == "w"{
            if clubName == "Pw"{
                fullClubName =  "Pitching Wedge"
            }
            else if clubName == "Sw"{
                fullClubName =  "Sand Wedge"
            }
            else if clubName == "Gw"{
                fullClubName =  "Gap Wedge"
            }
            else if clubName == "Lw"{
                fullClubName =  "Lob Wedge"
            }
            else{
                fullClubName = String(firstChar) + " Wood"
            }
        }
        return fullClubName
    }
    
    // MARK: - Table View Delegate And DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = nil
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if (self.expandedSectionHeaderNumber == section) {
            if section == 0{
                return 4
            }
            else{
                return clubMArray.count
            }
        }
        else {
            return 0
        }*/
        if titleStr == "Scoring Goals"{
            return 4
        }
        else{
            return clubMArray.count
        }
        /*else{
         if section == 0{
         return 2
         }
         else if section == 1{
         return 5
         }
         else if section == 2{
         return 2
         }
         else{
         return 0
         }
         }*/
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 35.0
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
//        return 10.0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if titleStr == "Scoring Goals"{
            return CGFloat(110.0)
        }
        else {
            if indexPath.row == 2{
                return CGFloat(125.0)
            }
            else{
                return CGFloat(100.0)
            }
        }
        //        else{
        //return CGFloat(44.0)
        //}
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.10)
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: 270, height: 35.0)
        
        if section == 0{
            label.text = "Game Goals"
            
            if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                viewWithTag.removeFromSuperview()
            }
            let headerFrame = self.tableView.frame.size
            
            let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 7, width: 18, height: 18))
            theImageView.image = UIImage(named: "Chevron-Dn-Wht")
            theImageView.tag = kHeaderSectionTag + section
            
            header.addSubview(theImageView)
            
            header.tag = section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
            header.addGestureRecognizer(headerTapGesture)
        }
        else{
            label.frame = CGRect(x: 10, y: (35.0/2)-8, width: 270, height: 35.0)
            label.text = "Swing Goals"
            label.sizeToFit()
            
            if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                viewWithTag.removeFromSuperview()
            }
            let headerFrame = self.tableView.frame.size
            
            let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 7, width: 18, height: 18))
            theImageView.image = UIImage(named: "Chevron-Dn-Wht")
            theImageView.tag = kHeaderSectionTag + section
            
            header.addSubview(theImageView)
            
            header.tag = section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
            header.addGestureRecognizer(headerTapGesture)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let btnInfo = UIButton()
            btnInfo.frame = CGRect(x:label.frame.origin.x+label.frame.size.width+10, y:7, width:25, height:25)
            btnInfo.setBackgroundImage(infoBtnImage, for: .normal)
            btnInfo.tintColor = UIColor.glfFlatBlue
            btnInfo.addTarget(self, action: #selector(self.headerInfoClicked(_:)), for: .touchUpInside)
            header.addSubview(btnInfo)
        }
        label.textColor = UIColor.black
        header.addSubview(label)
        return header
    }*/

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! SettingCell
        
        cell.lblGoal.isHidden = true
        cell.goalStackView.isHidden = true
        cell.btnGoalInfo.isHidden = true
        cell.lblClubHead.isHidden = true

        if titleStr == "Scoring Goals"{
         cell.goalStackView.isHidden = false
         cell.lblGoal.isHidden = false
         cell.btnGoalInfo.isHidden = false
         cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
         
         cell.isSelected = false
         cell.tintColor = UIColor.clear
         cell.accessoryType = cell.isSelected ? .none : .none
         
         cell.textLabel?.text = ""
         cell.lblMinGoal.text = "1"
         cell.lblMaxGoal.text = "18"
         cell.goalSlider.minimumValue = 1
         cell.goalSlider.maximumValue = 18
         
         cell.goalSlider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
         cell.goalSlider.tag = indexPath.row
         cell.lblGoalVal.tag = indexPath.row
         
         switch indexPath.row{
         case 0: cell.lblGoal.text = "PAR"
         cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "par") as! Double).rounded()))
         cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "par") as! Double).rounded()))"
         
         case 1: cell.lblGoal.text = "BIRDIE"
         cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "birdie") as! Double).rounded()))
         cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "birdie") as! Double).rounded()))"
         
         case 2: cell.lblGoal.text = "FAIRWAY HIT"
         cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "fairway") as! Double).rounded()))
         cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "fairway") as! Double).rounded()))"
         
         cell.lblMaxGoal.text = "14"
         cell.goalSlider.maximumValue = 14

         case 3: cell.lblGoal.text = "GIR"
         cell.goalSlider.value = Float(Int((goalsDic.value(forKey: "gir") as! Double).rounded()))
         cell.lblGoalVal.text = "\(Int((goalsDic.value(forKey: "gir") as! Double).rounded()))"
         
         default: break
         }
         cell.btnGoalInfo.tag = indexPath.row
         cell.btnGoalInfo.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
         }
         else{
         cell.goalStackView.isHidden = false
         cell.lblGoal.isHidden = false
         cell.btnGoalInfo.isHidden = true
         if indexPath.row == 0 || indexPath.row == 1{
         cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
         }
         else{
         cell.lblGoal.font = UIFont(name: "SFProDisplay-Regular", size: 15.0)
         }
         
         if indexPath.row == 2{
         cell.lblClubHead.isHidden = false
         }
         else{
         cell.lblClubHead.isHidden = true
         }
         
         cell.isSelected = false
         cell.tintColor = UIColor.clear
         cell.accessoryType = cell.isSelected ? .none : .none
         
         cell.textLabel?.text = ""
         
            let clubDic = clubMArray[indexPath.row] as! NSDictionary
            let clubName = (clubDic.value(forKey: "clubName") as! String)
            cell.lblGoal.text = clubName

            if clubName == "driver"{
                cell.lblGoal.text = "Driver"
            }
            else if clubName == "wood"{
                cell.lblGoal.text = "Woods"
            }
            else if clubName == "hybrid"{
                cell.lblGoal.text = "Hybrids"
            }
            else if clubName == "iron"{
                cell.lblGoal.text = "Irons"
            }
            else if clubName == "wedge"{
                cell.lblGoal.text = "Wedges"
            }
         
         cell.lblMinGoal.text = "\(clubDic.value(forKey: "minVal") as! Int)"
         cell.lblMaxGoal.text = "\(clubDic.value(forKey: "maxVal") as! Int)"
         cell.goalSlider.minimumValue = Float((clubDic.value(forKey: "minVal") as! Int))
         cell.goalSlider.maximumValue = Float((clubDic.value(forKey: "maxVal") as! Int))
         
         cell.goalSlider.value = Float(Int((clubDic.value(forKey: "defaultVal") as! Int)))
         cell.lblGoalVal.text = "\(Int((clubDic.value(forKey: "defaultVal") as! Int)))"
         
         cell.goalSlider.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
         cell.goalSlider.tag = (indexPath.section*100)+indexPath.row
         cell.lblGoalVal.tag = (indexPath.section*100)+indexPath.row
         
         cell.btnGoalInfo.tag = (indexPath.section*100)+indexPath.row
         cell.btnGoalInfo.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
         }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    // MARK: - infoClicked
    @objc func infoClicked(_ sender:UIButton){
        let section = sender.tag/100
        //        let row = sender.tag%100
        
        if section == 0{
            var title = String()
            var desc = String()
            
            if sender.tag == 0{
                title = "PAR"
                desc = StatsIntoConstants.parAverage
            }
            else if sender.tag == 1{
                title = "BIRDIE"
                desc = "Birdie"
            }
            else if sender.tag == 2{
                title = "FAIRWAY HIT"
                desc = StatsIntoConstants.fairwayHitTrend
            }
            else{
                title = "GIR"
                desc = StatsIntoConstants.GIR
            }
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = (title as String)
            viewCtrl.desc = desc
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        else{
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
            viewCtrl.title = "Clubhead Speed"
            viewCtrl.desc = StatsIntoConstants.clubheadSpeed
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    @objc func sliderChanged(_ sender: UISlider) {
        let section = sender.tag/100
        let row = sender.tag%100
        
        if titleStr == "Scoring Goals"{
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))  as! SettingCell
            cell.lblGoalVal.text = "\(Int((cell.goalSlider.value).rounded()))"
            
            let updatedValue  = Int((cell.goalSlider.value).rounded())
            if sender.tag == 0{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["par":updatedValue])
            }
            else if sender.tag == 1{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["birdie":updatedValue])
            }
            else if sender.tag == 2{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["fairway":updatedValue])
            }
            else{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/goals/").updateChildValues(["gir":updatedValue])
            }
            FBSomeEvents.shared.singleParamFBEvene(param: "Set Goals")
        }
        else{
            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0))  as! SettingCell
            cell.lblGoalVal.text = "\(Int((cell.goalSlider.value).rounded()))"
            
            let clubDic = clubMArray[row] as! NSDictionary
            var clubName = clubDic.value(forKey: "clubName") as! String
            let defaultVal  = Int((cell.goalSlider.value).rounded())
            
            if clubName == "Back Swing"{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues(["backSwing":defaultVal])
            }
            else if clubName == "Swing Tempo"{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues(["tempo":defaultVal])
            }
            else{
//                clubName  = getShortClubName(clubName: clubDic.value(forKey: "clubName") as! String)
//                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues([clubName:defaultVal])
                if clubName == "Driver"{
                    clubName = "driver"
                }
                else if clubName == "Woods"{
                    clubName = "wood"
                }
                else if clubName == "Hybrids"{
                    clubName = "hybrid"
                }
                else if clubName == "Irons"{
                    clubName = "iron"
                }
                else if clubName == "Wedges"{
                    clubName = "wedge"
                }
                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingGoals/").updateChildValues([clubName:defaultVal])
            }
            FBSomeEvents.shared.singleParamFBEvene(param: "Set Swing Goals")
            for i in 0..<clubMArray.count{
                let dic = clubMArray[i] as! NSDictionary
                if dic.value(forKey: "clubName") as! String == clubDic.value(forKey: "clubName") as! String{
                    let clubDic = NSMutableDictionary()
                    clubDic.setObject(dic.value(forKey: "clubName") as! String, forKey: "clubName" as NSCopying)
                    clubDic.setObject(dic.value(forKey: "minVal")!, forKey: "minVal" as NSCopying)
                    clubDic.setObject(dic.value(forKey: "maxVal")!, forKey: "maxVal" as NSCopying)
                    clubDic.setObject(defaultVal, forKey: "defaultVal" as NSCopying)
                    
                    clubMArray.replaceObject(at: i, with: clubDic)
                    break
                }
            }
            debugPrint("clubMArray",clubMArray)
        }
    }
    // MARK: - Expand / Collapse Methods
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer){
        
        let headerView = sender.view!
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            getUpDatedGoalsValues(section:section, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            }
            else {
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                getUpDatedGoalsValues(section:section, imageView: eImageView!)
            }
        }
    }
    func getUpDatedGoalsValues(section:Int, imageView: UIImageView){
        self.goalsDic = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "goals") { (snapshot) in
            if snapshot.value != nil{
                if let goalsDic = snapshot.value as? NSMutableDictionary{
                    self.goalsDic = goalsDic
                }
            }
            DispatchQueue.main.async( execute: {
                self.tableViewExpandSection(section, imageView: imageView)
            })
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        
        self.expandedSectionHeaderNumber = -1
        var indexesPath = [IndexPath]()
        if section == 0{
            for i in 0 ..< 4 {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        else{
            for i in 0..<clubMArray.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        self.tableView!.beginUpdates()
        self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
        self.tableView!.endUpdates()
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        var indexesPath = [IndexPath]()
        if section == 0{
            for i in 0 ..< 4 {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        else{
            for i in 0 ..< clubMArray.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
        }
        self.expandedSectionHeaderNumber = section
        self.tableView!.beginUpdates()
        self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
        self.tableView!.endUpdates()
    }
}
