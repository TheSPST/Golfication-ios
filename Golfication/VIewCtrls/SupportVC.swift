//
//  SupportVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 08/04/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

//https://www.oodlestechnologies.com/blogs/Country-code-selection-using-Radio-Button-In-table-view-Swift

import UIKit
import MessageUI

class SupportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var feedbackTblView: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblHours: UILabel!

    var feedbackArray = ["Mapping Issues", "Scorecard Issues", "App Functionality", "Feature Request", "Subscriptions", "Other"]
    var selectedIndex:IndexPath?
    var selectedText:String!
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHours.text = "Send us an email detailing your problem or suggessions.\nWe will get back you within 24 hours."
        btnContinue.setCorner(color: UIColor.clear.cgColor)
        feedbackTblView.layer.cornerRadius = 3.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupportCell", for: indexPath) as! SupportCell
        
        cell.lblTitle.text = feedbackArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if (selectedIndex == indexPath) {
            cell.btnRadio.backgroundColor = UIColor.glfBluegreen
            
        } else {
            cell.btnRadio.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedIndex = indexPath
        tableView.reloadData()
        
        selectedText = feedbackArray[indexPath.row]
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        if selectedText == nil{
            self.view.makeToast("Please select one of the above issue.")
        }else{
            if MFMailComposeViewController.canSendMail() {
                let picker = MFMailComposeViewController()
                picker.mailComposeDelegate = self
                picker.setToRecipients(["support@golfication.com"])
                picker.setSubject(selectedText)
                picker.setMessageBody("", isHTML: true)
                present(picker, animated: true, completion: nil)
            }
            else {
                let alertVC = UIAlertController(title: "Alert", message: "Please configure your mail first.", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            debugPrint("You sent the email.")
            self.dismiss(animated: true, completion: nil)
            break
        case .saved:
            debugPrint("You saved a draft of this email")
            break
        case .cancelled:
            debugPrint("You cancelled sending this email.")
            break
        case .failed:
            debugPrint("Mail failed:  An error occurred when trying to compose this email")
            break
        default:
            debugPrint("An error occurred when trying to compose this email")
            break
        }
        dismiss(animated: true, completion: nil)
    }
}
