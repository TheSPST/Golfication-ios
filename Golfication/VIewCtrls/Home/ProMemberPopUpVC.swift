//
//  ProMemberPopUpVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import FirebaseAnalytics

//var sharedSecret = "79d35d5b3b684c84ba4302a33d498a47"
var attrs = [
    //    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 19.0),
    //    NSAttributedStringKey.foregroundColor : UIColor.red,
    NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
var attributedString = NSMutableAttributedString(string:"")

class NetworkActivityIndicatorManager:NSObject{
    private static var loadingCount = 0
    
    class func NetworkOperationStarted(){
        if(loadingCount == 0){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func NetworkOperationFinished(){
        if(loadingCount > 0){
            loadingCount -= 1
        }
        if(loadingCount == 0){
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
}

class ProMemberPopUpVC: UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.pop()
    }
    @IBOutlet weak var cardView1: CardView!
    @IBOutlet weak var cardView2: CardView!
    @IBOutlet weak var cardView3: CardView!
    //@IBOutlet weak var cardView4: CardView!
    //@IBOutlet weak var cardView5: CardView!
//    @IBOutlet weak var cardView6: CardView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblDexcriptions: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnTnC: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    @IBOutlet weak var btnYearly: UIButton!
    
    @IBOutlet weak var view7Days: UIView!
    @IBOutlet weak var view30Days: UIView!
    //    @IBOutlet weak var btnTnC: UIButton!
    
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    
    @IBAction func privacyPolicyAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/privacypolicy.htm"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false

        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func termsAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/terms-of-service.html"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @IBAction func yearSubscriptionAction(_ sender: Any) {
        IAPHandler.shared.purchaseMyProduct(index: 1)
        
        /*self.actvtIndView.isHidden = false
         self.actvtIndView.startAnimating()
         
         let productId = "pro_subscription_yearly"
         SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
         NetworkActivityIndicatorManager.NetworkOperationStarted()
         
         if case .success(let purchase) = result {
         // Deliver content from server, then:
         if purchase.needsFinishTransaction {
         SwiftyStoreKit.finishTransaction(purchase.transaction)
         }
         
         let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
         SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
         
         if case .success(let receipt) = result {
         NetworkActivityIndicatorManager.NetworkOperationFinished()
         self.actvtIndView.isHidden = true
         self.actvtIndView.stopAnimating()
         
         let purchaseResult = SwiftyStoreKit.verifySubscription(
         type: .autoRenewable,
         productId: productId,
         inReceipt: receipt)
         
         switch purchaseResult {
         case .purchased(let expiryDate, let receiptItems):
         print("Product is valid until \(expiryDate)")
         if(UID!.count > 1){
         ref.child("userData/\(UID!)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
         //                                ref.child("userData/\(UID!)/proMembership/").updateChildValues(["isMembershipActive":1])
         
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let myString = formatter.string(from: expiryDate)
         let yourDate = formatter.date(from: myString)
         formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
         let myStringafd = formatter.string(from: yourDate!)
         
         let formatter2 = DateFormatter()
         formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let myString2 = formatter2.string(from: purchase.transaction.transactionDate!)
         let yourDate2 = formatter2.date(from: myString2)
         formatter2.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
         let myStringafd1 = formatter2.string(from: yourDate2!)
         
         let membershipDict = NSMutableDictionary()
         membershipDict.setObject(1, forKey: "isMembershipActive" as NSCopying)
         membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
         membershipDict.setObject(myStringafd, forKey: "expiryDate" as NSCopying)
         membershipDict.setObject(myStringafd1, forKey: "transactionDate" as NSCopying)
         membershipDict.setObject(purchase.transaction.transactionIdentifier!, forKey: "transactionId" as NSCopying)
         membershipDict.setObject(purchase.productId, forKey: "productId" as NSCopying)
         
         let proMembership = ["proMembership":membershipDict]
         ref.child("userData/\(UID!)/").updateChildValues(proMembership)
         }
         self.backAction()
         
         case .expired(let expiryDate, let receiptItems):
         print("Product is expired since \(expiryDate)")
         case .notPurchased:
         print("This product has never been purchased")
         }
         
         } else {
         
         }
         }
         } else {
         
         }
         }*/
    }
    
    @IBAction func monthSubscriptionAction(_ sender: Any) {
        
        IAPHandler.shared.purchaseMyProduct(index: 0)
        
        /*self.actvtIndView.isHidden = false
         self.actvtIndView.startAnimating()
         
         let productId = "pro_subscription_monthly"
         SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
         NetworkActivityIndicatorManager.NetworkOperationStarted()
         
         if case .success(let purchase) = result {
         // Deliver content from server, then:
         if purchase.needsFinishTransaction {
         SwiftyStoreKit.finishTransaction(purchase.transaction)
         }
         
         let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
         SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
         
         if case .success(let receipt) = result {
         NetworkActivityIndicatorManager.NetworkOperationFinished()
         self.actvtIndView.isHidden = true
         self.actvtIndView.stopAnimating()
         
         let purchaseResult = SwiftyStoreKit.verifySubscription(
         type: .autoRenewable,
         productId: productId,
         inReceipt: receipt)
         
         switch purchaseResult {
         case .purchased(let expiryDate, let receiptItems):
         debugPrint("Product is valid until \(expiryDate)\(receiptItems)")
         if(UID!.count > 1){
         ref.child("userData/\(UID!)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
         
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let myString = formatter.string(from: expiryDate)
         let yourDate = formatter.date(from: myString)
         formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
         let myStringafd = formatter.string(from: yourDate!)
         
         let formatter2 = DateFormatter()
         formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let myString2 = formatter2.string(from: purchase.transaction.transactionDate!)
         let yourDate2 = formatter2.date(from: myString2)
         formatter2.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
         let myStringafd1 = formatter2.string(from: yourDate2!)
         
         let membershipDict = NSMutableDictionary()
         membershipDict.setObject(1, forKey: "isMembershipActive" as NSCopying)
         membershipDict.setObject(self.beginTimestamp, forKey: "timestamp" as NSCopying)
         membershipDict.setObject(myStringafd, forKey: "expiryDate" as NSCopying)
         membershipDict.setObject(myStringafd1, forKey: "transactionDate" as NSCopying)
         membershipDict.setObject(purchase.transaction.transactionIdentifier!, forKey: "transactionId" as NSCopying)
         membershipDict.setObject(purchase.productId, forKey: "productId" as NSCopying)
         debugPrint("productId \(productId))")
         
         let proMembership = ["proMembership":membershipDict]
         ref.child("userData/\(UID!)/").updateChildValues(proMembership)
         }
         self.backAction()
         
         case .expired(let expiryDate, let receiptItems):
         debugPrint("Product is expired since \(expiryDate)\(receiptItems)")
         case .notPurchased:
         debugPrint("This product has never been purchased")
         }
         
         } else {
         
         }
         }
         } else {
         
         }
         }*/
    }
    
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    func backAction() {
        
        let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pop(transitionType: kCATransitionFromTop, duration: 0.2)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var descTitleLabel: UILabel!
    
    var usrImageView: UIImageView!
    
    var contentWidth:CGFloat = 0.0
    
    
    var attrs = [
        NSAttributedStringKey.font : UIFont(name: "SFProDisplay-Regular", size: 15.0)!,
        NSAttributedStringKey.foregroundColor : UIColor(rgb: 0x007AFF),
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    
    var attributedString = NSMutableAttributedString(string:"")
    var attributedString1 = NSMutableAttributedString(string:"")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ----------------- Event Tracking ---------------------------------
        
        Analytics.logEvent("premium_popup", parameters: [:])
        // -------------------------------------------------------------------------
        
        let btnTnCTitle = NSMutableAttributedString(string:(btnTnC.titleLabel?.text)!, attributes:attrs)
        attributedString.append(btnTnCTitle)
        btnTnC.setAttributedTitle(attributedString, for: .normal)
        
        let btnPrivacyTitle = NSMutableAttributedString(string:(btnPrivacy.titleLabel?.text)!, attributes:attrs)
        attributedString1.append(btnPrivacyTitle)
        btnPrivacy.setAttributedTitle(attributedString1, for: .normal)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        closeBtn.setCircle(frame: closeBtn.frame)
        //        let buttonTitleStr = NSMutableAttributedString(string:"Terms & Conditions", attributes:attrs)
        //        attributedString.append(buttonTitleStr)
        //        btnTnC.setAttributedTitle(attributedString, for: .normal)
        
        view7Days.layer.cornerRadius = 25.0
        view30Days.layer.cornerRadius = 25.0
        
        cardView1.shadowOffsetHeight = Int(0.5)
        cardView1.shadowOpacity = 0.1
        
        cardView2.shadowOffsetHeight = Int(0.5)
        cardView2.shadowOpacity = 0.1
        
        cardView3.shadowOffsetHeight = Int(0.5)
        cardView3.shadowOpacity = 0.1
        
        //        cardView4.shadowOffsetHeight = Int(0.5)
        //        cardView4.shadowOpacity = 0.1
        //
        //        cardView5.shadowOffsetHeight = Int(0.5)
        //        cardView5.shadowOpacity = 0.1
        
//        cardView6.shadowOffsetHeight = Int(0.5)
//        cardView6.shadowOpacity = 0.1
        
        //https://www.dribba.com/uiscrollview-and-autolayout-with-ios8-and-swift/
        scrollView.delegate = self
        
        /*titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: (self.view.frame.size.width)-20, height: 25))
         //titleLabel.text = "Subscribe to Golfication Pro"
         titleLabel.textAlignment = .center
         titleLabel.font = UIFont(name: "SFProDisplay-Medium", size: 21.0)
         titleLabel.textColor = UIColor.white
         titleLabel.backgroundColor = UIColor.clear
         
         usrImageView = UIImageView(frame: CGRect(x: 50+40, y: titleLabel.frame.origin.y + titleLabel.frame.size.height+10, width: self.view.frame.size.width-40-40-40-40, height: self.view.frame.size.width-40-40-50-40))
         usrImageView.backgroundColor = UIColor.clear
         usrImageView.contentMode = .scaleAspectFit
         
         subTitleLabel = UILabel(frame: CGRect(x: 20, y: usrImageView.frame.origin.y + usrImageView.frame.size.height+5, width: (self.view.frame.size.width)-40-20, height: 40))
         subTitleLabel.numberOfLines = 1
         subTitleLabel.textAlignment = .center
         subTitleLabel.font = UIFont(name: "SFProDisplay-Medium", size: 19.0)
         subTitleLabel.textColor = UIColor.white
         subTitleLabel.backgroundColor = UIColor.clear
         
         descTitleLabel = UILabel(frame: CGRect(x: 20, y: subTitleLabel.frame.origin.y + subTitleLabel.frame.size.height-10, width: (self.view.frame.size.width)-40-20, height: 40))
         descTitleLabel.numberOfLines = 2
         descTitleLabel.textAlignment = .center
         descTitleLabel.font = UIFont(name: "SFProDisplay-Regular", size: 13.0)
         descTitleLabel.textColor = UIColor.white
         descTitleLabel.backgroundColor = UIColor.clear
         
         
         //subTitleLabel.text = "Advance Stats"
         //descTitleLabel.text = "Distance, range and accuracy for all your clubs"
         // usrImageView.image = #imageLiteral(resourceName: "Advancedstats")
         
         cardView1.addSubview(titleLabel)
         cardView1.addSubview(descTitleLabel)
         cardView1.addSubview(usrImageView)
         cardView1.addSubview(subTitleLabel)*/
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.endPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.endFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
        
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.navigationController?.popViewController(animated: false)
                    self?.navigationController?.pop(transitionType: kCATransitionFromTop, duration: 0.2)
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }
    
    @objc func startFetchingDetails(_ notification: NSNotification) {
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        btnMonthly.isEnabled = false
        btnYearly.isEnabled = false
    }
    @objc func endFetchingDetails(_ notification: NSNotification) {
        self.actvtIndView.isHidden = true
        self.actvtIndView.stopAnimating()
        btnMonthly.isEnabled = true
        btnYearly.isEnabled = true
    }
    
    @objc func startPaymentRequest(_ notification: NSNotification) {
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        btnMonthly.isEnabled = false
        btnYearly.isEnabled = false
    }
    
    @objc func endPaymentRequest(_ notification: NSNotification) {
        self.actvtIndView.isHidden = true
        self.actvtIndView.stopAnimating()
        btnMonthly.isEnabled = true
        btnYearly.isEnabled = true
        
        //self.navigationController?.popToRootViewController(animated: true)
        // self.navigationController?.popViewController(animated: false)
        //self.navigationController?.pop(transitionType: kCATransitionFromTop, duration: 0.2)
    }
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        //float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
        
        //        titleLabel.removeFromSuperview()
        //        subTitleLabel.removeFromSuperview()
        //        usrImageView.removeFromSuperview()
        
        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        self.pageControl.currentPage = Int(currentPage)
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 10)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        if pageControl.currentPage == 0 {
            // subTitleLabel.text = "Advance Stats"
            //descTitleLabel.text = "Distance, range and accuracy for all your clubs"
            // usrImageView.image = #imageLiteral(resourceName: "Advancedstats")
            
            // cardView1.addSubview(titleLabel)
            // cardView1.addSubview(subTitleLabel)
            // cardView1.addSubview(descTitleLabel)
            // cardView1.addSubview(usrImageView)
        }
        else if pageControl.currentPage == 1 {
            //            titleLabel.text = "The Ultimate Golf Hack"
            // subTitleLabel.text = "Club Selection & Control"
            // descTitleLabel.text = "Know which clubs you need to hit often, and which you'd better leave out."
            //  usrImageView.image = #imageLiteral(resourceName: "controlPro")
            
            //cardView2.addSubview(titleLabel)
            //   cardView2.addSubview(subTitleLabel)
            //  cardView2.addSubview(descTitleLabel)
            //  cardView2.addSubview(usrImageView)
        }
        else if pageControl.currentPage == 2 {
            //   subTitleLabel.text = "Super Early-Bird Discount"
            //   descTitleLabel.text = "Get a $100 pre-order discount coupon for Golf's most powerful wearable on launch day"
            //    usrImageView.image = #imageLiteral(resourceName: "device1")
            
            //    cardView3.addSubview(titleLabel)
            //     cardView3.addSubview(subTitleLabel)
            //   cardView3.addSubview(descTitleLabel)
            //     cardView3.addSubview(usrImageView)
        }
            
        /*else if pageControl.currentPage == 3 {
            //            subTitleLabel.text = "Strokes Gained Analysis"
            //            descTitleLabel.text = "Break down each selection of your game, to better plan your training sessions."
            //            usrImageView.image = #imageLiteral(resourceName: "sg")
            //
            //            cardView6.addSubview(titleLabel)
            //            cardView6.addSubview(subTitleLabel)
            //            cardView6.addSubview(descTitleLabel)
            //            cardView6.addSubview(usrImageView)
        }*/
    }
}

