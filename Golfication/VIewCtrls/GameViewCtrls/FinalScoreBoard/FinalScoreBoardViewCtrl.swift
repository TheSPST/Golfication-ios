//
//  FinalScoreBoardViewCtrlViewController.swift
//  Golfication
//
//  Created by Khelfie on 16/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Charts
import FirebaseAuth
import UICircularProgressRing
import Firebase
class FinalScoreBoardViewCtrl: UIViewController,UITableViewDelegate, UITableViewDataSource,CustomProModeDelegate{
    let catagoryWise = ["Off The Tee","Approach","Around The Green","Putting"]
    let clubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"]
    var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
    var parWiseValues = ParWise()
    var finalPlayersData = NSMutableArray()
    var finalPlayerMArray = NSMutableArray()
    var playersColor = [UIColor.glfPaleTeal,UIColor.glfDustyRed,UIColor.glfBluegreen,UIColor.glfRosyPink,UIColor.glfSeafoamBlue]
    var finalScoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var playerArray = [(id:String,name:String,image:String)]()
    var completeScoreArray = [(playerName:String,playerImg:String,longestDrive:Double,shotsArray:[Double],putts:Double,distToHol:[Double])]()
    var yCoordArray = [Double]()
    var xCoordArray = [Double]()
    var playerDistArray = [[Double]]()
    var userImg = [UIButton]()
    var isManualScoring = Bool()
    var matchDataDict = NSMutableDictionary()
    var currentMatchId : String!
    var fairway = [(hit:Int,left:Int,right:Int)]()
    let view1 = customPieViewLeft()
    let view2 = customPieViewCenter()
    let view3 = customPieViewRight()
    let lblFairwayLeft = UILabel()
    let lblFairwayRight = UILabel()
    let lblFairwayHit = UILabel()
    let leftImg = UIImageView(image: #imageLiteral(resourceName: "left"))
    let rightImg = UIImageView(image: #imageLiteral(resourceName: "right"))
    let hitImg = UIImageView(image: #imageLiteral(resourceName: "path15"))
    var girDetails = [(gir:Int,girMiss:Int,girWithFairway:Int,girWithoutFairway:Int,fairwayMiss:Int,fairwayHit:Int)]()
    var chippingArray = [Chipping]()
    var sandArray = [Chipping]()
    var appraochArray = [Chipping]()
    //    var scoring = [(hole:Int,par:Int,players:varMutableDictionary])]()
    var cardViewMArray = NSMutableArray()
    var clubsForStrokesGained = [(String,Club)]()
    var allScoring = [Scoring]()
    var justFinishedTheMatch = false
    let editThisRound = EditPreviousGame()

    @IBOutlet weak var lblStackViewftUnit: UIStackView!
    @IBOutlet weak var lblStackViewftPremiumUnit: UIStackView!

    @IBOutlet weak var lblStackViewYdUnit: UIStackView!
    @IBOutlet weak var lblStackViewUnit: UIStackView!
    @IBOutlet weak var scrollableStackView: UIStackView!
    @IBOutlet weak var cardForOTT: CardView!
    @IBOutlet weak var cardForSandAccuracy: CardView!
    @IBOutlet weak var cardForApproachAccuracy2: CardView!
    @IBOutlet weak var cardForChippingAccuracy1: CardView!
    @IBOutlet weak var cardForPremiumChippingAccuracy: CardView!

    @IBOutlet weak var btnEditRound: UIBarButtonItem!
    var scrollArray = [CardView]()
    
    @IBOutlet weak var lblApproachPro: UILabel!
    @IBOutlet weak var lblChippingPro: UILabel!
    @IBOutlet weak var lblSGPro: UILabel!
    @IBOutlet weak var lblOttPro: UILabel!
    @IBOutlet weak var lblSandPro: UILabel!
    
    @IBOutlet weak var scattredSpreadOfTheTeeChart: ScatterChartView!
    @IBOutlet weak var lblOTTLeft: UILabel!
    @IBOutlet weak var lblOTTCenter: UILabel!
    @IBOutlet weak var lblOTTRight: UILabel!
    
    @IBOutlet weak var sandAccuracyScatterChart: ScatterChartView!
    @IBOutlet weak var lblLongSnd: UILabel!
    @IBOutlet weak var lblLeftSnd: UILabel!
    @IBOutlet weak var lblRightSnd: UILabel!
    @IBOutlet weak var lblShortSnd: UILabel!
    @IBOutlet weak var lblHitSnd: UILabel!
    @IBOutlet weak var sandImageView: UIImageView!
    
    @IBOutlet weak var approchAccuracyScatterChart: ScatterChartView!
    var holesInAllRounds = [Hole]()

    @IBOutlet weak var finalScoringStackView: UIStackView!

    @IBOutlet weak var card1TableView: CardView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblStrokesGainedValue: UILabel!
    @IBOutlet weak var lblPremiumSGValue: UILabel!

    @IBOutlet weak var cardForScoring: CardView!
    @IBOutlet weak var pieChartForScring: PieChartView!
    
    @IBOutlet weak var barChartForParAverage: BarChartView!
    @IBOutlet weak var cardForParAverage: CardView!
    
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var cardForDrivingAccuracy: CardView!
    @IBOutlet weak var viewForDrivingAccuracy: UIView!
    
    @IBOutlet weak var cardForAppochAccuracy: CardView!
    
    @IBOutlet weak var accurayRingBar: UICircularProgressRingView!
    @IBOutlet weak var lblGreenWithFH: UILabel!
    @IBOutlet weak var lblGreenWithFM: UILabel!

    @IBOutlet weak var cardForStrokesGained: CardView!
    @IBOutlet weak var cardForPremiumSG: CardView!

    @IBOutlet weak var barChartStrokesGained: BarChartView!
    @IBOutlet weak var barChartPremiumSG: BarChartView!

    @IBOutlet weak var chippingAccuracyScatterView: ScatterChartView!
    @IBOutlet weak var chippingAccuracyPremimumScatterView: ScatterChartView!

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblLong: UILabel!
    @IBOutlet weak var lblHit: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblShort: UILabel!

    @IBOutlet weak var lblLongChip: UILabel!
    @IBOutlet weak var lblHitChip: UILabel!
    @IBOutlet weak var lblRightChip: UILabel!
    @IBOutlet weak var lblLeftChip: UILabel!
    @IBOutlet weak var lblShortChip: UILabel!
    
    @IBOutlet weak var lblPremiumLongChip: UILabel!
    @IBOutlet weak var lblPremiumHitChip: UILabel!
    @IBOutlet weak var lblPremiumRightChip: UILabel!
    @IBOutlet weak var lblPremiumLeftChip: UILabel!
    @IBOutlet weak var lblPremiumShortChip: UILabel!
    
    @IBOutlet weak var card2: CardView!
    @IBOutlet weak var card2LineChart: LineChartView!
    @IBOutlet weak var card2ScoreDistribution: UILabel!
    @IBOutlet weak var card2AvgValue: UILabel!
    @IBOutlet weak var card2Avg: UILabel!
    
    @IBOutlet weak var card3Title: UILabel!
    @IBOutlet weak var card3: CardView!
    @IBOutlet weak var card3Avg: UILabel!
    @IBOutlet weak var card3AvgValue: UILabel!
    @IBOutlet weak var card3LineChartCurved: LineChartView!
    
    @IBOutlet weak var card4: CardView!
    @IBOutlet weak var card4ScatterChart: ScatterChartView!
    @IBOutlet weak var card4Title: UILabel!
    @IBOutlet weak var card4Avg: UILabel!
    
    @IBOutlet weak var card4AvgValue: UILabel!
    @IBOutlet weak var card5: CardView!
    @IBOutlet weak var card5MonsterPuttLineChart: LineChartView!
    @IBOutlet weak var card5Title: UILabel!
    @IBOutlet weak var card5Avg: UILabel!
    @IBOutlet weak var card5AvgValue: UILabel!
    @IBOutlet weak var SandAccuracyStackView: UIStackView!
    
    @IBOutlet weak var tblContainerHConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnPlayNow: UIButton!
    @IBOutlet weak var viewMoreStats: UIView!

    @IBOutlet weak var moreStatsContainerImage: UIView!
    @IBOutlet weak var viewProStatsUnlocked: UIView!
    @IBOutlet weak var btnStatsBecomePro: UIButton!

    var superClassName : String!
    let label = UILabel()
    var myVal: Int = 0
    var shotMoreTan9 = false
    
    @IBOutlet weak var timerLabel: UILabel!
    var countdownTimer: Timer!

    @IBAction func backButtonAction(_ sender: Any) {
        if(superClassName! == "MyFeedVC"){
            self.navigationController?.popViewController(animated: true)
        }else{
//            let dashboardVC = navigationController!.viewControllers.filter { $0 is NewHomeVC }.first!
//            navigationController!.popToViewController(dashboardVC, animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func editRoundAction(_ sender: Any) {
        self.editThisRound.continuePreviousMatch(matchId: self.currentMatchId!, userId: Auth.auth().currentUser!.uid)
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Round Summary"
        self.automaticallyAdjustsScrollViewInsets = false
        if fromGameImprovement{
            redirectToJoinFBGameImprovement()
        }        
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterResponseEditRound(_:)), name: NSNotification.Name(rawValue: "editRound"), object: nil)

        superClassName = NSStringFromClass((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].classForCoder)!).components(separatedBy: ".").last!
        cardForStrokesGained.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        cardForPremiumSG.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        
        cardForChippingAccuracy1.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        cardForPremiumChippingAccuracy.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))

