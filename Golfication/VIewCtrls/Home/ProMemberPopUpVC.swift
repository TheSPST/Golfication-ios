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
    
    @IBOutlet weak var lbl30DaysTrial: UILabel!

    //    @IBOutlet weak var btnTnC: UIButton!
    
    var progressView = SDLoader()

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
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly, 4->yearly_3Days_39.99, 5->yearly_1Month_39.99

        if Constants.trial == true{
            IAPHandler.shared.purchaseMyProduct(index: 4)
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 5)
        }
    }
    
    @IBAction func monthSubscriptionAction(_ sender: Any) {
        if Constants.trial == true{
            IAPHandler.shared.purchaseMyProduct(index: 0)
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 1)
        }
    }
    
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
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
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        if !(appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Upgrade to Pro".localized()
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
        
        view7Days.layer.cornerRadius = 25.0
        view30Days.layer.cornerRadius = 25.0
        
        cardView1.shadowOffsetHeight = Int(0.5)
        cardView1.shadowOpacity = 0.1
        
        cardView2.shadowOffsetHeight = Int(0.5)
        cardView2.shadowOpacity = 0.1
        
        cardView3.shadowOffsetHeight = Int(0.5)
        cardView3.shadowOpacity = 0.1
        
        //https://www.dribba.com/uiscrollview-and-autolayout-with-ios8-and-swift/
        scrollView.delegate = self
        
        checkTrialPreriod()

    }
    
    func checkTrialPreriod(){
        btnMonthly.isEnabled = false
        btnYearly.isEnabled = false

        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "trial") { (snapshot) in
            if(snapshot.value != nil){
                Constants.trial = snapshot.value as! Bool
                self.lbl30DaysTrial.isHidden = true
            }
            else{
                Constants.trial = false
                self.lbl30DaysTrial.isHidden = false
            }
            DispatchQueue.main.async( execute: {
                self.progressView.hide(navItem: self.navigationItem)

                self.btnMonthly.isEnabled = true
                self.btnYearly.isEnabled = true

                NotificationCenter.default.addObserver(self, selector: #selector(self.startPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.endPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.paymentCancelled(_:)), name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)

                NotificationCenter.default.addObserver(self, selector: #selector(self.startFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.endFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
                
                IAPHandler.shared.fetchAvailableProducts()
                IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
                    guard let strongSelf = self else{ return }
                    if type == .purchased {
                        let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                        alertView.addAction(action)
                        strongSelf.present(alertView, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }
    
    @objc func startFetchingDetails(_ notification: NSNotification) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        btnMonthly.isEnabled = false
        btnYearly.isEnabled = false
    }
    @objc func endFetchingDetails(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
        btnMonthly.isEnabled = true
        btnYearly.isEnabled = true
    }
    
    @objc func startPaymentRequest(_ notification: NSNotification) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        btnMonthly.isEnabled = false
        btnYearly.isEnabled = false
    }
    
    @objc func endPaymentRequest(_ notification: NSNotification) {
        
        self.progressView.hide(navItem: self.navigationItem)
        btnMonthly.isEnabled = true
        btnYearly.isEnabled = true
        
        let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func paymentCancelled(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
        btnMonthly.isEnabled = true
        btnYearly.isEnabled = true
    }
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        self.pageControl.currentPage = Int(currentPage)
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 10)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        if pageControl.currentPage == 0 {
        }
        else if pageControl.currentPage == 1 {
        }
        else if pageControl.currentPage == 2 {
        }
            
    }
}

