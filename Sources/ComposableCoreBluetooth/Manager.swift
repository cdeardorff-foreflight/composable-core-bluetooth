//
//  Manager.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        return switch self {
        case .unknown: "unknown"
        case .resetting: "resetting"
        case .unsupported: "unsupported"
        case .unauthorized: "unauthorized"
        case .poweredOff: "poweredOff"
        case .poweredOn: "poweredOn"
        @unknown default:
            fatalError()
        }
    }
}

public struct BluetoothManager {
    
    public var delegate: @Sendable () -> Effect<Action>
    
    public var connect: (Peripheral.State, ConnectionOptions?) async -> Void
    
    public var cancelConnection: (Peripheral.State) async -> Void
    
    public var retrieveConnectedPeripherals: ([CBUUID]) async -> [Peripheral.State]
    
    public var retrievePeripherals: ([UUID]) async -> [Peripheral.State]
    
    public var scanForPeripherals: ([CBUUID]?, ScanOptions?) async -> Void
    
    public var stopScan: () async -> Void
    
    public var state: () async -> CBManagerState
    
    public var peripheralEnvironment: (UUID) async -> Peripheral.Environment?
    
    public var _authorization: () -> CBManagerAuthorization
    
    @available(macOS, unavailable)
    public var registerForConnectionEvents: (ConnectionEventOptions?) async -> Void
    
    @available(macOS, unavailable)
    public var supports: (CBCentralManager.Feature) -> Bool
    
}

extension BluetoothManager {
    
    public enum Action: Equatable {
        case didUpdateState(CBManagerState)
        case didUpdateScanningState(Bool)
        case didDiscover(Peripheral.State, AdvertismentData, NSNumber)
        case willRestore(RestorationOptions)
        
        case peripheral(UUID, Peripheral.Action)
    }
}

extension BluetoothManager {
    
    public struct InitializationOptions {
        
        let showPowerAlert: Bool?
        let restoreIdentifier: String?
        
        public init(showPowerAlert: Bool? = nil, restoreIdentifier: String? = nil) {
            self.showPowerAlert = showPowerAlert
            self.restoreIdentifier = restoreIdentifier
        }
        
        func toDictionary() -> [String: Any] {
            var dictionary = [String: Any]()
            
            if let showPowerAlert = showPowerAlert {
                dictionary[CBCentralManagerOptionShowPowerAlertKey] = NSNumber(booleanLiteral: showPowerAlert)
            }
            
            if let restoreIdentifier = restoreIdentifier {
                dictionary[CBCentralManagerOptionRestoreIdentifierKey] = restoreIdentifier as NSString
            }
            
            return dictionary
        }
    }
    
    public struct ConnectionOptions {
        
        let notifyOnConnection: Bool?
        let notifyOnDisconnection: Bool?
        let notifyOnNotification: Bool?
        let enableTransportBridging: Bool?
        let requiredANCS: Bool?
        let startDelay: NSNumber?
        
        @available(macOS, unavailable)
        public init(
            notifyOnConnection: Bool? = nil,
            notifyOnDisconnection: Bool? = nil,
            notifyOnNotification: Bool? = nil,
            enableTransportBridging: Bool? = nil,
            requiredANCS: Bool? = nil,
            startDelay: NSNumber? = nil
        ) {
            self.notifyOnConnection = notifyOnConnection
            self.notifyOnDisconnection = notifyOnDisconnection
            self.notifyOnNotification = notifyOnNotification
            self.enableTransportBridging = enableTransportBridging
            self.requiredANCS = requiredANCS
            self.startDelay = startDelay
        }
        
        public init(
            notifyOnConnection: Bool? = nil,
            notifyOnDisconnection: Bool? = nil,
            notifyOnNotification: Bool? = nil,
            startDelay: NSNumber? = nil
        ) {
            self.notifyOnConnection = notifyOnConnection
            self.notifyOnDisconnection = notifyOnDisconnection
            self.notifyOnNotification = notifyOnNotification
            self.enableTransportBridging = nil
            self.requiredANCS = nil
            self.startDelay = startDelay
        }
        
