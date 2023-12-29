//
//  DestinationButton.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/12/23.
//

import Foundation
import SwiftUI

struct DestinationButton: View {
    let destination: DestinationModel
    let model: UnxipittyModel

    var body: some View {
        Button(
            action: {  },
            label: {
                HStack {
                    Image(nsImage: destination.icon ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)

                    Text(destination.label)
                }
            }
        )
        .buttonStyle(.plain)
    }
}

