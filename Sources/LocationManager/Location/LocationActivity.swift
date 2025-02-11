//
//  LocationActivity.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Combine

public protocol LocationActivity {
    func requestLocation() async throws
    var location: Published<GeoCoord?>.Publisher { get }
}

extension LocationActivity {
    
    public func requestLocation() async throws {
        let locationManager = SharedLocationManager.shared
        try await locationManager.requesLoation()
    }
    
    public var location: Published<GeoCoord?>.Publisher { SharedLocationManager.shared.currentLocation }
}
