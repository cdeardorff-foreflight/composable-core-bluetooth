//
//  PeripheralManager+Live.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 29.10.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture
import Combine
import CasePaths

private class DelegateRetainingCBPeripheralManager: CBPeripheralManager {
    private let retainedDelegate: CBPeripheralManagerDelegate?
    
    override init(delegate: CBPeripheralManagerDelegate?, queue: DispatchQueue?, options: [String : Any]? = nil) {
        self.retainedDelegate = delegate
        super.init(delegate: delegate, queue: queue, options: options)
    }
}

private struct PeripheralManagerSendableBox: Sendable {
    @UncheckedSendable var manager: CBPeripheralManager
    var delegateStream: AsyncStream<PeripheralManager.Action>
    var delegateStreamContinuation: AsyncStream<PeripheralManager.Action>.Continuation
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public static func live(queue: DispatchQueue?, options: InitializationOptions?) -> PeripheralManager {
        let task = Task<PeripheralManagerSendableBox, Never>(operation: { @MainActor in
            // TODO: Remove autounwrap
            var continuation: AsyncStream<Action>.Continuation!
            let stream = AsyncStream<Action> { continuation = $0 }
            
            let delegate = Delegate(continuation: continuation)
            let manager = DelegateRetainingCBPeripheralManager(
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
                }
            },
            addService: { @MainActor service in
                let manager = await task.value.manager
                manager.add(service.cbMutableService)
            },
            removeService: { @MainActor service in
                let manager = await task.value.manager
                manager.remove(service.cbMutableService)
            },
            removeAllServices: {
                let manager = await task.value.manager
                manager.removeAllServices()
            },
            startAdvertising: { @MainActor advertisementData in
                let manager = await task.value.manager
                manager.startAdvertising(advertisementData?.toDictionary())
            },
            stopAdvertising: {
                let manager = await task.value.manager
                manager.stopAdvertising()
            },
            updateValue: { value, characteristic, subscribedCentrals in
                await task.value.manager
                    .updateValue(value, for: characteristic.cbMutableCharacteristic, onSubscribedCentrals: subscribedCentrals?.map(\.rawValue))
            },
            respondToRequest: { request, errorCode in
                guard let cbAttRequest = request.rawValue else {
                    couldNotFindRawRequestValue()
                    return
                }
                let manager = await task.value.manager
                manager.respond(to: cbAttRequest, withResult: errorCode)
            },
            setDesiredConnectionLatency: { latency, central in
                guard let cbCentral = central.rawValue else {
                    couldNotFindRawCentralValue()
                    return
                }
                let manager = await task.value.manager
                manager.setDesiredConnectionLatency(latency, for: cbCentral)
            },
            publishL2CAPChannel: { withEncryption in
                let manager = await task.value.manager
                manager.publishL2CAPChannel(withEncryption: withEncryption)
            },
            unpublishL2CAPChannel: { psm in
                let manager = await task.value.manager
                manager.unpublishL2CAPChannel(psm)
            },
            state: { @MainActor in
                await task.value.manager.state
            },
            _authorization: {
                CBPeripheralManager.authorization
            }
            /*
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
            */
        )
    }
    
    class Delegate: NSObject, CBPeripheralManagerDelegate {
        let continuation: AsyncStream<PeripheralManager.Action>.Continuation
        
        init(continuation: AsyncStream<PeripheralManager.Action>.Continuation) {
            self.continuation = continuation
        }
        
        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            continuation.yield(.didUpdateState(peripheral.state))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
            continuation.yield(.willRestore(RestorationOptions(from: dict)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
            continuation.yield(.didAddService(convertToResult(Service(from: service), error: error)))
        }
        
        func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
            continuation.yield(.didUpdateAdvertisingState(convertToResult(true, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
            continuation.yield(.didSubscribeTo(Characteristic(from: characteristic), Central(from: central)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
            continuation.yield(.didUnsubscribeFrom(Characteristic(from: characteristic), Central(from: central)))
        }
        
        func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
            continuation.yield(.isReadyToUpdateSubscribers)
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
            continuation.yield(.didReceiveRead(ATTRequest(from: request)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
            continuation.yield(.didReceiveWrite(requests.map(ATTRequest.init)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
            continuation.yield(.didPublishL2CAPChannel(convertToResult(PSM, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
            continuation.yield(.didUnpublishL2CAPChannel(convertToResult(PSM, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
            continuation.yield(.didOpen(convertToResult(channel, error: error)))
        }
    }
}
