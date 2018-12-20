//
//  BLE.swift
//  Golfication
//
//  Created by Khelfie on 15/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import CoreBluetooth
import FirebaseAuth
import GoogleMaps
import AVFoundation

class BLE: NSObject {
    var locationManager = CLLocationManager()
    var isFinishGame = false
    var isDeviceSetup = false
    var packetOneFlagC8 = false
    var swingMatchId = String()
    var isDeviceStillConnected = false
    var counter : UInt8 = 0
    var clubsArr = [String]()
    var tagClubNumber = [(tag:Int ,club:Int,clubName:String)]()
//    var activeMatchId = String()
    //    let progressView = SDLoader()
    var timerForService = Timer()
    var timerForWriteCommand1 = Timer()
    var timerForWriteCommand21 = Timer()
    var timerForWriteCommand22 = Timer()
    var timerForWriteCommand3 = Timer()
    var timerForWriteCommand4 = Timer()
    var timerForWriteCommand5 = Timer()
    var timerForWriteCommand61 = Timer()
    var timerForWriteCommand62 = Timer()
    var timerForWriteCommand7 = Timer()
    var timerForWriteCommand8 = Timer()
    var timerForWriteCommand9 = Timer()
    var timerForWriteCommand11 = Timer()
    var totalClub : UInt8!
    var centerPointOfTeeNGreen = [(tee:CLLocationCoordinate2D ,fairway:CLLocationCoordinate2D, green:CLLocationCoordinate2D,par:Int)]()
    var isFinished = false
    var shotNo = 1
    var holeNo = 0
    var backSwing : Float = 0.0
    var downSwing : Float = 0.0
    var handVelocity :Float = 0.0
    var clubVelocity :Float = 0.0
    var backAngle:Float = 0.0
    var lat :Float = 0.0
    var lng :Float = 0.0
    var totalTagInFirstPackate = 0
    var leftOrRight : Int!
    var metric: Int!
    var isFirst = false
    var swingDetails = [(shotNo:Int,bs:Double,ds:Double,hv:Double,cv:Double,ba:Double,tempo:Double,club:String,time:Int64,hole:Int)]()
    var holeWithSwing = [(hole:Int,shotNo:Int,club:String,lat:Double,lng:Double,holeOut:Bool)]()
    let golficationXServiceCBUUID_READ = CBUUID(string: "0000AA80-0000-1000-8000-00805F9B34FB")
    let golficationXCharacteristicCBUUIDRead = CBUUID(string:"0000AA81-0000-1000-8000-00805F9B34FB")
    var shotCount = Int()
    let golficationXServiceCBUUID_Write = CBUUID(string: "0000BABE-0000-1000-8000-00805F9B34FB")
    let golficationXCharacteristicCBUUIDWrite = CBUUID(string: "0000BEEF-0000-1000-8000-00805F9B34FB")
    
    let golficationXCharacteristicCBUUIDOAD = CBUUID(string: TI_OAD_SERVICE)

    var totalHoleNumber = Int()
    var isPracticeMatch = false
    var currentGameId = Int()
    var centralManager: CBCentralManager!
    var pManager = CBPeripheralManager()
    var charctersticsWrite : CBCharacteristic!
    var charctersticsRead : CBCharacteristic!
    var service_Read : CBService!
    var service_Write: CBService!
    var currentCommandData = [UInt8]()
    var totalNumberOfClubSend : UInt8!
    var clubData = [(name:String,max:Int,min:Int)]()
    var tempFor7th = Int()
    var peripheralDevicesIn5Sec = NSMutableDictionary()
    var isSetupScreen = false
    var isContinue = false
    var player: AVAudioPlayer?
    var gameIDArr : [UInt8]!
    var oldLatLng = CLLocationCoordinate2D()
    var isProperConnected:Bool!{
        var isTrue = false
        if(Constants.deviceGolficationX != nil) && self.service_Read != nil && self.service_Write != nil{
            isTrue = true
        }
        return isTrue
    }
    var allClubs = ["Dr","3w","4w","5w","7w","1i","2i","3i","4i","5i","6i","7i","8i","9i","1h","2h","3h","4h","5h","6h","7h","Pw","Gw","Sw","Lw","Pu"]

    func startScanning(){
        self.isContinue = false
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        if(isProperConnected){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
        }else{
            let centralQueue = DispatchQueue(label: "bg_golficationX", attributes: [])
            self.centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        }
        if Constants.bleObserver == 0{
            self.setupObserver()
        }
    }
    
    private func setupObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(sendSecondCommand(_:)), name: NSNotification.Name(rawValue: "command2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendEightCommand(_:)), name: NSNotification.Name(rawValue: "command8"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendThirdCommandFromMap(_:)), name: NSNotification.Name(rawValue: "command3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startMatchCalling(_:)), name: NSNotification.Name(rawValue: "startMatchCalling"), object: nil)
        Constants.bleObserver += 1
    }
    func stopScanning(){
        if centralManager != nil{
            self.centralManager.stopScan()
        }
    }
    @objc func startMatchCalling(_ notification: NSNotification){
        if let isPractice = notification.object as? Bool{
            self.isFirst = false
            if(isPractice){
                self.isPracticeMatch = true
                if(self.swingMatchId.count == 0){
                    self.startMatch(isPractice: isPractice)
                }else{
                    self.sendFifthCommand()
                }
            }
        }
    }
//    func  randomIntVelocity(max:Int,min:Int) -> Int{
//        let rndom = arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min)
//        return Int(rndom)
//    }
    func randomGenerator(){
        let newCounter = UInt8(arc4random_uniform(254) + 1)
        if(self.counter == newCounter){
            self.counter = newCounter+1
        }else{
            self.counter = newCounter
        }
    }
    func invalidateAllTimers(){
        self.timerForService.invalidate()
        self.timerForWriteCommand1.invalidate()
        self.timerForWriteCommand21.invalidate()
        self.timerForWriteCommand22.invalidate()
        self.timerForWriteCommand3.invalidate()
        self.timerForWriteCommand4.invalidate()
        self.timerForWriteCommand5.invalidate()
        self.timerForWriteCommand61.invalidate()
        self.timerForWriteCommand62.invalidate()
        self.timerForWriteCommand7.invalidate()
        self.timerForWriteCommand8.invalidate()
        self.timerForWriteCommand9.invalidate()
        self.timerForWriteCommand11.invalidate()
    }
    public static func getData(value: [UInt8]) -> [Float] {
        var returnArray :[Float] = [0.0,0.0,0.0,0.0,0.0]
        if (value.count<=18) {
            var x: Float = Float()
            memccpy(&x, [value[0],value[1],value[2],value[3]], 4, 4)
            var y : Float = Float()
            memccpy(&y, [value[4],value[5],value[6],value[7]], 4, 4)
            var z : Float = Float()
            memccpy(&z, [value[8],value[9],value[10],value[11]], 4, 4)
            var t : Float = Float()
            memccpy(&t, [value[12],value[13],value[14],value[15]], 4, 4)
            returnArray.removeAll()
            returnArray.append(x)
            returnArray.append(y)
            returnArray.append(z)
            returnArray.append(t)
        }
        return returnArray
    }
    
    func byteArrayToInt (value :[UInt8])->Int{
        var newInt : Int = Int(value[0])
        newInt += Int(value[1])*256
        newInt += Int(value[2])*256*256
        newInt += Int(value[3])*256*256*256
        return newInt
    }
    func byteArrayToInt32 (value :[UInt8])->Int{
        var newInt : Int = Int(value[0])
        newInt += Int(value[1])*256
        return newInt
    }
    
    func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
    func forPrintingServices(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if(Constants.deviceGolficationX.services != nil ){
                for service in Constants.deviceGolficationX.services!{
                    if(self.service_Read == service){
                        for char in self.service_Read.characteristics!{
                            debugPrint("CharValue : \(String(describing: char.value))")
                            debugPrint("CharValue : \(char.uuid)")
                        }
                    }
                }
            }else{
                debugPrint("No Service Found")
            }
        })
    }
    
    var timeOut = 0
    func sendFirstCommand(leftOrRight:UInt8,metric:UInt8){
        timeOut = 0
//        debugPrint(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse))
        if(Constants.charctersticsGlobalForWrite != nil){
            invalidateAllTimers()
            self.randomGenerator()
            var data:[UInt8] = [1,counter,leftOrRight, metric]
            self.leftOrRight = Int(leftOrRight)
            self.metric = Int(metric)
            currentCommandData = data
            self.forPrintingServices()
            let writeData =  Data(bytes: data)
            Constants.deviceGolficationX.writeValue(writeData as Data, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.timeOut += 1
            timerForWriteCommand1 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                self.randomGenerator()
                data[1] = self.counter
                self.currentCommandData = data
                let writeData =  Data(bytes: data)
                if(self.timeOut > 3){
                    UIApplication.shared.keyWindow?.makeToast("Request Timeout try again.")
                    self.timerForWriteCommand1.invalidate()
                }else{
                    Constants.deviceGolficationX.writeValue(writeData as Data, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                }
                self.timeOut += 1
            })
        }else{
            UIApplication.shared.keyWindow?.makeToast("No Service found please try again.")
            Constants.deviceGolficationX = nil
        }
    }
