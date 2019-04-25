//
//  MySwingWebViewVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 27/02/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import WebKit

class MySwingWebViewVC: UIViewController, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!
    var linkStr: String =  ""
    var fromIndiegogo = Bool()
    var fromNotification = Bool()

    // MARK: backAction
    @IBAction func backAction(_ sender: Any) {
        
        if fromIndiegogo && !fromNotification {
            self.dismiss(animated: false, completion: nil)
        }
        else if fromIndiegogo && fromNotification {
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: linkStr) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
