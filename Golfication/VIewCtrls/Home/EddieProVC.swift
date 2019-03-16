//
//  EddieProVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class EddieProVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var eddieScrollView: UIScrollView!
    @IBOutlet weak var superScrollView: UIScrollView!

    @IBOutlet weak var btnNext: UILocalizedButton!
    @IBOutlet weak var btnPrev: UILocalizedButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnEddiePayment: UIButton!

    var currentPageIndex = 0
    var progressView = SDLoader()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = btnEddiePayment.bounds
        gradient.colors = [UIColor(rgb: 0xEB6A2D).cgColor, UIColor(rgb: 0xF5B646).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnEddiePayment.layer.insertSublayer(gradient, at: 0)
        btnEddiePayment.layer.cornerRadius = 20.0
        btnEddiePayment.layer.masksToBounds = true
        
        btnPrev.isHidden = true
        btnNext.setTitle("Next".localized(), for: .normal)
        btnPrev.setTitle("Prev".localized(), for: .normal)
        
        superScrollView.isScrollEnabled = false
        if UIDevice.current.iPhone5 {
          superScrollView.isScrollEnabled = true
        }
        
        checkTrialPreriod()
    }
    
    func checkTrialPreriod(){
        
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "trial") { (snapshot) in
            if(snapshot.value != nil){
                Constants.trial = snapshot.value as! Bool
//                self.lbl30DaysTrial.isHidden = true
            }
            else{
                Constants.trial = false
//                self.lbl30DaysTrial.isHidden = false
            }
            DispatchQueue.main.async( execute: {
                self.progressView.hide(navItem: self.navigationItem)
                
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
    
    @objc func startFetchingDetails(_ notification: NSNotification) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
    }
    @objc func endFetchingDetails(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
    }
    
    @objc func startPaymentRequest(_ notification: NSNotification) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
    }

    @objc func endPaymentRequest(_ notification: NSNotification) {
        
        self.progressView.hide(navItem: self.navigationItem)
        
        let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentCancelled(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
    }
    
    @IBAction func btnEddiePaymentAction(_ sender: Any) {
        
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly, 4->yearly_3Days_39.99, 5->yearly_1Month_39.99
        
        if Constants.trial == true{
            IAPHandler.shared.purchaseMyProduct(index: 4)
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 5)
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
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        btnNext.isHidden = false
        btnPrev.isHidden = false

        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)
        
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        if pageControl.currentPage == 8 {
            btnNext.isHidden = true
            btnPrev.isHidden = false
        }
        else if pageControl.currentPage == 0{
            btnPrev.isHidden = true
            btnNext.isHidden = false
        }
        currentPageIndex = self.pageControl.currentPage
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        btnPrev.isHidden = false

        currentPageIndex = self.pageControl.currentPage + 1
        pageControl.currentPage += 1
        
        let x = CGFloat(pageControl.currentPage) * (eddieScrollView.frame.size.width)
        eddieScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        if currentPageIndex == 8 {
            btnNext.isHidden = true
        }
    }

    @IBAction func btnPrevAction(_ sender: Any) {
        btnNext.isHidden = false
        
        currentPageIndex = self.pageControl.currentPage - 1
        pageControl.currentPage -= 1
        
        let x = CGFloat(pageControl.currentPage) * (eddieScrollView.frame.size.width)
        eddieScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        if currentPageIndex == 0 {
            btnPrev.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func closeAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: false)
    }
}
