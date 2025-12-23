import UIKit
import SnapKit
import Then

class IeumChip: UIButton {
    
    // MARK: - Properties
    
    /// 선택 상태가 변경될 때 호출되는 클로저 (변경된 상태값 isSelected 전달)
    var onSelectionChanged: ((Bool) -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
            onSelectionChanged?(isSelected)
        }
    }
    
    // MARK: - Initializer
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
        setupLayout()
        
        // 탭 제스처 기본 연결
        self.addTarget(self, action: #selector(didTapSelf), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupStyle() {
        titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        layer.cornerRadius = 16
        updateStyle()
    }
    
    private func setupLayout() {
        snp.makeConstraints {
            $0.height.equalTo(32)
        }
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func updateStyle() {
        if isSelected {
            backgroundColor = Colors.Gray.g950
            setTitleColor(Colors.white, for: .normal)
            layer.borderWidth = 0
        } else {
            backgroundColor = Colors.white
            setTitleColor(Colors.Gray.g950, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = Colors.Gray.g200.cgColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapSelf() {
        // 토글 동작 기본 내장 (필요 없다면 이 부분을 외부에서 제어하도록 변경 가능)
        // 현재는 UI 컴포넌트 자체적으로 토글 기능을 가짐
        // self.isSelected.toggle() // -> 외부에서 addTarget으로 제어하는게 더 유연할 수 있어서 주석 처리하거나 옵션으로 제공
    }
}
