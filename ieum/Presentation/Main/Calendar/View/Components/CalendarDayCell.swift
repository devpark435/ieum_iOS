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
    
    private let todayCircleView = UIView().then {
        $0.backgroundColor = Colors.Slate.s700
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    
    private let dayLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textAlignment = .center
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Lime.l200
    }
    
    private let countLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 9, weight: .semibold)
        $0.textColor = Colors.Gray.g400
        $0.textAlignment = .center
        $0.isHidden = true
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
        countLabel.isHidden = true
        containerView.backgroundColor = Colors.white
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(todayCircleView)
        containerView.addSubview(dayLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(countLabel)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        todayCircleView.snp.makeConstraints {
            $0.center.equalTo(dayLabel)
            $0.width.height.equalTo(24)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dayLabel.snp.bottom).offset(2)
            $0.width.height.equalTo(22)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configure(with item: CalendarDayItem, iconName: String?, selectedFilter: CalendarRecordType?) {
        guard let day = item.day else {
            dayLabel.text = nil
            iconImageView.isHidden = true
            countLabel.isHidden = true
            containerView.backgroundColor = .clear
            return
        }
        
        dayLabel.text = "\(day)"
        
        containerView.backgroundColor = item.isCurrentMonth ? Colors.white : Colors.Slate.s200
        
        if item.isToday && item.isCurrentMonth {
            todayCircleView.isHidden = false
            dayLabel.textColor = Colors.white
        } else {
            todayCircleView.isHidden = true
            
            if !item.isCurrentMonth {
                dayLabel.textColor = Colors.Gray.g300
            } else if let weekday = item.weekday {
                switch weekday {
                case 1:
                    dayLabel.textColor = UIColor.systemRed
                case 7:
                    dayLabel.textColor = UIColor.systemBlue
                default:
                    dayLabel.textColor = Colors.Gray.g950
                }
            }
        }
        
        if let iconName = iconName {
            iconImageView.isHidden = false
            
            if let systemImage = UIImage(systemName: iconName) {
                iconImageView.image = systemImage
                
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
        
        if let record = item.record, record.recordCount >= 2 {
            countLabel.isHidden = false
            countLabel.text = "+\(record.recordCount - 1)"
        } else {
            countLabel.isHidden = true
        }
    }
}
