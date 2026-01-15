import UIKit
import SnapKit
import Then

final class ProfileEditViewController: UIViewController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        title = "프로필 편집"
        
        let label = UILabel().then {
            $0.text = "프로필 편집 화면 (준비중)"
            $0.textColor = Colors.Gray.g500
            $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        }
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

