//
//  AssignTagVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreBluetooth
class AssignTagVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var shadowView: UIView!
    var clubs = NSMutableDictionary()
    var golfBagArr = NSMutableArray()
    let progressView = SDLoader()

    var golfBag = [String]()
    
    var golfBagDriverArray = [String]()
    var golfBagWoodArray = [String]()
    var golfBagHybridArray = [String]()
    var golfBagIronArray = [String]()
    var golfBagWageArray = [String]()
    var golfBagPuttArray = [String]()
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var array = [UIViewController]()
        for i in 0..<golfBag.count{
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "AssignTabsVC") as! AssignTabsVC
            viewCtrl.golfBagStr = golfBag[i]
            viewCtrl.golfBagDriverArray = golfBagDriverArray
            viewCtrl.golfBagIronArray = golfBagIronArray
            viewCtrl.golfBagWoodArray = golfBagWoodArray
            viewCtrl.golfBagWageArray = golfBagWageArray
            viewCtrl.golfBagHybridArray = golfBagHybridArray
            viewCtrl.golfBagPuttArray = golfBagPuttArray
            viewCtrl.clubs = clubs
            viewCtrl.golfBagArr = golfBagArr
            array.append(viewCtrl)
        }
        return array
}
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    @objc func btnContinueAction(){
        debugPrint("Continue")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command"), object: nil)
    }
    @objc func startMatch(_ notification:NSNotification){
        if let game = notification.object as? String{
            if(game == "New Match"){
                let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
                self.navigationController?.pushViewController(mapViewController, animated: true)
            }else{
                let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "ScanningVC") as! ScanningVC
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startMatch(_:)), name: NSNotification.Name(rawValue: "startMatch"), object: nil)
        self.tabBarController?.tabBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        let btn = UIBarButtonItem(title: "Continue".localized(), style: .done, target: self, action: #selector(self.btnContinueAction))
        self.navigationItem.setRightBarButtonItems([btn], animated: true)
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
        self.title = "Assign Tags"
        self.progressView.hide(navItem: self.navigationItem)
    }

}