//    @objc private func getMatchId(_ notification: NSNotification){
//        if let myDict = notification.object as? String{
//            self.activeMatchId = myDict
//        }
//        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "getMatchId"))
//    }
    private func sendNinthCommand(par:[UInt8]){
        self.randomGenerator()
        self.invalidateAllTimers()
        var param : [UInt8] = [9,counter]
        for i in par{
            param.append(i)
        }
        var writeData = Data()
        self.currentCommandData = param
        writeData =  Data(bytes:param)
        Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
        timerForWriteCommand9 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            var paramData = param
            self.randomGenerator()
            paramData[1] = self.counter
            writeData =  Data(bytes:paramData)
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.currentCommandData = paramData
        })
    }
    @objc private func sendThirdCommandFromMap(_ notification: NSNotification){
        if let myDict = notification.object as? [(tee:CLLocationCoordinate2D ,fairway:CLLocationCoordinate2D, green:CLLocationCoordinate2D,par:Int)]{
            self.centerPointOfTeeNGreen = myDict
            debugPrint(self.centerPointOfTeeNGreen)
        }
        self.sendThirdCommand()
    }
    private func sendEleventhCommand(){
        
        if(Constants.charctersticsGlobalForWrite != nil){
            self.randomGenerator()
            let param : [UInt8] = [11,counter]
            var writeData = Data()
            self.currentCommandData = param
            writeData =  Data(bytes:param)
            var counte = 0
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.timerForWriteCommand11 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                self.randomGenerator()
                let param : [UInt8] = [11,self.counter]
                writeData =  Data(bytes:param)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.currentCommandData = param
                if counte > 2{
                    self.timerForWriteCommand11.invalidate()
                    if !self.isSetupScreen{
                        self.sendThirdCommand()
                    }
                }
                counte += 1
                
                
            })
        }else{
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.makeToast("No Service found or timeout please try again.")
            }
        }
    }
    @objc private func sendSecondCommand(_ notification: NSNotification){
        timeOut = 0
        if(Constants.charctersticsGlobalForWrite != nil) && timeOut < 3{
            if let myDict = notification.object as? [(tag:Int ,club:Int,clubName:String)] {
                tagClubNumber = myDict
                self.clubsArr.removeAll()
                for data in myDict{
                    self.clubsArr.append(data.clubName)
                }
                debugPrint(tagClubNumber)
                self.totalClub = UInt8(myDict.count)
                self.updateMaxMin()
                var paramData : [UInt8] = [2,UInt8(200+myDict.count)]
                self.invalidateAllTimers()
                let writeData =  Data(bytes: paramData)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                timeOut += 1
                currentCommandData = paramData
                timerForWriteCommand21 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    self.randomGenerator()
                    paramData[1] = self.counter
                    self.currentCommandData = paramData
                    let writeData =  Data(bytes: paramData)
                    Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                    self.timeOut += 1
                })
            }
        }else{
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.makeToast("No Service found or timeout please try again.")
            }
        }
    }
    func sendSecondCommand(packet:UInt8){
        timeOut = 0
        if(Constants.charctersticsGlobalForWrite != nil) && timeOut < 3{
            var paramData : [UInt8] = [2,packet]
            var i = 0
            for data in tagClubNumber{
                paramData.append(UInt8(data.club))
                var tagNum = toByteArray(data.tag)
                debugPrint(tagNum.count)
                paramData.append(tagNum[0])
                paramData.append(tagNum[1])
                paramData.append(tagNum[2])
                paramData.append(tagNum[3])
                if(i == 2){
                    break
                }
                i += 1
            }
            if(tagClubNumber.count > i+1){
                tagClubNumber.removeFirst(i+1)
                self.totalTagInFirstPackate += i+1
            }else{
                self.totalTagInFirstPackate = tagClubNumber.count
                tagClubNumber.removeAll()
            }
            
            self.invalidateAllTimers()
            let total = paramData.count
            if(total < 18){
                for _ in 0..<18-total{
                    paramData.append(UInt8(0))
                }
            }
            let writeData =  Data(bytes: paramData)
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            timeOut += 1
            currentCommandData = paramData
            timerForWriteCommand21 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                self.randomGenerator()
                paramData[1] = self.counter
                self.currentCommandData = paramData
                let writeData =  Data(bytes: paramData)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.timeOut += 1
            })
        }else{
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.makeToast("No Service found or timeout please try again.")
            }
        }
    }
    
    func sendThirdCommand(){
        timeOut = 0
        if(Constants.charctersticsGlobalForWrite != nil) && timeOut < 3{
            self.invalidateAllTimers()
            self.randomGenerator()
            var param:[UInt8] = [3,counter]
            let writeData =  Data(bytes: param)
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            timeOut += 1
            self.currentCommandData = param
            timerForWriteCommand3 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                self.randomGenerator()
                param[1] = self.counter
                self.currentCommandData = param
                let writeData =  Data(bytes: param)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.timeOut += 1
            })
        }else{
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.makeToast("No Service found or timeout please try again.")
            }
        }
    }
    func sendFourthCommand(param:[UInt8]?){
        if(Constants.charctersticsGlobalForWrite != nil) && timeOut < 3{
            var writeData = Data()
            self.currentCommandData = param!
            writeData =  Data(bytes:param!)
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            timerForWriteCommand4 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                var paramData = param!
                self.randomGenerator()
                paramData[1] = self.counter
                writeData =  Data(bytes:paramData)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.currentCommandData = paramData
            })
        }else{
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.makeToast("No Service found or timeout please try again.")
            }
        }
    }
    
    private func sendsixthCommand1(){
        self.clubsArr.removeAll()
        for data in Constants.tagClubNum{
            self.clubsArr.append(data.clubName)
        }
        updateMaxMin()
        var param : [UInt8] = [6,200+UInt8(centerPointOfTeeNGreen.count)]
        for i in 0..<centerPointOfTeeNGreen.count where i%2 == 0{
            debugPrint(i)
            param.append(UInt8((centerPointOfTeeNGreen[i].par*10)+(centerPointOfTeeNGreen.count == i+1 ? 0:centerPointOfTeeNGreen[i+1].par)))
        }
        if param.count < 13{
            for _ in 0..<(12 - param.count){
                param.append(0)
            }
        }
        param.append(UInt8(Int(Constants.startingHole)!))
        self.invalidateAllTimers()
        let writeData =  Data(bytes: param)
        Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
        self.currentCommandData = param
        timerForWriteCommand61 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.currentCommandData = param
        })
    }
    private func sendSixthCommand2(value: UInt8){
        let latG = Float(centerPointOfTeeNGreen[Int(value-1)].green.latitude)
        let lngG = Float(centerPointOfTeeNGreen[Int(value-1)].green.longitude)
        debugPrint("Lattitude Green:",latG)
        debugPrint("Longitude Green:",lngG)
        let latT = Float(centerPointOfTeeNGreen[Int(value-1)].tee.latitude)
        let lngT = Float(centerPointOfTeeNGreen[Int(value-1)].tee.longitude)
        debugPrint("Lattitude Tee:",latT)
        debugPrint("Longitude Tee:",lngT)
        let dataArrH = toByteArray(latT)
//        dataArrH.removeLast()
        debugPrint(dataArrH)
        
        let dataArrH1 = toByteArray(lngT)
//        dataArrH1.removeLast()
        debugPrint(dataArrH1)
        
        let dataArrG = toByteArray(latG)
//        dataArrG.removeLast()
        debugPrint(dataArrG)
        
        let dataArrG1 = toByteArray(lngG)
//        dataArrG1.removeLast()
        debugPrint(dataArrG1)
        
        var param :[UInt8] = [6]
        param.append(value)
        for byte in dataArrH{
            param.append(byte)
        }
        for byte in dataArrH1{
            param.append(byte)
        }
        for byte in dataArrG{
            param.append(byte)
        }
        for byte in dataArrG1{
            param.append(byte)
        }
        debugPrint("param For value\(value) :--->  \(param)")
        let writeData =  Data(bytes: param)
        self.invalidateAllTimers()
        Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
        self.currentCommandData = param
        timerForWriteCommand62 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.currentCommandData = param
        })
    }
    @objc private func sendEightCommand(_ notification: NSNotification){
        if(Constants.charctersticsGlobalForWrite != nil){
            var newByteArray = toByteArray(self.currentGameId)
            if let gameId = notification.object as? String{
                if(gameId == "Finish"){
                    newByteArray = self.gameIDArr
                    isFinished = true
                }
            }
            if let currentId = notification.object as? [UInt8]{
                newByteArray = currentId
                debugPrint(currentId)
            }
            self.randomGenerator()
            if(isPracticeMatch){
                if self.swingDetails.last?.shotNo != 0{
                    self.swingDetails.append((shotNo: 0, bs: 0.0, ds: 0.0, hv: 0.0, cv: 0.0,ba:0.0,tempo:0.0,club:"",time:0,hole:0))
                }
                debugPrint(self.currentGameId)
                self.invalidateAllTimers()
                if newByteArray.count == 8{
                    newByteArray.removeLast(4)
                }
                var param : [UInt8] = [8,counter]
                for i in newByteArray{
                    param.append(i)
                }
                if(self.swingDetails.count == 1){
                    param.append(0)
                    param.append(0)
                }else{
                    var newByteArrForShot = toByteArray(swingDetails[swingDetails.count-2].shotNo)
                    param.append(newByteArrForShot[0])
                    param.append(newByteArrForShot[1])
                }
                debugPrint("Param : \(param)")
                let writeData =  Data(bytes: param)
                
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.currentCommandData = param
                timerForWriteCommand8 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                    self.randomGenerator()
                    param[1] = self.counter
                    let writeData =  Data(bytes: param)
                    Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                    self.currentCommandData = param
                })
            }else{
                var param : [UInt8] = [8,counter]
                for i in newByteArray{
                    param.append(i)
                }
                if(self.holeWithSwing.count == 0){
                    param.append(1)
                }else{
                    if(holeWithSwing.last!.holeOut){
                        param.append(UInt8(holeWithSwing.last!.hole+1))
                    }else{
                        param.append(UInt8(holeWithSwing.last!.hole))
                    }
                }
                if(self.holeWithSwing.count == 0){
                    param.append(UInt8(self.shotNumFor8th(hole: 1)))
                }else{
                    if(holeWithSwing.last!.holeOut){
                        param.append(UInt8(self.shotNumFor8th(hole: holeWithSwing.last!.hole+1)))
                    }else{
                        param.append(UInt8(holeWithSwing.last!.shotNo))
                    }
                }
                debugPrint("Param : \(param)")
                let writeData =  Data(bytes: param)
                self.invalidateAllTimers()
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.currentCommandData = param
                timerForWriteCommand8 = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                    self.randomGenerator()
                    param[1] = self.counter
                    let writeData =  Data(bytes: param)
                    Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                    self.currentCommandData = param
                })
            }
        }else{
            debugPrint("divice is not connected ")
        }
    }
    private func sendFifthCommand(){
        if (Constants.charctersticsGlobalForWrite != nil){
            self.randomGenerator()
            let timeStamp = Timestamp
            self.currentGameId = Int(timeStamp%100000000) //87554701
            debugPrint(self.currentGameId)
            var newByteArray = toByteArray(self.currentGameId)
            
            self.invalidateAllTimers()
            newByteArray.removeLast(4)
            var param : [UInt8] = [5,counter]
            if(isPracticeMatch){
                param.append(UInt8(2))
            }else{
                param.append(UInt8(1))
            }
            for i in newByteArray{
                param.append(i)
            }
            let writeData =  Data(bytes: param)
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.currentCommandData = param
            timerForWriteCommand5 = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                self.randomGenerator()
                param[1] = self.counter
                let writeData =  Data(bytes: param)
                Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                self.currentCommandData = param
            })
        }else{
            UIApplication.shared.keyWindow?.makeToast("No Service found please try again.")
        }
    }
    
    private func sendSeventhCommand(param:[UInt8],index:Int){
        self.invalidateAllTimers()
        var param = param
        for i in index..<clubData.count{
            if(index+3 == i){
                break
            }else{
                param.append(UInt8(i+1))
                let minByte = toByteArray(clubData[i].min)
                let maxByte = toByteArray(clubData[i].max)
                param.append(minByte[0])
                param.append(minByte[1])
                
                param.append(maxByte[0])
                param.append(maxByte[1])
            }
        }
        if(param.count < 18){
            for _ in 0..<18-param.count{
                param.append(UInt8(0))
            }
        }
        let writeData =  Data(bytes: param)
        Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
        self.currentCommandData = param
        timerForWriteCommand7 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            Constants.deviceGolficationX.writeValue(writeData, for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
            self.currentCommandData = param
        })
    }
    func playSound() {
        guard let url = Bundle.main.url(forResource: "swing_beep", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            guard let player = player else { return }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func discardGameFromDevice(){
        self.swingMatchId = ""
        if Constants.deviceGolficationX != nil{
            randomGenerator()
            if gameIDArr == nil{
                UIApplication.shared.keyWindow?.makeToast("No game available to discard.")
            }else{
                let param = [4,self.counter,gameIDArr[0],gameIDArr[1],gameIDArr[2],gameIDArr[3]]
                sendFourthCommand(param: param)
            }

        }
    }
}

extension BLE: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("--- centralManagerDidUpdateState")
        var bluetoothStatus = String()
        if central.state == CBManagerState.poweredOn {
            debugPrint("poweredOn")
            
            //            progressView.show()
//            DispatchQueue.main.async {
                let serviceUUIDs:[AnyObject] = [self.golficationXServiceCBUUID_READ]
                let lastPeripherals = self.centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs as! [CBUUID])
                
                if lastPeripherals.count > 0{
                    let device = lastPeripherals.last! as CBPeripheral;
                    Constants.deviceGolficationX = device;
                    self.centralManager.connect(Constants.deviceGolficationX, options: nil)
                    if(device.state == .disconnected){
                        UIApplication.shared.keyWindow?.makeToast("Device is disconnected restart the device and connect again.")
                        bluetoothStatus = "Device_Disconnected"
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothStatus"), object: bluetoothStatus)
                    }
                }
                else {
                    self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        if self.peripheralDevicesIn5Sec.count > 0{
                            debugPrint(self.peripheralDevicesIn5Sec)
                            let data = self.peripheralDevicesIn5Sec.allKeys as! [String]
                            let ordered = data.sorted()
                            debugPrint(data,ordered)
                            Constants.deviceGolficationX = (self.peripheralDevicesIn5Sec.value(forKey: "\(ordered.first!)") as! CBPeripheral)
                            Constants.deviceGolficationX.delegate = self
                            self.centralManager.stopScan()
                            self.centralManager.connect(Constants.deviceGolficationX)
                        }
                    }
                }
