//
//  StatsInfoVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 13/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class StatsInfoVC: UIViewController {
    @IBOutlet weak var lblDesc: UILabel!

    var desc = String()

    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lblDesc.text = desc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
