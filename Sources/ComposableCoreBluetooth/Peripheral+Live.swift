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
            .fireAndForget { cbPeripheral.readRSSI() }
        }
        
        environment.openL2CAPChannel = { psm in
            .fireAndForget { cbPeripheral.openL2CAPChannel(psm) }
        }

        environment.discoverServices = { ids in
            .fireAndForget { cbPeripheral.discoverServices(ids) }
        }
        
        environment.discoverIncludedServices = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverIncludedServices(ids, for: rawService) }
        }
        
        environment.discoverCharacteristics = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverCharacteristics(ids, for: rawService) }
        }
        
        environment.discoverDescriptors = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverDescriptors(for: rawCharacteristic) }
        }
        
        environment.readCharacteristicValue = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.readValue(for: rawCharacteristic) }
        }
        
        environment.readDescriptorValue = { descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.readValue(for: rawDescriptor) }
        }
        
        environment.writeCharacteristicValue = { data, characteristic, writeType in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.writeValue(data, for: rawCharacteristic, type: writeType) }
        }
        
        environment.writeDescriptorValue = { data, descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.writeValue(data, for: rawDescriptor) }
        }
        
        environment.setNotifyValue = { value, characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.setNotifyValue(value, for: rawCharacteristic) }
        }
        
        return environment
    }
    
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
                        service.uuid,
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
                        service.uuid,
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
                        characteristic.uuid,
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
                        characteristic.uuid,
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
                        descriptor.uuid,
                        .didUpdateValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid, descriptor.value), error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            continuation.yield(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid,
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
                        descriptor.uuid,
                        .didWriteValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid, descriptor.value), error: error))
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
                        characteristic.uuid,
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
                    .didOpenL2CAPChannel(convertToResult(channel, error: error))
                )
            )
        }
    }
}
