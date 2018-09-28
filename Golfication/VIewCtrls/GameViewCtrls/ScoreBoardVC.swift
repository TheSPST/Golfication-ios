//
//  ScoreBoardVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import ActionSheetPicker_3_0

class BottomViewInScore:UIView{
    let btn = UIButton()
    init(){
        super.init(frame: .zero)
        btn.backgroundColor = UIColor.glfBluegreen
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(UIColor.glfWhite, for: .normal)
//        btn.layer.cornerRadius = 15
        backgroundColor = UIColor.glfBlack75
        
        addSubview(btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class CellButton : UIButton{
    var userData:String?
    override init(frame: CGRect) {
        self.userData = ""
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        self.userData = ""
        super.init(coder: aDecoder)
    }
}
class ScoreBoardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var fairwayHitStackView: UIStackView!
    @IBOutlet weak var girStackView: UIStackView!
    @IBOutlet weak var puttsStackView: UIStackView!
    @IBOutlet weak var chipShotStackView: UIStackView!
    @IBOutlet weak var greenSideSandShotStackView: UIStackView!
    @IBOutlet weak var penalitiesStackView: UIStackView!
    @IBOutlet weak var scoringView: UIView!
    
    @IBOutlet weak var scorePopView: UIView!
    @IBOutlet weak var btnDetailScoring: UIButton!
    @IBOutlet weak var btnExpendScore: UIButton!
    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnShotRanking: UIButton!
    
    @IBOutlet weak var scoreSV: UIStackView!
    @IBOutlet weak var detailScoreSV: UIStackView!
    @IBOutlet weak var scoreSecondSV: UIStackView!
    
    @IBOutlet weak var stackViewStrokes1: UIStackView!
    @IBOutlet weak var stackViewStrokes2: UIStackView!
    @IBOutlet weak var stackViewStrokes3: UIStackView!
    @IBOutlet weak var stackViewStrokes4: UIStackView!
    
    @IBOutlet weak var lblPlayerNameDSV: UILabel!
    @IBOutlet weak var lblPlayerNameSSV: UILabel!
    
    @IBOutlet weak var lblHolePar: UILabel!
    
    @IBOutlet weak var stablefordView: UIView!
    @IBOutlet weak var imgViewRefreshScore: UIImageView!
    @IBOutlet weak var btnStableScore: UIButton!
    @IBOutlet weak var lblStableScore: UILabel!
    @IBOutlet weak var imgViewInfo: UIImageView!
    
    var progressView = SDLoader()
    @IBOutlet weak var btnMenu: UIBarButtonItem!

    var buttonsArrayForStrokes = [UIButton]()
    var buttonsArrayForFairwayHit = [UIButton]()
    var buttonsArrayForGIR = [UIButton]()
    var buttonsArrayForPutts = [UIButton]()
    var buttonsArrayForChipShot = [UIButton]()
    var buttonsArrayForSandSide = [UIButton]()
    var buttonsArrayForPenalty = [UIButton]()
    var holeWiseShots = NSMutableDictionary()
    var classicScoring = classicMode()
    var playerId : String!
    var index = 0
    var isAcceptInvite = false
    @IBOutlet weak var scoringSuperView: UIView!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    var isAccept = false
    var matchDataDict = NSMutableDictionary()
    var isContinue = false
    var holeOutforAppsFlyer = Int()
    var teeTypeArr = [(tee:String,handicap:Double)]()
    // ----------------------------- Old Outlet & Variables ----------------------------------------
    var playerData = NSMutableArray()
    let bView = BottomViewInScore()
    var scrollView: UIScrollView!
    var tblView: UITableView!
    var superView : Bool!
    let kHeaderSectionTag: Int = 6900
    
    var menueTableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    
    var plyerViseScore = [[(gir:Bool,fairwayHit:String)]]()
    var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    
    let padding: CGFloat = 10.0
    let width: CGFloat = 50.0
    func scrollViewDidScroll(_ scrollView1: UIScrollView)
    {
        //http://jayeshkawli.ghost.io/manually-scrolling-uiscrollview-ios-swift/
        //https://stackoverflow.com/questions/6949142/iphone-how-to-scroll-two-uitableviews-symmetrically
        if (!(scrollView1.contentOffset.x>0 || scrollView1.contentOffset.x<0)) && scrollView1 == self.menueTableView {
           tblView.isScrollEnabled = true

           self.scrollView = (scrollView1 == self.menueTableView) ? self.tblView : scrollView1
           self.scrollView.setContentOffset(scrollView1.contentOffset, animated: false)
        }
        else
        {
            tblView.isScrollEnabled = false
        }
    }

    @IBAction func backBtnAction(_ sender: Any) {
        //        for controller in self.navigationController!.viewControllers as Array {
        //            if controller.isKind(of: NewGameVC.self) {
        //                _ =  self.navigationController!.popToViewController(controller, animated: !self.isAcceptInvite)
        //                break
        //            }
        //        }
        self.navigationController?.pop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateView"), object: nil)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").removeAllObservers()
    }
    
    @IBAction func refreshStableFordAction(_ sender: UIButton) {
        if self.teeTypeArr.isEmpty{
            self.ifnoStableFord()
        }else{
            if self.btnStableScore.currentTitle!.contains("Stable"){
                self.btnStableScore.setTitle("Net Score", for: .normal)
                self.lblStableScore.text = "\(classicScoring.netScore!)"
            }else if self.btnStableScore.currentTitle!.contains("Net"){
                self.btnStableScore.setTitle("Gross Score", for: .normal)
                self.lblStableScore.text = "\(classicScoring.strokesCount!)"
            }else{
                self.btnStableScore.setTitle("Stableford Score", for: .normal)
                self.lblStableScore.text = "\(classicScoring.stableFordScore!)"
            }
        }
    }
    func statusStableFord(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.stablefordView.isHidden = self.chkStableford
            })
        }
    }
    var chkStableford = false
    func ifnoStableFord(){
        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "stablefordCourse") { (snapshot) in
            var dataDic = [String:Int]()
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? [String : Int])!
            }
            if !dataDic.isEmpty{
                for (key, _) in dataDic{
                    if key == selectedGolfID{
                        self.chkStableford = true
                        break
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                if !self.chkStableford{
                    let viewCtrl = RequestSFPopup(nibName:"RequestSFPopup", bundle:nil)
                    viewCtrl.modalPresentationStyle = .overCurrentContext
                    self.present(viewCtrl, animated: true, completion: nil)
                }else{
                    
                }
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        statusStableFord()
    }

    @objc func hideStableFord(_ notification:NSNotification){
        let alertVC = UIAlertController(title: "Thank you for your time!", message: "Stableford scoring for your course should be available in the next 48 hours!", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        self.chkStableford = true
        self.stablefordView.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideStableFord"), object: nil)
    }
    @objc func btnContinueAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "continueAction"), object: nil)
    }
    
    @IBAction func detailScoreAction(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.scorePopView.isHidden = false
        }
        else{
            sender.tag = 0
            self.scorePopView.isHidden = true
        }
        self.view.layoutIfNeeded()
        
    }
    func checkHoleOutZero(playerId:String) -> Int{
        // --------------------------- Check If User has not played game at all ------------------------
        var myVal: Int = 0
        for i in 0..<self.scoreData.count{
            for dataDict in self.scoreData[i].players{
                for (key,value) in dataDict{
                    if let dic = value as? NSDictionary{
                        if dic.value(forKey: "holeOut") as! Bool == true{
                            if(key as? String == playerId){
                                for (key,value) in value as! NSMutableDictionary
                                {
                                    if (key as! String == "holeOut" && value as! Bool){
                                        let countDic = NSMutableDictionary()
                                        countDic.setObject(i, forKey: "HoleIndex" as NSCopying)
                                        countDic.setObject(dic.count, forKey: "DetailCount" as NSCopying)
                                        myVal = myVal + (value as! Int)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return myVal
    }
    @IBAction func btnMenuAction(_ sender: Any) {
        self.holeOutforAppsFlyer = self.checkHoleOutZero(playerId: Auth.auth().currentUser!.uid)
        ActionSheetStringPicker.show(withTitle: "Menu", rows: ["Finish Round","Restart Round","End Round"], initialSelection: 0, doneBlock: { (picker, value, index) in
            if value != 1{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: NewGameVC.self) {
                        _ =  self.navigationController!.popToViewController(controller, animated: !self.isAcceptInvite)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EndRound"), object: nil)
                        })
                        break
                    }
                }
            }else{
                let emptyAlert = UIAlertController(title: "Restart Round", message: "You Played \(self.holeOutforAppsFlyer)/\(self.scoreData.count) Holes. Are you sure you want to Restart the Round ?", preferredStyle: UIAlertControllerStyle.alert)
                emptyAlert.addAction(UIAlertAction(title: "Restart Round", style: .default, handler: { (action: UIAlertAction!) in
                    self.progressView.show(atView: self.view, navItem: self.navigationItem)
                    self.resetScoreNodeForMe()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.getScoreFromMatchDataFirebase()
                        self.progressView.hide(navItem: self.navigationItem)
                        self.holeOutforAppsFlyer = 0
                    })
                }))
                emptyAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(emptyAlert, animated: true, completion: nil)
                
            }
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    func getScoreFromMatchDataFirebase(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchId)/") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.scoreData.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                matchDataDic = matchDict as! NSMutableDictionary
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,_) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                        }
                    }
                    if (keyData == "scoring"){
                        scoreArray = (value as! NSArray)
                    }
                }
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = value as! Int
                        }else{
                            let dict = NSMutableDictionary()
                            dict.setObject(value, forKey: key as! String as NSCopying)
                            playersArray.append(dict)
                        }
                    }
                    self.scoreData.append((hole: i, par:par,players:playersArray))
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.progressView.hide(navItem: self.navigationItem)
                self.tblView.reloadData()
            })
        }
    }
    func resetScoreNodeForMe(){
        for i in 0..<self.scoreData.count{
            let player = NSMutableDictionary()
            for j in 0..<self.scoreData[i].players.count{
                let id = (self.scoreData[i].players[j]).allKeys[0] as! String
                if(id == Auth.auth().currentUser?.uid){
                    let playerData = ["holeOut":false]
                    player.setObject(playerData, forKey: id as NSCopying)
                    ref.child("matchData/\(matchId)/scoring/\(i)/").updateChildValues(player as! [AnyHashable : Any])
                    self.scoreData[i].players[j].addEntries(from: playerData)
                }
            }
        }
    }
    
    @IBAction func btnActionScore(_ sender: UIButton) {
        if let str = holeWiseShots.value(forKey: "strokes") as? Int{
            self.detailScoreSV.isHidden = true
            if (str > self.scoreData[self.index].par+2){
                self.scoreSV.isHidden = false
                self.scoreSecondSV.isHidden = false
                self.btnExpendScore.isHidden = true
                for btn in buttonsArrayForStrokes{
                    btn.setTitleColor(UIColor.glfWhite, for: .normal)
                }
                buttonsArrayForStrokes[str-1].setTitleColor(UIColor.glfBluegreen, for: .normal)
            }else{
                self.scoreSV.isHidden = false
                self.stackViewStrokes1.isHidden = false
                self.scoreSecondSV.isHidden = true
                self.btnExpendScore.isHidden = false
                var newI = self.scoreData[self.index].par - 2
                for btn in self.stackViewStrokes1.arrangedSubviews{
                    (btn as! UIButton).setTitleColor(UIColor.glfWhite, for: .normal)
                    updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[self.index].par), btn: btn as! UIButton,color:UIColor.white)
                    newI += 1
                }
                if let btn = self.stackViewStrokes1.arrangedSubviews[str-self.scoreData[self.index].par+2] as? UIButton{
                    updateStrokesButtonWithoutStrokes(strokes: (str-self.scoreData[self.index].par), btn: btn,color:UIColor.glfBluegreen)
                    btn.setTitleColor(UIColor.glfBluegreen, for: .normal)
                }
            }
        }
    }
    func updateStrokesButtonWithoutStrokes(strokes:Int,btn:UIButton,color:UIColor){
        if strokes <= -2 || strokes <= -3{
            //double circle
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
            layer.cornerRadius = layer.frame.height/2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = btn.frame.height/2
            btn.layer.borderColor = color.cgColor
            
        }
            
        else if strokes == -1{
            //single circle
            if let layers = btn.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            btn.titleLabel?.layer.borderWidth = 0
            btn.layer.borderWidth = 1
            btn.layer.borderColor = color.cgColor
            btn.layer.cornerRadius = btn.frame.size.height/2
        }
            
        else if strokes == 1{
            //single square
            btn.layer.borderWidth = 1
            btn.layer.borderColor = color.cgColor
        }
            
        else if strokes >= 2 || strokes >= 3{
            //double square
            let layer = CALayer()
            layer.frame = CGRect(x: 3, y:  3, width: btn.frame.width - 6, height: btn.frame.height - 6)
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
            layer.cornerRadius = 2
            btn.layer.addSublayer(layer)
            
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 2
            btn.layer.borderColor = color.cgColor
        }
    }
    
    @IBAction func expendScoreAction(_ sender: Any) {
        scoreSecondSV.isHidden = false
        btnExpendScore.isHidden = true
        for btn in buttonsArrayForStrokes{
            btn.setTitle("\(btn.tag)", for: .normal)
            btn.layer.borderWidth = 0
            for lay in btn.layer.sublayers!{
                lay.borderWidth = 0
            }
        }
    }
    private func getHCPValue(playerID:String,holeNo:Int)->Int{
        var index = 0
        var hcp = 0
        for playersdata in self.playerData{
            if ((playersdata as! NSMutableDictionary).value(forKey: "id") as! String) == playerID{
                break
            }
            index += 1
        }
        for tee in holeHcpWithTee{
            if tee.hole == holeNo+1{
                for data in tee.teeBox{
                    if (data.value(forKey: "teeType") as! String) == (self.teeTypeArr[index].tee).lowercased(){
                        hcp = data.value(forKey:"hcp") as? Int ?? 0
                        break
                    }
                }
                break
            }
        }
        return hcp
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        // Do any additional setup after loading the view.
        bView.frame = CGRect(x: 0, y: self.view.frame.height-40, width: self.view.frame.width, height: 40)
        bView.btn.frame = CGRect(x: 0, y: 0, width: bView.frame.size.width, height: bView.frame.size.height)
        bView.btn.addTarget(self, action: #selector(btnContinueAction), for: .touchUpInside)
        self.stablefordView.setCornerView(color: UIColor.glfWhite.cgColor)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideStableFord(_:)), name: NSNotification.Name(rawValue: "hideStableFord"),object: nil)
        
