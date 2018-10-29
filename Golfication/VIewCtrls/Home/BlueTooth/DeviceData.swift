//
//  DeviceData.swift
//  Golfication
//
//  Created by Khelfie on 22/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Firebase
class DeviceData: NSObject {
    var swingMatchId : String!
    var currentGameId : Int!
    var isPracticeMatch : Bool!
    var matchId : String!
    var isDeviceSetup: Bool!
    var swingDetails = [(shotNo:Int,bs:Double,ds:Double,hv:Double,cv:Double,ba:Double,tempo:Double,club:String,time:Int64)]()
    var totalPracticeSession : Int!
    let progressView = SDLoader()
    func getDeviceData(){
        progressView.show()
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "deviceSetup") { (snapshot) in
            if (snapshot.value as? Bool) != nil{
                self.isDeviceSetup = snapshot.value as? Bool
                debugPrint(self.isDeviceSetup ? "Device Setup Completed":"please finish setup first")
            }
            DispatchQueue.main.async(execute: {
                if !self.isDeviceSetup{
                    UIApplication.shared.keyWindow?.makeToast("Please Finish Setup First from the profile.")
                }
                self.getActiveMatchId()
            })
        }
    }
    func getActiveMatchId(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "activeMatches") { (snapshot) in
            if let activeMatches = snapshot.value as? [String:Bool]{
                for data in activeMatches where data.value{
                    self.matchId = data.key
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide()
                if self.matchId != nil{
                    debugPrint("Active Matches : \(self.matchId!)")
                    self.getSwingKey(matchId: self.matchId)
                }
            })

        }
    }
    func getSwingKey(matchId:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseUserData(addedPath: "matchData/\(matchId)/plyer/\(Auth.auth().currentUser!.uid)/swingKey") { (snapshot) in
            if (snapshot.value != nil) {
                self.swingMatchId = snapshot.value as? String
            }
            DispatchQueue.main.async(execute: {
                if self.swingMatchId != nil {
                    debugPrint("Active Swing : \(self.swingMatchId!)")
                    self.getCurrentGameID(swingMatchId:self.swingMatchId)
                }else{
                    self.getSwingKeyForPractice()
                }
            })
        }
    }
    func getSwingKeyForPractice(){
        progressView.show()
        var swingMArray = NSMutableArray()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession") { (snapshot) in
            var dataDic = [String:Bool]()
            if(snapshot.value != nil){
                if let dataDi = snapshot.value as? [String:Bool]{
                    dataDic = dataDi
                    self.totalPracticeSession = dataDi.count+1
                }
            }
            DispatchQueue.main.async(execute: {
                let group = DispatchGroup()
                for (key, value) in dataDic{
                    group.enter()
                    if (value){
                        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(key)") { (snapshot) in
                            if(snapshot.value != nil){
                                if let data = snapshot.value as? NSDictionary{
                                    let timestamp = data.value(forKey: "timestamp") as? Int64
                                    if(timestamp != nil){
                                        let timeStart = Date(timeIntervalSince1970: (TimeInterval(timestamp!/1000)))
                                        let timeEnd = Calendar.current.date(byAdding: .second, value: 10*60*60, to: timeStart as Date)
                                        let timeNow = Date()
                                        if(timeNow > timeEnd!){
                                            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([key:false])
                                        }
                                    }
                                    self.currentGameId = data.value(forKey: "gameId") as? Int
                                    self.swingMatchId = key
                                    if let swings = data.value(forKey: "swings") as? NSMutableArray{
                                        for swing in swings{
                                            if let swin = swing as? NSMutableDictionary{
                                                let shot = swin.value(forKey: "shotNum") as! Int
                                                let bs = swin.value(forKey: "backSwing") as! Double
                                                let ds = swin.value(forKey: "downSwing") as! Double
                                                let hv = swin.value(forKey: "handSpeed") as! Double
                                                let cv = swin.value(forKey: "clubSpeed") as! Double
                                                let ba = swin.value(forKey: "backSwingAngle") as! Double
                                                let tempo = swin.value(forKey: "tempo") as! Double
                                                let club = swin.value(forKey: "club") as! String
                                                let time = swin.value(forKey: "timestamp") as! Int64
                                                self.swingDetails.append((shotNo: shot, bs: bs, ds: ds, hv: hv, cv: cv, ba: ba, tempo: tempo, club: club, time: time))
                                            }
                                        }
                                    }
                                    if let playType = data.value(forKey: "playType") as? String{
                                        if(playType != "match") && self.swingDetails.count != 0{
                                            swingMArray.add(data)
                                        }
                                    }
                                }
                            }
                            group.leave()
                        }
                    }
                    else{
                        group.leave()
                    }
                }
                
                group.notify(queue: .main, execute: {
                    if swingMArray.count != 0{
                        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                        let array: NSArray = swingMArray.sortedArray(using: [sortDescriptor]) as NSArray
                        swingMArray.removeAllObjects()
                        swingMArray = NSMutableArray()
                        swingMArray = array.mutableCopy() as! NSMutableArray
                        debugPrint("Active Swing Data",swingMArray)
                    }
                    if self.swingMatchId != nil{
                        debugPrint("Active Swing : \(self.swingMatchId!)")
                        self.getCurrentGameID(swingMatchId:self.swingMatchId)
                    }
                    self.progressView.hide()
                })
            })
        }
    }
    
    func getCurrentGameID(swingMatchId:String){
        progressView.show()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingMatchId)") { (snapshot) in
            var swingData = NSMutableDictionary()
            if (snapshot.value != nil) {
                swingData = snapshot.value as! NSMutableDictionary
            }
            DispatchQueue.main.async(execute: {
                for (key,value) in swingData{
                    if(key as! String == "gameId"){
                        self.currentGameId = value as? Int
                        debugPrint("Active GameID : \(self.currentGameId ?? 0)")

                    }
                    else if(key as! String == "playType"){
                        if(value as! String == "practice"){
                            self.isPracticeMatch = true
                            debugPrint("Active match type",value)
                        }
                    }
                }
                self.progressView.hide()
            })
        }
    }
}
