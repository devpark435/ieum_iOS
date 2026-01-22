//
//  AppDelegate.swift
//  ieum
//
//  Created by 박현렬 on 12/23/25.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // ✅ 디버깅: Info.plist 값 확인
        print("=== 카카오 SDK 초기화 ===")
        
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "KakaoAppKey") as? String,
              !appKey.isEmpty,
              !appKey.contains("$") else {  // $(KAKAO_APP_KEY) 그대로면 안 됨
            print("❌ KakaoAppKey를 찾을 수 없거나 비어있습니다!")
            print("📋 Info.plist 전체:")
            Bundle.main.infoDictionary?.forEach { key, value in
                if key.contains("Kakao") || key.contains("KAKAO") {
                    print("  \(key): \(value)")
                }
            }
            // 개발 중에는 명확한 에러 확인을 위해 fatalError 사용 (배포 시에는 제거 권장)
            print("⚠️ 카카오 앱 키가 설정되지 않았습니다. Configs/Debug.xcconfig 및 Build Settings를 확인해주세요.")
            return true
        }
        
        print("✅ 카카오 앱 키: \(appKey)")
        KakaoSDK.initSDK(appKey: appKey)
        print("✅ 카카오 SDK 초기화 완료")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
