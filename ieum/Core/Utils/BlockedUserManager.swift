import Foundation

struct BlockedUser: Codable {
    let userId: Int
    let nickname: String
}

final class BlockedUserManager {
    static let shared = BlockedUserManager()
    private let key = "blocked_users_v2"

    private init() {}

    var blockedUsers: [BlockedUser] {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let users = try? JSONDecoder().decode([BlockedUser].self, from: data) else {
                return []
            }
            return users
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    var blockedUserIds: Set<Int> {
        Set(blockedUsers.map { $0.userId })
    }

    func block(userId: Int, nickname: String) {
        guard !isBlocked(userId: userId) else { return }
        var users = blockedUsers
        users.append(BlockedUser(userId: userId, nickname: nickname))
        blockedUsers = users
    }

    func unblock(userId: Int) {
        blockedUsers = blockedUsers.filter { $0.userId != userId }
    }

    func isBlocked(userId: Int) -> Bool {
        blockedUsers.contains { $0.userId == userId }
    }
}
