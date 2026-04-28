import Foundation

final class BlockedUserManager {
    static let shared = BlockedUserManager()
    private let key = "blocked_user_ids"

    private init() {}

    var blockedUserIds: Set<Int> {
        get {
            let arr = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    func block(userId: Int) {
        var ids = blockedUserIds
        ids.insert(userId)
        blockedUserIds = ids
    }

    func isBlocked(userId: Int) -> Bool {
        blockedUserIds.contains(userId)
    }
}
