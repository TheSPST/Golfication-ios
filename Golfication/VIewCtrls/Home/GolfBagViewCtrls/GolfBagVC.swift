//
//  GolfBagVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GolfBagVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var shadowView: UIView!

    fileprivate let golfBag = ["Drivers", "Woods", "Hybrids", "Irons", "Wedges", "Putter"]
    
    @IBAction func backAction(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        var array = [UIViewController]()
        for i in 0..<golfBag.count{
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "GolfBagTabsVC") as! GolfBagTabsVC
            viewCtrl.golfBagStr = golfBag[i]
            array.append(viewCtrl)
        }
        return array
    }

    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        if playButton != nil{
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }

    override func viewDidLoad() {

        self.automaticallyAdjustsScrollViewInsets = false
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.glfBluegreen
        settings.style.buttonBarItemFont = UIFont(name: "SFProDisplay-Medium", size: 14.0)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        super.viewDidLoad()
        self.title = "Golf Bag"
    }
}
