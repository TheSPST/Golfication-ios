//
//  TIOADViewController.swift
//  TIOAD
//
//  Created by Rishabh Sood on 19/09/18.
//  Copyright © 2018 Rishabh Sood. All rights reserved.
//

import UIKit
import CoreBluetooth
import FirebaseStorage
class TIOADViewController: UIViewController{
    
    var perip : CBPeripheral!
    var oadImage: TIOADToadImageReader!
    var client: TIOADClient!
    var deviceSelected: Bool!
    
    @IBOutlet weak var TIOADProgress: UIProgressView!
    @IBOutlet weak var TIOADCurrentStatus: UILabel!
    @IBOutlet weak var TIOADOADImage: UILabel!
    @IBOutlet weak var TIOADCurrentBlock: UILabel!
    @IBOutlet weak var TIOADTotalBlock: UILabel!
    @IBOutlet weak var TIOADMTUSize: UILabel!
    @IBOutlet weak var TIOADBlockSize: UILabel!
    @IBOutlet weak var TIOADImageInfo: UITextView!
    @IBOutlet weak var TIOADChipID: UILabel!
    @IBOutlet weak var TIOADTotalBytes: UILabel!
    @IBOutlet weak var TIOADCurrentByte: UILabel!
    @IBOutlet weak var TIOADActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var TIOADStartScanButton: UIButton!
    
    @IBOutlet weak var golfXPopupView: UIView!
    @IBOutlet weak var  deviceCircularView: CircularProgress!
    @IBOutlet weak var lblUpdateFirmware: UILabel!
    @IBOutlet weak var lblBottomInfo: UILabel!
    @IBOutlet weak var btnProceed: UIButton!

    var prevVal: Float = 0.0
    
    //    let urlStr = "https://firebasestorage.googleapis.com/v0/b/golfication-4f97b.appspot.com/o/OADUpdates%2Ffirmware_v0.00.bin?alt=media&token=14c90409-fdc0-4712-96c8-83fca595fb10"
    let fileName = "Khelfie_project2_FlashROM_oad_merged-2.bin"
    
    //let urlStr1 = "https://firebasestorage.googleapis.com/v0/b/golfication-4f97b.appspot.com/o/OADUpdates%2FKhelfie_project2_FlashROM_oad1_merged.bin?alt=media&token=31ee2200-82e3-4214-8c44-e335f91b2488"
    //    let fileName1 = "Khelfie_project2_FlashROM_oad1_merged.bin"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OAD"
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        TIOADStartScanButton.setTitle("Downoad File", for: .normal)
        self.TIOADActivityIndicator.startAnimating()
        self.TIOADProgress.isHidden = true
        self.TIOADStartScanButton.isEnabled = false
        
