import Foundation

/// Fisher-Yates と、指定された項目を先頭・末尾へ移す `arrange`。Web 版 `src/shuffle.ts` に対応する。
/// 乱数は既定で `SystemRandomNumberGenerator`（暗号学的に安全で、範囲指定に剰余の偏りがない）。
enum Shuffler {
    static func shuffle<T>(_ source: [T]) -> [T] {
        var rng = SystemRandomNumberGenerator()
        return shuffle(source, using: &rng)
    }

    static func shuffle<T, G: RandomNumberGenerator>(_ source: [T], using rng: inout G) -> [T] {
        var result = source
        guard result.count > 1 else { return result }
        for i in stride(from: result.count - 1, to: 0, by: -1) {
            let j = Int.random(in: 0...i, using: &rng)
            result.swapAt(i, j)
        }
        return result
    }

    /// 一様にシャッフルしてから指定された項目を目的の位置と入れ替える。
    /// 条件を満たすまで引き直す方式は、指定以外の並びに偏りを持ち込む。
    static func arrange(_ items: [Item], firstId: UUID?, lastId: UUID?) -> [Item] {
        var rng = SystemRandomNumberGenerator()
        return arrange(items, firstId: firstId, lastId: lastId, using: &rng)
    }

    static func arrange<G: RandomNumberGenerator>(
        _ items: [Item],
        firstId: UUID?,
        lastId: UUID?,
        using rng: inout G
    ) -> [Item] {
        var result = shuffle(items, using: &rng)
        moveTo(&result, id: firstId, index: 0)
        // 先頭は直前で確定済み。firstId と lastId は同じ項目になり得ないので、
        // 末尾との入れ替えが先頭を巻き込むことはない。
        moveTo(&result, id: lastId, index: result.count - 1)
        return result
    }

    private static func moveTo(_ items: inout [Item], id: UUID?, index: Int) {
        guard let id, let at = items.firstIndex(where: { $0.id == id }), at != index else { return }
        items.swapAt(at, index)
    }
}
