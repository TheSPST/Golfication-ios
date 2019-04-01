//
//  MyScoreVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import FirebaseAnalytics

class OverViewVC: UIViewController, CustomProModeDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var overviewStackView: UIStackView!
    @IBOutlet weak var lblRoundsAvg: UILabel!
    @IBOutlet weak var lblScoreDistributionAvg: UILabel!
    @IBOutlet weak var lblScoringAvg: UILabel!
    @IBOutlet weak var lblParAvg: UILabel!
    @IBOutlet weak var lblPenaltyTrendsAvg: UILabel!
    
    @IBOutlet weak var lblAvgRoundsValue: UILabel!
    @IBOutlet weak var roundCardView: CardView!
    @IBOutlet weak var lblAvgScoreDistributionValue: UILabel!
    @IBOutlet weak var lblAvgPerformanceValue: UILabel!
    @IBOutlet weak var lblAvgPenaltiesTrendsValue: UILabel!
    @IBOutlet weak var barViewPenaltiesTrend: BarChartView!
    @IBOutlet weak var barViewParAverages: BarChartView!
    @IBOutlet weak var pieViewScoring: PieChartView!
    @IBOutlet weak var barViewScoreDistribution: LineChartView!
    @IBOutlet weak var barViewRounds: BarChartView!
    @IBOutlet weak var lblAvgScoreDistribution: UILabel!
    
    @IBOutlet weak var strokeGainedChartView: CardView!
    @IBOutlet weak var lblProSG: UILabel!
    @IBOutlet weak var lblStrokesGainedPerClubAvg: UILabel!
    @IBOutlet weak var strokesGainedPerClubBarChart: BarChartView!
    let progressView = SDLoader()

    var bestRound = Double()
    var avgScore = Double()
    var scores = [Scores]()
    var classicScores = [Scores]()
    var isDemoUser :Bool!
    var groupDict = [String:Double]()
    var cardViewMArray = NSMutableArray()
    
    var checkCaddie = Bool()
    var cardViewInfoArray = [(title:String,value:String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("my_scores_overview", parameters: [:])
        FBSomeEvents.shared.singleParamFBEvene(param: "View My Scores Overview")
        self.setupUI()
        //print("Scores in ViewDid Load : \(scores)")
        self.setData()
        self.setOverviewBarChart()
        //        self.roundLabelData.text = "Best Round :\(self.bestRound)"
        self.setScoreDistribution()
        self.setPenaltiesTrendBarCharts()
        self.setViewScoringPieChart()
        self.setViewParAveragesBarChart()
        
 //------------- Amit's Changes -------------------------------
        strokeGainedChartView.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        lblProSG.layer.cornerRadius = 3.0
        lblProSG.layer.masksToBounds = true
        lblStrokesGainedPerClubAvg.isHidden = true

        if !Constants.isProMode {
//            self.setProLockedUI(targetView: self.strokeGainedChartView, title: "Strokes Gained Per Round")
//            self.lblProSG.isHidden = true
              self.lblStrokesGainedPerClubAvg.isHidden = true
            //--------------------------- for insights -------------------------------
            let eddieStatsView = EddieStatsView()
            eddieStatsView.backgroundColor = UIColor.clear
            eddieStatsView.frame = CGRect(x: 16, y: 45, width: self.view.frame.width-52, height: 30)
            eddieStatsView.lblTitle.text = "Eddie has some insights for you."
            eddieStatsView.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            eddieStatsView.btnView.setTitleColor(UIColor.glfWhite, for: .normal)
            eddieStatsView.btnView.layer.borderColor = UIColor.glfWhite.cgColor
            roundCardView.addSubview(eddieStatsView)

            let eddieStatsView1 = EddieStatsView()
            eddieStatsView1.backgroundColor = UIColor.clear
            eddieStatsView1.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-52, height: 30)
            eddieStatsView1.lblTitle.text = "Unlock this stat with Eddie!"
            eddieStatsView1.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            eddieStatsView1.btnView.setTitleColor(UIColor.glfWhite, for: .normal)
            eddieStatsView1.btnView.layer.borderColor = UIColor.glfWhite.cgColor
            strokeGainedChartView.addSubview(eddieStatsView1)

            lblRoundsAvg.isHidden = true
            lblAvgRoundsValue.isHidden = true
            lblAvgScoreDistribution.isHidden = true
            lblAvgScoreDistributionValue.isHidden = true
            lblAvgPenaltiesTrendsValue.isHidden = true
            lblPenaltyTrendsAvg.isHidden = true
            lblScoringAvg.isHidden = true
            lblParAvg.isHidden = true
        }
        else{
            self.lblProSG.backgroundColor = UIColor.clear
            self.lblProSG.layer.borderWidth = 1.0
            self.lblProSG.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
            self.lblProSG.textColor = UIColor(rgb: 0xFFC700)
            self.lblProSG.isHidden = false
            lblStrokesGainedPerClubAvg.isHidden = false
        }
        self.setStrokesGainedPerClubBarChart()

        //-----------------------------------------------------
    }
    
    func setStrokesGainedClassicData(){
        
        var dataPoints = [String]()
        var dataValues = [Double]()
        var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
        
        for data in Constants.catagoryWise{
            strokesGainedData.append((data,0.0,0.0,0,0.0))
        }
        for score in classicScores{
            for i in 0..<score.clubDict.count{
                let clubClass = score.clubDict[i].1 as Club
                if(clubClass.type >= 0 && clubClass.type < 4){
                    strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                    strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                    strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                    strokesGainedData[clubClass.type].clubCount += 1
                }
            }
        }
        debugPrint(strokesGainedData)
        
        for data in strokesGainedData{
            dataPoints.append(data.clubType.localized())
            dataValues.append((data.clubStrokesGained / Double(classicScores.count)).rounded(toPlaces: 1))
            print(data)
        }
        self.strokesGainedPerClubBarChart.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: self.strokesGainedPerClubBarChart, color: UIColor.glfWhite, barWidth: 0.4,valueColor: UIColor.glfWhite.withAlphaComponent(0.5))
        strokesGainedPerClubBarChart.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.25)
        strokesGainedPerClubBarChart.leftAxis.labelTextColor  = UIColor.glfWhite.withAlphaComponent(0.5)
        strokesGainedPerClubBarChart.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        
        let publicScore  = PublicScore()
        let publicScoreStr = publicScore.getSGPerClub(gainAvg: dataValues[0], gainAvg1: dataValues[1], gainAvg2: dataValues[2], gainAvg3: dataValues[3])
        lblStrokesGainedPerClubAvg.text = publicScoreStr
    }
    
    func setStrokesGainedPerClubBarChart(){
        var dataPoints = [String]()
        var dataValues = [Double]()
        var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
        
        for data in Constants.catagoryWise{
            strokesGainedData.append((data,0.0,0.0,0,0.0))
        }
        for score in scores{
            for i in 0..<score.clubDict.count{
                let clubClass = score.clubDict[i].1 as Club
                if(clubClass.type >= 0 && clubClass.type < 4){
                    strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                    strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                    strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                    strokesGainedData[clubClass.type].clubCount += 1
                }
            }
        }
        debugPrint(strokesGainedData)
        var clubCou = 0
        for data in strokesGainedData{
            dataPoints.append(data.clubType.localized())
            dataValues.append((data.clubStrokesGained / Double(scores.count)).rounded(toPlaces: 1))
            clubCou += data.clubCount
            print(data)
        }

        if clubCou == 0{
            lblStrokesGainedPerClubAvg .isHidden = true
            let demoLabel = DemoLabel()
            demoLabel.frame = CGRect(x: 0, y: strokeGainedChartView.frame.height/2-15, width: strokeGainedChartView.frame.width, height: 30)
            strokeGainedChartView.addSubview(demoLabel)
            
            progressView.show(atView: self.view, navItem: self.navigationItem)
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/scoring") { (snapshot) in
                self.progressView.hide(navItem: self.navigationItem)
                
                let classicScore = Scores()
                let dataDic = (snapshot.value as? NSDictionary)!
                let dataArray = dataDic.allValues
                for i in 0..<dataArray.count {
                    if let smartCaddieDic = ((dataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                        var clubWiseArray = [Club]()
                        for key in Constants.allClubs{
                            var keysArray = smartCaddieDic.value(forKey: " \(key)")
                            if(keysArray == nil){
                                keysArray = smartCaddieDic.value(forKey: "\(key)")
                            }
                            if((keysArray) != nil){
                                let valueArray = keysArray as! NSArray
                                for j in 0..<valueArray.count{
                                    let clubData = Club()
                                    let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing")
                                    if((backSwing) != nil){
                                        clubData.backswing = backSwing as! Double
                                    }
                                    if let distance = (valueArray[j] as AnyObject).object(forKey: "distance") as? Double{
                                        clubData.distance = distance
                                        if(Constants.distanceFilter == 1){
                                            clubData.distance = distance/Constants.YARD
                                        }
                                    }
                                    var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                                    if let strk = (valueArray[j] as AnyObject).object(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double{
                                        strokesGained = strk
                                    }
                                    clubData.strokesGained = strokesGained
                                    
                                    let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore")
                                    if((swingScore) != nil){
                                        clubData.swingScore = swingScore as! Double
                                    }
                                    let type = (valueArray[j] as AnyObject).object(forKey: "type")
                                    if((type) != nil){
                                        clubData.type = type as! Int
                                    }
                                    if let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity") as? Double{
                                        clubData.proximity = proximity
                                        if(Constants.distanceFilter == 1){
                                            clubData.proximity = proximity/Constants.YARD
                                        }
                                    }
                                    let holeout = (valueArray[j] as AnyObject).object(forKey: "holeOut")
                                    if((holeout) != nil){
                                        clubData.holeout = holeout as! Double
                                    }
                                    
                                    clubWiseArray.append(clubData)
                                    classicScore.clubDict.append((key,clubData))
                                }
                            }
                        }
                    }
                    self.classicScores.append(classicScore)
                }
                DispatchQueue.main.async {
                    self.setStrokesGainedClassicData()
                }
            }
        }else{
            self.strokesGainedPerClubBarChart.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: self.strokesGainedPerClubBarChart, color: UIColor.glfWhite, barWidth: 0.4,valueColor: UIColor.glfWhite.withAlphaComponent(0.5))
            strokesGainedPerClubBarChart.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.25)
            strokesGainedPerClubBarChart.leftAxis.labelTextColor  = UIColor.glfWhite.withAlphaComponent(0.5)
            strokesGainedPerClubBarChart.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
            
            let publicScore  = PublicScore()
            let publicScoreStr = publicScore.getSGPerClub(gainAvg: dataValues[0], gainAvg1: dataValues[1], gainAvg2: dataValues[2], gainAvg3: dataValues[3])
            lblStrokesGainedPerClubAvg.text = publicScoreStr
            
        }
    }
    
    @objc func eddieProClicked(_ sender:UIButton){
        FBSomeEvents.shared.singleParamFBEvene(param: "Click My Scores Eddie")
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "Overview"
        self.navigationController?.pushViewController(viewCtrl, animated: false)
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
            viewCtrl.source = "Overview"
            self.navigationController?.pushViewController(viewCtrl, animated: false)

            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    func setupUI(){
        
        //        lblRoundsAvg.isHidden = true
        lblScoreDistributionAvg.isHidden = true
        lblScoringAvg.isHidden = true
        lblParAvg.isHidden = true
        //        lblPenaltyTrendsAvg.isHidden = true
        //        lblAvgPenaltiesTrendsValue.isHidden = true
        //        lblAvgRoundsValue.isHidden = true
        lblAvgPerformanceValue.isHidden = true
        
        roundCardView.backgroundColor = UIColor.glfBluegreen
        if(isDemoUser){
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.overviewStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)

                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Average Round Scores",value:StatsIntoConstants.averageRoundScores))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Score Distribution",value:StatsIntoConstants.scoreDistribution))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Scoring",value:StatsIntoConstants.scoring))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Par Average",value:StatsIntoConstants.parAverage))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"Strokes Gained",value:StatsIntoConstants.strokesGainedPerRound))
                        break
                    case 5:
                        self.cardViewInfoArray.append((title:"Penalities Trend",value:StatsIntoConstants.penalties))
                        break
                    default: break
                    }
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-50, y: 16, width: 25, height: 25)
                    if viewTag == 4{
                        statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-40, y: 16, width: 25, height: 25)
                    }
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == roundCardView) || (v == self.strokeGainedChartView){
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
            for v in self.overviewStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Average Round Scores",value:StatsIntoConstants.averageRoundScores))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Score Distribution",value:StatsIntoConstants.scoreDistribution))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Scoring",value:StatsIntoConstants.scoring))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Par Average",value:StatsIntoConstants.parAverage))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"Strokes Gained",value:StatsIntoConstants.strokesGainedPerRound))
                        break
                    case 5:
                        self.cardViewInfoArray.append((title:"Penalities Trend",value:StatsIntoConstants.penalties))
                        break
                    default: break
                    }
                    let shareStatsButton = ShareStatsButton()
                    shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                    shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                    shareStatsButton.tintColor = UIColor.glfFlatBlue
                    shareStatsButton.tag = viewTag
                    //------------- Amit's Changes -------------------------------
                    if (v == roundCardView) || (v == self.strokeGainedChartView){
                        shareStatsButton.tintColor = UIColor.white
                    }
                    //-------------------------------------------------------------
                    shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                    v.addSubview(shareStatsButton)
                    
                    //Stats Info Button
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width-shareStatsButton.frame.size.width)-70, y: 16, width: 25, height: 25)
                    if viewTag == 4{
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width-shareStatsButton.frame.size.width)-60, y: 16, width: 25, height: 25)
                    }
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == roundCardView) || (v == self.strokeGainedChartView){
                        statsInfoButton.tintColor = UIColor.white
                    }
                    statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                    v.addSubview(statsInfoButton)
                    
                    viewTag = viewTag+1
                }
            }
        }
        
        barViewPenaltiesTrend.isUserInteractionEnabled = false
        barViewParAverages.isUserInteractionEnabled = false
        pieViewScoring.isUserInteractionEnabled = false
        barViewScoreDistribution.isUserInteractionEnabled = false
        barViewRounds.isUserInteractionEnabled = false
        self.lblAvgScoreDistributionValue.isHidden = true
        self.lblAvgScoreDistribution.isHidden = true
        self.lblAvgRoundsValue.setCorner(color: UIColor.white.cgColor)
        self.lblAvgScoreDistributionValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgPerformanceValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgPenaltiesTrendsValue.setCorner(color: UIColor.glfBlack50.cgColor)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViewParAveragesBarChart(){
        let parCount = ParWise.init()
        for item in scores{
            if (item.parWise) != nil {
                if((item.parWise["three"]) != nil){
                    parCount.three = parCount.three + Double((item.parWise["three"]?.count)!)
                }
                if((item.parWise["four"]) != nil){
                    parCount.four = parCount.four + Double((item.parWise["four"]?.count)!)
                }
                if((item.parWise["five"]) != nil){
                    parCount.five = parCount.five + Double((item.parWise["five"]?.count)!)
                }
            }
        }
        let parValues = ParWise.init()
        for item in scores{
            if (item.parWise) != nil {
                if((item.parWise["three"]) != nil){
                    for (_,value) in (item.parWise["three"] as Dictionary!){
                        parValues.three = parValues.three + Double(UInt32(value))
                    }
                }
                if((item.parWise["four"]) != nil){
                    for (_,value) in (item.parWise["four"] as Dictionary!){
                        parValues.four = parValues.four + Double(UInt32(value))
                    }
                }
                if((item.parWise["five"]) != nil){
                    for (_,value) in (item.parWise["five"] as Dictionary!){
                        parValues.five = parValues.five + Double(UInt32(value))
                    }
                }
            }
        }
        //print(parValues)
        let finalParScore = ParWise()
        finalParScore.three = parValues.three/parCount.three
        finalParScore.four = parValues.four/parCount.four
        finalParScore.five = parValues.five/parCount.five
        let dataLable = ["Par3","Par4","Par5"]
        let dataPoints1 = [finalParScore.three,finalParScore.four,finalParScore.five]
        barViewParAverages.setStackedBarChart(dataPoints: dataLable, value1: dataPoints1 as! [Double] , chartView: barViewParAverages,barWidth:0.4)
        
        if Constants.baselineDict != nil{
            debugPrint("baselineDict==",Constants.baselineDict)
            
            let publicScore  = PublicScore()
            let publicScoreStr = publicScore.getOverviewParAvg(par3s: finalParScore.three, par4s: finalParScore.four, par5s: finalParScore.five)
            lblParAvg.isHidden = false
            lblParAvg.attributedText = publicScoreStr
        }
    }
    
    func setViewScoringPieChart(){
        var scoringArray = [Scoring]()
        for item in scores{
            let scoring = Scoring()
            scoring.doubleBogey = Double(item.scoring["2"]!) + Double(item.scoring["3"]!)
            scoring.bogey = Double(item.scoring["1"]!)
            scoring.par = Double(item.scoring["0"]!)
            scoring.birdie = Double(item.scoring["-1"]!)
            scoring.eagle = Double(item.scoring["-2"]!) + Double(item.scoring["-3"]!)
            
            scoringArray.append(scoring)
        }
        let score = Scoring.init()
        for item in scoringArray{
            score.doubleBogey = score.doubleBogey + item.doubleBogey
            score.bogey = score.bogey + item.bogey
            score.par = score.par + item.par
            score.birdie = score.birdie + item.birdie
            score.eagle = score.eagle + item.eagle
            //print(score)
        }
        let finalScoreInPercentage = Scoring.init()
        let totalSum = score.doubleBogey + score.bogey + (score.par as Double) + score.birdie + score.eagle
        finalScoreInPercentage.doubleBogey = (score.doubleBogey*100)/totalSum
        finalScoreInPercentage.bogey = (score.bogey*100)/totalSum
        finalScoreInPercentage.par = (score.par*100)/totalSum
        finalScoreInPercentage.birdie = (score.birdie*100)/totalSum
        finalScoreInPercentage.eagle = (score.eagle*100)/totalSum
        //print(finalScoreInPercentage)
        let dataLabel = ["2Bs","Bogeys","Pars","Birdies","Eagles"]
        let dataPoints = [finalScoreInPercentage.doubleBogey,finalScoreInPercentage.bogey,finalScoreInPercentage.par,finalScoreInPercentage.birdie,finalScoreInPercentage.eagle]
        
        pieViewScoring.setChartForScoring(dataPoints: dataLabel, values: dataPoints as! [Double], chartView: pieViewScoring,color:UIColor.glfSeafoamBlue,isValueEnable: true)
        //publicRankingof user
        if Constants.baselineDict != nil{
            var absoluteBirdie = 0.0
            var absolutePar = 0.0
            var absoluteBogey = 0.0
            var absoluteDBogey = 0.0
            
            if((score.eagle + score.birdie)>0) {
                absoluteBirdie = ((score.eagle + score.birdie) / totalSum) * 18;
            }
            if (score.doubleBogey>0){
                absoluteDBogey = (score.doubleBogey/totalSum) * 18;
            }
            if (score.bogey>0){
                absoluteBogey = (score.bogey/totalSum) * 18;
            }
            if (score.par>0){
                absolutePar = (score.par/totalSum) * 18;
            }
            debugPrint("baselineDict==",Constants.baselineDict)
            
            
            let publicScore  = PublicScore()
           
            let publicScoreStr = publicScore.getOverviewScoring(absoluteBirdie: absoluteBirdie, absolutePar: absolutePar, absoluteBogey: absoluteBogey, absoluteDBogey: absoluteDBogey)
            
            lblScoringAvg.isHidden = false
            lblScoringAvg.attributedText = publicScoreStr
        }
    }
    
    func setPenaltiesTrendBarCharts(){
        
        var xAxisLabelArray = [String]()
        var barDataArray = [Double]()
        for item in scores{
            if (item.penalty) != nil && item.penalty > 0{
                xAxisLabelArray.append(item.date)
                barDataArray.append(item.penalty)
            }
        }
        var avgPenalties = barDataArray.reduce(0, +)
        if(barDataArray.count > 0){
            avgPenalties = avgPenalties/Double(barDataArray.count)
        }
        lblAvgPenaltiesTrendsValue.text = "\(avgPenalties.rounded(toPlaces: 1))"
        lblPenaltyTrendsAvg.text = "Average Penalties Per Round "
        if avgPenalties >= 0.5{
            lblAvgPenaltiesTrendsValue.layer.borderColor = UIColor.glfDustyRed.cgColor
            lblAvgPenaltiesTrendsValue.textColor = UIColor.glfDustyRed
        }

        if(barDataArray.count > 0){
            barViewPenaltiesTrend.setBarChart(dataPoints: xAxisLabelArray, values: barDataArray, chartView: barViewPenaltiesTrend,color: UIColor.glfRosyPink, barWidth: 0.2, leftAxisMinimum: 0, labelTextColor: UIColor.glfWarmGrey,unit: "", valueColor: UIColor.glfWarmGrey)
            barViewPenaltiesTrend.leftAxis.axisMinimum = 0
            barViewPenaltiesTrend.leftAxis.axisMaximum = barDataArray.max()! + 1.0
            barViewPenaltiesTrend.leftAxis.labelCount = Int(barDataArray.max()!) + 1
        }
    }
    func setData(){
        var scoreArray = [Double]()
        for score in scores{
            scoreArray.append(score.score)
        }
        if(scoreArray.count > 0){
            bestRound = scoreArray.max()!
            avgScore = scoreArray.reduce(0,+)/Double(scoreArray.count)
        }
    }
    func setOverviewBarChart(){
        var dataPointsDate = [String]()
        var values = [Double]()
        var gameType = [String]()
        var avgScoreValue = Double()
        for score in scores{
            if(score.score != 0){
                dataPointsDate.append(score.date)
                gameType.append(score.type)
                var sum = 0
                for data in score.scoring{
                    sum += data.value
                }
                if(score.type == "9 holes") || (score.type == "9 hole"){
                    avgScoreValue += 2*score.score
                    values.append(score.score)
                }else if sum == 9 && (score.type != "9 holes"){
                    avgScoreValue += 2*score.score
                    values.append(2*score.score)
                }else{
                    avgScoreValue += score.score
                    values.append(score.score)
                }
            }
        }
        if(values.count > 0){
            avgScoreValue = avgScoreValue/Double(values.count)
        }
        lblAvgRoundsValue.text = "\((avgScoreValue).rounded(toPlaces: 1))"
        lblRoundsAvg.text = "Average Score "
        barViewRounds.setBarChartGameType(dataPoints: dataPointsDate, values: values, gameType: gameType, chartView: barViewRounds, barWidth: 0.2)
        barViewRounds.xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.75)
        barViewRounds.leftAxis.labelTextColor = UIColor.white.withAlphaComponent(0.75)
        barViewRounds.leftAxis.gridColor = UIColor.white.withAlphaComponent(0.25)
        barViewRounds.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        barViewRounds.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
    }
    
    func setScoreDistribution(){
        var scoreArray = [Double]()
        let KeysArray = ["below".localized() + "-85","86-90","91-95","96-100","101-105","105-" + "above".localized()]

        for keys in KeysArray{
            groupDict[keys] = 0
        }
        //print(groupDict)
        for i in 0..<scores.count{
            if(scores[i].type == "9 hole") || (scores[i].type == "9 holes"){
                scoreArray.append((scores[i].score)*2)
            }
            else{
                scoreArray.append(scores[i].score)
            }
        }
        
        for i in scoreArray{
            if(i<=85){
                updateValue(keys: "below".localized() + "-85")
            }
            else if(i>85 && i<=90){
                updateValue(keys: "86-90")
            }
            else if(i>90 && i<=95){
                updateValue(keys: "91-95")
            }
            else if(i>95 && i<=100){
                updateValue(keys: "96-100")
            }
            else if(i>100 && i<=105){
                updateValue(keys: "101-105")
            }
            else{
                updateValue(keys: "105-" + "above".localized())
            }
        }
        //print("This is Group Dict: ")
        //print(groupDict)
        var dataArray = [Double]()
        for i in 0..<KeysArray.count{
            //print(i,groupDict)
            dataArray.append(((groupDict[KeysArray[i]]!)*100)/Double(scoreArray.count))
        }
        //        let maxIndex = dataArray.index(of: dataArray.max()!)
        //        let label = Chatlogo()
        barViewScoreDistribution.setLineChartSimple(dataPoints:KeysArray , values: dataArray, chartView: barViewScoreDistribution,color:UIColor.glfFlatBlue)
        
    }
    func updateValue(keys:String){
        for (key,value) in groupDict{
            if(keys==key){
                var x = value
                x += 1
                groupDict.updateValue(x, forKey: keys)
            }
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Overview".localized())
    }
}

