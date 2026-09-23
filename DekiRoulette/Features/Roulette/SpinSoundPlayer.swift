import AVFAudio

/// スピン中の「カチッ」を鳴らす。止まる位置も回転角もスピン開始時に決まっているので、
/// 鳴らす時刻も先に分かる。`ClickTrack` で 1 本の波形にしてから一度に流し、リズムを揺らさない。
/// 音が出せない環境（素材が読めない、オーディオが使えない等）では黙って何もしない。
@MainActor
final class SpinSoundPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var click: (samples: [Float], format: AVAudioFormat)?

    /// 素材の読み込みとオーディオの準備。画面が出たところで呼んでおく。
    /// セッションの有効化はメインスレッドで待つと UI が固まるので、鳴らす前に別スレッドで終わらせておく。
    func prepare() {
        guard click == nil, let loaded = loadClick() else { return }
        click = loaded
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: loaded.format)

        Task.detached(priority: .utility) {
            let session = AVAudioSession.sharedInstance()
            // 消音（マナー）スイッチに従い、他のアプリで鳴っている音も止めない
            try? session.setCategory(.ambient, mode: .default)
            try? session.setActive(true)
        }
    }

    /// `times`（スピン開始からの秒）にクリック音を鳴らす。呼んだ時点が 0 秒。
    func play(at times: [TimeInterval]) {
        prepare()
        guard !times.isEmpty, let click else { return }

        let track = ClickTrack.render(
            click: click.samples,
            sampleRate: click.format.sampleRate,
            times: times,
            gain: Config.clickGain
        )
        guard let buffer = makeBuffer(track, format: click.format) else { return }
        // 中断のあとはエンジンが止まっているので、鳴らすたびに確かめる
        guard engine.isRunning || (try? engine.start()) != nil else { return }

        player.stop()
        player.scheduleBuffer(buffer, at: nil)
        player.play()
    }

    /// 画面から離れるときなど、鳴らしている途中で止める。
    func stop() {
        guard click != nil else { return }
        player.stop()
        engine.stop()
    }

    private func loadClick() -> (samples: [Float], format: AVAudioFormat)? {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(
                  pcmFormat: file.processingFormat,
                  frameCapacity: AVAudioFrameCount(file.length)
              ),
              (try? file.read(into: buffer)) != nil,
              let channel = buffer.floatChannelData?.pointee
        else { return nil }

        return (Array(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength))), file.processingFormat)
    }

    private func makeBuffer(_ samples: [Float], format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard !samples.isEmpty,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
              let channel = buffer.floatChannelData?.pointee
        else { return nil }

        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { channel.update(from: $0.baseAddress!, count: samples.count) }
        return buffer
    }
}
