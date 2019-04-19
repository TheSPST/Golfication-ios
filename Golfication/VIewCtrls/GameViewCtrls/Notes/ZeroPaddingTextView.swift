//
//  ZeroPaddingTextView.swift
//  UI
//
//  Created by George Tsifrikas on 28/10/2018.
//  Copyright © 2018 George Tsifrikas. All rights reserved.
//

import UIKit

@IBDesignable class ZeroPaddingTextView: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//
//        txtVNotes.text = "Placeholder for UITextView"
//        txtVNotes.textColor = UIColor.lightGray
//        txtVNotes.font = UIFont(name: "verdana", size: 13.0)
//        txtVNotes.returnKeyType = .done
//        txtVNotes.delegate = self
//    }
//
//    //MARK:- UITextViewDelegates
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.text == "Placeholder for UITextView" {
//            textView.text = ""
//            textView.textColor = UIColor.black
//            textView.font = UIFont(name: "verdana", size: 18.0)
//        }
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//        }
//        return true
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text == "" {
//            textView.text = "Placeholder for UITextView"
//            textView.textColor = UIColor.lightGray
//            textView.font = UIFont(name: "verdana", size: 13.0)
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

}
