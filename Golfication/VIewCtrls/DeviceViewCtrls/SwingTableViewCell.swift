//
//  SwingTableViewCell.swift
//  Golfication
//
//  Created by Khelfie on 20/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
class SwingTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var lblSubtitle2: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblScore.setCircle(frame:lblScore.frame)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
