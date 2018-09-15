//
//  HomeFreeProMemberVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 24/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeFreeProMemberVC: UIViewController, UIScrollViewDelegate {
    
    // MARK: – Set Outlets
    @IBOutlet weak var closeBtn: UIButton!
    
//    @IBOutlet weak var lblPricePerMonth: UILabel!
    @IBOutlet weak var cardView1: CardView!
    @IBOutlet weak var cardView2: CardView!
    @IBOutlet weak var cardView3: CardView!
    @IBOutlet weak var cardView4: CardView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewUpgradeTrial: UIView!
    @IBOutlet weak var viewJoinBtnContainer: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblCongrats: UILabel!
    @IBOutlet weak var btnMonthly:UIButton!
    @IBOutlet weak var btnYearly:UIButton!
    @IBOutlet weak var viewOneYear:UIView!
    @IBOutlet weak var viewOneMonth:UIView!

    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!

    // MARK: – Set Variables
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var descTitleLabel: UILabel!
    var usrImageView: UIImageView!
    
    var fromUpgrade = Bool()
    var fromNewUserPopUp = Bool()
    
    // MARK: – closeAction
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func monthlyAction(_ sender: Any) {
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly
        IAPHandler.shared.purchaseMyProduct(index: 1)
    }
    @IBAction func yearlyAction(_ sender: Any) {
        IAPHandler.shared.purchaseMyProduct(index: 2)
    }
    
    func setUpIAPHandler() {
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
                    self?.dismiss(animated: true, completion: nil)
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
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

        viewUpgradeTrial.isHidden = false
        viewJoinBtnContainer.isHidden = true
        
        UserDefaults.standard.set(false, forKey: "isNewUser")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }

    // MARK: – viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        setUpIAPHandler()

        viewUpgradeTrial.isHidden = true
        lblCongrats.text = "Your 30 days free trial has been activated"
        
        viewOneYear.layer.cornerRadius = 25.0
        viewOneMonth.layer.cornerRadius = 25.0

        closeBtn.setCircle(frame: closeBtn.frame)
        
        cardView1.shadowOffsetHeight = Int(0.5)
        cardView1.shadowOpacity = 0.1
        
        cardView2.shadowOffsetHeight = Int(0.5)
        cardView2.shadowOpacity = 0.1
        
        cardView3.shadowOffsetHeight = Int(0.5)
        cardView3.shadowOpacity = 0.1
        
        cardView4.shadowOffsetHeight = Int(0.5)
        cardView4.shadowOpacity = 0.1
        
        //https://www.dribba.com/uiscrollview-and-autolayout-with-ios8-and-swift/
        scrollView.delegate = self
    }
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)
        
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 10)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
    }
}
