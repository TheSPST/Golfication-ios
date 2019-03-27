//
//  CourseViewController.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let originalImage1 = UIImage(named: "backArrow")!
//        let btnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//        self.navigationItem.leftBarButtonItem.set
//
//        btnBack.tintColor = UIColor.white
//        btnBack.setImage(btnImage, for: .normal)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
