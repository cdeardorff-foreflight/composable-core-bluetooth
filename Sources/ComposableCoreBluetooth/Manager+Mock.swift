//
//  Manager+Mock.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture
import XCTestDynamicOverlay

extension BluetoothManager {
    
    @available(macOS, unavailable)
    public static func mock(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never> = { _, _, _ in
            _unimplemented("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never> = { _, _ in
            _unimplemented("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrieveConnectedPeripherals")
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrievePeripherals")
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never> = { _, _, _ in
            _unimplemented("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            _unimplemented("state")
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            _unimplemented("peripheralEnvironment")
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            _unimplemented("authorization")
        },
        registerForConnectionEvents: @escaping (AnyHashable, ConnectionEventOptions?) -> Effect<Never> = { _, _ in
            _unimplemented("registerForConnectionEvents")
        },
        supports: @escaping (CBCentralManager.Feature) -> Bool = { _ in
            _unimplemented("supports")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization,
            registerForConnectionEvents: registerForConnectionEvents,
            supports: supports
        )
    }
    
    @available(macOS, unavailable)
    public static func failing(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            .failing("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .failing("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never> = { _, _, _ in
            .failing("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never> = { _, _ in
            .failing("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            fail("retrieveConnectedPeripherals")
            return []
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            fail("retrievePeripherals")
            return []
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never> = { _, _, _ in
            .failing("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .failing("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            fail("state")
            return .unknown
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            fail("peripheralEnvironment")
            return nil
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            fail("authorization")
            return .notDetermined
        },
        registerForConnectionEvents: @escaping (AnyHashable, ConnectionEventOptions?) -> Effect<Never> = { _, _ in
            .failing("registerForConnectionEvents")
        },
        supports: @escaping (CBCentralManager.Feature) -> Bool = { _ in
            fail("supports")
            return false
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization,
            registerForConnectionEvents: registerForConnectionEvents,
            supports: supports
        )
    }
    
    public static func mock(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never> = { _, _, _ in
            _unimplemented("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never> = { _, _ in
            _unimplemented("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrieveConnectedPeripherals")
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrievePeripherals")
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never> = { _, _, _ in
            _unimplemented("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            _unimplemented("state")
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            _unimplemented("peripheralEnvironment")
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            _unimplemented("authorization")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization
        )
    }
    
    public static func failing(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            .failing("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .failing("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never> = { _, _, _ in
            .failing("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never> = { _, _ in
            .failing("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            fail("retrieveConnectedPeripherals")
            return []
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            fail("retrievePeripherals")
            return []
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never> = { _, _, _ in
            .failing("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .failing("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            fail("state")
            return .unknown
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            fail("peripheralEnvironment")
            return nil
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            fail("authorization")
            return .notDetermined
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization
        )
    }
}
