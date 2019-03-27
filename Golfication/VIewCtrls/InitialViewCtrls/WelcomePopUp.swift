//
//  WelcomePopUp.swift
//  Golfication
//
//  Created by Rishabh Sood on 17/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class WelcomePopUp: UIViewController {
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var containerView: UIView!
    var progressView = SDLoader()
    override func viewDidLoad() {
        super.viewDidLoad()
            self.lblWelcome.text = "Hi \(Constants.userName), let's shoot lower scores and make golf more fun - with the power of data and Artificial Intelligence!"
            self.btnGetStarted.layer.cornerRadius = self.btnGetStarted.frame.size.height/2
            self.btnGetStarted.layer.masksToBounds = true
    }
    
//    @IBAction func dismissAction(_ sender: Any) {
////        self.dismiss(animated: true, completion: nil)
//
//    }
    
    @IBAction func getStartedAction(_ sender: Any) {
        FBSomeEvents.shared.logCompleteTutorialEvent(contentData: "", contentId: "", success: true)
       let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       appDelegate.fromNewUserProfile = true
       appDelegate.window?.rootViewController = tabBarCtrl
    }
}