        btnProceed.isHidden = true
        btnProceed.setCorner(color: UIColor.clear.cgColor)
        deviceCircularView.progressColor = UIColor.glfBluegreen
        deviceCircularView.trackColor = UIColor.clear
        deviceCircularView.progressLayer.lineWidth = 3.0
        self.lblUpdateFirmware.text = "Updating Firmware 0%"
        let storage = Storage.storage(url:"gs://golficationtest.appspot.com")
        let pathReference = storage.reference(withPath:"OADUpdates/\(self.fileName)")
        pathReference.downloadURL { url, error in
            if let error = error {
                debugPrint(error)
                
                let alertVC = UIAlertController(title: "Error", message: "Could not download Firmware File.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.deviceSelected = false
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url!){
                        DispatchQueue.main.async {
                            debugPrint(data)
                            
                            self.oadImage = TIOADToadImageReader(imageData: data, fileName: self.fileName)
                            self.TIOADOADImage.text = self.fileName
                            
                            self.TIOADImageInfo.text = self.oadImage.description
                            
                            self.TIOADActivityIndicator.stopAnimating()
                            self.TIOADProgress.isHidden = false
                            
                            self.TIOADStartScanButton.isEnabled = true
                            self.startUpdate()
                        }
                    }
                    else{
                        let alertVC = UIAlertController(title: "Error", message: "Could not download Firmware File.", preferredStyle: UIAlertController.Style.alert)
                        let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
                        alertVC.addAction(action)
                        self.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func startUpdate(){
        if (!deviceSelected!) {
            for s:CBService in Constants.deviceGolficationX.services! where s.uuid.uuidString == TI_OAD_SERVICE{
                debugPrint("Start OAD, we are ready",s)
                NotificationCenter.default.addObserver(self, selector: #selector(self.callAgain(_:)), name: NSNotification.Name(rawValue: "getSwingInside"), object: nil)
                DispatchQueue.main.async {
                    self.client = TIOADClient(peripheral: Constants.deviceGolficationX, andImageData: self.oadImage, andDelegate: self)
                    self.TIOADMTUSize.text = "\(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse))"
                    self.TIOADBlockSize.text = "\(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)-4)"
                    self.deviceSelected = true
                    self.TIOADStartScanButton.setTitle("Start Updating", for: .normal)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getSwingInside"),object: nil)
                }
            }
        }
        else {
            client.startOAD()
            self.TIOADActivityIndicator.startAnimating()
            self.TIOADProgress.isHidden = true
            NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "getSwingInside"))
        }
    }
    @objc func callAgain(_ notification:NSNotification){
        self.startUpdate()
    }
    @IBAction func TIOADStartScanButtonTouched(_ sender: Any) {
        if (!deviceSelected!) {
            for s:CBService in Constants.deviceGolficationX.services! where s.uuid.uuidString == TI_OAD_SERVICE{
                debugPrint("Start OAD, we are ready",s)
                DispatchQueue.main.async {
                    self.client = TIOADClient(peripheral: Constants.deviceGolficationX, andImageData: self.oadImage, andDelegate: self)
                    self.TIOADMTUSize.text = "\(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse))"
                    self.TIOADBlockSize.text = "\(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)-4)"
                    self.deviceSelected = true
                    self.TIOADStartScanButton.setTitle("Start Updating", for: .normal)
                }
            }
        }
        else {
            client.startOAD()
            self.TIOADActivityIndicator.startAnimating()
            self.TIOADProgress.isHidden = true
        }
    }
    @IBAction func proceedAction(_ sender: Any) {
        let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarCtrl
    }
}

extension TIOADViewController: TIOADClientProgressDelegate{
    func client(_ client: TIOADClient!, oadProgressUpdated progress: TIOADClientProgressValues_t) {
        DispatchQueue.main.async {
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
            
            if self.prevVal < (Float(progress.currentByte)/Float(progress.totalBytes)){
                self.deviceCircularView.setProgressWithAnimationGolfX(duration: 0.0, fromValue: self.prevVal, toValue: Float(progress.currentByte)/Float(progress.totalBytes))
                self.lblUpdateFirmware.text = "Updating Firmware" + " \(Int((Float(progress.currentByte)/Float(progress.totalBytes))*100))%"
            }
            self.prevVal = (Float(progress.currentByte)/Float(progress.totalBytes))
        }
    }
    
    func client(_ client: TIOADClient!, oadProcessStateChanged state: TIOADClientState_t, error: Error!) {
        debugPrint("State changed :",Int(Float(state.rawValue)))
        debugPrint("Error: ",error);
        DispatchQueue.main.async {
            
            if ((state == tiOADClientGetDeviceTypeResponseRecieved) && error == nil) {
                self.TIOADStartScanButton.isEnabled = true
                self.TIOADChipID.text = client.getChipId()
            }
            if let status = TIOADClient.getStateString(from: state){
                if status.contains("Feedback complete OK"){
                    Constants.OADFeedback = true
                    self.lblBottomInfo.text = "Firmware Update Complete."
                    self.btnProceed.isHidden = false

                    /*let alertVC = UIAlertController(title: "Alert", message: "Firmware Updated Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                        self.dismiss(animated: true, completion: nil)
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                    alertVC.addAction(action)
                    self.present(alertVC, animated: true, completion: nil)*/
                }
            }
            self.TIOADCurrentStatus.text = TIOADClient.getStateString(from: state)
            
            if ((error) != nil){
                debugPrint("EOAD_Process_failed",(error.localizedDescription))
                if !error.localizedDescription.contains("Unknown error code during"){
                    let alertVC = UIAlertController(title: "Error", message: "EOAD Process failed with error: \(error.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
                    alertVC.addAction(action)
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
}
