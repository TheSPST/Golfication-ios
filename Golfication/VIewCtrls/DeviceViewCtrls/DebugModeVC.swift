//
//  DebugModeVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class DebugModeVC: UIViewController {

    @IBOutlet weak var textViewDebugData: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDebugData.isEditable = false
        // Do any additional setup after loading the view.
    }
    @IBAction func startDebugAction(_ sender: UIButton) {
        if Constants.ble != nil{
            textViewDebugData.text = "Testing Started..........."
            Constants.ble.sendforteenCommand()
        }
    }
}
