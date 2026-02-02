import UIKit
import SnapKit
import Then

class DatePickerInputView: UIView {
    
    // MARK: - Properties
    
    var onDateSelected: ((Date) -> Void)?
    
    var selectedDate: Date? {
        didSet {
            updateDateDisplay()
        }
    }
    
    /// 선택 가능한 최대 날짜 (기본값: 오늘)
    var maximumDate: Date? = Date()
    
    /// 선택 가능한 최소 날짜
    var minimumDate: Date?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Colors.black.cgColor
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Input.placeholder)
        $0.textColor = Colors.Gray.g950
        $0.text = "날짜를 선택해주세요"
    }
    
    private let calendarIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = Colors.Gray.g950
        $0.contentMode = .scaleAspectFit
    }
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
    }
    
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
        addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(calendarIconImageView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(74)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(calendarIconImageView.snp.leading).offset(-8)
        }
        
        calendarIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func didTapContainer() {
        showDatePicker()
    }
    
    private func showDatePicker() {
        guard let viewController = self.findViewController() else { return }
        
        let sheetVC = DatePickerSheetViewController(
            selectedDate: selectedDate ?? Date(),
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            onSelect: { [weak self] date in
                self?.selectedDate = date
                self?.onDateSelected?(date)
            }
        )
        
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        viewController.present(sheetVC, animated: true)
    }
    
    private func updateDateDisplay() {
        guard let date = selectedDate else {
            dateLabel.text = "날짜를 선택해주세요"
            dateLabel.textColor = Colors.Slate.s400
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        dateLabel.text = formatter.string(from: date)
        dateLabel.textColor = Colors.Gray.g950
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
            // UICollectionViewCell을 거쳐서 ViewController 찾기
            if let cell = responder as? UICollectionViewCell {
                responder = cell.superview
                while responder != nil {
                    responder = responder?.next
                    if let viewController = responder as? UIViewController {
                        return viewController
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - DatePickerSheetViewController

private class DatePickerSheetViewController: UIViewController {
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitle("선택", for: .normal)
        $0.setTitleColor(Colors.white, for: .normal)
        $0.backgroundColor = Colors.Gray.g950
        $0.layer.cornerRadius = 12
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Heading.h4)
    }
    
    private var onSelect: ((Date) -> Void)?
    
    init(selectedDate: Date, minimumDate: Date?, maximumDate: Date?, onSelect: @escaping (Date) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.datePicker.date = selectedDate
        self.datePicker.minimumDate = minimumDate
        self.datePicker.maximumDate = maximumDate
        self.onSelect = onSelect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        view.addSubview(datePicker)
        view.addSubview(confirmButton)
        
        datePicker.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    @objc private func didTapConfirm() {
        onSelect?(datePicker.date)
        dismiss(animated: true)
    }
}
