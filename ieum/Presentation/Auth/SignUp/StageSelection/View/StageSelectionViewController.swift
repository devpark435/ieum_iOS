import UIKit
import SnapKit
import Then

class StageSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var onSelect: ((String) -> Void)?
    private let stages = ["1기", "2기", "3기", "4기", "모르겠어요"]
    private let cancerName: String
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.textAlignment = .left // 필요시 조정
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // MARK: - Initializer
    
    init(cancerName: String) {
        self.cancerName = cancerName
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
        view.backgroundColor = Colors.black.withAlphaComponent(0.4) // 딤드 처리
        
        setupUI()
        setupLayout()
        
        // 배경 탭 시 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGesture)
        
        titleLabel.text = "선택하신 \(cancerName)의 병기를\n알려주세요"
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        
        stages.forEach { stage in
            let button = IeumButton(title: stage, radius: 12).then {
                $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
                $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
            }
            button.addTarget(self, action: #selector(didTapStage(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints {
                $0.height.equalTo(72) // 또는 디자인에 맞는 높이 (72?)
            }
        }
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            // 높이는 내용물에 따라 자동 조절되도록 bottom constraint 추가
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapStage(_ sender: IeumButton) {
        // IeumButton 내부 구조 변경으로 titleLabel 대신 title(for:) 사용
        guard let text = sender.title(for: .normal) else { return }
        
        // 선택 스타일 적용
        sender.isSelected = true
        
        // 0.2초 딜레이 후 닫기
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            let result = text == "모르겠어요" ? "?" : text
            self?.onSelect?(result)
            self?.dismissModal()
        }
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
}

