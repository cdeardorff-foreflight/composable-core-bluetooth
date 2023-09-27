//
//  Manager+Live.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import ComposableArchitecture

private struct BluetoothManagerSendableBox: Sendable {
    @UncheckedSendable var manager: CBCentralManager
    var delegateStream: AsyncStream<BluetoothManager.Action>
    var continuation: AsyncStream<BluetoothManager.Action>.Continuation
    var delegate: BluetoothManager.Delegate
    var scanningCancellable: AnyCancellable
}

extension BluetoothManager {
    
    private struct CreateId: Hashable { }
    
    public static func live(queue: DispatchQueue?, options: InitializationOptions?) -> BluetoothManager {
        
        let task = Task<BluetoothManagerSendableBox, Never> { @MainActor in
            
            var continuation: AsyncStream<Action>.Continuation!
            var stream = AsyncStream<Action> { continuation = $0 }
            
            let delegate = Delegate(continuation: continuation)
            let manager = CBCentralManager(
                delegate: delegate,
                queue: queue,
                options: options?.toDictionary()
            )
            
            let scanningCancellable = manager
                .publisher(for: \.isScanning)
                .map(BluetoothManager.Action.didUpdateScanningState)
                .sink { continuation.yield($0) }
                
            return .init(manager: manager, delegateStream: stream, continuation: continuation, delegate: delegate, scanningCancellable: scanningCancellable)
        }
        
        return Self(
            delegate: {
                return .run { send in
                    let stream = await task.value.delegateStream
                    for try await action in stream {
                        await send(action)
                    }
                }
            },
            connect: { peripheral, options in
                let manager = await task.value.manager
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.connect(rawPeripheral, options: options?.toDictionary())
            },
            cancelConnection: { peripheral in
                let manager = await task.value.manager
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.cancelPeripheralConnection(rawPeripheral)
            },
            retrieveConnectedPeripherals: { uuids in
                return await task.value.manager
                    .retrieveConnectedPeripherals(withServices: uuids)
                    .map(Peripheral.State.live)
            },
            retrievePeripherals: { uuids in
                return await task.value.manager
                    .retrievePeripherals(withIdentifiers: uuids)
                    .map(Peripheral.State.live)
            },
            scanForPeripherals: { services, options in
                await task.value.manager.scanForPeripherals(withServices: services, options: options?.toDictionary())
            },
            stopScan: {
                await task.value.manager.stopScan()
            },
            state: {
                return await task.value.manager.state
            },
            peripheralEnvironment: { (uuid) -> Peripheral.Environment? in
                let value = await task.value
                guard let rawPeripheral = value.manager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                    couldNotFindRawPeripheralValue()
                    return nil
                }
                
                return Peripheral.Environment.live(from: rawPeripheral, continuation: value.continuation)
            },
            _authorization: {
                CBCentralManager.authorization
            },
            registerForConnectionEvents: { options in
                await task.value.manager.registerForConnectionEvents(options: options?.toDictionary())
            },
        
            supports: CBCentralManager.supports
        )
    }
}

extension BluetoothManager {
    final class Delegate: NSObject, CBCentralManagerDelegate, Sendable {
        let continuation: AsyncStream<BluetoothManager.Action>.Continuation
        
        init(continuation: AsyncStream<BluetoothManager.Action>.Continuation) {
            self.continuation = continuation
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            continuation.yield(.peripheral(peripheral.identifier, .didConnect))
        }
        
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            if let error = error {
                if let error = error as? CBError {
                    continuation.yield(.peripheral(peripheral.identifier, .didDisconnect(.coreBluetooth(error))))
                } else {
                    continuation.yield(.peripheral(peripheral.identifier, .didDisconnect(.unknown(error.localizedDescription))))
                }
            } else {
                continuation.yield(.peripheral(peripheral.identifier, .didDisconnect(.none)))
            }
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            if let error = error {
                if let error = error as? CBError {
                    continuation.yield(.peripheral(peripheral.identifier, .didFailToConnect(.coreBluetooth(error))))
                } else {
                    continuation.yield(.peripheral(peripheral.identifier, .didFailToConnect(.unknown(error.localizedDescription))))
                }
            } else {
                continuation.yield(.peripheral(peripheral.identifier, .didFailToConnect(.unknown(.none))))
            }
        }
        
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
            continuation.yield(.didDiscover(Peripheral.State.live(from: peripheral), BluetoothManager.AdvertismentData(from: advertisementData), RSSI))
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            continuation.yield(.didUpdateState(central.state))
        }
        
        func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
            continuation.yield(.willRestore(RestorationOptions(from: dict)))
        }
        
#if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
            continuation.yield(.peripheral(peripheral.identifier, .connectionEventDidOccur(event)))
        }
#endif
        
#if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
            continuation.yield(.peripheral(peripheral.identifier, .didUpdateANCSAuthorization(peripheral.ancsAuthorized)))
        }
#endif
    }
}
