import UIKit
import SnapKit
import Then

final class CalendarGridView: UIView {
    
    // MARK: - Callbacks
    
    var onDateSelected: ((Date) -> Void)?
    
    // MARK: - Properties
    
    private var calendarDays: [CalendarDayItem] = []
    private var selectedFilter: CalendarRecordType? = nil
    private weak var viewModel: CalendarViewModel?
    
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK: - UI Components
    
    private let weekdayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        return collectionView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupWeekdayLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = Colors.Slate.s100
        
        addSubview(weekdayStackView)
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupLayout() {
        weekdayStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(32)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekdayStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupWeekdayLabels() {
        for (index, day) in weekdays.enumerated() {
            // 원형 배경을 위한 컨테이너 뷰
            let containerView = UIView()
            
            let circleView = UIView().then {
                $0.layer.cornerRadius = 14
                // 일요일은 연한 빨강 (Red.r100), 나머지는 Slate 200
                $0.backgroundColor = index == 0 ? Colors.Red.r100 : Colors.Slate.s200
            }
            
            let label = UILabel().then {
                $0.text = day
                $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
                $0.textAlignment = .center
                
                switch index {
                case 0: // 일요일
                    $0.textColor = UIColor.systemRed
                case 6: // 토요일
                    $0.textColor = UIColor.systemBlue
                default:
                    $0.textColor = Colors.Gray.g600
                }
            }
            
            containerView.addSubview(circleView)
            containerView.addSubview(label)
            
            circleView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(28)
            }
            
            label.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            weekdayStackView.addArrangedSubview(containerView)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with days: [CalendarDayItem], selectedFilter: CalendarRecordType?, viewModel: CalendarViewModel) {
        self.calendarDays = days
        self.selectedFilter = selectedFilter
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        
        let item = calendarDays[indexPath.item]
        let iconName = viewModel?.getIconForDay(item)
        cell.configure(with: item, iconName: iconName, selectedFilter: selectedFilter)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width) / 7
        return CGSize(width: width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = calendarDays[indexPath.item]
        if let date = item.date, item.isCurrentMonth {
            onDateSelected?(date)
        }
    }
}
