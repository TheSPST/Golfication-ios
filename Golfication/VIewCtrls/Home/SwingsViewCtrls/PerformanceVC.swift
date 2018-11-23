//
//  PerformanceVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import UICircularProgressRing
import Charts

class PerformanceVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var golfBagScrlView: UIScrollView!
    @IBOutlet weak var clubHeadScrlView: UIScrollView!
    
    @IBOutlet weak var lblBackSwingTempo: UILabel!
    @IBOutlet weak var lblDownSwingTempo: UILabel!

    @IBOutlet weak var lblBackSwing: UILabel!
    @IBOutlet weak var lblDwnSwing: UILabel!
    @IBOutlet weak var lblSwingScore: UILabel!
    @IBOutlet weak var lblHandSpeed: UILabel!
    @IBOutlet weak var lblTempoColon: UILabel!

    @IBOutlet weak var customColorSlider: CustomColorSlider!
    @IBOutlet weak var headSpeedLineChart: LineChartView!
    @IBOutlet weak var avgSwingCircularVw: UICircularProgressRingView!

    @IBOutlet weak var clubHeadSpeedView: UIView!

    @IBOutlet weak var backSwingUserImg: UIImageView!
//    @IBOutlet weak var backSwingClub: UIImageView!
    var backSwingAngleAvg = 0.0
    @IBOutlet weak var swingAngleCircular_Red: UICircularProgressRingView!
    @IBOutlet weak var swingAngleCircular_Blue: UICircularProgressRingView!
    var backSwingClub : UIImageView!


    var performanceMArray = NSMutableArray()
    var swingArray = NSMutableArray()
    var clubArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avgSwingCircularVw.fontColor = UIColor.clear
        self.avgSwingCircularVw.innerCapStyle = .square
        self.avgSwingCircularVw.outerCapStyle = .square
        
        customColorSlider.minimumValue = 0
        customColorSlider.maximumValue = 6
        clubArray = [String]()
        for i in 0..<performanceMArray.count{
            let dataDic = performanceMArray[i] as! NSDictionary
            let tempSwingArray = dataDic.value(forKey: "swings") as! NSMutableArray
            for j in 0..<tempSwingArray.count{
                let dic = tempSwingArray[j] as! NSDictionary
                
                clubArray.append(dic.value(forKey: "club") as! String)
                swingArray.add(dic)
            }
        }
        clubArray = Array(Set(clubArray))

        let tempArray = ["Dr", "3w", "1i", "1h", "2h", "3h", "2i", "4w", "4h", "3i", "5w", "5h", "4i", "7w", "6h", "5i", "7h", "6i", "7i", "8i", "9i", "Pw", "Gw", "Sw", "Lw"]
        var tempArray2 = [String]()
        for j in 0..<tempArray.count{
            if clubArray.contains(tempArray[j]){
                tempArray2.append(tempArray[j])
            }
        }
        clubArray.removeAll()
        clubArray = [String]()
        clubArray = tempArray2
        clubArray.insert("All Clubs", at: 0)
        
        setClubHeadSpeed()
        setGolfBagUI(tag: 0)
        setPerformanceData(tag: 0)
    }
    
    func setClubHeadSpeed() {
        var ironCount = 0
        var hybridCount = 0
        var driverCount = 0
        var putterCount = 0
        var wedgeCount = 0
        var woodCount = 0

        var ironClubSpeedSum = 0.0
        var hybridClubSpeedSum = 0.0
        var driverClubSpeedSum = 0.0
        var putterClubSpeedSum = 0.0
        var wedgeClubSpeedSum = 0.0
        var woodClubSpeedSum = 0.0

        var commanArray = [String]()
        var clubHeadAvgArray = [Int]()

        for j in 0..<clubArray.count{
            let clubName = clubArray[j]
            let lastChar = clubName.last!
            
            if lastChar == "i"{
                if !commanArray.contains("Iron(s)"){
                    commanArray.append("Iron(s)")
                }
            }
            else if lastChar == "h"{
                if !commanArray.contains("Hybrid(s)"){
                    commanArray.append("Hybrid(s)")
                }
            }
            else if lastChar == "r"{
                if !commanArray.contains("Driver(s)"){
                    commanArray.append("Driver(s)")
                }
            }
            else if lastChar == "u"{
                if !commanArray.contains("Putter(s)"){
                    commanArray.append("Putter(s)")
                }
            }
            else if lastChar == "w"{
                if clubName == "Pw" || clubName == "Sw" || clubName == "Gw" || clubName == "Lw"{
                    if !commanArray.contains("Wedge(s)"){
                        commanArray.append("Wedge(s)")
                    }
                }
                else{
                    if !commanArray.contains("Woods(s)"){
                        commanArray.append("Woods(s)")
                    }
                }
            }
        }
        
        for j in 0..<commanArray.count{
            let clubName = commanArray[j]
                for i in 0..<swingArray.count{
                    let dataDic = swingArray[i] as! NSDictionary
                    if clubName == "Iron(s)" && (dataDic.value(forKey: "club") as! String).last == "i"{
                        ironCount = ironCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        ironClubSpeedSum += clubSpeed
                    }
                    else if clubName == "Hybrid(s)" && (dataDic.value(forKey: "club") as! String).last == "h"{
                        hybridCount = hybridCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        hybridClubSpeedSum += clubSpeed
                    }
                    else if clubName == "Driver(s)" && (dataDic.value(forKey: "club") as! String).last == "r"{
                        driverCount = driverCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        driverClubSpeedSum += clubSpeed
                    }
                    else if clubName == "Putter(s)" && (dataDic.value(forKey: "club") as! String).last == "u"{
                        putterCount = putterCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        putterClubSpeedSum += clubSpeed
                    }
                    else if clubName == "Wedge(s)" && ((dataDic.value(forKey: "club") as! String) == "Pw" || (dataDic.value(forKey: "club") as! String) == "Sw" || (dataDic.value(forKey: "club") as! String) == "Gw" || (dataDic.value(forKey: "club") as! String) == "Lw"){
                        wedgeCount = wedgeCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        wedgeClubSpeedSum += clubSpeed
                    }
                    else if clubName == "Woods(s)" && ((dataDic.value(forKey: "club") as! String) == "3w" || (dataDic.value(forKey: "club") as! String) == "4w" || (dataDic.value(forKey: "club") as! String) == "5w" || (dataDic.value(forKey: "club") as! String) == "7w"){
                        woodCount = woodCount + 1
                        let clubSpeed = (dataDic.value(forKey: "clubSpeed") as! Double)
                        woodClubSpeedSum += clubSpeed
                    }
                }
         }
        if driverCount != 0{
            let finalDriverClubSpeed = (driverClubSpeedSum/(Double(driverCount)))
            clubHeadAvgArray.append(Int(finalDriverClubSpeed))
        }
        if woodCount != 0{
            let finalWoodClubSpeed = (woodClubSpeedSum/(Double(woodCount)))
            clubHeadAvgArray.append(Int(finalWoodClubSpeed))
        }
        if hybridCount != 0{
            let finalHybridClubSpeed = (hybridClubSpeedSum/(Double(hybridCount)))
            clubHeadAvgArray.append(Int(finalHybridClubSpeed))
        }
        if ironCount != 0{
            let finalIronClubSpeed = (ironClubSpeedSum/(Double(ironCount)))
            clubHeadAvgArray.append(Int(finalIronClubSpeed))
        }
        if wedgeCount != 0{
            let finalWedgeClubSpeed = (wedgeClubSpeedSum/(Double(wedgeCount)))
            clubHeadAvgArray.append(Int(finalWedgeClubSpeed))
        }
        if putterCount != 0{
            let finalPutterClubSpeed = (putterClubSpeedSum/(Double(putterCount)))
            clubHeadAvgArray.append(Int(finalPutterClubSpeed))
        }

        // ---------------------------------------------------------------
        if commanArray.count == clubHeadAvgArray.count{
            clubHeadSpeedView.isHidden = false

        for subV in clubHeadScrlView.subviews{
            subV.removeFromSuperview()
        }
        
        let clubHeadContainerView = UIView()
        clubHeadContainerView.backgroundColor = UIColor.clear
        
        let subViewWidth = 105.0
        let subViewHeight = Double(clubHeadScrlView.frame.size.height)
        var xOffset = 0.0
        let yOffset = 10.0
        let horzSpace = 10.0
        
        for j in 0..<commanArray.count{
            let clubName = commanArray[j]
            
            let subView = CardView()
            subView.frame = CGRect(x: xOffset, y: yOffset, width: subViewWidth, height: subViewHeight-20)
            subView.tag = j
            subView.backgroundColor = UIColor.white
            clubHeadContainerView.addSubview(subView)
            
            let speedLbl = UILabel()
            speedLbl.frame = CGRect(x: 0, y: 7, width: subViewWidth, height: 50)
            speedLbl.textColor = UIColor.black
            speedLbl.font = UIFont(name: "SFProDisplay-Regular", size: 50.0)
            speedLbl.text = "\(clubHeadAvgArray[j])"
            speedLbl.textAlignment = .center
            subView.addSubview(speedLbl)
            
            let kphLbl = UILabel()
            kphLbl.frame = CGRect(x: 0, y: Double(speedLbl.frame.size.height + speedLbl.frame.origin.y), width: subViewWidth, height: 18)
            kphLbl.textColor = UIColor(rgb: 0xA0B5AF)
            kphLbl.textAlignment = .center
            kphLbl.font = UIFont(name: "SFProDisplay-Regular", size: 13.0)
            kphLbl.text = "KPH"
            subView.addSubview(kphLbl)
            
            let clubLbl = UILabel()
            clubLbl.frame = CGRect(x: 0, y: Double(kphLbl.frame.size.height + kphLbl.frame.origin.y) + 7, width: subViewWidth, height: 23)
            clubLbl.textColor = UIColor(rgb: 0x3A7CA5)
            clubLbl.textAlignment = .center
            clubLbl.font = UIFont(name: "SFProDisplay-Regular", size: 17.0)
            clubLbl.text = clubName
            subView.addSubview(clubLbl)
            
            xOffset = Double(CGFloat(j+1) * (CGFloat(subViewWidth) + CGFloat(horzSpace)))
        }
        clubHeadContainerView.frame = CGRect(x: horzSpace, y: 0, width: xOffset - horzSpace, height: yOffset + subViewHeight)
        clubHeadScrlView.addSubview(clubHeadContainerView)
        clubHeadScrlView.contentSize = CGSize(width: CGFloat(xOffset + horzSpace), height: clubHeadScrlView.frame.size.height)
        }
        else{
            clubHeadSpeedView.isHidden = true
        }
    }
    
    func setPerformanceData(tag: Int) {
        var avgBackSwing = 0.0
        var avgDwnSwing = 0.0
        var avgSwingTempo = 0.0
        var numOfItems = 0
        var swingScoreSum = 0.0
        
        var vH1Sum = 0.0
        var vH2Sum = 0.0
        var vH3Sum = 0.0
        var handSpeedSum = 0.0
        var backSwingAngleSum = 0.0
        var clubNameSwingArray = [String]()
        for i in 0..<swingArray.count{
            let dataDic = swingArray[i] as! NSDictionary
            clubNameSwingArray.append((dataDic.value(forKey: "club") as! String))
        }
        clubNameSwingArray = Array(Set(clubNameSwingArray))

        if clubNameSwingArray.contains(clubArray[tag]){
            for i in 0..<swingArray.count{
                let dataDic = swingArray[i] as! NSDictionary
                
                if clubArray[tag] == (dataDic.value(forKey: "club") as! String){
                    numOfItems = numOfItems + 1
                    let tempo = (dataDic.value(forKey: "tempo") as! Double)
                    let backSwing = (dataDic.value(forKey: "backSwing") as! Double)
                    let downSwing = (dataDic.value(forKey: "downSwing") as! Double)
                    let backS = (dataDic.value(forKey: "backSwingAngle") as! Double)
                    let swingScore = (dataDic.value(forKey: "swingScore") as! Double)
                    
                    let vH1 = (dataDic.value(forKey: "VH1") as! Double)
                    let vH2 = (dataDic.value(forKey: "VH2") as! Double)
                    let vH3 = (dataDic.value(forKey: "VH3") as! Double)
                    let handSpeed = (dataDic.value(forKey: "handSpeed") as! Double)
                    
                    handSpeedSum += handSpeed
                    
                    vH1Sum += vH1
                    vH2Sum += vH2
                    vH3Sum += vH3
                    
                    avgSwingTempo += tempo
                    avgBackSwing += backSwing
                    avgDwnSwing += downSwing
                    swingScoreSum += swingScore
                    backSwingAngleSum += backS
                }
            }
        }
        else{
            for i in 0..<swingArray.count{
                let dataDic = swingArray[i] as! NSDictionary
                
                    numOfItems = numOfItems + 1
                    let tempo = (dataDic.value(forKey: "tempo") as! Double)
                    let backSwing = (dataDic.value(forKey: "backSwing") as! Double)
                    let downSwing = (dataDic.value(forKey: "downSwing") as! Double)
                    let backS = (dataDic.value(forKey: "backSwingAngle") as! Double)
                    let swingScore = (dataDic.value(forKey: "swingScore") as! Double)
                    
                    let vH1 = (dataDic.value(forKey: "VH1") as! Double)
                    let vH2 = (dataDic.value(forKey: "VH2") as! Double)
                    let vH3 = (dataDic.value(forKey: "VH3") as! Double)
                    let handSpeed = (dataDic.value(forKey: "handSpeed") as! Double)
                    
                    handSpeedSum += handSpeed
                    
                    vH1Sum += vH1
                    vH2Sum += vH2
                    vH3Sum += vH3
                    
                    avgSwingTempo += tempo
                    avgBackSwing += backSwing
                    avgDwnSwing += downSwing
                    swingScoreSum += swingScore
                    backSwingAngleSum += backS
            }
        }
        
        let avgVh1 = (vH1Sum/(Double(numOfItems)))
        let avgVh2 = (vH2Sum/(Double(numOfItems)))
        let avgVh3 = (vH3Sum/(Double(numOfItems)))
        
        let avgHandSpeed = (handSpeedSum/(Double(numOfItems)))
        lblHandSpeed.text = "\((avgHandSpeed).rounded(toPlaces: 2))"
        
        let finalAvgSwingTempo = (avgSwingTempo/(Double(numOfItems)))
        self.lblBackSwingTempo.text = String(format: "%.01f", finalAvgSwingTempo)
        self.lblDownSwingTempo.text = "1"
        self.backSwingAngleAvg = (backSwingAngleSum/Double(numOfItems))
        if(finalAvgSwingTempo>=3.7 || finalAvgSwingTempo<=2.3){
           self.lblBackSwingTempo.textColor = UIColor.red
            self.lblDownSwingTempo.textColor = UIColor.red
            lblTempoColon.textColor = UIColor.red
            
        }else if(finalAvgSwingTempo>=2.7 || finalAvgSwingTempo<=3.3){
            self.lblBackSwingTempo.textColor = UIColor.green
            self.lblDownSwingTempo.textColor = UIColor.green
            lblTempoColon.textColor = UIColor.green
        }else{
            self.lblBackSwingTempo.textColor = UIColor.yellow
            self.lblDownSwingTempo.textColor = UIColor.yellow
            lblTempoColon.textColor = UIColor.yellow
        }
        
        let finalAvgBackSwing = (avgBackSwing/(Double(numOfItems)))
        self.lblBackSwing.text = String(format: "%.03f sec", finalAvgBackSwing)
        
        let finalAvgDwnSwing = (avgDwnSwing/(Double(numOfItems)))
        self.lblDwnSwing.text = String(format: "%.03f sec", finalAvgDwnSwing)
        
        let avgSwing = swingScoreSum/Double(numOfItems)
        lblSwingScore.text = "\(Int(avgSwing))"
        DispatchQueue.main.async(execute: {
            self.avgSwingCircularVw.setProgress(value: CGFloat(Int(avgSwing)), animationDuration: 1)
            self.customColorSlider.setValue(CGFloat(finalAvgSwingTempo), animated: true)
        })
        
        customColorSlider.isEnabled = false
        customColorSlider.actionBlock = {slider,newvalue in
            debugPrint("newValue== ",newvalue)
        }
        
        debugPrint("ChartValues== ","avgVh1: \(avgVh1)","avgVh2: \(avgVh2)","avgVh3: \(avgVh3)")
        headSpeedLineChart.setLineChartHandSpeed(dataPoints:["", "", "", "", "", "" ,"" ,"" ,"" ,"","",""] , values: [0.2, 0.5, 1.0, 2.2,avgVh1,1.7,2.5,avgVh2,4.9,avgVh3,10.6,5.0], chartView: headSpeedLineChart,color:UIColor.glfFlatBlue)
        setBackSwingAngleDesign()
    }
    
    func setBackSwingAngleDesign(){
        swingAngleCircular_Red.shouldShowValueText = false
        swingAngleCircular_Blue.shouldShowValueText = false
        debugPrint("backSwingAngleAvg",backSwingAngleAvg)
        self.backSwingClub = UIImageView.init(image: UIImage(named: "club_horizontal"))
        backSwingClub.tag = 23

        for view in self.swingAngleCircular_Red.subviews where view is UIImageView{
            if view.tag == 23 {
                view.removeFromSuperview()
            }
        }
        var setBackSwingProgress = self.backSwingAngleAvg*75/270;
        if(self.backSwingAngleAvg>270){
            setBackSwingProgress = self.backSwingAngleAvg*80/270;
        }
        let swing = Double(setBackSwingProgress * 62 / 100)
        DispatchQueue.main.async {
            if(swing>=46){
                self.swingAngleCircular_Red.setProgress(value:(CGFloat(46 + (Int(swing)-46)/2)), animationDuration:2)
                self.swingAngleCircular_Blue.setProgress(value: 46, animationDuration: 1)
            }else{
                self.swingAngleCircular_Red.setProgress(value:46,animationDuration:2)
                self.swingAngleCircular_Blue.setProgress(value:CGFloat(swing), animationDuration:1)
            }
        }
        let newSwing = ceil(self.backSwingAngleAvg/10)*10
        if self.backSwingAngleAvg >= 0 && self.backSwingAngleAvg < 100{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_0_100")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.maxY*0.485
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width*0.9
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
            backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(-90)) / 180.0 * CGFloat(Double.pi))
            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(self.backSwingAngleAvg-90)) / 180.0 * CGFloat(Double.pi))
            }
        }else if self.backSwingAngleAvg >= 100 && self.backSwingAngleAvg < 200{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_100_200")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.maxY*0.285
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(newSwing-100)) / 180.0 * CGFloat(Double.pi))
            }
        }else if self.backSwingAngleAvg >= 200 && self.backSwingAngleAvg < 350{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_190_290")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.minY-backSwingClub.frame.height*0.5
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width*0.8
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(newSwing-100)) / 180.0 * CGFloat(Double.pi))
            }
        }
        self.swingAngleCircular_Red.addSubview(backSwingClub)
        swingAngleCircular_Red.addSubview(backSwingUserImg)

