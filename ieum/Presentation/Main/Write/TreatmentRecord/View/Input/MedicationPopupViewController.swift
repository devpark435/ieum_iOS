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
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .left
    }
    
    private let takenButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(Colors.Gray.g950, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
        $0.contentHorizontalAlignment = .left
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.Lime.l400
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    private let notTakenButton = UIButton().then {
        $0.setTitle("미완료", for: .normal)
        $0.setTitleColor(Colors.Gray.g950, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
        $0.contentHorizontalAlignment = .left
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.Red.r500
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
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
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(takenButton)
        containerView.addSubview(notTakenButton)
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
        
        takenButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
        
        notTakenButton.snp.makeConstraints {
            $0.top.equalTo(takenButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapGesture)
        
        let containerTap = UITapGestureRecognizer(target: self, action: nil)
        containerView.addGestureRecognizer(containerTap)
        
        takenButton.addTarget(self, action: #selector(didTapTaken), for: .touchUpInside)
        notTakenButton.addTarget(self, action: #selector(didTapNotTaken), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackground() {
        dismiss(animated: true)
    }
    
    @objc private func didTapTaken() {
        onSelect?(.taken)
        dismiss(animated: true)
    }
    
    @objc private func didTapNotTaken() {
        onSelect?(.notTaken)
        dismiss(animated: true)
    }
}
