//
//  PracticeSessionVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import UICircularProgressRing

class PracticeSessionVC: UIViewController, IndicatorInfoProvider, UIScrollViewDelegate {
    
    @IBOutlet weak var btnContainerSV1: UIStackView!
    @IBOutlet weak var btnContainerSV2: UIStackView!
    @IBOutlet weak var startSwingingSV: UIStackView!
    
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var customColorSlider: CustomColorSlider!

    @IBOutlet weak var clubSpeedLineChart: LineChartView!
    @IBOutlet weak var headSpeedLineChart: LineChartView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var swingProgressView: UIProgressView!
    
    @IBOutlet weak var swingScoreCircularView: UICircularProgressRingView!
    @IBOutlet weak var backSwingCircularView: UICircularProgressRingView!
    // SixButtons
    @IBOutlet weak var view1SwingScore: UIView!
    @IBOutlet weak var view2Clubhead: UIView!
    @IBOutlet weak var view3ClubPlane: UIView!
    @IBOutlet weak var view4Tempo: UIView!
    @IBOutlet weak var view5BackSwing: UIView!
    @IBOutlet weak var view6HandSpeed: UIView!
    // SixViews
    @IBOutlet weak var view1SwingV: UIView!
    @IBOutlet weak var view2ClubheadV: UIView!
    @IBOutlet weak var view3ClubPlaneV: UIView!
    @IBOutlet weak var view4TempoV: UIView!
    @IBOutlet weak var view5BackSwingV: UIView!
    @IBOutlet weak var view6HandSpeedV: UIView!
    //SixLabels
    @IBOutlet weak var lbl1SwingV: UILabel!
    @IBOutlet weak var lbl2ClubheadV: UILabel!
    @IBOutlet weak var lbl3ClubPlaneV: UILabel!
    @IBOutlet weak var lbl4TempoV: UILabel!
    @IBOutlet weak var lbl4Tempo1V: UILabel!
    @IBOutlet weak var lbl5BackSwingV: UILabel!
    @IBOutlet weak var lbl6HandSpeedV: UILabel!
    //SixLabels
    @IBOutlet weak var lbl1SwingB: UILabel!
    @IBOutlet weak var lbl2ClubheadB: UILabel!
    @IBOutlet weak var lbl3ClubPlaneB: UILabel!
    @IBOutlet weak var lbl4TempoB: UILabel!
    @IBOutlet weak var lbl5BackSwingB: UILabel!
    @IBOutlet weak var lbl6HandSpeedB: UILabel!
    @IBOutlet weak var lblbackSwing: UILabel!
    @IBOutlet weak var lbldownSwing: UILabel!
    
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblClubName1: UILabel!
    @IBOutlet weak var lblClubName2: UILabel!
    @IBOutlet weak var lblClubName3: UILabel!
    @IBOutlet weak var lblClubName4: UILabel!
    
    @IBOutlet weak var btnSwingScoreClubImage: UIButton!
    @IBOutlet weak var btnClubSpeedClubImage: UIButton!
    @IBOutlet weak var btnClubPlaneClubImage: UIButton!
    @IBOutlet weak var btnBackSwingClubImage: UIButton!
    @IBOutlet weak var btnHandSpeedClubImage: UIButton!
    let progressView = SDLoader()

    
    var shotBtnViews = [UIView]()
    var shotTopViews = [UIView]()
    var shotLbl = [UILabel]()
    var shotLblB = [UILabel]()
    var tempArray = [String]()
    var swingDetails = NSMutableDictionary()
    var shotNumStr = String()
    var shotsArray = [String]()
    var club = String()
    var progressValue = 0.0
    var count = Int()
    var superClassName = String()
    
