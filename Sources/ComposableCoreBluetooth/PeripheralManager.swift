//
//  PeripheralManager.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 29.10.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct PeripheralManager {
    
    var create: (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
        _unimplemented("create")
    }
    
    var destroy: (AnyHashable) -> Effect<Never> = { _ in
        _unimplemented("destroy")
    }
    
    var addService: (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
        _unimplemented("addService")
    }
    
    var removeService: (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
        _unimplemented("removeService")
    }
    
    var removeAllServices: (AnyHashable) -> Effect<Never> = { _ in
        _unimplemented("removeAllServices")
    }
    
    var startAdvertising: (AnyHashable, AdvertismentData?) -> Effect<Never> = { _, _ in
        _unimplemented("startAdvertising")
    }
    
    var stopAdvertising: (AnyHashable) -> Effect<Never> = { _ in
        _unimplemented("stopAdvertising")
    }
    
    var updateValue: (AnyHashable, Data, MutableCharacteristic, [Central]?) -> Effect<Bool> = { _, _, _, _ in
        _unimplemented("updateValue")
    }
    
    var respondToRequest: (AnyHashable, ATTRequest, CBATTError.Code) -> Effect<Never> = { _, _, _ in
        _unimplemented("respondToRequest")
    }
    
    var setDesiredConnectionLatency: (AnyHashable, CBPeripheralManagerConnectionLatency, Central) -> Effect<Never> = { _, _, _ in
        _unimplemented("setDesiredConnectionLatency")
    }
    
    var publishL2CAPChannel: (AnyHashable, Bool) -> Effect<Never> = { _, _ in
        _unimplemented("publishL2CAPChannel")
    }
    
    var unpublishL2CAPChannel: (AnyHashable, CBL2CAPPSM) -> Effect<Never> = { _, _ in
        _unimplemented("unpublishL2CAPChannel")
    }
    
    var state: (AnyHashable) -> CBManagerState = { _ in
        _unimplemented("state")
    }
    
    var _authorization: () -> CBManagerAuthorization = {
        _unimplemented("authorization")
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public func create(id: AnyHashable, queue: DispatchQueue?, options: InitializationOptions?) -> Effect<Action> {
        create(id, queue, options)
    }
    
    public func destroy(id: AnyHashable) -> Effect<Never> {
        destroy(id)
    }
    
    public func add(id: AnyHashable, service: MutableService) -> Effect<Never> {
        addService(id, service)
    }
    
    public func remove(id: AnyHashable, service: MutableService) -> Effect<Never> {
        removeService(id, service)
    }
    
    public func removeAllServices(id: AnyHashable) -> Effect<Never> {
        removeAllServices(id)
    }
    
    public func startAdvertising(id: AnyHashable, _ adverstimentData: AdvertismentData?) -> Effect<Never> {
        startAdvertising(id, adverstimentData)
    }
    
    public func stopAdvertising(id: AnyHashable) -> Effect<Never> {
        stopAdvertising(id)
    }
    
    public func updateValue(id: AnyHashable, _ data: Data, for characteristic: MutableCharacteristic, onSubscribed centrals: [Central]?) -> Effect<Bool> {
        updateValue(id, data, characteristic, centrals)
    }
    
    public func respond(id: AnyHashable, to request: ATTRequest, with result: CBATTError.Code) -> Effect<Never> {
        respondToRequest(id, request, result)
    }
    
    public func setDesiredConnectionLatency(id: AnyHashable, _ latency: CBPeripheralManagerConnectionLatency, for central: Central) -> Effect<Never> {
        setDesiredConnectionLatency(id, latency, central)
    }
    
    public func publishL2CAPChannel(id: AnyHashable, withEncryption: Bool) -> Effect<Never> {
        publishL2CAPChannel(id, withEncryption)
    }
    
    public func unpublishL2CAPChannel(id: AnyHashable, _ psm: CBL2CAPPSM) -> Effect<Never> {
        unpublishL2CAPChannel(id, psm)
    }
    
    @available(iOS 13.1, macOS 10.15, macCatalyst 13.1, tvOS 13.0, watchOS 6.0, *)
    public func authorization() -> CBManagerAuthorization {
        _authorization()
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public enum Action: Equatable {
        case willRestore(RestorationOptions)
        case didAddService(Result<Service, BluetoothError>)
        case didSubscribeTo(Characteristic, Central)
        case didUnsubscribeFrom(Characteristic, Central)
        case isReadyToUpdateSubscribers
        case didReceiveRead(ATTRequest)
        case didReceiveWrite([ATTRequest])
        case didPublishL2CAPChannel(Result<CBL2CAPPSM, BluetoothError>)
        case didUnpublishL2CAPChannel(Result<CBL2CAPPSM, BluetoothError>)
        case didOpen(Result<CBL2CAPChannel, BluetoothError>)
        
        case didUpdateState(CBManagerState)
        case didUpdateAdvertisingState(Result<Bool, BluetoothError>)
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public struct InitializationOptions {
        
        public let showPowerAlert: Bool?
        public let restoreIdentifier: String?
        
        public init(showPowerAlert: Bool? = nil, restoreIdentifier: String? = nil) {
            self.showPowerAlert = showPowerAlert
            self.restoreIdentifier = restoreIdentifier
        }
        
        func toDictionary() -> [String: Any] {
            var dictionary = [String: Any]()
            
            if let showPowerAlert = showPowerAlert {
                dictionary[CBPeripheralManagerOptionShowPowerAlertKey] = NSNumber(booleanLiteral: showPowerAlert)
            }
            
            if let restoreIdentifier = restoreIdentifier {
                dictionary[CBPeripheralManagerOptionRestoreIdentifierKey] = restoreIdentifier as NSString
            }
            
            return dictionary
        }
    }
    
    public struct RestorationOptions: Equatable {
        
        public let services: [Service]?
        public let advertismentData: AdvertismentData?
        
        init(from dictionary: [String: Any]) {
            services = (dictionary[CBPeripheralManagerRestoredStateServicesKey] as? [CBService])?.map(Service.init)
            advertismentData = (dictionary[CBPeripheralManagerRestoredStateAdvertisementDataKey] as? [String: Any]).map(AdvertismentData.init)
        }
    }
    
    public struct AdvertismentData: Equatable {
        
        public let localName: String?
        public let manufacturerData: Data?
        public let serviceData: [CBUUID: Data]?
        public let serviceUUIDs: [CBUUID]?
        public let overflowServiceUUIDs: [CBUUID]?
        public let solicitedServiceUUIDs: [CBUUID]?
        public let txPowerLevel: NSNumber?
        public let isConnectable: Bool?
        
        public init(
            localName: String? = nil,
            manufacturerData: Data? = nil,
            serviceData: [CBUUID: Data]? = nil,
            serviceUUIDs: [CBUUID]? = nil,
            overflowServiceUUIDs: [CBUUID]? = nil,
            solicitedServiceUUIDs: [CBUUID]? = nil,
            txPowerLevel: NSNumber? = nil,
            isConnectable: Bool? = nil
        ) {
            self.localName = localName
            self.manufacturerData = manufacturerData
            self.serviceData = serviceData
            self.serviceUUIDs = serviceUUIDs
            self.overflowServiceUUIDs = overflowServiceUUIDs
            self.solicitedServiceUUIDs = solicitedServiceUUIDs
            self.txPowerLevel = txPowerLevel
            self.isConnectable = isConnectable
        }
        
        init(from dictionary: [String: Any]) {
            localName = dictionary[CBAdvertisementDataLocalNameKey] as? String
            manufacturerData = dictionary[CBAdvertisementDataManufacturerDataKey] as? Data
            txPowerLevel = dictionary[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
            isConnectable = (dictionary[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
            serviceData = dictionary[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
            serviceUUIDs = dictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
            overflowServiceUUIDs = dictionary[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
            solicitedServiceUUIDs = dictionary[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
        }
        
        func toDictionary() -> [String: Any] {
            var dictionary = [String: Any]()
            
            if let localName = localName {
                dictionary[CBAdvertisementDataLocalNameKey] = localName as NSString
            }
            
            if let manufacturerData = manufacturerData {
                dictionary[CBAdvertisementDataManufacturerDataKey] = manufacturerData as NSData
            }
            
            if let txPowerLevel = txPowerLevel {
                dictionary[CBAdvertisementDataTxPowerLevelKey] = txPowerLevel
            }
            
            if let isConnectable = isConnectable {
                dictionary[CBAdvertisementDataIsConnectable] = NSNumber(booleanLiteral: isConnectable)
            }
            
            if let serviceData = serviceData {
                dictionary[CBAdvertisementDataServiceDataKey] = serviceData as [CBUUID: NSData]
            }
            
            if let serviceUUIDs = serviceUUIDs {
                dictionary[CBAdvertisementDataServiceUUIDsKey] = serviceUUIDs
            }
            
            if let overflowServiceUUIDs = overflowServiceUUIDs {
                dictionary[CBAdvertisementDataOverflowServiceUUIDsKey] = overflowServiceUUIDs
            }
            
            if let solicitedServiceUUIDs = solicitedServiceUUIDs {
                dictionary[CBAdvertisementDataSolicitedServiceUUIDsKey] = solicitedServiceUUIDs
            }
            
            return dictionary
        }
    }
}
