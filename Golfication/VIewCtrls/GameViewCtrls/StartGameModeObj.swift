//
//  StartGameModeObj.swift
//  Golfication
//
//  Created by Rishabh Sood on 25/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseAnalytics
import FBSDKCoreKit
class StartGameModeObj: NSObject{

    var finalMatchDic = NSMutableDictionary()
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var requestedMatchId = String()
    
    // MARK: setUpClassicMap
    func setUpClassicMap(onCourse:Int){
        matchDataDic = NSMutableDictionary()
        let tempdic = NSMutableDictionary()
        tempdic.setObject(Auth.auth().currentUser?.uid ?? "", forKey: "id" as NSCopying)
        tempdic.setObject(Auth.auth().currentUser?.displayName ?? "", forKey: "name" as NSCopying)
        if selectedTee.count > 1{
            tempdic.setObject(selectedTee.lowercased(), forKey: "tee" as NSCopying)
            tempdic.setObject(selectedTeeColor.lowercased(), forKey: "teeColor" as NSCopying)
            tempdic.setObject("\(handicap)", forKey: "handicap" as NSCopying)
        }

        var imagUrl =  ""
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        tempdic.setObject(imagUrl, forKey: "image" as NSCopying)
        tempdic.setObject(2, forKey: "status" as NSCopying)
        tempdic.setObject(-1, forKey: "timestamp" as NSCopying)
        addPlayersArray.insert(tempdic, at: 0)
        
        for i in 1..<addPlayersArray.count{
            (addPlayersArray[i] as AnyObject).setObject(1, forKey: "status" as NSCopying)
        }
        debugPrint("addPlayersArray== ",addPlayersArray)
        if(isShowCase){
            let dJohnSonUser = NSMutableDictionary()
            dJohnSonUser.setObject("D.Johnson" , forKey: "name" as NSCopying)
            dJohnSonUser.setObject( "http://www.golfication.com/assets/DJ%20256PNG.png", forKey: "image" as NSCopying)
            dJohnSonUser.setObject(Timestamp , forKey: "timestamp" as NSCopying)
            dJohnSonUser.setObject( "jpSgWiruZuOnWybYce55YDYGXP62", forKey: "id" as NSCopying)
            addPlayersArray.add(dJohnSonUser)
        }
        matchDataDic.setObject(selectedGolfID, forKey: "courseId" as NSCopying)
        matchDataDic.setObject(selectedGolfName, forKey: "courseName" as NSCopying)
        matchDataDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        matchDataDic.setObject(gameType, forKey: "matchType" as NSCopying)
        matchDataDic.setObject("classic", forKey: "scoringMode" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "startingHole" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "currentHole" as NSCopying)
        matchDataDic.setObject((Auth.auth().currentUser?.uid)!, forKey: "startedBy" as NSCopying)
        let playerDict = NSMutableDictionary()
        for data in addPlayersArray{
            let player = data as! NSMutableDictionary
            let id = player.value(forKey: "id")
            playerDict.setObject(player, forKey: id as! NSCopying)
        }
        matchDataDic.setObject(playerDict, forKey: "player" as NSCopying)
        matchDataDic.setObject(selectedLat, forKey: "lat" as NSCopying)
        matchDataDic.setObject(selectedLong, forKey: "lng" as NSCopying)
        matchDataDic.setObject(onCourse == 0 ? true:false, forKey: "onCourse" as NSCopying)
        updateLastCourseDetails(scoringMode:"classic")
        matchId = ref!.child("matchData").childByAutoId().key
        self.finalMatchDic.setObject(matchDataDic, forKey: matchId as NSCopying)
        for player in addPlayersArray{
            
            if let reciever = ((player as AnyObject).object(forKey:"id") as? String){
                if(reciever != Auth.auth().currentUser?.uid){
                    Notification.sendNotification(reciever: reciever, message: "\(Auth.auth().currentUser?.displayName ?? "Guest1") send you request to join the game", type:"7", category: "dont know",matchDataId: matchId, feedKey: "")
                }
            }
            
        }
        ref.child("matchData").updateChildValues(self.finalMatchDic as! [AnyHashable : Any])
       
        if(!isShowCase){
            for (key,_) in playerDict{
                if((key as! String) == Auth.auth().currentUser?.uid) && (matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:true] as [AnyHashable:Any])
                }
                else if (matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:false] as [AnyHashable:Any])
                }
            }
        }
        if  !(selectedGolfID == "") {
            let courseId = "course_\(selectedGolfID)"
            self.getParFromFirebase(courseId: courseId, matchData: matchDataDic)
        }
        FBSomeEvents.shared.logGameStartedEvent(gameType: 3)
    }
    func updateLastCourseDetails(scoringMode:String){
        let lastCourseDict = NSMutableDictionary()
        lastCourseDict.setObject(selectedGolfID, forKey: "id" as NSCopying)
        lastCourseDict.setObject(selectedLat, forKey: "lat" as NSCopying)
        lastCourseDict.setObject(selectedLong, forKey: "lng" as NSCopying)
        lastCourseDict.setObject(selectedGolfName, forKey: "name" as NSCopying)
        
        if(scoringMode == "advanced"){
            lastCourseDict.setObject("2", forKey: "mapped" as NSCopying)
        }else if(scoringMode == "rangefinder"){
            lastCourseDict.setObject("1", forKey: "mapped" as NSCopying)
        }else{
            lastCourseDict.setObject("0", forKey: "mapped" as NSCopying)
        }
        let lastCourseDetails = ["lastCourseDetails":lastCourseDict]
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(lastCourseDetails)
    }
    func getParFromFirebase(courseId:String,matchData:NSMutableDictionary){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "golfCourses/\(courseId)/par") { (snapshot) in
            
            var dataDic = NSMutableArray()
            if(snapshot.childrenCount > 0){
                dataDic = snapshot.value as! NSMutableArray
            }
            var count = 1
            for data in dataDic {
                if let par = (data as AnyObject).value(forKey: "par") as? String{
                    self.scoring.append((hole: count, par: Int(par)!, players: [NSMutableDictionary]()))
                }else if let par = (data as AnyObject).value(forKey: "par") as? Int{
                    self.scoring.append((hole: count, par: par, players: [NSMutableDictionary]()))
                }
                count += 1
            }
            DispatchQueue.main.async(execute: {
                if(self.scoring.count > 0){
                    mode = 3
                    Analytics.logEvent("mode3_gameStarted", parameters: [:])
                    Notification.sendLocaNotificatonToUser()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: self.scoring)
                }
                else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClassicApiCompleted"), object: self.scoring)
                }
            })
        }
    }
    
    // MARK: setUpRFMap
    func setUpRFMap(golfId: String,onCourse:Int){
        matchDataDic = NSMutableDictionary()
        let tempdic = NSMutableDictionary()
        tempdic.setObject(Auth.auth().currentUser?.uid ?? "", forKey: "id" as NSCopying)
        tempdic.setObject(Auth.auth().currentUser?.displayName ?? "", forKey: "name" as NSCopying)
        if selectedTee.count > 1{
            tempdic.setObject(selectedTee.lowercased(), forKey: "tee" as NSCopying)
            tempdic.setObject(selectedTeeColor.lowercased(), forKey: "teeColor" as NSCopying)
            tempdic.setObject("\(handicap)", forKey: "handicap" as NSCopying)

        }
        var imagUrl =  ""
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        tempdic.setObject(imagUrl, forKey: "image" as NSCopying)
        tempdic.setObject(2, forKey: "status" as NSCopying)
        tempdic.setObject(-1, forKey: "timestamp" as NSCopying)
        addPlayersArray.insert(tempdic, at: 0)
        for i in 1..<addPlayersArray.count{
            (addPlayersArray[i] as AnyObject).setObject(1, forKey: "status" as NSCopying)
        }
        if(isShowCase){
            let dJohnSonUser = NSMutableDictionary()
            dJohnSonUser.setObject("Deejay" , forKey: "name" as NSCopying)
            dJohnSonUser.setObject( "http://www.golfication.com/assets/DJ%20256PNG.png", forKey: "image" as NSCopying)
            dJohnSonUser.setObject(Timestamp , forKey: "timestamp" as NSCopying)
            dJohnSonUser.setObject( "jpSgWiruZuOnWybYce55YDYGXP62", forKey: "id" as NSCopying)
            addPlayersArray.add(dJohnSonUser)
        }
        matchDataDic.setObject(selectedGolfID, forKey: "courseId" as NSCopying)
        matchDataDic.setObject(selectedGolfName, forKey: "courseName" as NSCopying)
        matchDataDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        matchDataDic.setObject(gameType, forKey: "matchType" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "startingHole" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "currentHole" as NSCopying)
        matchDataDic.setObject("rangefinder", forKey: "scoringMode" as NSCopying)
        matchDataDic.setObject((Auth.auth().currentUser?.uid)!, forKey: "startedBy" as NSCopying)
        let playerDict = NSMutableDictionary()
        for data in addPlayersArray{
            let player = data as! NSMutableDictionary
            let id = player.value(forKey: "id")
            playerDict.setObject(player, forKey: id as! NSCopying)
        }
        matchDataDic.setObject(playerDict, forKey: "player" as NSCopying)
        matchDataDic.setObject(selectedLat, forKey: "lat" as NSCopying)
        matchDataDic.setObject(selectedLong, forKey: "lng" as NSCopying)
        matchDataDic.setObject(onCourse == 0 ? true:false, forKey: "onCourse" as NSCopying)
        updateLastCourseDetails(scoringMode:"rangefinder")
        matchId = ref!.child("matchData").childByAutoId().key
        self.finalMatchDic.setObject(matchDataDic, forKey: matchId as NSCopying)
        for player in addPlayersArray{
            if let reciever = ((player as AnyObject).object(forKey:"id") as? String){
                if(reciever != Auth.auth().currentUser?.uid){
                    Notification.sendNotification(reciever: reciever, message: "\(Auth.auth().currentUser?.displayName ?? "Guest1") send you request to join the game", type:"7", category: "dont know",matchDataId: matchId, feedKey: "")
                }
            }
            
        }
        ref.child("matchData").updateChildValues(self.finalMatchDic as! [AnyHashable : Any])
        if(!isShowCase){
            for (key,_) in playerDict{
                if((key as! String) == Auth.auth().currentUser?.uid) && matchId.count > 1{
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:true] as [AnyHashable:Any])
                }
                else if (matchId.count>1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:false] as [AnyHashable:Any])
                }
            }
        }
        if  !(selectedGolfID == "") {
            
            mode = 2
            Analytics.logEvent("mode2_gameStarted", parameters: [:])
            Notification.sendLocaNotificatonToUser()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RFApiCompleted"), object: golfId)
        }
        FBSomeEvents.shared.logGameStartedEvent(gameType: 2)        
    }
    
    // MARK: showDefaultMap
    func showDefaultMap(onCourse:Int){
        
        setUpMapData(scoringMode: "advanced",onCourse:onCourse)
        mode = 1
        Analytics.logEvent("mode1_gameStarted", parameters: [:])
        Notification.sendLocaNotificatonToUser()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DefaultMapApiCompleted"), object: self.scoring)
    }
    
    func setUpMapData(scoringMode:String,onCourse:Int){
        
        matchDataDic = NSMutableDictionary()
        let tempdic = NSMutableDictionary()
        tempdic.setObject(Auth.auth().currentUser?.uid ?? "", forKey: "id" as NSCopying)
        tempdic.setObject(Auth.auth().currentUser?.displayName ?? "", forKey: "name" as NSCopying)
        if selectedTee.count > 1{
            tempdic.setObject(selectedTee.lowercased(), forKey: "tee" as NSCopying)
            tempdic.setObject(selectedTeeColor.lowercased(), forKey: "teeColor" as NSCopying)
            tempdic.setObject("\(handicap)", forKey: "handicap" as NSCopying)
        }
        var imagUrl =  ""
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        tempdic.setObject(imagUrl, forKey: "image" as NSCopying)
        tempdic.setObject(2, forKey: "status" as NSCopying)
        tempdic.setObject(-1, forKey: "timestamp" as NSCopying)
        addPlayersArray.insert(tempdic, at: 0)
        
        for i in 1..<addPlayersArray.count{
            (addPlayersArray[i] as AnyObject).setObject(1, forKey: "status" as NSCopying)
        }
        matchDataDic.setObject(selectedGolfID, forKey: "courseId" as NSCopying)
        matchDataDic.setObject(selectedGolfName, forKey: "courseName" as NSCopying)
        matchDataDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
        matchDataDic.setObject(gameType, forKey: "matchType" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "startingHole" as NSCopying)
        matchDataDic.setObject(startingHole, forKey: "currentHole" as NSCopying)
        if(scoringMode.count > 0){
            matchDataDic.setObject(scoringMode, forKey: "scoringMode" as NSCopying)
        }
        matchDataDic.setObject((Auth.auth().currentUser?.uid)!, forKey: "startedBy" as NSCopying)
        let playerDict = NSMutableDictionary()
        for data in addPlayersArray{
            let player = data as! NSMutableDictionary
            let id = player.value(forKey: "id")
            playerDict.setObject(player, forKey: id as! NSCopying)
        }
        
        matchDataDic.setObject(playerDict, forKey: "player" as NSCopying)
        matchDataDic.setObject(selectedLat, forKey: "lat" as NSCopying)
        matchDataDic.setObject(selectedLong, forKey: "lng" as NSCopying)
        matchDataDic.setObject(onCourse == 0 ? true:false, forKey: "onCourse" as NSCopying)
        updateLastCourseDetails(scoringMode:"advanced")
        matchId = ref!.child("matchData").childByAutoId().key
        self.finalMatchDic.setObject(matchDataDic, forKey: matchId as NSCopying)
        
        for player in addPlayersArray{
            if let reciever = ((player as AnyObject).object(forKey:"id") as? String){
                if(reciever != Auth.auth().currentUser?.uid){
                    Notification.sendNotification(reciever: reciever, message: "\(Auth.auth().currentUser?.displayName ?? "Guest1") send you request to join the game", type:"7", category: "dont know",matchDataId: matchId, feedKey: "")
                }
            }
        }
        ref.child("matchData").updateChildValues(self.finalMatchDic as! [AnyHashable : Any])
        if(!isShowCase){
            for (key,_) in playerDict{
                if((key as! String) == Auth.auth().currentUser?.uid) && (matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:true] as [AnyHashable:Any])
                }
                else if(matchId.count > 1){
                    ref.child("userData/\(key as! String)/activeMatches/").updateChildValues([matchId:false] as [AnyHashable:Any])
                }
            }
        }
        FBSomeEvents.shared.logGameStartedEvent(gameType: 1)
        
    }
    
}