//            }
            bluetoothStatus = "Bluetooth_ON"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothStatus"), object: bluetoothStatus)
            
        } else if(central.state == CBManagerState.poweredOff) {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.keyWindow?.makeToast("Make sure that your bluetooth is turned on.")
                bluetoothStatus = "Bluetooth_OFF"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothStatus"), object: bluetoothStatus)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GolficationX_Disconnected"), object: nil)
            })
            Constants.ble.invalidateAllTimers()
            charctersticsWrite = nil
            charctersticsRead = nil
            Constants.deviceGolficationX = nil
            Constants.charctersticsGlobalForWrite = nil
            Constants.charctersticsGlobalForRead = nil
            Constants.ble = nil

        }
        else if(central.state == CBManagerState.unsupported) {
            DispatchQueue.main.async(execute: {
                UIApplication.shared.keyWindow?.makeToast("This device is unsupported.")
                bluetoothStatus = "Device_Unsupported"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothStatus"), object: bluetoothStatus)
            })
            
        }else{
            DispatchQueue.main.async(execute: {
                UIApplication.shared.keyWindow?.makeToast("Try again after restarting the device.")
                bluetoothStatus = "Restart_Device"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BluetoothStatus"), object: bluetoothStatus)
            })
        }
    }
    
    func alertShowing(msg:String){
        DispatchQueue.main.async(execute: {
            let alertVC = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
            alertVC.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        })
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugPrint(peripheral)
        debugPrint("advertisementData :\(advertisementData)")
        //        let dict = NSMutableDictionary()
        //        dict.setValue(peripheral, forKey: "peripheral")
        //        dict.setValue(RSSI, forKey: "rssi")
        
        let name = advertisementData["kCBAdvDataLocalName"] as? String
        if (peripheral.name == "Golfication X") || (name == "Golfication X") || (peripheral.name == "Holfication X") || (name == "Holfication X") /*|| (peripheral.name == "CC2650 SensorTag") || (peripheral.name == "PeripheralObserver") || (peripheral.name == "SBP OAD off-chip")*/{
            peripheralDevicesIn5Sec.setValue(peripheral, forKey: "\(RSSI)")
        }
    }
    func endAllActiveSessions(){
        if self.swingMatchId.count > 1{
            FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "swingSession") { (snapshot) in
                if(snapshot.value != nil){
                    if let dataDic = snapshot.value as? [String:Bool]{
                        for (key, value) in dataDic{
                            if(value) && key != self.swingMatchId{
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([key:false])
                            }
                        }
                    }
                }
            }
        }
    }
    func startMatch(isPractice:Bool){
        self.currentGameId = Int(Timestamp%100000000) //87554701
        if(isPractice){
            self.swingMatchId = ref!.child("swingSession").childByAutoId().key
            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:true])
            let matchDataDic = NSMutableDictionary()
            matchDataDic.setObject(self.currentGameId, forKey: "gameId" as NSCopying)
            matchDataDic.setObject("practice", forKey: "playType" as NSCopying)
            matchDataDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
            
            matchDataDic.setObject(Auth.auth().currentUser!.uid, forKey: "userKey" as NSCopying)
            ref.child("swingSessions").updateChildValues([self.swingMatchId:matchDataDic])
            self.sendFifthCommand()
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startMatch"), object: "New Match")
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "75_Percent_Updated"), object: nil)

        Constants.deviceGolficationX!.discoverServices([self.golficationXServiceCBUUID_READ, self.golficationXServiceCBUUID_Write,self.golficationXCharacteristicCBUUIDOAD])
        DispatchQueue.main.async(execute: {
            var i = 0
            self.timerForService = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                if(self.service_Read == nil) && (self.service_Write == nil){
                    i += 1
                    debugPrint("loop0")
                    Constants.deviceGolficationX!.discoverServices([self.golficationXServiceCBUUID_READ, self.golficationXServiceCBUUID_Write,self.golficationXCharacteristicCBUUIDOAD])
                    if(i > 3){
                        self.alertShowing(msg: "Scanning Time out try again")
                        self.timerForService.invalidate()
                        self.centralManager.stopScan()
                        self.centralManager.cancelPeripheralConnection(Constants.deviceGolficationX)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Scanning_Time_Out"), object: nil)
                    }
                }
                else{
//                    if self.isSetupScreen{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
//                    }
                    self.isDeviceStillConnected = true
                    self.timerForService.invalidate()
                }
            })
        })
    }
    
}
extension BLE: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services{
            for service in services {
                debugPrint(service.uuid)
                if(service.uuid == golficationXServiceCBUUID_READ){
                    service_Read = service
                    debugPrint("Read UUID :\(service_Read!.uuid)")
                    Constants.deviceGolficationX.discoverCharacteristics(nil, for: service_Read)
                }
                if(service.uuid == golficationXServiceCBUUID_Write){
                    service_Write = service
                    debugPrint("Write UUID  :\(service_Write!.uuid)")
                    Constants.deviceGolficationX.discoverCharacteristics(nil, for: service_Write)
                }
                if(service.uuid == golficationXCharacteristicCBUUIDOAD){
                    debugPrint("Write UUID  :\(service.uuid)")
                    Constants.deviceGolficationX.discoverCharacteristics(nil, for: service)
                }
            }
            if(service_Write != nil) && (service_Read != nil){
                
            }
        } else {
            service_Read = nil
            service_Write = nil
            debugPrint("No service Found")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if(characteristic.uuid == golficationXCharacteristicCBUUIDWrite){
                self.charctersticsWrite = characteristic
                Constants.charctersticsGlobalForWrite = characteristic
                debugPrint(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    self.sendEleventhCommand()
                }
            }else if (characteristic.uuid == golficationXCharacteristicCBUUIDRead){
                self.charctersticsRead = characteristic
                Constants.charctersticsGlobalForRead = characteristic
                Constants.deviceGolficationX.setNotifyValue(true, for: self.charctersticsRead)
            }
        }
        
    }
    func uploadSwingScore(){
        DispatchQueue.main.async(execute: {
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(self.swingMatchId)/swings") { (snapshot) in
                var shotArr = [NSMutableDictionary]()
                if(snapshot.value != nil){
                    if let data = snapshot.value as? [NSMutableDictionary]{
                        shotArr = data
                    }
                }
                DispatchQueue.main.async(execute: {
                    for data in self.swingDetails{
                        if(data.shotNo != 0) && shotArr.count>0 && self.isPracticeMatch{
                            let swingDict = NSMutableDictionary()
                            swingDict.setValue(data.club, forKey: "club")
                            swingDict.setValue(data.bs, forKey: "backSwing")
                            swingDict.setValue(data.ds, forKey: "downSwing")
                            swingDict.setValue(data.hv, forKey: "handSpeed")
                            swingDict.setValue(data.tempo, forKey: "tempo")
                            swingDict.setValue(data.shotNo, forKey: "shotNum")
                            swingDict.setValue(data.cv, forKey: "clubSpeed")
                            swingDict.setValue(data.time, forKey: "timestamp")
                            swingDict.setValue(data.ba, forKey: "backSwingAngle")
                            if !self.isPracticeMatch{
                                swingDict.setValue(data.hole, forKey: "holeNum")
                            }
                            //                            swingDict.setValue(self.randomIntVelocity(max: 90,min: 60),forKey:"VC1")
                            //                            swingDict.setValue(self.randomIntVelocity(max: 55,min: 30),forKey:"VC2")
                            //                            swingDict.setValue(self.randomIntVelocity(max: 140,min: 120),forKey:"VC3")
                            //                            swingDict.setValue(self.randomIntVelocity(max: 15,min: 10),forKey:"VH1")
                            //                            swingDict.setValue(self.randomIntVelocity(max: 6,min: 2),forKey:"VH2")
                            //                            swingDict.setValue(self.randomIntVelocity(max: 40,min: 30),forKey:"VH3")
                            
                            var d = 0.0
                            if(data.tempo > 3){
                                d = data.tempo - 3
                            }else{
                                d = 3 - data.tempo
                            }
                            let swingScore = 95 - (d/3)*55
                            swingDict.setValue(Int(swingScore), forKey: "swingScore")
                            var isAvailable = false
                            for shot in shotArr{
                                if(shot.value(forKey: "shotNum") as! Int) == data.shotNo{
                                    isAvailable = true
                                    break
                                }
                            }
                            if(!isAvailable){
                                shotArr.append(swingDict)
                            }
                        }else{
                            if self.isPracticeMatch{
                                if(data.shotNo != 0){
                                    let swingDict = NSMutableDictionary()
                                    swingDict.setValue(data.club, forKey: "club")
                                    swingDict.setValue(data.bs, forKey: "backSwing")
                                    swingDict.setValue(data.ds, forKey: "downSwing")
                                    swingDict.setValue(data.hv, forKey: "handSpeed")
                                    swingDict.setValue(data.tempo, forKey: "tempo")
                                    swingDict.setValue(data.shotNo, forKey: "shotNum")
                                    swingDict.setValue(data.cv, forKey: "clubSpeed")
                                    swingDict.setValue(data.time, forKey: "timestamp")
                                    swingDict.setValue(data.ba, forKey: "backSwingAngle")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 90,min: 60),forKey:"VC1")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 55,min: 30),forKey:"VC2")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 140,min: 120),forKey:"VC3")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 15,min: 10),forKey:"VH1")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 6,min: 2),forKey:"VH2")
                                    //                                swingDict.setValue(self.randomIntVelocity(max: 40,min: 30),forKey:"VH3")
                                    
                                    var d = 0.0
                                    if(data.tempo > 3){
                                        d = data.tempo - 3
                                    }else{
                                        d = 3 - data.tempo
                                    }
                                    let swingScore = 95 - (d/3)*55
                                    swingDict.setValue(Int(swingScore), forKey: "swingScore")
                                    shotArr.append(swingDict)
                                }
                            }else{
                                if (data.shotNo != 0){
                                    let swingDict = NSMutableDictionary()
                                    swingDict.setValue(data.club, forKey: "club")
                                    swingDict.setValue(data.bs, forKey: "backSwing")
                                    swingDict.setValue(data.ds, forKey: "downSwing")
                                    swingDict.setValue(data.hv, forKey: "handSpeed")
                                    swingDict.setValue(data.tempo, forKey: "tempo")
                                    swingDict.setValue(data.shotNo, forKey: "shotNum")
                                    swingDict.setValue(data.cv, forKey: "clubSpeed")
                                    swingDict.setValue(data.time, forKey: "timestamp")
                                    swingDict.setValue(data.ba, forKey: "backSwingAngle")
                                    swingDict.setValue(data.hole, forKey: "holeNum")
                                    var d = 0.0
                                    if(data.tempo > 3){
                                        d = data.tempo - 3
                                    }else{
                                        d = 3 - data.tempo
                                    }
                                    let swingScore = 95 - (d/3)*55
                                    swingDict.setValue(Int(swingScore), forKey: "swingScore")
                                    var isAvailable = false
                                    for shot in shotArr{
                                        if(shot.value(forKey: "shotNum") as! Int) == data.shotNo && (shot.value(forKey: "holeNum") as! Int) == data.hole{
                                            isAvailable = true
                                            break
                                        }
                                    }
                                    if(!isAvailable){
                                        shotArr.append(swingDict)
                                    }
                                }
                            }
                        }
                    }
                    if(shotArr.count > 0){
                        ref.child("swingSessions/\(self.swingMatchId)/").updateChildValues(["swings":shotArr], withCompletionBlock: { (error, ref) in
                            let dict = NSMutableDictionary()
                            dict.addEntries(from: ["id" : self.swingMatchId])
                            dict.addEntries(from: ["gameId":self.currentGameId])
                            if self.isPracticeMatch{
                                if !self.isFirst{
                                    if !self.isFinished{
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getSwing"), object: dict)
                                        self.isFirst = true
                                    }
                                }else{
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getSwingInside"), object: dict)
                                }
                            }
                        })
                    }else{
                        let dict = NSMutableDictionary()
                        dict.addEntries(from: ["id" : self.swingMatchId])
                        dict.addEntries(from: ["gameId":self.currentGameId])
                        if self.isPracticeMatch{
                            if !self.isFinished{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getSwing"), object: dict)
                            }
                        }
                    }
                })
            }
            
        })
    }
    func uploadShotsToMatchData(){
        //        var holeWithSwing = [(hole:Int,shotNo:Int,club:String,lat:Double,lng:Double,holeOut:Bool)]()
        DispatchQueue.main.async(execute: {
            var shotArr = [NSMutableDictionary]()
            let group = DispatchGroup()
            for i in 0..<self.holeWithSwing.count-1{
                let data = self.holeWithSwing[i]
                let nextData = self.holeWithSwing[i+1]
                if(data.hole == nextData.hole){
                    if(data.shotNo != 0){
                        let shotDict = NSMutableDictionary()
                        shotDict.setValue(data.club, forKey: "club")
                        shotDict.setValue(data.lat, forKey: "lat1")
                        shotDict.setValue(data.lng, forKey: "lng1")
                        shotDict.setValue(false, forKey: "penalty")
                        shotDict.setValue(data.holeOut, forKey: "holeOut")
                        
                        if(nextData.holeOut){
                            shotDict.setValue(nextData.lat, forKey: "lat2")
                            shotDict.setValue(nextData.lng, forKey: "lng2")
                        }else{
                            let shotDict1 = NSMutableDictionary()
                            shotDict1.setValue(nextData.club, forKey: "club")
                            shotDict1.setValue(nextData.lat, forKey: "lat1")
                            shotDict1.setValue(nextData.lng, forKey: "lng1")
                            shotDict1.setValue(false, forKey: "penalty")
                            shotDict1.setValue(nextData.holeOut, forKey: "holeOut")
                            shotArr.append(shotDict1)
                        }
                        shotArr.append(shotDict)
                        shotArr = shotArr.removeDuplicates()
                        
                        if(i+1 == self.holeWithSwing.count-1){
                            group.enter()
                            ref.child("matchData/\(Constants.matchId)/scoring/\(data.hole-1)/\(Auth.auth().currentUser!.uid)/").updateChildValues(["shots":shotArr], withCompletionBlock: { (error, ref) in
                                ref.child("matchData/\(Constants.matchId)/scoring/\(data.hole-1)/\(Auth.auth().currentUser!.uid)/").updateChildValues(["holeOut":true], withCompletionBlock: { (error, ref) in
                                    group.leave()
                                })
                            })
                            shotArr.removeAll()
                        }
                    }
                }else{
                    group.enter()
                    ref.child("matchData/\(Constants.matchId)/scoring/\(data.hole-1)/\(Auth.auth().currentUser!.uid)/").updateChildValues(["shots":shotArr], withCompletionBlock: { (error, ref) in
                        group.leave()
                    })
                    shotArr.removeAll()
                    if(nextData.shotNo != 0){
                        let shotDict = NSMutableDictionary()
                        shotDict.setValue(nextData.club, forKey: "club")
                        shotDict.setValue(nextData.lat, forKey: "lat1")
                        shotDict.setValue(nextData.lng, forKey: "lng1")
                        shotDict.setValue(false, forKey: "penalty")
                        
                        shotDict.setValue(nextData.holeOut, forKey: "holeOut")
                        shotArr.append(shotDict)
                    }
                }
            }
            group.notify(queue: .main, execute: {
                if let scoring = Constants.matchDataDic.value(forKeyPath: "scoring") as? NSMutableArray{
                    var holeNm = 1
                    if self.holeWithSwing.last?.hole != scoring.count{
                        holeNm = self.holeWithSwing.last!.hole
                        self.holeWithSwing.removeAll()
                        self.holeWithSwing.append((hole: holeNm+1, shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: self.gameIDArr)
                    }
                }
            })
        })
    }
    func updateSingleShot(nextData:(hole:Int,shotNo:Int,club:String,lat:Double,lng:Double,holeOut:Bool)){
        let shotDict = NSMutableDictionary()
        shotDict.setValue(nextData.club, forKey: "club")
        if lat == 0{
            if let userLocation = self.locationManager.location{
                let newPoint = GMSGeometryOffset(userLocation.coordinate, 3,CLLocationDirection(arc4random_uniform(360)))
                shotDict.setValue(newPoint.latitude, forKey: "lat1")
                shotDict.setValue(newPoint.longitude, forKey: "lng1")
            }
        }else{
            
            shotDict.setValue(nextData.lat, forKey: "lat1")
            shotDict.setValue(nextData.lng, forKey: "lng1")
        }
        shotDict.setValue(false, forKey: "penalty")
        shotDict.setValue(nextData.holeOut, forKey: "holeOut")
        let currentLocation: CLLocation = self.locationManager.location!
        let lat1 = currentLocation.coordinate.latitude
        let lng1 = currentLocation.coordinate.longitude
        let dict = NSMutableDictionary()
        dict.setValue(lat1, forKey: "lat1")
        dict.setValue(lng1, forKey: "lng1")
        shotDict.setValue(dict, forKey: "phoneLocation")
        ref.child("matchData/\(Constants.matchId)/scoring/\(nextData.hole-1)/\(Auth.auth().currentUser!.uid)/shots/\(nextData.shotNo-1)").updateChildValues(shotDict as! [AnyHashable : Any])
        if self.currentCommandData.first != UInt8(92){
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: self.gameIDArr)
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "response9"), object: false)
    }
    
    func updateHoleOutShot(){
        ref.child("matchData/\(Constants.matchId)/scoring/\(self.holeNo-1)/\(Auth.auth().currentUser!.uid)/").updateChildValues(["holeOut":true])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "response9"), object: true)
        if self.currentCommandData.first != UInt8(92){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: self.gameIDArr)
        }
    }
    func updateSingleSwing(data:(shotNo:Int,bs:Double,ds:Double,hv:Double,cv:Double,ba:Double,tempo:Double,club:String,time:Int64,hole:Int),hole:Int){
        let swingDict = NSMutableDictionary()
        swingDict.setValue(data.club, forKey: "club")
        swingDict.setValue(data.bs, forKey: "backSwing")
        swingDict.setValue(data.ds, forKey: "downSwing")
        swingDict.setValue(data.hv, forKey: "handSpeed")
        swingDict.setValue(data.tempo, forKey: "tempo")
        swingDict.setValue(data.shotNo, forKey: "shotNum")
        swingDict.setValue(hole, forKey: "holeNum")
        swingDict.setValue(data.cv, forKey: "clubSpeed")
        swingDict.setValue(data.time, forKey: "timestamp")
        swingDict.setValue(data.ba, forKey: "backSwingAngle")
//        swingDict.setValue(self.randomIntVelocity(max: 90,min: 60),forKey:"VC1")
//        swingDict.setValue(self.randomIntVelocity(max: 55,min: 30),forKey:"VC2")
//        swingDict.setValue(self.randomIntVelocity(max: 140,min: 120),forKey:"VC3")
//        swingDict.setValue(self.randomIntVelocity(max: 15,min: 10),forKey:"VH1")
//        swingDict.setValue(self.randomIntVelocity(max: 6,min: 2),forKey:"VH2")
//        swingDict.setValue(self.randomIntVelocity(max: 40,min: 30),forKey:"VH3")
        
        var d = 0.0
        if(data.tempo > 3){
            d = data.tempo - 3
        }else{
            d = 3 - data.tempo
        }
        let swingScore = 95 - (d/3)*55
        swingDict.setValue(Int(swingScore), forKey: "swingScore")
        
        ref.child("swingSessions/\(self.swingMatchId)/swings/\(data.shotNo-1)/").updateChildValues(swingDict as! [AnyHashable : Any])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case golficationXCharacteristicCBUUIDRead:
            if(characteristic.value != nil){
                let data = characteristic.value!
                var dataArray = [UInt8]()
                for i in data{
                    dataArray.append(i)
                }
                //                var arry = BluetootheConnectionTesting.getData(value: dataArray)
                
                debugPrint("data Array Recieved :\(dataArray)")
                
                let responseInIntFirst4 = byteArrayToInt(value: [dataArray[2],dataArray[3],dataArray[4],dataArray[5]])
                let responseInIntSecond4 = byteArrayToInt(value: [dataArray[3],dataArray[4],dataArray[5],dataArray[6]])
                
                debugPrint("\(totalTagInFirstPackate)")
                if  dataArray[0] == UInt8(1) && (dataArray[0] == currentCommandData[0]) && (dataArray[1] == currentCommandData[1]){
                    timerForWriteCommand1.invalidate()
                    debugPrint("RecviedResult 1")
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["handed":self.leftOrRight == 1 ? "Left":"Right"])
                    Constants.handed = self.leftOrRight == 1 ? "Left":"Right"
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["unit":self.metric == 1 ? 1:0])
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "responseFirstCommand"),object:nil)
                    }
                }else if dataArray[0] == UInt8(2) && ((dataArray[1] == self.tagClubNumber.count)||totalTagInFirstPackate == dataArray[1]){
                    timerForWriteCommand21.invalidate()
                    debugPrint("RecviedResult 2.1")
                    if(self.tagClubNumber.count == 0){
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["deviceSetup":true])
                        ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["device":true])
                        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "command2"))
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"command2Finished"), object: nil)
                    }else{
                        if(totalTagInFirstPackate == 0){
                            self.sendSecondCommand(packet: 41)
                        }else{
                            self.sendSecondCommand(packet: UInt8(41 + totalTagInFirstPackate/3))
                        }
                    }
                }else if dataArray[0] == UInt8(2) && (dataArray[1] == UInt8(self.totalClub)){
                    timerForWriteCommand22.invalidate()
                    debugPrint("RecviedResult 2.2   ----  \(self.totalClub!)")
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["deviceSetup":true])
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["device":true])

                    NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "command2"))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"command2Finished"), object: nil)
                    //                    self.startMatch()
                }else if dataArray[0] == UInt8(3){
                    self.invalidateAllTimers()
                    debugPrint("gameID Response from Third Command  : \(responseInIntFirst4)")
                    debugPrint("gameID Response from Third Command  : \(byteArrayToInt(value: [dataArray[2],dataArray[3],dataArray[4],dataArray[5]]))")
                    self.gameIDArr = [dataArray[2],dataArray[3],dataArray[4],dataArray[5]]
                    if (responseInIntFirst4 == 1){
                        if(self.isPracticeMatch){
                            self.startMatch(isPractice: true)
                        }else{
                            self.sendsixthCommand1()
                        }
                    }else{
                        if(!self.isPracticeMatch) && self.currentGameId/100 == responseInIntFirst4/100{
                            self.invalidateAllTimers()
                            debugPrint(self.swingMatchId)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: [dataArray[2],dataArray[3],dataArray[4],dataArray[5]])
                        }else if self.currentGameId/100 == responseInIntFirst4/100{
                            self.invalidateAllTimers()
                            debugPrint(self.swingMatchId)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: [dataArray[2],dataArray[3],dataArray[4],dataArray[5]])
                        }else{
                            DispatchQueue.main.async(execute: {
                                let gameAlert = UIAlertController(title: "Ongoing Match", message: "Discard the ongoing game.", preferredStyle: UIAlertControllerStyle.alert)
                                gameAlert.addAction(UIAlertAction(title: "Discard", style: .default, handler: { (action: UIAlertAction!) in
                                    ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
                                    self.swingMatchId = ""
                                    self.randomGenerator()
                                    self.swingDetails.removeAll()
                                    self.sendFourthCommand(param: [4,self.counter,dataArray[2],dataArray[3],dataArray[4],dataArray[5]])
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
                                }))
                                gameAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (action: UIAlertAction!) in
                                    debugPrint("Game Discard cancel Press")
                                }))
                                UIApplication.shared.keyWindow?.rootViewController?.present(gameAlert, animated: true, completion: nil)
                            })
                        }
                    }
                }else if(dataArray[0] == UInt8(4)){
                    self.invalidateAllTimers()
                    self.currentGameId = responseInIntFirst4
                    DispatchQueue.main.async(execute: {
                        self.endAllActiveSessions()
                        UIApplication.shared.keyWindow?.makeToast("Game Discarded Successfully.")
                    })

                }else if (dataArray[0] == UInt8(6)){
                    timerForWriteCommand61.invalidate()
                    if (currentCommandData[1] > 200) && (dataArray[1] == currentCommandData[1]-200){
                        self.totalHoleNumber = Int(dataArray[1])
                        timerForWriteCommand62.invalidate()
                        self.sendSixthCommand2(value: 1)
                    }else if dataArray[1] == currentCommandData[1]{
                        if(totalHoleNumber != currentCommandData[1]){
                            timerForWriteCommand62.invalidate()
                            self.sendSixthCommand2(value:  currentCommandData[1]+1)
                        }else{
                            self.timerForWriteCommand62.invalidate()
                            let param : [UInt8] = [7,51]
                            self.sendSeventhCommand(param: param, index: 0)
                            tempFor7th = 51
                        }
                    }
                }else if (dataArray[0] == UInt8(7)){
                    self.timerForWriteCommand7.invalidate()
                    if(Int(dataArray[1]) == clubData.count){
                        self.sendFifthCommand()
                    }else{
                        tempFor7th += 1
                        let param : [UInt8] = [7,UInt8(tempFor7th)]
                        self.sendSeventhCommand(param: param, index: Int(dataArray[1]))
                    }
                    
                }else if (dataArray[0] == UInt8(5)){
                    self.timerForWriteCommand5.invalidate()
                    self.currentGameId = responseInIntSecond4
                    if(dataArray[2] == UInt8(2)){
                        self.shotNo = 1
                        self.isFinished = false
                        self.isFirst = false
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.keyWindow?.makeToast("Ready to take swing...")
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "readyToTakeSwing"), object: nil)
                        })
                        
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.swingMatchId = ref!.child("swingSession").childByAutoId().key
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:true])
                            let matchDataDic = NSMutableDictionary()
                            matchDataDic.setObject(self.currentGameId, forKey: "gameId" as NSCopying)
                            matchDataDic.setObject("match", forKey: "playType" as NSCopying)
                            matchDataDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
                            matchDataDic.setObject(Auth.auth().currentUser!.uid, forKey: "userKey" as NSCopying)
                            
                            if(!self.isPracticeMatch){
                                ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)").updateChildValues(["swingKey":self.swingMatchId])
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "courseDataAPI"), object: nil)
                                matchDataDic.setObject(Constants.matchId, forKey: "matchKey" as NSCopying)
                                matchDataDic.setObject(Constants.selectedGolfName, forKey: "courseName" as NSCopying)
                                UIApplication.shared.keyWindow?.makeToast("Course loaded Successful.")
