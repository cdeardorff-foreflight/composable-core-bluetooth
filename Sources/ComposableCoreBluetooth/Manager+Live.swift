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

private class DelegateRetainingCBCentralManager: CBCentralManager {
    private let retainedDelegate: CBCentralManagerDelegate?
    
    override init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: [String : Any]? = nil) {
        self.retainedDelegate = delegate
        super.init(delegate: delegate, queue: queue, options: options)
    }
}

private struct BluetoothManagerSendableBox: Sendable {
    @UncheckedSendable var manager: CBCentralManager
    var delegateStream: AsyncStream<BluetoothManager.Action>
    var delegateStreamContinuation: AsyncStream<BluetoothManager.Action>.Continuation
}

extension BluetoothManager {
        
    public static func live(queue: DispatchQueue?, options: InitializationOptions?) -> BluetoothManager {
        let task = Task<BluetoothManagerSendableBox, Never>(operation: { @MainActor in
            var continuation: AsyncStream<Action>.Continuation!
            let stream = AsyncStream<Action> { continuation = $0 }
            
            let delegate = Delegate(continuation: continuation)
            let manager = DelegateRetainingCBCentralManager(
                delegate: delegate,
                queue: queue,
                options: options?.toDictionary()
            )
            
            return .init(
                manager: manager,
                delegateStream: stream,
                delegateStreamContinuation: continuation)
        })
        
        
        return Self(
            delegate: { @MainActor in
                let box = await task.value
                return .init { continuation in
                    Task {
                        for try await action in box.delegateStream {
                            continuation.yield(action)
                        }
                    }
                    Task {
                        let isScanningStream = box.manager
                            .publisher(for: \.isScanning)
                            .map(BluetoothManager.Action.didUpdateScanningState)
                            .values
                        for try await action in isScanningStream {
                            continuation.yield(action)
                        }
                    }
                }
            },
            connect: { @MainActor peripheral, options in
                let manager = await task.value.manager
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.connect(rawPeripheral, options: options?.toDictionary())
            },
            cancelConnection: { @MainActor peripheral in
                let manager = await task.value.manager
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.cancelPeripheralConnection(rawPeripheral)
            },
            retrieveConnectedPeripherals: { @MainActor uuids in
                await task.value.manager
                    .retrieveConnectedPeripherals(withServices: uuids.map(\.cbUUID))
                    .map(Peripheral.State.live)
            },
            retrievePeripherals: { @MainActor uuids in
                await task.value.manager
                    .retrievePeripherals(withIdentifiers: uuids)
                    .map(Peripheral.State.live)
            },
            scanForPeripherals: { @MainActor services, options in
                await task.value.manager.scanForPeripherals(
                    withServices: services?.map(\.cbUUID),
                    options: options?.toDictionary())
            },
            stopScan: { @MainActor in
                await task.value.manager.stopScan()
            },
            state: { @MainActor in
                await task.value.manager.state
            },
            peripheralEnvironment: { @MainActor (uuid) -> Peripheral.Environment? in
                let box = await task.value
                guard let rawPeripheral = box.manager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                    couldNotFindRawPeripheralValue()
                    return nil
                }
                
                return Peripheral.Environment.live(
                    from: rawPeripheral,
                    continuation: box.delegateStreamContinuation)
            },
            _authorization: {
                CBCentralManager.authorization
            },
            registerForConnectionEvents: { @MainActor options in
                await task.value.manager.registerForConnectionEvents(options: options?.toDictionary())
            },
            supports: {
                CBCentralManager.supports($0)
            }
        )
    }
}

extension BluetoothManager {
    class Delegate: NSObject, CBCentralManagerDelegate {
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
