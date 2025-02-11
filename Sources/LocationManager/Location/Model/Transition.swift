//
//  Transition.swift
//  LocationManager
//
//  Created by Fernando Fuentes on 11/02/25.
//

public struct TransitionEvent: Codable {
    public let transitionType: TransitionType
    public let presenceType: PresenceType
    public let identifier: String
    public let timeStamp: Int
    public let geoCoord: GeoCoord
}

public enum TransitionType: Codable {
    case entry
    case exit
}

public enum PresenceType: String, Codable {
    case geofencing
    case beacon
}
