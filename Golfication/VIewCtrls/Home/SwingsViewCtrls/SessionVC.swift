//
//  SessionVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://www.anexinet.com/blog/expandable-collapsible-uitableview-sections/

import UIKit
import XLPagerTabStrip
import FirebaseAuth

class SessionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    @IBOutlet weak var sessionTableView: UITableView!

    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    let kHeaderSectionTag: Int = 6900
    
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    
    var sessionMArray = NSMutableArray()
    let progressView = SDLoader()

    var parVal = Int()
    var strokesGainedVal = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let practiceMArray = NSMutableArray()
        let matchMArray = NSMutableArray()

        for i in 0..<sessionMArray.count{
            let dataDic = sessionMArray[i] as! NSDictionary
            
            let swingArray = dataDic.value(forKey: "swings") as! NSMutableArray
            var avgSwingScore = 0.0
            if dataDic.value(forKey: "playType") as! String == "practice"{
                var clubArray = [String]()
                for j in 0..<swingArray.count{
                    let dic = swingArray[j] as! NSDictionary
                    clubArray.append(dic.value(forKey: "club") as! String)
                    clubArray = Array(Set(clubArray))
                }
                let practiceDic = NSMutableDictionary()
                practiceDic.setValue(dataDic.value(forKey: "timestamp"), forKey: "timestamp")
                practiceDic.setValue(swingArray.count, forKey: "swing")
                for data in swingArray{
                    avgSwingScore += (data as! NSMutableDictionary).value(forKey: "swingScore") as! Double
                }
                practiceDic.setValue(avgSwingScore/Double(swingArray.count), forKey: "swingScoreAvg")
                practiceDic.setValue(clubArray.count, forKey: "club")
                practiceDic.setValue(swingArray, forKey: "swingArray")

                practiceMArray.add(practiceDic)
            }
            else{
                var clubArray = [String]()
                var holeShot = [(key:String,hole:Int,shot:Int)]()
                for j in 0..<swingArray.count{
                    let dic = swingArray[j] as! NSDictionary
                    clubArray.append(dic.value(forKey: "club") as! String)
                    clubArray = Array(Set(clubArray))
                    avgSwingScore += dic.value(forKey: "swingScore") as! Double
                    if let key = dataDic.value(forKey: "matchKey") as? String{
                        let holeNum = dic.value(forKey: "holeNum") as! Int
                        let shotNum = dic.value(forKey: "shotNum") as! Int
                        holeShot.append((key:key,hole: holeNum-1, shot: shotNum-1))
                    }
                }
                let matchDic = NSMutableDictionary()
                matchDic.setValue(avgSwingScore/Double(swingArray.count), forKey: "swingScoreAvg")
                matchDic.setValue(dataDic.value(forKey: "timestamp"), forKey: "timestamp")
                matchDic.setValue(swingArray.count, forKey: "swing")
                matchDic.setValue(clubArray.count, forKey: "club")
                matchDic.setValue(dataDic.value(forKey: "courseName"), forKey: "courseName")
                matchDic.setValue(swingArray, forKey: "swingArray")
                matchDic.setValue(dataDic.value(forKey: "matchKey"), forKey: "matchKey")
                matchDic.setValue(holeShot, forKey: "holeShot")
                matchMArray.add(matchDic)
            }
        }
        
        if practiceMArray.count>0 && matchMArray.count>0{
            sectionNames = ["Practise Session(\(practiceMArray.count))", "Rounds Played(\(matchMArray.count))"]
            sectionItems = [practiceMArray, matchMArray]
            debugPrint("sectionItems == ",sectionItems)
        }
        else if practiceMArray.count == 0 && matchMArray.count == 0{
            sectionNames = []
            sectionItems = []

        }
        else if practiceMArray.count > 0 && matchMArray.count == 0{
            sectionNames = ["Practise Session(\(practiceMArray.count))"]
            sectionItems = [practiceMArray]
        }
        else if practiceMArray.count == 0 && matchMArray.count > 0{
            sectionNames = ["Rounds Played(\(matchMArray.count))"]
            sectionItems = [matchMArray]
        }
        
        self.sessionTableView.delegate = self
        self.sessionTableView.dataSource = self
        self.sessionTableView.reloadData()
        }
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.sessionTableView.backgroundView = messageLabel
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.10)
        
        let label = UILabel()
        
        label.frame = CGRect(x: 10, y: 0, width: 200, height: 44.0)
        label.text = self.sectionNames[section] as? String
        label.textColor = UIColor.glfBluegreen
        header.addSubview(label)
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.sessionTableView.frame.size
        
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell") as! SessionTableViewCell
        let array = self.sectionItems[indexPath.section] as! NSArray
        
        let unixTimestamp = ((array[indexPath.row] as AnyObject).value(forKey:"timestamp") as! Double)/1000
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMM d, yyyy"
        let strDate = dateFormatter.string(from: date)

        cell.lblDate.text = strDate
        cell.lblSwingClub.text = "\((array[indexPath.row] as AnyObject).value(forKey:"swing") as! Int)" + " Swing(s), " + "\((array[indexPath.row] as AnyObject).value(forKey:"club") as! Int)" + " Club(s)"
        cell.lblAvg.text = String(Int((array[indexPath.row] as AnyObject).value(forKey:"swingScoreAvg") as! Double))
        if indexPath.section == 0{
            var incr = array.count
            incr = incr - indexPath.row
            cell.lblSession.text = "Session" + "\(incr)"
        }
        else{
            cell.lblSession.text = (array[indexPath.row] as AnyObject).value(forKey:"courseName") as? String
        }
        //cell.lblAvg.text = ""

        cell.avgCircleView.layer.cornerRadius = cell.avgCircleView.frame.size.height/2

        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "PracticePageContainerVC") as! PracticePageContainerVC
//        viewCtrl.swingKey = swingKey
        let array = self.sectionItems[indexPath.section] as! NSArray
        var shotsAr = [String]()
        let swingArr = (array[indexPath.row] as AnyObject).value(forKey:"swingArray") as! NSArray
        viewCtrl.count = swingArr.count
        for i in 0..<swingArr.count{
            shotsAr.append("Shot \(i+1)")
        }
        viewCtrl.shotsArray = shotsAr
        viewCtrl.tempArray1 = swingArr
        if indexPath.section == 0{
            viewCtrl.fromRoundsPlayed = false
            viewCtrl.title = "Practice Session \(indexPath.row+1)"
        }
        else{
            viewCtrl.fromRoundsPlayed = true
            viewCtrl.holeShot = (array[indexPath.row] as AnyObject).value(forKey:"holeShot") as! [(key:String,hole:Int,shot:Int)]
            viewCtrl.title = (array[indexPath.row] as AnyObject).value(forKey:"courseName") as? String
        }
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Expand / Collapse Methods
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        
        let headerView = sender.view!
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            }
            else {
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        
        let sectionData = self.sectionItems[section] as! NSArray
        self.expandedSectionHeaderNumber = -1
        if (sectionData.count == 0) {
            return
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.sessionTableView!.beginUpdates()
            self.sessionTableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.sessionTableView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        
        let sectionData = self.sectionItems[section] as! NSArray
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1
            return
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.sessionTableView!.beginUpdates()
            self.sessionTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.sessionTableView!.endUpdates()
        }
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Session")
    }

}