        cardForOTT.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        cardForSandAccuracy.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        cardForApproachAccuracy2.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        let originalImage = #imageLiteral(resourceName: "sand")
        let sandImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        sandImageView.image = sandImage
        sandImageView.tintColor = UIColor.glfWhite
        for data in self.catagoryWise{
            self.strokesGainedData.append((data,0.0,0.0,0,0.0))
        }
        if(distanceFilter == 1){
            var meterString = [" 60m "," 40m "," 20m ","20m","40m","60m"]
            var i = 0
            for view in self.lblStackViewYdUnit.arrangedSubviews{
                (view as! UILabel).text = meterString[i]
                i += 1
            }
            var meterString1 = ["15m","10m","5m","5m","10m","15m"]
            i = 0
            for view in self.lblStackViewUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.lblStackViewftUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.lblStackViewftPremiumUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.SandAccuracyStackView.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
        }else{
            var meterString = [" 60yd "," 40yd "," 20yd ","20yd","40yd","60yd"]
            var i = 0
            for view in self.lblStackViewYdUnit.arrangedSubviews{
                (view as! UILabel).text = meterString[i]
                i += 1
            }
            var meterString1 = ["45ft","30ft","15ft","15ft","30ft","45ft"]
            i = 0
            for view in self.lblStackViewUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.lblStackViewftUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.lblStackViewftPremiumUnit.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
            i = 0
            for view in self.SandAccuracyStackView.arrangedSubviews{
                (view as! UILabel).text = meterString1[i]
                i += 1
            }
        }

        self.setUpinitialUI()
        for i in 0..<finalPlayersData.count{
            let playerId = (finalPlayersData[i] as AnyObject).value(forKey: "id") as? String
            let playerName = (finalPlayersData[i] as AnyObject).value(forKey: "name") as? String
            let img = (finalPlayersData[i] as AnyObject).value(forKey: "image") as? String
            playerArray.append((id: playerId!, name: playerName ?? "", image: img ?? ""))
            let button = UIButton()
            let frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            button.setCorner(color: playersColor[i].cgColor)
            button.setCircle(frame: frame)
            button.backgroundColor = playersColor[i]
            button.isUserInteractionEnabled = false
            fairway.append((hit: 0 , left: 0, right: 0))
            girDetails.append((gir: 0, girMiss: 0, girWithFairway: 0, girWithoutFairway: 0, fairwayMiss: 0, fairwayHit: 0))
            allScoring.append(Scoring())
            if(i == 0){
                if !(self.justFinishedTheMatch){
                    self.getStrokesGainedFirebase(playerId: playerId!, matchid: self.currentMatchId!)
                }else{
                    self.actvtIndView.isHidden = false
                    self.actvtIndView.startAnimating()
                    ref.child("userData/\(playerId!)/scoring").observe(DataEventType.value, with: { (snapshot) in
                        self.getStrokesGainedFirebase(playerId: playerId!, matchid: self.currentMatchId!)
                    })
                }
            }
            if(img != nil){
                button.sd_setBackgroundImage(with: URL(string:img!), for: .normal, placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
                if(button.currentBackgroundImage == #imageLiteral(resourceName: "you")){
                    button.setBackgroundImage(nil, for: .normal)
                    button.setTitle("\(playerName!.first!)", for: .normal)
                }
            }
            userImg.append(button)
            
        }
        self.getData()
        // Do any additional setup after loading the view.
        let tempdic = NSMutableDictionary()
        tempdic.setObject(" ", forKey: "id" as NSCopying)
        tempdic.setObject(" ", forKey: "name" as NSCopying)
        tempdic.setObject(" ", forKey: "image" as NSCopying)
        tempdic.setObject(-2, forKey: "status" as NSCopying)
        tempdic.setObject(-2, forKey: "timestamp" as NSCopying)
        
        finalPlayersData.insert(tempdic, at: 0)
        
        if finalPlayerMArray.count == 0 {
            finalPlayerMArray.addObjects(from: finalPlayersData as! [Any])
            finalPlayerMArray.removeObject(at: 0)
        }

        
        scrollArray = [cardForChippingAccuracy1,cardForApproachAccuracy2,cardForOTT,cardForSandAccuracy]
        pageControl.currentPage = 0
        for i in 0..<scrollArray.count{
            self.scrollableStackView.addArrangedSubview(scrollArray[i])
            scrollArray[i].isHidden = true
            if (i == pageControl.currentPage){
                scrollArray[i].isHidden = false
            }
        }
        self.pageControl.numberOfPages = scrollArray.count
        
        viewMoreStats.isHidden = true
        viewProStatsUnlocked.isHidden = true
        if let mode = matchDataDic.value(forKey: "scoringMode") as? String{
            if(mode == "classic") || (mode == "rangefinder"){
                
                for i in 0..<finalPlayersData.count{
                    let playerId = (finalPlayersData[i] as AnyObject).value(forKey: "id") as? String
                    if playerId == Auth.auth().currentUser!.uid{
                        viewProStatsUnlocked.isHidden = true
                        viewMoreStats.isHidden = false
                        btnPlayNow.setCornerWithRadius(color: UIColor.clear.cgColor, radius: 20.0)
                        moreStatsContainerImage.layer.cornerRadius = moreStatsContainerImage.frame.size.height/2
                        break
                    }
                }
            }
            else{
                for i in 0..<finalPlayersData.count{
                    let playerId = (finalPlayersData[i] as AnyObject).value(forKey: "id") as? String
                    if playerId == Auth.auth().currentUser!.uid{
                        if !isProMode{
                        if let summaryTimer = (finalPlayersData[i] as AnyObject).value(forKey: "summaryTimer") as? Int64{
                            let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(summaryTimer/1000)))
                            let timeEnd = Calendar.current.date(byAdding: .second, value: 3600, to: timeStart as Date)
                            
                            let timeNow = NSDate()
                            let calendar = NSCalendar.current
                            var components = calendar.dateComponents([.second], from: timeNow as Date, to: timeEnd!)
                            
                            if components.second == 0 || components.second! < 0{
                                viewMoreStats.isHidden = true
                                viewProStatsUnlocked.isHidden = true
                            }
                            else{
                                viewMoreStats.isHidden = true
                                viewProStatsUnlocked.isHidden = false
                                btnStatsBecomePro.setCornerWithRadius(color: UIColor.clear.cgColor, radius: 20.0)
                                startTimer(totalTime: (components.second!))
                            }
                        }
                        }
                        break
                    }
                }
            }
        }
