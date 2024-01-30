//
//  PeripheralManager+Live.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public static let mock = Self(
        delegate: { unimplemented() },
        addService: { _ in unimplemented() },
        removeService: { _ in unimplemented() },
        removeAllServices: { unimplemented() },
        startAdvertising: { _ in unimplemented() },
        stopAdvertising: { unimplemented() },
        updateValue: { _, _, _ in unimplemented() },
        respondToRequest: { _, _ in
            _unimplemented("respondToRequest")
        },
        setDesiredConnectionLatency: { _, _ in
            _unimplemented("setDesiredConnectionLatency")
        },
        publishL2CAPChannel: { _ in
            _unimplemented("publishL2CAPChannel")
        },
        unpublishL2CAPChannel: { _ in
            _unimplemented("unpublishL2CAPChannel")
        },
        state: { unimplemented() },
        _authorization: { unimplemented() }
    )

    
    public static let failing = Self(
        delegate: { unimplemented() },
        addService: { _ in unimplemented() },
        removeService: { _ in unimplemented() },
        removeAllServices: { unimplemented() },
        startAdvertising: { _ in unimplemented() },
        stopAdvertising: { unimplemented() },
        updateValue: { _, _, _ in unimplemented() },
        respondToRequest: { _, _ in
            _unimplemented("respondToRequest")
        },
        setDesiredConnectionLatency: { _, _ in
            _unimplemented("setDesiredConnectionLatency")
        },
        publishL2CAPChannel: { _ in
            _unimplemented("publishL2CAPChannel")
        },
        unpublishL2CAPChannel: { _ in
            _unimplemented("unpublishL2CAPChannel")
        },
        state: { unimplemented() },
        _authorization: { unimplemented() }
    )
}
