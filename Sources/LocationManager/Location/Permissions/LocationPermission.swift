//
//  LocationPermission.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Combine

public protocol LocationPermission {
    func requestAlwaysAuthorization()
    var permissionStatus: Published<PermissionStatus>.Publisher { get }
}


extension LocationPermission {
    
    public func requestAlwaysAuthorization() {
        let locationManager = SharedLocationManager.shared
        locationManager.requestAlwaysAuthorization()
    }
    
    public var permissionStatus: Published<PermissionStatus>.Publisher { SharedLocationManager.shared.locationPermissionStatus }
}
