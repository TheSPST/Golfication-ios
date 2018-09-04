//
//  BluetoothSync.swift
//  Golfication
//
//  Created by Rishabh Sood on 07/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://github.com/Pluto-Y/Swift-LightBlue/blob/master/Source/BluetoothManager.swift
//https://github.com/Pluto-Y/Swift-LightBlue/blob/master/Source/BluetoothDelegate.swift

import UIKit
import CoreBluetooth

class BluetoothSync: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var connectedPeripheral : CBPeripheral?
    var delegate : BluetoothDelegate?
    var state: CBManagerState? {
        guard _manager != nil else {
            return nil
        }
        return CBManagerState(rawValue: (_manager?.state.rawValue)!)
    }
    var _manager: CBCentralManager!

    static private var instance : BluetoothSync {
        return sharedInstance
    }
    
    public static let sharedInstance = BluetoothSync()
    
    public override init() {
        super.init()
        initCBCentralManager()
    }
    
    func initCBCentralManager() {
        var dic : [String : Any] = Dictionary()
        dic[CBCentralManagerOptionShowPowerAlertKey] = false
        _manager = CBCentralManager(delegate: self, queue: nil, options: dic)
        
    }
    static func getInstance() -> BluetoothSync {
        return instance
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            debugPrint("State : Powered Off")
        case .poweredOn:
            debugPrint("State : Powered On")
        case .resetting:
            debugPrint("State : Resetting")
        case .unauthorized:
            debugPrint("State : Unauthorized")
        case .unknown:
            debugPrint("State : Unknown")
        case .unsupported:
            debugPrint("State : Unsupported")
        }
        if let state = self.state {
            delegate?.didUpdateState?(state)
        }
    }
    
    func startScanPeripheral() {
        _manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanPeripheral() {
        _manager?.stopScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        delegate?.didDiscoverPeripheral?(peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    func connectPeripheral(_ peripheral: CBPeripheral) {
        //if !isConnecting {
//            isConnecting = true
            _manager?.connect(peripheral)
//            timeoutMonitor = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.connectTimeout(_:)), userInfo: peripheral, repeats: false)
        //}
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.didConnectedPeripheral?(peripheral)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        connectedPeripheral = peripheral
        if error != nil {
            debugPrint("Bluetooth Manager --> Discover Services Error, error:\(error?.localizedDescription ?? "")")
            return ;
        }
        
        // If discover services, then invalidate the timeout monitor
        self.delegate?.didDiscoverServices?(peripheral)
    }
}

