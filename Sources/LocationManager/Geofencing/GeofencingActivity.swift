//
//  GeofencingActivity.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Combine
import CoreLocation

#if os(iOS)
public protocol GeofencingActivity {
    func enableLogging(_ enabled: Bool)
    func monitoring(for regions: [CLRegion], action: PresenceAction)
    var transitionEvent: Published<TransitionEvent?>.Publisher { get }
}

extension GeofencingActivity {
    
    func enableLogging(_ enabled: Bool) {
        GeofencingManager.shared.enableLogging(enabled)
    }
    
    func monitoring(for regions: [CLRegion], action: PresenceAction) {
        GeofencingManager.shared.monitoring(for: regions, action: action)
    }
    
    var transitionEvent:  Published<TransitionEvent?>.Publisher { GeofencingManager.shared.transition }
}
#endif
