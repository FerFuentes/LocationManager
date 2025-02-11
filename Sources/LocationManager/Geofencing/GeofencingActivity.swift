//
//  GeofencingActivity.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Combine
import CoreLocation


public protocol GeofencingActivity {
#if os(iOS)
    func enableLogging(_ enabled: Bool)
    func monitoring(for regions: [CLRegion], action: PresenceAction)
    var transitionEvent: Published<TransitionEvent?>.Publisher { get }
#endif
}

extension GeofencingActivity {
#if os(iOS)
    public func enableLogging(_ enabled: Bool) {
        GeofencingManager.shared.enableLogging(enabled)
    }
    
    public func monitoring(for regions: [CLRegion], action: PresenceAction) {
        GeofencingManager.shared.monitoring(for: regions, action: action)
    }
    
    public var transitionEvent:  Published<TransitionEvent?>.Publisher { GeofencingManager.shared.transition }
#endif
}
