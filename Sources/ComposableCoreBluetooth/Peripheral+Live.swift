//
//  Peripheral.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import CoreBluetooth
import ComposableArchitecture
import Combine

extension Peripheral.State {
    
    public static func live(from cbPeripheral: CBPeripheral) -> Self {
        #if !os(macOS)
        return Peripheral.State(
            identifier: cbPeripheral.identifier,
            name: cbPeripheral.name,
            state: cbPeripheral.state,
            canSendWriteWithoutResponse: cbPeripheral.canSendWriteWithoutResponse,
            isANCSAuthorized: cbPeripheral.ancsAuthorized,
            services: cbPeripheral.services?.map(Service.init) ?? []
        )
        #else
        return Peripheral.State(
            identifier: cbPeripheral.identifier,
            name: cbPeripheral.name,
            state: cbPeripheral.state,
            canSendWriteWithoutResponse: cbPeripheral.canSendWriteWithoutResponse,
            services: cbPeripheral.services?.map(Service.init) ?? []
        )
        #endif
    }
}

extension Peripheral.Environment {
    
    static func live(from cbPeripheral: CBPeripheral, continuation: AsyncStream<BluetoothManager.Action>.Continuation) -> Self {
        
        var environment = Peripheral.Environment()
        
        environment.rawValue = cbPeripheral
        environment.delegate = Delegate(continuation)
        cbPeripheral.delegate = environment.delegate
        environment.stateCancelable = cbPeripheral
            .publisher(for: \.state)
            .sink { state in
                continuation.yield(.peripheral(cbPeripheral.identifier, .didUpdateState(state)))
            }
        
        environment.readRSSI = {
            cbPeripheral.readRSSI()
        }
        
        environment.openL2CAPChannel = { psm in
            cbPeripheral.openL2CAPChannel(psm)
        }
        
        environment.discoverServices = { ids in
            cbPeripheral.discoverServices(ids)
        }
        
        environment.discoverIncludedServices = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return
            }
            
            cbPeripheral.discoverIncludedServices(ids, for: rawService)
        }
        
        environment.discoverCharacteristics = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return
            }
            
            cbPeripheral.discoverCharacteristics(ids, for: rawService)
        }
        
        environment.discoverDescriptors = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return
            }
            
            cbPeripheral.discoverDescriptors(for: rawCharacteristic)
        }
        
        environment.readCharacteristicValue = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return
            }
            
            cbPeripheral.readValue(for: rawCharacteristic)
        }
        
        environment.readDescriptorValue = { descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return
            }
            
            cbPeripheral.readValue(for: rawDescriptor)
        }
        
        environment.writeCharacteristicValue = { data, characteristic, writeType in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return
            }
            
            cbPeripheral.writeValue(data, for: rawCharacteristic, type: writeType)
        }
        
        environment.writeDescriptorValue = { data, descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return
            }
            
            cbPeripheral.writeValue(data, for: rawDescriptor)
        }
        
        environment.setNotifyValue = { value, characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return
            }
            
            cbPeripheral.setNotifyValue(value, for: rawCharacteristic)
        }
        
        return environment
    }
}

extension Peripheral.Environment {
    
    class Delegate: NSObject, CBPeripheralDelegate {
        let continuation: AsyncStream<BluetoothManager.Action>.Continuation
        
        init(_ continuation: AsyncStream<BluetoothManager.Action>.Continuation) {
            self.continuation = continuation
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .didDiscoverServices(convertToResult(peripheral.services?.map(Service.init(from:)) ?? [], error: error))
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .service(
                        service.uuid.uuidValue,
                        .didDiscoverIncludedServices(convertToResult(service.includedServices?.map(Service.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .service(
                        service.uuid.uuidValue,
                        .didDiscoverCharacteristics(convertToResult(service.characteristics?.map(Characteristic.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid.uuidValue,
                        .didDiscoverDescriptors(convertToResult(characteristic.descriptors?.map(Descriptor.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid.uuidValue,
                        .didUpdateValue(convertToResult(characteristic.value, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .descriptor(
                        descriptor.uuid.uuidValue,
                        .didUpdateValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid.uuidValue, descriptor.value), error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid.uuidValue,
                        .didWriteValue(convertToResult(characteristic.value, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .descriptor(
                        descriptor.uuid.uuidValue,
                        .didWriteValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid.uuidValue, descriptor.value), error: error))
                    )
                )
            )
        }
        
        func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .isReadyToSendWriteWithoutResponse
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid.uuidValue,
                        .didUpdateNotificationState(convertToResult(characteristic.isNotifying, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .didReadRSSI(convertToResult(RSSI, error: error))
                )
            )
        }
        
        func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .didUpdateName(peripheral.name)
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .didModifyServices(invalidatedServices.map(Service.init))
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .didOpenL2CAPChannel(convertToResult(L2CAPChannel(rawValue: channel), error: error))
                )
            )
        }
    }
}
