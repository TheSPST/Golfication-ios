//
//  PracticeGameViewCtrl.swift
//  Golfication
//
//  Created by Khelfie on 23/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class PracticeGameViewCtrl: UIViewController {
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSwingSpeed: UILabel!
    @IBOutlet weak var lblTempo: UILabel!
    @IBOutlet weak var lblBackSwing: UILabel!
    @IBOutlet weak var lblDownSwing: UILabel!
    @IBOutlet weak var lblHandSpeed: UILabel!
    @IBOutlet weak var lblClubSpeed: UILabel!
    @IBOutlet weak var btnRecieveData: UIButton!
    
    @IBAction func btnActionFinishMatch(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
    }
    
    @IBAction func btnActionRecieveData(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: nil)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

