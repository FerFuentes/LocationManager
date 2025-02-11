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
    
    func requestAlwaysAuthorization() {
        let locationManager = SharedLocationManager.shared
        locationManager.requestAlwaysAuthorization()
    }
    
    var permissionStatus: Published<PermissionStatus>.Publisher { SharedLocationManager.shared.locationPermissionStatus }
}
