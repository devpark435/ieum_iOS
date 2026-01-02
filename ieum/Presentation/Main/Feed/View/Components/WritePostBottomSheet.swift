import UIKit
import SnapKit
import Then

final class WritePostBottomSheet: UIViewController {
    
    // MARK: - Properties
    
    var onSelectTreatmentRecord: (() -> Void)?
    var onSelectDailyRecord: (() -> Void)?
    
    // MARK: - UI Components
    
    private let blurEffectView = UIVisualEffectView().then {
        $0.effect = nil
        $0.backgroundColor = Colors.black.withAlphaComponent(0)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 16
        $0.layer.shadowOpacity = 0.1
        $0.clipsToBounds = false
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fillEqually
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let treatmentRecordButton = UIButton().then {
        $0.backgroundColor = Colors.white
    }
    
    private let treatmentRecordIcon = UIImageView().then {
        $0.image = UIImage(named: "treatmentrecord-icon")
        $0.contentMode = .scaleAspectFit
    }
    
    private let treatmentTitleLabel = UILabel().then {
        $0.text = "치료 기록"
        $0.font = .ieum(UIFont.IeumFont.Heading.h3)
        $0.textColor = Colors.Slate.s800
    }
    
    private let treatmentSubtitleLabel = UILabel().then {
        $0.text = "내 몸의 하루, 오늘은 어땠나요?"
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Slate.s500
    }
    
    private let dailyRecordButton = UIButton().then {
        $0.backgroundColor = Colors.white
    }
    
    private let dailyRecordIcon = UIImageView().then {
        $0.image = UIImage(named: "dailyrecord-icon")
        $0.contentMode = .scaleAspectFit
    }
    
    private let dailyTitleLabel = UILabel().then {
        $0.text = "일상 기록"
        $0.font = .ieum(UIFont.IeumFont.Heading.h3)
        $0.textColor = Colors.Slate.s800
    }
    
    private let dailySubtitleLabel = UILabel().then {
        $0.text = "자유롭게 이야기를 기록해 보세요."
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Slate.s500
    }
    
    // MARK: - Initializer
    
    init() {
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
        view.backgroundColor = .clear
        
        setupUI()
        setupLayout()
        setupActions()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmedViewTap))
        blurEffectView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.transform = CGAffineTransform(translationX: 0, y: 250)
        containerView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(blurEffectView)
        view.addSubview(containerView)
        containerView.addSubview(contentStackView)
        
        let treatmentView = UIView()
        treatmentView.addSubview(treatmentRecordButton)
        treatmentRecordButton.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        treatmentView.addSubview(treatmentRecordIcon)
        treatmentView.addSubview(treatmentTitleLabel)
        treatmentView.addSubview(treatmentSubtitleLabel)
        treatmentView.isUserInteractionEnabled = true
        
        let dailyView = UIView()
        dailyView.addSubview(dailyRecordButton)
        dailyRecordButton.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        dailyView.addSubview(dailyRecordIcon)
        dailyView.addSubview(dailyTitleLabel)
        dailyView.addSubview(dailySubtitleLabel)
        dailyView.isUserInteractionEnabled = true
        
        contentStackView.addArrangedSubview(treatmentView)
        contentStackView.addArrangedSubview(dailyView)
        
        
        setupContentLayout(view: treatmentView, icon: treatmentRecordIcon, title: treatmentTitleLabel, subtitle: treatmentSubtitleLabel)
        setupContentLayout(view: dailyView, icon: dailyRecordIcon, title: dailyTitleLabel, subtitle: dailySubtitleLabel)
    }
    
    private func setupContentLayout(view: UIView, icon: UIImageView, title: UILabel, subtitle: UILabel) {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(24)
        }
        
        title.snp.makeConstraints {
            $0.leading.equalTo(icon.snp.trailing).offset(4)
            $0.centerY.equalTo(icon)
        }
        
        subtitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(4)
            $0.leading.equalTo(title)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupLayout() {
        blurEffectView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-83)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(blurEffectView.snp.bottom).offset(-28)
            $0.height.equalTo(180)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    private func setupActions() {
        treatmentRecordButton.addTarget(self, action: #selector(didTapTreatment), for: .touchUpInside)
        dailyRecordButton.addTarget(self, action: #selector(didTapDaily), for: .touchUpInside)
    }
    
    // MARK: - Animation
    
    private func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            self.blurEffectView.backgroundColor = Colors.black.withAlphaComponent(0.2)
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }
    
    private func hideBottomSheet(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.blurEffectView.effect = nil
            self.blurEffectView.backgroundColor = .clear
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 250)
            self.containerView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleDimmedViewTap() {
        hideBottomSheet {
            self.dismiss(animated: false)
        }
    }
    
    @objc private func didTapTreatment() {
        hideBottomSheet {
            self.dismiss(animated: false) {
                self.onSelectTreatmentRecord?()
            }
        }
    }
    
    @objc private func didTapDaily() {
        hideBottomSheet {
            self.dismiss(animated: false) {
                self.onSelectDailyRecord?()
            }
        }
    }
}
