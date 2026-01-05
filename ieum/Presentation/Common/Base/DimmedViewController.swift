import UIKit
import SnapKit
import Then

class DimmedViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    // 블러 위에 얹을 어두운 레이어 (투명도 조절)
    private let dimmedOverlayView = UIView().then {
        $0.backgroundColor = Colors.black.withAlphaComponent(0.4) // 기본값 40%
    }
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve // 부드러운 전환
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureAndBlurBackground()
    }
    
    // MARK: - Setup
    
    private func setupBaseUI() {
        view.insertSubview(backgroundImageView, at: 0)
        view.insertSubview(dimmedOverlayView, aboveSubview: backgroundImageView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dimmedOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Blur Logic
    
    private func captureAndBlurBackground() {
        guard let presentingView = presentingViewController?.view else { return }
        
        // 스냅샷 캡처
        if let snapshot = presentingView.asImage() {
            // 블러 처리는 무거운 작업이므로 백그라운드에서 수행
            DispatchQueue.global(qos: .userInitiated).async {
                // 피그마 기준 Radius 14.5 적용
                if let blurredImage = snapshot.applyBlur(radius: 14.5) {
                    DispatchQueue.main.async { [weak self] in
                        self?.backgroundImageView.image = blurredImage
                    }
                }
            }
        }
    }
}