//                                let gameAlert = UIAlertController(title: "Device GPS", message: "Which GPS you want to use?", preferredStyle: UIAlertControllerStyle.alert)
//                                gameAlert.addAction(UIAlertAction(title: "Phone GPS", style: .default, handler: { (action: UIAlertAction!) in
//                                    ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gpsMode":"phone"])
//                                }))
//                                gameAlert.addAction(UIAlertAction(title: "Device GPS", style: .default, handler: { (action: UIAlertAction!) in
//                                    ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)/").updateChildValues(["gpsMode":"device"])
//
//                                }))
//                                UIApplication.shared.keyWindow?.rootViewController?.present(gameAlert, animated: true, completion: nil)
                            }
                            ref.child("swingSessions").updateChildValues([self.swingMatchId:matchDataDic])
                        })
                    }
                }else if (dataArray[0] == UInt8(81)) && (currentCommandData[1] == dataArray[1]){
                    self.isContinue = true
                    self.timerForWriteCommand8.invalidate()
                    if(isPracticeMatch){
                        memccpy(&backSwing, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&downSwing, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        memccpy(&handVelocity, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                        swingDetails[shotNo-1].bs = Double(backSwing)
                        swingDetails[shotNo-1].ds = Double(downSwing)
                        swingDetails[shotNo-1].hv = Double(handVelocity)
                        swingDetails[shotNo-1].tempo = (downSwing == 0.0 ? 0.0 : Double(backSwing/downSwing))
                        swingDetails[shotNo-1].time = Timestamp
                        var clubIndex = 0
                        if(Int(dataArray[14])) != 0 && (Int(dataArray[14])) <= 26{
                            clubIndex = (Int(dataArray[14]))-1
                        }
                        var club = "Dr"
                        if !self.allClubs[clubIndex].contains("Pu"){
                            club = self.allClubs[clubIndex]
                        }
                        swingDetails[shotNo-1].club = club
                    }else{
                        if(self.holeWithSwing.count == 0){
                            self.holeWithSwing.append((hole: 1, shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                            self.swingDetails.append((shotNo: 0, bs: 0, ds: 0, hv: 0, cv: 0,ba:0.0,tempo: 0.0, club: "",time:0,hole:0))
                        }else if(self.holeWithSwing.last!.holeOut){
                            self.holeWithSwing.append((hole:holeWithSwing.last!.hole+1 , shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                            self.swingDetails.append((shotNo: 0, bs: 0, ds: 0, hv: 0, cv: 0, ba:0.0, tempo: 0.0, club: "",time:0,hole:0))
                        }else{
                            self.holeWithSwing.append((hole: 1, shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                            self.swingDetails.append((shotNo: 0, bs: 0, ds: 0, hv: 0, cv: 0, ba:0.0, tempo: 0.0, club: "",time:0,hole:0))
                        }
                        holeNo = Int(dataArray[16])
                        holeWithSwing[holeWithSwing.count-1].hole = Int(dataArray[16])
                        holeWithSwing[holeWithSwing.count-1].shotNo = Int(dataArray[15])
                        if Int(dataArray[15]) == 0{
                            holeWithSwing[holeWithSwing.count-1].holeOut = true
                        }
                        memccpy(&backSwing, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&downSwing, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        memccpy(&handVelocity, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                        var clubIndex = 0
                        if(Int(dataArray[14])) != 0 && (Int(dataArray[14])) <= 26{
                            clubIndex = (Int(dataArray[14]))-1
                        }
//                        var club = "Dr"
//                        if !self.allClubs[clubIndex].contains("Pu"){
//                            club = self.allClubs[clubIndex]
//                        }
                        holeWithSwing[holeWithSwing.count-1].club = self.allClubs[clubIndex]
                        swingDetails[swingDetails.count-1].club = self.allClubs[clubIndex]
                        swingDetails[swingDetails.count-1].shotNo = Int(dataArray[15])
                        swingDetails[swingDetails.count-1].bs = Double(backSwing)
                        swingDetails[swingDetails.count-1].ds = Double(downSwing)
                        swingDetails[swingDetails.count-1].hv = Double(handVelocity)
                        swingDetails[swingDetails.count-1].tempo = (downSwing == 0.0 ? 0.0 : Double(backSwing/downSwing))
                        swingDetails[swingDetails.count-1].time = Timestamp
                        swingDetails[swingDetails.count-1].hole = Int(dataArray[16])
                    }
                }else if (dataArray[0] == UInt8(82)) && (currentCommandData[1] == dataArray[1]){
                    self.isContinue = true
                    if(isPracticeMatch){
                        memccpy(&clubVelocity, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&backAngle, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        swingDetails[shotNo-1].cv = Double(clubVelocity)
                        swingDetails[shotNo-1].ba = Double(backAngle)
                        swingDetails[shotNo-1].shotNo = byteArrayToInt32(value: [dataArray[10],dataArray[11]])
                        shotNo = byteArrayToInt32(value: [dataArray[10],dataArray[11]])+1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: self.gameIDArr)
                    }else{
                        
                        memccpy(&clubVelocity, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&backAngle, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        memccpy(&lat, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                        memccpy(&lng, [dataArray[14],dataArray[15],dataArray[16],dataArray[17]], 4, 4)
                        oldLatLng = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng))
                        if (oldLatLng.latitude == Double(lat)) && (oldLatLng.longitude == Double(lng)){
                            let newPoint = GMSGeometryOffset(CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)), 1,CLLocationDirection(arc4random_uniform(360)))
                            holeWithSwing[holeWithSwing.count-1].lat = newPoint.latitude
                            holeWithSwing[holeWithSwing.count-1].lng = newPoint.longitude
                        }else{
                            holeWithSwing[holeWithSwing.count-1].lat = Double(lat)
                            holeWithSwing[holeWithSwing.count-1].lng = Double(lng)
                        }
                        swingDetails[swingDetails.count-1].cv = Double(clubVelocity)
                        swingDetails[swingDetails.count-1].ba = Double(backAngle)

                        debugPrint("Lattitude From Device : ",Double(lat))
                        debugPrint("Longitude From Device : ",Double(lng))
                        if (holeWithSwing[holeWithSwing.count-1].holeOut){
                            self.updateHoleOutShot()
                            debugPrint("HoleWithSwing",holeWithSwing)
                        }else{
                            self.updateSingleShot(nextData: holeWithSwing.last!)
                            debugPrint("HoleWithSwing",holeWithSwing)
                        }
                    }
                }else if(dataArray[0] == UInt8(80)){
                    self.timerForWriteCommand8.invalidate()
                    self.isContinue = true
                    self.uploadSwingScore()
                    if !isPracticeMatch{
                        if let scoring = Constants.matchDataDic.value(forKeyPath: "scoring") as? NSMutableArray{
                            var holeNm = 1
                            if self.holeWithSwing.last?.hole != scoring.count{
                                holeNm = Int(self.currentCommandData[6])
                                self.holeWithSwing.removeAll()
                                self.holeWithSwing.append((hole: holeNm+1, shotNo: self.shotNumFor8th(hole: holeNm+1), club: "", lat: 0.0, lng: 0.0, holeOut: false))
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: self.gameIDArr)
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
                            }
                        }
                    }
                    
                    if(self.isFinished){
                        self.sendNinthCommand(par: [dataArray[2],dataArray[3],dataArray[4],dataArray[5]])
                    }
                }else if(dataArray[0] == UInt8(9)){
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/swingSession/").updateChildValues([self.swingMatchId:false])
                    self.invalidateAllTimers()
                    if self.isPracticeMatch{
                        self.swingDetails.removeAll()
                        DispatchQueue.main.async(execute: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "practiceFinished"), object: "Finish")
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "practiceFinished"), object: "Finish")
                        })
                    }

                }else if(dataArray[0] == UInt8(91)){
                    if swingDetails.last == nil{
                        swingDetails.append((shotNo: 0 , bs: 0.0, ds: 0.0, hv: 0.0, cv: 0.0, ba:0.0, tempo: 0.0, club: "",time:0,hole:0))
                        holeWithSwing.append((hole: 0, shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                    }
                    else if(swingDetails.last!.shotNo != 0){
                        swingDetails.append((shotNo: 0 , bs: 0.0, ds: 0.0, hv: 0.0, cv: 0.0, ba:0.0, tempo: 0.0, club: "",time:0,hole:0))
                        holeWithSwing.append((hole: 0, shotNo: 0, club: "", lat: 0.0, lng: 0.0, holeOut: false))
                    }
                    if(isPracticeMatch){
                        memccpy(&backSwing, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&downSwing, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        memccpy(&handVelocity, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                        swingDetails[shotNo-1].bs = Double(backSwing)
                        swingDetails[shotNo-1].ds = Double(downSwing)
                        swingDetails[shotNo-1].hv = Double(handVelocity)
                        var clubIndex = 0
                        if(Int(dataArray[14])) != 0 && (Int(dataArray[14])) <= 26{
                            clubIndex = (Int(dataArray[14]))-1
                        }
                        var club = "Dr"
                        if !self.allClubs[clubIndex].contains("Pu"){
                            club = self.allClubs[clubIndex]
                        }
                        swingDetails[shotNo-1].club = club
                        swingDetails[shotNo-1].tempo = (downSwing == 0.0 ? 0.0 : Double(backSwing/downSwing))
                        swingDetails[shotNo-1].time = Timestamp
                        debugPrint(swingDetails)
                    }else{
                        self.currentCommandData[0] = UInt8(91)
                        holeNo = Int(dataArray[16])
                        holeWithSwing[holeWithSwing.count-1].hole = Int(dataArray[16])
                        holeWithSwing[holeWithSwing.count-1].shotNo = Int(dataArray[15])
                        swingDetails[swingDetails.count-1].shotNo = Int(dataArray[15])
                        var clubNumber = 0
                        if(Int(dataArray[14])) != 0 && (Int(dataArray[14])) <= 26{
                            clubNumber = (Int(dataArray[14]))-1
                        }
                        holeWithSwing[holeWithSwing.count-1].club = self.allClubs[clubNumber]
                        swingDetails[swingDetails.count-1].club = self.allClubs[clubNumber]
                        if(Int(dataArray[15]) == 0){
                            holeWithSwing[holeWithSwing.count-1].holeOut = true
                        }else{
                            holeWithSwing[holeWithSwing.count-1].holeOut = false
                            memccpy(&backSwing, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                            memccpy(&downSwing, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                            memccpy(&handVelocity, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                            
                            swingDetails[swingDetails.count-1].bs = Double(backSwing)
                            swingDetails[swingDetails.count-1].ds = Double(downSwing)
                            swingDetails[swingDetails.count-1].hv = Double(handVelocity)
                            swingDetails[swingDetails.count-1].tempo = (downSwing == 0.0 ? 0.0 : Double(backSwing/downSwing))
                            swingDetails[swingDetails.count-1].time = Timestamp
                            swingDetails[swingDetails.count-1].hole = Int(dataArray[16])
                        }
                        debugPrint(swingDetails)
                    }
                    
                }else if(dataArray[0] == UInt8(92)){
                    if(isPracticeMatch){
                        memccpy(&clubVelocity, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&backAngle, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        swingDetails[shotNo-1].cv = Double(clubVelocity)
                        swingDetails[shotNo-1].ba = Double(backAngle)
                        swingDetails[shotNo-1].shotNo = byteArrayToInt32(value: [dataArray[10],dataArray[11]])
                        shotNo = byteArrayToInt32(value: [dataArray[10],dataArray[11]])+1
                        debugPrint(swingDetails)
                        self.uploadSwingScore()
                    }else{
                        self.currentCommandData[0] = UInt8(92)
                        memccpy(&clubVelocity, [dataArray[2],dataArray[3],dataArray[4],dataArray[5]], 4, 4)
                        memccpy(&backAngle, [dataArray[6],dataArray[7],dataArray[8],dataArray[9]], 4, 4)
                        memccpy(&lat, [dataArray[10],dataArray[11],dataArray[12],dataArray[13]], 4, 4)
                        memccpy(&lng, [dataArray[14],dataArray[15],dataArray[16],dataArray[17]], 4, 4)
                        swingDetails[swingDetails.count-1].cv = Double(clubVelocity)
                        swingDetails[swingDetails.count-1].ba = Double(backAngle)
                        if(lat == 0) || (lng == 0){
                            if let location = self.locationManager.location{
                                holeWithSwing[holeWithSwing.count-1].lat = location.coordinate.latitude
                                holeWithSwing[holeWithSwing.count-1].lng = location.coordinate.longitude
                            }
                        }else{
                            oldLatLng = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng))
                            if (oldLatLng.latitude == Double(lat)) && (oldLatLng.longitude == Double(lng)){
                                let newPoint = GMSGeometryOffset(CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)), 1,CLLocationDirection(arc4random_uniform(360)))
                                holeWithSwing[holeWithSwing.count-1].lat = newPoint.latitude
                                holeWithSwing[holeWithSwing.count-1].lng = newPoint.longitude
                            }else{
                                holeWithSwing[holeWithSwing.count-1].lat = Double(lat)
                                holeWithSwing[holeWithSwing.count-1].lng = Double(lng)
                            }
                            debugPrint("Lattitude From Device : ",Double(lat))
                            debugPrint("Longitude From Device : ",Double(lng))
                        }
                        
                        debugPrint(self.swingDetails)
                        debugPrint(self.holeWithSwing)
                        if(holeWithSwing.last!.shotNo != 0){
                            self.updateSingleSwing(data:swingDetails.last!,hole:holeNo)
                            self.updateSingleShot(nextData: holeWithSwing.last!)
                            self.swingDetails.removeAll()
                        }else if(holeWithSwing.last!.shotNo == 0){
                            self.updateHoleOutShot()
                        }
                    }
                    self.endAllActiveSessions()
                }else if(dataArray[0] == UInt8(10)){
                    self.isDeviceSetup = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setupDevice"), object: false)
                    self.alertShowing(msg: "Please Complete Golfiction X setup first.")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noSetup"), object: nil)
                    //                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["deviceSetup":false])
                    //                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["device":false])
                    self.invalidateAllTimers()
                }else if (dataArray[0] == UInt8(11)){
                    DispatchQueue.main.async(execute: {
                        let version = self.byteArrayToInt32(value: [dataArray[1],dataArray[2]])
                        self.invalidateAllTimers()
                        if(version < Constants.firmwareVersion){
                            let gameAlert = UIAlertController(title: "Firmware Update", message: "New version \(version) found for GolficationX", preferredStyle: UIAlertControllerStyle.alert)
                            gameAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                                debugPrint("Cancel")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScreen"), object: nil)
                            }))
                            gameAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action: UIAlertAction!) in
                                debugPrint("Updating")
                                self.randomGenerator()
                                let newByteArr = self.toByteArray(Constants.firmwareVersion)
                                let param = [12,self.counter,newByteArr[0],newByteArr[1]]
                                self.currentCommandData = param
                                Constants.deviceGolficationX.writeValue(Data(bytes: param), for: Constants.charctersticsGlobalForWrite!, type: CBCharacteristicWriteType.withResponse)
                            }))
                            UIApplication.shared.keyWindow?.rootViewController?.present(gameAlert, animated: true, completion: nil)
                        }
                    })
                }else if (dataArray[0] == UInt8(12)){
                    DispatchQueue.main.async(execute: {
                        if let wd = UIApplication.shared.delegate?.window {
                            let vc = wd!.rootViewController
                            if(vc is UITabBarController){
                                if let viewC = (vc as! UITabBarController).selectedViewController as? UINavigationController{
                                    let storyboard = UIStoryboard(name: "OAD", bundle: nil)
                                    let viewCtrl = storyboard.instantiateViewController(withIdentifier: "TIOADViewController") as! TIOADViewController
                                    viewC.topViewController?.navigationController?.push(viewController: viewCtrl)
                                    
                                }
                            }
                        }
                    })
                }
            }
            break
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    func shotNumFor8th(hole:Int)->Int{
        var shotNm = 0
        if let scoring = Constants.matchDataDic.value(forKeyPath: "scoring") as? NSMutableArray{
            if let holeData = (scoring[hole-1] as! NSMutableDictionary).value(forKey: Auth.auth().currentUser!.uid) as? NSMutableDictionary{
                if let holeShotArr = holeData.value(forKey: "shots") as? NSArray{
                    shotNm = holeShotArr.count
                }
            }
        }
        return shotNm
    }
    func updateMaxMin(){
        self.clubData.removeAll()
        for data in Constants.clubWithMaxMin{
            if clubsArr.contains(data.name){
                self.clubData.append((name: data.name, max: data.max, min: data.min))
            }
        }
        self.clubData.sort{($0).max > ($1).max}
        if (!self.clubData.isEmpty){
            for i in 0..<self.clubData.count-1{
                if !(self.clubData[i].min == self.clubData[i+1].max+1) && (self.clubData[i].min>Constants.clubWithMaxMin[i+1].max+1){
                    let diff = self.clubData[i].min - self.clubData[i+1].max+1
                    self.clubData[i].max += diff/2
                    self.clubData[i+1].min -= diff/2
                    if(self.clubData[i+1].min < 0){
                        self.clubData[i+1].min = 0
                    }
                }
            }
            debugPrint("clubs \(self.clubData)")
        }
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "Alert" , message: "Device failed to connect please try again after reboot the device.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        debugPrint("success On write: \(currentCommandData)")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            if peripherals.count > 0 {
                Constants.deviceGolficationX = peripherals[0]
                Constants.deviceGolficationX?.delegate = self
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            debugPrint(Constants.deviceGolficationX.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse))
            self.invalidateAllTimers()
//            self.alertShowing(msg: "GolficationX disconnected Please connect again")
            //        centralManager.connect(deviceGolficationX!, options: nil)
            UIApplication.shared.keyWindow?.makeToast("Device Disconnected.....")
            Constants.deviceGolficationX = nil
            self.charctersticsWrite = nil
            self.charctersticsRead = nil
            Constants.charctersticsGlobalForWrite = nil
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GolficationX_Disconnected"), object: nil)
//            if(self.isPracticeMatch){
                Constants.deviceGolficationX = peripheral
                self.centralManager.connect(peripheral, options: nil)
//            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print(e)
        } else {
            if charctersticsRead.isNotifying {
                
                print("notification updated: " + charctersticsRead.uuid.uuidString)
            }
            if charctersticsWrite.isNotifying {
                print("notification updated: " + charctersticsWrite.uuid.uuidString)
            }
        }
    }
}

