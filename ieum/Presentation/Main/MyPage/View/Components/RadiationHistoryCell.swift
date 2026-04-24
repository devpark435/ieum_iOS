import UIKit
import SnapKit
import Then

final class RadiationHistoryCell: UICollectionViewCell {
    
    static let identifier = "RadiationHistoryCell"
    
    // MARK: - Properties
    
    var onDelete: (() -> Void)?
    var onStartDateChanged: ((Date) -> Void)?
    var onEndDateChanged: ((Date) -> Void)?
    var onInProgressChanged: ((Bool) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200Border.cgColor
    }
    
    private let deleteButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        $0.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        $0.tintColor = Colors.Red.r400
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }

    private let startDateLabel = UILabel().then {
        $0.text = "시작날짜"
        $0.font = .ieum(UIFont.IeumFont.Heading.h5)
        $0.textColor = Colors.Gray.g950
    }
    
    private let startDatePickerInputView = DatePickerInputView()
    
    private let endDateContainerView = UIView()
    
    private let endDateLabel = UILabel().then {
        $0.text = "종료날짜"
        $0.font = .ieum(UIFont.IeumFont.Heading.h5)
        $0.textColor = Colors.Gray.g950
    }
    
    private let endDatePickerInputView = DatePickerInputView()
    
    private let inProgressChip = InProgressChip()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(deleteButton)
        containerView.addSubview(stackView)

        stackView.addArrangedSubview(startDateLabel)
        stackView.addArrangedSubview(startDatePickerInputView)

        endDateContainerView.addSubview(endDateLabel)
        endDateContainerView.addSubview(endDatePickerInputView)
        endDateContainerView.addSubview(inProgressChip)
        stackView.addArrangedSubview(endDateContainerView)
    }

    private func setupLayout() {
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 40)
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(28)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(deleteButton.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        endDateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        endDatePickerInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(endDateLabel.snp.bottom).offset(12)
            $0.bottom.equalToSuperview()
        }
        
        inProgressChip.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(endDateLabel)
        }
    }
    
    private func setupActions() {
        startDatePickerInputView.onDateSelected = { [weak self] date in
            self?.onStartDateChanged?(date)
        }

        endDatePickerInputView.onDateSelected = { [weak self] date in
            self?.onEndDateChanged?(date)
        }

        inProgressChip.onCheckChanged = { [weak self] isChecked in
            self?.updateEndDateEnabled(!isChecked)
            self?.onInProgressChanged?(isChecked)
        }

        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    }

    private func updateEndDateEnabled(_ enabled: Bool) {
        endDatePickerInputView.isUserInteractionEnabled = enabled
        endDatePickerInputView.alpha = enabled ? 1.0 : 0.5
    }

    @objc private func didTapDelete() {
        showDeleteConfirmation()
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "삭제", message: "이 방사선 이력을 삭제하시겠습니까?", preferredStyle: .alert)
        
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
    
    func configure(startDate: Date?, endDate: Date?, isInProgress: Bool) {
        startDatePickerInputView.selectedDate = startDate
        endDatePickerInputView.selectedDate = endDate
        inProgressChip.isChecked = isInProgress
        updateEndDateEnabled(!isInProgress)
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
