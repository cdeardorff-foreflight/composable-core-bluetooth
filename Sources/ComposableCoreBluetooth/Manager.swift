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

public struct BluetoothManager: Sendable {
    
    public var delegate: @Sendable () async -> AsyncStream<Action>
    
    var connect: @Sendable (Peripheral.State, ConnectionOptions?) async -> Void
    
    var cancelConnection: @Sendable (Peripheral.State) async -> Void
    
    var retrieveConnectedPeripherals: @Sendable ([UUID]) async -> [Peripheral.State]
    
    var retrievePeripherals: @Sendable ([UUID]) async -> [Peripheral.State]
    
    var scanForPeripherals: @Sendable ([UUID]?, ScanOptions?) async -> Void
    
    var stopScan: @Sendable () async -> Void
    
    var state: @Sendable () async -> CBManagerState
    
    var peripheralEnvironment: @Sendable (UUID) async -> Peripheral.Environment?
    
    var _authorization: @Sendable () -> CBManagerAuthorization
    
    @available(macOS, unavailable)
    var registerForConnectionEvents: @Sendable (ConnectionEventOptions?) async -> Void
    
    @available(macOS, unavailable)
    var supports: @Sendable (CBCentralManager.Feature) -> Bool
}

extension BluetoothManager {
    
    public func connect(to peripheral: Peripheral.State, options: ConnectionOptions? = nil) async {
        await connect(peripheral, options)
    }
    
    public func cancelConnection(with peripheral: Peripheral.State) async {
        await cancelConnection(peripheral)
    }
    
    public func retrieveConnectedPeripherals(services: [UUID]) async -> [Peripheral.State] {
        await retrieveConnectedPeripherals(services)
    }
    
    public func retrievePeripherals(identifiers: [UUID]) async -> [Peripheral.State] {
        await retrievePeripherals(identifiers)
    }
    
    public func scanForPeripherals(services: [UUID]? = nil, options: ScanOptions? = nil) async {
        await scanForPeripherals(services, options)
    }
    
    public func stopScan() async {
        await stopScan()
    }
    
    public func state() async -> CBManagerState {
        return await state()
    }
    
    public func peripheralEnvironment(for uuid: UUID) async -> Peripheral.Environment? {
        await peripheralEnvironment(uuid)
    }
    
    @available(iOS 13.1, macOS 10.15, macCatalyst 13.1, tvOS 13.0, watchOS 6.0, *)
    public func authorization() -> CBManagerAuthorization {
        _authorization()
    }
    
    @available(macOS, unavailable)
    public func supports(_ feature: CBCentralManager.Feature) -> Bool {
        supports(feature)
    }
    
    @available(macOS, unavailable)
    public func registerForConnectionEvents(options: ConnectionEventOptions? = nil) async {
        await registerForConnectionEvents(options)
    }
}

extension BluetoothManager {
    
    public enum Action: Equatable, Sendable {
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
    
    public struct ScanOptions: Equatable, Sendable {
        
        let allowDuplicates: Bool?
        let solicitedServiceUUIDs: [UUID]?
        
        public init(allowDuplicates: Bool? = nil, solicitedServiceUUIDs: [UUID]? = nil) {
            self.allowDuplicates = allowDuplicates
            self.solicitedServiceUUIDs = solicitedServiceUUIDs
        }
        
        init(from dictionary: [String: Any]?) {
            allowDuplicates = (dictionary?[CBCentralManagerScanOptionAllowDuplicatesKey] as? NSNumber)?.boolValue
            solicitedServiceUUIDs = (dictionary?[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] as? [CBUUID])?.map(\.uuidValue)
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
        let serviceUUIDs: [UUID]?
        
        public init(peripheralUUIDs: [UUID]? = nil, serviceUUIDs: [UUID]? = nil) {
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
    
    public struct RestorationOptions: Equatable, Sendable {
        
        public let peripherals: [Peripheral.State]?
        public let scannedServices: [UUID]?
        public let scanOptions: BluetoothManager.ScanOptions?
        
        init(from dictionary: [String: Any]) {
            scannedServices = (dictionary[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID])?.map(\.uuidValue)
            scanOptions = ScanOptions(from: dictionary[CBCentralManagerRestoredStateScanOptionsKey] as? [String: Any])
            peripherals = (dictionary[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral])?.map(Peripheral.State.live)
        }
    }
    
    public struct AdvertismentData: Equatable, Sendable {
        
        public let localName: String?
        public let manufacturerData: Data?
        public let serviceData: [UUID: Data]?
        public let serviceUUIDs: [UUID]?
        public let overflowServiceUUIDs: [UUID]?
        public let solicitedServiceUUIDs: [UUID]?
        public let txPowerLevel: NSNumber?
        public let isConnectable: Bool?
        
        public init(
            localName: String? = nil,
            manufacturerData: Data? = nil,
            serviceData: [UUID: Data]? = nil,
            serviceUUIDs: [UUID]? = nil,
            overflowServiceUUIDs: [UUID]? = nil,
            solicitedServiceUUIDs: [UUID]? = nil,
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
            let providedServiceData = (dictionary[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data])
            serviceData = Dictionary(uniqueKeysWithValues: (providedServiceData ?? [:]).map {
                return ($0.key.uuidValue, $0.value)
            })
            serviceUUIDs = (dictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.map(\.uuidValue)
            overflowServiceUUIDs = (dictionary[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID])?.map(\.uuidValue)
            solicitedServiceUUIDs = (dictionary[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID])?.map(\.uuidValue)
        }
    }
}
