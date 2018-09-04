//
//  HomeTopTableVIewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 02/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Charts
import FirebaseDatabase
import UICircularProgressRing

class HomeTopTableVIewCell: UITableViewCell {
    
    @IBOutlet weak var card4Achievements: CardView!
    @IBOutlet weak var achievementView: UIScrollView!
    @IBOutlet weak var scoreViewProgressBar: UICircularProgressRingView!
    @IBOutlet weak var barView: BarChartView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var avgDistanceValue: UILabel!
    @IBOutlet weak var avgDistanceLabel: UILabel!
    @IBOutlet weak var strokesGainedValue: UILabel!
    @IBOutlet weak var strokesGainedLabel: UILabel!
    @IBOutlet weak var card3PieChartView: PieChartView!
    @IBOutlet weak var strokesGainedData: UILabel!
    @IBOutlet weak var bestRoundLabel: UILabel!
    @IBOutlet weak var mySwingScoreView: UICircularProgressRingView!
    
    @IBOutlet weak var lblAvgFromLastRounds: UILabel!
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblAvgLastTenRounds: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewCardOne: UIView!
    
    @IBOutlet weak var btnMySwing: UIButton!
    @IBOutlet weak var btnMyScore: UIButton!
    @IBOutlet weak var btnStrokeGained: UIButton!
    
    @IBOutlet weak var moreStatView: UIView!
    @IBOutlet weak var totalScoreLbl: UILabel!
    
    class var reuseIdentifier: String {
        get {
            return "HomeTopTableVIewCell"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblAvgFromLastRounds.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
