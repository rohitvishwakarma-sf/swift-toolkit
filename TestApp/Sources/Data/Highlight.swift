//
//  Highlight.swift
//  TestApp
//
//  Created by Rohit  Vishwakarma on 23/03/22.
//

import Combine
import Foundation
import GRDB
import R2Shared
import R2Navigator
import UIKit

enum HighlightColor: UInt8, Codable, SQLExpressible {
    case red = 1
    case green = 2
    case blue = 3
    case yellow = 4
}

enum AnnotationType:UInt8,Codable {
    case normal
    case underline
    case strikeThrough
    case sideMark
}

extension HighlightColor {
    var uiColor: UIColor {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        }
    }
}

struct Highlight: Codable {
    typealias Id = String

    let id: Id
    /// Foreign key to the publication.
    var bookId: Book.Id
    /// Location in the publication.
    var locator: Locator
    /// Color of the highlight.
    var color: HighlightColor
    /// Date of creation.
    var created: Date = Date()
    /// Total progression in the publication.
    var progression: Double?
    
    var annotationType: AnnotationType

    init(id: Id = UUID().uuidString, bookId: Book.Id, locator: Locator, color: HighlightColor, created: Date = Date(), annotation:AnnotationType) {
        self.id = id
        self.bookId = bookId
        self.locator = locator
        self.progression = locator.locations.totalProgression
        self.color = color
        self.created = created
        self.annotationType = annotation
    }
}

extension Highlight: TableRecord, FetchableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id, bookId, locator, color, created, progression, annotationType
    }
}

struct HighlightNotFoundError: Error {}

final class HighlightRepository {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    func all(for bookId: Book.Id) -> AnyPublisher<[Highlight], Error> {
        db.observe { db in
            try Highlight
                .filter(Highlight.Columns.bookId == bookId)
                .order(Highlight.Columns.progression)
                .fetchAll(db)
        }
    }

    func highlight(for highlightId: Highlight.Id) -> AnyPublisher<Highlight, Error> {
        db.observe { db in
            try Highlight
                .filter(Highlight.Columns.id == highlightId)
                .fetchOne(db)
                .orThrow(HighlightNotFoundError())
        }
    }

    func add(_ highlight: Highlight) -> AnyPublisher<Highlight.Id, Error> {
        return db.write { db in
            try highlight.insert(db)
            return highlight.id
        }.eraseToAnyPublisher()
    }

    func update(_ id: Highlight.Id, color: HighlightColor) -> AnyPublisher<Void, Error> {
        return db.write { db in
            let filtered = Highlight.filter(Highlight.Columns.id == id)
            let assignment = Highlight.Columns.color.set(to: color)
            try filtered.updateAll(db, onConflict: nil, assignment)
        }.eraseToAnyPublisher()
    }

    func remove(_ id: Highlight.Id) -> AnyPublisher<Void, Error> {
        db.write { db in try Highlight.deleteOne(db, key: id) }
    }
}

