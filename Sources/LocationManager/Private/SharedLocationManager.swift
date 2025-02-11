// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Combine
import CoreLocation

final class LocationService: @unchecked Sendable {
    static let shared = LocationService()
    let locationManager: CLLocationManager = .init()
}

class SharedLocationManager: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    static let shared = SharedLocationManager()
        
    @Published private var _locationPermissionStatus: PermissionStatus = .notDetermined
    var locationPermissionStatus: Published<PermissionStatus>.Publisher { $_locationPermissionStatus }
    
    @Published private var _currentLocation: GeoCoord?
    var currentLocation: Published<GeoCoord?>.Publisher { $_currentLocation }
    
    internal let locationManager = LocationService.shared.locationManager

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
#if os(iOS)
        locationManager.allowsBackgroundLocationUpdates = true
#endif
    }
    
    internal var isLocationPermissionGranted: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
    
    internal func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
            
        case .authorizedWhenInUse:  // Location services are available.
            _locationPermissionStatus = .whenInUse
            
        case .restricted, .denied:  // Location services currently unavailable.
            _locationPermissionStatus = .unavailable
            
        case .notDetermined:        // Authorization not determined yet.
            _locationPermissionStatus = .notDetermined
            
        case .authorizedAlways:
            _locationPermissionStatus = .always
            
        default:
            break
        }
    }
    
    internal func requesLoation() async throws {
        if #available (iOS 17.0, watchOS 10.0, *) {
            try await requestLocationForLatestVersions()
        } else {
            try requestLocationForOlderVersions()
        }
    }
    
    private func requestLocationForOlderVersions() throws {
        guard isLocationPermissionGranted else {
            throw SharedLocationManager.Location.Error.denied
        }
        
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        _currentLocation = GeoCoord(latitude: latitude, longitude: longitude, isStationary: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        _currentLocation = GeoCoord(latitude: 0.0, longitude: 0.0, isStationary: false)
    }
    
    @available(iOS 17.0, watchOS 10.0, *)
    private func  requestLocationForLatestVersions() async throws  {
        guard isLocationPermissionGranted else {
            throw SharedLocationManager.Location.Error.denied
        }

        do {
            for try await locationUpdate in CLLocationUpdate.liveUpdates() {
                guard let location = locationUpdate.location else { return }
                var stationary: Bool?
                
                if #available(iOS 18.0, watchOS 11.0, *) {
                    stationary = locationUpdate.stationary
                }

                _currentLocation = GeoCoord(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    isStationary: stationary
                )
            }
        } catch {
            throw SharedLocationManager.Location.Error.unknown(error)
        }
    }
}
