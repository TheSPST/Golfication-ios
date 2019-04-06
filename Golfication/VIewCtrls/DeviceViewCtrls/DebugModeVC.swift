//
//  DebugModeVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
class DebugModeVC: UIViewController{
    var debugDataArray = [DebugData]()
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnDebug: UIButton!
    var progressView = SDLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Debug Golfication X"
        btnDebug.setCorner(color: UIColor.glfBlack40.cgColor)
        NotificationCenter.default.addObserver(self, selector: #selector(self.debugFinish(_:)), name: NSNotification.Name(rawValue: "DebugRunning"), object: nil)
    }
    
    @objc func debugFinish(_ notification:NSNotification){
        if let data = notification.object as? [UInt8]{
            convertAccel(value: data)
        }else if let obj = notification.object as? String{
            if obj.contains(find: "Finish"){
                DispatchQueue.main.async( execute: {
                    let gameAlert = UIAlertController(title: "Recording Complete", message: "Your data was recorded successfully. Please press Send to send this data for analysis.", preferredStyle: UIAlertControllerStyle.alert)
                    gameAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction!) in
                        self.progressView.show(atView: self.view, navItem: self.navigationItem)
                        var dataArr = [NSMutableDictionary]()
                        for data in self.debugDataArray{
                            let dict = NSMutableDictionary()
                            dict.setValue(data.x, forKey: "x")
                            dict.setValue(data.y, forKey: "y")
                            dict.setValue(data.z, forKey: "z")
                            dict.setValue(data.a, forKey: "a")
                            dict.setValue(data.b, forKey: "b")
                            dict.setValue(data.c, forKey: "c")
                            dict.setValue(data.g1, forKey: "g1")
                            dict.setValue(data.g2, forKey: "g2")
                            dict.setValue(data.g3, forKey: "g3")
                            dict.setValue(data.time, forKey: "timestamp")
                            dataArr.append(dict)
                        }
                        ref.child("deviceDebug/\(Auth.auth().currentUser!.uid)/").updateChildValues(["\(Timestamp)":dataArr]) { (e, re) in
                            self.progressView.hide(navItem: self.navigationItem)
                            self.debugDataArray.removeAll()
                            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DebugRunning"), object: nil)
                            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = tabBarCtrl
                            
                            let alert = UIAlertController(title: "Data Submitted", message: "Thanks for uploading data, we will get back to you soon.".localized(), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { [weak alert] (_) in
                                debugPrint("Cancel Alert: \(alert?.title ?? "")")
                            }))
                            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    }))
                    gameAlert.addAction(UIAlertAction(title: "Discard".localized(), style: .default, handler: { (action: UIAlertAction!) in
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DebugRunning"), object: nil)
                        self.lblTimer.text = "15:00"
                    }))
                    self.present(gameAlert, animated: true, completion: nil)
                    
                })
            }
        }else{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DebugRunning"), object: nil)
        }
    }
    
    func convertAccel(value:[UInt8]) {
        var x : Float = 0.0
        var y : Float = 0.0
        var z : Float = 0.0
        var a : Float = 0.0
        var b : Float = 0.0
        var c : Float = 0.0
        
        if (Int(value[0])>50){
            let val1 = Float(value[0])-255.0
            let val2 = Float(Int(value[1])>100 ? (Int(value[1])-256):Int(value[1]))/100.0
            x = Float(val1)+val2
        }else {
            let val1 = Float(value[0])
            let val2 = Float(Int(value[1])>100 ? (Int(value[1])-256):Int(value[1]))/100.0
            x = val1+val2
        }
        
        if (Int(value[2])>50){
            let val1 = Float(value[2])-255.0
            let val2 = Float(Int(value[3])>100 ? (Int(value[3])-256):Int(value[3]))/100.0
            y = val1+val2
        }else {
            let val1 = Float(value[2])
            let val2 = Float(Int(value[3])>100 ? (Int(value[3])-256):Int(value[3]))/100.0
            y = val1+val2
        }
        
        if (Int(value[4])>50){
            let val1 = Float(value[4])-255.0
            let val2 = Float(Int(value[5])>100 ? (Int(value[5])-256):Int(value[5]))/100.0
            z = val1+val2
        }else {
            let val1 = Float(value[4])
            let val2 = Float(Int(value[5])>100 ? (Int(value[5])-256):Int(value[5]))/100.0
            z = val1+val2
        }
        
        if (Int(value[6])>50){
            let val1 = Float(value[6])-255.0
            let val2 = Float(Int(value[7])>100 ? (Int(value[7])-256):Int(value[7]))/100.0
            a = val1+val2;
        }else {
            let val1 = Float(value[6])
            let val2 = Float(Int(value[7])>100 ? (Int(value[7])-256):Int(value[7]))/100.0
            a = Float(val1)+val2
        }
        
        if (Int(value[8])>50){
            let val1 = Float(value[8])-255.0
            let val2 = Float(Int(value[9])>100 ? (Int(value[9])-256):Int(value[9]))/100.0
            b = val1+val2
        }else {
            let val1 = Float(value[8])
            let val2 = Float(Int(value[9])>100 ? (Int(value[9])-256):Int(value[9]))/100.0
            b = Float(val1)+val2
        }
        
        if (Int(value[10])>50){
            let val1 = Float(value[10])-255.0
            let val2 = Float(Int(value[11])>100 ? (Int(value[11])-256):Int(value[11]))/100.0
            c = val1+val2
        }else {
            let val1 = Float(value[10])
            let val2 = Float(Int(value[11])>100 ? (Int(value[11])-256):Int(value[11]))/100.0
            c = val1+val2
        }
        
        let g1 = Float(Int(value[12]) > 100 ? (Int(value[12])-256):(Int(value[12]))) + Float(Int(value[13]) > 100 ? (Int(value[13])-256) : Int(value[13]))*100.0
        let g2 = Float(Int(value[14]) > 100 ? (Int(value[14])-256):(Int(value[14]))) + Float(Int(value[15]) > 100 ? (Int(value[15])-256) : Int(value[15]))*100.0
        let g3 = Float(Int(value[16]) > 100 ? (Int(value[16])-256):(Int(value[16]))) + Float(Int(value[17]) > 100 ? (Int(value[17])-256) : Int(value[17]))*100.0
        
        if (x.isNaN){ x=0}
        if (y.isNaN){ y=0}
        if (z.isNaN){ z=0}
        if (a.isNaN){ a=0}
        if (b.isNaN){ b=0}
        if (c.isNaN){ c=0}
        
        let debugDa = DebugData(x: x, y: y, z: z, a: a, b: b, c: c, g1: g1, g2: g2, g3: g3, time: Timestamp)
        self.debugDataArray.append(debugDa)
    }
    @IBAction func startDebugAction(_ sender: UIButton) {
        if Constants.ble != nil && Constants.deviceGolficationX != nil{
            btnDebug.isEnabled = false
            Constants.ble.sendforteenCommand()
            var tim = 1
            var totalTime = 1500
            let _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (t) in
                self.lblTimer.text = "\(totalTime/100):\(100-tim)"
                tim += 1
                if tim == 100{
                    totalTime -= 100
                    tim = 0
                }
                if totalTime == 0{
                    self.lblTimer.text = "00:00"
                    t.invalidate()
                    self.btnDebug.isEnabled = true
                }
            }
        }
    }
    
}
