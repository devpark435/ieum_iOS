import UIKit
import SnapKit
import Then

class IeumTextField: UIView {
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Helper.AboveBtn.m)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 1
    }
    
    let textField = UITextField().then {
        $0.font = .ieum(UIFont.IeumFont.Input.placeholder)
        $0.textColor = Colors.Gray.g950
        $0.borderStyle = .none
    }
    
    private let bottomLine = UIView().then {
        $0.backgroundColor = Colors.Gray.g300
    }
    
    private let errorLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Helper.characterCount)
        $0.textColor = Colors.Red.r500
        $0.numberOfLines = 0
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    init(title: String? = nil, placeholder: String? = nil) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        
        if let title = title {
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        
        textField.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        
        let inputContainer = UIView()
        inputContainer.addSubview(textField)
        inputContainer.addSubview(bottomLine)
        
        stackView.addArrangedSubview(inputContainer)
        stackView.addArrangedSubview(errorLabel)
        
        textField.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    func setError(message: String?) {
        if let message = message, !message.isEmpty {
            errorLabel.text = message
            errorLabel.isHidden = false
            bottomLine.backgroundColor = Colors.Red.r500
            titleLabel.textColor = Colors.Red.r500
        } else {
            errorLabel.text = nil
            errorLabel.isHidden = true
            bottomLine.backgroundColor = Colors.Gray.g300
            titleLabel.textColor = Colors.Gray.g950
        }
    }
}
