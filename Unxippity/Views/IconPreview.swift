//
//  IconPreview.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/10/23.
//

import Foundation
import SwiftUI

struct IconPreview: View {
    @EnvironmentObject var model: UnxipittyModel

    @State var isHoveringDropArea = false {
        didSet {
            DispatchQueue.main.async {
                if isHoveringDropArea {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
    @State var dashPhase: CGFloat = 0.0
    @State var targeted = false

    var body: some View {
        ZStack {
            if let url = model.url {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)

                VStack(alignment: .center, spacing: 2) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    if let fileSize = model.fileSize {
                        Text(fileSize)
                            .font(.callout.bold())
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(0)
                    }
                }
                .padding()

            } else {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray.opacity(0.8),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: .zero, dash: [8, 4], dashPhase: dashPhase)
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .animation(
                        isHoveringDropArea
                        ? .linear(duration: 1).repeatForever(autoreverses: false)
                        : .default
                        , value: dashPhase
                    )
                    .onDrop(of: [.fileURL], isTargeted: $targeted, perform: { providers in
                        guard let provider = providers.first else { return false }
                        
                        var result = false
                        _ = provider.loadObject(ofClass: URL.self) { url, error in
                            guard let url, url.pathExtension == "xip" else { return }

                            Task { @MainActor in
                                model.url = url
                            }

                            result = true
                        }
                        return result
                    })

                Text(".xip file")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            guard model.url == nil else { return }

            guard let fileURL = selectFile() else {
                print("Cancelled")
                return
            }
            
            model.url = fileURL
        }
        .onHover(perform: { hovering in
            guard model.url == nil else { return }
            isHoveringDropArea = hovering

            withAnimation {
                dashPhase = hovering ? 12.0 : 0
                print("Animate to \(dashPhase)")
            }
        })
        .frame(width: 100, height: 100)
    }
}