//        backSwingUserImg.bringSubview(toFront: backSwingClub)
    }
    func setGolfBagUI(tag: Int) {
        for subV in golfBagScrlView.subviews{
            subV.removeFromSuperview()
        }
        let golfBagContainerView = UIView()
        
        let btnWidth = 60.0
        let btnHeight = 60.0
        let lblHeight = 20.0
        var xOffset = 0.0
        let yOffset = 10.0
        let horzSpace = 10.0
        
        for i in 0..<clubArray.count{
            let clubName = clubArray[i]
            
            let btns = UIButton()
            btns.frame = CGRect(x: xOffset, y: yOffset, width: btnWidth, height: btnHeight)
            btns.setCornerWithCircleWidthOne(color: UIColor(rgb: 0xF7F7F7).cgColor)
            btns.imageView?.sizeToFit()
            btns.tag = i
            btns.addTarget(self, action: #selector(clubButtonClick), for: .touchUpInside)
            golfBagContainerView.addSubview(btns)
            
            let titleLbl = UILabel()
            titleLbl.frame = CGRect(x: xOffset, y: (Double(btns.frame.size.height + CGFloat(yOffset))), width: btnWidth, height: lblHeight)
            titleLbl.textColor = UIColor.glfFlatBlue
            titleLbl.textAlignment = .center
            titleLbl.font = UIFont(name: "SFProDisplay-Light", size: 9.0)
            
            if i == tag{
                btns.setCornerWithCircleWidthOne(color: UIColor.glfBluegreen.cgColor)
                titleLbl.textColor = UIColor.glfBluegreen
            }
            let lastChar = clubName.last!
            let firstChar = clubName.first!
            
            btns.setBackgroundImage(UIImage(named: String(firstChar)+String(lastChar)), for: .normal)
            
            if lastChar == "i"{
                titleLbl.text = String(firstChar) + " Iron"
            }
            else if lastChar == "h"{
                titleLbl.text = String(firstChar) + " Hybrid"
            }
            else if lastChar == "r"{
                titleLbl.text = "Driver"
            }
            else if lastChar == "u"{
                titleLbl.text = "Putter"
            }
            else if lastChar == "w"{
                if clubName == "Pw"{
                    titleLbl.text =  "Pitching Wedge"
                }
                else if clubName == "Sw"{
                    titleLbl.text =  "Sand Wedge"
                }
                else if clubName == "Gw"{
                    titleLbl.text =  "Gap Wedge"
                }
                else if clubName == "Lw"{
                    titleLbl.text =  "Lob Wedge"
                }
                else{
                    titleLbl.text = String(firstChar) + " Woods"
                }
            }
            else{
                titleLbl.text =  clubName
                btns.setImage(#imageLiteral(resourceName: "golfBag"), for: .normal)
                btns.backgroundColor = UIColor.glfWhite
            }
            golfBagContainerView.addSubview(titleLbl)
            
            xOffset = Double(CGFloat(i+1) * (CGFloat(btnWidth) + CGFloat(horzSpace)))
        }
        golfBagContainerView.frame = CGRect(x: (Double(self.view.frame.size.width/2) - Double(btnWidth/2)) + horzSpace, y: 0, width: xOffset - horzSpace, height: yOffset + btnHeight + lblHeight)
        golfBagScrlView.addSubview(golfBagContainerView)
        golfBagScrlView.contentSize = CGSize(width: CGFloat(xOffset + horzSpace + (Double(self.view.frame.size.width/2) - Double(btnWidth/2))), height: golfBagScrlView.frame.size.height)
    }
    
    // MARK: clubButtonClick
    @objc func clubButtonClick(_ sender: UIButton!) {
        let tagVal = sender.tag
        DispatchQueue.main.async {
            self.swingAngleCircular_Red.setProgress(value:0,animationDuration:0.001)
            self.swingAngleCircular_Blue.setProgress(value:0, animationDuration:0.001)
        }
        setGolfBagUI(tag: tagVal)
        setPerformanceData(tag: tagVal)
        
        if tagVal == 0{
            clubHeadSpeedView.isHidden = false
        }
        else{
            clubHeadSpeedView.isHidden = true
        }
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Performance")
    }
}
