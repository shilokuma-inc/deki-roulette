import Testing
@testable import DekiRoulette

@MainActor
struct OrderModelTests {
    private func makeModel(_ labels: [String] = ["A", "B", "C", "D"]) -> OrderModel {
        OrderModel(items: ItemLabel.makeItems(labels))
    }

    @Test func 長押しのたびに先頭_末尾_解除と回る() {
        let model = makeModel()
        let id = model.items[0].id
        model.cycleMark(id: id)
        #expect(model.marks == [id: .first])
        model.cycleMark(id: id)
        #expect(model.marks == [id: .last])
        model.cycleMark(id: id)
        #expect(model.marks.isEmpty)
    }

    @Test func 先頭は1項目まで() {
        let model = makeModel()
        let a = model.items[0].id
        let b = model.items[1].id
        model.cycleMark(id: a)
        model.cycleMark(id: b)
        #expect(model.marks == [b: .first])
    }

    @Test func 先頭を末尾に回すと以前の末尾は外れる() {
        let model = makeModel()
        let a = model.items[0].id
        let b = model.items[1].id
        model.cycleMark(id: b)
        model.cycleMark(id: b)  // b が末尾
        model.cycleMark(id: a)  // a が先頭
        model.cycleMark(id: a)  // a が末尾へ。b の末尾は落ちる
        #expect(model.marks == [a: .last])
    }

    @Test func 指定した項目を削除すると指定も外れる() {
        let model = makeModel()
        let id = model.items[1].id
        model.cycleMark(id: id)
        model.removeItem(id: id)
        #expect(model.marks.isEmpty)
    }

    @Test func 並べ替えは指定を反映する() {
        for _ in 0..<50 {
            let model = makeModel()
            let first = model.items[2].id
            let last = model.items[0].id
            // 末尾を先に確定させる。未指定の項目を長押しすると先頭になり、前の先頭を上書きするため
            model.cycleMark(id: last)
            model.cycleMark(id: last)
            model.cycleMark(id: first)
            model.shuffleItems(reducedMotion: true)
            #expect(model.revealing)
            #expect(model.ordered?.first?.id == first)
            #expect(model.ordered?.last?.id == last)
            #expect(model.ordered.map { Set($0) } == Set(model.items))
        }
    }

    @Test func 演出中は並べ替えられず時間が経つと終わる() async throws {
        let model = makeModel()
        model.shuffleItems(reducedMotion: true)
        #expect(!model.canShuffle)
        try await Task.sleep(for: .seconds(Config.reducedMotionRevealDuration + 0.3))
        #expect(!model.revealing)
        #expect(model.canShuffle)
    }

    @Test func 項目を触ると結果が消える() {
        let model = makeModel()
        model.shuffleItems(reducedMotion: true)
        #expect(model.ordered != nil)
        model.cycleMark(id: model.items[0].id)
        #expect(model.ordered == nil)
    }
}