        func toDictionary() -> [String: Any] {
            var dictionary = [String: Any]()
            
            if let notifyOnConnection = notifyOnConnection {
                dictionary[CBConnectPeripheralOptionNotifyOnConnectionKey] = NSNumber(booleanLiteral: notifyOnConnection)
            }
            
            if let notifyOnDisconnection = notifyOnDisconnection {
                dictionary[CBConnectPeripheralOptionNotifyOnDisconnectionKey] = NSNumber(booleanLiteral: notifyOnDisconnection)
            }
            
            if let notifyOnNotification = notifyOnNotification {
                dictionary[CBConnectPeripheralOptionNotifyOnNotificationKey] = NSNumber(booleanLiteral: notifyOnNotification)
            }
            
            #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
            if let enableTransportBridging = enableTransportBridging {
                dictionary[CBConnectPeripheralOptionEnableTransportBridgingKey] = NSNumber(booleanLiteral: enableTransportBridging)
            }
            #endif
            
            #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
            if let requiredANCS = requiredANCS {
                dictionary[CBConnectPeripheralOptionRequiresANCS] = NSNumber(booleanLiteral: requiredANCS)
            }
            #endif
            
            if let startDelay = startDelay {
                dictionary[CBConnectPeripheralOptionStartDelayKey] = startDelay
            }
            
            return dictionary
        }
    }
    
    public struct ScanOptions: Equatable {
        
        let allowDuplicates: Bool?
        let solicitedServiceUUIDs: [CBUUID]?
        
        public init(allowDuplicates: Bool? = nil, solicitedServiceUUIDs: [CBUUID]? = nil) {
            self.allowDuplicates = allowDuplicates
            self.solicitedServiceUUIDs = solicitedServiceUUIDs
        }
        
        init(from dictionary: [String: Any]?) {
            allowDuplicates = (dictionary?[CBCentralManagerScanOptionAllowDuplicatesKey] as? NSNumber)?.boolValue
            solicitedServiceUUIDs = dictionary?[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] as? [CBUUID]
        }
        
        func toDictionary() -> [String: Any] {
            
            var dictionary = [String: Any]()
            
            if let allowDuplicates = allowDuplicates {
                dictionary[CBCentralManagerScanOptionAllowDuplicatesKey] = NSNumber(booleanLiteral: allowDuplicates)
            }
            
            if let solicitedServiceUUIDs = solicitedServiceUUIDs {
                dictionary[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] = solicitedServiceUUIDs as NSArray
            }
            
            return dictionary
        }
    }
    
    @available(macOS, unavailable)
    public struct ConnectionEventOptions {
        
        let peripheralUUIDs: [UUID]?
        let serviceUUIDs: [CBUUID]?
        
        public init(peripheralUUIDs: [UUID]? = nil, serviceUUIDs: [CBUUID]? = nil) {
            self.peripheralUUIDs = peripheralUUIDs
            self.serviceUUIDs = serviceUUIDs
        }
        
        func toDictionary() -> [CBConnectionEventMatchingOption : Any] {
            var dictionary = [CBConnectionEventMatchingOption: Any]()

            if let peripheralUUIDs = peripheralUUIDs {
                dictionary[.peripheralUUIDs] = peripheralUUIDs as NSArray
            }
            
            if let serviceUUIDs = serviceUUIDs {
                dictionary[.serviceUUIDs] = serviceUUIDs as NSArray
            }
            
            return dictionary
        }
    }
    
    public struct RestorationOptions: Equatable {
        
        public let peripherals: [Peripheral.State]?
        public let scannedServices: [CBUUID]?
        public let scanOptions: BluetoothManager.ScanOptions?
        
        init(from dictionary: [String: Any]) {
            scannedServices = dictionary[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID]
            scanOptions = ScanOptions(from: dictionary[CBCentralManagerRestoredStateScanOptionsKey] as? [String: Any])
            peripherals = (dictionary[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral])?.map(Peripheral.State.live)
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
    }
}
