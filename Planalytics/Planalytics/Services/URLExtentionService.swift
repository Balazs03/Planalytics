//
//  URLExtentionService.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 02. 24..
//

import Foundation

public extension URL {
    static func storeURL(appGroup: String, databaseName: String) -> URL? {
        if let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            return fileContainer.appendingPathComponent("\(databaseName).sqlite")
        }
        return nil
    }
}
