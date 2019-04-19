//
//  NotesVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 19/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class NotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var notesTblView: UITableView!
    @IBOutlet weak var btnKnowMore: UIButton!
    @IBOutlet weak var btnEddiePayment: UIButton!
    @IBOutlet weak var footerView: UIView!

    let progressView = SDLoader()
    
    var notesArray = [(Timestamp:Int64, Text: String)]()
    var notesCourseID = String()
    var notesHoleNum = String()
    var isProgress = false
    
    var connectAttrs = [
        NSAttributedStringKey.font : UIFont(name: "SFProDisplay-Italic", size: 13.0)!,
        NSAttributedStringKey.foregroundColor : UIColor(rgb:0x007AFF),
        NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
    
    @IBAction func knowMoreAction(_ sender: Any) {
        
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Notes"
        self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    @IBAction func privacyPolicyAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/privacypolicy.htm"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @IBAction func termsAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "http://www.golfication.com/terms-of-service.html"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEddiePaymentAction(_ sender: Any) {
        
        //0->monthly , 1->trial monthly, 2-> trial yearly, 3->yearly, 4->yearly_3Days_39.99, 5->yearly_1Month_39.99
        if isProgress{
            self.view.makeToast("Please wait for a while.")
        }
        else{
            IAPHandler.shared.purchaseMyProduct(index: 6)
//            if Constants.trial == true{
//                IAPHandler.shared.purchaseMyProduct(index: 4)
//            }
//            else{
//                IAPHandler.shared.purchaseMyProduct(index: 5)
//            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
    }
    @IBAction func addNotesAction(sender: UIBarButtonItem) {
        if notesArray.first != nil{
            if !(notesArray.first!.Text.isEmpty){
                notesArray.insert((Timestamp: Timestamp, Text: ""), at: 0)
            }
        }
        else{
            notesArray.insert((Timestamp: Timestamp, Text: ""), at: 0)
        }
        notesTblView.reloadData()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        notesTblView.allowsSelection = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notes - Hole \(notesHoleNum.last!)"
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.btnEddiePayment.frame.size.width, height: self.btnEddiePayment.frame.size.height)
        gradient.colors = [UIColor(rgb: 0xEB6A2D).cgColor, UIColor(rgb: 0xF5B646).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnEddiePayment.layer.insertSublayer(gradient, at: 0)
        btnEddiePayment.layer.cornerRadius = 20.0
        btnEddiePayment.layer.masksToBounds = true
        
        let atrString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string: "Know more", attributes:connectAttrs)
        atrString.append(buttonTitleStr)
        btnKnowMore.setAttributedTitle(atrString, for: .normal)
        
        checkTrialPreriod()
        if Constants.isProMode{
            getNotesDataFromFirebase()
        }
        else{
            notesArray = [(Timestamp:Int64, Text: String)]()
            self.notesArray.append((Timestamp: Timestamp, Text: ""))
            self.notesTblView.reloadData()
        }
    }
    
    func checkTrialPreriod(){
        
        isProgress = true
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "trial") { (snapshot) in
            if(snapshot.value != nil){
                Constants.trial = snapshot.value as! Bool
            }
            else{
                Constants.trial = false
            }
            DispatchQueue.main.async( execute: {
                self.isProgress = false
                NotificationCenter.default.addObserver(self, selector: #selector(self.startPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentStarted"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.endPaymentRequest(_:)), name: NSNotification.Name(rawValue: "PaymentFinished"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.paymentCancelled(_:)), name: NSNotification.Name(rawValue: "PaymentCancelled"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.startFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingStarted"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.endFetchingDetails(_:)), name: NSNotification.Name(rawValue: "FetchingFinished"), object: nil)
                
                IAPHandler.shared.fetchAvailableProducts()
                IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
                    guard let strongSelf = self else{ return }
                    if type == .purchased {
                        let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                        alertView.addAction(action)
                        strongSelf.present(alertView, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    @objc func startFetchingDetails(_ notification: NSNotification) {
        isProgress = true
    }
    @objc func endFetchingDetails(_ notification: NSNotification) {
        isProgress = false
    }
    
    @objc func startPaymentRequest(_ notification: NSNotification) {
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        isProgress = true
    }
    
    @objc func endPaymentRequest(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
        isProgress = false
        
        let alert = UIAlertController(title: "Alert", message: "Congratulations! Your Pro MemberShip is now Active", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            debugPrint(alert as Any)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentCancelled(_ notification: NSNotification) {
        self.progressView.hide(navItem: self.navigationItem)
        isProgress = false
    }
    
    func getNotesDataFromFirebase(){
        self.notesArray = [(Timestamp:Int64, Text: String)]()
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "notes/\(notesCourseID)/\(Auth.auth().currentUser!.uid)") { (snapshot) in
            var allNotes = NSDictionary()
            if snapshot.value != nil{
                allNotes = snapshot.value as! NSDictionary
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                
                for (key,value) in allNotes{
                    if (key as! String) == self.notesHoleNum{
                        let dic = value as! NSDictionary
                        for (key1,value1) in dic{
                            self.notesArray.append((Timestamp:Int64(key1 as! String)!, Text: value1 as! String))
                        }
                        break
                    }
                }
                if self.notesArray.count == 0{
                    self.notesArray.append((Timestamp: Timestamp, Text: ""))
                }else{
                    self.notesArray = self.notesArray.sorted{
                        ($0.Timestamp > $1.Timestamp)
                    }
                }
                self.notesTblView.reloadData()
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Constants.isProMode{
            return notesArray.count
        }
        else{
            return notesArray.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !Constants.isProMode && indexPath.row == notesArray.count{
            return 800
        }
        else{
            return notesArray[indexPath.row].Text.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 14))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        if !Constants.isProMode && indexPath.row == notesArray.count{
            cell.textView.isHidden = true
            cell.dateTrashSV.isHidden = true
            footerView.frame.size.width = self.view.frame.size.width
//            footerView.backgroundColor = UIColor.cyan
            cell.contentView.addSubview(footerView)
        }
        else{
            cell.textView.isHidden = false
            cell.dateTrashSV.isHidden = false
            
            cell.textView.text = notesArray[indexPath.row].Text
            cell.label.text = notesArray[indexPath.row].Text
            
            cell.textView.placeholder = Constants.placeholder
            cell.textView.placeholderColor = UIColor.lightGray
            //textView.attributedPlaceholder = ... // NSAttributedString (optional)
            
            cell.textChanged {[weak tableView, weak self] newText in
                self?.notesArray[indexPath.row].Text = newText
                cell.label.text = newText
                
                DispatchQueue.main.async {
                    if !newText.isEmpty{
                        ref.child("notes/\(self!.notesCourseID)/\(Auth.auth().currentUser!.uid)/\(self!.notesHoleNum)/").updateChildValues(["\(self!.notesArray[indexPath.row].Timestamp)":newText])
                        tableView?.beginUpdates()
                        tableView?.endUpdates()
                    }else{
                        ref.child("notes/\(self!.notesCourseID)/\(Auth.auth().currentUser!.uid)/\(self!.notesHoleNum)/").updateChildValues(["\(self!.notesArray[indexPath.row].Timestamp)":NSNull()])
                    }
                    self!.navigationItem.rightBarButtonItem?.isEnabled = (self?.isEmptyAnyValue())!
                }
            }
            if notesArray.count>0 && notesArray[0].Text.isEmpty && indexPath.row == 0{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                if Constants.isProMode{
                    cell.textView.becomeFirstResponder()
                    cell.textView.isEditable = true
                    cell.btnTrash.isHidden = false
                }
                else{
                    cell.textView.resignFirstResponder()
                    cell.btnTrash.isHidden = true
                    cell.textView.isEditable = false
                }
            }
            
            cell.btnTrash.tag = indexPath.row
            cell.btnTrash.addTarget(self, action: #selector(self.deleteNote(_:)), for: .touchUpInside)
            
            let unixTimestamp = self.notesArray[indexPath.row].Timestamp/1000
            let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
            let strDate = dateFormatter.string(from: date)
            cell.lblDate.text = strDate
        }
        return cell
    }
    
    func isEmptyAnyValue()->Bool{
        for data in self.notesArray{
            if data.Text.isEmpty{
                return false
            }
        }
        return true
    }
    
    @objc func deleteNote(_ sender:UIButton){
        if notesArray.count>0{
            ref.child("notes/\(self.notesCourseID)/\(Auth.auth().currentUser!.uid)/\(self.notesHoleNum)/").updateChildValues(["\(self.notesArray[sender.tag].Timestamp)":NSNull()] as [AnyHashable:Any])
            notesArray.remove(at: sender.tag)
            if sender.tag == 0{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            notesTblView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}

