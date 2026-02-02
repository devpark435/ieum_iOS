import UIKit
import SnapKit
import Then

final class CalendarDayCell: UICollectionViewCell {
    
    static let identifier = "CalendarDayCell"
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 8
    }
    
    // 오늘 날짜 숫자 뒤 원형 배경
    private let todayCircleView = UIView().then {
        $0.backgroundColor = Colors.Slate.s700
        $0.layer.cornerRadius = 14
        $0.isHidden = true
    }
    
    private let dayLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textAlignment = .center
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Lime.l200
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        dayLabel.textColor = Colors.Gray.g950
        iconImageView.image = nil
        iconImageView.isHidden = true
        todayCircleView.isHidden = true
        containerView.backgroundColor = Colors.white
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(todayCircleView)
        containerView.addSubview(dayLabel)
        containerView.addSubview(iconImageView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        // 오늘 원형 배경 (날짜 숫자 뒤에 배치)
        todayCircleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with item: CalendarDayItem, iconName: String?, selectedFilter: CalendarRecordType?) {
        guard let day = item.day else {
            // 빈 셀
            dayLabel.text = nil
            iconImageView.isHidden = true
            containerView.backgroundColor = .clear
            return
        }
        
        dayLabel.text = "\(day)"
        
        // 셀 배경색 설정 (현재 달: 흰색, 이전/다음 달: Slate.s200)
        containerView.backgroundColor = item.isCurrentMonth ? Colors.white : Colors.Slate.s200
        
        // 오늘 날짜 처리
        if item.isToday && item.isCurrentMonth {
            todayCircleView.isHidden = false
            dayLabel.textColor = Colors.white
        } else {
            todayCircleView.isHidden = true
            
            // 날짜 색상 설정
            if !item.isCurrentMonth {
                dayLabel.textColor = Colors.Gray.g300
            } else if let weekday = item.weekday {
                switch weekday {
                case 1: // 일요일
                    dayLabel.textColor = UIColor.systemRed
                case 7: // 토요일
                    dayLabel.textColor = UIColor.systemBlue
                default:
                    dayLabel.textColor = Colors.Gray.g950
                }
            }
        }
        
        // 아이콘 설정
        if let iconName = iconName {
            iconImageView.isHidden = false
            
            // SF Symbol인지 Asset 이미지인지 확인
            if let systemImage = UIImage(systemName: iconName) {
                iconImageView.image = systemImage
                
                // 필터에 따른 색상 설정
                if let filter = selectedFilter {
                    iconImageView.tintColor = filter.selectedBackgroundColor
                } else if iconName == "checkmark.circle.fill" {
                    iconImageView.tintColor = Colors.Lime.l200
                }
            } else if let assetImage = UIImage(named: iconName) {
                iconImageView.image = assetImage
            }
        } else {
            iconImageView.isHidden = true
        }
    }
}
