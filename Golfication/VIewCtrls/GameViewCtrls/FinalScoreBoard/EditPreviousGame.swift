//
//  EditPreviousGame.swift
//  Golfication
//
//  Created by Khelfie on 01/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class EditPreviousGame: NSObject {
    var isActiveMatch = false
    var matchData = NSDictionary()
    var userData = NSDictionary()
    var scoringValues = [NSMutableDictionary]()
    var updatedValues = NSMutableDictionary()
    var feedKeyForDeletion : String!
    var scoreData : NSMutableDictionary!
    var scoringMode : Int!
    func continuePreviousMatch(matchId:String,userId:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            if let user = snapshot.value as? NSDictionary{
                self.userData = user
            }
            DispatchQueue.main.async( execute: {
                if(self.userData.value(forKey: "activeMatches") != nil){
                    self.isActiveMatch = true
                }
                if(!self.isActiveMatch){
                    FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)/") { (snapshot) in
                        if  let matchDict = (snapshot.value as? NSDictionary){
                            self.matchData = matchDict as! NSMutableDictionary
                            var keyData = String()
                            for (key,value) in matchDict{
                                keyData = key as! String
                                if (keyData == "scoringMode"){
                                    let scoringMode = value as! String
                                    if(scoringMode == "classic"){
                                        self.scoringMode = 3
                                    }
                                    else if(scoringMode == "rangefinder"){
                                        self.scoringMode = 2
                                    }
                                    else{
                                        self.scoringMode = 1
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async(execute: {
                            if let scoring = self.userData.value(forKey: "scoring") as? NSDictionary{
                                self.scoringValues = scoring.allValues as! [NSMutableDictionary]
                                let allKeys = scoring.allKeys as! [String]
                                if let index = allKeys.index(of: matchId){
                                    self.scoreData = self.scoringValues[index]
                                }
                                self.updatedValues.setValue(self.scoringValues.count > 1 ? self.scoringValues.count:NSNull(), forKey: "scoring")
                            }
                            var allFeed = [String:Bool]()
                            if let myFeeds = self.userData["myFeeds"] as? [String : Bool]{
                                allFeed = myFeeds
                                let group = DispatchGroup()
                                for (key,_) in myFeeds{
                                    group.enter()
                                    ref.child("feedData/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                                        if snapshot.exists() {
                                            let feedData = (snapshot.value as? NSDictionary)!
                                            if let match = feedData["matchKey"] as? String {
                                                if(match == matchId){
                                                    self.feedKeyForDeletion = key
                                                }
                                            }
                                        }
                                        group.leave()
                                    })
                                }
                                group.notify(queue: .main) {
                                    if(self.feedKeyForDeletion != nil){
                                        allFeed.removeValue(forKey: self.feedKeyForDeletion)
                                    }
                                    self.updatedValues.setValue(allFeed, forKey: "myFeeds")
                                    debugPrint(self.updatedValues)
                                    self.checkStatisticsData(matchKey: matchId, userKey: userId)
                                    debugPrint(self.updatedValues)
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    func checkStatisticsData(matchKey:String,userKey:String) {
        var statistics = NSMutableDictionary()
        var card4 : NSMutableDictionary!
        var card6 : NSMutableDictionary!
        var card7 : NSMutableDictionary!
        if let states = userData.value(forKey: "statistics") as? NSMutableDictionary{
            statistics = states
            card4 = statistics.value(forKey: "card4") as! NSMutableDictionary
            card6 = statistics.value(forKey: "card6") as! NSMutableDictionary
            card7 = statistics.value(forKey: "card7") as! NSMutableDictionary
            card4.removeObject(forKey: matchKey)
            var smartCaddie : NSMutableDictionary!
            if(self.scoringMode == 1) && self.scoreData != nil{
                smartCaddie = scoreData.value(forKey: "smartCaddie") as? NSMutableDictionary
                var distance = Double()
                var size = Int()
                if let drData = smartCaddie.value(forKey: "Dr") as? [NSMutableDictionary]{
                    for data in drData{
                        distance += data.value(forKey: "distance") as! Double
                    }
                    size = drData.count
                }
                var count = card6.value(forKey: "driveCount") as! Int
                var dis = card6.value(forKey: "driveDistance") as! Double
                count -= size
                dis -= distance
                card6.setValue(count, forKey: "driveCount")
                card6.setValue(dis, forKey: "driveDistance")
            }
            if let scoreArr = self.matchData.value(forKey: "scoring") as? [NSMutableDictionary]{
                var puttsCount = Int()
                var holeCount = Int()
                for data in scoreArr{
                    if let holeData = data.value(forKey:userKey) as? NSMutableDictionary{
                        if let putts = holeData.value(forKey: "putting") as? Int{
                            puttsCount += putts
                            holeCount += 1
                        }
                    }
                }
                var putts = card7.value(forKey: "puttCount") as! Int
                var holes = card7.value(forKey: "holeCount") as! Int
                putts -= puttsCount
                holes -= holeCount
                card7.setValue(putts, forKey: "puttCount")
                card7.setValue(holes, forKey: "holeCount")
            }
        }
        statistics.setValue(card4, forKey: "card4")
        statistics.setValue(card6, forKey: "card6")
        statistics.setValue(card7, forKey: "card7")
        updatedValues.setValue(statistics, forKey: "statistics")
    }
}
