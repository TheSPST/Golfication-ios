//
//  UpdateDeviceFrameworkViewCtrl.swift
//  Golfication
//
//  Created by Khelfie on 25/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import CoreBluetooth

class UpdateDeviceFrameworkViewCtrl: UIViewController {
    
    @IBOutlet weak var lblConnected: UILabel!
    @IBOutlet weak var lblDownloaded: UILabel!
    @IBOutlet weak var lblUploaded: UILabel!
    let urlStr = "https://firebasestorage.googleapis.com/v0/b/golfication-4f97b.appspot.com/o/simple_peripheral_cc2640r2lp_oad_offchip_app_FlashROM.hex?alt=media&token=b61ba02c-6856-472e-9191-4356ff5e7e8d"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - btnAction
    @IBAction func btnActionConnect(_ sender: UIButton) {
        ble = BLE()
        ble.startScanning()
        lblConnected.text = "Connected"
    }
    @IBAction func btnActionDownload(_ sender: UIButton) {
        let url = URL(string: urlStr)
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){
                DispatchQueue.main.async {
                    debugPrint(data)
                    let hex = String(data: data, encoding: .utf8)
                    debugPrint(hex!)
                    self.writeImageWithHeader(hex:hex!)
                }
            }
        }
    }
    func writeImageWithHeader(hex:String){

        let img = FirmwareImage(hexString: hex)
        debugPrint(img)
        let headerData = img.imgIdentifyRequestData()
//        deviceGolficationX.writeValue(headerData, for: oadCharacteristicHeader!, type: .withResponse)
        debugPrint(img.nBlocks)

        let NUM_BLOCK_PER_CONNECTION = 2   // send 4, 16 byte blocks per connection
//        let BLOCK_TRANSFER_INTERVAL  = 0.1  // every 100ms
        for _ in 0..<NUM_BLOCK_PER_CONNECTION {
            if let blockData = img.nextBlock() {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    debugPrint("blockData:\(blockData)")
//                    deviceGolficationX.writeValue(blockData, for: oadCharacteristicBlock!, type: .withoutResponse)
//                })
         } else {
                debugPrint("Error in writing")
                break
            }
        }
    }
    @IBAction func btnActionUpload(_ sender: UIButton) {
//        if (charctersticsGlobalForWrite != nil){
//
//
//
//
//            let param : [UInt8] = [3,4,5,6,7]
//            let writeData =  Data(bytes: param)
//            deviceGolficationX.writeValue(writeData as Data, for: charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
//            let timerForWriteCommand = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
//                let writeData =  Data(bytes: param)
//                deviceGolficationX.writeValue(writeData as Data, for: charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
//            })
//        }else{
//            let alertVC = UIAlertController(title: "Alert", message: "No Service Found", preferredStyle: UIAlertControllerStyle.alert)
//            let action = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
    //        alertVC.addAction(action)
//            self.present(alertVC, animated: true, completion: nil)
//        }
        
        
        
    }
}
