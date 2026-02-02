import UIKit
import SnapKit
import Then

final class SurgeryHistoryCell: UICollectionViewCell {
    
    static let identifier = "SurgeryHistoryCell"
    
    // MARK: - Properties
    
    var onDelete: (() -> Void)?
    var onDateChanged: ((Date) -> Void)?
    var onDescriptionChanged: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200Border.cgColor
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "수술날짜"
        $0.font = .ieum(UIFont.IeumFont.Heading.h5)
        $0.textColor = Colors.Gray.g950
    }
    
    private let datePickerInputView = DatePickerInputView()
    
    private let descriptionLabel = UILabel().then {
        $0.text = "수술이름"
        $0.font = .ieum(UIFont.IeumFont.Heading.h5)
        $0.textColor = Colors.Gray.g950
    }
    
    private let descriptionInputView = IeumInputView(maxCount: 20).then {
        $0.textField.placeholder = "수술이름을 입력해주세요"
        $0.setBorderColors(defaultColor: Colors.black, activeColor: Colors.Primary.green)
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
        setupSwipeGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(datePickerInputView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(descriptionInputView)
    }
    
    private func setupLayout() {
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 40)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setupActions() {
        datePickerInputView.onDateSelected = { [weak self] date in
            self?.onDateChanged?(date)
        }
        
        descriptionInputView.textField.addTarget(self, action: #selector(descriptionDidChange), for: .editingChanged)
    }
    
    private func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .left
        addGestureRecognizer(swipeGesture)
    }
    
    @objc private func descriptionDidChange() {
        let text = descriptionInputView.textField.text ?? ""
        onDescriptionChanged?(text)
    }
    
    @objc private func handleSwipe() {
        showDeleteConfirmation()
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "삭제", message: "이 수술 이력을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.onDelete?()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let viewController = self.findViewController() {
            viewController.present(alert, animated: true)
        }
    }
    
    func configure(date: Date?, description: String) {
        datePickerInputView.selectedDate = date
        descriptionInputView.textField.text = description
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
