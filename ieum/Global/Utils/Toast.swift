import UIKit
import SnapKit

final class Toast {
    static func show(message: String, duration: TimeInterval = 2.0) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        let toastView = ToastView(message: message)
        toastView.alpha = 0
        window.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(65) // TabBar Height(49) + Margin(12) + alpha
            $0.leading.trailing.equalToSuperview().inset(24) // Adjusted to 24 horizontal inset
            $0.height.equalTo(56) // Adjusted to 56 height
        }
        
        // Animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            toastView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn) {
                toastView.alpha = 0
            } completion: { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}

