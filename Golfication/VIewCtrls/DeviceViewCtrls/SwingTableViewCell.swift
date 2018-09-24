//
//  SwingTableViewCell.swift
//  Golfication
//
//  Created by Khelfie on 20/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import UICircularProgressRing

class SwingTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var lblSubtitle2: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var clubImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var swingProgressView: UICircularProgressRingView!
    override func awakeFromNib() {
        super.awakeFromNib()
        swingProgressView.isHidden = true
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
