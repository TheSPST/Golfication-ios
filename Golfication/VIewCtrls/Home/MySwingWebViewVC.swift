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
    @IBOutlet weak var webView: UIWebView!
    
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
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if fromIndiegogo {
        playButton.floatButton.removeFromSuperview()
        playButton.contentView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let myURL = URL(string: linkStr)
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
        
        if let url = URL(string: linkStr) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: CGRect( x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 20 ), configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
}
