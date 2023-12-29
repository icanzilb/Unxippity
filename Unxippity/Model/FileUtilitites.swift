//
//  FileUtilitites.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/10/23.
//

import Foundation
import Cocoa

func selectFile(selected: URL? = nil) -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.title = "Select a .xip file"
    if let selected {
        openPanel.directoryURL = selected
    }
    openPanel.allowedContentTypes = [.archive]
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true

    guard openPanel.runModal() == .OK else {
        return nil
    }

    guard openPanel.url?.pathExtension == "xip" else {
        return nil
    }

    return openPanel.url
}

func selectFolder(selected: URL? = nil) -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.title = "Select a folder"
    if let selected {
        openPanel.directoryURL = selected
    }
    openPanel.allowedContentTypes = [.directory]
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false

    guard openPanel.runModal() == .OK else {
        return nil
    }

    return openPanel.url
}
