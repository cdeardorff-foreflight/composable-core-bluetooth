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
    
    public static func mock(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("destroy")
        },
        addService: @escaping (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
            _unimplemented("addService")
        },
        removeService: @escaping (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
            _unimplemented("removeService")
        },
        removeAllServices: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("removeAllServices")
        },
        startAdvertising: @escaping (AnyHashable, AdvertismentData?) -> Effect<Never> = { _, _ in
            _unimplemented("startAdvertising")
        },
        stopAdvertising: @escaping (AnyHashable) -> Effect<Never> = { _ in
            _unimplemented("stopAdvertising")
        },
        updateValue: @escaping (AnyHashable, Data, MutableCharacteristic, [Central]?) -> Effect<Bool> = { _, _, _, _ in
            _unimplemented("updateValue")
        },
        respondToRequest: @escaping (AnyHashable, ATTRequest, CBATTError.Code) -> Effect<Never> = { _, _, _ in
            _unimplemented("respondToRequest")
        },
        setDesiredConnectionLatency: @escaping (AnyHashable, CBPeripheralManagerConnectionLatency, Central) -> Effect<Never> = { _, _, _ in
            _unimplemented("setDesiredConnectionLatency")
        },
        publishL2CAPChannel: @escaping (AnyHashable, Bool) -> Effect<Never> = { _, _ in
            _unimplemented("publishL2CAPChannel")
        },
        unpublishL2CAPChannel: @escaping (AnyHashable, CBL2CAPPSM) -> Effect<Never> = { _, _ in
            _unimplemented("unpublishL2CAPChannel")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            addService: addService,
            removeService: removeService,
            removeAllServices: removeAllServices,
            startAdvertising: startAdvertising,
            stopAdvertising: stopAdvertising,
            updateValue: updateValue,
            respondToRequest: respondToRequest,
            setDesiredConnectionLatency: setDesiredConnectionLatency,
            publishL2CAPChannel: publishL2CAPChannel,
            unpublishL2CAPChannel: unpublishL2CAPChannel
        )
    }
    
    public static func failing(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action> = { _, _, _ in
            .unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .unimplemented("destroy")
        },
        addService: @escaping (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
            .unimplemented("addService")
        },
        removeService: @escaping (AnyHashable, MutableService) -> Effect<Never> = { _, _ in
            .unimplemented("removeService")
        },
        removeAllServices: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .unimplemented("removeAllServices")
        },
        startAdvertising: @escaping (AnyHashable, AdvertismentData?) -> Effect<Never> = { _, _ in
            .unimplemented("startAdvertising")
        },
        stopAdvertising: @escaping (AnyHashable) -> Effect<Never> = { _ in
            .unimplemented("stopAdvertising")
        },
        updateValue: @escaping (AnyHashable, Data, MutableCharacteristic, [Central]?) -> Effect<Bool> = { _, _, _, _ in
            .unimplemented("updateValue")
        },
        respondToRequest: @escaping (AnyHashable, ATTRequest, CBATTError.Code) -> Effect<Never> = { _, _, _ in
            .unimplemented("respondToRequest")
        },
        setDesiredConnectionLatency: @escaping (AnyHashable, CBPeripheralManagerConnectionLatency, Central) -> Effect<Never> = { _, _, _ in
            .unimplemented("setDesiredConnectionLatency")
        },
        publishL2CAPChannel: @escaping (AnyHashable, Bool) -> Effect<Never> = { _, _ in
            .unimplemented("publishL2CAPChannel")
        },
        unpublishL2CAPChannel: @escaping (AnyHashable, CBL2CAPPSM) -> Effect<Never> = { _, _ in
            .unimplemented("unpublishL2CAPChannel")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            addService: addService,
            removeService: removeService,
            removeAllServices: removeAllServices,
            startAdvertising: startAdvertising,
            stopAdvertising: stopAdvertising,
            updateValue: updateValue,
            respondToRequest: respondToRequest,
            setDesiredConnectionLatency: setDesiredConnectionLatency,
            publishL2CAPChannel: publishL2CAPChannel,
            unpublishL2CAPChannel: unpublishL2CAPChannel
        )
    }
}
