//
//  FillLevelGauge.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import SwiftUI

struct FillLevelGauge: View {
    let percentage: Int
    let tier: FillLevelTier

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
                .frame(width: 54, height: 54)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(percentage, 100)) / 100.0)
                .stroke(tier.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 54, height: 54)

            Text("\(percentage)%")
                .font(.system(size: 13, weight: .bold))
        }
    }
}
