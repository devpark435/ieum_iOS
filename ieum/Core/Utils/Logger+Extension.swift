import OSLog

extension Logger {
    // 앱의 번들 ID를 서브시스템으로 사용
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.ieum.ieum"

    // 카테고리별 로거 정의
    static let network = Logger(subsystem: subsystem, category: "network")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let debug = Logger(subsystem: subsystem, category: "debug")
}
