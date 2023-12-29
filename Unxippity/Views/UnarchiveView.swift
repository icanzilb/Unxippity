//
//  UnarchiveView.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/11/23.
//

import Foundation
import SwiftUI

struct UnarchiveView: View {
    @EnvironmentObject var model: UnxipittyModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let _ = model.url {
                ProgressView(value: model.progress, total: 1.0) {
                    Text("Unxipping \(model.url?.lastPathComponent ?? "")...")
                } currentValueLabel: {
                    Text("Progress: \(Int(model.progress * 100.0))%")
                        .font(.callout.monospaced().bold())
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                Spacer().frame(height: 16)

                PostUnarchiveOptionsView(includeTargetSelection: false)
            }
        }
    }
}
