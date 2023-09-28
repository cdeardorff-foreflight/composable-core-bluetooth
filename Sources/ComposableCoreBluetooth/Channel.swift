//
//  L2CAPChannel.swift
//  ComposableCoreBluetooth
//
//  Created by Cameron Deardorff on 9/28/23.
//

import Foundation
import ComposableArchitecture
import CoreBluetooth

@dynamicMemberLookup
public struct L2CAPChannel: Equatable, Hashable, Sendable {
    
    @UncheckedSendable public private(set) var rawValue: CBL2CAPChannel
    
    public init(rawValue: CBL2CAPChannel) {
        self.rawValue = rawValue
    }
    
    public init?(rawValue: CBL2CAPChannel?) {
        guard let rawValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<CBL2CAPChannel, T>) -> T {
        self.rawValue[keyPath: keyPath]
    }
    
}
