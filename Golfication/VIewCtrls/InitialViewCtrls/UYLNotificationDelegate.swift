//
//  UYLNotificationDelegate.swift
//  Golfication
//
//  Created by Rishabh Sood on 03/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://useyourloaf.com/blog/local-notifications-with-ios-10/
//https://www.devfright.com/use-usernotifications-framework-delegate-protocol/

import UIKit
import UserNotifications

var friendNotifFeedId = String()

class UYLNotificationDelegate: NSObject, UNUserNotificationCenterDelegate  {
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()

    //triggered when app is in foreground
    /*func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        var userInfo = notification.request.content.userInfo
//        if notification.request.identifier == UNNotificationDefaultActionIdentifier{
//            //self.redirectToGameScreen()
//        }
    
        // Play sound and show alert to the user
        completionHandler([.alert, .sound, .badge])
    }*/
    
    //  triggered when user taps on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        var userInfo = response.notification.request.content.userInfo
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Notification")
        if userInfo["type"] as? String == "8" {
           getScoreFromMatchDataScoring(matchId: userInfo["swingKey"] as! String)
         }
         else if userInfo["type"] as? String == "9" {
            // Opens the particular feed item
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl

            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
            viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
            viewCtrl.fromIndiegogo = true
            viewCtrl.fromNotification = true
            var navCtrl = UINavigationController()
            navCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            navCtrl.pushViewController(viewCtrl, animated: true)
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
         else if userInfo["type"] as? String == "10" {
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl

            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MyFeedVC") as! MyFeedVC
            viewCtrl.feedKey = userInfo["feedKey"] as! String
            var navCtrl = UINavigationController()
            navCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            navCtrl.pushViewController(viewCtrl, animated: true)
         }
        else if userInfo["type"] as? String == "11" || userInfo["type"] as? String == "6"{
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            
            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileVC
            viewCtrl.userKey = userInfo["sender"] as! String
            var navCtrl = UINavigationController()
            navCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            navCtrl.pushViewController(viewCtrl, animated: true)
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
         }
         else if userInfo["type"] as? String == "12" {
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
            
            friendNotifFeedId = userInfo["feedKey"] as! String
            tabBarCtrl.selectedIndex = 1
         }
        else
        {
            switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                debugPrint("Dismiss Action")
            case UNNotificationDefaultActionIdentifier:
                if(response.notification.request.content.categoryIdentifier != "my.notification"){
                    self.redirectToGameScreen()
                }
            case "Snooze":
                debugPrint("Snooze")
            case "Delete":
                debugPrint("Delete")
            case "update_Location":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
            case "track_Shot":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotTracking"), object: nil)
            case "stop_Tracking":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotTracking"), object: nil)
            case "prev_hole":
                debugPrint("PrevHole")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "holeChange"), object: "prev")
            case "next_hole":
                debugPrint("NextHole")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "holeChange"), object: "next")
            default:
                debugPrint("Unknown action")
            }
        }
        // Determine the user action
        completionHandler()
    }
    
    // MARK: - getScoreFromMatchDataScoring
    func getScoreFromMatchDataScoring(matchId:String){
        self.scoring.removeAll()
        var isManualScoring = false
        let matchDataDiction = NSMutableDictionary()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)") { (snapshot) in
            var matchDict = NSDictionary()
            if(snapshot.childrenCount > 1){
                matchDict = (snapshot.value as? NSDictionary)!
            }
            var scoreArray = NSArray()
            var keyData = String()
            var playersKey = [String]()
            for (key,value) in matchDict{
                keyData = key as! String
                if(keyData == "player"){
                    for (k,_) in value as! NSMutableDictionary{
                        playersKey.append(k as! String)
                    }
                }
                else if (keyData == "scoring"){
                    scoreArray = (value as! NSArray)
                }
                else if(keyData == "scoringMode"){
                    isManualScoring = true
                }else if(keyData == "courseId"){
                    matchDataDiction.setObject(value, forKey: "courseId" as NSCopying)
                }else if (keyData == "courseName"){
                    matchDataDiction.setObject(value, forKey: "courseName" as NSCopying)
                }else if(keyData == "startingHole"){
                    matchDataDiction.setObject(value, forKey: "startingHole" as NSCopying)
                }else if (keyData == "matchType"){
                    matchDataDiction.setObject(value, forKey: "matchType" as NSCopying)
                }
            }
            for i in 0..<scoreArray.count {
                var playersArray = [NSMutableDictionary]()
                var par:Int!
                let score = scoreArray[i] as! NSDictionary
                for(key,value) in score{
                    if(key as! String == "par"){
                        par = value as! Int
                    }
                    for playerId in playersKey{
                        if(key as! String)==playerId{
                            let dict = NSMutableDictionary()
                            dict.setObject(value, forKey: key as! String as NSCopying)
                            playersArray.append(dict)
                        }
                    }
                }
                self.scoring.append((hole: i, par:par,players:playersArray))
            }
            let players = NSMutableArray()
            if(matchDict.object(forKey: "player") != nil){
                let tempArray = matchDict.object(forKey: "player")! as! NSMutableDictionary
                for (k,v) in tempArray{
                    let dict = v as! NSMutableDictionary
                    dict.addEntries(from: ["id":k])
                    players.add(dict)
                }
            }
            DispatchQueue.main.async(execute: {
                
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl

                let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "FinalScoreBoardViewCtrl") as! FinalScoreBoardViewCtrl
                viewCtrl.finalPlayersData = players
                viewCtrl.finalScoreData = self.scoring
                viewCtrl.isManualScoring = isManualScoring
                viewCtrl.matchDataDict = matchDataDiction
                viewCtrl.currentMatchId = matchId
                var navCtrl = UINavigationController()
                navCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
                navCtrl.pushViewController(viewCtrl, animated: true)
            })
        }
    }
    
    func redirectToGameScreen(){
        
        let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarCtrl
        let gameController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC

        var playNavCtrl = UINavigationController()
        playNavCtrl.automaticallyAdjustsScrollViewInsets = false
        playNavCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
        playNavCtrl.pushViewController(gameController, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
}
