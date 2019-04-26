//
//  EddieProVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class EddieProVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var eddieScrollView: UIScrollView!
    @IBOutlet weak var superScrollView: UIScrollView!

    @IBOutlet weak var btnNext: UILocalizedButton!
    @IBOutlet weak var btnPrev: UILocalizedButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var btnEddiePayment: UIButton!
    @IBOutlet weak var btnYearlyPayment: UIButton!
    @IBOutlet weak var btnMonthlyPayment: UIButton!
    @IBOutlet weak var getEddieView: CardView!
    @IBOutlet weak var smartCaddieView: CardView!
    @IBOutlet weak var windSpeedView: CardView!
    
    @IBOutlet weak var eddieImgHCons: NSLayoutConstraint!
    @IBOutlet weak var windImgHCons: NSLayoutConstraint!
    @IBOutlet weak var elevImgHCons: NSLayoutConstraint!
    @IBOutlet weak var goalImgHCons: NSLayoutConstraint!
    @IBOutlet weak var notesImgHCons: NSLayoutConstraint!
    @IBOutlet weak var recClubImgHCons: NSLayoutConstraint!
    @IBOutlet weak var distanceImgHCons: NSLayoutConstraint!
    @IBOutlet weak var clubStatsImgHCons: NSLayoutConstraint!
    @IBOutlet weak var sgStatsImgHCons: NSLayoutConstraint!

    var source = String()
    @IBOutlet weak var topContra: NSLayoutConstraint!
    @IBOutlet weak var bottomPadd: NSLayoutConstraint!
    var currentPageIndex = 0
    var isProgress = false
    var eddieView = NSMutableDictionary()
    var progressView = SDLoader()
    override func viewDidLoad() {
        super.viewDidLoad()
        FBSomeEvents.shared.logInitiateCheckoutEvent()
        let gradient = CAGradientLayer()
        gradient.frame = btnEddiePayment.bounds
        gradient.colors = [UIColor(rgb: 0xEB6A2D).cgColor, UIColor(rgb: 0xF5B646).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnEddiePayment.layer.insertSublayer(gradient, at: 0)
        btnEddiePayment.layer.cornerRadius = 20.0
        btnEddiePayment.layer.masksToBounds = true
        let gradient1 = CAGradientLayer()
        gradient1.frame = btnYearlyPayment.bounds
        gradient1.colors = [UIColor(rgb: 0x2E6594).cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient1.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient1.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnYearlyPayment.layer.insertSublayer(gradient1, at: 0)
        btnYearlyPayment.layer.cornerRadius = 20.0
        btnYearlyPayment.layer.masksToBounds = true

        let gradient2 = CAGradientLayer()
        gradient2.frame = btnMonthlyPayment.bounds
        gradient2.colors = [UIColor(rgb: 0x2E6594).cgColor, UIColor(rgb: 0x2C4094).cgColor]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient1.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnMonthlyPayment.layer.insertSublayer(gradient2, at: 0)
        btnMonthlyPayment.layer.cornerRadius = 20.0
        btnMonthlyPayment.layer.masksToBounds = true

        btnPrev.isHidden = true
        btnNext.setTitle("See How >".localized(), for: .normal)
        btnPrev.setTitle("Prev".localized(), for: .normal)
        
        let colorTop =  UIColor(rgb:0xECF6FB).cgColor
        let colorBottom = UIColor.white.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width-40, height: self.getEddieView.frame.size.height-40)
        self.getEddieView.layer.insertSublayer(gradientLayer, at: 0)
        getEddieView.layer.masksToBounds = true

        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.colors = [colorTop, colorBottom]
        gradientLayer1.locations = [0.0, 1.0]
        gradientLayer1.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width-40, height: self.smartCaddieView.frame.size.height-40)
        self.smartCaddieView.layer.insertSublayer(gradientLayer1, at: 0)
        smartCaddieView.layer.masksToBounds = true
        if UIDevice.current.iPhoneX || UIDevice.current.iPhoneXR || UIDevice.current.iPhoneXSMax{
//            pageControl.heightConst(50)
//            bottomPadd.constant = 30.0
//            topContra.constant = 30.0
        }
        setImageRatio()
        checkTrialPreriod()
        self.eddieView.setValue(source, forKey: "source")
        self.eddieView.setValue(true, forKey: "screen\(currentPageIndex+1)")
        FBSomeEvents.shared.singleParamFBEvene(param: "View Eddie \(currentPageIndex+1))")
        self.eddieView.setValue(Auth.auth().currentUser!.displayName, forKey: "name")
        
        //setUpScrol()
    }
    
    func setImageRatio(){
        
        // Set Eddie Image
        let eddieImage = UIImage(named: "big_eddie")!
        let eddieRatio = eddieImage.size.width / eddieImage.size.height
        let eddieNewHeight = self.view.frame.size.width-20-40 / eddieRatio

        // Set Wind  Speed Image
        let image = UIImage(named: "windSpeed")!
        let ratio = image.size.width / image.size.height
        let newHeight = self.view.frame.size.width-20 / ratio
        
        // Set Elevation Image
        let elevImage = UIImage(named: "courseElecations")!
        let elevRatio = elevImage.size.width / elevImage.size.height
        let elevNewHeight = self.view.frame.size.width-20 / elevRatio
        
        // Set Goals Image
        let goalImage = UIImage(named: "yourGoals")!
        let goalRatio = goalImage.size.width / goalImage.size.height
        let goalNewHeight = self.view.frame.size.width-20 / goalRatio
        
        // Set Notes Image
        let notesImage = UIImage(named: "takeNotes")!
        let notesRatio = notesImage.size.width / notesImage.size.height
        let notesNewHeight = self.view.frame.size.width-20 / notesRatio
        
        // Set Recommended Club Image
        let recClubImage = UIImage(named: "recBestClub")!
        let recClubRatio = recClubImage.size.width / recClubImage.size.height
        let recClubNewHeight = self.view.frame.size.width-20 / recClubRatio
        
        // Set distance Image
        let distanceImage = UIImage(named: "voiceAssitance")!
        let distanceRatio = distanceImage.size.width / distanceImage.size.height
        let distanceNewHeight = self.view.frame.size.width-20 / distanceRatio
        
        // Set club Stats Image
        let clubStatsImage = UIImage(named: "gameClubStats")!
        let clubStatsRatio = clubStatsImage.size.width / clubStatsImage.size.height
        let clubStatsNewHeight = self.view.frame.size.width-20 / clubStatsRatio
        
        // Set SG Stats Image
        let sgStatsImage = UIImage(named: "sgStats")!
        let sgStatsRatio = sgStatsImage.size.width / sgStatsImage.size.height
        let sgStatsNewHeight = self.view.frame.size.width-20 / sgStatsRatio
        
        eddieImgHCons.constant = eddieNewHeight
        if UIDevice.current.iPhoneSE{
            windImgHCons.constant = newHeight - 50
            elevImgHCons.constant = elevNewHeight - 48
            goalImgHCons.constant = goalNewHeight - 50
            notesImgHCons.constant = notesNewHeight - 50
            recClubImgHCons.constant = recClubNewHeight - 50
            distanceImgHCons.constant = distanceNewHeight - 50
            clubStatsImgHCons.constant = clubStatsNewHeight - 50
            sgStatsImgHCons.constant = sgStatsNewHeight - 50
        }
        else if UIDevice.current.iPhone || UIDevice.current.iPhoneX{
            windImgHCons.constant = newHeight - 55
            elevImgHCons.constant = elevNewHeight - 53
            goalImgHCons.constant = goalNewHeight - 55
            notesImgHCons.constant = notesNewHeight - 55
            recClubImgHCons.constant = recClubNewHeight - 55
            distanceImgHCons.constant = distanceNewHeight - 55
            clubStatsImgHCons.constant = clubStatsNewHeight - 55
            sgStatsImgHCons.constant = sgStatsNewHeight - 55
        }
        else if UIDevice.current.iPhonePlus ||  UIDevice.current.iPhoneXR || UIDevice.current.iPhoneXSMax{
            windImgHCons.constant = newHeight - 59
            elevImgHCons.constant = elevNewHeight - 57
            goalImgHCons.constant = goalNewHeight - 59
            notesImgHCons.constant = notesNewHeight - 59
            recClubImgHCons.constant = recClubNewHeight - 59
            distanceImgHCons.constant = distanceNewHeight - 59
            clubStatsImgHCons.constant = clubStatsNewHeight - 59
            sgStatsImgHCons.constant = sgStatsNewHeight - 59
        }
    }
    func setUpScrol(){
        //https://stackoverflow.com/questions/41154784/how-to-resize-uiimageview-based-on-uiimages-size-ratio-in-swift-3/41155070
        
        let scrol = UIScrollView.init(frame: CGRect(x:0, y:64, width:self.view.frame.size.width ,height:self.view.frame.size.height-64))
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.yellow

        let cardView = CardView()
        cardView.backgroundColor = UIColor.green
        
        let subView = UIView.init(frame: CGRect(x:0, y:0, width:self.view.frame.size.width-20 ,height:90))
        subView.backgroundColor  = UIColor.blue
        
        let image = UIImage(named: "windSpeed")!
        let imageView = UIImageView.init(frame: CGRect(x:0, y:subView.frame.size.height, width:self.view.frame.size.width-20 ,height:0))
        
        let ratio = image.size.width / image.size.height
        let newHeight = self.view.frame.size.width-20 / ratio
        imageView.frame.size = CGSize(width: self.view.frame.size.width-20, height: newHeight-40)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.red
        
        let label = UILabel.init(frame: CGRect(x:10, y: imageView.frame.origin.y + imageView.frame.size.height, width:scrol.frame.size.width - 40 ,height:05))
        label.numberOfLines = 0
        label.text = "Eddie uses live weather feed to provide accurate information about the wind before you play each shot."
        label.sizeToFit()
        label.backgroundColor = UIColor.cyan
        
        cardView.frame = CGRect(x:10, y:0, width:self.view.frame.size.width-20 ,height:label.frame.origin.y + label.frame.size.height + 20)
        containerView.frame = CGRect(x:0, y:0, width:self.view.frame.size.width ,height:scrol.frame.size.height)// width will be changed

        cardView.addSubview(subView)
        cardView.addSubview(imageView)
        cardView.addSubview(label)
        
        containerView.addSubview(cardView)

        scrol.addSubview(containerView)
        self.view.addSubview(scrol)
    }
    
    func checkTrialPreriod(){
        
        isProgress = true
//        progressView.show(atView: self.view, navItem: self.navigationItem)
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
                self.isProgress = false
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
        isProgress = true
//        progressView.show(atView: self.view, navItem: self.navigationItem)


    }
    @objc func endFetchingDetails(_ notification: NSNotification) {
        isProgress = false
        if self.isBtnEddieClicked{
            IAPHandler.shared.purchaseMyProduct(index: 6)
            FBSomeEvents.shared.logAddToCartEvent(type: "Yearly", price: 40)
            FBSomeEvents.shared.singleParamFBEvene(param: "Click Eddie Buy")
        }else{
            self.progressView.hide(navItem: self.navigationItem)
        }
    }
    
    @objc func startPaymentRequest(_ notification: NSNotification) {
        isProgress = true
        progressView.show(atView: self.view, navItem: self.navigationItem)


    }

    @objc func endPaymentRequest(_ notification: NSNotification) {
        
        isProgress = false
        self.progressView.hide(navItem: self.navigationItem)
        let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            debugPrint(alert as Any)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentCancelled(_ notification: NSNotification) {
        isProgress = false
        self.progressView.hide(navItem: self.navigationItem)
    }
    var isBtnEddieClicked = false
    @IBAction func btnEddiePaymentAction(_ sender: Any) {
        
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly, 4->yearly_3Days_39.99, 5->yearly_1Month_39.99
        progressView.show(atView: self.view, navItem: self.navigationItem)
        if isProgress{
           self.isBtnEddieClicked = true
//           self.view.makeToast("Please wait for a while.")
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 6)
            FBSomeEvents.shared.logAddToCartEvent(type: "Yearly", price: 40)
//            if Constants.trial == true{
//                IAPHandler.shared.purchaseMyProduct(index: 4)
//            }
//            else{
//                IAPHandler.shared.purchaseMyProduct(index: 5)
//            }
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Eddie Buy")
    }
    
    @IBAction func monthlyPaymentAction(_ sender: Any) {
        
        if isProgress{
            self.view.makeToast("Please wait for a while.")
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 1)
            FBSomeEvents.shared.logAddToCartEvent(type: "Monthly", price: 4)
//            if Constants.trial == true{
//                IAPHandler.shared.purchaseMyProduct(index: 0)
//            }
//            else{
//                IAPHandler.shared.purchaseMyProduct(index: 1)
//            }
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Eddie Buy Monthly")
    }

    @IBAction func yearlyPaymentAction(_ sender: Any) {
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly, 4->yearly_3Days_39.99, 5->yearly_1Month_39.99
        if isProgress{
            self.view.makeToast("Please wait for a while.")
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 6)
            FBSomeEvents.shared.logAddToCartEvent(type: "Yearly", price: 40)


//            if Constants.trial == true{
//                IAPHandler.shared.purchaseMyProduct(index: 4)
//            }
//            else{
//                IAPHandler.shared.purchaseMyProduct(index: 5)
//            }
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Eddie Buy Annual")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)
        debugPrint(self.eddieView)
        ref.child("eddieViews/\(Auth.auth().currentUser!.uid)").updateChildValues(["\(Timestamp)":self.eddieView])
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        btnNext.setTitle("Next".localized(), for: .normal)

        btnNext.isHidden = false
        btnPrev.isHidden = false

        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)
        self.eddieView.setValue(true, forKey: "screen\(Int(currentPage+1))")

        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        if pageControl.currentPage == 9 {
            btnNext.isHidden = true
            btnPrev.isHidden = false
        }
        else if pageControl.currentPage == 0{
            btnPrev.isHidden = true
            btnNext.isHidden = false
            btnNext.setTitle("See How >", for: .normal)
        }
        currentPageIndex = self.pageControl.currentPage
        FBSomeEvents.shared.singleParamFBEvene(param: "View Eddie \(currentPageIndex+1))")
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        btnNext.setTitle("Next".localized(), for: .normal)
        btnPrev.isHidden = false

        currentPageIndex = self.pageControl.currentPage + 1
        pageControl.currentPage += 1
        FBSomeEvents.shared.singleParamFBEvene(param: "View Eddie \(currentPageIndex+1))")
        let x = CGFloat(pageControl.currentPage) * (eddieScrollView.frame.size.width)
        eddieScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        if currentPageIndex == 9 {
            btnNext.isHidden = true
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "View Eddie \(currentPageIndex+1))")
    }

    @IBAction func btnPrevAction(_ sender: Any) {
        btnNext.setTitle("Next".localized(), for: .normal)
        btnNext.isHidden = false
        
        currentPageIndex = self.pageControl.currentPage - 1
        pageControl.currentPage -= 1
        
        let x = CGFloat(pageControl.currentPage) * (eddieScrollView.frame.size.width)
        eddieScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        if currentPageIndex == 0 {
            btnPrev.isHidden = true
            btnNext.setTitle("See How >", for: .normal)
        }
        FBSomeEvents.shared.singleParamFBEvene(param: "View Eddie \(currentPageIndex+1))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func btnActionTermOfService(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/terms-of-service.html"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func btnActionPrivacyPolicy(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/privacypolicy.htm"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func closeAction(_ sender: Any) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Eddie Close")
        if self.navigationController?.viewControllers.count == 2{
            if self.navigationController?.viewControllers[0].isKind(of: NewHomeVC.self) ?? false{
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
}
