//
//  PlayersTableViewCell.swift
//  Golfication
//
//  Created by Khelfie on 25/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class PlayersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playerImage.setCircle(frame: self.playerImage.frame)
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
