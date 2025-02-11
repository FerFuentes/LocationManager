//
//  LocationActivity.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//

public protocol LocationActivity {
    func reuqestLocation() async throws
}

extension LocationActivity {
    
    public func reuqestLocation() async throws {
        let locationManager = SharedLocationManager.shared
        try await locationManager.requesLoation()
    }
}
