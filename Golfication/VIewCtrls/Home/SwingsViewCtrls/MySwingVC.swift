//
//  MySwingVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import UICircularProgressRing

class MySwingVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var avgSwingCircularVw: UICircularProgressRingView!
    @IBOutlet weak var consistancyCrclrVw: UICircularProgressRingView!
    
    @IBOutlet weak var lblClubUsed: UILabel!
    @IBOutlet weak var lblSwingTempo: UILabel!
    @IBOutlet weak var lblBackSwing: UILabel!
    @IBOutlet weak var lblSwingPlane: UILabel!
    
    @IBOutlet weak var lblIronVal: UILabel!
    @IBOutlet weak var lblHybridVal: UILabel!
    @IBOutlet weak var lblWoodVal: UILabel!
    @IBOutlet weak var lblDriverVal: UILabel!
    
    @IBOutlet weak var lblIron: UILabel!
    @IBOutlet weak var lblHybrid: UILabel!
    @IBOutlet weak var lblWood: UILabel!
    @IBOutlet weak var lblDriver: UILabel!
    @IBOutlet weak var stackVwClubHdSpeed: UIStackView!
    

    var filteredArray: [NSDictionary] = []
    var swingDataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        var RSTypeArray: [String] = []
        var PlayTypeArray: [String] = []
        var CSTypeArray: [String] = []
        
        if finalFilterDic.count>0 {
            
            RSTypeArray = finalFilterDic.value(forKey: "RSTypeArray") as! [String]
            PlayTypeArray = finalFilterDic.value(forKey: "PlayTypeArray") as! [String]
            CSTypeArray = finalFilterDic.value(forKey: "CSTypeArray") as! [String]
        }
        if RSTypeArray.count>0 || PlayTypeArray.count>0 || CSTypeArray.count>0{
            
            self.getFilteredValue(roundTimeArr: RSTypeArray, playTypeArr: PlayTypeArray, clubArr: CSTypeArray)
        }
        else{
            self.getDefaultValue()
        }
    }
    
    func getFilteredValue(roundTimeArr: [String], playTypeArr: [String], clubArr: [String] ){
        
        if self.filteredArray.count>0{
            self.filteredArray.removeAll()
            self.filteredArray = []
        }
        let marrPredicates = NSMutableArray()
        var swingRoundArray = [String]()
        
        var roundTimeTypeStr = ""
        
        var last4Char: String = ""
        var timeStr: String = ""
        var newTimeStamp = 0.0
        
        for i in 0..<roundTimeArr.count{
            timeStr = roundTimeArr[i]
            last4Char = String(timeStr.suffix(4))
            
            if last4Char == "Days"{
                let newTimeStr = timeStr.dropLast(5)
                var timeStampInDays = 2592000000.0 // 30 Days timestamp
                if newTimeStr == "90"{
                    timeStampInDays = timeStampInDays*3
                }
                else if newTimeStr == "180"{
                    timeStampInDays = timeStampInDays*6
                }
                let nowDouble = (NSDate().timeIntervalSince1970) * 1000
                newTimeStamp = nowDouble - timeStampInDays
            }
            else{
                // for rounds
                
                for i in 0..<self.swingDataArray.count {
                    
                    let swingRound = (self.swingDataArray[i] as AnyObject).object(forKey:"round") as! String
                    swingRoundArray.append(swingRound)
                }
            }
            swingRoundArray = Array(Set(swingRoundArray))
            swingRoundArray.sort()
            
        }
        
//        var selectedRoundArray: ArraySlice = [""]
          var selectedRoundArray = ArraySlice<String>() // changed by shubham
        
        if last4Char == "Days"{
            
            roundTimeTypeStr.append("self.timestamp >= '\(NSNumber(value:newTimeStamp))'")
            
            let roundTimeTypePredicate = NSPredicate(format: ("self.timestamp >= \(NSNumber(value:newTimeStamp))"))
            marrPredicates.add(roundTimeTypePredicate)
        }
        else{
            // for rounds
            if roundTimeArr.contains("10 Rounds"){
                
                let round10Array = swingRoundArray.suffix(10)
                selectedRoundArray = round10Array
            }
            else if roundTimeArr.contains("20 Rounds"){
                
                let round20Array = swingRoundArray.suffix(20)
                selectedRoundArray = round20Array
            }
            else if roundTimeArr.contains("50 Rounds"){
                
                let round50Array = swingRoundArray.suffix(50)
                selectedRoundArray = round50Array
            }
            //print("selectedRoundArray = ", selectedRoundArray)

            for roundType in selectedRoundArray {
                
                if roundType == selectedRoundArray.last {
                    
                    roundTimeTypeStr.append("self.round == '\(roundType)'")
                    
                    let roundTimeTypePredicate = NSPredicate(format: roundTimeTypeStr)
                    marrPredicates.add(roundTimeTypePredicate)
                }
                else{
                    roundTimeTypeStr.append("self.round == '\(roundType)' or ")
                }
            }
        }
        
        var playTypeStr = ""
        
        for playType in playTypeArr {
            
            if playType == playTypeArr.last {
                
                playTypeStr.append("self.playType == '\(playType)'")
                
                let playTypePredicate = NSPredicate(format: playTypeStr)
                marrPredicates.add(playTypePredicate)
            }
            else {
                
                playTypeStr.append("self.playType == '\(playType)' or ")
            }
        }
        var clubStr = ""
        
        for club in clubArr {
            
            if club == clubArr.last {
                
                clubStr.append("self.club == '\(club)'")
                
                let clubPredicate = NSPredicate(format: clubStr)
                marrPredicates.add(clubPredicate)
            }
                
            else {
                clubStr.append("self.club == '\(club)' or ")
            }
        }
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: marrPredicates as! [NSPredicate])
        
        filteredArray = swingDataArray.filtered(using: andPredicate) as! [NSDictionary]
        //print("filteredArray1 = ", filteredArray)
        
        if filteredArray.count==0{
            
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        self.setData(dataAr: filteredArray)
    }
    
    func getDefaultValue(){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swings") { (snapshot) in
            
            self.actvtIndView.startAnimating()
            self.view.isUserInteractionEnabled = false
            var dataDic = NSMutableDictionary()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? NSMutableDictionary)!
            }
            
            if self.swingDataArray.count>0{
                self.swingDataArray.removeAllObjects()
                self.swingDataArray = NSMutableArray()
            }
            self.swingDataArray.addObjects(from: dataDic.allValues)
            self.actvtIndView.stopAnimating()
            self.actvtIndView.isHidden = true
            self.view.isUserInteractionEnabled = true
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            self.swingDataArray.sortedArray(using: [sortDescriptor])
            //print("dataArray :\(self.swingDataArray)")
            self.setData(dataAr: self.swingDataArray as! [NSDictionary])
            
        }
        //            DispatchQueue.main.async( execute: {
        //
        //            })
    }
    //}
    
    func setData(dataAr: [NSDictionary]){
        
        //-------- Set Avg Swing Data ---------------
        //        let dataArray = dataDic.allValues
        
        var avgBackSwing = 0.0
        var avgDownSwing = 0.0
        var avgBackSwingAngle = 0.0
        var avgSwingPlane = 0.0
        
        var clubArray = [String]()
        
        for i in 0..<dataAr.count {
            
            let backSwing: Double? = ((dataAr[i] as AnyObject).object(forKey:"backswing") as! NSNumber).doubleValue
            
            let downSwing: Double? = ((dataAr[i] as AnyObject).object(forKey:"downswing") as! NSNumber).doubleValue
            
            let backSwingAngle: Double? = ((dataAr[i] as AnyObject).object(forKey:"backswingAngle") as! NSNumber).doubleValue
            
            let swingPlane: Double? = ((dataAr[i] as AnyObject).object(forKey:"plane") as! NSNumber).doubleValue
            
            avgBackSwing += backSwing!
            avgDownSwing += downSwing!
            avgBackSwingAngle += backSwingAngle!
            avgSwingPlane += swingPlane!
            
            let club = ((dataAr[i] as AnyObject).object(forKey:"club")as! String)
            clubArray.append(club)
        }
        
        //-------- Set Avg Swing Score Data ---------------
        let finalAvgBackSwing: Float = Float(avgBackSwing/2)
        self.avgSwingCircularVw.setProgress(value: CGFloat(finalAvgBackSwing*100), animationDuration: 1.0)
        
        //-------- Set Club Used Data ---------------
        
        let uniqueClubArray = Array(Set(clubArray))
        self.lblClubUsed.text =  String(uniqueClubArray.count)
        
        //--------- Set Consistancy Data ---------------
        
        self.consistancyCrclrVw.setProgress(value: CGFloat(finalAvgBackSwing*100), animationDuration: 1.0)
        
        //-------- Set Swing Tempo Data ---------------
        
        let finalAvgDownSwing: Float = Float(avgDownSwing/2)
        
        let swingTempoRatio = finalAvgBackSwing/finalAvgDownSwing
        //print("swingTempoRatio :\(swingTempoRatio)")
        
        //        let val = self.gcd(Int(finalAvgBackSwing),Int(finalAvgDownSwing))
        //        print("val :\(val)")
        //if val != 0{
        
        self.lblSwingTempo.text =  String("\(NSString(format: "%.01f", swingTempoRatio)):\(Int(1))")
        //}
        //else{
        //            self.lblSwingTempo.text =  String("\(Int(finalAvgBackSwing*100)):\(Int(finalAvgDownSwing*100))")
        //}
        
        //-------- Set Back Swing Data ---------------
        let finalAvgBackSwingAngle: Float = Float(avgBackSwingAngle/2)
        self.lblBackSwing.text = String("\(Int(finalAvgBackSwingAngle))d");
        
        //-------- Set Swing Plane Data ---------------
        let finalAvgSwingPlane: Float = Float(avgSwingPlane/2)
        self.lblSwingPlane.text = String("\(finalAvgSwingPlane)%");
        
        //-------- Set Club Head Speed Data ---------------
        
        var totalIron = 0.0
        var totalHybrid = 0.0
        var totalWood = 0.0
        var totalDriver = 0.0
        
        var ironCount = 0
        var hybridCount = 0
        var woodCount = 0
        var driverCount = 0
        
        for i in 0..<clubArray.count {
            let clubSpeed: Double? = ((dataAr[i] as AnyObject).object(forKey:"clubSpeed") as! NSNumber).doubleValue
            
            let clubCtgry = (clubArray[i] as String)
            
            let lastChar = clubCtgry.last!
            
            if lastChar == "i"{
                ironCount = ironCount + 1
                totalIron += clubSpeed!
                
                if ironCount>1{
                    self.lblIronVal.text = String(totalIron/2);
                }
                else{
                    self.lblIronVal.text = String(totalIron);
                }
            }
            else if lastChar == "y"{
                hybridCount = hybridCount + 1
                totalHybrid += clubSpeed!
                
                if hybridCount>1{
                    self.lblHybridVal.text = String(totalHybrid/2);
                }
                else{
                    self.lblHybridVal.text = String(totalHybrid);
                }
            }
            else if lastChar == "w"{
                let index = clubCtgry.index(clubCtgry.endIndex, offsetBy: -2)
                let endChar = clubCtgry[index]
                //print("endChar :\(endChar)")
                
                let digits =  CharacterSet.decimalDigits.contains(endChar.unicodeScalars.first!)
                if digits{
                    self.lblWoodVal.isHidden = false
                    self.lblWood.isHidden = false
                    
                    woodCount = woodCount + 1
                    totalWood += clubSpeed!
                    
                    if woodCount>1{
                        self.lblWoodVal.text = String(totalWood/2);
                    }
                    else{
                        self.lblWoodVal.text = String(totalWood);
                    }
                }
            }
            else if lastChar == "r"{
                driverCount = driverCount + 1
                totalDriver += clubSpeed!
                
                if driverCount>1{
                    self.lblDriverVal.text = String(totalDriver/2);
                }
                else{
                    self.lblDriverVal.text = String(totalDriver);
                }
            }
        }
        if ironCount == 0{
            self.lblIronVal.isHidden = true
            self.lblIron.isHidden = true
        }
        if hybridCount == 0{
            self.lblHybridVal.isHidden = true
            self.lblHybrid.isHidden = true
        }
        if woodCount == 0{
            self.lblWoodVal.isHidden = true
            self.lblWood.isHidden = true
        }
        if driverCount == 0{
            self.lblDriverVal.isHidden = true
            self.lblDriver.isHidden = true
        }
    }
    
    func gcd(_ m: Int, _ n: Int) -> Int {
        var a = 0
        var b = max(m, n)
        var r = min(m, n)
        
        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        return b
    }
    
    func setChart(dataPoints: [String], values: [Double], chartView :PieChartView ) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.legend.enabled = false
        chartView.holeRadiusPercent = 0
        pieChartDataSet.selectionShift = 0
        chartView.highlightPerTapEnabled = false
        chartView.transparentCircleColor = UIColor.clear
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Performance")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

internal extension Date {
    init(_ s: String) {
        let df = DateFormatter()
        df.dateFormat = "MM-d-yyyy"
        guard let date = df.date(from: s) else {
            fatalError("Invalid date string.")
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}
