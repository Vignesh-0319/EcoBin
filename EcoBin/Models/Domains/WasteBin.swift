//
//  WasteBin.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import Foundation
import CoreLocation
import SwiftUI

enum BinType: String, Codable, CaseIterable {
    case general = "General"
    case recyclable = "Recyclable"
    case organic = "Organic"
    case hazardous = "Hazardous"
    
    var iconName: String {
        switch self {
        case .general: return "trash.fill"
        case .recyclable: return "arrow.3.trianglepath"
        case .organic: return "leaf.fill"
        case .hazardous: return "exclamationmark.shield.fill"
        }
    }
}

enum FillLevelTier: String, Codable {
    case optimal
    case moderate
    case high
    case critical
    
    var color: Color {
        switch self {
        case .optimal: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct WasteBin: Identifiable, Codable, Hashable {
    let id: UUID
    let binCode: String
    var coordinate: CLLocationCoordinate2D
    var type: BinType
    var fillPercentage: Int
    var batteryLevel: Int
    var lastEmptied: Date
    var isDamaged: Bool
    
    var tier: FillLevelTier {
        switch fillPercentage {
        case 0..<50: return .optimal
        case 50..<75: return .moderate
        case 75..<90: return .high
        default: return .critical
        }
    }

    static func == (lhs: WasteBin, rhs: WasteBin) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
