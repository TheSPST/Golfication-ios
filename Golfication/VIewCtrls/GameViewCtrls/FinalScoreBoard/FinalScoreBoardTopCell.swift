//
//  FinalScoreBoardTopCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 09/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class FinalScoreBoardTopCell: UITableViewCell {

    @IBOutlet weak var btnHoleByHole: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var topHdrView: UIView!
    @IBOutlet weak var  btnViewScore: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblPar: UILabel!
    @IBOutlet weak var lblThru: UILabel!
    @IBOutlet weak var lblStrokes: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.setCircle(frame: userImageView.frame)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