//        bView.isHidden = true
        self.navigationItem.rightBarButtonItem?.isEnabled = isContinue
        bView.isHidden = !isContinue
        for data in playerData{
            if let player = data as? NSMutableDictionary{
                var teeOfP = String()
                if let tee = player.value(forKeyPath: "tee") as? String{
                    teeOfP = tee
                }
                var handicapOfP = Double()
                if let hcp = player.value(forKeyPath: "handicap") as? String{
                    handicapOfP = Double(hcp)!
                }
                if(teeOfP != ""){
                    self.teeTypeArr.append((tee: teeOfP, handicap: handicapOfP))
                }
            }
        }
        if !teeTypeArr.isEmpty{
            self.loadStableFordData()
        }else{
            
        }
        let bottomLbl = UILabel()
        bottomLbl.frame = CGRect(x: 50, y: self.view.frame.height-40-(30+5), width: self.view.frame.width-100, height: 30)
        bottomLbl.numberOfLines = 2
        bottomLbl.textAlignment = .center
        bottomLbl.textColor = UIColor.darkGray
        bottomLbl.font = UIFont(name: "SFProDisplay-Regular", size: 11.0)
        bottomLbl.text = "Enable stableford scores by sending us a photo of the club score card"
        bottomLbl.backgroundColor = UIColor.clear
        
        self.title = "Your Scorecard"
        self.view.backgroundColor = UIColor(rgb: 0xF8F8F7)
