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

    override func viewDidLoad() {
        super.viewDidLoad()

        var nameStr = Auth.auth().currentUser!.displayName!
        
        if let dotRange = nameStr.range(of: " ") {
            nameStr.removeSubrange(dotRange.lowerBound..<nameStr.endIndex)
        }
        lblWelcome.text = "Hi \(nameStr), let's shoot lower scores and make golf more fun - with the power of data and Artificial Intelligence!"
        
        btnGetStarted.layer.cornerRadius = btnGetStarted.frame.size.height/2
        btnGetStarted.layer.masksToBounds = true
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func getStartedAction(_ sender: Any) {
       let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       appDelegate.fromNewUserProfile = true
       appDelegate.window?.rootViewController = tabBarCtrl
    }
}
