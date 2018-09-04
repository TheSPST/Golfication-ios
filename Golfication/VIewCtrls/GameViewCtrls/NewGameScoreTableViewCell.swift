//
//  NewGameScoreTableViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 19/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class NewGameScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPlayer: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblPar: UILabel!
    @IBOutlet weak var lblThru: UILabel!
    @IBOutlet weak var lblStrokes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPlayer.setCircle(frame: imgPlayer.frame)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
