import UIKit
import SnapKit
import Then

/// 필터용 칩 (파란색 배경 스타일)
final class FilterChip: UIButton {
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        titleLabel?.font = .ieum(UIFont.IeumFont.label)
        layer.cornerRadius = 16
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        snp.makeConstraints {
            $0.height.equalTo(32)
        }
        
        updateStyle()
    }
    
    private func updateStyle() {
        if isSelected {
            backgroundColor = Colors.Slate.s900
            setTitleColor(Colors.white, for: .normal)
            layer.borderWidth = 0
        } else {
            backgroundColor = Colors.Slate.s100
            setTitleColor(Colors.Gray.g950, for: .normal)
            layer.borderWidth = 0
        }
    }
}

/// 필터 칩셋 뷰 (가로 스크롤 가능)
final class FilterChipView: UIView {
    
    // MARK: - Properties
    
    var onFilterSelected: ((String) -> Void)?
    
    private let filterItems = ["전체", "직장암", "대장암", "간이식", "기타"] // "유방암"은 API에 없어서 제외
    private var chips: [FilterChip] = []
    private var selectedFilter: String = "전체"
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupChips()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }
    
    private func setupChips() {
        filterItems.forEach { title in
            let chip = FilterChip(title: title).then {
                if title == "전체" {
                    $0.isSelected = true
                }
            }
            
            chip.addTarget(self, action: #selector(didTapChip(_:)), for: .touchUpInside)
            
            chips.append(chip)
            stackView.addArrangedSubview(chip)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapChip(_ sender: FilterChip) {
        guard let title = sender.title(for: .normal) else { return }
        selectFilter(title)
    }
    
    private func selectFilter(_ title: String) {
        // 이전 선택 해제
        chips.forEach { chip in
            if chip.title(for: .normal) == selectedFilter {
                chip.isSelected = false
            }
        }
        
        // 새 선택 적용
        selectedFilter = title
        if let selectedChip = chips.first(where: { $0.title(for: .normal) == title }) {
            selectedChip.isSelected = true
        }
        
        onFilterSelected?(title)
    }
}

