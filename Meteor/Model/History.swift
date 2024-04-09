//
//  History.swift
//  Meteor
//
//  Created by 장기화 on 3/28/24.
//

import Foundation
import SwiftData

typealias History = HistorySchemaV2.History

enum HistorySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [History.self]
    }
    
    @Model
    class History {
        @Attribute(.unique) var id = UUID()
        var content: String
        var timestamp: TimeInterval
        
        init(content: String, timestamp: TimeInterval) {
            self.content = content
            self.timestamp = timestamp
        }
    }
}

enum HistorySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [History.self]
    }
    
    @Model
    class History {
        @Attribute(.unique) var content: String
        var timestamp: TimeInterval
        
        init(content: String, timestamp: TimeInterval) {
            self.content = content
            self.timestamp = timestamp
        }
    }
}

enum HistoryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HistorySchemaV1.self, HistorySchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static var migrateV1toV2 = MigrationStage.custom(
        fromVersion: HistorySchemaV1.self,
        toVersion: HistorySchemaV2.self,
        willMigrate: { context in
            let historys = try context.fetch(FetchDescriptor<HistorySchemaV1.History>())
            var contents = Set<String>()
            
            for history in historys {
                if contents.contains(history.content) {
                    context.delete(history)
                }
                contents.insert(history.content)
            }
            try context.save()
        },
        didMigrate: nil
    )
}
