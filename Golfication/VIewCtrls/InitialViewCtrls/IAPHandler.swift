//
//  IAPHelper.swift
//  Golfication
//
//  Created by Rishabh Sood on 24/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://hackernoon.com/swift-how-to-add-in-app-purchases-in-your-ios-app-c1dc2fc82319
import UIKit
import StoreKit
import FirebaseAuth

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
            //      case .restored: return "You've successfully restored your purchase!"
        //      case .purchased: return "You've successfully bought this purchase!"
        case .restored: return "Congratulations! Your Pro MemberShip is now Active"
        case .purchased: return "Congratulations! Your Pro MemberShip is now Active"
        }
    }
}


class IAPHandler: NSObject {
    static let shared = IAPHandler()
    
//    let AUTO_RENEW_MONTHLY_PRODUCT_ID = "pro_subscription_monthly"
//    let AUTO_RENEW_YEARLY_PRODUCT_ID = "pro_subscription_yearly"
    
//    let AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID = "pro_subscription_trial_monthly"
//    let AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID = "pro_subscription_trial_yearly"
    
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(index: Int){
        if iapProducts.count == 0 { return }
        if self.canMakePurchases() {
            NetworkActivityIndicatorManager.NetworkOperationStarted()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
            
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
            debugPrint("productID==",productID)
            
        }
        else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID, Constants.AUTO_RENEW_YEARLY_PRODUCT_ID, Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID, Constants.AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID, Constants.AUTO_RENEW_TRIAL_3_DAYS_PRODUCT_ID,Constants.AUTO_RENEW_TRIAL_1_MONTH_PRODUCT_ID, Constants.AUTO_RENEW_EDDIE_MONTHLY_PRODUCT_ID, Constants.AUTO_RENEW_EDDIE_YEARLY_PRODUCT_ID)

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        debugPrint("productIdentifiers==",productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                debugPrint(product.productIdentifier + product.localizedDescription + "\nfor just \(price1Str!)")
            }
        }
        
        NetworkActivityIndicatorManager.NetworkOperationFinished()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    // print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    
                    // --------- Send Data to Firebase -----------
                    if(Auth.auth().currentUser!.uid.count > 1){
                        
                        let dateNow = NSDate(timeIntervalSince1970: (TimeInterval(beginTimestamp/1000)))

                        var date = Date()
                        let calendar = Calendar.current
                        if productID == Constants.AUTO_RENEW_MONTHLY_PRODUCT_ID || productID == Constants.AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID || productID == Constants.AUTO_RENEW_EDDIE_MONTHLY_PRODUCT_ID{
                            date = calendar.date(byAdding: .day, value: 30, to: dateNow as Date)!
                        }
                        else{
                            date = calendar.date(byAdding: .month, value: 12, to: dateNow as Date)!
                        }
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en")
                        formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"

                        let expiryStr = formatter.string(from: date)
                        
                        let formatter2 = DateFormatter()
                        formatter2.locale = Locale(identifier: "en")
                        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"

                        let myString2 = formatter2.string(from: (transaction.transactionDate)!!)
                        let yourDate2 = formatter2.date(from: myString2)
                        formatter2.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
                        let trnStr = formatter2.string(from: yourDate2!)
                        
//                        if productID == Constants.AUTO_RENEW_TRIAL_3_DAYS_PRODUCT_ID || productID == Constants.AUTO_RENEW_TRIAL_1_MONTH_PRODUCT_ID{
//                            productID = Constants.AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID
//                        }
                        
                        let membershipDict = NSMutableDictionary()
                        membershipDict.setObject(1, forKey: "isMembershipActive" as NSCopying)
                        membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
                        membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
                        membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
                        //membershipDict.setObject(transaction.transactionIdentifier, forKey: "transactionId" as NSCopying)
                        membershipDict.setObject(productID, forKey: "productID" as NSCopying)
                        membershipDict.setObject("ios", forKey: "device" as NSCopying)

                        let proMembership = ["proMembership":membershipDict]
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
                        
                        let subDic = NSMutableDictionary()
                        subDic.setObject(productID, forKey: "productID" as NSCopying)
                        subDic.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
                        subDic.setObject("purchase", forKey: "type" as NSCopying)
                        let subKey = ref!.child("\(Auth.auth().currentUser!.uid)").childByAutoId().key
                        let subscriptionDict = NSMutableDictionary()
                        subscriptionDict.setObject(subDic, forKey: subKey as NSCopying)
                        ref.child("subscriptions/\(Auth.auth().currentUser!.uid)/").updateChildValues(subscriptionDict as! [AnyHashable : Any])

                        NetworkActivityIndicatorManager.NetworkOperationFinished()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
                        Constants.isProfileUpdated = true
                    }
                    
                    break
                    
                case .failed:
                    //  print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    NetworkActivityIndicatorManager.NetworkOperationFinished()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)
                    break
                case .restored:
                    //  print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970) * 1000
    }
}

