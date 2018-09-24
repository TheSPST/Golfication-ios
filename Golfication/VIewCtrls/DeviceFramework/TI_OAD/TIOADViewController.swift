//
//  TIOADViewController.swift
//  TIOAD
//
//  Created by Rishabh Sood on 19/09/18.
//  Copyright © 2018 Rishabh Sood. All rights reserved.
//

import UIKit
import CoreBluetooth

class TIOADViewController: UIViewController{

    var perip : CBPeripheral!
    var deviceList = NSMutableArray()
    
    var oadImage: TIOADToadImageReader!
    var client: TIOADClient!
    var deviceSelected: Bool!
    var man: CBCentralManager!

    @IBOutlet weak var TIOADProgress: UIProgressView!
    @IBOutlet weak var TIOADCurrentStatus: UILabel!
    @IBOutlet weak var TIOADOADImage: UILabel!
    @IBOutlet weak var TIOADCurrentBlock: UILabel!
    @IBOutlet weak var TIOADTotalBlock: UILabel!
    @IBOutlet weak var TIOADMTUSize: UILabel!
    @IBOutlet weak var TIOADBlockSize: UILabel!
    @IBOutlet weak var TIOADImageInfo: UITextView!
    @IBOutlet weak var TIOADDevicesFoundTableView: UITableView!
    @IBOutlet weak var TIOADChipID: UILabel!
    @IBOutlet weak var TIOADTotalBytes: UILabel!
    @IBOutlet weak var TIOADCurrentByte: UILabel!
    @IBOutlet weak var TIOADActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var TIOADStartScanButton: UIButton!
    
    let urlStr = "https://firebasestorage.googleapis.com/v0/b/golfication-4f97b.appspot.com/o/OADUpdates%2FKhelfie_project2_FlashROM_oad_merged.bin?alt=media&token=867a96d2-3b58-43e0-bb4d-a7428da056e9"
    let fileName = "Khelfie_project2_FlashROM_oad_merged.bin"
    
    //let urlStr1 = "https://firebasestorage.googleapis.com/v0/b/golfication-4f97b.appspot.com/o/OADUpdates%2FKhelfie_project2_FlashROM_oad1_merged.bin?alt=media&token=31ee2200-82e3-4214-8c44-e335f91b2488"
//    let fileName1 = "Khelfie_project2_FlashROM_oad1_merged.bin"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OAD"
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        man = CBCentralManager(delegate: self, queue: nil)

        self.TIOADActivityIndicator.startAnimating()
        self.TIOADProgress.isHidden = true
        self.TIOADStartScanButton.isEnabled = false

        let url = URL(string: urlStr)
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){
                DispatchQueue.main.async {
                    debugPrint(data)
                    
                    self.oadImage = TIOADToadImageReader(imageData: data, fileName: self.fileName)
                    self.TIOADOADImage.text = self.fileName
                    
                    self.TIOADImageInfo.text = self.oadImage.description
                    self.TIOADDevicesFoundTableView.delegate = self
                    self.TIOADDevicesFoundTableView.dataSource = self
                    self.deviceList = NSMutableArray()
                    self.deviceSelected = false

                    self.TIOADActivityIndicator.stopAnimating()
                    self.TIOADProgress.isHidden = false
                    self.TIOADStartScanButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func TIOADStartScanButtonTouched(_ sender: Any) {
        if (!deviceSelected) {
            self.deviceList = NSMutableArray()
            deviceSelected = false
            self.TIOADDevicesFoundTableView.reloadData()
            man = CBCentralManager(delegate: self, queue: nil)
        }
        else {
            client.startOAD()
            self.TIOADActivityIndicator.startAnimating()
            self.TIOADProgress.isHidden = true
        }
    }
}

extension TIOADViewController : CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn) {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (RSSI.intValue > -80) {
            var found = false
            for  ii in 0..<self.deviceList.count {
                let cell = self.deviceList[ii] as! TIOADDeviceTableViewCell
                if (cell.p.identifier == peripheral.identifier) {
                    found = true
                }
            }
            if (!found) {
                let nib = Bundle.main.loadNibNamed("TIOADDeviceTableViewCell", owner: self, options: nil)! as NSArray

                let cell = nib.object(at: 0) as! TIOADDeviceTableViewCell
                cell.p = peripheral
                cell.deviceNameLabel.text = peripheral.name
                cell.deviceUUIDLabel.text = peripheral.identifier.uuidString
                self.deviceList.add(cell)
                self.TIOADDevicesFoundTableView.reloadData()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        perip = peripheral
        perip.delegate = self
        peripheral.discoverServices([CBUUID(string: TI_OAD_SERVICE)])
//        [peripheral discoverServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:TI_OAD_SERVICE], nil]];

    }
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//
//    }
}

extension TIOADViewController : CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s:CBService in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: s)
        }
//        for (CBService *s in peripheral.services) {
//            [peripheral discoverCharacteristics:nil forService:s];
//        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if (service.uuid.uuidString == TI_OAD_SERVICE) {
            debugPrint("Start OAD, we are ready")
            
            client = TIOADClient(peripheral: peripheral, andImageData: oadImage, andDelegate: self)
            
            self.TIOADMTUSize.text = "\(peripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse))"
            self.TIOADBlockSize.text = "\(peripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)-4)"
        }
    }
    /*func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
    }*/
}

extension TIOADViewController: TIOADClientProgressDelegate{
    func client(_ client: TIOADClient!, oadProgressUpdated progress: TIOADClientProgressValues_t) {
        
        debugPrint("Progress update: ")
        debugPrint("Block \(progress.currentBlock) of  \(progress.totalBlocks)")
        debugPrint("Byte \(progress.currentByte) og  \(progress.totalBytes)")

        debugPrint("Progress:",String(format: "%.1f", (Float(progress.currentByte)/Float(progress.totalBytes))))
        
        self.TIOADActivityIndicator.stopAnimating()
        self.TIOADProgress.isHidden = false
        
        self.TIOADTotalBlock.text = "\(progress.totalBlocks)"
        self.TIOADCurrentBlock.text = "\(progress.currentBlock)"
        self.TIOADTotalBytes.text = "\(progress.totalBytes)"
        self.TIOADCurrentByte.text = "\(progress.currentByte)"

        self.TIOADProgress.progress = Float(progress.currentByte)/Float(progress.totalBytes)
    }
    
    func client(_ client: TIOADClient!, oadProcessStateChanged state: TIOADClientState_t, error: Error!) {
        debugPrint("State changed :",Int(Float(state.rawValue)))
        debugPrint("Error: ",error);
        
        if ((state == tiOADClientGetDeviceTypeResponseRecieved) && error == nil) {
            self.TIOADStartScanButton.isEnabled = true
            self.TIOADChipID.text = client.getChipId()
        }
        self.TIOADCurrentStatus.text = TIOADClient.getStateString(from: state)
        
        if ((error) != nil) {
            debugPrint("EOAD_Process_failed",(error.localizedDescription))
            let alertVC = UIAlertController(title: "Error", message: "EOAD Process failed with error: \(error.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
            alertVC.addAction(action)
          self.present(alertVC, animated: true, completion: nil)
        }
    }
}

extension TIOADViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.deviceList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.deviceList[indexPath.row] as! TIOADDeviceTableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = self.deviceList[indexPath.row] as! TIOADDeviceTableViewCell
        man.connect(cell.p, options: nil)
        deviceSelected = true
        self.TIOADStartScanButton.isEnabled = false
        self.TIOADStartScanButton.setTitle("Start Programming", for: .normal)
    }
}
