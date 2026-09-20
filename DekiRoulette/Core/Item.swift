import Foundation

struct Item: Identifiable, Hashable, Sendable {
    let id: UUID
    let label: String

    init(id: UUID = UUID(), label: String) {
        self.id = id
        self.label = label
    }
}

/// リストの行に出す印。ルーレットは当たり、順番決めは先頭・末尾を指す。
enum Mark: Sendable {
    case target
    case first
    case last
}

typealias Marks = [UUID: Mark]
