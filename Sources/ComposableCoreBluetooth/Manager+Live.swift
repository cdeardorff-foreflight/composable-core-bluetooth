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
    
    override init(delegate: CBCentralManagerDelegate?, queue: dispatch_queue_t?, options: [String : Any]? = nil) {
        self.retainedDelegate = delegate
        super.init(delegate: delegate, queue: queue, options: options)
    }
}

extension BluetoothManager {
        
    public static func live(queue: DispatchQueue?, options: InitializationOptions?) -> BluetoothManager {
        var continuation: AsyncStream<Action>.Continuation!
        let stream = AsyncStream<Action> { continuation = $0 }
        
        let delegate = Delegate(continuation: continuation)
        let manager = DelegateRetainingCBCentralManager(
            delegate: delegate,
            queue: queue,
            options: options?.toDictionary()
        )
        
        return Self(
            delegate: {
                return .merge(
                    .run { send in
                        for try await action in stream {
                            await send(action)
                        }
                    },
                    .run { send in
                        let isScanningStream = manager
                            .publisher(for: \.isScanning)
                            .map(BluetoothManager.Action.didUpdateScanningState)
                            .values
                        for try await action in isScanningStream {
                            await send(action)
                        }
                    }
                )
            },
            connect: { peripheral, options in
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.connect(rawPeripheral, options: options?.toDictionary())
            },
            cancelConnection: { peripheral in
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                    couldNotFindRawPeripheralValue()
                    return
                }
                manager.cancelPeripheralConnection(rawPeripheral)
            },
            retrieveConnectedPeripherals: { uuids in
                return manager
                    .retrieveConnectedPeripherals(withServices: uuids)
                    .map(Peripheral.State.live)
            },
            retrievePeripherals: { uuids in
                return manager
                    .retrievePeripherals(withIdentifiers: uuids)
                    .map(Peripheral.State.live)
            },
            scanForPeripherals: { services, options in
                manager.scanForPeripherals(withServices: services, options: options?.toDictionary())
            },
            stopScan: {
                manager.stopScan()
            },
            state: {
                manager.state
            },
            peripheralEnvironment: { (uuid) -> Peripheral.Environment? in
                guard let rawPeripheral = manager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                    couldNotFindRawPeripheralValue()
                    return nil
                }
                
                return Peripheral.Environment.live(from: rawPeripheral, continuation: continuation)
            },
            _authorization: {
                CBCentralManager.authorization
            },
            registerForConnectionEvents: { options in
                manager.registerForConnectionEvents(options: options?.toDictionary())
            },
            supports: CBCentralManager.supports
        )
    }
}

extension BluetoothManager {
    class Delegate: NSObject, CBCentralManagerDelegate {
        let continuation: AsyncStream<BluetoothManager.Action>.Continuation
        
        init(continuation: AsyncStream<BluetoothManager.Action>.Continuation) {
            self.continuation = continuation
        }
        
        deinit {
            assertionFailure()
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
