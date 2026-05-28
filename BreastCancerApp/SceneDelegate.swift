import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let splashVC = UIHostingController(rootView: BloomSplashView())
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        self.window = window

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            let preferredName = self.resolvePreferredStoryboardName(
                isLoggedIn: isLoggedIn,
                hasCompletedOnboarding: hasCompletedOnboarding
            )

            guard let rootVC = self.resolveRootViewController(
                preferredName: preferredName,
                isLoggedIn: isLoggedIn,
                hasCompletedOnboarding: hasCompletedOnboarding
            ) else {
                print("❌ No storyboard could be loaded. Check your storyboard names.")
                return
            }

            UIView.transition(
                with: window,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: { window.rootViewController = rootVC }
            )
        }
    }

    private func resolvePreferredStoryboardName(isLoggedIn: Bool, hasCompletedOnboarding: Bool) -> String {
        if isLoggedIn, hasCompletedOnboarding { return "TabbarMain" }

        // 1. Try modern Scene Configuration setting
        if let sceneManifest = Bundle.main.infoDictionary?["UIApplicationSceneManifest"] as? [String: Any],
           let sceneConfigs = sceneManifest["UISceneConfigurations"] as? [String: Any],
           let appRoles = sceneConfigs["UIWindowSceneSessionRoleApplication"] as? [[String: Any]],
           let firstRole = appRoles.first,
           let sceneStoryboard = firstRole["UISceneStoryboardFile"] as? String {
            return sceneStoryboard
        }
        // 2. Try legacy UIMainStoryboardFile key
        if let mainStoryboard = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as? String {
            return mainStoryboard
        }
        return "TabbarMain"
    }

    private func resolveRootViewController(
        preferredName: String,
        isLoggedIn: Bool,
        hasCompletedOnboarding: Bool
    ) -> UIViewController? {
        // Handle signup/onboarding flows
        if preferredName == "signupMain" {
            if isLoggedIn, !hasCompletedOnboarding {
                let loginSB = UIStoryboard(name: "Login", bundle: nil)
                if let profileVC = loginSB.instantiateViewController(withIdentifier: "ProfileSetupViewController") as? ProfileSetupViewController {
                    return profileVC
                }
            } else {
                let onboardingSB = UIStoryboard(name: "OnboardingMain", bundle: nil)
                if let welcomeVC = onboardingSB.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                    let navController = UINavigationController(rootViewController: welcomeVC)
                    navController.isNavigationBarHidden = true
                    return navController
                }
            }
        }

        // Fall back to preferred storyboard, then TabbarMain
        let storyboardsToTry = preferredName == "TabbarMain" ? ["TabbarMain"] : [preferredName, "TabbarMain"]
        for name in storyboardsToTry {
            if let vc = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController() {
                return vc
            }
            print("⚠️ Could not load storyboard: \(name), trying fallback...")
        }
        return nil
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {
        ReminderResyncService.syncAll()
        SyncManager.shared.pullAllAndStartTimer()
    }

    func sceneWillResignActive(_: UIScene) {}
    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {
        SyncManager.shared.pushDirtyAndStopTimer()
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = SupabaseAuthService.shared.handleGoogleOpenURL(url)
    }
}
