//
//  MultiplayerTeeSelectionVC.swift
//  Golfication
//
//  Created by Khelfie on 07/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class MultiplayerTeeSelectionVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableViewMultiplayerTee: UITableView!
    @IBOutlet weak var btnStart: UIButton!
    var totalPlayers = NSMutableArray()
    var handicap = [Double]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHandicapOfAllUser()
        self.title = "Player Stats"
        // Do any additional setup after loading the view.
    }
    func fetchHandicapOfAllUser(){
            let group = DispatchGroup()
            for player in totalPlayers{
                let playerDict = player as! NSMutableDictionary
                let id = playerDict.value(forKey: "id") as! String
                group.enter()
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/\(id)/handicap") { (snapshot) in
                    if(snapshot.value != nil){
                        if let data = snapshot.value as? String{
                            if data == "-"{
                                self.handicap.append(0.0)
                            }else{
                                self.handicap.append(Double(data)!)
                            }
                        }else{
                            self.handicap.append(0.0)
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main, execute: {
                debugPrint(self.handicap)
                self.tableViewMultiplayerTee.delegate = self
                self.tableViewMultiplayerTee.dataSource = self
                self.tableViewMultiplayerTee.reloadData()
            })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnStartAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callApi"), object: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalPlayers.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "multiplayerTeeSelectionTableViewCell", for: indexPath) as! MultiplayerTeeSelectionTableViewCell
        cell.btnHandicap.tag = indexPath.row
        cell.btnDropDownTee.tag = indexPath.row
        cell.btnHandicap.addTarget(self, action: #selector(btnActionHadicap), for: .touchUpInside)
        cell.btnDropDownTee.addTarget(self, action: #selector(btnActionSelectTee), for: .touchUpInside)
        cell.lblUserName.text = ((self.totalPlayers[indexPath.row] as! NSMutableDictionary).value(forKey: "name") as! String)
        cell.btnHandicap.setTitle(String(self.handicap[indexPath.row]) == "0.0" ? "-":String(self.handicap[indexPath.row]), for: .normal)
        if(self.handicap[indexPath.row] != 0.0){
            cell.btnHandicap.isUserInteractionEnabled = false
        }
        if let img = (self.totalPlayers[indexPath.row] as! NSMutableDictionary).value(forKey: "image") as? String, img.count > 2{
            cell.btnUserImg.sd_setImage(with: URL(string: img), for: .normal, placeholderImage: UIImage(named: "0_you"), completed: nil)
        }
        cell.lblTeeRating.text = "\(selectedRating)"
        cell.lblTeeName.text = selectedTee
        cell.lblTeeSlope.text = "\(selectedSlope)"
        for i in teeArr{
            if(i.name == selectedTee){
                cell.lblTeeType.text = "(\(i.type) Tee)"
            }
        }
        if let userData = self.totalPlayers[indexPath.row] as? NSMutableDictionary{
            userData.addEntries(from: ["tee" : selectedTee.lowercased()])
            userData.addEntries(from: ["handicap" : String(self.handicap[indexPath.row]) == "0.0" ? "18.0":String(self.handicap[indexPath.row])])
            debugPrint(userData)
        }
        
        
        return cell
    }
    @objc func btnActionHadicap(sender:UIButton){
        debugPrint("Handicap Action")
        if let userData = self.totalPlayers[sender.tag] as? NSMutableDictionary{
            let alert = UIAlertController(title: "\(userData.value(forKey: "name") as! String)", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "-"
                textField.keyboardType = UIKeyboardType.decimalPad
            }
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields!.first!
                self.handicap[sender.tag] = Double(textField.text as! String) != nil ? Double(textField.text as! String)! : 18.0
                userData.addEntries(from: ["handicap" : "\(self.handicap[sender.tag])"])
                let cell = self.tableViewMultiplayerTee.cellForRow(at: IndexPath(row: sender.tag, section: 0))  as! MultiplayerTeeSelectionTableViewCell
                cell.btnHandicap.setTitle("\(self.handicap[sender.tag])", for: .normal)
                debugPrint(userData)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func btnActionSelectTee(sender:UIButton){
        debugPrint("selectedTee Clicked")
        let cell = self.tableViewMultiplayerTee.cellForRow(at: IndexPath(row: sender.tag, section: 0))  as! MultiplayerTeeSelectionTableViewCell
        let myController = UIAlertController(title: "Select Tee", message: "Please select your Tee according to your Handicap", preferredStyle: UIAlertControllerStyle.actionSheet)
        let messageAttributed = NSMutableAttributedString(
            string: myController.message!,
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.glfBluegreen, NSAttributedStringKey.font: UIFont(name: "SFProDisplay-Medium", size: 15.0)!])
        myController.setValue(messageAttributed, forKey: "attributedMessage")
        var i = 0
        for tee in teeArr{
            let whiteTee = (UIAlertAction(title: "\(tee.name) (\(tee.type) Tee)", style: UIAlertActionStyle.default, handler: { action in
                cell.lblTeeName.text = "\(tee.name)"
                cell.lblTeeType.text = "(\(tee.type) Tee)"
                cell.lblTeeRating.text = tee.rating
                cell.lblTeeSlope.text = tee.slope
                if let userData = self.totalPlayers[sender.tag] as? NSMutableDictionary{
                    userData.addEntries(from: ["tee" : tee.type.lowercased()])
                    debugPrint(userData)
                }
            }))
            myController.addAction(whiteTee)
            i += 1
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            debugPrint("Cancelled")
        })
        myController.addAction(cancelOption)
        present(myController, animated: true, completion: nil)
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
