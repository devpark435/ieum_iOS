import UIKit
import SnapKit

final class IeumRefreshControl: UIRefreshControl {

    private let iconImageView: UIImageView = {
        let image = UIImage(named: "appbar-icon")?.withRenderingMode(.alwaysOriginal)
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        return iv
    }()

    override init() {
        super.init()
        tintColor = .clear
        backgroundColor = .clear
        addSubview(iconImageView)
        addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize = CGSize(width: 44, height: 24)
        iconImageView.frame = CGRect(
            x: (bounds.width - iconSize.width) / 2,
            y: (bounds.height - iconSize.height) / 2,
            width: iconSize.width,
            height: iconSize.height
        )
    }

    @objc private func handleValueChanged() {
        startRotation()
    }

    override func endRefreshing() {
        super.endRefreshing()
        UIView.animate(withDuration: 0.2) {
            self.iconImageView.alpha = 0
        } completion: { _ in
            self.stopRotation()
        }
    }

    private func startRotation() {
        iconImageView.alpha = 1
        guard iconImageView.layer.animation(forKey: "rotation") == nil else { return }
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        iconImageView.layer.add(rotation, forKey: "rotation")
    }

    private func stopRotation() {
        iconImageView.layer.removeAnimation(forKey: "rotation")
    }
}
