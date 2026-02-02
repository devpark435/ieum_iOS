import UIKit
import SnapKit
import Then

final class CalendarHeaderView: UIView {
    
    // MARK: - Callbacks
    
    var onMonthTapped: (() -> Void)?
    var onFilterSelected: ((CalendarRecordType?) -> Void)?
    
    // MARK: - Properties
    
    private var selectedFilter: CalendarRecordType? = nil
    private var filterButtons: [CalendarRecordType: UIButton] = [:]
    
    // MARK: - UI Components
    
    private let monthButton = UIButton().then {
        $0.setTitleColor(Colors.Gray.g950, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Heading.h2)
        $0.contentHorizontalAlignment = .left
    }
    
    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(named: "chevron-down")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Gray.g950
    }
    
    private let filterScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private let filterStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fill
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
        setupFilterChips()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = Colors.white
        
        addSubview(monthButton)
        addSubview(chevronImageView)
        addSubview(filterScrollView)
        filterScrollView.addSubview(filterStackView)
    }
    
    private func setupLayout() {
        monthButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalTo(monthButton)
            $0.leading.equalTo(monthButton.snp.trailing).offset(4)
            $0.width.height.equalTo(20)
        }
        
        filterScrollView.snp.makeConstraints {
            $0.top.equalTo(monthButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        filterStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }
    
    private func setupActions() {
        monthButton.addTarget(self, action: #selector(didTapMonth), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMonth))
        chevronImageView.isUserInteractionEnabled = true
        chevronImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupFilterChips() {
        for type in CalendarRecordType.allCases {
            let button = createFilterButton(for: type)
            filterButtons[type] = button
            filterStackView.addArrangedSubview(button)
        }
    }
    
    private func createFilterButton(for type: CalendarRecordType) -> UIButton {
        let button = UIButton().then {
            $0.setTitle(type.title, for: .normal)
            $0.setTitleColor(Colors.Gray.g600, for: .normal)
            $0.setTitleColor(Colors.Gray.g950, for: .selected)
            $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
            $0.backgroundColor = type.backgroundColor
            $0.layer.cornerRadius = 18
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            $0.tag = CalendarRecordType.allCases.firstIndex(of: type) ?? 0
        }
        
        button.addTarget(self, action: #selector(didTapFilter(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func didTapMonth() {
        onMonthTapped?()
    }
    
    @objc private func didTapFilter(_ sender: UIButton) {
        let type = CalendarRecordType.allCases[sender.tag]
        
        // 같은 필터를 다시 누르면 해제
        if selectedFilter == type {
            selectedFilter = nil
        } else {
            selectedFilter = type
        }
        
        updateFilterUI()
        onFilterSelected?(selectedFilter)
    }
    
    // MARK: - UI Updates
    
    private func updateFilterUI() {
        for (type, button) in filterButtons {
            let isSelected = type == selectedFilter
            button.isSelected = isSelected
            button.backgroundColor = type.backgroundColor
            button.setTitleColor(isSelected ? Colors.Gray.g950 : Colors.Gray.g600, for: .normal)
            
            // 선택된 칩에 Lime 200 border 추가
            if isSelected {
                button.layer.borderWidth = 2
                button.layer.borderColor = Colors.Lime.l200.cgColor
            } else {
                button.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Public Methods
    
    func setMonth(_ monthString: String) {
        monthButton.setTitle(monthString, for: .normal)
    }
    
    func setSelectedFilter(_ filter: CalendarRecordType?) {
        selectedFilter = filter
        updateFilterUI()
    }
}
