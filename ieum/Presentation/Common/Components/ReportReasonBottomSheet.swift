import UIKit
import SnapKit
import Then

final class ReportReasonBottomSheet: UIViewController {
    
    // MARK: - Properties
    
    var onSelectReason: ((ReportReason) -> Void)?
    
    // MARK: - UI Components
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = Colors.black.withAlphaComponent(0)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let headerView = UIView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "신고 사유 선택"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Slate.s800
    }
    
    private let closeButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.Slate.s500
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let reasonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupUI()
        setupLayout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.transform = CGAffineTransform(translationX: 0, y: 400)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        containerView.addSubview(separatorView)
        containerView.addSubview(reasonStackView)
        
        for reason in ReportReason.allCases {
            let button = createReasonButton(reason)
            reasonStackView.addArrangedSubview(button)
        }
    }
    
    private func setupLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        reasonStackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmedTap))
        dimmedView.addGestureRecognizer(tapGesture)
        
        closeButton.addTarget(self, action: #selector(handleCloseTap), for: .touchUpInside)
    }
    
    // MARK: - Reason Button Factory
    
    private func createReasonButton(_ reason: ReportReason) -> UIView {
        let container = UIView()
        container.backgroundColor = Colors.white
        
        let button = UIButton()
        button.tag = ReportReason.allCases.firstIndex(of: reason) ?? 0
        button.addTarget(self, action: #selector(handleReasonTap(_:)), for: .touchUpInside)
        
        let label = UILabel().then {
            $0.text = reason.displayName
            $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
            $0.textColor = Colors.Slate.s700
            $0.isUserInteractionEnabled = false
        }
        
        let chevron = UIImageView().then {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            $0.image = UIImage(systemName: "chevron.right", withConfiguration: config)
            $0.tintColor = Colors.Slate.s300
            $0.isUserInteractionEnabled = false
        }
        
        container.addSubview(button)
        container.addSubview(label)
        container.addSubview(chevron)
        
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        return container
    }
    
    // MARK: - Animation
    
    private func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.backgroundColor = Colors.black.withAlphaComponent(0.4)
            self.containerView.transform = .identity
        }
    }
    
    private func hideBottomSheet(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmedView.backgroundColor = Colors.black.withAlphaComponent(0)
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 400)
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleDimmedTap() {
        hideBottomSheet {
            self.dismiss(animated: false)
        }
    }
    
    @objc private func handleCloseTap() {
        hideBottomSheet {
            self.dismiss(animated: false)
        }
    }
    
    @objc private func handleReasonTap(_ sender: UIButton) {
        let reason = ReportReason.allCases[sender.tag]
        hideBottomSheet {
            self.dismiss(animated: false) {
                self.onSelectReason?(reason)
            }
        }
    }
}
