import UIKit
import SafariServices
import SnapKit
import Then

final class ConsentViewController: UIViewController {

    // MARK: - Properties

    var onConsented: (() -> Void)?

    private let privacyURL = URL(string: "https://southern-dash-bc7.notion.site/2f7a0853c74280b7b6a1d7a0172cbdac")!

    // MARK: - UI Components

    private let logoImageView = UIImageView().then {
        $0.image = Images.Icon.appbarLogo
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.text = "서비스를 이용하기 위해\n개인정보 처리방침에 동의해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
    }

    private let privacyRow = ConsentRowView(title: "(필수) 개인정보 처리방침 동의")

    private let nextButton = IeumButton(title: "다음").then {
        $0.setStyle(backgroundColor: Colors.Lime.l400, borderColor: Colors.Lime.l200, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        setupUI()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(privacyRow)
        view.addSubview(nextButton)
    }

    private func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        privacyRow.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }

    private func setupActions() {
        privacyRow.onCheckChanged = { [weak self] isChecked in
            self?.nextButton.isEnabled = isChecked
        }

        privacyRow.onViewTapped = { [weak self] in
            guard let self else { return }
            let safari = SFSafariViewController(url: self.privacyURL)
            self.present(safari, animated: true)
        }

        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapNext() {
        onConsented?()
    }
}

// MARK: - ConsentRowView

final class ConsentRowView: UIView {

    var onCheckChanged: ((Bool) -> Void)?
    var onViewTapped: (() -> Void)?

    private let checkbox = IeumCheckbox()

    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g700
    }

    private let viewButton = UIButton().then {
        $0.setTitle("보기", for: .normal)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
    }

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(checkbox)
        addSubview(titleLabel)
        addSubview(viewButton)
    }

    private func setupLayout() {
        checkbox.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        viewButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        checkbox.onCheckChanged = { [weak self] isChecked in
            self?.onCheckChanged?(isChecked)
        }
        viewButton.addTarget(self, action: #selector(didTapView), for: UIControl.Event.touchUpInside)
    }

    func setChecked(_ checked: Bool) {
        checkbox.isChecked = checked
    }

    @objc private func didTapView() {
        onViewTapped?()
    }
}