    var gender = String()
    var handicap = String()
    var benchMarkVal = String()
    @IBOutlet weak var lblBottomClubSpeedKPH: UILabel!
    @IBOutlet weak var lblBottomClubSpeedCHS: UILabel!
    @IBOutlet weak var lblTempoColon: UILabel!
    @IBOutlet weak var lblSwingTempo: UILabel!

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: shotNumStr)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTempArr()
        self.shotBtnViews = [view1SwingScore,view2Clubhead,view3ClubPlane,view4Tempo,view5BackSwing,view6HandSpeed]
        self.shotTopViews = [view1SwingV,view2ClubheadV,view3ClubPlaneV,view4TempoV,view5BackSwingV,view6HandSpeedV]
        self.shotLbl = [lbl1SwingV,lbl2ClubheadV,lbl3ClubPlaneV,lbl4TempoV,lbl5BackSwingV,lbl6HandSpeedV,lbldownSwing,lblbackSwing]
        self.shotLblB = [lbl1SwingB,lbl2ClubheadB,lbl3ClubPlaneB,lbl4TempoB,lbl5BackSwingB,lbl6HandSpeedB,lbldownSwing,lblbackSwing]
        
        btnTapped(tagVal:0)
        for i in 0..<self.tempArray.count{
            shotLbl[i].text = tempArray[i]
            shotLblB[i].text = tempArray[i]
        }
        self.title = "Practice Session \(count)"
        
        self.perform(#selector(self.updateProgress), with: nil, afterDelay:0.0)
        self.swingScoreCircularView.innerCapStyle = .square
        self.swingScoreCircularView.outerCapStyle = .square
        self.swingScoreCircularView.fontColor = UIColor.clear
        
        self.backSwingCircularView.innerCapStyle = .square
        self.backSwingCircularView.outerCapStyle = .square
        self.backSwingCircularView.fontColor = UIColor.clear

        customColorSlider.defaultValue = 0.5
        customColorSlider.isEnabled = false
        customColorSlider.actionBlock={slider,newvalue in
            debugPrint("newvalue== ",newvalue)
        }
        lblClubName.textColor = UIColor.glfFlatBlue
        lblClubName1.textColor = UIColor.glfFlatBlue
        lblClubName2.textColor = UIColor.glfFlatBlue
        lblClubName3.textColor = UIColor.glfFlatBlue
        lblClubName4.textColor = UIColor.glfFlatBlue
        
        let originalImage1 = UIImage(named: "golfBag")!
        let btnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnSwingScoreClubImage.tintColor = UIColor.glfFlatBlue
        btnClubSpeedClubImage.tintColor = UIColor.glfFlatBlue
        btnClubPlaneClubImage.tintColor = UIColor.glfFlatBlue
        btnBackSwingClubImage.tintColor = UIColor.glfFlatBlue
        btnHandSpeedClubImage.tintColor = UIColor.glfFlatBlue

        btnSwingScoreClubImage.setImage(btnImage, for: .normal)
        btnClubSpeedClubImage.setImage(btnImage, for: .normal)
        btnClubPlaneClubImage.setImage(btnImage, for: .normal)
        btnBackSwingClubImage.setImage(btnImage, for: .normal)
        btnHandSpeedClubImage.setImage(btnImage, for: .normal)
    }
    
    func getUserData(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)

        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            if(snapshot.childrenCount > 0){
                var userData = NSDictionary()
                userData = snapshot.value as! NSDictionary

                if let gender = userData.object(forKey: "gender") as? String{
                    self.gender = gender
                }
                if let handicap = userData.object(forKey: "handicap") as? String{
                    self.handicap = handicap
                }
            }
            
            DispatchQueue.main.async(execute: {
                var benchmark_Key = String()

                if self.gender == "male"{
                 if self.handicap == "-"{
                 benchmark_Key = "M6";
                 }else if self.handicap >= "0" && self.handicap < "6"{
                 benchmark_Key = "M0";
                 }else if self.handicap >= "6" && self.handicap < "20"{
                 benchmark_Key = "M6";
                 }else{
                 benchmark_Key = "M20";
                 }
                 }else{
                 if self.handicap == "-"{
                 benchmark_Key = "F6";
                 }else if self.handicap >= "0" && self.handicap < "6"{
                 benchmark_Key = "F0";
                 }else if self.handicap >= "6" && self.handicap < "20"{
                 benchmark_Key = "F6";
                 }else{
                 benchmark_Key = "F20";
                 }
                 }
                if let club = self.swingDetails.value(forKey: "club") as? String{
                    self.getBenchmarkData(benchMark: benchmark_Key, clubName:club)
                }
                else{
                    self.progressView.hide(navItem: self.navigationItem)
                }
            })
        }
    }
    
    func getBenchmarkData(benchMark:String, clubName:String){

        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "benchmarks/" + benchMark + "/" + clubName) { (snapshot) in
            
            self.benchMarkVal = snapshot.value as! String
            
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)

                let clubSpeed = self.swingDetails.value(forKey: "clubSpeed") as! Double
                let clubSpeedTemp:Double = Double(self.benchMarkVal)!
                 if(clubSpeedTemp*0.9<clubSpeed){
                    self.lbl2ClubheadB.textColor = UIColor.green

                 }else if(clubSpeedTemp*0.8<clubSpeed && clubSpeedTemp*0.9>clubSpeed){
                    self.lbl2ClubheadB.textColor = UIColor.yellow

                 }else if(clubSpeedTemp*0.8>clubSpeed){
                    self.lbl2ClubheadB.textColor = UIColor.red
                 }
                
                let tempo = self.swingDetails.value(forKey: "tempo") as! Double
                if(tempo>=3.7 || tempo<=2.3){
                    self.lbl4TempoB.textColor = UIColor.red
                    
                }else if(tempo>=2.7 || tempo<=3.3){
                    self.lbl4TempoB.textColor = UIColor.green
                }else{
                    self.lbl4TempoB.textColor = UIColor.yellow
                }
            })
        }
    }
    
    func initTempArr(){
        if self.swingDetails.count != 0{
            let backSwingAngle = self.swingDetails.value(forKey: "backSwingAngle") as! Double
            let backSwing = (self.swingDetails.value(forKey: "backSwing") as! Double)
            let downSwing = (self.swingDetails.value(forKey: "downSwing") as! Double)
            let clubSpeed = self.swingDetails.value(forKey: "clubSpeed") as! Double
            let handSpeed = self.swingDetails.value(forKey: "handSpeed") as! Double
            let tempo = self.swingDetails.value(forKey: "tempo") as! Double
            let swingScore = self.swingDetails.value(forKey: "swingScore") as! Int
            self.club = self.swingDetails.value(forKey: "club") as! String
            self.club = BackgroundMapStats.getClubName(club: self.club).uppercased()
            tempArray.append("\(Int(swingScore))")
            tempArray.append("\(Int(clubSpeed))")
//            tempArray.append("+\(Int(5))%")
            tempArray.append("-")
            tempArray.append("\(tempo.rounded(toPlaces: 1))")
            lbl4Tempo1V.text = "1"
            tempArray.append("\(Int(backSwingAngle))")
            tempArray.append("\(Int(handSpeed))")
            tempArray.append("\(downSwing.rounded(toPlaces: 3)) sec")
            tempArray.append("\(backSwing.rounded(toPlaces: 3)) sec")
            lblClubName.text = self.club
            lblClubName1.text = self.club
            lblClubName2.text = self.club
            lblClubName3.text = self.club
            lblClubName4.text = self.club
            
            getUserData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        scrollView.isHidden = false
        startSwingingSV.isHidden = true
        self.view.backgroundColor = UIColor.white
        if superClassName != "SwingSessionVC"{
        if shotsArray.last == shotNumStr{
            scrollView.isHidden = true
            startSwingingSV.isHidden = false
            self.view.backgroundColor = UIColor(rgb: 0xF6F6F5)
            self.swingProgressView.setProgress(100, animated: true)
        }
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        btnTapped(tagVal:sender.tag)
    }
    @objc func updateProgress() {
        progressValue = progressValue + 0.1
        self.swingProgressView.progress = Float(progressValue)
        if progressValue != 2.0 {
            self.perform(#selector(updateProgress), with: nil, afterDelay: 0.1)
        }
    }
    
    func btnTapped(tagVal:Int) {
        
        if tagVal != 2{
            //---------------------- default color ---------
            lblBottomClubSpeedKPH.textColor = UIColor(rgb: 0x87A39A)
            lblBottomClubSpeedCHS.textColor = UIColor(rgb: 0x87A39A)
            lblSwingTempo.textColor = UIColor(rgb: 0x87A39A)

        for i in 0..<self.shotBtnViews.count{
            shotBtnViews[i].layer.cornerRadius = 3.0
            shotBtnViews[i].layer.borderWidth = 1.0
            shotBtnViews[i].layer.borderColor = UIColor(rgb: 0xDBE7EE).cgColor
            if shotBtnViews[i].tag == tagVal{
                shotBtnViews[i].layer.borderColor = UIColor.glfFlatBlue.cgColor
            }
        }
        for i in 0..<shotTopViews.count{
            shotTopViews[i].isHidden = true
            if shotTopViews[i].tag == tagVal{
                shotTopViews[i].isHidden = false
                if tagVal == 0{
                    DispatchQueue.main.async(execute: {
                        self.swingScoreCircularView.setProgress(value: CGFloat(83), animationDuration: 1)
                    })
                }
                else if tagVal == 1{
                    let avgVh1 = 55.5
                    let avgVh2 = 10.2
                    let avgVh3 = 30.7
                    clubSpeedLineChart.setLineChartHandSpeed(dataPoints:["", "", "", "", "", "" ,"" ,"" ,"" ,"","",""] , values: [0.2, 0.5, 1.0, 2.2,avgVh1,1.7,2.5,avgVh2,4.9,avgVh3,10.6,5.0], chartView: clubSpeedLineChart,color:UIColor.glfFlatBlue)
                    clubSpeedLineChart.leftAxis.axisLineColor = UIColor.white
                    clubSpeedLineChart.xAxis.axisLineColor = UIColor.white
                    
                    //---------------- Set Color -------------
                    let clubSpeed = self.swingDetails.value(forKey: "clubSpeed") as! Double
                    let clubSpeedTemp:Double = Double(self.benchMarkVal)!
                    if(clubSpeedTemp*0.9<clubSpeed){
                        lblBottomClubSpeedKPH.textColor = UIColor.green
                        lblBottomClubSpeedCHS.textColor = UIColor.green

                        shotBtnViews[i].layer.borderColor = UIColor.green.cgColor
                        self.lbl2ClubheadV.textColor = UIColor.green
                        self.lbl2ClubheadB.textColor = UIColor.green
                        
                    }else if(clubSpeedTemp*0.8<clubSpeed && clubSpeedTemp*0.9>clubSpeed){
                        lblBottomClubSpeedKPH.textColor = UIColor.yellow
                        lblBottomClubSpeedCHS.textColor = UIColor.yellow

                        shotBtnViews[i].layer.borderColor = UIColor.yellow.cgColor
                        self.lbl2ClubheadV.textColor = UIColor.yellow
                        self.lbl2ClubheadB.textColor = UIColor.yellow
                        
                    }else if(clubSpeedTemp*0.8>clubSpeed){
                        lblBottomClubSpeedKPH.textColor = UIColor.red
                        lblBottomClubSpeedCHS.textColor = UIColor.red

                        shotBtnViews[i].layer.borderColor = UIColor.red.cgColor
                        self.lbl2ClubheadV.textColor = UIColor.red
                        self.lbl2ClubheadB.textColor = UIColor.red
                    }
                }
                else if tagVal == 3{
                    /*DispatchQueue.main.async(execute: {
                        self.customColorSlider.setValue(CGFloat(3.5), animated: true)
                    })
                    customColorSlider.actionBlock = {slider,newvalue in
                        debugPrint("newValue== ",newvalue)
                    }*/
                    
                    let tempo = self.swingDetails.value(forKey: "tempo") as! Double

                    if(tempo>=3.7 || tempo<=2.3){
                        lbl4TempoB.textColor = UIColor.red
                        lbl4TempoV.textColor = UIColor.red
                        lbl4Tempo1V.textColor = UIColor.red
                        lblTempoColon.textColor = UIColor.red
                        shotBtnViews[i].layer.borderColor = UIColor.red.cgColor
                        lblSwingTempo.textColor = UIColor.red
                        
                    }else if(tempo>=2.7 || tempo<=3.3){
                        lbl4TempoB.textColor = UIColor.green
                        lbl4TempoV.textColor = UIColor.green
                        lbl4Tempo1V.textColor = UIColor.green
                        lblTempoColon.textColor = UIColor.green
                        shotBtnViews[i].layer.borderColor = UIColor.green.cgColor
                        lblSwingTempo.textColor = UIColor.green
                    }else{
                        lbl4TempoB.textColor = UIColor.yellow
                        lbl4TempoV.textColor = UIColor.yellow
                        lbl4Tempo1V.textColor = UIColor.yellow
                        lblTempoColon.textColor = UIColor.yellow
                        shotBtnViews[i].layer.borderColor = UIColor.yellow.cgColor
                        lblSwingTempo.textColor = UIColor.yellow
                    }
                }
                else if tagVal == 4{
                    DispatchQueue.main.async(execute: {
                        self.backSwingCircularView.setProgress(value: CGFloat(50), animationDuration: 1)
                    })
                }
                else if tagVal == 5{
                    let avgVh1 = 10.5
                    let avgVh2 = 55.2
                    let avgVh3 = 70.7
                    headSpeedLineChart.setLineChartHandSpeed(dataPoints:["", "", "", "", "", "" ,"" ,"" ,"" ,"","",""] , values: [0.2, 0.5, 1.0, 2.2,avgVh1,1.7,2.5,avgVh2,4.9,avgVh3,10.6,5.0], chartView: headSpeedLineChart,color:UIColor.glfFlatBlue)
                    headSpeedLineChart.leftAxis.axisLineColor = UIColor.white
                    headSpeedLineChart.xAxis.axisLineColor = UIColor.white
                }
            }
        }
    }
    }
}
