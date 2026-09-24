//
//  BinDetailSheet.swift
//  EcoBin
//
//  Created by SUPER CHARGE on 24/09/26.
//

import SwiftUI

struct BinDetailSheet: View {
    let bin: WasteBin
    var onReportIssue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bin.binCode)
                        .font(.title2.bold())
                    Text(bin.type.rawValue + " Waste")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                FillLevelGauge(percentage: bin.fillPercentage, tier: bin.tier)
            }

            Divider()

            HStack(spacing: 20) {
                Label("Battery: \(bin.batteryLevel)%", systemImage: "battery.75")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Label("Emptied: \(bin.lastEmptied.formatted(.relative(presentation: .named)))", systemImage: "clock.arrow.circlepath")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if bin.isDamaged {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Sensor reports bin damage or tilt.")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button(role: .none, action: onReportIssue) {
                Label("Report Damage or Overflow", systemImage: "flag.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding([.horizontal, .bottom], 20)
    }
}
