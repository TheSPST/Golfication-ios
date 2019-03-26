//
//  SessionReportVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/31/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import UICircularProgressRing
import Charts

class SessionReportVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var sessionReportTable: UITableView!
    var actvtIndView: UIActivityIndicatorView!
    var swings = NSDictionary()
    var swingsArray = [Swings]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupActivityIndicator()
        let swingsDict = swings as NSDictionary? as? [String : Bool] ?? [:]
        //print("SwingDictionary from previous data\(swings)")
        self.setData(dataDic: swingsDict)
        
        
    }
            //-------- Set Swing Data ---------------
    func setData(dataDic : [String : Bool]){
        //print("DataDictionary is : \(dataDic)")
        let group = DispatchGroup()
        var count = 0
        for (key,value) in dataDic{
            if value {
                group.enter()
                let swing = Swings()
                ref.child("userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/swings/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        count += 1
                        let swingData = (snapshot.value as? NSDictionary)!
                        //print(swingData)
                        swing.count = count
                        if let backswing = swingData["backswing"] as? Double {
                            swing.backswing = backswing
                        }
                        if let backswingAngle = swingData["backswingAngle"] as? Int {
                            swing.backswingAngle = backswingAngle
                        }
                        if let club = swingData["club"] as? String {
                            swing.club = club
                        }
                        if let clubSpeed = swingData["clubSpeed"] as? Double {
                            swing.clubSpeed = clubSpeed
                        }
                        if let downswing = swingData["downswing"] as? Double {
                            swing.downswing = downswing
                        }
                        if let plane = swingData["plane"] as? Int {
                            swing.plane = plane
                        }
                        if let playType = swingData["playType"] as? String {
                            swing.playType = playType
                        }
                        if let round = swingData["round"] as? String {
                            swing.round = round
                        }
                        if let score = swingData["score"] as? Double {
                            swing.score = score
                        }
                        if let timestamp = swingData["timestamp"] as? Double {
                            swing.timestamp = timestamp
                        }
                        if let video = swingData["video"] as? String {
                            swing.video = video
                        }
                        self.swingsArray.append(swing)

                    }
                    
                    group.leave()
                    
                })
            }
            group.notify(queue: .main) {
                //print("All callbacks are completed\(self.swingsArray)")
                self.actvtIndView.stopAnimating()
                self.actvtIndView.isHidden = true
                self.view.isUserInteractionEnabled = true
                self.sessionReportTable.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return swingsArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(indexPath.row)
        //        let sessionReportVC = storyboard?.instantiateViewController(withIdentifier: "SessionReportVC") as! SessionReportVC
        //        self.navigationController?.pushViewController(sessionReportVC, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionReportTableViewCell") as! SessionReportTableViewCell
        cell.configureWithItem(swing: self.swingsArray[indexPath.item])
        return cell
    }
    
    func setupActivityIndicator(){
        actvtIndView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        actvtIndView.color = UIColor.darkGray
        actvtIndView.center = view.center
        actvtIndView.startAnimating()
        self.view.addSubview(actvtIndView)
        actvtIndView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewDidAppear(animated)
    }
    
}
