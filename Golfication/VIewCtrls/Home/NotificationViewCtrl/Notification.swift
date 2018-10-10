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
    
    static func sendLocaNotificatonToUser(){
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // Swift
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        
        let content = UNMutableNotificationContent()
        //content.title = "Please complete your Game"
        //content.subtitle = "Notification test"
        content.body = "Complete your ongoing round at \(selectedGolfName)!"
        content.badge = 0
        
        content.sound = UNNotificationSound.default()
        //content.sound = UNNotificationSound(named: "MySound.aiff") //file name is "MySound.aiff"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
        let request = UNNotificationRequest(identifier: "UYLLocalNotification", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                debugPrint(error)
                // Something went wrong
            }
        })
    }
    
    static func sendLocaNotificatonNearByGolf(){
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // Swift
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        //
        let content = UNMutableNotificationContent()
        
        if let nearByGolfClub = UserDefaults.standard.object(forKey: "NearByGolfClub") as? String{
            content.body = "Start your round at \(nearByGolfClub)!"
            UserDefaults.standard.set("", forKey: "NearByGolfClub")
            UserDefaults.standard.synchronize()
        }
        else{
            if let courseName = UserDefaults.standard.object(forKey: "HomeCourseName") as? String{
                content.body = "Start your round at \(courseName)!"
            }
        }
        content.badge = 0
        
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "UYLLocalNotification", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                debugPrint(error)
                // Something went wrong
            }
        })
    }
    
    // ---------- New Additions by Shubham -------------------------

    static func sendGameDetailsNotification(msg:String,title:String,subtitle:String,timer:Double,isStart:Bool,isHole:Bool){
        if onCourseNotification == 1{
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
        if onCourseNotification == 1{
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
