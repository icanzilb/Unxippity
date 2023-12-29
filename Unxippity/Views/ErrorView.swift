//
//  ErrorView.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/12/23.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    let message: String

    var body: some View {
        Text(message)
            .truncationMode(.head)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.red.opacity(0.8))
            .help(message)
        Divider()
    }
}
