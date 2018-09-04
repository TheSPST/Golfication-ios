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
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        
        if let url = URL(string: linkStr) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
