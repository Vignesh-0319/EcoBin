//
//  BinMapViewModel.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import Foundation
import MapKit
import SwiftUI

@Observable
final class BinMapViewModel {
    var bins: [WasteBin] = []
    var selectedBin: WasteBin?
    var selectedFilter: BinType?
    var isLoading: Bool = false
    var errorMessage: String?
    
    var cameraPosition: MapCameraPosition = .userLocation(fallback: .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), distance: 3000)
    ))

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    var visibleBins: [WasteBin] {
        guard let selectedFilter else { return bins }
        return bins.filter { $0.type == selectedFilter }
    }

    @MainActor
    func loadNearbyBins() async {
        isLoading = true
        errorMessage = nil
        do {
            let endpoint = Endpoint(path: "/bins/nearby")
            // In a production backend, this fetches telemetry:
            // self.bins = try await apiClient.request(endpoint: endpoint)
            
            // Mock sample for immediate preview
            try await Task.sleep(nanoseconds: 500_000_000)
            self.bins = [
                WasteBin(id: UUID(), binCode: "BIN-401", coordinate: .init(latitude: 37.7749, longitude: -122.4194), type: .general, fillPercentage: 92, batteryLevel: 84, lastEmptied: .now.addingTimeInterval(-86400), isDamaged: false),
                WasteBin(id: UUID(), binCode: "BIN-402", coordinate: .init(latitude: 37.7765, longitude: -122.4172), type: .recyclable, fillPercentage: 40, batteryLevel: 95, lastEmptied: .now.addingTimeInterval(-10800), isDamaged: false),
                WasteBin(id: UUID(), binCode: "BIN-403", coordinate: .init(latitude: 37.7732, longitude: -122.4215), type: .organic, fillPercentage: 80, batteryLevel: 62, lastEmptied: .now.addingTimeInterval(-43200), isDamaged: true)
            ]
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