//        self.navigationController?.navigationBar.backItem?.title = ""
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.setInitialUI()
        self.scoringView.layer.cornerRadius = 5

        let holeDic = NSMutableDictionary()
        holeDic.setObject(scoreData.count, forKey: "Hole" as NSCopying)
        sectionNames.insert(holeDic, at: 0)

        let tempDic = NSMutableDictionary()
        tempDic.setObject("parId", forKey: "id" as NSCopying)
        tempDic.setObject("Par", forKey: "name" as NSCopying)
        sectionNames.insert(tempDic, at: 1)
        
        for i in 0..<playerData.count{
            
            sectionNames.insert(playerData[i], at: i+2)
        }
        debugPrint("sectionNames== ",sectionNames.count)

        //debugPrint("mode== ",mode) // mode 3 = classic, mode 1 = Advance, mode 3 = Rf
        if !teeTypeArr.isEmpty{
            sectionItems = [[],["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"]]
            if mode == 1{
                sectionItems = [[],["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty","HCP", "Stableford", "Net Score"]]
            }
        }
        else{
            sectionItems = [[],["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                            ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
            if mode == 1{
                sectionItems = [[],["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                                ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
            }
            
        }

        menueTableView =  UITableView(frame: CGRect(x: 0, y: 64, width: 180, height: self.view.frame.size.height-(64+75+5)), style: .plain)
        menueTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenueCell")
        menueTableView.dataSource = self
        menueTableView.delegate = self
        menueTableView.tag = 0
        menueTableView.backgroundColor = UIColor.clear
//        menueTableView.separatorStyle = .none
        menueTableView.separatorColor = UIColor(rgb: 0xF0F0EE)
        menueTableView.showsVerticalScrollIndicator = false
        self.menueTableView!.tableFooterView = UIView()
        view.addSubview(menueTableView)
        
        scrollView =  UIScrollView(frame: CGRect(x: menueTableView.frame.origin.x + menueTableView.frame.size.width, y: menueTableView.frame.origin.y, width: view.frame.size.width - menueTableView.frame.size.width-2, height: menueTableView.frame.size.height))
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        self.imgViewRefreshScore.tintImageColor(color: UIColor.glfWhite)
        self.imgViewInfo.tintImageColor(color: UIColor.glfFlatBlue)
        view.addSubview(scrollView)
        if teeTypeArr.isEmpty{
            view.addSubview(bottomLbl)
            self.imgViewRefreshScore.isHidden = true
            self.lblStableScore.text = "n/a"
        }else{
            self.imgViewInfo.isHidden = true
        }
        view.addSubview(bView)
        
        var tableWidth = CGFloat()
        for i in 0..<scoreData.count{
            
            tableWidth = 10+(width+padding)*CGFloat(i+2)
        }
        tblView =  UITableView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: scrollView.frame.size.height), style: .plain)
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        tblView.dataSource = self
        tblView.delegate = self
        tblView.tag = 1
        tblView.backgroundColor = UIColor.clear
        tblView.separatorColor = UIColor(rgb: 0xF0F0EE)
        tblView.alwaysBounceVertical = false
        tblView.tableFooterView = UIView()
        scrollView.addSubview(tblView)
        
        scrollView.contentSize = CGSize(width: tblView.frame.size.width, height: tblView.frame.size.height)
        
        let imgView = UIImageView()
        self.expandedSectionHeaderNumber = 2
        tableViewExpandSection(2, imageView: imgView)
        
        self.playerId = ((self.sectionNames[1] as AnyObject).value(forKey: "id") as! String)

        self.scoringSuperView.isHidden = true
        btnDetailScoring.setCorner(color: UIColor.clear.cgColor)
        btnExpendScore.setCorner(color: UIColor.clear.cgColor)
        btnScore.setCornerWithCircleWidthOne(color: UIColor.white.cgColor)
        btnShotRanking.layer.cornerRadius = 10.0

        let tap = UITapGestureRecognizer(target: self, action:  #selector (self.superViewTouchAction (_:)))
        self.scoringSuperView.addGestureRecognizer(tap)
        if scoreData.count == 0{
            menueTableView.isHidden = true
            scrollView.isHidden = true
            bottomLbl.isHidden = true
            bView.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            let emptyLbl = UILabel()
            emptyLbl.frame = CGRect(x: 10, y: self.view.frame.height/2 - 20, width: self.view.frame.width-20, height: 40)
            emptyLbl.numberOfLines = 2
            emptyLbl.textAlignment = .center
            emptyLbl.text = "No Data Found"
            emptyLbl.backgroundColor = UIColor.clear
            self.view.addSubview(emptyLbl)
        }
    }
    var courseData = CourseData()
    func loadStableFordData(){
        if  self.holeHcpWithTee.isEmpty && !isContinue{
            let startingIndex = Int(matchDataDic.value(forKeyPath: "startingHole") as! String)!
            let gameTypeIndex = matchDataDic.value(forKey: "matchType") as! String == "9 holes" ? 9:18
            self.courseData.startingIndex = startingIndex
            self.courseData.gameTypeIndex = gameTypeIndex
            let courseId = "course_\(matchDataDic.value(forKeyPath: "courseId") as! String)"
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            self.courseData.getGolfCourseDataFromFirebase(courseId: courseId)
            NotificationCenter.default.addObserver(self, selector: #selector(self.loadMap(_:)), name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        }
    }
    @objc func loadMap(_ notification:NSNotification){
        self.progressView.hide(navItem: navigationItem)
        for i in 0..<courseData.numberOfHoles.count{
            self.scoreData[i].hole = courseData.numberOfHoles[i].hole
        }
        self.holeHcpWithTee = self.courseData.holeHcpWithTee
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
        self.tblView.reloadData()
    }
    var holeHcpWithTee = [(hole:Int,teeBox:[NSMutableDictionary])]()
    private func processSelectTee(rangeFinArr:[NSMutableDictionary]){
        var i = 1
        for data in rangeFinArr{
            if let teeBox = data.value(forKey: "teeBoxes") as? NSMutableArray{
                var teeData = [NSMutableDictionary]()
                for data in teeBox{
                    teeData.append(data as! NSMutableDictionary)
                }
                holeHcpWithTee.append((hole: i, teeBox: teeData))
            }
            i += 1
        }
    }
    func setHoleShotDetails(par:Int,shots:Int){
        var holeFinishStatus = String()
        var color = UIColor()
        switch shots-par{
        case -1:
            holeFinishStatus = "  Birdie  "
            color = UIColor.glfFlatBlue
            break
        case -2:
            holeFinishStatus = "  Eagle  "
            color = UIColor.glfFlatBlue
            break
        case -3:
            holeFinishStatus = "  Albatross  "
            color = UIColor.glfFlatBlue
            break
        case 0:
            holeFinishStatus = "  Par  "
            color = UIColor.glfFlatBlue
            break
        case 1:
            holeFinishStatus = "  Bogey  "
            color = UIColor.glfWarmGrey
            break
        case 2:
            holeFinishStatus = "  D. Bogey  "
            color = UIColor.glfWarmGrey
            break
        default:
            holeFinishStatus = " \(shots-par) Bogey"
            color = UIColor.glfRosyPink
        }
        btnShotRanking.setTitle(holeFinishStatus, for: .normal)
        btnShotRanking.backgroundColor = color
    }
    
    @objc func superViewTouchAction(_ sender:UITapGestureRecognizer){
        let location = sender.location(in: self.scoringSuperView)
        if !self.scoringView.frame.contains(location){
            self.scoringSuperView.isHidden = true
            getScoreFromMatchDataFirebase()
        }
    }
    
    //MARK: - Setup Initital UI
    func setInitialUI(){
        var tag = 0
        for view in fairwayHitStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.fairwayHitAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForFairwayHit.append((view as! UIButton))
            }
        }
        tag = 10
        for view in girStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.girAction), for: .touchUpInside)
                
                tag += 1
                buttonsArrayForGIR.append((view as! UIButton))
            }
        }
        tag = 20
        for view in puttsStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.puttsAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPutts.append((view as! UIButton))
            }
        }
        tag = 30
        for view in chipShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).frame = frame
                (view as! UIButton).setCircle(frame: frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.chipShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForChipShot.append((view as! UIButton))
            }
        }
        tag = 40
        for view in greenSideSandShotStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.sandShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForSandSide.append((view as! UIButton))
            }
        }
        tag = 50
        for view in penalitiesStackView.subviews{
            if view.isKind(of: UIButton.self){
                (view as! UIButton).frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height)
                (view as! UIButton).setCircle(frame: view.frame)
                (view as! UIButton).tag = tag
                (view as! UIButton).layer.borderWidth = 1
                (view as! UIButton).layer.borderColor = UIColor.glfWarmGrey.cgColor
                (view as! UIButton).addTarget(self, action: #selector(self.penaltyShotAction), for: .touchUpInside)
                tag += 1
                buttonsArrayForPenalty.append((view as! UIButton))
            }
        }
        // Setup Stroks buttons
        buttonsArrayForStrokes.removeAll()
        var i = 1
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes2.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes3.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
        for btn in self.stackViewStrokes4.arrangedSubviews{
            (btn as! UIButton).setTitle("\(i)", for: .normal)
            (btn as! UIButton).tag = i
            i += 1
            (btn as! UIButton).addTarget(self, action: #selector(self.strokesAction), for: .touchUpInside)
            buttonsArrayForStrokes.append(btn as! UIButton)
        }
    }
    @objc func penaltyShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "penaltyCount")
        for btn in buttonsArrayForPenalty{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["penaltyCount":NSNull()])
                for btn in buttonsArrayForPenalty{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "penaltyCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    func updateDictionaryWithValues(dict:NSMutableDictionary)->NSMutableDictionary{
        let dictnary = dict
        let chipShot = dict.value(forKey: "chipCount")
        let sandShot = dict.value(forKey: "sandCount")
        let putting = dict.value(forKey: "putting")
        if((chipShot) != nil) && ((sandShot) != nil) && ((putting) != nil){
            if(chipShot as! Int == 1) && (sandShot as! Int == 0) && (putting as! Int == 1){
                dictnary.setObject(true, forKey: "chipUpDown" as NSCopying)
            }else if(chipShot as! Int > 0) && (((chipShot as! Int) + (putting as! Int)) > 2) && (putting as! Int > 0){
                dictnary.setObject(false, forKey: "chipUpDown" as NSCopying)
            }
            if(chipShot as! Int == 0) && (sandShot as! Int == 1) && (putting as! Int == 1){
                dictnary.setObject(true, forKey: "sandUpDown" as NSCopying)
            }else if(chipShot as! Int > 0) && (((putting as! Int) + (putting as! Int)) > 2) && (putting as! Int > 0){
                dictnary.setObject(false, forKey: "sandUpDown" as NSCopying)
            }
        }
        return dictnary
    }
    @objc func sandShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "sandCount")
        
        for btn in buttonsArrayForSandSide{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["sandCount":NSNull()])
                for btn in buttonsArrayForSandSide{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "sandCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func chipShotAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "chipCount")
        for btn in buttonsArrayForChipShot{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["chipCount":NSNull()])
                for btn in buttonsArrayForChipShot{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "chipCount" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func puttsAction(sender: UIButton!) {
        holeWiseShots.removeObject(forKey: "putting")
        for btn in buttonsArrayForPutts{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["putting":NSNull()])
                for btn in buttonsArrayForPutts{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.isHidden = true
            btn.backgroundColor = UIColor.clear
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((btn.tag % 10), forKey: "putting" as NSCopying)
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    @objc func girAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "gir_false")]
        holeWiseShots.removeObject(forKey: "gir")
        for btn in buttonsArrayForGIR{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["gir":NSNull()])
                for btn in buttonsArrayForGIR{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    btn.isHidden = false
                    let originalImage1 = imgArray[btn.tag%10]
                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    btn.setImage(backBtnImage1, for: .normal)
                    btn.tintColor = UIColor.glfWarmGrey
                    btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
                }
                break
            }
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            let originalImage1 = imgArray[btn.tag%10]
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(backBtnImage1, for: .normal)
            btn.tintColor = UIColor.glfWarmGrey
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            btn.isHidden = true
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                btn.tintColor = UIColor.glfWhite
                btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                if(btn.tag%10 == 0){
                    holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
                }
                else{
                    holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
                }
            }
            holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
            debugPrint(holeWiseShots)
            updateScoreData()
            ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
        }
    }
    @objc func fairwayHitAction(sender: UIButton!) {
        var imgArray = [#imageLiteral(resourceName: "fairway_left"),#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "fairway_right")]
        holeWiseShots.removeObject(forKey: "fairway")
        for btn in buttonsArrayForFairwayHit{
            if(btn.isSelected) && (btn.tag == sender.tag){
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)/").updateChildValues(["fairway":NSNull()])
                for btn in buttonsArrayForFairwayHit{
                    btn.isSelected = false
                    btn.backgroundColor = UIColor.clear
                    let originalImage1 = imgArray[btn.tag]
                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    btn.setImage(backBtnImage1, for: .normal)
                    btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
                    btn.isHidden = false
                }
                break
            }
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            let originalImage1 = imgArray[btn.tag]
            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(backBtnImage1, for: .normal)
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            btn.isHidden = true
            if btn.tag == sender.tag{
                btn.isSelected = true
                btn.isHidden = false
                btn.backgroundColor = UIColor.glfBluegreen
                btn.tintColor = UIColor.glfWhite
                btn.imageView?.tintImageColor(color: UIColor.glfWhite)
                if(btn.tag == 0){
                    holeWiseShots.setObject("L", forKey: "fairway" as NSCopying)
                }else if (btn.tag == 1){
                    holeWiseShots.setObject("H", forKey: "fairway" as NSCopying)
                }else{
                    holeWiseShots.setObject("R", forKey: "fairway" as NSCopying)
                }
                holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
                debugPrint(holeWiseShots)
                ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
            }
            
        }
        holeWiseShots = updateDictionaryWithValues(dict: holeWiseShots)
        debugPrint(holeWiseShots)
        updateScoreData()
        
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(holeWiseShots as! [AnyHashable : Any])
    }
    func updateScoreData(){
        var i = 0
        for data in scoreData[self.index].players{
            let keys = data.allKeys as! [String]
            if keys.first == self.playerId{
                if(holeWiseShots.value(forKey: "holeOut") == nil){
                    holeWiseShots.setValue(false, forKey: "holeOut")
                }
                let dict = NSMutableDictionary()
                dict.setValue(holeWiseShots, forKey: self.playerId)
                scoreData[self.index].players[i] = dict
            }
            i += 1
        }
    }
    @objc func buttonAction(sender: CellButton!) {
        
        self.view.addSubview(self.scoringSuperView)
        self.scoringSuperView.isHidden = false
        self.scoringView.isHidden = false
        self.scoringView.tag = 33
        
        self.fairwayHitStackView.superview?.isHidden = false
        if(self.scoreData[self.index].par == 3){
            self.fairwayHitStackView.superview?.isHidden = true
        }
        
        var newI = self.scoreData[self.index].par - 2
        for btn in self.stackViewStrokes1.arrangedSubviews{
            (btn as! UIButton).setTitle("\(newI)", for: .normal)
            updateStrokesButtonWithoutStrokes(strokes: (newI-self.scoreData[self.index].par), btn: btn as! UIButton,color: UIColor.white)
            newI += 1
        }
        self.playerId = sender.userData
        self.index = sender.tag
        self.classicScoring = self.getScoreIntoClassicNode(hole: self.index,playerKey: self.playerId!)
        self.updateValue()
        lblHolePar.text = "Hole \(self.index+1) - Par \(self.scoreData[self.index].par)"
    }
    
    func getScoreIntoClassicNode(hole:Int,playerKey:String)->classicMode{
        let classicScore = classicMode()
        for data in scoreData[hole].players{
            if let dic = (data).value(forKey: playerKey) as? NSMutableDictionary{
                self.holeWiseShots = dic
                if let chipShot = dic.value(forKey: "chipCount") as? Int{
                    classicScore.chipShot = chipShot
                }
                if let sandShot = dic.value(forKey: "sandCount") as? Int{
                    classicScore.sandShot = sandShot
                }
                if let strokesCount = dic.value(forKey: "strokes") as? Int{
                    classicScore.strokesCount = strokesCount
                }
                if let holeOut = dic.value(forKey: "holeOut") as? Bool{
                    classicScore.holeOut = holeOut
                }
                if let putting = dic.value(forKey: "putting") as? Int{
                    classicScore.putting = putting
                }
                if let fairway = dic.value(forKey: "fairway") as? String{
                    classicScore.fairway = fairway
                }
                if let penaltyShot = dic.value(forKey: "penaltyCount") as? Int{
                    classicScore.penaltyShot = penaltyShot
                }
                if let gir = dic.value(forKey: "gir") as? Bool{
                    classicScore.gir = gir
                }
                if let sb = dic.value(forKey: "stableFordPoints") as? Int{
                    classicScore.stableFordScore = sb
                }
                if let netScore = dic.value(forKey: "netScore") as? Int{
                    classicScore.netScore = netScore
                }
            }
        }
        return classicScore
    }
    
    func updateValue(){
        for i in 0..<buttonsArrayForChipShot.count{
            buttonsArrayForChipShot[i].isSelected = false
            buttonsArrayForChipShot[i].isHidden = false
            buttonsArrayForChipShot[i].backgroundColor = UIColor.clear
            if ((classicScoring.chipShot) != nil){
                buttonsArrayForChipShot[i].isHidden = true
            }
        }
        if ((classicScoring.chipShot) != nil){
            buttonsArrayForChipShot[classicScoring.chipShot!%10].isSelected = true
            buttonsArrayForChipShot[classicScoring.chipShot!%10].isHidden = false
            buttonsArrayForChipShot[classicScoring.chipShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.chipShot! % 10), forKey: "chipCount" as NSCopying)
        }
        for i in 0..<buttonsArrayForPenalty.count{
            buttonsArrayForPenalty[i].isSelected = false
            buttonsArrayForPenalty[i].isHidden = false
            buttonsArrayForPenalty[i].backgroundColor = UIColor.clear
            if ((classicScoring.penaltyShot) != nil){
                buttonsArrayForPenalty[i].isHidden = true
            }
        }
        if ((classicScoring.penaltyShot) != nil){
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].isSelected = true
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].isHidden = false
            buttonsArrayForPenalty[classicScoring.penaltyShot!%10].backgroundColor = UIColor.glfBluegreen
            holeWiseShots.setObject((classicScoring.penaltyShot! % 10), forKey: "penaltyCount" as NSCopying)
            
        }
        for i in 0..<buttonsArrayForSandSide.count{
            buttonsArrayForSandSide[i].isSelected = false
            buttonsArrayForSandSide[i].isHidden = false
            buttonsArrayForSandSide[i].backgroundColor = UIColor.clear
            if ((classicScoring.sandShot) != nil){
                buttonsArrayForSandSide[i].isHidden = true
            }
            if ((classicScoring.sandShot) != nil){
                buttonsArrayForSandSide[classicScoring.sandShot!%10].isSelected = true
                buttonsArrayForSandSide[classicScoring.sandShot!%10].isHidden = false
                buttonsArrayForSandSide[classicScoring.sandShot!%10].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((classicScoring.sandShot! % 10), forKey: "sandCount" as NSCopying)
            }
        }
        for i in 0..<buttonsArrayForPutts.count{
            buttonsArrayForPutts[i].isSelected = false
            buttonsArrayForPutts[i].isHidden = false
            buttonsArrayForPutts[i].backgroundColor = UIColor.clear
            if ((classicScoring.putting) != nil){
                buttonsArrayForPutts[i].isHidden = true
            }
            if ((classicScoring.putting) != nil){
                buttonsArrayForPutts[classicScoring.putting!%10].isHidden = false
                buttonsArrayForPutts[classicScoring.putting!%10].isSelected = true
                buttonsArrayForPutts[classicScoring.putting!%10].backgroundColor = UIColor.glfBluegreen
                holeWiseShots.setObject((classicScoring.putting! % 10), forKey: "putting" as NSCopying)
            }
        }
        
        buttonsArrayForGIR[0].isSelected = false
        buttonsArrayForGIR[1].isSelected = false
        buttonsArrayForGIR[0].isHidden = false
        buttonsArrayForGIR[1].isHidden = false
        buttonsArrayForGIR[0].backgroundColor = UIColor.clear
        buttonsArrayForGIR[1].backgroundColor = UIColor.clear
        buttonsArrayForGIR[0].imageView?.tintImageColor(color: UIColor.glfWarmGrey)
        buttonsArrayForGIR[1].imageView?.tintImageColor(color: UIColor.glfWarmGrey)
        buttonsArrayForGIR[0].tintColor = UIColor.glfWarmGrey
        buttonsArrayForGIR[1].tintColor = UIColor.glfWarmGrey
        if ((classicScoring.gir) != nil){
            buttonsArrayForGIR[0].isHidden = true
            buttonsArrayForGIR[1].isHidden = true
        }
        if ((classicScoring.gir) != nil){
            if(classicScoring.gir!){
                buttonsArrayForGIR[0].isSelected = true
                buttonsArrayForGIR[0].isHidden = false
                buttonsArrayForGIR[0].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForGIR[0].imageView?.tintImageColor(color: UIColor.glfWhite)
                buttonsArrayForGIR[0].tintColor = UIColor.glfWhite
                holeWiseShots.setObject(true, forKey: "gir" as NSCopying)
            }
            else{
                buttonsArrayForGIR[1].isSelected = true
                buttonsArrayForGIR[1].isHidden = false
                buttonsArrayForGIR[1].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForGIR[1].imageView?.tintImageColor(color: UIColor.glfWhite)
                buttonsArrayForGIR[1].tintColor = UIColor.glfWhite
                
                holeWiseShots.setObject(false, forKey: "gir" as NSCopying)
            }
        }
        
        for btn in buttonsArrayForFairwayHit{
            btn.isSelected = false
            btn.backgroundColor = UIColor.clear
            btn.isHidden = false
            btn.imageView?.tintImageColor(color: UIColor.glfWarmGrey)
            if ((classicScoring.fairway) != nil){
                btn.isHidden = true
            }
        }
        if ((classicScoring.fairway) != nil){
            switch (classicScoring.fairway!){
            case "L":
                buttonsArrayForFairwayHit[0].isSelected = true
                buttonsArrayForFairwayHit[0].isHidden = false
                buttonsArrayForFairwayHit[0].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[0].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("L", forKey: "fairway" as NSCopying)
                break
            case "H":
                buttonsArrayForFairwayHit[1].isSelected = true
                buttonsArrayForFairwayHit[1].isHidden = false
                buttonsArrayForFairwayHit[1].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[1].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("H", forKey: "fairway" as NSCopying)
                break
            default:
                buttonsArrayForFairwayHit[2].isSelected = true
                buttonsArrayForFairwayHit[2].isHidden = false
                buttonsArrayForFairwayHit[2].backgroundColor = UIColor.glfBluegreen
                buttonsArrayForFairwayHit[2].imageView?.tintImageColor(color: UIColor.glfWhite)
                holeWiseShots.setObject("R", forKey: "fairway" as NSCopying)
                break
            }
        }
        //btnDetailsScoringConstraints.constant = 0
        if classicScoring.holeOut != nil && classicScoring.holeOut!{
            self.setHoleShotDetails(par:self.scoreData[self.index].par,shots:classicScoring.strokesCount!)
            self.btnScore.setTitle("\(classicScoring.strokesCount!)", for: .normal)
            self.scoreSV.isHidden = true
            self.detailScoreSV.isHidden = false
            //btnDetailsScoringConstraints.constant = 16
        }else{
            self.scoreSV.isHidden = false
            self.detailScoreSV.isHidden = true
            self.scoreSecondSV.isHidden = true
            //btnDetailsScoringConstraints.constant = 0
        }
    }
    @objc func strokesAction(sender: UIButton!){
        let title = sender.currentTitle
        self.holeWiseShots.setObject(Int(title!)!, forKey: "strokes" as NSCopying)
        self.holeWiseShots.setObject(true, forKey: "holeOut" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(["strokes":Int(title!)!] as [AnyHashable : Any])
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(self.playerId!)").updateChildValues(["holeOut":true] as [AnyHashable : Any])
        self.setHoleShotDetails(par:self.scoreData[self.index].par,shots:Int(title!)!)
        self.btnScore.setTitle("\(title!)", for: .normal)
        self.scoreSV.isHidden = true
        self.detailScoreSV.isHidden = false
        if(!self.teeTypeArr.isEmpty){
            self.uploadStableFordPints(playerId: self.playerId!,strokes:Int(title!)!)
        }else{
            updateScoreData()
        }
    }
    func uploadStableFordPints(playerId:String,strokes:Int){
        var index = 0
        for playersdata in self.playerData{
            if (playersdata as! NSMutableDictionary).value(forKey: "id") as! String == playerId{
                break
            }
            index += 1
        }
        let par = scoreData[index].par
        let extrashotsReminder = Int(self.calculateTotalExtraShots(playerID: playerId)) % scoreData.count
        let extrashotsDiv = Int(self.calculateTotalExtraShots(playerID: playerId)) / scoreData.count
        var hcp = 0
        var totalShotsInThishole = 0
        for tee in holeHcpWithTee{
            if tee.hole == self.index+1{
                for data in tee.teeBox{
                    if (data.value(forKey: "teeType") as! String) == (self.teeTypeArr[index].tee).lowercased(){
                        hcp = data.value(forKey:"hcp") as? Int ?? 0
                        break
                    }
                }
                break
            }
        }
        if hcp > 0 && hcp <= extrashotsReminder{
            totalShotsInThishole = par + extrashotsDiv + 1
        }else{
            totalShotsInThishole = par + extrashotsDiv
        }
        let sbPoint = totalShotsInThishole - strokes + 2
        let netScore = strokes - (totalShotsInThishole - par)
        holeWiseShots.setObject(sbPoint, forKey: "stableFordPoints" as NSCopying)
//        lblStableFordScore.text = "\(sbPoint)"
//        btnStableScore.setTitle("Stableford Score", for: .normal)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(playerId)/stableFordPoints").setValue(sbPoint)
        holeWiseShots.setObject(netScore, forKey: "netScore" as NSCopying)
        ref.child("matchData/\(matchId)/scoring/\(self.index)/\(playerId)/netScore").setValue(netScore)
        updateScoreData()
    }
    func calculateTotalExtraShots(playerID:String)->Double{
        var index = 0
        for playersdata in self.playerData{
            if ((playersdata as! NSMutableDictionary).value(forKey: "id") as! String) == playerId{
                break
            }
            index += 1
        }
        
        var slopeIndex = 0
        for data in teeArr{
            if(data.type.lowercased() == self.teeTypeArr[index].tee.lowercased()){
                break
            }
            slopeIndex += 1
        }
        let data = (self.teeTypeArr[index].handicap * Double(teeArr[slopeIndex].slope)!)
        return (Double(data / 113))
    }
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.menueTableView.backgroundView = messageLabel
            self.tblView.backgroundView = messageLabel
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 ||  section == 1{
            return 0
        }
        else if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let header = UIView()
        header.backgroundColor = UIColor.white
        
        if tableView.tag == 0 {
            
            let usrImageView = UIImageView(frame: CGRect(x: 10, y: 8, width: 32, height: 32))
            usrImageView.setCircle(frame: usrImageView.frame)
            if section > 1{
                usrImageView.image = #imageLiteral(resourceName: "you")
                if let url = (self.sectionNames[section] as AnyObject).value(forKey: "image") as? String{
                    usrImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
                    if url == ""{
                        usrImageView.image = #imageLiteral(resourceName: "you")
                    }
                }
                usrImageView.tag = kHeaderSectionTag + section
                let label = UILabel()
                
                label.frame = CGRect(x: usrImageView.frame.origin.x + usrImageView.frame.size.width+10, y: 15, width: 80, height: 15)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.textColor = UIColor.glfFlatBlue
                label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                header.addSubview(label)
                
                //header.textLabel?.textColor = UIColor.blue
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.menueTableView.frame.size
                
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
                theImageView.image = UIImage(named: "Chevron-Dn-Wht")
                theImageView.tag = kHeaderSectionTag + section
                
                header.addSubview(theImageView)
                header.addSubview(usrImageView)
                
                // make headers touchable
                header.tag = section
                let headerTapGesture = UITapGestureRecognizer()
                headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
                header.addGestureRecognizer(headerTapGesture)
                
//                UIView.animate(withDuration: 0.4, animations: {
//                    theImageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//                })
//                if (self.expandedSectionHeaderNumber == section) {
//                    UIView.animate(withDuration: 0.4, animations: {
//                        theImageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//                    })
//                }
               }
            else if section == 0{
                header.backgroundColor = UIColor(rgb: 0x2E9F80)

                let holeLbl = UILabel()
                holeLbl.frame = CGRect(x: usrImageView.frame.origin.x, y: 9, width: 80, height: 15)
                holeLbl.textColor = UIColor.white
                holeLbl.text = "Hole"
                header.addSubview(holeLbl)
            }
            else{
                header.backgroundColor = UIColor(rgb:0xACE675)
                let label = UILabel()
                
                label.frame = CGRect(x: usrImageView.frame.origin.x, y: 9, width: 80, height: 15)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.textColor = UIColor.glfBluegreen
                label.sizeToFit()
                header.addSubview(label)
            }
        }
        else{
            if section == 0{
                header.backgroundColor = UIColor(rgb: 0x2E9F80)
                
                let label =  UILabel(frame: CGRect(x: 10+(width + padding)*CGFloat(scoreData.count), y: 12, width: 50, height: 15))
                label.text = "Total"
                label.textAlignment = .center
                label.textColor = UIColor.white
                header.addSubview(label)

                for i in 0..<scoreData.count{
                    
                    let label =  UILabel(frame: CGRect(x: 25+(width + padding)*CGFloat(i), y: 9, width: 35, height: 15))
                    label.text = "\(i+1)"
                    label.textAlignment = .center
                    label.textColor = UIColor.white
                    header.addSubview(label)
                }
            }
            else if section == 1{
                header.backgroundColor = UIColor(rgb:0xACE675)

                var totalpar = 0
                for i in 0..<scoreData.count{
                    //var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
                    let label =  UILabel(frame: CGRect(x: 25+(width + padding)*CGFloat(i), y: 9, width: 35, height: 15))
                    label.text = "\(self.scoreData[i].par)"
                    label.textAlignment = .center
                    label.textColor = UIColor.black
                    header.addSubview(label)
                    
                    totalpar += self.scoreData[i].par
                }
                let label =  UILabel(frame: CGRect(x: 25+(width + padding)*CGFloat(scoreData.count), y: 9, width: 35, height: 15))
                label.text = "\(totalpar)"
                label.textAlignment = .center
                label.textColor = UIColor.black
                header.addSubview(label)
            }
            else{
                header.backgroundColor = UIColor(rgb: 0xF7F7F5)
                
                let playerId = (self.sectionNames[section] as AnyObject).value(forKey: "id") as? String
                for view in header.subviews{
                    if view.isKind(of: UILabel.self){
                        view.removeFromSuperview()
                    }
                }
                
                var totalStrokes = 0
                for i in 0..<self.scoreData.count{
                    
                    let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(i), y: 5, width: 35, height: 35))
                    subView.backgroundColor = UIColor.clear
                    header.addSubview(subView)
                    
//                    let btn =  UIButton(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
//                    btn.titleLabel?.textAlignment = .center
//                    btn.setTitleColor(UIColor.black, for: .normal)
//                    btn.setTitle("-", for: .normal)
//                    subView.addSubview(btn)
                    
                    let btn = CellButton()
                    btn.frame = CGRect(x: 5, y: 5, width: 25, height: 25)
                    btn.setTitle("-", for: .normal)
                    btn.titleLabel?.textAlignment = .center
                    btn.setTitleColor(UIColor.black, for: .normal)
                    btn.tag = i
                    btn.userData = playerId
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    subView.addSubview(btn)
                    btn.isUserInteractionEnabled = isContinue

                    for dataDict in self.scoreData[i].players{
                        for (key,value) in dataDict{
                            if(key as? String == playerId){
                                if let valueDict = value as? NSMutableDictionary{
                                    for (key,value) in valueDict{
                                        var totalShots = 0
                                        var allScore = Int()
                                        if(key as! String == "shots"){
                                            let shotsArray = value as! NSArray
                                            allScore  = shotsArray.count - (self.scoreData[i].par)
                                            totalShots = shotsArray.count
                                            btn.setTitle("\(totalShots)", for: .normal)
                                            
                                            totalStrokes += totalShots
                                        }
                                        else if (key as! String == "strokes"){
                                            allScore  = (value as! Int) - (self.scoreData[i].par)
                                            totalShots = (value as! Int)
                                            btn.setTitle("\(totalShots)", for: .normal)
                                            
                                            totalStrokes += totalShots
                                        }
                                        if allScore <= -2 || allScore <= -3{
                                            //double circle
                                            subView.layer.borderWidth = 1.0
                                            subView.layer.cornerRadius = subView.frame.size.height/2
                                            subView.layer.borderColor = UIColor.glfBluegreen.cgColor
                                            
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.cornerRadius = btn.frame.size.height/2
                                            btn.layer.borderColor = UIColor.glfBluegreen.cgColor
                                        }
                                        else if allScore == -1{
                                            //single circle
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.cornerRadius = btn.frame.size.height/2
                                            btn.layer.borderColor = UIColor.glfBluegreen.cgColor
                                        }
                                        else if allScore == 1{
                                            //single square
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.borderColor = UIColor.red.cgColor
                                        }
                                        else if allScore >= 2 || allScore >= 3{
                                            //double square
                                            subView.layer.borderWidth = 1.0
                                            subView.layer.borderColor = UIColor.red.cgColor
                                            btn.layer.borderWidth = 1.0
                                            btn.layer.borderColor = UIColor.red.cgColor
                                        }
                                        else{
                                            // do nothing
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(scoreData.count), y: 5, width: 35, height: 35))
                subView.backgroundColor = UIColor.clear
                header.addSubview(subView)
                let btn =  UIButton(frame: CGRect(x: 3, y: 5, width: 25, height: 25))
                btn.titleLabel?.textAlignment = .center
                btn.setTitleColor(UIColor.black, for: .normal)
                btn.setTitle("-", for: .normal)
                btn.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 16.0)
                if totalStrokes > 0{
                    btn.setTitle("\(totalStrokes)", for: .normal)
                }
                subView.addSubview(btn)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section>1{
            return 45
        }
        else{
        return 32.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 32.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String
        
        if tableView.tag == 0 {
            cellIdentifier = "MenueCell"
        }
        else{
            cellIdentifier = "DataCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.section > 1{
            
            if tableView.tag == 0 {
                let section = self.sectionItems[indexPath.section] as! NSArray
                cell.textLabel?.text = section[indexPath.row] as? String
                
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                
                if mode == 1{
                    if indexPath.row == 8{
                        cell.backgroundColor = UIColor(rgb: 0xE7E7E7)
                    }
                    else if indexPath.row == 9 || indexPath.row == 10{
                        cell.backgroundColor = UIColor(rgb: 0x98B6CD)
                    }
                }
                else{
                    if indexPath.row == 6{
                        cell.backgroundColor = UIColor(rgb: 0xE7E7E7)
                    }
                    else if indexPath.row == 7 || indexPath.row == 8{
                        cell.backgroundColor = UIColor(rgb: 0x98B6CD)
                    }
                }
            }
            else{
                cell.backgroundColor = UIColor(rgb: 0xF7F7F5)
                if mode == 1{
                    if indexPath.row == 8{
                        cell.backgroundColor = UIColor(rgb: 0xE7E7E7)
                    }
                    else if indexPath.row == 9 || indexPath.row == 10{
                        cell.backgroundColor = UIColor(rgb: 0x98B6CD)
                    }
                }
                else{
                    if indexPath.row == 6{
                        cell.backgroundColor = UIColor(rgb: 0xE7E7E7)
                    }
                    else if indexPath.row == 7 || indexPath.row == 8{
                        cell.backgroundColor = UIColor(rgb: 0x98B6CD)
                    }
                }
                cell.textLabel?.textColor = UIColor.clear
                cell.textLabel?.text = ""
                let playerId = (self.sectionNames[indexPath.section] as AnyObject).value(forKey: "id") as? String
                
                for subView in cell.contentView.subviews{
                    subView.removeFromSuperview()
                }
                var drDistance = 0
                var drivingCount = 0
                var frwHit = 0
                var aprchDistance = 0
                var aprchCount = 0
                var girTotal = 0
                var chipDown = 0
                var sandTotal = 0
                var puttsTotal = 0
                var penaltyTotal = 0
                var hcpTotal = 0
                var stablefordTotal = 0
                var netScoreTotal = 0

                for i in 0..<scoreData.count{

                    let btn = CellButton(frame:CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 40, height: 32))
                    btn.setTitle("-", for: .normal)
                    btn.titleLabel?.textAlignment = .center
                    btn.titleLabel!.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                    btn.setTitleColor(UIColor.black, for: .normal)
                    btn.tag = i
                    btn.userData = playerId
                    btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    cell.contentView.addSubview(btn)
                    btn.isUserInteractionEnabled = isContinue
                    
//                    let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 40, height: 32))
//                    label.text = "-"
//                    label.textAlignment = .center
//                    label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
//                    label.textColor = UIColor.black
//                    label.backgroundColor = UIColor.clear
//                    cell.contentView.addSubview(label)
                    
//                    let theImageView = UIButton(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 32, height: 32))
                    
                    for dataDict in self.scoreData[i].players{

                        for (key,value) in dataDict{

                            var imgArray = [#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "gir_false")]
                            if(key as? String == playerId){
                                if let dict = value as? NSMutableDictionary{
                                for (key,value) in dict{
                                    if mode == 1{
                                    if indexPath.row == 0{
                                        if(key as! String == "drivingDistance"){
                                            var drivingDistance = value as! Double
                                            var suffix = "m"
                                            if(distanceFilter != 1){
                                                drivingDistance = drivingDistance*YARD
                                                suffix = "yd"
                                            }
//                                            label.text = "\(Int(drivingDistance))\(suffix)"
                                            btn.setTitle("\(Int(drivingDistance))\(suffix)", for: .normal)

                                            drDistance += (Int(drivingDistance))
                                            drivingCount += 1
                                        }
                                    }
                                    else if indexPath.row == 1{
                                        if(key as! String == "fairway"){
                                            let fairway = value as! String
//                                            label.text = ""
                                            btn.setTitle("", for: .normal)
                                            if(fairway == "H"){
                                                let backBtnImage1 = #imageLiteral(resourceName: "hit").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                btn.setImage(backBtnImage1, for: .normal)
                                                btn.tintColor = UIColor.glfBluegreen

                                                frwHit += 1

                                            }else if(fairway == "L"){
                                                let backBtnImage1 = #imageLiteral(resourceName: "fairway_left").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                btn.setImage(backBtnImage1, for: .normal)
                                                btn.tintColor = UIColor.glfFlatBlue

                                            }else{
                                                let backBtnImage1 = #imageLiteral(resourceName: "fairway_right").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                btn.setImage(backBtnImage1, for: .normal)
                                                btn.tintColor = UIColor.glfFlatBlue
                                            }
                                            //cell.contentView.addSubview(btn)
                                        }
                                    }
                                    else if indexPath.row == 2{
                                        if(key as! String == "approachDistance"){
                                            var approchDist = value as! Double
                                            var suffix = "m"
                                            if(distanceFilter != 1){
                                                approchDist = approchDist*YARD
                                                suffix = "yd"
                                            }
//                                            label.text = "\(Int(approchDist))\(suffix)"
                                            btn.setTitle("\(Int(approchDist))\(suffix)", for: .normal)
                                            aprchDistance += (Int(approchDist))
                                            aprchCount += 1
                                        }
                                    }
                                    else if indexPath.row == 3{
                                        if(key as! String == "gir"){
                                            let gir = value as! Bool
//                                            label.text = ""
                                            btn.setTitle("", for: .normal)
                                            if gir{
                                                let originalImage1 = imgArray[0]
                                                let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                btn.setImage(backBtnImage1, for: .normal)
                                                girTotal += 1
                                            }else{
                                                let originalImage1 = imgArray[1]
                                                let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                btn.setImage(backBtnImage1, for: .normal)
                                            }
                                            btn.tintColor = UIColor.glfBluegreen
//                                            cell.contentView.addSubview(btn)
                                        }
                                    }
                                    else if indexPath.row == 4{
                                        if(key as! String == "chipUpDown"){
                                            if let chipUpDown = value as? Bool{
//                                                label.text = ""
                                                btn.setTitle("", for: .normal)
                                                if chipUpDown{
                                                    let originalImage1 = imgArray[0]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    btn.setImage(backBtnImage1, for: .normal)
                                                    chipDown += 1
                                                }else{
                                                    let originalImage1 = imgArray[1]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    btn.setImage(backBtnImage1, for: .normal)
                                                }
                                                btn.tintColor = UIColor.glfBluegreen
//                                                cell.contentView.addSubview(btn)
                                            }
                                        }
                                    }
                                    else if indexPath.row == 5{
                                        if(key as! String == "sandUpDown"){
                                            if let sandDown = value as? Bool{
//                                                label.text = ""
                                                btn.setTitle("", for: .normal)
                                                if sandDown{
                                                    let originalImage1 = imgArray[0]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    btn.setImage(backBtnImage1, for: .normal)
                                                    sandTotal += 1
                                                }else{
                                                    let originalImage1 = imgArray[1]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    btn.setImage(backBtnImage1, for: .normal)
                                                }
                                                btn.tintColor = UIColor.glfBluegreen
//                                                cell.contentView.addSubview(btn)
                                            }
                                        }
                                    }
                                    else if indexPath.row == 6{
                                        if(key as! String == "putting"){
                                            let approchDist = value as! Int
//                                            label.text = "\(approchDist)"
                                            btn.setTitle("\(approchDist)", for: .normal)

                                            puttsTotal += approchDist
                                        }
                                    }
                                    else if indexPath.row == 7{
                                        if(key as! String == "penaltyCount"){
                                            let approchDist = value as! Int
//                                            label.text = "\(approchDist)"
                                            btn.setTitle("\(approchDist)", for: .normal)
                                            penaltyTotal += approchDist
                                        }
                                    }
                                    else if indexPath.row == 8{
                                        let hcp = self.getHCPValue(playerID:playerId!,holeNo: i)
                                        debugPrint(i)
                                        btn.setTitle("\(hcp)", for: .normal)
                                        hcpTotal += hcp
                                    }
                                    else if indexPath.row == 9{
                                        if(key as! String == "stableFordPoints"){
                                            let stableFord = value as! Int
//                                            label.text = "\(stableFord)"
                                            btn.setTitle("\(stableFord)", for: .normal)

                                            stablefordTotal += stableFord
                                        }
                                        }
                                    else if indexPath.row == 10{
                                        if(key as! String == "netScore"){
                                            let netScore = value as! Int
//                                            label.text = "\(netScore)"
                                            btn.setTitle("\(netScore)", for: .normal)

                                            netScoreTotal += netScore
                                        }
                                        }
                                    }
                                    else{
                                            if indexPath.row == 0{
                                                if(key as! String == "fairway"){
                                                    let fairway = value as! String
//                                                    label.text = ""
                                                    btn.setTitle("", for: .normal)

                                                    if(fairway == "H"){
                                                        let backBtnImage1 = #imageLiteral(resourceName: "hit").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        btn.setImage(backBtnImage1, for: .normal)
                                                        btn.tintColor = UIColor.glfBluegreen

                                                        frwHit += 1
                                                        
                                                    }else if(fairway == "L"){
                                                        let backBtnImage1 = #imageLiteral(resourceName: "fairway_left").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        btn.setImage(backBtnImage1, for: .normal)
                                                        btn.tintColor = UIColor.glfFlatBlue
                                                    }else{
                                                        let backBtnImage1 = #imageLiteral(resourceName: "fairway_right").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        btn.setImage(backBtnImage1, for: .normal)
                                                        btn.tintColor = UIColor.glfFlatBlue
                                                    }
//                                                    cell.contentView.addSubview(btn)
                                                }
                                            }
                                            else if indexPath.row == 1{
                                                if(key as! String == "gir"){
                                                    let gir = value as! Bool
//                                                    label.text = ""
                                                    btn.setTitle("", for: .normal)

                                                    if gir{
                                                        let originalImage1 = imgArray[0]
                                                        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        btn.setImage(backBtnImage1, for: .normal)
                                                        girTotal += 1
                                                    }else{
                                                        let originalImage1 = imgArray[1]
                                                        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        btn.setImage(backBtnImage1, for: .normal)
                                                    }
                                                    btn.tintColor = UIColor.glfBluegreen
//                                                    cell.contentView.addSubview(btn)
                                                }

                                            }
                                            else if indexPath.row == 2{
                                                if(key as! String == "chipUpDown"){
                                                    if let chipUpDown = value as? Bool{
//                                                        label.text = ""
                                                        btn.setTitle("", for: .normal)

                                                        if chipUpDown{
                                                            let originalImage1 = imgArray[0]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            btn.setImage(backBtnImage1, for: .normal)
                                                            chipDown += 1
                                                        }else{
                                                            let originalImage1 = imgArray[1]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            btn.setImage(backBtnImage1, for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfBluegreen
//                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 3{
                                                if(key as! String == "sandUpDown"){
                                                    if let sandDown = value as? Bool{
//                                                        label.text = ""
                                                        btn.setTitle("", for: .normal)

                                                        if sandDown{
                                                            let originalImage1 = imgArray[0]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            btn.setImage(backBtnImage1, for: .normal)
                                                            sandTotal += 1
                                                        }else{
                                                            let originalImage1 = imgArray[1]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            btn.setImage(backBtnImage1, for: .normal)
                                                        }
                                                        btn.tintColor = UIColor.glfBluegreen
//                                                        cell.contentView.addSubview(btn)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 4{
                                                if(key as! String == "putting"){
                                                    let approchDist = value as! Int
//                                                    label.text = "\(approchDist)"
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    puttsTotal += approchDist
                                                }
                                            }
                                            else if indexPath.row == 5{
                                                if(key as! String == "penaltyCount"){
                                                    let approchDist = value as! Int
//                                                    label.text = "\(approchDist)"
                                                    btn.setTitle("\(approchDist)", for: .normal)
                                                    penaltyTotal += approchDist
                                                }
                                            }
                                            else if indexPath.row == 6{
                                                let hcp = self.getHCPValue(playerID:playerId!,holeNo:i)
                                                debugPrint(i)
                                                btn.setTitle("\(hcp)", for: .normal)
                                                hcpTotal += hcp
                                            }
                                            else if indexPath.row == 7{
                                                if(key as! String == "stableFordPoints"){
                                                    let stableFord = value as! Int
//                                                    label.text = "\(stableFord)"
                                                    btn.setTitle("\(stableFord)", for: .normal)
                                                    stablefordTotal += stableFord
                                                }
                                            }
                                            else if indexPath.row == 8{
                                                if(key as! String == "netScore"){
                                                    let netScore = value as! Int
//                                                    label.text = "\(netScore)"
                                                    btn.setTitle("\(netScore)", for: .normal)
                                                    netScoreTotal += netScore
                                                }
                                        }
                                      }
                                    }
                                }
                            }
                        }
                    }
                }
                let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(scoreData.count), y: 0, width: 40, height: 32))
                label.text = "-"
                
                if mode == 1{
                if indexPath.row == 0{
                    if drDistance>0{
                        var suffix = "m"
                        if(distanceFilter != 1){
                            suffix = "yd"
                        }
                        label.text = "\(Int(drDistance/drivingCount))\(suffix)"
                    }
                }
                else if indexPath.row == 1{
                    if frwHit>0{
                        label.text = "\(frwHit)"
                    }
                }
                else if indexPath.row == 2{
                    if aprchDistance>0{
                        var suffix = "m"
                        if(distanceFilter != 1){
                            suffix = "yd"
                        }
                        label.text = "\(Int(aprchDistance/aprchCount))\(suffix)"
                    }
                }
                else if indexPath.row == 3{
                    if girTotal>0{
                        label.text = "\(girTotal)"
                    }
                }
                else if indexPath.row == 4{
                    if chipDown>0{
                        label.text = "\(chipDown)"
                    }
                }
                else if indexPath.row == 5{
                    if sandTotal>0{
                        label.text = "\(sandTotal)"
                    }
                }
                else if indexPath.row == 6{
                    if puttsTotal>0{
                    label.text = "\(puttsTotal)"
                    }
                }
                else if indexPath.row == 7{
                    if penaltyTotal>0{
                    label.text = "\(penaltyTotal)"
                    }
                }
                else if indexPath.row == 8{
                    if hcpTotal>0{
                        label.text = ""
                    }
                }
                else if indexPath.row == 9{
                    if stablefordTotal>0{
                        label.text = "\(stablefordTotal)"
                    }
                    }
                else if indexPath.row == 10{
                    if netScoreTotal>0{
                        label.text = "\(netScoreTotal)"
                    }
                    }
                }
                else{
                        if indexPath.row == 0{
                            if frwHit>0{
                                label.text = "\(frwHit)"
                            }
                        }
                        else if indexPath.row == 1{
                            if girTotal>0{
                                label.text = "\(girTotal)"
                            }
                        }
                        else if indexPath.row == 2{
                            if chipDown>0{
                                label.text = "\(chipDown)"
                            }
                        }
                        else if indexPath.row == 3{
                            if sandTotal>0{
                                label.text = "\(sandTotal)"
                            }
                        }
                        else if indexPath.row == 4{
                            if puttsTotal>0{
                            label.text = "\(puttsTotal)"
                            }
                        }
                        else if indexPath.row == 5{
                            if penaltyTotal>0{
                            label.text = "\(penaltyTotal)"
                            }
                        }
                        else if indexPath.row == 6{
                            if hcpTotal>0{
                                label.text = ""
                            }
                        }

                        else if indexPath.row == 7{
                            if stablefordTotal>0{
                                label.text = "\(stablefordTotal)"
                            }
                    }
                        else if indexPath.row == 8{
                            if netScoreTotal>0{
                                label.text = "\(netScoreTotal)"
                            }
                    }
                }
                label.textAlignment = .center
                label.textColor = UIColor.black
                label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                label.backgroundColor = UIColor.clear
                cell.contentView.addSubview(label)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        //let headerView = sender.view as! UITableViewHeaderFooterView
        let headerView = sender.view
        if !(self.scoringView.isHidden){
            self.scoringView.isHidden = true
        }

        let section    = headerView?.tag
        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section!
            tableViewExpandSection(section!, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section!, imageView: eImageView!)
            }
            else {
//                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                tableViewExpandSection(section!, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1
        if (sectionData.count == 0) {
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.menueTableView!.beginUpdates()
            self.menueTableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            
            self.menueTableView!.beginUpdates()
            self.menueTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
}
