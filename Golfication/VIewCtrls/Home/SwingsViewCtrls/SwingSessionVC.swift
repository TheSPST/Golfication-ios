//
//  SwingSessionVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/25/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SwingSessionVC: ButtonBarPagerTabStripViewController, DemoFooterViewDelegate, BluetoothDelegate {
    @IBOutlet weak var shadowView: UIView!

    var dataMArray = NSMutableArray()
    var isDemoStats = Bool()
    var sharedInstance: BluetoothSync!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    override func viewDidLoad() {
        Constants.finalFilterDic.removeAllObjects()
        
        //        RSTypeArray.removeAll()
        //        PlayTypeArray.removeAll()
        //        CSTypeArray.removeAll()
        //        HoleTypeArray.removeAll()
        //        CoursesTypeArray.removeAll()
        
        // change selected bar color
        self.automaticallyAdjustsScrollViewInsets = false
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.glfBluegreen
        settings.style.buttonBarItemFont = UIFont(name: "SFProDisplay-Semibold", size: 14.0)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        if isDemoStats{
            self.title = "My Swings Demo"
            setDemoFotter()
        }
    }
    
    func setDemoFotter(){
        let demoView = DemoFooterView()
        demoView.frame = CGRect(x: 0.0, y: self.view.frame.height-55.0, width: self.view.frame.width, height: 55.0)
        demoView.delegate = self
        demoView.backgroundColor = UIColor.glfFlatBlue
        demoView.label.frame = CGRect(x: 10, y: demoView.frame.size.height/2-22, width: demoView.frame.width * 0.7, height: 44.0)
        demoView.btnPlayGame.frame = CGRect(x:demoView.frame.width - demoView.frame.width * 0.25 - 10, y: demoView.frame.size.height/2-15, width: demoView.frame.width * 0.25, height: 30.0)
        self.view.addSubview(demoView)
        
        demoView.label.text = "Get your swing stats with Golfication X"
        demoView.label.textAlignment = .left
        demoView.label.textColor = UIColor.white
        demoView.btnPlayGame.setTitle("Connect Now", for: .normal)
    }
    
    func playGameButton(button: UIButton) {
        self.sharedInstance = BluetoothSync.getInstance()
        self.sharedInstance.delegate = self
        self.sharedInstance.initCBCentralManager()
    }
    
    func didUpdateState(_ state: CBManagerState) {
        debugPrint("state== ",state)
        var alert = String()
        
        switch state {
        case .poweredOff:
            alert = "Make sure that your bluetooth is turned on."
            break
        case .poweredOn:
            debugPrint("State : Powered On")
            
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "bluetootheConnectionTesting") as! BluetootheConnectionTesting
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            self.sharedInstance.delegate = nil
            return
            
        case .unsupported:
            alert = "This device is unsupported."
            break
        default:
            alert = "Try again after restarting the device."
            break
        }
        
        let alertVC = UIAlertController(title: "Alert", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.sharedInstance.delegate = nil
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func filterNavBarButtonClick(_ sender: Any) {
        let index =  self.buttonBarView.selectedIndex
        
        let filterVc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        if index == 1{
            filterVc.fromSwingSession = true
        }
        else{
            filterVc.fromSwingPerform = true
        }
        self.navigationController?.pushViewController(filterVc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    override public func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController]
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        let childOneVC = storyboard.instantiateViewController(withIdentifier: "MySwingVC") as! MySwingVC
//        let childTwoVC = storyboard.instantiateViewController(withIdentifier: "SessionViewController") as! SessionViewController
        let storyboard = UIStoryboard(name: "MySwing", bundle: nil)
        
        let childOneVC = storyboard.instantiateViewController(withIdentifier: "SessionVC") as! SessionVC
        childOneVC.sessionMArray = dataMArray
        childOneVC.isDemoStats = isDemoStats
        
        let childTwoVC = storyboard.instantiateViewController(withIdentifier: "PerformanceVC") as! PerformanceVC
        childTwoVC.performanceMArray = dataMArray

        let array :  [UIViewController] = [childTwoVC,childOneVC]
        return array
    }
}

