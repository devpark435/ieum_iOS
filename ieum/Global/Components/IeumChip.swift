import UIKit
import SnapKit
import Then

class IeumChip: UIButton {
    
    // MARK: - Types
    
    enum ChipType {
        case select // 기본 선택형 (토글 가능)
        case `static` // 고정형 (스텝 뱃지 등)
    }
    
    // MARK: - Properties
    
    private let type: ChipType
    
    /// 선택 상태가 변경될 때 호출되는 클로저 (변경된 상태값 isSelected 전달)
    var onSelectionChanged: ((Bool) -> Void)?
    
    override var isSelected: Bool {
        didSet {
            if type == .select {
                updateStyle()
                onSelectionChanged?(isSelected)
            }
        }
    }
    
    // MARK: - Initializer
    
    init(title: String, type: ChipType = .select) {
        self.type = type
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
        setupLayout()
        
        // 탭 제스처 기본 연결 (선택형일 때만)
        if type == .select {
            self.addTarget(self, action: #selector(didTapSelf), for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupStyle() {
        titleLabel?.font = .ieum(UIFont.IeumFont.label) // 15px Regular
        layer.cornerRadius = 13 // 높이 26 기준
        
        switch type {
        case .select:
            updateStyle() // 초기 상태(비선택) 적용
        case .static:
            // 스텝 뱃지 스타일 (검정 배경, 흰색 텍스트)
            backgroundColor = Colors.Gray.g950
            setTitleColor(Colors.white, for: .normal)
            layer.borderWidth = 0
            isUserInteractionEnabled = false // 터치 불가
        }
    }
    
    private func setupLayout() {
        snp.makeConstraints {
            $0.height.equalTo(26) // 스텝 뱃지 높이 기준 26 (기존 칩은 32였음, 상황에 따라 조절 필요)
        }
        
        // 패딩: 스텝 뱃지는 패딩이 적거나 고정 너비일 수 있음
        // 기존 칩(32)과 스텝 뱃지(26) 높이가 다르므로 type에 따라 분기하거나 오토레이아웃으로 처리
        if type == .static {
             contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        } else {
             contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
             snp.updateConstraints { $0.height.equalTo(32) }
        }
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
        // self.isSelected.toggle() // 외부 제어 권장
    }
}
