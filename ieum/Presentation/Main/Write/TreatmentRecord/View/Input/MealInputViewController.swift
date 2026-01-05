import UIKit
import SnapKit
import Then

final class MealInputViewController: UIViewController {
    
    // MARK: - Properties
    
    var onComplete: ((MealStatus, String?) -> Void)?
    
    private var selectedStatus: MealStatus = .good {
        didSet {
            updateChipSelection()
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "어떻게 드셨나요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
    }
    
    // Chips
    private let chipsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private lazy var goodChip = createChip(title: "잘먹음", icon: "face-smile", status: .good)
    private lazy var littleChip = createChip(title: "소량", icon: "face-neutral", status: .little)
    private lazy var badChip = createChip(title: "못먹음", icon: "face-frown", status: .bad)
    
    private lazy var textView = UITextView().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
        $0.delegate = self
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = "식사 내용을 적어주세요"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
        $0.numberOfLines = 0
    }
    
    private lazy var accessoryView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56))
        view.backgroundColor = Colors.Gray.g200
        
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(Colors.white, for: .normal)
        button.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return view
    }()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        setupUI()
        setupLayout()
        updateChipSelection()
        
        textView.inputAccessoryView = accessoryView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func createChip(title: String, icon: String, status: MealStatus) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(Colors.Gray.g600, for: .normal)
        button.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        button.layer.cornerRadius = 20 // 40 height / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.Gray.g200.cgColor
        
        // 아이콘 설정 (시스템 이미지 예시)
        // 실제로는 icon 파라미터 사용해야 함
        let image = UIImage(systemName: "face.smiling") // 임시
        button.setImage(image, for: .normal)
        button.tintColor = Colors.Gray.g600
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedStatus = status
        }), for: UIControl.Event.touchUpInside)
        
        return button
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(chipsStackView)
        chipsStackView.addArrangedSubview(goodChip)
        chipsStackView.addArrangedSubview(littleChip)
        chipsStackView.addArrangedSubview(badChip)
        
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        chipsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(chipsStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func updateChipSelection() {
        let chips: [(UIButton, MealStatus)] = [
            (goodChip, .good),
            (littleChip, .little),
            (badChip, .bad)
        ]
        
        for (btn, status) in chips {
            if status == selectedStatus {
                // Primary.lime 대신 Lime.l400 또는 l100 등 적절한 색상 사용
                // 배경은 연한 색, 글자/테두리는 진한 색 권장
                btn.backgroundColor = Colors.Lime.l100
                btn.layer.borderColor = Colors.Lime.l400.cgColor
                btn.setTitleColor(Colors.Lime.l500, for: .normal)
                btn.tintColor = Colors.Lime.l500
            } else {
                btn.backgroundColor = Colors.white
                btn.layer.borderColor = Colors.Gray.g200.cgColor
                btn.setTitleColor(Colors.Gray.g600, for: .normal)
                btn.tintColor = Colors.Gray.g600
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        onComplete?(selectedStatus, textView.text)
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
}

extension MealInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

