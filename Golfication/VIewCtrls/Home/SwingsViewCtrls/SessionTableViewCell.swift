//
//  SessionTableViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 30/10/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import UICircularProgressRing

class SessionTableViewCell: UITableViewCell {
    @IBOutlet weak var sessionCircularVw: UICircularProgressRingView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAvg: UILabel!
    @IBOutlet weak var lblSwingClub: UILabel!
    @IBOutlet weak var avgCircleView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureWithItem(rounds: RoundsWithSection) {
//        var swingTitle = "Swings"
//        var clubTitle = "Clubs"
        
//        self.sessionCircularVw.setProgress(value: CGFloat(rounds.rows.avgScore!), animationDuration: 1.0)
//        self.lblTitle.text = "\(rounds.row.date!), \(rounds.row.roundName!)"
//        if rounds.row.numSwings == 1{
//            swingTitle = "Swing"
//        }
//        if(rounds.row.clubs == 1){
//            clubTitle = "Club"
//        }
//        self.lblSubTitle.text = "\(rounds.numSwings ?? 0) \(swingTitle), \(rounds.clubs ?? 0) \(clubTitle)"
    }
    
}
