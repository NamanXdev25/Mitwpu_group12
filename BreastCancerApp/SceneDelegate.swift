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

        // 2. After animation completes, transition to TabbarMain
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            let storyboard = UIStoryboard(name: "TabbarMain", bundle: nil)
            guard let mainVC = storyboard.instantiateInitialViewController() else {
                print("❌ Could not load TabbarMain storyboard")
                return
            }
            UIView.transition(
                with: window,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = mainVC
                }
            )
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        ReminderResyncService.syncAll()
    }

    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = SupabaseAuthService.shared.handleGoogleOpenURL(url)
    }
}
