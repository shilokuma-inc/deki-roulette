import Testing
@testable import DekiRoulette

@MainActor
struct RouletteModelTests {
    private func makeModel(_ labels: [String] = ["A", "B", "C", "D"]) -> RouletteModel {
        RouletteModel(items: ItemLabel.makeItems(labels))
    }

    @Test func 項目は上限まで追加できる() {
        let model = makeModel([])
        for i in 0..<30 { model.addItem("項目\(i)") }
        #expect(model.items.count == Config.maxItems)
        #expect(model.atCapacity)
    }

    @Test func 空のラベルは追加されない() {
        let model = makeModel([])
        model.addItem("   ")
        #expect(model.items.isEmpty)
    }

    @Test func 項目が2つ未満なら回せない() {
        let model = makeModel(["A"])
        #expect(!model.canSpin)
        #expect(model.beginSpin(reducedMotion: false) == nil)
    }

    @Test func 当たり指定はトグルする() {
        let model = makeModel()
        let id = model.items[1].id
        model.toggleTarget(id: id)
        #expect(model.targetId == id)
        #expect(model.marks == [id: .target])
        model.toggleTarget(id: id)
        #expect(model.targetId == nil)
    }

    @Test func 指定した項目を削除すると指定も外れる() {
        let model = makeModel()
        let id = model.items[2].id
        model.toggleTarget(id: id)
        model.removeItem(id: id)
        #expect(model.targetId == nil)
        #expect(model.items.count == 3)
    }

    @Test func 削除すると削除した項目と元の位置が返る() {
        let model = makeModel()
        let item = model.items[1]
        let removed = model.removeItem(id: item.id)
        #expect(removed == RemovedItem(item: item, index: 1))
        #expect(model.items.map(\.label) == ["A", "C", "D"])
        #expect(model.removeItem(id: item.id) == nil)
    }

    @Test func 元に戻すと同じIDで元の位置に入る() {
        let model = makeModel()
        let removed = model.removeItem(id: model.items[1].id)!
        model.restore(removed.item, at: removed.index)
        #expect(model.items.map(\.label) == ["A", "B", "C", "D"])
        #expect(model.items[1].id == removed.item.id)
    }

    @Test func 元に戻しても指定は復元しない() {
        let model = makeModel()
        let id = model.items[2].id
        model.toggleTarget(id: id)
        let removed = model.removeItem(id: id)!
        model.restore(removed.item, at: removed.index)
        #expect(model.targetId == nil)
        #expect(model.marks.isEmpty)
    }

    @Test func 元の位置が範囲外なら末尾に戻す() {
        let model = makeModel()
        let removed = model.removeItem(id: model.items[3].id)!
        model.removeItem(id: model.items[2].id)
        model.restore(removed.item, at: removed.index)
        #expect(model.items.map(\.label) == ["A", "B", "D"])
    }

    @Test func 同じ項目が残っているか上限に達していれば戻さない() {
        let model = makeModel()
        model.restore(model.items[0], at: 0)
        #expect(model.items.count == 4)

        let full = makeModel([])
        for i in 0..<Config.maxItems { full.addItem("項目\(i)") }
        full.restore(Item(label: "E"), at: 0)
        #expect(full.items.count == Config.maxItems)
    }

    @Test func 元に戻すと結果が消える() {
        let model = makeModel()
        let removed = model.removeItem(id: model.items[0].id)!
        model.rotation = model.beginSpin(reducedMotion: false)!
        model.finishSpin()
        #expect(model.result != nil)
        model.restore(removed.item, at: removed.index)
        #expect(model.result == nil)
    }

    @Test func すべて削除すると項目も指定も結果も消える() {
        let model = makeModel()
        model.toggleTarget(id: model.items[1].id)
        model.rotation = model.beginSpin(reducedMotion: false)!
        model.finishSpin()
        model.removeAll()
        #expect(model.items.isEmpty)
        #expect(model.targetId == nil)
        #expect(model.result == nil)
        #expect(!model.canSpin)
    }

    @Test func 指定があれば結果はその項目になる() {
        for _ in 0..<50 {
            let model = makeModel()
            model.toggleTarget(id: model.items[3].id)
            let next = model.beginSpin(reducedMotion: false)
            #expect(next != nil)
            #expect(model.spinning)
            #expect(model.result == nil)
            model.rotation = next!
            model.finishSpin()
            #expect(!model.spinning)
            #expect(model.result == "D")
            #expect(RouletteMath.indexUnderPointer(rotation: model.rotation, count: 4) == 3)
        }
    }

    @Test func 指定がなければ結果は針の下の項目と一致する() {
        for _ in 0..<50 {
            let model = makeModel()
            let next = model.beginSpin(reducedMotion: false)!
            model.rotation = next
            model.finishSpin()
            let index = RouletteMath.indexUnderPointer(rotation: next, count: 4)
            #expect(model.result == model.items[index].label)
        }
    }

    @Test func スピン中は二重に始められない() {
        let model = makeModel()
        #expect(model.beginSpin(reducedMotion: false) != nil)
        #expect(model.beginSpin(reducedMotion: false) == nil)
    }

    @Test func 結果の添字は針の下のスライスと一致する() throws {
        for _ in 0..<50 {
            let model = makeModel()
            let next = model.beginSpin(reducedMotion: false)!
            model.rotation = next
            model.finishSpin()
            let outcome = try #require(model.outcome)
            #expect(outcome.index == RouletteMath.indexUnderPointer(rotation: next, count: 4))
            #expect(outcome.label == model.items[outcome.index].label)
        }
    }

    @Test func 同じラベルが並んでいても結果の添字は指定した項目を指す() {
        let model = makeModel(["A", "A", "A", "A"])
        model.toggleTarget(id: model.items[2].id)
        model.rotation = model.beginSpin(reducedMotion: false)!
        model.finishSpin()
        #expect(model.outcome == SpinOutcome(index: 2, label: "A"))
    }

    @Test func 項目を触ると結果が消える() {
        let model = makeModel()
        model.rotation = model.beginSpin(reducedMotion: false)!
        model.finishSpin()
        #expect(model.result != nil)
        model.addItem("E")
        #expect(model.result == nil)
    }
}
