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

private var dependencies: [AnyHashable: Dependencies] = [:]

private struct Dependencies {
    let manager: CBCentralManager
    let delegate: BluetoothManager.Delegate
    let send: Send<BluetoothManager.Action>
}

extension BluetoothManager {
    
    private struct CreateId: Hashable { }
    
    public static let live: BluetoothManager = { () -> BluetoothManager in
        var manager = BluetoothManager()
        
        manager.create = { id, queue, options in
            
            return .merge(
                .run { send in
                    let delegate = Delegate(send)
                    let manager = CBCentralManager(
                        delegate: delegate,
                        queue: queue,
                        options: options?.toDictionary()
                    )
                    dependencies[id] = Dependencies(manager: manager, delegate: delegate, send: send)
                },
                .run { send in
                    guard let isScanningStream = dependencies[id]?
                        .manager
                        .publisher(for: \.isScanning)
                        .map(BluetoothManager.Action.didUpdateScanningState)
                        .values
                    else { return }
                    
                    for try await action in isScanningStream {
                        await send(action)
                    }
                }
            )
            .cancellable(id: CreateId())
        }
        
        manager.destroy = { id in
            .cancel(id: CreateId())
        }
        
        manager.connect = { id, peripheral, options in
            
            guard let rawPeripheral = dependencies[id]?.manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                couldNotFindRawPeripheralValue()
                return .none
            }
            
            return .fireAndForget {
                dependencies[id]?.manager.connect(rawPeripheral, options: options?.toDictionary())
            }
        }
        
        manager.cancelConnection = { id, peripheral  in
            
            guard let rawPeripheral = dependencies[id]?.manager.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first else {
                couldNotFindRawPeripheralValue()
                return .none
            }
            
            return .fireAndForget {
                dependencies[id]?.manager.cancelPeripheralConnection(rawPeripheral)
            }
        }
        
        manager.retrieveConnectedPeripherals = { id, uuids in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return []
            }
            
            return dependency
                .manager
                .retrieveConnectedPeripherals(withServices: uuids)
                .map(Peripheral.State.live)
        }
        
        manager.retrievePeripherals = { id, uuids in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return []
            }
            
            return dependency
                .manager
                .retrievePeripherals(withIdentifiers: uuids)
                .map(Peripheral.State.live)
        }
        
        manager.scanForPeripherals = { id, services, options in
            .fireAndForget {
                dependencies[id]?.manager.scanForPeripherals(withServices: services, options: options?.toDictionary())
            }
        }
        
        manager.stopScan = { id in
            .fireAndForget {
                dependencies[id]?.manager.stopScan()
            }
        }
        
        if #available(iOS 13.1, macOS 10.15, macCatalyst 13.1, tvOS 13.0, watchOS 6.0, *) {
            manager._authorization = {
                CBCentralManager.authorization
            }
        }
        
        manager.state = { id in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return .unknown
            }
            
            return dependency.manager.state
        }
        
        manager.peripheralEnvironment = { (id, uuid) -> Peripheral.Environment? in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return nil
            }
            
            guard let rawPeripheral = dependencies[id]?.manager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                couldNotFindRawPeripheralValue()
                return nil
            }
            
            return Peripheral.Environment.live(from: rawPeripheral, send: dependency.send)
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        manager.registerForConnectionEvents = { id, options in
            .fireAndForget {
                dependencies[id]?.manager.registerForConnectionEvents(options: options?.toDictionary())
            }
        }
        #endif
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        manager.supports = CBCentralManager.supports
        #endif

        return manager
    }()
}

extension BluetoothManager {
    class Delegate: NSObject, CBCentralManagerDelegate {
        let send: Send<BluetoothManager.Action>
        
        init(_ send: Send<BluetoothManager.Action>) {
            self.send = send
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            Task { @MainActor in
                send(.peripheral(peripheral.identifier, .didConnect))
            }
        }
        
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            Task { @MainActor in
                if let error = error {
                    if let error = error as? CBError {
                        send(.peripheral(peripheral.identifier, .didDisconnect(.coreBluetooth(error))))
                    } else {
                        send(.peripheral(peripheral.identifier, .didDisconnect(.unknown(error.localizedDescription))))
                    }
                } else {
                    send(.peripheral(peripheral.identifier, .didDisconnect(.none)))
                }
            }
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            Task { @MainActor in
                if let error = error {
                    if let error = error as? CBError {
                        send(.peripheral(peripheral.identifier, .didFailToConnect(.coreBluetooth(error))))
                    } else {
                        send(.peripheral(peripheral.identifier, .didFailToConnect(.unknown(error.localizedDescription))))
                    }
                } else {
                    send(.peripheral(peripheral.identifier, .didFailToConnect(.unknown(.none))))
                }
            }
        }

        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
            Task { @MainActor in
                send(.didDiscover(Peripheral.State.live(from: peripheral), BluetoothManager.AdvertismentData(from: advertisementData), RSSI))
            }
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            Task { @MainActor in
                send(.didUpdateState(central.state))
            }
        }
        
        func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
            Task { @MainActor in
                send(.willRestore(RestorationOptions(from: dict)))
            }
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
            Task { @MainActor in
                send(.peripheral(peripheral.identifier, .connectionEventDidOccur(event)))
            }
        }
        #endif
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
            Task { @MainActor in
                send(.peripheral(peripheral.identifier, .didUpdateANCSAuthorization(peripheral.ancsAuthorized)))
            }
        }
        #endif
    }
}
