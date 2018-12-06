//
//  RefreshSubscriptionManager.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://stackoverflow.com/questions/50779564/call-a-function-one-time-per-day-at-a-specific-time-swift

import UIKit
import SwiftyStoreKit
import FirebaseAuth

class RefreshSubscriptionManager: NSObject {
    
    static let shared = RefreshSubscriptionManager()
    private let defaults = UserDefaults.standard
    private let defaultsKey = "lastRefresh"
    private let calender = Calendar.current
    private var firTimeEnd:Date!
    
    func loadDataIfNeeded(completion: (Bool) -> Void) {
        // load the data
        checkSubscriptionFromFirebase()
        
        if isRefreshRequired() {
            defaults.set(Date(), forKey: defaultsKey)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func checkSubscriptionFromFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMembership") { (snapshot) in
            
            if(snapshot.childrenCount > 0){
                var proData = NSDictionary()
                proData = snapshot.value as! NSDictionary
                if let expTimestamp = proData.value(forKey: "timestamp") as? Int{
                    
                    let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(expTimestamp/1000)))
                    self.firTimeEnd = Calendar.current.date(byAdding: .day, value: 365, to: timeStart as Date)
                    if proData.value(forKey: "productID") as? String != nil{
                        if (proData.value(forKey: "productID") as! String == Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID) || (proData.value(forKey: "productID") as! String == Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID) || (proData.value(forKey: "productID") as! String == Constants.FREE_MONTHLY_PRODUCT_ID){
                            
                            self.firTimeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
                        }
                    }
                    debugPrint("self.firTimeEnd==",self.firTimeEnd)
                }
            }
            DispatchQueue.main.async( execute: {
                self.receiptValidationUsingSwifty()
            })
        }
    }
    private func isRefreshRequired() -> Bool {
        
        guard let lastRefreshDate = defaults.object(forKey: defaultsKey) as? Date else {
            return true
        }
        
        if let diff = calender.dateComponents([.hour], from: lastRefreshDate, to: Date()).hour, diff > 24 {
            return true
        } else {
            return false
        }
    }
    
    func receiptValidationUsingSwifty(){
//        let AUTO_RENEW_MONTHLY_PRODUCT_ID = "pro_subscription_monthly"
//        let AUTO_RENEW_YEARLY_PRODUCT_ID = "pro_subscription_yearly"
        
//        let AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID = "pro_subscription_trial_monthly"
//        let AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID = "pro_subscription_trial_yearly"
        
        let productIDarr = [Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID, Constants.AUTO_RENEW_YEARLY_PRODUCT_ID, Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID, Constants.AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID]
        for data in productIDarr{
            SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                switch result {
                case .success(let receiptData):
                    let encryptedReceipt = receiptData.base64EncodedString(options: [])
                    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
                    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                        switch result {
                        case .success(let receipt):
                            // Verify the purchase of a Subscription
                            let purchaseResult = SwiftyStoreKit.verifySubscription(type: .autoRenewable,productId: data,inReceipt: receipt)
                            switch purchaseResult {
                                
                            //if Product is Purchased & trial is true or false
                            case .purchased(let expiryDate, let items):
                                
                                debugPrint("\(data) is valid until \(expiryDate)\n\(items.first!)\n")
                                
                                if(Auth.auth().currentUser!.uid.count > 1){
                                    
                                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["trial" :NSNull()] as [AnyHashable:Any])
                                    Constants.trial = false
                                    if items.first!.isTrialPeriod == false{
                                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["trial" :true] as [AnyHashable:Any])
                                        Constants.trial = true
                                    }
                                    
                                    if self.firTimeEnd != nil{
                                        
                                        if self.firTimeEnd! < expiryDate{
                                            
                                            if items.first!.cancellationDate != nil{
                                                
                                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :false] as [AnyHashable:Any])
                                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMembership" :NSNull()] as [AnyHashable:Any])
                                                Constants.isProMode = false
                                            }
                                            else{
                                                let formatter = DateFormatter()
                                                formatter.locale = Locale(identifier: "en")
                                                formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"

                                                let expiryStr = formatter.string(from: expiryDate)
                                                debugPrint("expiryStr",expiryStr)
                                                
                                                let pf = DateFormatter()
                                                pf.locale = Locale(identifier: "en")
                                                pf.dateFormat = "dd-MMM-yyyy  HH:mm:ss"

                                                let purchaseStr = pf.string(from: items.first!.purchaseDate)
                                                debugPrint("purchaseStr",purchaseStr)
                                                
                                                let timeInterval = items.first!.purchaseDate.timeIntervalSince1970 * 1000
                                                let myTimestamp = Int64(timeInterval)
                                                debugPrint("myTimestamp",myTimestamp)
                                                
                                                let mydate = NSDate(timeIntervalSince1970:TimeInterval((myTimestamp)/1000))
                                                debugPrint("mydate",mydate)
                                                
                                                let membershipDict = NSMutableDictionary()
                                                membershipDict.setObject(1, forKey: "isMembershipActive" as NSCopying)
                                                membershipDict.setObject(myTimestamp, forKey: "timestamp" as NSCopying)
                                                membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
                                                membershipDict.setObject(purchaseStr, forKey: "transactionDate" as NSCopying)
                                                membershipDict.setObject(items.first!.productId, forKey: "productID" as NSCopying)
                                                membershipDict.setObject("ios", forKey: "device" as NSCopying)
                                                
                                                let proMembership = ["proMembership":membershipDict]
                                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
                                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
                                                
                                            }
                                        }
                                    }
                                }
                            //if Product is expired & trial is true or false
                            case .expired(let expiryDate, let items):
                                debugPrint("\(data) is expired since \(expiryDate)\n\(items.first!.isTrialPeriod)\n")
                                debugPrint("\(data) is expired since \(expiryDate)\n\(items.last!)\n")
                                
                            //if Product is not purchased yet
                            case .notPurchased:
                                debugPrint("The user has never purchased \(data)")
                            }
                        case .error(let error):
                            debugPrint("Receipt verification failed: \(error)")
                        }
                    }
                    debugPrint("Fetch receipt success:\n\(encryptedReceipt)")
                case .error(let error):
                    debugPrint("Fetch receipt failed: \(error)")
                }
            }
        }
    }
}
