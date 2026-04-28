import UIKit
import SnapKit
import Then

protocol SettingsViewControllerDelegate: AnyObject {
    func didTapBlockedUsers()
    func didTapPrivacyPolicy()
    func didTapDeleteAccount()
    func didTapLogout()
}

final class SettingsViewController: UIViewController {
    
    // MARK: - Types
    
    enum SettingsSection: Int, CaseIterable {
        case info       // 정보 섹션 (개인정보 처리방침)
        case account    // 계정 섹션 (회원탈퇴, 로그아웃)
    }
    
    enum SettingsItem {
        case blockedUsers     // 차단 목록
        case privacyPolicy    // 개인정보 처리방침
        case deleteAccount    // 회원탈퇴
        case logout           // 로그아웃

        var title: String {
            switch self {
            case .blockedUsers: return "차단 목록"
            case .privacyPolicy: return "개인정보 처리방침"
            case .deleteAccount: return "회원탈퇴"
            case .logout: return "로그아웃"
            }
        }

        var textColor: UIColor {
            switch self {
            case .deleteAccount, .logout: return UIColor.systemRed
            default: return Colors.Gray.g950
            }
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: SettingsViewControllerDelegate?
    
    private let infoItems: [SettingsItem] = [.blockedUsers, .privacyPolicy]
    private let accountItems: [SettingsItem] = [.deleteAccount, .logout]
    
    // MARK: - UI Components
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = Colors.Slate.s50
        $0.separatorStyle = .singleLine
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s50
        setupNavigationBar()
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "설정"
        
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    private func setupLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func handleItemSelection(_ item: SettingsItem) {
        switch item {
        case .blockedUsers:
            delegate?.didTapBlockedUsers()
        case .privacyPolicy:
            delegate?.didTapPrivacyPolicy()
        case .deleteAccount:
            showDeleteAccountConfirmation()
        case .logout:
            showLogoutConfirmation()
        }
    }
    
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "정말 탈퇴하시겠습니까?\n모든 게시물, 댓글, 이미지가 삭제됩니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.delegate?.didTapDeleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.delegate?.didTapLogout()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SettingsSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .info:
            return infoItems.count
        case .account:
            return accountItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = getItem(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.textProperties.color = item.textColor
        content.textProperties.font = .ieum(UIFont.IeumFont.Text.bodyM)
        
        cell.contentConfiguration = content
        cell.backgroundColor = Colors.white
        cell.selectionStyle = .none
        cell.accessoryType = (item == .privacyPolicy || item == .blockedUsers) ? .disclosureIndicator : .none
        
        return cell
    }
    
    private func getItem(at indexPath: IndexPath) -> SettingsItem {
        guard let sectionType = SettingsSection(rawValue: indexPath.section) else {
            return .privacyPolicy
        }
        switch sectionType {
        case .info:
            return infoItems[indexPath.row]
        case .account:
            return accountItems[indexPath.row]
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = getItem(at: indexPath)
        handleItemSelection(item)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 섹션 간 간격을 위한 빈 헤더
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 20
    }
}
