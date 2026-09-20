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

    @Test func 項目を触ると結果が消える() {
        let model = makeModel()
        model.rotation = model.beginSpin(reducedMotion: false)!
        model.finishSpin()
        #expect(model.result != nil)
        model.addItem("E")
        #expect(model.result == nil)
    }
}