//        self.navigationItem.rightBarButtonItem = nil
        self.btnEditRound.isEnabled = false
        for data in self.finalPlayersData{
            if let uid =  (data as AnyObject).value(forKey: "id") as? String{
                if(uid == Auth.auth().currentUser!.uid){
                    self.btnEditRound.isEnabled = true
                    break
                }
            }
        }
    }
   
    func startTimer(totalTime : Int) {
        var totalTime = totalTime
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
        self.timerLabel.text = "\(self.timeFormatted(totalTime)) min"
            
            if totalTime != 0 {
                totalTime -= 1
            }
            else {
                self.viewProStatsUnlocked.isHidden = true
                self.countdownTimer.invalidate()
            }
        })
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
//        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func premiumBecomeAProAction(_ sender: UIButton){
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.2)
    }
    
    @IBAction func playNowAction(_ sender: UIButton){
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func getStrokesGainedFirebase(playerId:String,matchid:String){
        var playerIndex = Int()
        for i in 0..<playerArray.count{
            if(playerId == playerArray[i].id){
                playerIndex = i
                break
            }
        }
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/\(playerId)/scoring/\(matchid)") { (snapshot) in
            if !(self.justFinishedTheMatch){
                self.actvtIndView.isHidden = false
                self.actvtIndView.startAnimating()
            }
            var dataDic = NSDictionary()
            if(snapshot.value != nil){
                dataDic = (snapshot.value as? NSDictionary)!
                debugPrint(dataDic)
                self.clubsForStrokesGained = self.transferDataIntoClasses(myDataDict: dataDic)
                for i in 0..<self.clubsForStrokesGained.count{
                    let clubClass = self.clubsForStrokesGained[i].1 as Club
                    if(clubClass.type >= 0 && clubClass.type < 4){
                        self.strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                        self.strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                        self.strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                        self.strokesGainedData[clubClass.type].clubCount += 1
                    }
                }
                if let scoringData = dataDic.value(forKey: "scoring") as? NSMutableDictionary{
                    let scoring = Scoring()
                    scoring.doubleBogey = Double(scoringData.value(forKey: "2") as! Double) + Double(scoringData.value(forKey: "3") as! Double)
                    scoring.bogey = Double(scoringData.value(forKey: "1") as! Double)
                    scoring.par = Double(scoringData.value(forKey: "0") as! Double)
                    scoring.birdie = Double(scoringData.value(forKey: "-1") as! Double)
                    scoring.eagle = Double(scoringData.value(forKey: "-2") as! Double)  + Double(scoringData.value(forKey: "-3") as! Double)
                    self.allScoring[playerIndex] = scoring
                }
                if let parValues = dataDic.value(forKey: "parWise") as? NSMutableDictionary{
                    if let par5 = parValues.value(forKey: "five") as? NSMutableDictionary{
                        let allValues = par5.allValues as! [Int]
                        let sum = allValues.reduce(0, +)
                        self.parWiseValues.five = Double(sum)/Double(allValues.count)
                    }
                    if let par4 = parValues.value(forKey: "four") as? NSMutableDictionary{
                        let allValues = par4.allValues as! [Int]
                        let sum = allValues.reduce(0, +)
                        self.parWiseValues.four = Double(sum)/Double(allValues.count)
                    }
                    if let par3 = parValues.value(forKey: "three") as? NSMutableDictionary{
                        let allValues = par3.allValues as! [Int]
                        let sum = allValues.reduce(0, +)
                        self.parWiseValues.three = Double(sum)/Double(allValues.count)
                    }
                }
                if let hit = dataDic.value(forKey: "fairwayHit") as? Int{
                    self.fairway[playerIndex].hit = hit
                    self.girDetails[playerIndex].fairwayHit = hit
                }
                if let left = dataDic.value(forKey: "fairwayLeftValue") as? Int{
                    self.fairway[playerIndex].left = left
                }
                if let miss = dataDic.value(forKey: "fairwayMiss") as? Int{
                    self.girDetails[playerIndex].fairwayMiss = miss
                }
                if let right = dataDic.value(forKey: "fairwayRightValue") as? Int{
                    self.fairway[playerIndex].right = right
                }
                if let gir = dataDic.value(forKey: "gir") as? Int{
                    self.girDetails[playerIndex].gir = gir
                }
                if let girMiss = dataDic.value(forKey: "girMiss") as? Int{
                    self.girDetails[playerIndex].girMiss = girMiss
                }
                if let girWF = dataDic.value(forKey: "girWithFairway") as? Int{
                    self.girDetails[playerIndex].girWithFairway = girWF
                }
                if let girWOF = dataDic.value(forKey: "girWoFairway") as? Int{
                    self.girDetails[playerIndex].girWithoutFairway = girWOF
                }
                
                if let chipping = dataDic.value(forKey: "chipping") as? NSArray{
                    for i in 0..<chipping.count{
                        let chip = Chipping()
                        chip.club = (chipping[i] as AnyObject).object(forKey:"club") as? String
                        chip.distance = (chipping[i] as AnyObject).object(forKey:"distance") as? Double
                        chip.hole = (chipping[i] as AnyObject).object(forKey:"hole") as? Int
                        chip.proximityX = (chipping[i] as AnyObject).object(forKey:"proximityX") as? Double
                        chip.proximityY = (chipping[i] as AnyObject).object(forKey:"proximityY") as? Double
                        chip.und = (chipping[i] as AnyObject).object(forKey:"und") as? Int
                        chip.green = (chipping[i] as AnyObject).object(forKey:"green") as? Bool
                        if(distanceFilter == 1){
                            chip.proximityX = chip.proximityX/YARD
                            chip.proximityY = chip.proximityY/YARD
                            chip.distance = chip.distance/YARD
                        }
                        self.chippingArray.append(chip)
                    }
                }
                if let holesDict = dataDic.value(forKey: "tees") as? NSDictionary{
                    let holes = holesDict.allValues
                    debugPrint(self.playerArray)
                    for i in 0..<holes.count{
                        let hole = Hole()
                        hole.club = (holes[i] as AnyObject).object(forKey:"club") as! String
                        if let dist = (holes[i] as AnyObject).object(forKey:"distance") as? String{
                            hole.distance = Double(dist)
                            debugPrint(self.currentMatchId!)
                        }else{
                            hole.distance = (holes[i] as AnyObject).object(forKey:"distance") as! Double
                        }
                        if let spred = (holes[i] as AnyObject).object(forKey:"spread") as? String{
                            hole.spread = Double(spred)
                        }else{
                            hole.spread = (holes[i] as AnyObject).object(forKey:"spread") as! Double
                        }

                        if(distanceFilter == 1){
                            hole.distance = hole.distance/YARD
                        }
                        if let fHit = (holes[i] as AnyObject).object(forKey:"fairway") as? String{
                            hole.hitMiss = fHit
                        }
                        self.holesInAllRounds.append(hole)
                    }
                }
                if let chipping = dataDic.value(forKey: "sand") as? NSArray{
                    for i in 0..<chipping.count{
                        let chip = Chipping()
                        chip.club = (chipping[i] as AnyObject).object(forKey:"club") as? String
                        chip.distance = (chipping[i] as AnyObject).object(forKey:"distance") as? Double
                        chip.hole = (chipping[i] as AnyObject).object(forKey:"hole") as? Int
                        chip.proximityX = (chipping[i] as AnyObject).object(forKey:"proximityX") as? Double
                        chip.proximityY = (chipping[i] as AnyObject).object(forKey:"proximityY") as? Double
                        chip.und = (chipping[i] as AnyObject).object(forKey:"und") as? Int
                        chip.green = (chipping[i] as AnyObject).object(forKey:"green") as? Bool
                        if(distanceFilter == 1){
                            chip.proximityX = chip.proximityX/YARD
                            chip.proximityY = chip.proximityY/YARD
                            chip.distance = chip.distance/YARD
                        }
                        self.sandArray.append(chip)
                    }
                }
                if let chipping = dataDic.value(forKey: "approach") as? NSArray{
                    for i in 0..<chipping.count{
                        let chip = Chipping()
                        chip.club = (chipping[i] as AnyObject).object(forKey:"club") as? String
                        chip.distance = (chipping[i] as AnyObject).object(forKey:"distance") as? Double
                        chip.hole = (chipping[i] as AnyObject).object(forKey:"hole") as? Int
                        chip.proximityX = (chipping[i] as AnyObject).object(forKey:"proximityX") as? Double
                        chip.proximityY = (chipping[i] as AnyObject).object(forKey:"proximityY") as? Double
                        chip.und = (chipping[i] as AnyObject).object(forKey:"und") as? Int
                        chip.green = (chipping[i] as AnyObject).object(forKey:"green") as? Bool
                        if(distanceFilter == 1){
                            chip.proximityX = chip.proximityX/YARD
                            chip.proximityY = chip.proximityY/YARD
                            chip.distance = chip.distance/YARD
                        }
                        self.appraochArray.append(chip)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.actvtIndView.isHidden = true
                self.actvtIndView.stopAnimating()
                self.setStrokesGainedPerClubBarChart()
                self.setViewScoringPieChart()
                self.setViewParAveragesBarChart()
                self.setSpreadOffTheTeaGraph()
                self.setDrivingAccuracyChart()
                self.setupGirCircularChart()
                self.setupchippingAccuracyScatterView()
                self.setupSandAccuracyScatterChart()
                self.setupApprochAccuracyScatterChart()
                if(self.scrollArray.count == 0){
                    self.scrollableStackView.isHidden = true
                }else{
                    for i in 0..<self.scrollArray.count{
                        if !(self.scrollArray[i].isHidden){
                            self.pageControl.currentPage = i
                            break
                        }
                    }
                }
                if (self.cardForPremiumSG.isHidden == true) && (self.cardForPremiumChippingAccuracy.isHidden == true){
                    self.viewProStatsUnlocked.isHidden = true
                }
            })
        }
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
    func setupApprochAccuracyScatterChart(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        for data in self.appraochArray{
            proximityXPoints.append(data.proximityX)
            proximityYPoints.append(data.proximityY)
            if(data.green) != nil && (data.green){
                hit += 1
                color.append(UIColor.glfWhite)
            }else{
                color.append(UIColor.glfRosyPink)
                if(data.proximityY >= abs(data.proximityX)){
                long += 1
                }else if(data.proximityY <= -abs(data.proximityX)){
                    short += 1
                }else if(data.proximityX >= abs(data.proximityY)){
                    right += 1
                }else if(data.proximityX <= -abs(data.proximityY)){
                    left += 1
                }
            }
        }
        let sumOfLSRL = long+short+right+left+hit
        if(sumOfLSRL != 0){
            approchAccuracyScatterChart.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: approchAccuracyScatterChart, color: color)
            approchAccuracyScatterChart.leftAxis.enabled = false
            approchAccuracyScatterChart.leftAxis.axisMaximum = 90
            approchAccuracyScatterChart.leftAxis.axisMinimum = -90
            approchAccuracyScatterChart.xAxis.enabled = false
            approchAccuracyScatterChart.xAxis.axisMaximum = 90
            approchAccuracyScatterChart.xAxis.axisMinimum = -90
            lblLong.text = "Long \(100*long/sumOfLSRL)%"
            lblShort.text = "Short \(100*short/sumOfLSRL)%"
            lblRight.text = "Right \(100*right/sumOfLSRL)%"
            lblLeft.text = "Left \(100*left/sumOfLSRL)%"
            lblHit.text = "Hit \(100*hit/sumOfLSRL)%"
        }else{
            self.cardForApproachAccuracy2.isHidden = true
            if let index = self.scrollArray.index(of: cardForApproachAccuracy2){
                self.scrollArray.remove(at:index)
            }
            self.pageControl.numberOfPages = self.scrollArray.count
        }
        
    }
    func setupGirCircularChart(){
        var girArray = [Double]()
        var girMissArray = [Double]()
        var totalFairwayHit = 0.0
        var totalFairwayMiss = 0.0
        var girFairwayHit = 0.0
        var girFairwayMiss = 0.0
        for score in self.girDetails{
            if(score.gir != 0){
                girArray.append(Double(score.gir))
            }
            if(score.girMiss != 0){
                girMissArray.append(Double(score.girMiss))
            }
            totalFairwayHit += Double(score.fairwayHit)
            totalFairwayMiss += Double(score.fairwayMiss)
            girFairwayHit += Double(score.girWithFairway)
            girFairwayMiss += Double(score.girWithoutFairway)
        }
        let sum = girArray.reduce(0, +)
        
        let totalSum = (sum + girMissArray.reduce(0, +))
        if(totalFairwayHit != 0){
            self.lblGreenWithFH.text = "\(((girFairwayHit/totalFairwayHit)*100).rounded(toPlaces: 1))%"
        }else{
            self.lblGreenWithFH.text = "0.0%"
        }
        if(totalFairwayMiss != 0){
            self.lblGreenWithFM.text = "\(((girFairwayMiss/totalFairwayMiss)*100).rounded(toPlaces: 1))%"
        }else{
            self.lblGreenWithFM.text = "0.0%"
        }
        if(sum != 0){
            let girPercantage = (sum / totalSum)*100
            accurayRingBar.setProgress(value: CGFloat(girPercantage), animationDuration: 1.0)
        }else{
            self.cardForAppochAccuracy.isHidden = true
        }
    }
    func setUpScoreTrends(){
        var playerName = [String]()
        var player1Shots = [[Double]]()
        for score in self.completeScoreArray{
            player1Shots.append(score.shotsArray)
            playerName.append(score.playerName)
        }
        self.card2LineChart.setLineChartWithZigZag(dataPoints: player1Shots.count, values: player1Shots, chartView: self.card2LineChart, color:playersColor, playersName: playerName)
    }
    func setUpLongestDrive(){
        var xyCoordinates = [[(x:Double,y:Double)]]()
        let y = self.card3LineChartCurved.frame.height - 40.0
        let width = self.card3LineChartCurved.frame.width
        var playersName = [String]()
        for i in 0..<self.completeScoreArray.count{
            if(self.completeScoreArray[i].longestDrive > 0){
                xyCoordinates.append(self.getYCoordinates(dist:self.completeScoreArray[i].longestDrive))
                let btn  = UIButton()
                btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                btn.setCircle(frame: btn.frame)
                let url = URL(string:(finalPlayersData[i] as AnyObject).value(forKey: "image") as! String)
                btn.sd_setBackgroundImage(with: url, for: .normal, completed: nil)
                if url == nil{
                    btn.setBackgroundImage(UIImage(named: "you"), for: .normal)
                }
                btn.frame.origin = CGPoint(x:(self.completeScoreArray[i].longestDrive/650)*Double(width),y:Double(y))
                self.card3LineChartCurved.addSubview(btn)
                playersName.append(self.completeScoreArray[i].playerName)
            }
        }
        self.card3LineChartCurved.setCurveWithColor(dataPoints: xyCoordinates.count, values: xyCoordinates, chartView: self.card3LineChartCurved, color: playersColor,playersName:playersName, maxRange: 500)
    }
    func setupchippingAccuracyScatterView(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        for data in chippingArray{
            proximityXPoints.append(data.proximityX * 3)
            proximityYPoints.append(data.proximityY * 3)
            if(data.green) != nil && (data.green){
                hit += 1
                color.append(UIColor.glfWhite)
            }else{
                color.append(UIColor.glfRosyPink)
            if(data.proximityY >= abs(data.proximityX)){
                long += 1
            }
            else if(data.proximityY <= -abs(data.proximityX)){
                short += 1
            }
            else if(data.proximityX >= abs(data.proximityY)){
                right += 1
            }
            else if(data.proximityX <= -abs(data.proximityY)){
                left += 1
            }
        }
    }
        let sumOfLSRL = long+short+right+left+hit
        if(sumOfLSRL != 0){
            chippingAccuracyScatterView.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: chippingAccuracyScatterView, color: color)
            chippingAccuracyScatterView.leftAxis.enabled = false
            chippingAccuracyScatterView.xAxis.enabled = false
            chippingAccuracyScatterView.leftAxis.axisMaximum = 90
            chippingAccuracyScatterView.leftAxis.axisMinimum = -90
            chippingAccuracyScatterView.xAxis.axisMaximum = 90
            chippingAccuracyScatterView.xAxis.axisMinimum = -90
            
            chippingAccuracyPremimumScatterView.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: chippingAccuracyPremimumScatterView, color: color)
            chippingAccuracyPremimumScatterView.leftAxis.enabled = false
            chippingAccuracyPremimumScatterView.xAxis.enabled = false
            chippingAccuracyPremimumScatterView.leftAxis.axisMaximum = 90
            chippingAccuracyPremimumScatterView.leftAxis.axisMinimum = -90
            chippingAccuracyPremimumScatterView.xAxis.axisMaximum = 90
            chippingAccuracyPremimumScatterView.xAxis.axisMinimum = -90

            lblLongChip.text = "Long \(100*long/sumOfLSRL)%"
            lblShortChip.text = "Short \(100*short/sumOfLSRL)%"
            lblRightChip.text = "Right \(100*right/sumOfLSRL)%"
            lblLeftChip.text = "Left \(100*left/sumOfLSRL)%"
            lblHitChip.text = "Hit \(100*hit/sumOfLSRL)%"
            
            lblPremiumLongChip.text = "Long \(100*long/sumOfLSRL)%"
            lblPremiumShortChip.text = "Short \(100*short/sumOfLSRL)%"
            lblPremiumRightChip.text = "Right \(100*right/sumOfLSRL)%"
            lblPremiumLeftChip.text = "Left \(100*left/sumOfLSRL)%"
            lblPremiumHitChip.text = "Hit \(100*hit/sumOfLSRL)%"

        }else{
            self.cardForChippingAccuracy1.isHidden = true
            self.cardForPremiumChippingAccuracy.isHidden = true
            if let index = self.scrollArray.index(of: cardForChippingAccuracy1){
                self.scrollArray.remove(at:index)
            }
            self.pageControl.numberOfPages = self.scrollArray.count
        }
    }
    func setUpDistanceToHole(){
        var xCoordinates = [Double]()
        var yCoordinates = [Double]()
        var dataPoints = [String]()
        var count = 0
        var userData = [Int]()
        for i in 0..<self.completeScoreArray.count{
            dataPoints.append(self.completeScoreArray[i].playerName)
            let btn = userImg[i]
            btn.frame.origin = CGPoint(x: Double(self.card4ScatterChart.frame.width*0.8), y: Double(40*(i+1)))
            self.card4ScatterChart.addSubview(btn)
            userData.append(self.completeScoreArray[i].distToHol.count)
            for j in 0..<self.completeScoreArray[i].distToHol.count{
                if(self.completeScoreArray[i].distToHol[j] == 0){
                    xCoordinates.append(0)
                    yCoordinates.append(0)
                }
                else{
                    let distance :Int = Int(self.completeScoreArray[i].distToHol[j].rounded())
                    let xcord = Double(arc4random_uniform(UInt32(distance)))
                    let x = xcord
                    xCoordinates.append(x)
                    yCoordinates.append(sqrt(Double(distance * distance) - x*x))
                }
            }
            count += 1
        }
        for i in 0..<xCoordinates.count{
            if !((arc4random_uniform(UInt32(100)) <= 75) && (arc4random_uniform(UInt32(100)) >= 25)){
                    xCoordinates[i] = -xCoordinates[i]
                    yCoordinates[i] = -yCoordinates[i]
            }
        }
        self.card4ScatterChart.setScatterChartWithLegend(valueX: xCoordinates, valueY: yCoordinates, dataPoints: dataPoints, chartView: self.card4ScatterChart, color: playersColor,userData:userData)
        card4ScatterChart.leftAxis.axisMinimum = -90
        card4ScatterChart.leftAxis.axisMaximum = 90
        card4ScatterChart.xAxis.axisMinimum = -120
        card4ScatterChart.xAxis.axisMaximum = 120
        card4ScatterChart.xAxis.enabled = false
        card4ScatterChart.leftAxis.enabled = false
    }
    func setDrivingAccuracyChart(){
        var fairwayLeft = Int()
        var fairwayHit = Int()
        var fairwayRight = Int()
        for item in self.fairway{
            fairwayHit += item.hit
            fairwayLeft += item.left
            fairwayRight += item.right
        }
        let totalFairway = fairwayHit+fairwayLeft+fairwayRight
        var fairwayLeftInPercentage = 0
        var fairwayHitInPercentage = 0
        var fairwayRightInPercentage = 0
        if(fairwayLeft != 0){
            fairwayLeftInPercentage = ((fairwayLeft)*100)/(totalFairway)
        }
        if(fairwayHit != 0){
            fairwayHitInPercentage = ((fairwayHit)*100)/(totalFairway)
        }
        if(fairwayRight != 0){
            fairwayRightInPercentage = ((fairwayRight)*100)/(totalFairway)
        }
        self.lblFairwayHit.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        self.lblFairwayRight.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        self.lblFairwayLeft.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        self.lblFairwayRight.text = "\(fairwayRightInPercentage)%"
        self.lblFairwayHit.text = "\(fairwayHitInPercentage)%"
        self.lblFairwayLeft.text = "\(fairwayLeftInPercentage)%"
        
        self.lblOTTLeft.text = "Right Rough \(fairwayLeftInPercentage)%"
        self.lblOTTCenter.text = "Fairway \(fairwayHitInPercentage)%"
        self.lblOTTRight.text = "Left Rough \(fairwayRightInPercentage)%"
        
        
        if(fairwayHitInPercentage > 90){
            hitImg.removeFromSuperview()
        }
        if(fairwayLeftInPercentage > 90){
            leftImg.removeFromSuperview()
        }
        if(fairwayRightInPercentage > 90){
            rightImg.removeFromSuperview()
        }
        view1.updateViewWithColor(rect: view1.frame, color: UIColor.glfRosyPink, radius: view1.frame.height*CGFloat(fairwayLeftInPercentage)/100)
        view2.updateViewWithColor(rect: view2.frame, color: UIColor.glfPaleTeal, radius: view2.frame.height*CGFloat(fairwayHitInPercentage)/100)
        view3.updateViewWithColor(rect: view3.frame, color: UIColor.glfRosyPink, radius: view3.frame.height*CGFloat(fairwayRightInPercentage)/100)
        
        if(totalFairway == 0){
            self.cardForDrivingAccuracy.isHidden = true
        }
        
    }
    func setViewParAveragesBarChart(){
        let dataLable = ["Par3","Par4","Par5"]
        let dataPoints1 = [self.parWiseValues.three,self.parWiseValues.four,self.parWiseValues.five]
        barChartForParAverage.setStackedBarChart(dataPoints: dataLable, value1: dataPoints1 as! [Double] , chartView: barChartForParAverage,barWidth:0.4)
        if(self.parWiseValues.three == 0.0){
            self.cardForParAverage.isHidden = true
        }
    }
    func setViewScoringPieChart(){
        let finalScoreInPercentage = Scoring.init()
        let totalSum = allScoring[0].doubleBogey + allScoring[0].bogey + (allScoring[0].par as Double) + allScoring[0].birdie + allScoring[0].eagle
        finalScoreInPercentage.doubleBogey = (allScoring[0].doubleBogey*100)/totalSum
        finalScoreInPercentage.bogey = (allScoring[0].bogey*100)/totalSum
        finalScoreInPercentage.par = (allScoring[0].par*100)/totalSum
        finalScoreInPercentage.birdie = (allScoring[0].birdie*100)/totalSum
        finalScoreInPercentage.eagle = (allScoring[0].eagle*100)/totalSum
        print(finalScoreInPercentage)
        let dataLabel = ["2Bs","Bogeys","Pars","Birdies","Eagles"]
        let dataPoints = [finalScoreInPercentage.doubleBogey,finalScoreInPercentage.bogey,finalScoreInPercentage.par,finalScoreInPercentage.birdie,finalScoreInPercentage.eagle]
        pieChartForScring.setChartForScoring(dataPoints: dataLabel, values: dataPoints as! [Double], chartView: pieChartForScring,color:UIColor.glfSeafoamBlue,isValueEnable: true)
        if(totalSum == 0){
            self.cardForScoring.isHidden = true
        }
    }
    func transferDataIntoClasses(myDataDict:NSDictionary)->[(String,Club)]{
        var clubDict = [(String,Club)]()
            if let smartCaddieDic = myDataDict.object(forKey:"smartCaddie") as? NSDictionary{
                var clubWiseArray = [Club]()
                for key in self.clubs{
                    var keysArray = smartCaddieDic.value(forKeyPath: " \(key)")
                    if (keysArray == nil){
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
                            let distance = (valueArray[j] as AnyObject).object(forKey: "distance")
                            if((distance) != nil){
                                clubData.distance = distance as! Double
                            }
                            var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                            if let strk = (valueArray[j] as AnyObject).object(forKey: strkGainedString[skrokesGainedFilter]) as? Double{
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
                            let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity")
                            if((proximity) != nil){
                                clubData.proximity = proximity as! Double
                            }
                            let holeout = (valueArray[j] as AnyObject).object(forKey: "holeout")
                            if((holeout) != nil){
                                clubData.holeout = holeout as! Double
                            }
                            
                            clubWiseArray.append(clubData)
                            clubDict.append((key,clubData))
                        }
                    }
                }
        }
        return clubDict
    }
    func setProLockedUI(targetView:UIView?, title: String) {
        
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
        targetView?.addSubview(customProModeView)
    }
    func setStrokesGainedPerClubBarChart(){
        var dataPoints = [String]()
        var dataValues = [Double]()
        for data in self.strokesGainedData{
            if(data.clubCount != 0){
                dataPoints.append(data.clubType)
                dataValues.append(data.clubStrokesGained)
            }
        }
        if !(dataPoints.isEmpty){
            self.lblStrokesGainedValue.text = "\(dataValues.reduce(0, +))"
            self.lblPremiumSGValue.text = "\(dataValues.reduce(0, +))"

            
            barChartStrokesGained.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: barChartStrokesGained, color: UIColor.glfWhite, barWidth: 0.2,valueColor: UIColor.glfWhite.withAlphaComponent(0.5))
            barChartStrokesGained.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.25)
            barChartStrokesGained.leftAxis.labelTextColor  = UIColor.glfWhite.withAlphaComponent(0.5)
            barChartStrokesGained.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
            
            barChartPremiumSG.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: barChartPremiumSG, color: UIColor.glfWhite, barWidth: 0.2,valueColor: UIColor.glfWhite.withAlphaComponent(0.5))
            barChartPremiumSG.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.25)
            barChartPremiumSG.leftAxis.labelTextColor  = UIColor.glfWhite.withAlphaComponent(0.5)
            barChartPremiumSG.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)


        }else{
            cardForStrokesGained.isHidden = true
            cardForPremiumSG.isHidden = true
        }
    }
    func proLockBtnPressed(button:UIButton) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.2)
    }
    func setSpreadOffTheTeaGraph(){
        var dataXAxis = [Double]()
        var dataYAxis = [Double]()
        var color = [UIColor]()
        for item in holesInAllRounds{
            if(item.spread <= 25  && item.spread >= -25){
                color.append(UIColor.glfWhite)
            }
            else{
                color.append(UIColor.glfRosyPink)
            }
            dataXAxis.append(item.spread)
            
            dataYAxis.append(item.distance)
        }
        if(holesInAllRounds.count != 0){
            scattredSpreadOfTheTeeChart.setScatterChart(valueX: dataXAxis, valueY: dataYAxis, chartView: scattredSpreadOfTheTeeChart, color: color)
            scattredSpreadOfTheTeeChart.leftAxis.axisLineColor = UIColor.clear
            scattredSpreadOfTheTeeChart.leftAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
            scattredSpreadOfTheTeeChart.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.5)
            scattredSpreadOfTheTeeChart.leftAxis.axisMinimum = dataYAxis.min()! - 5
            scattredSpreadOfTheTeeChart.leftAxis.labelCount = 3
            let formatter = NumberFormatter()
            formatter.positiveSuffix = " yd"
            if(distanceFilter == 1){
                formatter.positiveSuffix = " m"
            }
            scattredSpreadOfTheTeeChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
            scattredSpreadOfTheTeeChart.xAxis.enabled = false
            lblOTTRight.text = "Right Rough"
            lblOTTLeft.text = "Left Rough"
            lblOTTCenter.text = "Fairway"
        }else{
            self.cardForOTT.isHidden = true
            if let index = self.scrollArray.index(of: cardForOTT){
                self.scrollArray.remove(at:index)
            }
            self.pageControl.numberOfPages = self.scrollArray.count
        }

    }
    func setupSandAccuracyScatterChart(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        
        for data in sandArray{
            proximityXPoints.append(data.proximityX * 3)
            proximityYPoints.append(data.proximityY * 3)
            if(data.green){
                hit += 1
                color.append(UIColor.glfGreenBlue)
            }else{
                color.append(UIColor.glfRosyPink)
                if(data.proximityY >= abs(data.proximityX)){
                    long += 1
                }
                else if(data.proximityY <= -abs(data.proximityX)){
                    short += 1
                }
                else if(data.proximityX >= abs(data.proximityY)){
                    right += 1
                }
                else if(data.proximityX <= -abs(data.proximityY)){
                    left += 1
                }
            }
        }
        let sumOfLSRL = long+short+right+left+hit
        if(sumOfLSRL != 0){
            
            sandAccuracyScatterChart.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: sandAccuracyScatterChart, color: color)
            sandAccuracyScatterChart.leftAxis.enabled = false
            sandAccuracyScatterChart.xAxis.enabled = false
            sandAccuracyScatterChart.leftAxis.axisMaximum = 90
            sandAccuracyScatterChart.leftAxis.axisMinimum = -90
            sandAccuracyScatterChart.xAxis.axisMaximum = 150
            sandAccuracyScatterChart.xAxis.axisMinimum = -150
            lblLongSnd.text = "Long \(100*long/sumOfLSRL)%"
            lblShortSnd.text = "Short \(100*short/sumOfLSRL)%"
            lblRightSnd.text = "Right \(100*right/sumOfLSRL)%"
            lblLeftSnd.text = "Left \(100*left/sumOfLSRL)%"
            lblHitSnd.text = "Hit \(100*hit/sumOfLSRL)%"
        }else{
            self.cardForSandAccuracy.isHidden = true
            if let index = self.scrollArray.index(of: cardForSandAccuracy){
                self.scrollArray.remove(at:index)
            }
            self.pageControl.numberOfPages = self.scrollArray.count
        }
        
    }
    func setUpMonsterPutt(){
        var xyCoordinates = [[(x:Double,y:Double)]]()
        let y = self.card5MonsterPuttLineChart.frame.height - 50.0
        let width = self.card5MonsterPuttLineChart.frame.width
        var playersName = [String]()
        var puttsArray = [Double]()
        var imageArray = [String]()
        for i in 0..<self.completeScoreArray.count{
            let putts = self.completeScoreArray[i].putts * 3.0
            if(putts > 0){
//                print(putts)
                xyCoordinates.append(self.getYCoordinates(dist:putts*3))
                let img = (finalPlayersData[i] as AnyObject).value(forKey: "image") as! String
                imageArray.append(img)
                puttsArray.append(self.completeScoreArray[i].putts * 3)
                playersName.append(self.completeScoreArray[i].playerName)
            }
        }
        
        for i in 0..<playersName.count{
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            btn.setCircle(frame: btn.frame)
            if imageArray[i].count > 2{
                let url = URL(string:imageArray[i])
                btn.sd_setBackgroundImage(with: url, for: .normal, completed: nil)
                if url == nil{
                btn.setBackgroundImage(UIImage(named:"you"), for: .normal)
                }
            }
            else{
                let name = playersName[i]
                btn.setTitle("\(name.first ?? " ")", for: .normal)
                btn.backgroundColor = playersColor[i]
            }
            btn.frame.origin = CGPoint(x:(self.completeScoreArray[i].putts * 3 / (puttsArray.max()! * 1.5))*Double(width),y:Double(y))
            self.card5MonsterPuttLineChart.addSubview(btn)
        }
        if(xyCoordinates.count != 0){
        
            self.card5MonsterPuttLineChart.setCurveWithColor(dataPoints: xyCoordinates.count, values: xyCoordinates, chartView: self.card5MonsterPuttLineChart, color: [UIColor.clear,UIColor.clear,UIColor.clear,UIColor.clear,UIColor.clear],playersName:playersName,maxRange:Int(puttsArray.max()! * 1.3))
            self.card5MonsterPuttLineChart.legend.enabled = false
            let formatter = NumberFormatter()
            formatter.positiveSuffix = " ft"
            self.card5MonsterPuttLineChart.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
            let imgView = UIImageView(image:#imageLiteral(resourceName: "holeflag"))
            let frame  = CGRect(x: 0.0, y: self.card5MonsterPuttLineChart.frame.height*0.25, width: self.card5MonsterPuttLineChart.frame.width*0.15, height: self.card5MonsterPuttLineChart.frame.height*0.7)
            imgView.frame = frame
            self.card5MonsterPuttLineChart.addSubview(imgView)
        }else{
            self.card5.isHidden = true
        }

    }
    func setUpinitialUI(){
        self.card2ScoreDistribution.text = "Score Trends"
        self.card2Avg.isHidden = true
        self.card2AvgValue.isHidden = true
        self.card3Avg.isHidden = true
        self.card3Title.text = "Longest Drive"
        self.card3AvgValue.isHidden = true
        self.card4Title.text = "Closest to the hole"
        self.card4Avg.isHidden = true
        self.card4AvgValue.isHidden = true
        self.card5Title.text = "Monster Putt"
        self.card5Avg.isHidden = true
        self.card5AvgValue.isHidden = true
        if(finalPlayersData.count == 1){
            self.card2.isHidden = true
            self.card3.isHidden = true
            self.card4.isHidden = true
            self.card5.isHidden = true
        }
        
        let vi0 = UIView()
        vi0.frame.origin = .zero
        vi0.frame.size = CGSize(width:self.view.frame.width * 0.25,height:cardForOTT.frame.height)
        vi0.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        
        let vi1 = UIView()
        vi1.frame.origin = CGPoint(x:self.view.frame.width*0.75-20 ,y:0)
        vi1.frame.size = vi0.frame.size
        vi1.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        cardForOTT.addSubview(vi0)
        cardForOTT.addSubview(vi1)
        
        cardForOTT.backgroundColor = UIColor.glfBluegreen
        
        
        
        
        let originalImage1 = #imageLiteral(resourceName: "share")
        let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        var viewTag = 0
        for v in self.finalScoringStackView.subviews{
            if v.isKind(of: CardView.self){
                self.cardViewMArray.add(v)
                let shareStatsButton = ShareStatsButton()
                shareStatsButton.frame = CGRect(x: self.view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                shareStatsButton.tintColor = UIColor.glfFlatBlue
                shareStatsButton.tag = viewTag
                shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                if (v == self.cardForStrokesGained) || (v == self.cardForChippingAccuracy1) || (v == self.cardForSandAccuracy) || (v == self.cardForOTT) || (v == self.cardForApproachAccuracy2){
                    shareStatsButton.tintColor = UIColor.white
                }
                viewTag = viewTag+1
                if(v != self.card1TableView){
                    v.addSubview(shareStatsButton)
                }
                if !isProMode {
                    
//                    self.cardForChippingAccuracy1.makeBlurView(targetView: cardForChippingAccuracy1)
                    self.setProLockedUI(targetView: cardForChippingAccuracy1, title: "Chipping Accuracy")
                    
//                    self.cardForApproachAccuracy2.makeBlurView(targetView: cardForApproachAccuracy2)
                    self.setProLockedUI(targetView: cardForApproachAccuracy2, title: "Approach Accuracy")
                    
//                    self.cardForOTT.makeBlurView(targetView: cardForOTT)
                    self.setProLockedUI(targetView: cardForOTT, title: "Spread Off The Tee")
                    
//                    self.cardForSandAccuracy.makeBlurView(targetView: cardForSandAccuracy)
                    self.setProLockedUI(targetView: cardForSandAccuracy, title: "Sand Accuracy")
                    
//                    self.cardForStrokesGained.makeBlurView(targetView: cardForStrokesGained)
                    self.setProLockedUI(targetView: cardForStrokesGained, title: "Strokes Gained Per Club")
                    
                    lblApproachPro.isHidden = true
                    lblSandPro.isHidden = true
                    lblOttPro.isHidden = true
                    lblChippingPro.isHidden = true
                    lblSGPro.isHidden = true
                }
            }
        }
        lblApproachPro.layer.cornerRadius = 3.0
        lblApproachPro.layer.masksToBounds = true
        lblChippingPro.layer.cornerRadius = 3.0
        lblChippingPro.layer.masksToBounds = true
        lblSGPro.layer.cornerRadius = 3.0
        lblSGPro.layer.masksToBounds = true
        lblOttPro.layer.cornerRadius = 3.0
        lblOttPro.layer.masksToBounds = true
        lblSandPro.layer.cornerRadius = 3.0
        lblSandPro.layer.masksToBounds = true
        
        let combinedView = UIView()
        combinedView.frame = CGRect(x: 0, y:0, width: self.view.frame.size.width-40, height: viewForDrivingAccuracy.frame.size.height)
        view1.frame = CGRect(x: 8, y: 30, width: combinedView.frame.width/2.5, height: viewForDrivingAccuracy.frame.height*0.6)
        view1.center.y = combinedView.bounds.midY
        leftImg.frame.origin = CGPoint(x: #imageLiteral(resourceName: "left").size.width + view1.frame.size.height*0.20, y: view1.frame.height*0.56)
        lblFairwayLeft.frame = CGRect(origin: CGPoint(x: leftImg.frame.origin.x - 30, y: leftImg.frame.origin.y - 20), size: CGSize(width:30,height:20))
        view1.addSubview(leftImg)
        view1.addSubview(lblFairwayLeft)
        
        view2.frame.size.width = view1.frame.width
        view2.frame.size.height = view1.frame.height+10
        view2.center.x = combinedView.bounds.midX
        view2.frame.origin.y = view1.frame.origin.y-20

        hitImg.frame.origin = CGPoint(x: view2.frame.width/2 - #imageLiteral(resourceName: "path15").size.width/2, y:#imageLiteral(resourceName: "path15").size.height + view2.frame.size.height*0.1)
        lblFairwayHit.frame = CGRect(origin: CGPoint(x: hitImg.frame.origin.x, y:hitImg.frame.origin.y - 30), size: CGSize(width:30,height:20))
        view2.addSubview(lblFairwayHit)
        view2.addSubview(hitImg)
        
        view3.frame = CGRect(x: combinedView.frame.size.width-view2.frame.width-8, y: view1.frame.origin.y, width: view2.frame.width, height:view1.frame.height)

        rightImg.frame.origin = CGPoint(x: view3.frame.width - #imageLiteral(resourceName: "right").size.width - view3.frame.size.height*0.15, y:view3.frame.height*0.60)
        lblFairwayRight.frame = CGRect(origin: CGPoint(x: rightImg.frame.origin.x + 15, y:rightImg.frame.origin.y - 10), size: CGSize(width:30,height:20))
        view3.addSubview(lblFairwayRight)
        view3.addSubview(rightImg)
        
        combinedView.addSubview(view1)
        combinedView.addSubview(view3)
        combinedView.addSubview(view2)
        viewForDrivingAccuracy.addSubview(combinedView)
        
        // swipe gesture for chipping card view
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector((handleSwipes)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        scrollableStackView.addGestureRecognizer(leftSwipe)
        scrollableStackView.addGestureRecognizer(rightSwipe)

    }
    
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .right) {
            let prevPG = pageControl.currentPage - 1
            pageControl.currentPage = pageControl.currentPage - 1
            if(pageControl.currentPage == -1){
                pageControl.currentPage = 0
            }
            if(prevPG != -1){
                debugPrint(pageControl.currentPage)
                for i in 0..<scrollArray.count{
                    if (i == pageControl.currentPage){
                        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                            self.scrollArray[i].frame = self.scrollArray[i].frame.offsetBy(dx: self.view.frame.width, dy: 0)
                        }
                        animator.startAnimation()
                        self.scrollArray[i].isHidden = false
                    }else{
                        self.scrollArray[i].isHidden = true
                    }
                }
            }
        }
        if (sender.direction == .left) {
            let nextPG = pageControl.currentPage + 1
            pageControl.currentPage = pageControl.currentPage + 1
            if(pageControl.currentPage == scrollArray.count){
                pageControl.currentPage = scrollArray.count-1
            }
            if(nextPG != scrollArray.count){
                debugPrint(pageControl.currentPage)
                for i in 0..<scrollArray.count{
                    if (i == pageControl.currentPage){
                        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                            self.scrollArray[i].frame = self.scrollArray[i].frame.offsetBy(dx: -self.view.frame.width, dy: 0)
                        }
                        animator.startAnimation()
                        self.scrollArray[i].isHidden = false
                    }else{
                        self.scrollArray[i].isHidden = true
                    }
                }
            }
        }
    }
    func getData()  {
        
        var maxDist = Double()
        var maxDistArray = [Double]()
        for j in  0..<self.playerArray.count{
            var distArray = [Double]()
            let shotArray = NSMutableArray()
            var userID : String!
            var count = 0
            var putts = [Double]()
            var distanceToHole = [Double]()
            for i in 0..<finalScoreData.count{
                let userDataDic = finalScoreData[i].players
                for data in userDataDic{
                    for (key,value) in data{
                        userID = key as! String
                        let userDataDic = value as! NSDictionary
//                        print("userID == ", userID)
//                        print("userData == ", userDataDic)
                        if userID == self.playerArray[j].id {
                            let holeOut = userDataDic.value(forKey: "holeOut") as! Bool
                            if (holeOut){
                                if let drivingDistance = (userDataDic.value(forKey: "drivingDistance") as? Double){
                                    distArray.append(drivingDistance)
                                }
                                else{
                                    distArray.append(0.0)
                                }
                                if let shots = (userDataDic.value(forKey: "shots") as? NSArray){
                                    let shot = shots[0] as! NSMutableDictionary
                                    if(finalScoreData[i].par == 3){
                                        if (shot.value(forKey: "distanceToHole1") as! Double) < 40.0{
                                                distanceToHole.append(shot.value(forKey: "distanceToHole1") as! Double * 3.0)
                                        }

                                    }
                                    let lastShot = shots.lastObject as! NSMutableDictionary
                                    if(lastShot.value(forKey: "club") as! String == "Pu"){
                                        putts.append(lastShot.value(forKey: "distance") as! Double)
                                    }
                                    else{
                                        putts.append(0.0)
                                    }
                                    count += shots.count
                                    shotArray.add(count)
                                }
                                else if let shots = (userDataDic.value(forKey: "strokes") as? Int){
                                    count += shots
                                    shotArray.add(count)
                                }
                                else{
                                    count += 0
                                    shotArray.add(count)
                                }
                            }
                            else{
                                count += 0
                                shotArray.add(count)
                                putts.append(0.0)
                            }
                        }
                    }
                }
            }
            maxDist = ((distArray.max() != nil) ? distArray.max()! : 0.0)
            maxDistArray.append(maxDist)
            self.completeScoreArray.append((playerName: self.playerArray[j].name, playerImg: self.playerArray[j].image, longestDrive: maxDist, shotsArray: shotArray as! [Double], putts: ((putts.max() != nil) ? putts.max()! : 0.0), distToHol: distanceToHole))
        }
        tblContainerHConstraint.constant = CGFloat((finalPlayersData.count * 50) + 100)
        
        self.tableView.reloadData()
        self.setUpMonsterPutt()
        if(isManualScoring){
            self.updateViewsIfManualScoring()
        }
        self.setUpScoreTrends()
        self.setUpLongestDrive()
        self.setUpDistanceToHole()
    }
    func updateViewsIfManualScoring(){
        self.card5.isHidden = true
        self.card4.isHidden = true
        self.card3.isHidden = true
    }
    func getYCoordinates(dist:Double)->[(x:Double,y:Double)]{
        var xCo = 0.0
        var yCo = 0.0
        var yCoordinates = [Double]()
        var xyCoordinates = [(x:Double,y:Double)]()
        while(xCo <= dist){
            if(xCo == 0.0){
                yCo = 0.0
            }
            else{
                yCo = (dist / 4) - (((xCo - (dist / 2)) * (xCo - (dist / 2))) / dist)
            }
            xyCoordinates.append((x:xCo,y:yCo))
            yCoordinates.append(yCo)
            xCo += dist/25
        }
        return xyCoordinates
    }

    
//}
//extension FinalScoreBoardViewCtrl, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return self.finalPlayersData.count
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
            let  cell = tableView.dequeueReusableCell(withIdentifier: "FinalScoreBoardTopCell") as! FinalScoreBoardTopCell
            var height = CGFloat()
            if indexPath.row == 0{
                height = ((cell.topHdrView.frame.size.height)+33)
            }
            else{
                height =  (cell.bgView.frame.size.height)
            }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinalScoreBoardTopCell") as! FinalScoreBoardTopCell
        cell.btnViewScore.layer.cornerRadius = 3.0
        cell.btnHoleByHole.layer.cornerRadius = 3.0
        cell.btnHoleByHole.isHidden = false
        if let mode = matchDataDic.value(forKey: "scoringMode") as? String{
            if(mode == "classic") || (mode == "rangefinder"){
                cell.btnHoleByHole.isHidden = true
            }
        }
        cell.btnHoleByHole.isHidden = isManualScoring
        if(superClassName == "RFMapVC") || (superClassName == "BasicScoringVC"){
                cell.btnHoleByHole.isHidden = true
            }
        
        cell.btnViewScore.clipsToBounds = false
            if indexPath.row == 0{
                cell.bgView.isHidden = true
                cell.topHdrView.isHidden = false
                cell.btnViewScore.addTarget(self, action: #selector(FinalScoreBoardViewCtrl.viewScoreAction(_:)), for: .touchUpInside)
                cell.btnHoleByHole.addTarget(self, action: #selector(FinalScoreBoardViewCtrl.viewHoleByHoleAction(_:)), for: .touchUpInside)
                cell.contentView.addSubview((cell.topHdrView))
            }
            else{
                cell.bgView.isHidden = false
                cell.topHdrView.isHidden = true
                cell.contentView.addSubview((cell.bgView))
                
                cell.lblPlayerName.text = (self.finalPlayersData[indexPath.row] as AnyObject).value(forKey: "name") as? String
                let url = URL(string:(self.finalPlayersData[indexPath.row] as AnyObject).value(forKey: "image") as? String ?? "")
                cell.userImageView.sd_setImage(with: url, completed: nil)
                if url == nil{
                    cell.userImageView.image = UIImage(named:"you")
                }
                let playerId = (self.finalPlayersData[indexPath.row] as AnyObject).value(forKey: "id") as? String
                
                var finalPar: Int = 0
                self.myVal = 0
                var finalStroke: Int = 0
                
                for i in 0..<self.finalScoreData.count{
                    for dataDict in finalScoreData[i].players{
                        for (key,value) in dataDict{
                            let dic = value as! NSDictionary
                            if dic.value(forKey: "holeOut") as! Bool == true{
                                if(key as? String == playerId){
                                    for (key,value) in value as! NSMutableDictionary
                                    {
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            let allScore  = shotsArray.count - (finalScoreData[i].par)
                                            finalPar = finalPar + allScore
                                        }
                                        if (key as! String == "holeOut" && value as! Bool){
                                            self.myVal = self.myVal + (value as! Int)
                                        }
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            let allScore  = shotsArray.count
                                            finalStroke = finalStroke + allScore
                                        }else if (key as! String == "strokes"){
                                            var allScore  = value as! Int
                                            finalStroke = finalStroke + allScore
                                            allScore  = allScore - (finalScoreData[i].par)
                                            finalPar = finalPar + allScore
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                cell.lblPar.text = "\(finalPar)"
                if finalPar>0{
                    cell.lblPar.text = "+\(finalPar)"
                }

                cell.lblThru.text = "\(self.myVal)"
                if let status = (self.finalPlayersData[indexPath.row] as AnyObject).value(forKey: "status") as? Int{
                    if status == 3 || status == 4{
                        if finalScoreData.count == 18{
                            if self.myVal == 18{
                                cell.lblThru.text = "F"
                            }
                        }
                        else{
                            if self.myVal == 9{
                                cell.lblThru.text = "F"
                            }
                        }
                    }
                }
                cell.lblStrokes.text = "\(finalStroke)"
                
                if(self.myVal < 8){
                    for view in finalScoringStackView.arrangedSubviews{
                        if(view.tag != 1){
                            view.isHidden = true
                        }
                    }
//                    label.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
//                    label.center = self.view.center
//                    label.numberOfLines = 2
//                    label.text = "Please play 9 holes to see stats."
//                    self.view.addSubview(label)
                }
            }
            return cell
    }
    @objc func viewScoreAction(_ sender: UIButton!) {
        let viewCtrl = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
        viewCtrl.scoreData = finalScoreData
        viewCtrl.playerData = finalPlayerMArray
        viewCtrl.matchDataDict = self.matchDataDict
        viewCtrl.isFinalSummary = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    @objc func afterResponseEditRound(_ notification:NSNotification){
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "editRound"))
    }
    
    @objc func viewHoleByHoleAction(_ sender: UIButton!) {
        if(superClassName! == "NewGameVC") || superClassName! == "MapViewController" || superClassName! == "RFMapVC" || (superClassName! == "NewMapVC"){
            self.matchDataDict = matchDataDic
        }
        let playerDict = NSMutableDictionary()
        for data in self.finalPlayerMArray{
            if let player = data as? NSMutableDictionary{
                let id = player.value(forKey: "id")
                playerDict.setObject(player, forKey: id as! NSCopying)
            }
        }
        if(playerDict.count > 0){
            sender.isUserInteractionEnabled = false
            let viewCtrl = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "NewMapVC") as! NewMapVC
            self.matchDataDict.setObject(playerDict, forKey: "player" as NSCopying)
            viewCtrl.matchDataDict = self.matchDataDict
            viewCtrl.isContinue = false
            viewCtrl.isHoleByHole = true
            viewCtrl.currentMatchId = self.currentMatchId
            viewCtrl.scoring = self.finalScoreData
            viewCtrl.courseId = "course_\(self.matchDataDict["courseId"]!)"
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
        sender.isUserInteractionEnabled = true
    }
    
    var gameImprovementPopup: UIView!
    var joinBtn: UIButton!
    
    var fromGameImprovement = Bool()
    
    @objc func closeGameImprovement(_ sender: UIButton!) {
        self.gameImprovementPopup.removeFromSuperview()
    }
    
    @objc func joinGameImprovementAction(_ sender: UIButton!) {
        self.gameImprovementPopup.removeFromSuperview()
        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["fbPopupCount" :3] as [AnyHashable:Any])
        sleep(2)
        UIApplication.tryURL(urls: [
            "fb://group?id=1927412700888670",
            "http://www.facebook.com/groups/1927412700888670" // Website if app fails
            ])
    }
    
    private func redirectToJoinFBGameImprovement() {
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "fbPopupCount") { (snapshot) in
            if(snapshot.value != nil){
                let count = snapshot.value as! Int
                
                if count < 3{
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["fbPopupCount" :count+1] as [AnyHashable:Any])
                    
                    self.gameImprovementPopup = Bundle.main.loadNibNamed("GameImprovementPopup", owner: self, options: nil)![0] as? UIView
                    self.gameImprovementPopup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    
                    self.joinBtn = (self.gameImprovementPopup.viewWithTag(111) as! UIButton)
                    self.joinBtn.layer.cornerRadius = 3.0
                    self.joinBtn.addTarget(self, action: #selector(self.joinGameImprovementAction(_:)), for: .touchUpInside)
                    
                    let closeBtn = self.gameImprovementPopup.viewWithTag(222) as! UIButton
                    closeBtn.addTarget(self, action: #selector(self.closeGameImprovement(_:)), for: .touchUpInside)
                    
                    self.view.addSubview(self.gameImprovementPopup)
                }
            }
            else{
                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["fbPopupCount" :1] as [AnyHashable:Any])
                
                self.gameImprovementPopup = Bundle.main.loadNibNamed("GameImprovementPopup", owner: self, options: nil)![0] as? UIView
                self.gameImprovementPopup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
                self.joinBtn = (self.gameImprovementPopup.viewWithTag(111) as! UIButton)
                self.joinBtn.layer.cornerRadius = 3.0
                self.joinBtn.addTarget(self, action: #selector(self.joinGameImprovementAction(_:)), for: .touchUpInside)
                
                let closeBtn = self.gameImprovementPopup.viewWithTag(222) as! UIButton
                closeBtn.addTarget(self, action: #selector(self.closeGameImprovement(_:)), for: .touchUpInside)
                
                self.view.addSubview(self.gameImprovementPopup)
            }
        }
    }

}
extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}
