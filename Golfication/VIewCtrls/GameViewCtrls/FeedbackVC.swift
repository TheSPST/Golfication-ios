//
//  FeedbackVC.swift
//  Golfication
//
//  Created by Khelfie on 31/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import StoreKit
import FirebaseAuth
// How was your golfication Expierience
class FeedbackVC: UIViewController,UITextViewDelegate {
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var heightOfView: NSLayoutConstraint!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var textViewForFeedback: UITextField!
    @IBOutlet weak var btnIncorrectMapping: UIButton!
    @IBOutlet weak var btnOtherIssue: UIButton!
    @IBOutlet weak var btnDifficultToUse: UIButton!
    @IBOutlet weak var btnMissingFeature: UIButton!
    @IBOutlet weak var btnWrongParValues: UIButton!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var lblWhatWentWrong: UILabel!
    
    @IBOutlet weak var lblStarDetails: UILabel!
    @IBOutlet weak var allWrongBtnSV: UIStackView!
    
    @IBOutlet weak var btnSkip: UILocalizedButton!
    @IBOutlet weak var skipSubmitStackView: UIStackView!
    var onDoneBlock : ((Bool) -> Void)?
    var originOfMainView : CGPoint!
    @IBAction func btnActionSkip(_ sender: UIButton) {
        self.btnActionClose(sender)
    }
    
