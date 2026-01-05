import UIKit
import SnapKit
import Then

final class TextInputViewController: UIViewController {
    
    // MARK: - Properties
    
    var onComplete: ((String) -> Void)?
    
    private let titleText: String
    private let placeholderText: String
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
    }
    
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
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
        $0.numberOfLines = 0
    }
    
    // Input Accessory View
    private lazy var accessoryView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56))
        view.backgroundColor = Colors.Gray.g100 // 키보드 위 배경색 확인 필요
        
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        button.setTitleColor(Colors.Gray.g600, for: .normal) // 활성 상태에 따라 색상 변경 필요
        button.backgroundColor = Colors.Gray.g200 // 비활성 배경
        // button.layer.cornerRadius?
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        // 버튼 스타일링은 디자인에 맞춰 조정 필요. 예시 이미지는 키보드 바로 위에 회색 바 형태
        // 여기서는 전체가 버튼인 형태로 가정하거나, 우측에 완료 버튼이 있는 형태일 수 있음.
        // 이미지상으로는 '완료' 버튼이 키보드 위에 꽉 차있는 형태(혹은 툴바 형태)로 보임.
        
        // 꽉 찬 버튼 형태로 구현
        button.backgroundColor = Colors.Gray.g200
        button.setTitleColor(Colors.white, for: .normal) // 텍스트 색상
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - Initializer
    
    init(title: String, placeholder: String) {
        self.titleText = title
        self.placeholderText = placeholder
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
        
        titleLabel.text = titleText
        placeholderLabel.text = placeholderText
        
        // 텍스트뷰에 액세서리 뷰 연결
        textView.inputAccessoryView = accessoryView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160) // 적절한 높이 설정
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        onComplete?(textView.text)
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
}

extension TextInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

