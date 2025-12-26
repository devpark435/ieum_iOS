//
//  SceneDelegate.swift
//  ieum
//
//  Created by 박현렬 on 12/23/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // 전역 키보드 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window?.addGestureRecognizer(tapGesture)
        
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator?.start()
    }
    
    @objc private func dismissKeyboard() {
        window?.endEditing(true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    /// 텍스트 필드, 버튼 등 interactive 요소에서는 제스처를 무시합니다.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        
        // 터치된 뷰와 그 상위 뷰들을 모두 확인
        var currentView: UIView? = touchedView
        while let view = currentView {
            // UITextField, UITextView는 직접 체크
            if view is UITextField || view is UITextView {
                return false
            }
            
            // UIButton, UIControl도 체크
            if view is UIButton || view.isKind(of: UIControl.self) {
                return false
            }
            
            // IeumInputView (커스텀 인풋 뷰)도 체크
            let className = String(describing: type(of: view))
            if className == "IeumInputView" {
                return false
            }
            
            // 스크롤 뷰 내부도 무시 (스크롤 제스처와 충돌 방지)
            if view is UIScrollView {
                return false
            }
            
            currentView = view.superview
        }
        
        // IeumInputView 내부의 모든 뷰도 체크 (containerView, stackView 등)
        var parentView: UIView? = touchedView.superview
        while let parent = parentView {
            if String(describing: type(of: parent)) == "IeumInputView" {
                return false
            }
            parentView = parent.superview
        }
        
        return true
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
