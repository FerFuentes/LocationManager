//
//  go.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Foundation
import CoreLocation

public enum PresenceAction: String {
    case start
    case stop
}


class GeofencingManager: @unchecked Sendable {
#if os(iOS)
    static let shared = GeofencingManager()
    
    private let sharedLocationManager = SharedLocationManager.shared
    private let logger = DebugLogger.shared
    
    @Published private var _transition: TransitionEvent?
    var transition: Published<TransitionEvent?>.Publisher { $_transition }
    
    public func enableLogging(_ isEnabled: Bool) {
        self.logger.enableLogging(isEnabled)
    }
    
    internal func monitoring(for regions: [CLRegion], action: PresenceAction) {
        let monitoredRegions = getMonitoredRegions()
        // Stop all monitoring if no regions are provided
        guard !regions.isEmpty || action == .stop || sharedLocationManager.isLocationPermissionGranted else {
            if !monitoredRegions.isEmpty {
                monitoredRegions.forEach { monitoringByRegion(for: $0, action: .stop) }
            }
            return
        }

        // Log currently monitored regions
        monitoredRegions.forEach { region in
            logger.log("🌐 Tracking region identifier: \(region.identifier)", level: .info)
        }

        // Stop monitoring regions that are no longer in the new list
        monitoredRegions.filter { monitoredRegion in
            !regions.contains(where: { $0.identifier == monitoredRegion.identifier })
        }.forEach { region in
            monitoringByRegion(for: region, action: .stop)
        }

        // Start monitoring new regions that aren't currently monitored
        regions.filter { region in
            !monitoredRegions.contains(where: { $0.identifier == region.identifier })
        }.forEach { region in
            monitoringByRegion(for: region, action: .start)
        }
        
    }
    
    private func monitoringByRegion(for region: CLRegion, action: PresenceAction) {
        switch region {
        case let circularRegion as CLCircularRegion:
            forGeofencesMonitoring(for: circularRegion, action: action)
            
        case let beaconRegion as CLBeaconRegion:
            forBeaconRegionMonitoring(for: beaconRegion, action: action)
            
        default:
            logger.log("Unsupported region type: \(type(of: region))", level: .error)
        }
    }
    
    private func forBeaconRegionMonitoring(for beaconRegion: CLBeaconRegion, action: PresenceAction) {
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            switch action {
            case .start:
                beaconRegion.notifyOnEntry = true
                beaconRegion.notifyOnExit = true
                monitoring(for: beaconRegion as CLBeaconRegion, action: .start)
                logger.log("🌐 Beacon start monitoring identifier: \(beaconRegion.identifier)", level: .info)
            case .stop:
                monitoring(for: beaconRegion as CLBeaconRegion, action: .stop)
                logger.log("🛑 Becon Stopped monitoring region \(beaconRegion.identifier)", level: .info)
            }
        }
    }
    
    private func forGeofencesMonitoring(for circularRegion: CLCircularRegion, action: PresenceAction) {
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            switch action {
            case .start:
                circularRegion.notifyOnEntry = true
                circularRegion.notifyOnExit = true
                monitoring(for: circularRegion as CLCircularRegion, action: .start)
                logger.log("🌐 Geofence start monitoring identifier: \(circularRegion.identifier)", level: .info)
            case .stop:
                monitoring(for: circularRegion as CLCircularRegion, action: .stop)
                logger.log("🛑 Geofence stop monitoring identifier: \(circularRegion.identifier)", level: .info)
            }
        }
    }
    
    private func getMonitoredRegions() -> Set<CLRegion> {
        sharedLocationManager.locationManager.monitoredRegions
    }
    
    internal func monitoring(for region: CLRegion, action: PresenceAction) {
        switch action {
        case .start:
            sharedLocationManager.locationManager.startMonitoring(for: region)
        case .stop:
            sharedLocationManager.locationManager.stopMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let location = manager.location?.coordinate
        else { return }
        
        didRegisterEvent(event: .entry, location: location, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let location = manager.location?.coordinate
        else { return }
        
        didRegisterEvent(event: .exit, location: location, region: region)
    }
    
    private func didRegisterEvent(event: TransitionType, location: CLLocationCoordinate2D, region: CLRegion) {
        let timeStamp = Int(Date().timeIntervalSince1970)
        let presenceType: PresenceType = region is CLBeaconRegion ? .beacon : .geofencing
        let geoCoord: GeoCoord = GeoCoord(latitude: location.latitude, longitude: location.longitude, isStationary: false)
        let identifier = region.identifier
        
       _transition = TransitionEvent(
            transitionType: event,
            presenceType: presenceType,
            identifier: identifier,
            timeStamp: timeStamp,
            geoCoord: geoCoord
        )

        logger.log("\(event == .entry ? "⬇️" : "⬆️") \(event) to: \(identifier), type: \(presenceType)", level: .info)
    }
#endif
}

    

