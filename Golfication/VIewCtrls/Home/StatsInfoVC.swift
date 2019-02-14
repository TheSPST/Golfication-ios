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
//        lblDesc.text = desc
        
        let attributedString = NSMutableAttributedString(string: desc)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        // *** Set Attributed String to your label ***
        lblDesc.attributedText = attributedString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
