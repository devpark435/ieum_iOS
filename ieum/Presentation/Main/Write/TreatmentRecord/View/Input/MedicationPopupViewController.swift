import UIKit
import SnapKit
import Then

final class MedicationPopupViewController: DimmedViewController {
    
    // MARK: - Properties
    
    var onSelect: ((MedicationStatus) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "복약 상태는 어떤가요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h2) // h4 -> h2
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .left
    }
    
    // 버튼 컨테이너 (Spacing 12)
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private lazy var takenButton = createSelectionButton(
        title: "완료",
        iconName: "checkmark.circle.fill",
        color: Colors.Lime.l400,
        action: #selector(didTapTaken)
    )
    
    private lazy var notTakenButton = createSelectionButton(
        title: "미완료",
        iconName: "xmark.circle.fill",
        color: Colors.Red.r500,
        action: #selector(didTapNotTaken)
    )
    
    // MARK: - Initializer
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }
    
    // MARK: - Helper
    
    private func createSelectionButton(title: String, iconName: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = Colors.white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.Slate.s200.cgColor // 기본 Border
        
        // Content Stack
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4 // 이모지랑 텍스트 사이 여백 4
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: iconName, withConfiguration: config)
        let iconView = UIImageView(image: image)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = .ieum(UIFont.IeumFont.Text.bodyM)
        label.textColor = Colors.Gray.g950
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        button.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10) // 좌 10
            $0.top.bottom.equalToSuperview().inset(14) // 상하 14
            $0.trailing.lessThanOrEqualToSuperview().inset(10) // 우 10 (lessThanOrEqual)
        }
        
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Touch Highlight Logic (Optional: TouchDown 시 Border 변경 등)
        button.addAction(UIAction(handler: { _ in
            button.layer.borderColor = Colors.Green.g500.cgColor
        }), for: .touchDown)
        
        button.addAction(UIAction(handler: { _ in
             button.layer.borderColor = Colors.Slate.s200.cgColor
        }), for: [.touchCancel, .touchUpOutside])
        
        return button
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(takenButton)
        buttonStackView.addArrangedSubview(notTakenButton)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        // 버튼 높이는 내부 컨텐츠 패딩에 의해 결정되거나 고정할 수 있음.
        // 기존 72 높이였으나, 패딩 요구사항(상하 14)에 따르면 내용물 높이 + 28이 됨.
        // 텍스트 bodyM lineHeight 약 24 가정 시 24+28 = 52 정도.
        // 버튼 높이 명시 안하면 StackView가 알아서 늘림.
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapGesture)
        
        let containerTap = UITapGestureRecognizer(target: self, action: nil)
        containerView.addGestureRecognizer(containerTap)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackground() {
        dismiss(animated: true)
    }
    
    @objc private func didTapTaken() {
        // 선택 시 Border Color 변경 (Green 500) - UI Feedback
        takenButton.layer.borderColor = Colors.Green.g500.cgColor
        // 잠시 딜레이 후 dismiss? 또는 바로 dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.onSelect?(.taken)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapNotTaken() {
        notTakenButton.layer.borderColor = Colors.Green.g500.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.onSelect?(.notTaken)
            self.dismiss(animated: true)
        }
    }
}
