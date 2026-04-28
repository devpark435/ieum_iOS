import UIKit
import SnapKit
import Then

final class BlockedUsersViewController: UIViewController {

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = Colors.Slate.s50
        $0.separatorStyle = .singleLine
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.register(BlockedUserCell.self, forCellReuseIdentifier: BlockedUserCell.identifier)
    }

    private let emptyLabel = UILabel().then {
        $0.text = "차단한 사용자가 없습니다"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - State

    private var blockedUsers: [BlockedUser] = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s50
        setupNavigationBar()
        setupUI()
        setupLayout()
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "차단 목록"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.white
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.Gray.g950,
            .font: UIFont.ieum(UIFont.IeumFont.Heading.h4)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = Colors.Gray.g950
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupLayout() {
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    // MARK: - Helpers

    private func reload() {
        blockedUsers = BlockedUserManager.shared.blockedUsers
        emptyLabel.isHidden = !blockedUsers.isEmpty
        tableView.isHidden = blockedUsers.isEmpty
        tableView.reloadData()
    }

    private func showUnblockConfirmation(for user: BlockedUser) {
        let alert = UIAlertController(
            title: "차단 해제",
            message: "\(user.nickname)님의 차단을 해제하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "해제", style: .destructive) { [weak self] _ in
            BlockedUserManager.shared.unblock(userId: user.userId)
            self?.reload()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension BlockedUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserCell.identifier, for: indexPath) as? BlockedUserCell else {
            return UITableViewCell()
        }
        let user = blockedUsers[indexPath.row]
        cell.configure(nickname: user.nickname) { [weak self] in
            self?.showUnblockConfirmation(for: user)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BlockedUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 56 }
}

// MARK: - BlockedUserCell

private final class BlockedUserCell: UITableViewCell {
    static let identifier = "BlockedUserCell"

    private let nicknameLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
    }

    private let unblockButton = UIButton(type: .system).then {
        $0.setTitle("차단 해제", for: .normal)
        $0.setTitleColor(Colors.Red.r500, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
    }

    private var onUnblock: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Colors.white

        contentView.addSubview(nicknameLabel)
        contentView.addSubview(unblockButton)

        nicknameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(unblockButton.snp.leading).offset(-8)
        }

        unblockButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        unblockButton.addTarget(self, action: #selector(didTapUnblock), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(nickname: String, onUnblock: @escaping () -> Void) {
        nicknameLabel.text = nickname
        self.onUnblock = onUnblock
    }

    @objc private func didTapUnblock() { onUnblock?() }
}
