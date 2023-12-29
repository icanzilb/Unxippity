//
//  PostUnarchiveOptionsView.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/11/23.
//

import Foundation
import SwiftUI

extension NSImage {
    func copy(size: NSSize) -> NSImage? {
            // Create a new rect with given width and height
            let frame = NSMakeRect(0, 0, size.width, size.height)

            // Get the best representation for the given size.
            guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
                return nil
            }

            // Create an empty image with the given size.
            let img = NSImage(size: size)

            // Set the drawing context and make sure to remove the focus before returning.
            img.lockFocus()
            defer { img.unlockFocus() }

            // Draw the new image
            if rep.draw(in: frame) {
                return img
            }

            // Return nil in case something went wrong.
            return nil
        }
}

struct PostUnarchiveOptionsView: View {
    @EnvironmentObject var model: UnxipittyModel

    let includeTargetSelection: Bool

    @AppStorage("lastExtractDestination") var lastExtractDestination: URL?
    @State var modelMenuKey = UUID()
    @State var modelSelectFolderKey = UUID()

    private func customItemTag() -> String {
        if model.extractDestination == "." {
            return ""
        }
        if model.extractDestination == DestinationModel.applications.label {
            return ""
        }
        if model.extractDestination == lastExtractDestination?.path {
            return ""
        }
        return model.extractDestination
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                if includeTargetSelection {
                    Picker("Extract into:", selection: model.$extractDestination) {
                        if let url = model.url {
                            DestinationButton(destination: .sameFolder(url.deletingLastPathComponent().path), model: model)
                                .tag(DestinationModel.sameFolder(url.path).label)
                        }
                        if let url = model.downloadModel?.url {
                            DestinationButton(destination: .sameFolder(url.deletingLastPathComponent().path), model: model)
                                .tag(DestinationModel.sameFolder(url.path).label)
                        }
                        DestinationButton(destination: .applications, model: model)
                            .tag(DestinationModel.applications.label)

                        if let last = lastExtractDestination {
                            DestinationButton(destination: .path(last.path), model: model)
                                .tag(last.path)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    Button(
                        action: {
                            modelSelectFolderKey = model.lock()
                            defer { model.unlock(with: modelSelectFolderKey) }

                            guard let folderURL = selectFolder() else { return }
                            model.extractDestination = folderURL.path
                            lastExtractDestination = folderURL
                        },
                        label: { Text("Select folder...") }
                    )
                    .padding(.leading, 100)
                    .padding(.top, 2)

                } else if let finalURL = model.finalURL {
                    HStack {
                        Text("Extract into:")
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(finalURL.deletingLastPathComponent().path)
                            .truncationMode(.head)
                            .lineLimit(1)
                            .font(.callout.monospaced())
                        Button(action: {
                            NSWorkspace.shared.open(finalURL.deletingLastPathComponent())
                        }, label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .scaleEffect(x: 0.8, y: 0.8)
                                .foregroundColor(.secondary)
                        })
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading) {
                Text("When done:")
                    .font(.body)
                    .foregroundStyle(.primary)

                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 4) {
                    GridRow {
                        Toggle(isOn: model.$deleteSourceFile, label: {
                            Label {
                                Text("Delete the .xip file")
                            } icon: {
                                Image(systemName: model.deleteSourceFile ? "trash.fill" : "trash")
                                    .frame(width: 12)
                            }
                        })

                        Toggle(isOn: model.$beepWhenDone, label: {
                            Label {
                                Text("Beep")
                            } icon: {
                                Image(systemName: model.beepWhenDone ? "speaker.wave.2.fill" : "speaker.slash")
                                    .frame(width: 12)
                            }
                        })
                    }

                    Spacer().frame(height: 1)

                    GridRow {
                        Toggle(isOn: model.$launchWhenDone, label: {
                            Label {
                                Text("Launch Xcode")
                            } icon: {
                                Image(systemName: model.launchWhenDone ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                                    .frame(width: 12)
                            }
                        })

                        Toggle(isOn: model.$closeWhenDone, label: {
                            Label {
                                Text("Close app")
                            } icon: {
                                Image(systemName: model.closeWhenDone ? "xmark.rectangle.fill" : "menubar.rectangle")
                                    .frame(width: 12)
                            }
                        })

                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(2)
        }
    }
}
