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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewMultiplayerTee.delegate = self
        self.tableViewMultiplayerTee.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStartAction(_ sender: Any) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "multiplayerTeeSelectionTableViewCell", for: indexPath) as! MultiplayerTeeSelectionTableViewCell
        
        return cell
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
