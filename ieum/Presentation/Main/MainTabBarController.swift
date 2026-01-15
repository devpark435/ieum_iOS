import UIKit
import SnapKit
import Then

final class MainTabBarController: UITabBarController {
    
    private var coordinators: [Coordinator] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customizeTabBarAppearance()
    }
    
    // MARK: - Setup
    
    private func setupTabBar() {
        tabBar.backgroundColor = Colors.white
        tabBar.tintColor = Colors.Slate.s900
        tabBar.unselectedItemTintColor = Colors.Gray.g400
        tabBar.isTranslucent = false
        
        // 기본 그림자 제거 (커스텀 스타일 적용)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    private func setupViewControllers() {
        let feedNav = UINavigationController()
        let feedCoordinator = FeedCoordinator(navigationController: feedNav)
        feedCoordinator.start()
        coordinators.append(feedCoordinator)
        
        let feedTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        feedTabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        feedNav.tabBarItem = feedTabBarItem
        
        let calendarVC = CalendarViewController()
        let calendarNav = UINavigationController(rootViewController: calendarVC)
        let calendarTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar")
        )
        calendarTabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        calendarNav.tabBarItem = calendarTabBarItem
        
        let myPageNav = UINavigationController()
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNav)
        myPageCoordinator.start()
        coordinators.append(myPageCoordinator)
        
        let myPageTabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        myPageTabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        myPageNav.tabBarItem = myPageTabBarItem
        
        viewControllers = [feedNav, calendarNav, myPageNav]
    }
    
    private func customizeTabBarAppearance() {
        // 좌우 상단 radius 16 적용
        let cornerRadius: CGFloat = 16
        
        // TabBar의 상단 모서리에만 radius 적용
        let path = UIBezierPath(
            roundedRect: tabBar.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        tabBar.layer.mask = maskLayer
        
        // 그림자 추가 (선택사항)
        tabBar.layer.shadowColor = Colors.Gray.g200.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 8
        tabBar.layer.shadowOpacity = 0.1
    }
}

