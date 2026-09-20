import Foundation
import Testing
@testable import DekiRoulette

struct ShuffleTests {
    private let items = ItemLabel.makeItems(["A", "B", "C", "D", "E", "F"])

    @Test func シャッフルは要素を保つ() {
        var rng = SeededGenerator(seed: 1)
        let result = Shuffler.shuffle(items, using: &rng)
        #expect(Set(result) == Set(items))
        #expect(result.count == items.count)
    }

    @Test func 先頭と末尾の指定が反映される() {
        for seed in UInt64(0)..<200 {
            var rng = SeededGenerator(seed: seed)
            let result = Shuffler.arrange(items, firstId: items[2].id, lastId: items[4].id, using: &rng)
            #expect(result.first == items[2])
            #expect(result.last == items[4])
            #expect(Set(result) == Set(items))
        }
    }

    @Test func 先頭だけの指定でも末尾は自由に動く() {
        var seenLast = Set<UUID>()
        for seed in UInt64(0)..<200 {
            var rng = SeededGenerator(seed: seed)
            let result = Shuffler.arrange(items, firstId: items[0].id, lastId: nil, using: &rng)
            #expect(result.first == items[0])
            seenLast.insert(result.last!.id)
        }
        #expect(seenLast.count > 1)
    }

    @Test func 指定なしならすべての位置に散る() {
        var seenFirst = Set<UUID>()
        for seed in UInt64(0)..<200 {
            var rng = SeededGenerator(seed: seed)
            seenFirst.insert(Shuffler.arrange(items, firstId: nil, lastId: nil, using: &rng).first!.id)
        }
        #expect(seenFirst.count == items.count)
    }

    @Test func 要素が1つでも落ちない() {
        let single = [items[0]]
        #expect(Shuffler.arrange(single, firstId: single[0].id, lastId: nil) == single)
        #expect(Shuffler.arrange([], firstId: nil, lastId: nil).isEmpty)
    }
}
