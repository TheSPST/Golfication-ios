//
//  ScoreTableViewCell.swift
//  Golfication
//
//  Created by IndiRenters on 12/5/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblStartingPoint: UILabel!
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblStrokesGained: UILabel!
    @IBOutlet weak var lblScoreInPercentage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
