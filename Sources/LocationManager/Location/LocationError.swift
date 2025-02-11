//
//  PermissionError.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//
import Foundation

extension SharedLocationManager {
    public enum Location {
        public enum Error: Swift.Error, LocalizedError {
            case invalidParameters(String)
            case needToRequestPermission
            case unavailable
            case denied
            case restricted
            case locationUnknown
            case networkError
            case unknown(Swift.Error)
            
            public var errorDescription: String? {
                switch self {
                case .invalidParameters(let message):
                    return "Invalid parameters: \(message)"
                case .unavailable:
                    return "Location services are not available on this device."
                case .needToRequestPermission:
                    return "Permission is required before attempting to access location."
                case .denied:
                    return "Location access was denied by the user."
                case .restricted:
                    return "Location access is restricted (e.g., parental controls or MDM settings)."
                case .locationUnknown:
                    return "The location could not be determined at this time."
                case .networkError:
                    return "Network issues are preventing location updates."
                case .unknown(let error):
                    return "An unknown error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
}
