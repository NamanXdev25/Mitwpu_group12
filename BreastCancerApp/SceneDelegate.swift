import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 1. Create window and show splash screen
        let window = UIWindow(windowScene: windowScene)
        let splashVC = UIHostingController(rootView: BloomSplashView())
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        self.window = window

        // 2. After animation completes, transition to whichever storyboard is set in Info.plist
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            var preferredName = "TabbarMain"
            
            // 1. Try modern Scene Configuration setting (where Xcode puts it for iOS 13+ apps)
            if let sceneManifest = Bundle.main.infoDictionary?["UIApplicationSceneManifest"] as? [String: Any],
               let sceneConfigs = sceneManifest["UISceneConfigurations"] as? [String: Any],
               let appRoles = sceneConfigs["UIWindowSceneSessionRoleApplication"] as? [[String: Any]],
               let firstRole = appRoles.first,
               let sceneStoryboard = firstRole["UISceneStoryboardFile"] as? String {
                preferredName = sceneStoryboard
            }
            // 2. Try legacy UIMainStoryboardFile key (if it wasn't found above)
            else if let mainStoryboard = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as? String {
                preferredName = mainStoryboard
            }

            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

            if isLoggedIn && hasCompletedOnboarding {
                preferredName = "TabbarMain"
            }

            // Try preferred storyboard first, fall back to TabbarMain
            let storyboardsToTry = preferredName == "TabbarMain" ? ["TabbarMain"] : [preferredName, "TabbarMain"]
            var mainVC: UIViewController?

            for name in storyboardsToTry {
                if let vc = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController() {
                    mainVC = vc
                    break
                } else {
                    print("⚠️ Could not load storyboard: \(name), trying fallback...")
                }
            }

            guard let rootVC = mainVC else {
                print("❌ No storyboard could be loaded. Check your storyboard names.")
                return
            }

            UIView.transition(
                with: window,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = rootVC
                }
            )
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        ReminderResyncService.syncAll()
        SyncManager.shared.pullAllAndStartTimer()
    }

    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        SyncManager.shared.pushDirtyAndStopTimer()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = SupabaseAuthService.shared.handleGoogleOpenURL(url)
    }
}
