//
//  DestinationModel.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/12/23.
//

import Foundation
import Cocoa

enum DestinationModel: Hashable {
    case sameFolder(String)
    case applications
    case path(String)

    init?(from: String, url: URL?) {
        switch from {
        case "Same folder":
            if let url {
                self = .sameFolder(url.deletingLastPathComponent().path)
            } else {
                return nil
            }
        case "Applications folder":
            self = .applications
        default: self = .path(from)
        }
    }

    var label: String {
        return switch self {
        case .sameFolder: "Same folder"
        case .applications: "Applications folder"
        case .path(let path): path
        }
    }

    var icon: NSImage? {
        let result = switch self {
        case .sameFolder(let path): NSWorkspace.shared.icon(forFile: path)
        case .applications: NSWorkspace.shared.icon(forFile: "/Applications")
        case .path(let path): NSWorkspace.shared.icon(forFile: path)
        }
        return result.copy(size: NSSize(width: 16, height: 16))
    }
}
