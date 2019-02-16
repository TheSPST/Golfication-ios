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
    var fromMap = Bool()
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        if fromMap{
            fromMap = false
            self.dismiss(animated: true, completion: nil)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: desc)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        lblDesc.attributedText = attributedString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
