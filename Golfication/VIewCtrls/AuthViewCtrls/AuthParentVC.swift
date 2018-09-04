//
//  SignUpParentVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 20/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseAuth
class AuthParentVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!

    @IBAction func guestAction(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        if Auth.auth().currentUser != nil{
            if(Auth.auth().currentUser?.isEmailVerified)!{
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                self.navigationController?.pushViewController(tabBarCtrl, animated: false)
            }else{
                do{
                    try Auth.auth().signOut()
                }
                catch _ as NSError {
                }
            }
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        //self.automaticallyAdjustsScrollViewInsets = false
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
        
        if UIDevice.current.iPad {
            logoImageView.isHidden = true
        }
        else{
            logoImageView.isHidden = false
        }
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let childOneVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        let childTwoVC = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        let array :  [UIViewController] = [childOneVC,childTwoVC]
        return array
    }
}
