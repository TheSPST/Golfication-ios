//
//  TogetherTopVIewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Charts
class TogetherTopVIewCell: UITableViewCell {

    @IBOutlet weak var lblAvrgFromLastRounds: UILabel!
    @IBOutlet weak var cardViewScore: CardView!
    @IBOutlet weak var swingsRankValue: UILabel!
    @IBOutlet weak var roundPlayerRankValue: UILabel!
    @IBOutlet weak var strokesGainedPuttingRankValue: UILabel!
    @IBOutlet weak var totalScorePercentileBar: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
