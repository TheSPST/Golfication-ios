//
//  TIOADDeviceTableViewCell.swift
//  TIOAD
//
//  Created by Rishabh Sood on 19/09/18.
//  Copyright © 2018 Rishabh Sood. All rights reserved.
//

import UIKit
import CoreBluetooth

class TIOADDeviceTableViewCell: UITableViewCell {

    var p: CBPeripheral!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceUUIDLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
