import UIKit
import SnapKit
import Then
import Combine

final class MyPageMainViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyPageViewModel
    private let postsViewModel: MyPostsViewModel
    private weak var coordinator: MyPageCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    private var currentTab: MyPageTab = .profile {
        didSet {
            updateTabUI()
            updateChildViewController()
        }
    }
    
    enum MyPageTab {
        case profile
        case posts
    }
    
    // MARK: - Child View Controllers
    
    // Lazy initialization to defer creation until needed (and after ViewModels are ready if needed)
    // Note: MyProfileViewController and MyPostsViewController will be implemented in later steps.
    // For now, we'll use placeholder ViewControllers or if the class names are known, we can instantiate them.
    // Since the plan says "Implement MyPageMainViewController" before child VCs, I will use placeholders
    // or stub classes if they don't exist yet. But to avoid compilation errors, I should check if they exist.
    // They are NOT created yet. So I will create stub classes in this file or separate files.
    // Actually, creating separate files for child VCs is better. 
    // However, I must stick to "MyPageMainViewController implementation".
    // I will assume MyProfileViewController and MyPostsViewController will be created in the next steps.
    // To make this compile now, I will create minimal class definitions for them at the bottom of this file 
    // or just use UIViewController for now and update later.
    // Better: Create the files for child VCs in the next steps, but referenced here.
    // Swift allows referencing classes defined in other files even if they don't exist yet (will fail compile).
    // So I will create the files for child VCs as empty/stub classes NOW to ensure compilation.
    
    private lazy var profileViewController = MyProfileViewController(viewModel: viewModel)
    private lazy var postsViewController = MyPostsViewController(viewModel: postsViewModel)
    
    // MARK: - UI Components
    
    private let headerView = UIView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let tabStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 24
    }
    
    private let profileTabButton = UIButton().then {
        $0.setTitle("내 프로필", for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.setTitleColor(Colors.Slate.s900, for: .selected)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
    }
    
    private let postsTabButton = UIButton().then {
        $0.setTitle("내가 쓴 글", for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.setTitleColor(Colors.Slate.s900, for: .selected)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
    }
    
    private let settingsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "gearshape"), for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = Colors.Slate.s900
    }
    
    private let containerView = UIView()
    
    // MARK: - Initializer
    
    init(viewModel: MyPageViewModel, postsViewModel: MyPostsViewModel, coordinator: MyPageCoordinator) {
        self.viewModel = viewModel
        self.postsViewModel = postsViewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        setupUI()
        setupLayout()
        setupActions()
        
        // Initial State
        currentTab = .profile
        profileTabButton.isSelected = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(tabStackView)
        headerView.addSubview(settingsButton)
        headerView.addSubview(indicatorView)
        
        tabStackView.addArrangedSubview(profileTabButton)
        tabStackView.addArrangedSubview(postsTabButton)
        
        view.addSubview(containerView)
    }
    
    private func setupLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        tabStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        // Indicator will be positioned under selected tab button
        indicatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.leading.equalTo(profileTabButton)
            $0.width.equalTo(profileTabButton)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        profileTabButton.addTarget(self, action: #selector(didTapProfileTab), for: .touchUpInside)
        postsTabButton.addTarget(self, action: #selector(didTapPostsTab), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
    }
    
    // MARK: - Tab Handling
    
    @objc private func didTapProfileTab() {
        currentTab = .profile
    }
    
    @objc private func didTapPostsTab() {
        currentTab = .posts
    }
    
    @objc private func didTapSettings() {
        coordinator?.showSettings()
    }
    
    private func updateTabUI() {
        let isProfile = currentTab == .profile
        profileTabButton.isSelected = isProfile
        postsTabButton.isSelected = !isProfile
        
        profileTabButton.titleLabel?.font = isProfile ? .ieum(UIFont.IeumFont.Heading.h4) : .ieum(UIFont.IeumFont.Text.bodyM)
        postsTabButton.titleLabel?.font = !isProfile ? .ieum(UIFont.IeumFont.Heading.h4) : .ieum(UIFont.IeumFont.Text.bodyM)
        
        // Animate Indicator to selected tab
        let selectedButton = isProfile ? profileTabButton : postsTabButton
        
        indicatorView.snp.remakeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.leading.equalTo(selectedButton)
            $0.width.equalTo(selectedButton)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateChildViewController() {
        let vc: UIViewController
        switch currentTab {
        case .profile:
            vc = profileViewController
        case .posts:
            vc = postsViewController
        }
        
        // Remove existing child
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        // Add new child
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        vc.didMove(toParent: self)
    }
}

