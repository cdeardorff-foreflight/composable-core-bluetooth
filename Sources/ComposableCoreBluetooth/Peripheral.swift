//
//  Peripheral.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import CoreBluetooth
import Combine
import ComposableArchitecture

extension CBPeripheralState: Hashable {}

public enum Peripheral {
    
    public struct State: Equatable, Hashable, Sendable {
        
        public let identifier: UUID
        public var name: String?
        public var state: CBPeripheralState
        public let canSendWriteWithoutResponse: Bool
        public var services: [Service]
        
        #if !os(macOS)
        public var isANCSAuthorized: Bool
        
        init(
            identifier: UUID,
            name: String?,
            state: CBPeripheralState,
            canSendWriteWithoutResponse: Bool,
            isANCSAuthorized: Bool,
            services: [Service]
        ) {
            self.identifier = identifier
            self.name = name
            self.state = state
            self.canSendWriteWithoutResponse = canSendWriteWithoutResponse
            self.isANCSAuthorized = isANCSAuthorized
            self.services = services
        }
        #else
        init(
            identifier: UUID,
            name: String?,
            state: CBPeripheralState,
            canSendWriteWithoutResponse: Bool,
            services: [Service]
        ) {
            self.identifier = identifier
            self.name = name
            self.state = state
            self.canSendWriteWithoutResponse = canSendWriteWithoutResponse
            self.services = services
        }
        #endif
    }
    
    public struct Environment {
        
        var rawValue: CBPeripheral?
        var delegate: CBPeripheralDelegate?
        var stateCancelable: AnyCancellable?
        
        public internal(set) var readRSSI: () async -> Void
        var discoverServices: ([CBUUID]?) async -> Void
        var discoverIncludedServices: ([CBUUID]?, Service) async -> Void
        var discoverCharacteristics: ([CBUUID]?, Service) async -> Void
        var discoverDescriptors: (Characteristic) async -> Void
        var readCharacteristicValue: (Characteristic) async -> Void
        var readDescriptorValue: (Descriptor) async -> Void
        var writeCharacteristicValue: (Data, Characteristic, CBCharacteristicWriteType) async -> Void
        var writeDescriptorValue: (Data, Descriptor) async -> Void
        var setNotifyValue: (Bool, Characteristic) async -> Void
        var openL2CAPChannel: (CBL2CAPPSM) async -> Void
        var maximumWriteValueLength: (CBCharacteristicWriteType) -> Int

        init(
            rawValue: CBPeripheral? = nil,
            delegate: CBPeripheralDelegate? = nil,
            stateCancelable: AnyCancellable? = nil,
            readRSSI: @escaping () async -> Void = { _unimplemented("readRSSI") },
            discoverServices: @escaping ([CBUUID]?) async -> Void = { _ in _unimplemented("discoverServices") },
            discoverIncludedServices: @escaping ([CBUUID]?, Service) async -> Void = { _, _ in _unimplemented("discoverIncludedServices") },
            discoverCharacteristics: @escaping ([CBUUID]?, Service) async -> Void = { _, _ in _unimplemented("discoverCharacteristics") },
            discoverDescriptors: @escaping (Characteristic) async -> Void = { _ in _unimplemented("discoverDescriptors") },
            readCharacteristicValue: @escaping (Characteristic) async -> Void = { _ in _unimplemented("readCharacteristicValue")},
            readDescriptorValue: @escaping (Descriptor) async -> Void = { _ in _unimplemented("readDescriptorValue") },
            writeCharacteristicValue: @escaping (Data, Characteristic, CBCharacteristicWriteType) async -> Void = { _, _, _ in _unimplemented("writeCharacteristicValue") },
            writeDescriptorValue: @escaping (Data, Descriptor) async -> Void = { _, _ in _unimplemented("writeDescriptorValue") },
            setNotifyValue: @escaping (Bool, Characteristic) async -> Void = { _, _ in _unimplemented("setNotifyValue") },
            openL2CAPChannel: @escaping (CBL2CAPPSM) async -> Void = { _ in _unimplemented("openL2CAPChannel") },
            maximumWriteValueLength: @escaping (CBCharacteristicWriteType) -> Int = { _ in _unimplemented("maximumWriteValueLength") }
        ) {
            self.rawValue = rawValue
            self.delegate = delegate
            self.stateCancelable = stateCancelable
            self.readRSSI = readRSSI
            self.discoverServices = discoverServices
            self.discoverIncludedServices = discoverIncludedServices
            self.discoverCharacteristics = discoverCharacteristics
            self.discoverDescriptors = discoverDescriptors
            self.readCharacteristicValue = readCharacteristicValue
            self.readDescriptorValue = readDescriptorValue
            self.writeCharacteristicValue = writeCharacteristicValue
            self.writeDescriptorValue = writeDescriptorValue
            self.setNotifyValue = setNotifyValue
            self.openL2CAPChannel = openL2CAPChannel
            self.maximumWriteValueLength = maximumWriteValueLength
        }
        
        public func discoverServices(_ uuids: [CBUUID]? = nil) async -> Void {
            await discoverServices(uuids)
        }
        
        public func discoverIncludedServices(_ uuids: [CBUUID]? = nil, for service: Service) async -> Void {
            await discoverIncludedServices(uuids, service)
        }
        
        public func discoverCharacteristics(_ uuids: [CBUUID]? = nil, for service: Service) async -> Void {
            await discoverCharacteristics(uuids, service)
        }
        
        public func discoverDescriptors(for characteristic: Characteristic) async -> Void {
            await discoverDescriptors(characteristic)
        }
        
        public func readValue(for characteristic: Characteristic) async -> Void {
            await readCharacteristicValue(characteristic)
        }
        
        public func readValue(for descriptor: Descriptor) async -> Void {
            await readDescriptorValue(descriptor)
        }
        
        public func writeValue(_ data: Data, for characteristic: Characteristic, type: CBCharacteristicWriteType) async -> Void {
            await writeCharacteristicValue(data, characteristic, type)
        }
        
        public func writeValue(_ data: Data, for descriptor: Descriptor) async -> Void {
            await writeDescriptorValue(data, descriptor)
        }
            
        public func setNotifyValue(_ enabled: Bool, for characteristic: Characteristic) async -> Void {
            await setNotifyValue(enabled, characteristic)
        }
        
        public func openL2CAPChannel(_ psm: CBL2CAPPSM) async -> Void {
            await openL2CAPChannel(psm)
        }
        
        public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
            maximumWriteValueLength(type)
        }
    }
}

extension Peripheral.State: Identifiable {
    public var id: UUID {
        identifier
    }
}

extension Peripheral: Equatable {}

extension Peripheral {
    public enum Action: Equatable, Sendable {
        case isReadyToSendWriteWithoutResponse
        case didUpdateName(String?)
        case didUpdateState(CBPeripheralState)
        case didModifyServices([Service])
        case didReadRSSI(Result<NSNumber, BluetoothError>)
        case didOpenL2CAPChannel(Result<L2CAPChannel, BluetoothError>)
        case didDiscoverServices(Result<[Service], BluetoothError>)
        
        case didConnect
        case didDisconnect(BluetoothError?)
        case didFailToConnect(BluetoothError)
        
        @available(macOS, unavailable)
        case didUpdateANCSAuthorization(Bool)
        
        @available(macOS, unavailable)
        case connectionEventDidOccur(CBConnectionEvent)

        case service(UUID, Service.Action)
        case characteristic(UUID, Characteristic.Action)
        case descriptor(UUID, Descriptor.Action)
    }
}
