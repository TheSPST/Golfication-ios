//
//  NotificationForReferral.swift
//  Golfication
//
//  Created by Khelfie on 10/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class NotificationForReferral: NSObject {
    var newTimer : Int64!
    var keys : [String]!
    func checkReferralTimestampWithInvite(completionHandler:@escaping (Bool) -> ()){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/\(referedBy!)/referralTimestamp") { (snapshot) in
            if let timer = snapshot.value as? Int64{
                self.newTimer = timer
            }
            DispatchQueue.main.async( execute: {
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/\(referedBy!)/invite") { (snapshot) in
                    var dataDic = [String:Bool]()
                    self.keys = [String]()
                    if(snapshot.childrenCount > 0){
                        dataDic = (snapshot.value as? [String : Bool])!
                    }
                    DispatchQueue.main.async( execute: {
                        for refer in dataDic{
                            if(refer.value){
                                self.keys.append(refer.key)
                            }
                        }
                        if(self.newTimer != nil){
                            let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(self.newTimer/1000)))
                            let timeEnd = Calendar.current.date(byAdding: .second, value: 2*24*60*60, to: timeStart as Date)
                            if(timeEnd! < Date(timeIntervalSince1970: (TimeInterval(Timestamp/1000)))) && self.keys.count == 1{
                                    Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Invite one more friend to claim your $50 discount!", type: "13", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }else if(timeEnd! < Date(timeIntervalSince1970: (TimeInterval(Timestamp/1000)))) && self.keys.count == 2{
                                    Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Congratulations! Your $50 discount is ready!", type: "13", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }else if (self.keys.count > 2){
                                Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Congratulations!", type: "6", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }else{
                                Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Congratulations!", type: "6", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }
                        }else{
                            if(self.keys.count == 1){
                                Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Invite one more friend to claim your $50 discount!", type: "13", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }else if(self.keys.count == 2){
                                Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Congratulations! Your $50 discount is ready!", type: "13", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }else if(self.keys.count > 2){
                                Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Congratulations!", type: "6", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            }
                            ref.child("userData/\(referedBy!)/").updateChildValues(["referralTimestamp":Timestamp] as [AnyHashable:Any])
                        }
                        if self.keys.count == 0 && !referedBy.isEmpty{
                            Notification.sendNotification(reciever: "\(referedBy!)",message: "Your friend \(Auth.auth().currentUser!.displayName!) has just joined Golfication. Invite two more friends to claim your $50 discount!", type: "13", category: "Referred", matchDataId: "notAvailable", feedKey:"nothing")
                            if(self.newTimer == nil){
                                ref.child("userData/\(referedBy!)/").updateChildValues(["referralTimestamp":Timestamp] as [AnyHashable:Any])
                            }
                        }
                        completionHandler(true)
                    })
                }
                
            })
        }
    }
}
