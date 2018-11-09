//
//  SessionViewController.swift
//  Golfication
//
//  Created by IndiRenters on 10/25/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SessionViewController:  UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var roundsTable: UITableView!
    var actvtIndView: UIActivityIndicatorView!
    var roundsWithSection = [RoundsWithSection]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupActivityIndicator()

    }
    //-------- Set Rounds in Table Data ---------------
    func setData(dataArray: NSArray){
        var roundDict = [(String,Rounds)]()
        //print("dataArray :\(dataArray)")
        for i in 0..<dataArray.count {
            let round = Rounds()
            round.timestamp = ((dataArray[i] as AnyObject).object(forKey:"timestamp") as! NSNumber).doubleValue
            let date = NSDate(timeIntervalSince1970:(round.timestamp)/1000)
            let section = date.toString(dateFormat: "MMMM YY")
            round.date = date.toString(dateFormat: "dd MMMM YY")
            round.avgScore = ((dataArray[i] as AnyObject).object(forKey:"avgScore") as! NSNumber).doubleValue
            round.clubs = ((dataArray[i] as AnyObject).object(forKey:"clubs") as! NSNumber).intValue
            round.playType = ((dataArray[i] as AnyObject).object(forKey:"playType") as! String)
            round.roundName = ((dataArray[i] as AnyObject).object(forKey:"roundName") as! String)
            round.swings = ((dataArray[i] as AnyObject).object(forKey:"swings") as! NSDictionary)
            round.numSwings = ((dataArray[i] as AnyObject).object(forKey:"numSwings") as! NSNumber).intValue
            roundDict.append((section,round))
        }
        
        //Descending Order of time
        roundDict.sort{($0.1).timestamp > ($1.1).timestamp}
        roundsWithSection = [RoundsWithSection]()
        // creating Model object and initializing them monthwise
        var i = 0
        var j = 0
        while i <= roundDict.count-1 {
            let temp = roundDict[i]
            let round = RoundsWithSection()
            round.sections = temp.0
            round.rows = [temp.1]
            while(j <= roundDict.count-1){
                if(i != roundDict.count-1){
                    if temp.0 == roundDict[i+1].0{
                        round.addSection(row: roundDict[i+1].1)
                        i += 1
                    }
                    else{
                        break
                    }
                }
                j = j+1
            }
            i += 1
            roundsWithSection.append(round)
        }
        //print("roundWithSectionArray: \(roundsWithSection)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        //print("numberOfSections:\(roundsWithSection.count)")
        return roundsWithSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection:\(roundsWithSection[section].rows).count)")
        return (roundsWithSection[section].rows).count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //-------- Load sessionReportViewController while user click on cell ---------------
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let sessionReportVC = storyboard.instantiateViewController(withIdentifier: "SessionReportVC") as! SessionReportVC
        sessionReportVC.title = roundsWithSection[indexPath.section].rows[indexPath.row].date!
        sessionReportVC.swings = roundsWithSection[indexPath.section].rows[indexPath.row].swings!
        self.navigationController?.pushViewController(sessionReportVC, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;
    }
            //-------- Set section in Table ---------------
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return roundsWithSection[section].sections
    }
                //-------- Set cell to show data  ---------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MySwingSessionCell") as! SessionTableViewCell
        var swingTitle = "Swings"
        var clubTitle = "Clubs"
        
        cell.sessionCircularVw.setProgress(value: CGFloat(roundsWithSection[indexPath.section].rows[indexPath.row].avgScore!), animationDuration: 1.0)
        
        cell.lblTitle.text = "\(roundsWithSection[indexPath.section].rows[indexPath.row].date!), \(roundsWithSection[indexPath.section].rows[indexPath.row].roundName!)"
        
        if roundsWithSection[indexPath.section].rows[indexPath.row].numSwings == 1{
            swingTitle = "Swing"
        }
        
        if(roundsWithSection[indexPath.section].rows[indexPath.row].clubs == 1){
            clubTitle = "Club"
        }
        cell.lblSubTitle.text = "\(roundsWithSection[indexPath.section].rows[indexPath.row].numSwings ?? 0) \(swingTitle), \(roundsWithSection[indexPath.section].rows[indexPath.row].clubs ?? 0) \(clubTitle)"
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Session")
    }
    func setupActivityIndicator(){
        actvtIndView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        actvtIndView.color = UIColor.darkGray
        actvtIndView.center = view.center
        actvtIndView.startAnimating()
        self.view.addSubview(actvtIndView)
        actvtIndView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var dataDic = NSDictionary()
        var dataArray = NSArray()

        //-------- Getting SwingRound Data form Firebase ---------------
        let appnedPath = "swingRounds"
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: appnedPath) { (snapshot) in
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? NSDictionary)!
            }
            self.actvtIndView.startAnimating()
            self.view.isUserInteractionEnabled = false
            //print("dataDic :\(dataDic)")
            DispatchQueue.main.async( execute: {
                self.actvtIndView.stopAnimating()
                self.actvtIndView.isHidden = true
                self.view.isUserInteractionEnabled = true
                dataArray = dataDic.allValues as NSArray
                self.setFilteredData(dataArray: dataArray)
                self.roundsTable.reloadData()
            })
        }
    }
    func setFilteredData(dataArray: NSArray) {
        var playTypeArray:[String] = []
        if Constants.finalFilterDic.count > 0 {
            var filteredDataArray = Array<Any>()
            playTypeArray = Constants.finalFilterDic.value(forKey: "PlayTypeArray") as! [String]
            if (playTypeArray.count > 0){
            for playType in playTypeArray{
                for i in 0..<dataArray.count{
                    if(((dataArray[i] as AnyObject).object(forKey:"playType") as! String) == playType){
                        filteredDataArray.append(dataArray[i])
                    }
                }
            }
            self.setData(dataArray: filteredDataArray as NSArray)
            //print("Filtered Array : \(filteredDataArray)")
            }
            else{
                self.setData(dataArray: dataArray)

            }
        }
        else{
                self.setData(dataArray: dataArray)
        }
    }
}
