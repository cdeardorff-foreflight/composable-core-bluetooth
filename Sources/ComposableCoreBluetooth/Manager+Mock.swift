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
    public static let failing = Self(
        delegate: { unimplemented() },
        connect: { _,_ in unimplemented() },
        cancelConnection: { _ in unimplemented() },
        retrieveConnectedPeripherals: { _ in unimplemented()},
        retrievePeripherals: { _ in unimplemented()},
        scanForPeripherals: { _,_ in unimplemented()},
        stopScan: { unimplemented() },
        state: {  unimplemented() },
        peripheralEnvironment: { _ in unimplemented()},
        _authorization: { unimplemented() },
        registerForConnectionEvents: { _ in unimplemented() },
        supports: { _ in unimplemented() })
}
