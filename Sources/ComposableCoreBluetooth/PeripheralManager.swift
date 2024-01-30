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
public struct PeripheralManager: Sendable {
    
    public var delegate: @Sendable () async -> AsyncStream<Action>
    
    public var addService: @Sendable (MutableService) async -> Void
    
    public var removeService: @Sendable (MutableService) async -> Void
    
    public var removeAllServices: @Sendable () async -> Void
        
    public var startAdvertising: @Sendable (AdvertisementData?) async -> Void
    
    public var stopAdvertising: @Sendable () async -> Void

    public var updateValue: @Sendable (Data, MutableCharacteristic, [Central]?) async -> Bool
    
    public var respondToRequest: @Sendable (ATTRequest, CBATTError.Code) async -> Void

    public var setDesiredConnectionLatency: @Sendable (CBPeripheralManagerConnectionLatency, Central) async -> Void

    public var publishL2CAPChannel: @Sendable (Bool) async -> Void

    public var unpublishL2CAPChannel: @Sendable (CBL2CAPPSM) async -> Void

    public var state: @Sendable () async -> CBManagerState
    
    public var _authorization: @Sendable () -> CBManagerAuthorization
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public func add(service: MutableService) async {
        await addService(service)
    }
    
    public func remove(service: MutableService) async {
        await removeService(service)
    }
    
    public func removeAllServices() async {
        await removeAllServices()
    }
    
    public func startAdvertising(_ advertisementData: AdvertisementData?) async {
        await startAdvertising(advertisementData)
    }
    
    public func stopAdvertising() async {
        await stopAdvertising()
    }
    
    public func updateValue(_ data: Data, for characteristic: MutableCharacteristic, onSubscribed centrals: [Central]?) async -> Bool {
        await updateValue(data, characteristic, centrals)
    }
    
    public func respond(to request: ATTRequest, with result: CBATTError.Code) async {
        await respondToRequest(request, result)
    }
    
    public func setDesiredConnectionLatency(_ latency: CBPeripheralManagerConnectionLatency, for central: Central) async {
        await setDesiredConnectionLatency(latency, central)
    }
    
    public func publishL2CAPChannel(withEncryption: Bool) async {
        await publishL2CAPChannel(withEncryption)
    }
    
    public func unpublishL2CAPChannel(_ psm: CBL2CAPPSM) async {
        await unpublishL2CAPChannel(psm)
    }
    
    @available(iOS 13.1, macOS 10.15, macCatalyst 13.1, tvOS 13.0, watchOS 6.0, *)
    public func authorization() -> CBManagerAuthorization {
        _authorization()
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    public enum Action: Equatable, Sendable {
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
    
    public struct RestorationOptions: Equatable, Sendable {
        
        public let services: [Service]?
        public let advertisementData: AdvertisementData?
        
        init(from dictionary: [String: Any]) {
            services = (dictionary[CBPeripheralManagerRestoredStateServicesKey] as? [CBService])?.map(Service.init)
            advertisementData = (dictionary[CBPeripheralManagerRestoredStateAdvertisementDataKey] as? [String: Any]).map(AdvertisementData.init)
        }
    }
    
    public struct AdvertisementData: Equatable, Sendable {
        
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
