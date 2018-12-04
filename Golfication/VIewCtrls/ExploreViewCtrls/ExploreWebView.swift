//
//  ExploreWebView.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class ExploreWebView: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var linkStr: String =  ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)
        
        self.navigationController?.navigationBar.isHidden = false
        
        if let url = URL(string: linkStr) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    @objc func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
