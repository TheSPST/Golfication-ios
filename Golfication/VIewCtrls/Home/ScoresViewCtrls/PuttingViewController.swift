//
//  PuttingViewController.swift
//  Golfication
//
//  Created by IndiRenters on 10/26/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import FirebaseAnalytics
var putsPerRoundHCP = [Double]()
class PuttingViewController: UIViewController, CustomProModeDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var puttingStackView: UIStackView!
    @IBOutlet weak var lblPuttsPerHoleAvg: UILabel!
    @IBOutlet weak var putsWithGirAvg: UILabel!
    @IBOutlet weak var lblPutsVsHandicapAvg: UILabel!

    @IBOutlet weak var cardViewPuttsPerHole: CardView!
    @IBOutlet weak var lblAvgPuttsPHoleValue: UILabel!
    @IBOutlet weak var barViewPuttsPerHole: BarChartView!
    @IBOutlet weak var pieViewPuttsBreakUp: PieChartView!
    @IBOutlet weak var barViewPuttsVsHandicap: BarChartView!
    
    @IBOutlet weak var puttingCardView: CardView!
    @IBOutlet weak var lblProPutting: UILabel!
    @IBOutlet weak var lblStrokesGainedPuttingAvg: UILocalizedLabel!
    @IBOutlet weak var lblPuttingSG: UILabel!
    @IBOutlet weak var lblFirstPuttProximity: UILabel!
    @IBOutlet weak var lblHoleOutDistance: UILabel!

    var totalPutts = 0.0
    var isDemoUser :Bool!
    var scores = [Scores]()
    var cardViewMArray = NSMutableArray()

    var checkCaddie = Bool()
    var cardViewInfoArray = [(title:String,value:String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("my_scores_putting", parameters: [:])
        FBSomeEvents.shared.singleParamFBEvene(param: "View My Scores Putting")
        self.getPuttsVSHandicapDataFromFirebase()
        self.setupUI()
        self.setupPutsPerHole()
        self.setupPuttsBreakUp()
        
        // Do any additional setup after loading the view.
        
        //---------------------------------------------------
        lblProPutting.layer.cornerRadius = 3.0
        lblProPutting.layer.masksToBounds = true
        lblStrokesGainedPuttingAvg.isHidden = true

        lblPuttingSG.isHidden = true
        self.lblPuttingSG.setCorner(color: UIColor.glfBlack50.cgColor)

        if !Constants.isProMode {
            
//            self.setProLockedUI(targetView: self.puttingCardView, title: "Putting".localized())
            self.lblProPutting.isHidden = true
            
            lblPuttsPerHoleAvg.isHidden = true
            lblAvgPuttsPHoleValue.isHidden = true
            
            let eddieStatsView1 = EddieStatsView()
            eddieStatsView1.backgroundColor = UIColor.clear
            eddieStatsView1.frame = CGRect(x: 16, y: 45, width: self.view.frame.width-52, height: 30)
            eddieStatsView1.lblTitle.text = "Eddie has some insights for you."
            eddieStatsView1.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            eddieStatsView1.btnView.setTitleColor(UIColor.glfWhite, for: .normal)
            eddieStatsView1.btnView.layer.borderColor = UIColor.glfWhite.cgColor
            cardViewPuttsPerHole.addSubview(eddieStatsView1)
        }
        else{
            self.lblProPutting.isHidden = false
            self.lblPuttsPerHoleAvg.isHidden = false
            self.lblAvgPuttsPHoleValue.isHidden = false
        }
        setHoleOutDistanceWithPuttProximity()
    }
    
    @objc func eddieProClicked(_ sender:UIButton){
        FBSomeEvents.shared.singleParamFBEvene(param: "Click My Scores Eddie")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Putting"
        self.navigationController?.pushViewController(viewCtrl, animated: false)
    }

    func setHoleOutDistanceWithPuttProximity(){
        var totalHoleOutDistance = [Double]()//3
        var totalProximity = [Double]()//2

        for score in scores{
            for i in 0..<score.clubDict.count{
                let clubClass = score.clubDict[i].1 as Club
                if(clubClass.type >= 0 && clubClass.type < 4){
                    if(clubClass.proximity != 0){
                    totalProximity.append(clubClass.proximity)
                    }
                    if(clubClass.holeout != 0){
                    totalHoleOutDistance.append(clubClass.holeout)
                    }
                }
            }
        }
//---------------------------------------------------------------------------------------------
        var isTotalProximity = false
        var isHoleOutTrue = false
        if(totalHoleOutDistance.count > 0){
            let sum = totalHoleOutDistance.reduce(0, +)
            self.lblHoleOutDistance.text = "\((sum/Double(totalHoleOutDistance.count)).rounded(toPlaces: 1)) ft"
        }
        else{
            self.lblHoleOutDistance.isHidden = true
            self.lblHoleOutDistance.text = "0.0ft"
            isHoleOutTrue = true
        }
        if(totalProximity.count > 0){
            let sum = totalProximity.reduce(0, +)
            self.lblFirstPuttProximity.text = "\((sum/Double(totalProximity.count)).rounded(toPlaces: 1)) ft"
            self.lblStrokesGainedPuttingAvg.isHidden = false
            self.lblPuttingSG.isHidden = false
            self.lblStrokesGainedPuttingAvg.text = "Proximity to Hole after Approach Putt"
            self.lblPuttingSG.text = "\((sum/Double(totalProximity.count)).rounded(toPlaces: 1)) ft"
        }
        else{
            self.lblFirstPuttProximity.text = "0.0 ft"
            isTotalProximity = true
        }
        if(isTotalProximity && isHoleOutTrue){
            puttingCardView.isHidden = true
        }
    }
    
    func setProLockedUI(targetView:UIView?, title:String) {
        
        let customProModeView = CustomProModeView()
        customProModeView.frame =  CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!-16, height: (targetView?.frame.size.height)!)
        customProModeView.delegate = self
        customProModeView.btnDevice.isHidden = true
        customProModeView.btnPro.isHidden = false
        
        customProModeView.proImageView.frame.size.width = 45
        customProModeView.proImageView.frame.size.height = 45
        customProModeView.proImageView.frame.origin.x = (customProModeView.frame.size.width)-45-4
        customProModeView.proImageView.frame.origin.y = 0
        
        customProModeView.label.frame.size.width = (customProModeView.bounds.width)-80
        customProModeView.label.frame.size.height = 50
        customProModeView.label.center = CGPoint(x: (customProModeView.bounds.midX), y: (customProModeView.bounds.midY)-40)
        customProModeView.label.backgroundColor = UIColor.clear
        
        customProModeView.btnPro.frame.size.width = (customProModeView.label.frame.size.width/2)+10
        customProModeView.btnPro.frame.size.height = 40
        customProModeView.btnPro.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 20)
        
        customProModeView.titleLabel.frame = CGRect(x: customProModeView.frame.origin.x + 16, y: customProModeView.frame.origin.y + 16, width: customProModeView.bounds.width, height: 30)
        customProModeView.titleLabel.backgroundColor = UIColor.clear
        customProModeView.titleLabelText = title
        
        customProModeView.labelText = "Pro members only"
        customProModeView.btnTitle = "Become a Pro"
        //customProModeView.backgroundColor = UIColor.clear
        customProModeView.backgroundColor = UIColor(red:110.0/255.0, green:185.0/255.0, blue:165.0/255.0, alpha:1.0)
        
        if !checkCaddie{
            customProModeView.btnPro.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 30)
            
            customProModeView.titleLabel.textColor = UIColor.darkGray
            customProModeView.labelText = "Unlock this stat by playing a round with Shot Tracking"
            customProModeView.btnTitle = "Play Now"
            customProModeView.backgroundColor = UIColor.white
        }
        targetView?.addSubview(customProModeView)
    }
    func proLockBtnPressed(button:UIButton) {
        if !checkCaddie{
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
        else{
            FBSomeEvents.shared.singleParamFBEvene(param: "Click My Scores Eddie")
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
            viewCtrl.source = "Putting"
            self.navigationController?.pushViewController(viewCtrl, animated: false)

            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    func setupUI(){
        barViewPuttsPerHole.isUserInteractionEnabled = false
        pieViewPuttsBreakUp.isUserInteractionEnabled = false
        barViewPuttsVsHandicap.isUserInteractionEnabled = false
        
        lblPuttsPerHoleAvg.isHidden = true
        putsWithGirAvg.isHidden = true
        lblPutsVsHandicapAvg.isHidden = true
        lblAvgPuttsPHoleValue.isHidden = true
        if(isDemoUser){
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.puttingStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)
                    
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Putts Per Hole",value:StatsIntoConstants.puttsPerHole))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Putts Breakup",value:StatsIntoConstants.puttsBreakup))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Putting",value:StatsIntoConstants.putting))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Putts Vs Handicap",value:StatsIntoConstants.puttVersusHandicap))
                        break
                    default: break
                    }
                    //Stats Info Button
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-50, y: 16, width: 25, height: 25)
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == cardViewPuttsPerHole){
                        statsInfoButton.tintColor = UIColor.white
                    }
                    statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                    v.addSubview(statsInfoButton)
                    viewTag = viewTag+1
                }
            }
        }
        else{
            let originalImage1 = #imageLiteral(resourceName: "share")
            let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.puttingStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Putts Per Hole",value:StatsIntoConstants.puttsPerHole))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Putts Breakup",value:StatsIntoConstants.puttsBreakup))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Putting",value:StatsIntoConstants.putting))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Putts Vs Handicap",value:StatsIntoConstants.puttVersusHandicap))
                        break
                    default: break
                    }
                    let shareStatsButton = ShareStatsButton()
                    shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                    shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                    shareStatsButton.tintColor = UIColor.glfFlatBlue
                    shareStatsButton.tag = viewTag
                    if (v == cardViewPuttsPerHole){
                        shareStatsButton.tintColor = UIColor.white
                    }
                    shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                    v.addSubview(shareStatsButton)
                    
                    //Stats Info Button
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width-shareStatsButton.frame.size.width)-70, y: 16, width: 25, height: 25)
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == cardViewPuttsPerHole){
                        statsInfoButton.tintColor = UIColor.white
                    }
                    statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                    v.addSubview(statsInfoButton)
                    viewTag = viewTag+1
                }
            }
        }
        cardViewPuttsPerHole.backgroundColor = UIColor.glfBluegreen
        self.lblAvgPuttsPHoleValue.setCorner(color: UIColor.white.cgColor)
    }
    
    // MARK: - infoClicked
    @objc func infoClicked(_ sender:UIButton){
        FBSomeEvents.shared.singleParamFBEvene(param: "Click My Scores Info")
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
        viewCtrl.title = cardViewInfoArray[sender.tag].title
        viewCtrl.desc = cardViewInfoArray[sender.tag].value
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }

    // MARK: - shareClicked
    @objc func shareClicked(_ sender:UIButton){
        let tagVal = sender.tag
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ShareStatsVC") as! ShareStatsVC
        viewCtrl.shareCardView = (cardViewMArray[tagVal] as! CardView)
        viewCtrl.fromFeed = false

        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        navCtrl.modalPresentationStyle = .overCurrentContext
        self.present(navCtrl, animated: false, completion: nil)
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    func setupPuttVsHandicap(){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "handicap") { (snapshot) in
            var hcp : Double!
            if let handicap = snapshot.value as? String{
                if handicap != "-"{
                    hcp = Double(handicap)!
                }
            }
            DispatchQueue.main.async( execute: {
                var avgPuttsRound = [Double]()
                for score in self.scores{
                    var avgPerRound = 0.0
                    var is9Holes : Double = 1
                    if(score.type == "9 holes") || (score.type == "9 hole"){
                        is9Holes = 2
                    }
                    for i in 0..<score.putts.count{
                        avgPerRound += score.putts[i] * Double(i)
                    }
                    avgPuttsRound.append(avgPerRound*is9Holes)
                }
                let colors = [UIColor.glfWarmGrey,UIColor.glfPaleTeal,UIColor.glfFlatBlue75]
                if (hcp != nil) && Int(hcp.rounded()) == 0 {
                    self.barViewPuttsVsHandicap.setBarChartPuttsVSHandicap(dataPoints: [self.puttsVS[0].dataP,"Your Stats",self.puttsVS[1].dataP], values: [(self.puttsVS[0].dataV),(avgPuttsRound.reduce(0, +) / Double(avgPuttsRound.count)),(self.puttsVS[1].dataV)], chartView: self.barViewPuttsVsHandicap,colors: colors, barWidth: 0.4)
                }else if hcp != nil{
                    let ind = Int(hcp.rounded()/5)
                    self.barViewPuttsVsHandicap.setBarChartPuttsVSHandicap(dataPoints: [self.puttsVS[ind].dataP,"Your Stats",self.puttsVS[ind+1].dataP], values: [self.puttsVS[ind].dataV,(avgPuttsRound.reduce(0, +) / Double(avgPuttsRound.count)),self.puttsVS[ind+1].dataV], chartView: self.barViewPuttsVsHandicap,colors: colors, barWidth: 0.4)
                }else{
                    var dataValuesForBar = [Double]()
                    dataValuesForBar.append(31.0)
                    dataValuesForBar.append(avgPuttsRound.reduce(0, +) / Double(avgPuttsRound.count))
                    dataValuesForBar.append(34.5)
                    self.barViewPuttsVsHandicap.setBarChartPuttsVSHandicap(dataPoints: ["11-15 HCP","Your Stats","16-20 HCP"], values: dataValuesForBar, chartView: self.barViewPuttsVsHandicap,colors: colors, barWidth: 0.4)
                }
                if Constants.baselineDict != nil{
                    let publicScore  = PublicScore()
                    let publicScoreStr = publicScore.getPuttsHandicap(avergePutts:avgPuttsRound.reduce(0, +) / Double(avgPuttsRound.count))
                    
                    self.lblPutsVsHandicapAvg.isHidden = false
                    self.lblPutsVsHandicapAvg.attributedText = publicScoreStr
                }
            })
        }
    }
    
    
    func setupPuttsBreakUp(){
//        print(totalPutts)
        var totalPuttsRoundWise = [0.0,0.0,0.0,0.0,0.0,0.0]
        var totalPuttsRoundWise1 = [0.0,0.0,0.0,0.0,0.0,0.0]
        for score in scores{
            var is9Holes : Double = 1
            if(score.type == "9 holes") || (score.type == "9 hole"){
                is9Holes = 2
            }
            for i in 0..<score.putts.count{
                totalPuttsRoundWise[i] += score.putts[i]*is9Holes
            }
            for i in 0..<score.putts.count{
                totalPuttsRoundWise1[i] += score.putts[i]
            }
        }
//        print(totalPuttsRoundWise)
        let sum = totalPuttsRoundWise1.reduce(0, +)
        var dataPoints = [String]()
        var puttsAvgPerc = [Double]()
        var avgPutts = 0.0
        for i in 0..<totalPuttsRoundWise.count{
            if(totalPuttsRoundWise[i] > 0){
                avgPutts += Double(i)*totalPuttsRoundWise[i]
                puttsAvgPerc.append(((totalPuttsRoundWise1[i]/sum)*100).rounded(toPlaces: 1))
                dataPoints.append("\(i) Putt")
            }
        }
//        print(puttsAvgPerc)
        pieViewPuttsBreakUp.setChartForPuttingBreak(dataPoints: dataPoints, values: puttsAvgPerc, chartView: pieViewPuttsBreakUp,avgPutts: (avgPutts/Double(scores.count)).rounded(toPlaces: 2))
        
        if Constants.baselineDict != nil{
            if !(Int(totalPuttsRoundWise[0]) == 0 && Int(totalPuttsRoundWise[1]) == 0  && Int(totalPuttsRoundWise[2]) == 0  && Int(totalPuttsRoundWise[3]) == 0  && Int(totalPuttsRoundWise[4]) == 0){
                
                let publicScore  = PublicScore()
                let publicScoreStr = publicScore.getPuttsBreakup(zeroPutts:totalPuttsRoundWise1[0],  onePutts:totalPuttsRoundWise1[1], twoPutts:totalPuttsRoundWise1[2], threePutts:totalPuttsRoundWise1[3], fourPutts:totalPuttsRoundWise1[4])
                
                    putsWithGirAvg.isHidden = false
                    putsWithGirAvg.attributedText = publicScoreStr
            }
        }
    }
    func setupPutsPerHole(){
        var roundTimeStamp = [String]()
        var roundWisePuttingSumAvg = [Double]()
        var gameTypes = [String]()
        for score in scores{
            var sum = 0.0
            var sumOfAll = 0.0
            for i in 0..<score.putts.count{
                sumOfAll += ((score.putts[i]) * Double(i))
                sum += score.putts[i]
            }
            self.totalPutts += sumOfAll
            if(sumOfAll != 0){
                roundWisePuttingSumAvg.append((sumOfAll/sum).rounded(toPlaces: 1))
                roundTimeStamp.append(score.date)
                gameTypes.append(score.type)
            }
        }
        barViewPuttsPerHole.setBarChartGameType(dataPoints: roundTimeStamp, values: roundWisePuttingSumAvg, gameType: gameTypes, chartView: barViewPuttsPerHole, barWidth: 0.2)
        barViewPuttsPerHole.leftAxis.axisMinimum = 0.0
        barViewPuttsPerHole.leftAxis.axisMaximum = 1 + (roundWisePuttingSumAvg.max() ?? 0)
        barViewPuttsPerHole.leftAxis.labelCount = 4
        
        if !roundWisePuttingSumAvg.isEmpty{
            self.lblPuttsPerHoleAvg.text = "Average Putts Per Hole"
            self.lblAvgPuttsPHoleValue.text = "\((roundWisePuttingSumAvg.reduce(0,+)/Double(roundWisePuttingSumAvg.count)).rounded(toPlaces: 1))"
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var puttsVS = [(dataP:String,dataV:Double)]()
    func getPuttsVSHandicapDataFromFirebase(){
        let group = DispatchGroup()
        if putsPerRoundHCP.isEmpty{
            for i in 0..<55{
                group.enter()
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "baseline/\(i)/puttsPerRound") { (snapshot) in
                    var puttsPer = Double()
                    if let puttsPerRound = snapshot.value as? String{
                        puttsPer = Double(puttsPerRound)!
                        putsPerRoundHCP.append(puttsPer)
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main, execute: {
                var i = 0
                var sum = 0.0
                for data in putsPerRoundHCP{
                    if (i == 0){
                        self.puttsVS.append((dataP: "\(i) - \(i) HCP", dataV: data))
                    }else if (i % 5 == 0){
                        sum += data
                        self.puttsVS.append((dataP: "\(i-4) - \(i) HCP", dataV: sum/5))
                        sum = 0.0
                    }else if (i > 50){
                        sum += data
                        if i == 54{
                            self.puttsVS.append((dataP: "\(i-3) - \(i) HCP", dataV: sum/4))
                        }
                    }else{
                        sum += data
                    }
                    i += 1
                }
                self.setupPuttVsHandicap()
            })
        }else{
            var i = 0
            var sum = 0.0
            for data in putsPerRoundHCP{
                if (i == 0){
                    self.puttsVS.append((dataP: "\(i) - \(i) HCP", dataV: data))
                }else if (i % 5 == 0){
                    sum += data
                    self.puttsVS.append((dataP: "\(i-4) - \(i) HCP", dataV: sum/5))
                    sum = 0.0
                }else if (i > 50){
                    sum += data
                    if i == 54{
                        self.puttsVS.append((dataP: "\(i-3) - \(i) HCP", dataV: sum/4))
                    }
                }else{
                    sum += data
                }
                i += 1
            }
            self.setupPuttVsHandicap()
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Putting".localized())
    }
}
