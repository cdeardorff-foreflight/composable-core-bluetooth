//
//  Peripheral+Mock.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import ComposableArchitecture
import CoreBluetooth
import XCTestDynamicOverlay


extension Peripheral.State {
    
    #if !os(macOS)
    public static func mock(
        identifier: UUID,
        name: String?,
        state: CBPeripheralState,
        canSendWriteWithoutResponse: Bool,
        isANCSAuthorized: Bool,
        services: [Service]
    ) -> Self {
        Self(
            identifier: identifier,
            name: name,
            state: state,
            canSendWriteWithoutResponse: canSendWriteWithoutResponse,
            isANCSAuthorized: isANCSAuthorized,
            services: services
        )
    }
    
    #else
    public static func mock(
        identifier: UUID,
        name: String?,
        state: CBPeripheralState,
        canSendWriteWithoutResponse: Bool,
        services: [Service]
    ) -> Self {
        Self(
            identifier: identifier,
            name: name,
            state: state,
            canSendWriteWithoutResponse: canSendWriteWithoutResponse,
            services: services
        )
    }
    #endif
}

import class Combine.AnyCancellable

extension Peripheral.Environment {
    
    public static func mock(
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
    ) -> Self {
        Self(
            rawValue: nil,
            delegate: nil,
            stateCancelable: nil,
            readRSSI: readRSSI,
            discoverServices: discoverServices,
            discoverIncludedServices: discoverIncludedServices,
            discoverCharacteristics: discoverCharacteristics,
            discoverDescriptors: discoverDescriptors,
            readCharacteristicValue: readCharacteristicValue,
            readDescriptorValue: readDescriptorValue,
            writeCharacteristicValue: writeCharacteristicValue,
            writeDescriptorValue: writeDescriptorValue,
            setNotifyValue: setNotifyValue,
            openL2CAPChannel: openL2CAPChannel,
            maximumWriteValueLength: maximumWriteValueLength
        )
    }
    
    public static func failing(
        readRSSI: @escaping () async -> Void = { fail("readRSSI") },
        discoverServices: @escaping ([CBUUID]?) async -> Void = { _ in fail("discoverServices") },
        discoverIncludedServices: @escaping ([CBUUID]?, Service) async -> Void = { _, _ in fail("discoverIncludedServices") },
        discoverCharacteristics: @escaping ([CBUUID]?, Service) async -> Void = { _, _ in fail("discoverCharacteristics") },
        discoverDescriptors: @escaping (Characteristic) async -> Void = { _ in fail("discoverDescriptors") },
        readCharacteristicValue: @escaping (Characteristic) async -> Void = { _ in fail("readCharacteristicValue")},
        readDescriptorValue: @escaping (Descriptor) async -> Void = { _ in fail("readDescriptorValue") },
        writeCharacteristicValue: @escaping (Data, Characteristic, CBCharacteristicWriteType) async -> Void = { _, _, _ in fail("writeCharacteristicValue") },
        writeDescriptorValue: @escaping (Data, Descriptor) async -> Void = { _, _ in fail("writeDescriptorValue") },
        setNotifyValue: @escaping (Bool, Characteristic) async -> Void = { _, _ in fail("setNotifyValue") },
        openL2CAPChannel: @escaping (CBL2CAPPSM) async -> Void = { _ in fail("openL2CAPChannel") },
        maximumWriteValueLength: @escaping (CBCharacteristicWriteType) -> Int = { _ in
            fail("maximumWriteValueLength")
            return 0
        }
    ) -> Self {
        Self(
            rawValue: nil,
            delegate: nil,
            stateCancelable: nil,
            readRSSI: readRSSI,
            discoverServices: discoverServices,
            discoverIncludedServices: discoverIncludedServices,
            discoverCharacteristics: discoverCharacteristics,
            discoverDescriptors: discoverDescriptors,
            readCharacteristicValue: readCharacteristicValue,
            readDescriptorValue: readDescriptorValue,
            writeCharacteristicValue: writeCharacteristicValue,
            writeDescriptorValue: writeDescriptorValue,
            setNotifyValue: setNotifyValue,
            openL2CAPChannel: openL2CAPChannel,
            maximumWriteValueLength: maximumWriteValueLength
        )
    }
}
