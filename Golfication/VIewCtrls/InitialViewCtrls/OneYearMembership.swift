//
//  OneYearMembership.swift
//  Golfication
//
//  Created by Khelfie on 08/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class OneYearMembership: NSObject {
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970) * 1000
    }

    func giveMemberShip(promocode:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "codes/\(promocode)") { (snapshot) in
            var codeData = String()
            if(snapshot.value != nil){
                codeData = snapshot.value as! String
            }
            DispatchQueue.main.async(execute: {
            if codeData == "N"{
                    let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(self.beginTimestamp/1000)))
                    let timeEnd = Calendar.current.date(byAdding: .month, value: 12, to: timeStart as Date)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
                    let expiryStr = formatter.string(from: timeEnd!)
                    let trnStr = formatter.string(from: timeStart as Date)
                    
                    let membershipDict = NSMutableDictionary()
                    membershipDict.setObject(0, forKey: "isMembershipActive" as NSCopying)
                    membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
                    membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
                    membershipDict.setObject("Free_Membership_Yearly", forKey: "productID" as NSCopying)
                    membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
                    
                    let proMembership = ["proMembership":membershipDict]
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
                    ref.child("codes/\(promocode)/").setValue((Auth.auth().currentUser?.uid)!)
                    UserDefaults.standard.set(false, forKey: "isNewUser")
                    UserDefaults.standard.synchronize()
                
                let subDic = NSMutableDictionary()
                subDic.setObject("Free_Membership_Yearly", forKey: "productID" as NSCopying)
                subDic.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
                subDic.setObject("purchase", forKey: "type" as NSCopying)
                let subKey = ref!.child("\(Auth.auth().currentUser!.uid)").childByAutoId().key
                let subscriptionDict = NSMutableDictionary()
                subscriptionDict.setObject(subDic, forKey: subKey as NSCopying)
                ref.child("subscriptions/\(Auth.auth().currentUser!.uid)/").updateChildValues(subscriptionDict as! [AnyHashable : Any])

                if let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProfileProMemberPopUPVC") as? ProfileProMemberPopUPVC{
                    viewCtrl.fromUpgrade = true
                    fromIndiegogo = true
                    viewCtrl.modalPresentationStyle = .overCurrentContext
                    UIApplication.shared.keyWindow?.rootViewController?.present(viewCtrl, animated: true, completion: nil)
                }
//                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Alert", message: "This link is invalid or used", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            })
        }
        
    }
}
