//
//  SwingSessionVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/25/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SwingSessionVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var shadowView: UIView!

    var dataMArray = NSMutableArray()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    override func viewDidLoad() {
        finalFilterDic.removeAllObjects()
        
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
        
        let childTwoVC = storyboard.instantiateViewController(withIdentifier: "PerformanceVC") as! PerformanceVC
        childTwoVC.performanceMArray = dataMArray

        let array :  [UIViewController] = [childTwoVC,childOneVC]
        return array
    }
}

