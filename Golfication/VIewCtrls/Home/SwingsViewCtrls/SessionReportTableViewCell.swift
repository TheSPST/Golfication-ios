//
//  SessionReportTableViewCell.swift
//  Golfication
//
//  Created by IndiRenters on 10/31/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import UICircularProgressRing
import Charts

class SessionReportTableViewCell: UITableViewCell {
    

    @IBOutlet weak var sessionReportBarChartView: BarChartView!
    @IBOutlet weak var sessionCircularVw: UICircularProgressRingView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureWithItem(swing: Swings) {
        self.sessionCircularVw.setProgress(value: CGFloat(swing.score), animationDuration: 1.0)
        self.lblTitle?.text = "#\(swing.count!) | \(swing.club!) | Full Swings"
        let date = NSDate(timeIntervalSince1970:(swing.timestamp)/1000)
        self.lblSubTitle?.text = date.toString(dateFormat: "hh:mm a")

    
    }
}