    var btnArray = [UIButton]()
    var matchIdentifier : String!
    var mode : Int!
    var dataForFirebase = (rating:Int(),feedback:String(),wrong:String())
    
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    func showReview() {
            if #available(iOS 10.3, *) {
                debugPrint("Review Requested")
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            debugPrint(position)
            if(self.keyboardHeight != nil){
                if(self.keyboardHeight > 0){
                    textViewForFeedback?.resignFirstResponder()
                }
            }else if !(self.mainView.frame.contains(position)){
                self.btnActionClose(UIButton.self)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.layer.cornerRadius = 5
        self.btnSubmit.layer.cornerRadius = 3
        btnIncorrectMapping.setCorner(color: UIColor.glfWarmGrey.cgColor)
        btnOtherIssue.setCorner(color: UIColor.glfWarmGrey.cgColor)
        btnDifficultToUse.setCorner(color: UIColor.glfWarmGrey.cgColor)
        btnMissingFeature.setCorner(color: UIColor.glfWarmGrey.cgColor)
        btnWrongParValues.setCorner(color: UIColor.glfWarmGrey.cgColor)
        self.originOfMainView = self.mainView.frame.origin

//        textViewForFeedback.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        btnArray = [btnIncorrectMapping,btnOtherIssue,btnDifficultToUse,btnMissingFeature,btnWrongParValues]
        var i = 1
        for btn in btnArray{
            btn.tag = i
            i += 1
        }
        i = 0
        for btn in starsStackView.arrangedSubviews{
            btn.tag = i
            (btn as! UIButton).addTarget(self, action: #selector(self.starCount(_:)), for: .touchUpInside)
            i += 1
        }
        switch mode {
        case 2:
                self.btnIncorrectMapping.setTitle("Unmapped Course", for: .normal)
                break
        case 3:
                self.btnIncorrectMapping.setTitle("Unmapped Course", for: .normal)
            break
        default:
                self.btnIncorrectMapping.setTitle("Incorrect Mapping", for: .normal)
            break
        }
        
        // Do any additional setup after loading the view.
    }
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard textViewForFeedback != nil else {
            return
        }
        if(self.keyboardHeight != nil){
            if(self.keyboardHeight > 0){
                textViewForFeedback?.resignFirstResponder()
            }
        }

//        textViewForFeedback = nil
    }
    
    @objc func starCount(_ sender:UIButton){
        self.lblStarDetails.isHidden = false
        let text = ["Poor","Fair","Good","Very Good","Excellent"]
        self.lblStarDetails.text = text[sender.tag]
        dataForFirebase.rating = sender.tag + 1
        self.lblWhatWentWrong.isHidden = false
        debugPrint("count++")
        self.skipSubmitStackView.isHidden = false
        self.btnSkip.setTitleColor(UIColor.glfWarmGrey, for: .normal)
        for i in 0..<starsStackView.arrangedSubviews.count{
            if(i < sender.tag+1){
                (starsStackView.arrangedSubviews[i] as! UIButton).setBackgroundImage(#imageLiteral(resourceName: "ICC_highlightedStar_2x"), for: .normal)
                self.allWrongBtnSV.isHidden = false
                self.textViewForFeedback.isHidden = false
            }else{
                (starsStackView.arrangedSubviews[i] as! UIButton).setBackgroundImage(#imageLiteral(resourceName: "ICC_emptyStar_2x"), for: .normal)
            }
        }
        self.btnSubmit.isHidden = false
        self.mainStackView.layoutIfNeeded()
        self.heightOfView.constant = mainStackView.frame.height + 24
        if(mainStackView.frame.height < 140){
            self.heightOfView.constant = 160
        }
        self.lblWhatWentWrong.text = "What went wrong ?"

        if(sender.tag == 4){
            self.allWrongBtnSV.isHidden = true
            self.textViewForFeedback.isHidden = true
            self.btnSubmit.isHidden = false
            self.btnSkip.setTitleColor(UIColor.glfWhite, for: .normal)
            self.lblWhatWentWrong.text = ""
            self.mainStackView.layoutIfNeeded()
            self.heightOfView.constant = mainStackView.frame.height + 24
            if(mainStackView.frame.height < 140){
                self.heightOfView.constant = 160
            }
        }
    }
    @IBAction func btnActionClose(_ sender: Any) {
        onDoneBlock!(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnActionWrongPar(_ sender: UIButton) {
        for btn in btnArray{
            if(sender.tag == btn.tag){
                btn.isSelected = true
                btn.backgroundColor = UIColor.glfDarkGreen
                btn.setTitleColor(UIColor.glfWhite, for: .selected)
                dataForFirebase.wrong = btn.currentTitle!
                
            }else{
                btn.backgroundColor = UIColor.glfWhite
                btn.setTitleColor(UIColor.glfWarmGrey, for: .selected)
                btn.isSelected = false
            }
        }
    }
    
    @IBAction func btnActionSubmit(_ sender: Any) {
        self.btnSubmit.isHidden = true
        self.lblWhatWentWrong.text = "Thank you for feedback."
        if let str = self.textViewForFeedback.text{
            dataForFirebase.feedback = str
        }
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["rating":dataForFirebase.rating])
        dict.addEntries(from: ["feedback":dataForFirebase.feedback])
        dict.addEntries(from: ["wrong":dataForFirebase.wrong])
        
        ref.child("matchData/\(matchIdentifier!)/userFeedBack").updateChildValues([Auth.auth().currentUser!.uid :dict] as [AnyHashable:Any])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if(self.dataForFirebase.rating == 5){
                self.showReview()
            }
            self.btnActionClose(UIButton.self)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textViewDidBeginEditing(_ textField: UITextView) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textViewDidEndEditing(_ textField: UITextView) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textViewShouldReturn(_ textField: UITextView) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: Keyboard Handling
extension FeedbackVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.heightOfView.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.view.frame.size.height - (self.textViewForFeedback.frame.origin.y) - (self.textViewForFeedback.frame.size.height)
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.mainView.frame.origin = CGPoint(x: self.mainView.frame.minX, y: self.mainView.frame.minY - (collapseSpace + 10))
                self.mainView.layoutIfNeeded()
                
                self.heightOfView.constant = self.mainStackView.frame.height + 24
                if(self.mainStackView.frame.height < 140){
                    self.heightOfView.constant = 160
                }

                self.mainView.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.mainView.frame.origin = self.originOfMainView
            self.heightOfView.constant = self.mainStackView.frame.height + 24
            if(self.mainStackView.frame.height < 140){
                self.heightOfView.constant = 160
            }
            self.mainView.layoutIfNeeded()

        }
        
        keyboardHeight = nil
    }
}
