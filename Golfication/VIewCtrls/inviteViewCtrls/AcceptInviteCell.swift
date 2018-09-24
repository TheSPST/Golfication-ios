//
//  AcceptInviteCell.swift
//  Golfication
//
//  Created by Khelfie on 29/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class AcceptInviteCell: UITableViewCell {
    @IBOutlet weak var btnPlayerImage: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblPlayerStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnPlayerImage.setCircle(frame: btnPlayerImage.frame)
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
