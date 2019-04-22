//
//  Notification.swift
//  Golfication
//
//  Created by Khelfie on 04/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import UserNotifications

class Notification: NSObject{

    static func sendNotification(reciever:String,message:String,type:String,category:String,matchDataId:String, feedKey:String){
        
        let parameters = ["sender":"\((Auth.auth().currentUser?.uid)!)", "receiver":reciever, "message":message, "type":type, "feedKey": feedKey, "swingKey":matchDataId, "category":category, "storyNum":"sdfaf"] as [String : Any]
        
        //create the url with URL
        //https://www.khelfie.com/Notification/testnotificationFileNew.php
        let url = URL(string: "http://www.khelfie.com/Notification/testnotificationFileNew.php")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
        })
        task.resume()
    }

    // ---------- New Additions by Shubham -------------------------

    static func sendGameDetailsNotification(msg:String,title:String,subtitle:String,timer:Double,isStart:Bool,isHole:Bool){
        if Constants.onCourseNotification == 1{
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["my.notification"])
            center.removeDeliveredNotifications(withIdentifiers: ["my.notification"])
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = msg
            let updateLocation = UNNotificationAction(identifier: "update_Location",title: "Upadate Location", options: [.authenticationRequired])
            
            //        var trackShot = UNNotificationAction(identifier: "track_Shot",title: "Track Shot", options: [.authenticationRequired])
            //        if(isStart){
            //            trackShot = UNNotificationAction(identifier: "stop_Tracking",title: "Stop Tracking", options: [.authenticationRequired])
            //        }
            
            let prevHoleAction = UNNotificationAction(identifier: "prev_hole",title: " Prev Hole", options: [.authenticationRequired])
            let nextHoleAction = UNNotificationAction(identifier: "next_hole",title: "Next Hole", options: [.authenticationRequired])
            
            let category = UNNotificationCategory(identifier: "my.notification",actions: [updateLocation,prevHoleAction, nextHoleAction],intentIdentifiers: [], options: [])
            let category2HoleOut = UNNotificationCategory(identifier: "my.notification",actions: [prevHoleAction, nextHoleAction],intentIdentifiers: [], options: [])
            if(isHole){
                UNUserNotificationCenter.current().setNotificationCategories([category2HoleOut])
            }else{
                UNUserNotificationCenter.current().setNotificationCategories([category])
            }
            content.categoryIdentifier = "my.notification"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timer,
                repeats: false)
            //Create the request
            let request = UNNotificationRequest(
                identifier: "my.notification",
                content: content,
                trigger: trigger
            )
            //Schedule the request
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    static func sendRangeFinderNotification(msg:String,title:String,subtitle:String,timer:Double){
        if Constants.onCourseNotification == 1{
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["my.notification"])
            center.removeDeliveredNotifications(withIdentifiers: ["my.notification"])
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = msg
            let updateLocation = UNNotificationAction(identifier: "update_Location",title: "Upadate Location", options: [.authenticationRequired])
            let prevHoleAction = UNNotificationAction(identifier: "prev_hole",title: " Prev Hole", options: [.authenticationRequired])
            let nextHoleAction = UNNotificationAction(identifier: "next_hole",title: "Next Hole", options: [.authenticationRequired])
            
            let category = UNNotificationCategory(identifier: "my.notification",actions: [updateLocation,prevHoleAction, nextHoleAction],intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "my.notification"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timer,
                repeats: false)
            //Create the request
            let request = UNNotificationRequest(
                identifier: "my.notification",
                content: content,
                trigger: trigger
            )
            //Schedule the request
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    
    static func sendLocalNotificationForNonProNewUser(){
        
        if !Constants.isProMode && Constants.matchId.isEmpty {
            let titleArr = ["Make a Birdie","Are you a weak-iron player?","Score your round in 90 seconds","Account for the Wind!"]
            let subtitleArr = ["Track your round with Easy Scoring, and learn to shoot lower scores.","Know your weaknesses. Make data-driven decisions on-course.","In a hurry? Use Easy Scoring & keep improving your game!","Plan your shots using live Wind Speed and direction."]
            let timeArr : [TimeInterval] = [86400,259200,432000,604800]
//            let timeArr : [TimeInterval] = [60,180,300,420]
            let identifiers = ["my.newUser","my.newUser3","my.newUser5","my.newUser7"]
            for i in 0..<identifiers.count{
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifiers[i]])
                center.removeDeliveredNotifications(withIdentifiers: [identifiers[i]])
                let content = UNMutableNotificationContent()
                content.title = titleArr[i]
                content.body = subtitleArr[i]
                content.badge = 0
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeArr[i], repeats: false)
                let request = UNNotificationRequest(identifier: identifiers[i], content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    static func sendLocaNotificatonNearByGolf(){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["my.nearbyGolf"])
        center.removeDeliveredNotifications(withIdentifiers: ["my.nearbyGolf"])
        let content = UNMutableNotificationContent()
        if let nearByGolfClub = UserDefaults.standard.object(forKey: "NearByGolfClub") as? String{
            content.title = "Playing Golf?"
            content.body = "Start your round at \(nearByGolfClub)!"
            UserDefaults.standard.set("", forKey: "NearByGolfClub")
            UserDefaults.standard.synchronize()
        }
        content.badge = 0
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "my.nearbyGolf", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                debugPrint(error)
            }
        })
    }
    static func sendLocaNotificatonToUser(){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["my.notification"])
        center.removeDeliveredNotifications(withIdentifiers: ["my.notification"])
        let content = UNMutableNotificationContent()
        content.title = "Finish your on-going round"
        content.body = "View performance stats and advanced insights by completing your round at \(Constants.selectedGolfName)!"
        content.badge = 0
        content.sound = UNNotificationSound.default()//1800 30Minutes
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
        let request = UNNotificationRequest(identifier: "my.notification", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                debugPrint(error)
            }
        })
    }
    static func sendLocaNotificatonAfterGameFinished(){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["my.game"])
        center.removeDeliveredNotifications(withIdentifiers: ["my.game"])
        let content = UNMutableNotificationContent()
        content.title = "Optimized Hole Strategy"
        content.body = "Improve your Birdie chances with AI Club Recommendations."
        content.badge = 0
        content.sound = UNNotificationSound.default()//604800 7Days
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: false)
        let request = UNNotificationRequest(identifier: "my.game", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    static func sendLocalNotificationForElevation(){
        if let courseId = UserDefaults.standard.object(forKey: "HomeCourseId") as? String{
            let course = "course_\(courseId)"
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseGolf(addedPath: "\(course)/rangefinder/elevations") { (snapshot) in
                var arr = NSArray()
                if let elevation = snapshot.value as? NSArray{
                    arr = elevation
                }
                DispatchQueue.main.async(execute: {
                    if arr.count != 0{
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: ["my.elevation"])
                        center.removeDeliveredNotifications(withIdentifiers: ["my.elevation"])
                        let content = UNMutableNotificationContent()
                        content.title = "Course elevations are now live!"
                        var golfName = ""
                        if let courseName = UserDefaults.standard.object(forKey: "HomeCourseName") as? String{
                            golfName = courseName
                        }
                        let fullNameArr = Auth.auth().currentUser!.displayName!.components(separatedBy: " ")
                        content.body = "Hi \(fullNameArr[0]). \(golfName) is ready with elevations and \"plays like\" distances. Start your round now!"
                        content.badge = 0
                        content.sound = UNNotificationSound.default()//3600 1hour
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
                        let request = UNNotificationRequest(identifier: "my.elevation", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    }
                })
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "prev_hole":
            print("btnActionPreviousHole")
        case "next_hole":
            print("btnActionNextHole")
        default:
            print("Other Action")
        }
        completionHandler()
    }
}
