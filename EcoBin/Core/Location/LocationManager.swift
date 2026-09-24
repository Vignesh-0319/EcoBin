//
//  LocationManager.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import Foundation
import CoreLocation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isNearTargetBin: Bool = false
    
    private var targetCheckInRegion: CLCircularRegion?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
    }

    func setCheckInGeofence(for coordinate: CLLocationCoordinate2D, radiusInMeters: CLLocationDistance = 25.0) {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radiusInMeters,
            identifier: "BinCheckInZone"
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        self.targetCheckInRegion = region
        
        // Immediate check against current location
        if let current = userLocation {
            let userLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
            let targetLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            isNearTargetBin = userLoc.distance(from: targetLoc) <= radiusInMeters
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startTracking()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        userLocation = latest.coordinate

        if let region = targetCheckInRegion {
            isNearTargetBin = region.contains(latest.coordinate)
        }
    }
}
