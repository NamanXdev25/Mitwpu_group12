//////////
//////////  CoinRewardService.swift
//////////  BreastCancerApp
//////////
//////////  Created by Naman Bhansali on 03/03/26.
//////////
////////
//////////
//////////  CoinRewardService.swift
//////////  BreastCancerApp
//////////
////////
////////import UIKit
////////
////////// MARK: - Coin Reward Service
////////
////////final class CoinRewardService {
////////    static let shared = CoinRewardService()
////////
////////    // MARK: - Reward Amounts
////////    struct Rewards {
////////        static let hydrationPlus       = 10
////////        static let medicationTaken     = 15
////////        static let breathingSession    = 25
////////        static let exerciseComplete    = 20
////////        static let journalEntry        = 20
////////        static let appointmentCreated  = 20
////////        static let memoryCreated       = 15
////////    }
////////
////////    // MARK: - Daily Limit Keys
////////    private enum DailyKeys {
////////        static let breathingDate = "coin_reward_breathing_date"
////////        static let exerciseDate  = "coin_reward_exercise_date"
////////    }
////////
////////    private init() {}
////////
////////    // MARK: - Public API
////////
////////    /// Awards coins and shows the celebration animation on the given VC.
////////    /// Returns true if coins were actually awarded.
////////    @discardableResult
////////    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
////////        guard amount > 0 else { return false }
////////        GardenManager.shared.addCoins(amount)
////////        showCoinAnimation(amount: amount, reason: reason, on: viewController)
////////        return true
////////    }
////////
////////    /// Awards breathing coins ONLY if not already earned today.
////////    @discardableResult
////////    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
////////        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
////////        markEarnedToday(key: DailyKeys.breathingDate)
////////        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
////////    }
////////
////////    /// Awards exercise coins ONLY if not already earned today.
////////    @discardableResult
////////    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
////////        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
////////        markEarnedToday(key: DailyKeys.exerciseDate)
////////        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
////////    }
////////
////////    // MARK: - Daily Limit Helpers
////////
////////    private func hasEarnedToday(key: String) -> Bool {
////////        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
////////            return false
////////        }
////////        return Calendar.current.isDateInToday(savedDate)
////////    }
////////
////////    private func markEarnedToday(key: String) {
////////        UserDefaults.standard.set(Date(), forKey: key)
////////    }
////////
////////    // MARK: - Coin Celebration Animation
////////
////////    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
////////        guard let window = viewController.view.window else { return }
////////
////////        // Haptic feedback
////////        let generator = UINotificationFeedbackGenerator()
////////        generator.notificationOccurred(.success)
////////
////////        // === Dimmed overlay ===
////////        let overlay = UIView(frame: window.bounds)
////////        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
////////        overlay.alpha = 0
////////        window.addSubview(overlay)
////////
////////        // === Container for content ===
////////        let container = UIView()
////////        container.translatesAutoresizingMaskIntoConstraints = false
////////        overlay.addSubview(container)
////////
////////        NSLayoutConstraint.activate([
////////            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
////////            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
////////            container.widthAnchor.constraint(equalToConstant: 260),
////////            container.heightAnchor.constraint(equalToConstant: 220)
////////        ])
////////
////////        // === Glowing circle behind coin ===
////////        let glowView = UIView()
////////        glowView.translatesAutoresizingMaskIntoConstraints = false
////////        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
////////        glowView.layer.cornerRadius = 55
////////        container.addSubview(glowView)
////////
////////        NSLayoutConstraint.activate([
////////            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////////            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
////////            glowView.widthAnchor.constraint(equalToConstant: 110),
////////            glowView.heightAnchor.constraint(equalToConstant: 110)
////////        ])
////////
////////        // === Coin icon ===
////////        let coinSize: CGFloat = 64
////////        let coinLabel = UILabel()
////////        coinLabel.text = "🪙"
////////        coinLabel.font = UIFont.systemFont(ofSize: 56)
////////        coinLabel.textAlignment = .center
////////        coinLabel.translatesAutoresizingMaskIntoConstraints = false
////////        container.addSubview(coinLabel)
////////
////////        NSLayoutConstraint.activate([
////////            coinLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////////            coinLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
////////            coinLabel.widthAnchor.constraint(equalToConstant: coinSize),
////////            coinLabel.heightAnchor.constraint(equalToConstant: coinSize)
////////        ])
////////
////////        // === "+X Coins!" label ===
////////        let coinsLabel = UILabel()
////////        coinsLabel.text = "+\(amount) Coins!"
////////        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
////////        coinsLabel.textColor = UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0) // Gold
////////        coinsLabel.textAlignment = .center
////////        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
////////        container.addSubview(coinsLabel)
////////
////////        NSLayoutConstraint.activate([
////////            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////////            coinsLabel.topAnchor.constraint(equalTo: coinLabel.bottomAnchor, constant: 12)
////////        ])
////////
////////        // === Reason label ===
////////        let reasonLabel = UILabel()
////////        reasonLabel.text = reason
////////        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
////////        reasonLabel.textColor = .white
////////        reasonLabel.textAlignment = .center
////////        reasonLabel.alpha = 0.85
////////        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
////////        container.addSubview(reasonLabel)
////////
////////        NSLayoutConstraint.activate([
////////            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////////            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
////////        ])
////////
////////        // === Sparkle particles ===
////////        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))
////////
////////        // === Animate In ===
////////        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
////////        coinLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
////////
////////        UIView.animate(withDuration: 0.5,
////////                       delay: 0,
////////                       usingSpringWithDamping: 0.6,
////////                       initialSpringVelocity: 0.8,
////////                       options: .curveEaseOut) {
////////            overlay.alpha = 1
////////            container.transform = .identity
////////            coinLabel.transform = .identity
////////        }
////////
////////        // Pulse the glow
////////        UIView.animate(withDuration: 0.8,
////////                       delay: 0.3,
////////                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
////////            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
////////            glowView.alpha = 0.6
////////        }
////////
////////        // === Animate Out after 2 seconds ===
////////        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
////////            overlay.alpha = 0
////////            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
////////        } completion: { _ in
////////            overlay.removeFromSuperview()
////////        }
////////    }
////////
////////    // MARK: - Sparkle Particles
////////
////////    private func addSparkles(to parentView: UIView, center: CGPoint) {
////////        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
////////        let particleCount = 12
////////
////////        for i in 0..<particleCount {
////////            let label = UILabel()
////////            label.text = sparkleEmoji[i % sparkleEmoji.count]
////////            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
////////            label.sizeToFit()
////////            label.center = center
////////            label.alpha = 0
////////            parentView.addSubview(label)
////////
////////            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
////////            let radius: CGFloat = CGFloat.random(in: 80...160)
////////            let targetX = center.x + cos(angle) * radius
////////            let targetY = center.y + sin(angle) * radius
////////
////////            UIView.animate(withDuration: 0.6,
////////                           delay: Double.random(in: 0.05...0.3),
////////                           options: .curveEaseOut) {
////////                label.alpha = 1
////////                label.center = CGPoint(x: targetX, y: targetY)
////////            } completion: { _ in
////////                UIView.animate(withDuration: 0.3, delay: 0.8) {
////////                    label.alpha = 0
////////                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
////////                } completion: { _ in
////////                    label.removeFromSuperview()
////////                }
////////            }
////////        }
////////    }
////////}
//////
////////
////////  CoinRewardService.swift
////////  BreastCancerApp
////////
//////
//////import UIKit
//////
//////// MARK: - Coin Reward Service
//////
//////final class CoinRewardService {
//////    static let shared = CoinRewardService()
//////
//////    // MARK: - Reward Amounts
//////    struct Rewards {
//////        static let hydrationPlus       = 10
//////        static let medicationTaken     = 15
//////        static let breathingSession    = 25
//////        static let exerciseComplete    = 20
//////        static let journalEntry        = 20
//////        static let appointmentCreated  = 20
//////        static let memoryCreated       = 15
//////    }
//////
//////    // MARK: - Daily Limit Keys
//////    private enum DailyKeys {
//////        static let breathingDate = "coin_reward_breathing_date"
//////        static let exerciseDate  = "coin_reward_exercise_date"
//////    }
//////
//////    private init() {}
//////
//////    // MARK: - Public API
//////
//////    /// Awards coins and shows the celebration animation on the given VC.
//////    /// Returns true if coins were actually awarded.
//////    @discardableResult
//////    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
//////        guard amount > 0 else { return false }
//////        GardenManager.shared.addCoins(amount)
//////        showCoinAnimation(amount: amount, reason: reason, on: viewController)
//////        return true
//////    }
//////
//////    /// Awards breathing coins ONLY if not already earned today.
//////    @discardableResult
//////    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
//////        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
//////        markEarnedToday(key: DailyKeys.breathingDate)
//////        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
//////    }
//////
//////    /// Awards exercise coins ONLY if not already earned today.
//////    @discardableResult
//////    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
//////        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
//////        markEarnedToday(key: DailyKeys.exerciseDate)
//////        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
//////    }
//////
//////    // MARK: - Daily Limit Helpers
//////
//////    private func hasEarnedToday(key: String) -> Bool {
//////        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
//////            return false
//////        }
//////        return Calendar.current.isDateInToday(savedDate)
//////    }
//////
//////    private func markEarnedToday(key: String) {
//////        UserDefaults.standard.set(Date(), forKey: key)
//////    }
//////
//////    // MARK: - Coin Celebration Animation
//////
//////    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
//////        guard let window = viewController.view.window else { return }
//////
//////        // Haptic feedback
//////        let generator = UINotificationFeedbackGenerator()
//////        generator.notificationOccurred(.success)
//////
//////        // === Dimmed overlay ===
//////        let overlay = UIView(frame: window.bounds)
//////        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
//////        overlay.alpha = 0
//////        window.addSubview(overlay)
//////
//////        // === Container for content ===
//////        let container = UIView()
//////        container.translatesAutoresizingMaskIntoConstraints = false
//////        overlay.addSubview(container)
//////
//////        NSLayoutConstraint.activate([
//////            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
//////            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
//////            container.widthAnchor.constraint(equalToConstant: 260),
//////            container.heightAnchor.constraint(equalToConstant: 220)
//////        ])
//////
//////        // === Glowing circle behind coin ===
//////        let glowView = UIView()
//////        glowView.translatesAutoresizingMaskIntoConstraints = false
//////        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
//////        glowView.layer.cornerRadius = 55
//////        container.addSubview(glowView)
//////
//////        NSLayoutConstraint.activate([
//////            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//////            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
//////            glowView.widthAnchor.constraint(equalToConstant: 110),
//////            glowView.heightAnchor.constraint(equalToConstant: 110)
//////        ])
//////
//////        // === Coin icon (bitcoinsign.circle.fill — same as Healing Garden storyboard) ===
//////        let coinSize: CGFloat = 64
//////        let coinConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
//////        let coinImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: coinConfig)
//////        let coinImageView = UIImageView(image: coinImage)
//////        coinImageView.tintColor = .systemYellow
//////        coinImageView.contentMode = .scaleAspectFit
//////        coinImageView.translatesAutoresizingMaskIntoConstraints = false
//////        container.addSubview(coinImageView)
//////
//////        NSLayoutConstraint.activate([
//////            coinImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//////            coinImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
//////            coinImageView.widthAnchor.constraint(equalToConstant: coinSize),
//////            coinImageView.heightAnchor.constraint(equalToConstant: coinSize)
//////        ])
//////
//////        // === "+X Coins!" label ===
//////        let coinsLabel = UILabel()
//////        coinsLabel.text = "+\(amount) Coins!"
//////        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
//////        coinsLabel.textColor = .systemYellow
//////        coinsLabel.textAlignment = .center
//////        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
//////        container.addSubview(coinsLabel)
//////
//////        NSLayoutConstraint.activate([
//////            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//////            coinsLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 12)
//////        ])
//////
//////        // === Reason label ===
//////        let reasonLabel = UILabel()
//////        reasonLabel.text = reason
//////        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//////        reasonLabel.textColor = .white
//////        reasonLabel.textAlignment = .center
//////        reasonLabel.alpha = 0.85
//////        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
//////        container.addSubview(reasonLabel)
//////
//////        NSLayoutConstraint.activate([
//////            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//////            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
//////        ])
//////
//////        // === Sparkle particles ===
//////        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))
//////
//////        // === Animate In ===
//////        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//////        coinImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//////
//////        UIView.animate(withDuration: 0.5,
//////                       delay: 0,
//////                       usingSpringWithDamping: 0.6,
//////                       initialSpringVelocity: 0.8,
//////                       options: .curveEaseOut) {
//////            overlay.alpha = 1
//////            container.transform = .identity
//////            coinImageView.transform = .identity
//////        }
//////
//////        // Pulse the glow
//////        UIView.animate(withDuration: 0.8,
//////                       delay: 0.3,
//////                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
//////            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//////            glowView.alpha = 0.6
//////        }
//////
//////        // === Animate Out after 2 seconds ===
//////        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
//////            overlay.alpha = 0
//////            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//////        } completion: { _ in
//////            overlay.removeFromSuperview()
//////        }
//////    }
//////
//////    // MARK: - Sparkle Particles
//////
//////    private func addSparkles(to parentView: UIView, center: CGPoint) {
//////        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
//////        let particleCount = 12
//////
//////        for i in 0..<particleCount {
//////            let label = UILabel()
//////            label.text = sparkleEmoji[i % sparkleEmoji.count]
//////            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
//////            label.sizeToFit()
//////            label.center = center
//////            label.alpha = 0
//////            parentView.addSubview(label)
//////
//////            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
//////            let radius: CGFloat = CGFloat.random(in: 80...160)
//////            let targetX = center.x + cos(angle) * radius
//////            let targetY = center.y + sin(angle) * radius
//////
//////            UIView.animate(withDuration: 0.6,
//////                           delay: Double.random(in: 0.05...0.3),
//////                           options: .curveEaseOut) {
//////                label.alpha = 1
//////                label.center = CGPoint(x: targetX, y: targetY)
//////            } completion: { _ in
//////                UIView.animate(withDuration: 0.3, delay: 0.8) {
//////                    label.alpha = 0
//////                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//////                } completion: { _ in
//////                    label.removeFromSuperview()
//////                }
//////            }
//////        }
//////    }
//////}
////
//////
//////  CoinRewardService.swift
//////  BreastCancerApp
//////
////
////import UIKit
////
////// MARK: - Coin Reward Service
////
////final class CoinRewardService {
////    static let shared = CoinRewardService()
////
////    // MARK: - Reward Amounts
////    struct Rewards {
////        static let hydrationGoal       = 30
////        static let allMedicationsTaken = 30
////        static let breathingSession    = 25
////        static let exerciseComplete    = 20
////        static let journalEntry        = 20
////        static let appointmentCreated  = 20
////        static let memoryCreated       = 15
////    }
////
////    // MARK: - Daily Limit Keys
////    private enum DailyKeys {
////        static let breathingDate  = "coin_reward_breathing_date"
////        static let exerciseDate   = "coin_reward_exercise_date"
////        static let hydrationDate  = "coin_reward_hydration_date"
////        static let medicationDate = "coin_reward_medication_date"
////    }
////
////    private init() {}
////
////    // MARK: - Public API
////
////    /// Awards coins and shows the celebration animation on the given VC.
////    /// Returns true if coins were actually awarded.
////    @discardableResult
////    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
////        guard amount > 0 else { return false }
////        GardenManager.shared.addCoins(amount)
////        showCoinAnimation(amount: amount, reason: reason, on: viewController)
////        return true
////    }
////
////    /// Awards breathing coins ONLY if not already earned today.
////    @discardableResult
////    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
////        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
////        markEarnedToday(key: DailyKeys.breathingDate)
////        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
////    }
////
////    /// Awards exercise coins ONLY if not already earned today.
////    @discardableResult
////    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
////        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
////        markEarnedToday(key: DailyKeys.exerciseDate)
////        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
////    }
////
////    /// Awards hydration coins ONLY if daily goal is met AND not already earned today.
////    @discardableResult
////    func awardHydrationGoalIfEligible(currentML: Int, goalML: Int, on viewController: UIViewController) -> Bool {
////        guard currentML >= goalML else { return false }  // Goal not met yet
////        guard !hasEarnedToday(key: DailyKeys.hydrationDate) else { return false }  // Already earned today
////        markEarnedToday(key: DailyKeys.hydrationDate)
////        return awardCoins(Rewards.hydrationGoal, reason: "Hydration Goal Complete 💧", on: viewController)
////    }
////
////    /// Awards medication coins ONLY if all meds are taken AND not already earned today.
////    @discardableResult
////    func awardMedicationGoalIfEligible(allTaken: Bool, on viewController: UIViewController) -> Bool {
////        guard allTaken else { return false }  // Not all taken yet
////        guard !hasEarnedToday(key: DailyKeys.medicationDate) else { return false }  // Already earned today
////        markEarnedToday(key: DailyKeys.medicationDate)
////        return awardCoins(Rewards.allMedicationsTaken, reason: "All Medications Taken 💊", on: viewController)
////    }
////
////    // MARK: - Daily Limit Helpers
////
////    private func hasEarnedToday(key: String) -> Bool {
////        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
////            return false
////        }
////        return Calendar.current.isDateInToday(savedDate)
////    }
////
////    private func markEarnedToday(key: String) {
////        UserDefaults.standard.set(Date(), forKey: key)
////    }
////
////    // MARK: - Coin Celebration Animation
////
////    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
////        guard let window = viewController.view.window else { return }
////
////        // Haptic feedback
////        let generator = UINotificationFeedbackGenerator()
////        generator.notificationOccurred(.success)
////
////        // === Dimmed overlay ===
////        let overlay = UIView(frame: window.bounds)
////        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
////        overlay.alpha = 0
////        window.addSubview(overlay)
////
////        // === Container for content ===
////        let container = UIView()
////        container.translatesAutoresizingMaskIntoConstraints = false
////        overlay.addSubview(container)
////
////        NSLayoutConstraint.activate([
////            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
////            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
////            container.widthAnchor.constraint(equalToConstant: 260),
////            container.heightAnchor.constraint(equalToConstant: 220)
////        ])
////
////        // === Glowing circle behind coin ===
////        let glowView = UIView()
////        glowView.translatesAutoresizingMaskIntoConstraints = false
////        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
////        glowView.layer.cornerRadius = 55
////        container.addSubview(glowView)
////
////        NSLayoutConstraint.activate([
////            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
////            glowView.widthAnchor.constraint(equalToConstant: 110),
////            glowView.heightAnchor.constraint(equalToConstant: 110)
////        ])
////
////        // === Coin icon (bitcoinsign.circle.fill — same as Healing Garden storyboard) ===
////        let coinSize: CGFloat = 64
////        let coinConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
////        let coinImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: coinConfig)
////        let coinImageView = UIImageView(image: coinImage)
////        coinImageView.tintColor = .systemYellow
////        coinImageView.contentMode = .scaleAspectFit
////        coinImageView.translatesAutoresizingMaskIntoConstraints = false
////        container.addSubview(coinImageView)
////
////        NSLayoutConstraint.activate([
////            coinImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////            coinImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
////            coinImageView.widthAnchor.constraint(equalToConstant: coinSize),
////            coinImageView.heightAnchor.constraint(equalToConstant: coinSize)
////        ])
////
////        // === "+X Coins!" label ===
////        let coinsLabel = UILabel()
////        coinsLabel.text = "+\(amount) Coins!"
////        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
////        coinsLabel.textColor = .systemYellow
////        coinsLabel.textAlignment = .center
////        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
////        container.addSubview(coinsLabel)
////
////        NSLayoutConstraint.activate([
////            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////            coinsLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 12)
////        ])
////
////        // === Reason label ===
////        let reasonLabel = UILabel()
////        reasonLabel.text = reason
////        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
////        reasonLabel.textColor = .white
////        reasonLabel.textAlignment = .center
////        reasonLabel.alpha = 0.85
////        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
////        container.addSubview(reasonLabel)
////
////        NSLayoutConstraint.activate([
////            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
////            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
////        ])
////
////        // === Sparkle particles ===
////        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))
////
////        // === Animate In ===
////        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
////        coinImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
////
////        UIView.animate(withDuration: 0.5,
////                       delay: 0,
////                       usingSpringWithDamping: 0.6,
////                       initialSpringVelocity: 0.8,
////                       options: .curveEaseOut) {
////            overlay.alpha = 1
////            container.transform = .identity
////            coinImageView.transform = .identity
////        }
////
////        // Pulse the glow
////        UIView.animate(withDuration: 0.8,
////                       delay: 0.3,
////                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
////            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
////            glowView.alpha = 0.6
////        }
////
////        // === Animate Out after 2 seconds ===
////        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
////            overlay.alpha = 0
////            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
////        } completion: { _ in
////            overlay.removeFromSuperview()
////        }
////    }
////
////    // MARK: - Sparkle Particles
////
////    private func addSparkles(to parentView: UIView, center: CGPoint) {
////        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
////        let particleCount = 12
////
////        for i in 0..<particleCount {
////            let label = UILabel()
////            label.text = sparkleEmoji[i % sparkleEmoji.count]
////            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
////            label.sizeToFit()
////            label.center = center
////            label.alpha = 0
////            parentView.addSubview(label)
////
////            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
////            let radius: CGFloat = CGFloat.random(in: 80...160)
////            let targetX = center.x + cos(angle) * radius
////            let targetY = center.y + sin(angle) * radius
////
////            UIView.animate(withDuration: 0.6,
////                           delay: Double.random(in: 0.05...0.3),
////                           options: .curveEaseOut) {
////                label.alpha = 1
////                label.center = CGPoint(x: targetX, y: targetY)
////            } completion: { _ in
////                UIView.animate(withDuration: 0.3, delay: 0.8) {
////                    label.alpha = 0
////                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
////                } completion: { _ in
////                    label.removeFromSuperview()
////                }
////            }
////        }
////    }
////}
//
//
////
////  CoinRewardService.swift
////  BreastCancerApp
////
//
//import UIKit
//
//// MARK: - Coin Reward Service
//
//final class CoinRewardService {
//    static let shared = CoinRewardService()
//
//    // MARK: - Reward Amounts
//    struct Rewards {
//        static let hydrationGoal       = 30
//        static let allMedicationsTaken = 30
//        static let breathingSession    = 25
//        static let exerciseComplete    = 20
//        static let journalEntry        = 20
//        static let appointmentCreated  = 20
//        static let memoryCreated       = 15
//    }
//
//    // MARK: - Daily Limit Keys
//    private enum DailyKeys {
//        static let breathingDate  = "coin_reward_breathing_date"
//        static let exerciseDate   = "coin_reward_exercise_date"
//        static let hydrationDate   = "coin_reward_hydration_date"
//        static let medicationDate  = "coin_reward_medication_date"
//        static let journalDate     = "coin_reward_journal_date"
//        static let appointmentDate = "coin_reward_appointment_date"
//    }
//
//    private init() {}
//
//    // MARK: - Public API
//
//    /// Awards coins and shows the celebration animation on the given VC.
//    /// Returns true if coins were actually awarded.
//    @discardableResult
//    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
//        guard amount > 0 else { return false }
//        GardenManager.shared.addCoins(amount)
//        showCoinAnimation(amount: amount, reason: reason, on: viewController)
//        return true
//    }
//
//    /// Awards breathing coins ONLY if not already earned today.
//    @discardableResult
//    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
//        markEarnedToday(key: DailyKeys.breathingDate)
//        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
//    }
//
//    /// Awards exercise coins ONLY if not already earned today.
//    @discardableResult
//    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
//        markEarnedToday(key: DailyKeys.exerciseDate)
//        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
//    }
//
//    /// Awards hydration coins ONLY if daily goal is met AND not already earned today.
//    @discardableResult
//    func awardHydrationGoalIfEligible(currentML: Int, goalML: Int, on viewController: UIViewController) -> Bool {
//        guard currentML >= goalML else { return false }  // Goal not met yet
//        guard !hasEarnedToday(key: DailyKeys.hydrationDate) else { return false }  // Already earned today
//        markEarnedToday(key: DailyKeys.hydrationDate)
//        return awardCoins(Rewards.hydrationGoal, reason: "Hydration Goal Complete 💧", on: viewController)
//    }
//
//    /// Awards medication coins ONLY if all meds are taken AND not already earned today.
//    @discardableResult
//    func awardMedicationGoalIfEligible(allTaken: Bool, on viewController: UIViewController) -> Bool {
//        guard allTaken else { return false }  // Not all taken yet
//        guard !hasEarnedToday(key: DailyKeys.medicationDate) else { return false }  // Already earned today
//        markEarnedToday(key: DailyKeys.medicationDate)
//        return awardCoins(Rewards.allMedicationsTaken, reason: "All Medications Taken 💊", on: viewController)
//    }
//
//    /// Awards journal coins ONLY if not already earned today.
//    @discardableResult
//    func awardJournalCoinsIfEligible(reason: String, on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.journalDate) else { return false }
//        markEarnedToday(key: DailyKeys.journalDate)
//        return awardCoins(Rewards.journalEntry, reason: reason, on: viewController)
//    }
//
//    /// Awards appointment coins ONLY if not already earned today.
//    @discardableResult
//    func awardAppointmentCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.appointmentDate) else { return false }
//        markEarnedToday(key: DailyKeys.appointmentDate)
//        return awardCoins(Rewards.appointmentCreated, reason: "Appointment Created 📅", on: viewController)
//    }
//
//    // MARK: - Daily Limit Helpers
//
//    private func hasEarnedToday(key: String) -> Bool {
//        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
//            return false
//        }
//        return Calendar.current.isDateInToday(savedDate)
//    }
//
//    private func markEarnedToday(key: String) {
//        UserDefaults.standard.set(Date(), forKey: key)
//    }
//
//    // MARK: - Coin Celebration Animation
//
//    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
//        guard let window = viewController.view.window else { return }
//
//        // Haptic feedback
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//
//        // === Dimmed overlay ===
//        let overlay = UIView(frame: window.bounds)
//        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
//        overlay.alpha = 0
//        window.addSubview(overlay)
//
//        // === Container for content ===
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        overlay.addSubview(container)
//
//        NSLayoutConstraint.activate([
//            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
//            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
//            container.widthAnchor.constraint(equalToConstant: 260),
//            container.heightAnchor.constraint(equalToConstant: 220)
//        ])
//
//        // === Glowing circle behind coin ===
//        let glowView = UIView()
//        glowView.translatesAutoresizingMaskIntoConstraints = false
//        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
//        glowView.layer.cornerRadius = 55
//        container.addSubview(glowView)
//
//        NSLayoutConstraint.activate([
//            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
//            glowView.widthAnchor.constraint(equalToConstant: 110),
//            glowView.heightAnchor.constraint(equalToConstant: 110)
//        ])
//
//        // === Coin icon (bitcoinsign.circle.fill — same as Healing Garden storyboard) ===
//        let coinSize: CGFloat = 64
//        let coinConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
//        let coinImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: coinConfig)
//        let coinImageView = UIImageView(image: coinImage)
//        coinImageView.tintColor = .systemYellow
//        coinImageView.contentMode = .scaleAspectFit
//        coinImageView.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(coinImageView)
//
//        NSLayoutConstraint.activate([
//            coinImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            coinImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
//            coinImageView.widthAnchor.constraint(equalToConstant: coinSize),
//            coinImageView.heightAnchor.constraint(equalToConstant: coinSize)
//        ])
//
//        // === "+X Coins!" label ===
//        let coinsLabel = UILabel()
//        coinsLabel.text = "+\(amount) Coins!"
//        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
//        coinsLabel.textColor = .systemYellow
//        coinsLabel.textAlignment = .center
//        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(coinsLabel)
//
//        NSLayoutConstraint.activate([
//            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            coinsLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 12)
//        ])
//
//        // === Reason label ===
//        let reasonLabel = UILabel()
//        reasonLabel.text = reason
//        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        reasonLabel.textColor = .white
//        reasonLabel.textAlignment = .center
//        reasonLabel.alpha = 0.85
//        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(reasonLabel)
//
//        NSLayoutConstraint.activate([
//            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
//        ])
//
//        // === Sparkle particles ===
//        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))
//
//        // === Animate In ===
//        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//        coinImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.8,
//                       options: .curveEaseOut) {
//            overlay.alpha = 1
//            container.transform = .identity
//            coinImageView.transform = .identity
//        }
//
//        // Pulse the glow
//        UIView.animate(withDuration: 0.8,
//                       delay: 0.3,
//                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
//            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            glowView.alpha = 0.6
//        }
//
//        // === Animate Out after 2 seconds ===
//        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
//            overlay.alpha = 0
//            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//        } completion: { _ in
//            overlay.removeFromSuperview()
//        }
//    }
//
//    // MARK: - Sparkle Particles
//
//    private func addSparkles(to parentView: UIView, center: CGPoint) {
//        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
//        let particleCount = 12
//
//        for i in 0..<particleCount {
//            let label = UILabel()
//            label.text = sparkleEmoji[i % sparkleEmoji.count]
//            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
//            label.sizeToFit()
//            label.center = center
//            label.alpha = 0
//            parentView.addSubview(label)
//
//            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
//            let radius: CGFloat = CGFloat.random(in: 80...160)
//            let targetX = center.x + cos(angle) * radius
//            let targetY = center.y + sin(angle) * radius
//
//            UIView.animate(withDuration: 0.6,
//                           delay: Double.random(in: 0.05...0.3),
//                           options: .curveEaseOut) {
//                label.alpha = 1
//                label.center = CGPoint(x: targetX, y: targetY)
//            } completion: { _ in
//                UIView.animate(withDuration: 0.3, delay: 0.8) {
//                    label.alpha = 0
//                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//                } completion: { _ in
//                    label.removeFromSuperview()
//                }
//            }
//        }
//    }
//}

////
////  CoinRewardService.swift
////  BreastCancerApp
////
//
//import UIKit
//
//// MARK: - Coin Reward Service
//
//final class CoinRewardService {
//    static let shared = CoinRewardService()
//
//    // MARK: - Reward Amounts
//    struct Rewards {
//        static let hydrationGoal       = 30
//        static let allMedicationsTaken = 30
//        static let breathingSession    = 25
//        static let exerciseComplete    = 20
//        static let journalEntry        = 20
//        static let appointmentCreated  = 20
//        static let memoryCreated       = 15
//    }
//
//    // MARK: - Daily Limit Keys
//    private enum DailyKeys {
//        static let breathingDate  = "coin_reward_breathing_date"
//        static let exerciseDate   = "coin_reward_exercise_date"
//        static let hydrationDate   = "coin_reward_hydration_date"
//        static let medicationDate  = "coin_reward_medication_date"
//        static let journalDate     = "coin_reward_journal_date"
//        static let appointmentDate = "coin_reward_appointment_date"
//        static let memoryDate      = "coin_reward_memory_date"
//    }
//
//    private init() {}
//
//    // MARK: - Public API
//
//    /// Awards coins and shows the celebration animation on the given VC.
//    /// Returns true if coins were actually awarded.
//    @discardableResult
//    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
//        guard amount > 0 else { return false }
//        GardenManager.shared.addCoins(amount)
//        showCoinAnimation(amount: amount, reason: reason, on: viewController)
//        return true
//    }
//
//    /// Awards breathing coins ONLY if not already earned today.
//    @discardableResult
//    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
//        markEarnedToday(key: DailyKeys.breathingDate)
//        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
//    }
//
//    /// Awards exercise coins ONLY if not already earned today.
//    @discardableResult
//    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
//        markEarnedToday(key: DailyKeys.exerciseDate)
//        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
//    }
//
//    /// Awards hydration coins ONLY if daily goal is met AND not already earned today.
//    @discardableResult
//    func awardHydrationGoalIfEligible(currentML: Int, goalML: Int, on viewController: UIViewController) -> Bool {
//        guard currentML >= goalML else { return false }  // Goal not met yet
//        guard !hasEarnedToday(key: DailyKeys.hydrationDate) else { return false }  // Already earned today
//        markEarnedToday(key: DailyKeys.hydrationDate)
//        return awardCoins(Rewards.hydrationGoal, reason: "Hydration Goal Complete 💧", on: viewController)
//    }
//
//    /// Awards medication coins ONLY if all meds are taken AND not already earned today.
//    @discardableResult
//    func awardMedicationGoalIfEligible(allTaken: Bool, on viewController: UIViewController) -> Bool {
//        guard allTaken else { return false }  // Not all taken yet
//        guard !hasEarnedToday(key: DailyKeys.medicationDate) else { return false }  // Already earned today
//        markEarnedToday(key: DailyKeys.medicationDate)
//        return awardCoins(Rewards.allMedicationsTaken, reason: "All Medications Taken 💊", on: viewController)
//    }
//
//    /// Awards journal coins ONLY if not already earned today.
//    @discardableResult
//    func awardJournalCoinsIfEligible(reason: String, on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.journalDate) else { return false }
//        markEarnedToday(key: DailyKeys.journalDate)
//        return awardCoins(Rewards.journalEntry, reason: reason, on: viewController)
//    }
//
//    /// Awards appointment coins ONLY if not already earned today.
//    @discardableResult
//    func awardAppointmentCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.appointmentDate) else { return false }
//        markEarnedToday(key: DailyKeys.appointmentDate)
//        return awardCoins(Rewards.appointmentCreated, reason: "Appointment Created 📅", on: viewController)
//    }
//
//    /// Awards memory coins ONLY if not already earned today.
//    @discardableResult
//    func awardMemoryCoinsIfEligible(on viewController: UIViewController) -> Bool {
//        guard !hasEarnedToday(key: DailyKeys.memoryDate) else { return false }
//        markEarnedToday(key: DailyKeys.memoryDate)
//        return awardCoins(Rewards.memoryCreated, reason: "Memory Created 📸", on: viewController)
//    }
//
//    // MARK: - Daily Limit Helpers
//
//    private func hasEarnedToday(key: String) -> Bool {
//        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
//            return false
//        }
//        return Calendar.current.isDateInToday(savedDate)
//    }
//
//    private func markEarnedToday(key: String) {
//        UserDefaults.standard.set(Date(), forKey: key)
//    }
//
//    // MARK: - Coin Celebration Animation
//
//    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
//        guard let window = viewController.view.window else { return }
//
//        // Haptic feedback
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//
//        // === Dimmed overlay ===
//        let overlay = UIView(frame: window.bounds)
//        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
//        overlay.alpha = 0
//        window.addSubview(overlay)
//
//        // === Container for content ===
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        overlay.addSubview(container)
//
//        NSLayoutConstraint.activate([
//            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
//            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
//            container.widthAnchor.constraint(equalToConstant: 260),
//            container.heightAnchor.constraint(equalToConstant: 220)
//        ])
//
//        // === Glowing circle behind coin ===
//        let glowView = UIView()
//        glowView.translatesAutoresizingMaskIntoConstraints = false
//        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
//        glowView.layer.cornerRadius = 55
//        container.addSubview(glowView)
//
//        NSLayoutConstraint.activate([
//            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
//            glowView.widthAnchor.constraint(equalToConstant: 110),
//            glowView.heightAnchor.constraint(equalToConstant: 110)
//        ])
//
//        // === Coin icon (bitcoinsign.circle.fill — same as Healing Garden storyboard) ===
//        let coinSize: CGFloat = 64
//        let coinConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
//        let coinImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: coinConfig)
//        let coinImageView = UIImageView(image: coinImage)
//        coinImageView.tintColor = .systemYellow
//        coinImageView.contentMode = .scaleAspectFit
//        coinImageView.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(coinImageView)
//
//        NSLayoutConstraint.activate([
//            coinImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            coinImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
//            coinImageView.widthAnchor.constraint(equalToConstant: coinSize),
//            coinImageView.heightAnchor.constraint(equalToConstant: coinSize)
//        ])
//
//        // === "+X Coins!" label ===
//        let coinsLabel = UILabel()
//        coinsLabel.text = "+\(amount) Coins!"
//        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
//        coinsLabel.textColor = .systemYellow
//        coinsLabel.textAlignment = .center
//        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(coinsLabel)
//
//        NSLayoutConstraint.activate([
//            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            coinsLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 12)
//        ])
//
//        // === Reason label ===
//        let reasonLabel = UILabel()
//        reasonLabel.text = reason
//        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        reasonLabel.textColor = .white
//        reasonLabel.textAlignment = .center
//        reasonLabel.alpha = 0.85
//        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(reasonLabel)
//
//        NSLayoutConstraint.activate([
//            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
//        ])
//
//        // === Sparkle particles ===
//        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))
//
//        // === Animate In ===
//        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//        coinImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.8,
//                       options: .curveEaseOut) {
//            overlay.alpha = 1
//            container.transform = .identity
//            coinImageView.transform = .identity
//        }
//
//        // Pulse the glow
//        UIView.animate(withDuration: 0.8,
//                       delay: 0.3,
//                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
//            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            glowView.alpha = 0.6
//        }
//
//        // === Animate Out after 2 seconds ===
//        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
//            overlay.alpha = 0
//            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//        } completion: { _ in
//            overlay.removeFromSuperview()
//        }
//    }
//
//    // MARK: - Sparkle Particles
//
//    private func addSparkles(to parentView: UIView, center: CGPoint) {
//        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
//        let particleCount = 12
//
//        for i in 0..<particleCount {
//            let label = UILabel()
//            label.text = sparkleEmoji[i % sparkleEmoji.count]
//            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
//            label.sizeToFit()
//            label.center = center
//            label.alpha = 0
//            parentView.addSubview(label)
//
//            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
//            let radius: CGFloat = CGFloat.random(in: 80...160)
//            let targetX = center.x + cos(angle) * radius
//            let targetY = center.y + sin(angle) * radius
//
//            UIView.animate(withDuration: 0.6,
//                           delay: Double.random(in: 0.05...0.3),
//                           options: .curveEaseOut) {
//                label.alpha = 1
//                label.center = CGPoint(x: targetX, y: targetY)
//            } completion: { _ in
//                UIView.animate(withDuration: 0.3, delay: 0.8) {
//                    label.alpha = 0
//                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//                } completion: { _ in
//                    label.removeFromSuperview()
//                }
//            }
//        }
//    }
//}


//
//  CoinRewardService.swift
//  BreastCancerApp
//

import UIKit

// MARK: - Coin Reward Service

final class CoinRewardService {
    static let shared = CoinRewardService()

    // MARK: - Reward Amounts
    struct Rewards {
        static let hydrationGoal       = 30
        static let allMedicationsTaken = 30
        static let breathingSession    = 25
        static let exerciseComplete    = 20
        static let journalEntry        = 20
        static let appointmentCreated  = 20
        static let memoryCreated       = 15
    }

    // MARK: - Daily Limit Keys
    private enum DailyKeys {
        static let breathingDate  = "coin_reward_breathing_date"
        static let exerciseDate   = "coin_reward_exercise_date"
        static let hydrationDate  = "coin_reward_hydration_date"
        static let medicationDate = "coin_reward_medication_date"
        static let journalDate    = "coin_reward_journal_date"
        static let appointmentDate = "coin_reward_appointment_date"
        static let memoryDate     = "coin_reward_memory_date"   // <- shared key for all memory flows
    }

    private init() {}

    // MARK: - Public API

    /// Awards coins and shows the celebration animation on the given VC.
    /// Returns true if coins were actually awarded.
    @discardableResult
    func awardCoins(_ amount: Int, reason: String, on viewController: UIViewController) -> Bool {
        guard amount > 0 else { return false }
        GardenManager.shared.addCoins(amount)
        showCoinAnimation(amount: amount, reason: reason, on: viewController)
        return true
    }

    /// Awards breathing coins ONLY if not already earned today.
    @discardableResult
    func awardBreathingCoinsIfEligible(on viewController: UIViewController) -> Bool {
        guard !hasEarnedToday(key: DailyKeys.breathingDate) else { return false }
        markEarnedToday(key: DailyKeys.breathingDate)
        return awardCoins(Rewards.breathingSession, reason: "Breathing Session", on: viewController)
    }

    /// Awards exercise coins ONLY if not already earned today.
    @discardableResult
    func awardExerciseCoinsIfEligible(on viewController: UIViewController) -> Bool {
        guard !hasEarnedToday(key: DailyKeys.exerciseDate) else { return false }
        markEarnedToday(key: DailyKeys.exerciseDate)
        return awardCoins(Rewards.exerciseComplete, reason: "Exercise Complete", on: viewController)
    }

    /// Awards hydration coins ONLY if daily goal is met AND not already earned today.
    @discardableResult
    func awardHydrationGoalIfEligible(currentML: Int, goalML: Int, on viewController: UIViewController) -> Bool {
        guard currentML >= goalML else { return false }  // Goal not met yet
        guard !hasEarnedToday(key: DailyKeys.hydrationDate) else { return false }  // Already earned today
        markEarnedToday(key: DailyKeys.hydrationDate)
        return awardCoins(Rewards.hydrationGoal, reason: "Hydration Goal Complete 💧", on: viewController)
    }

    /// Awards medication coins ONLY if all meds are taken AND not already earned today.
    @discardableResult
    func awardMedicationGoalIfEligible(allTaken: Bool, on viewController: UIViewController) -> Bool {
        guard allTaken else { return false }  // Not all taken yet
        guard !hasEarnedToday(key: DailyKeys.medicationDate) else { return false }  // Already earned today
        markEarnedToday(key: DailyKeys.medicationDate)
        return awardCoins(Rewards.allMedicationsTaken, reason: "All Medications Taken 💊", on: viewController)
    }

    /// Awards journal coins ONLY if not already earned today.
    @discardableResult
    func awardJournalCoinsIfEligible(reason: String, on viewController: UIViewController) -> Bool {
        guard !hasEarnedToday(key: DailyKeys.journalDate) else { return false }
        markEarnedToday(key: DailyKeys.journalDate)
        return awardCoins(Rewards.journalEntry, reason: reason, on: viewController)
    }

    /// Awards appointment coins ONLY if not already earned today.
    @discardableResult
    func awardAppointmentCoinsIfEligible(on viewController: UIViewController) -> Bool {
        guard !hasEarnedToday(key: DailyKeys.appointmentDate) else { return false }
        markEarnedToday(key: DailyKeys.appointmentDate)
        return awardCoins(Rewards.appointmentCreated, reason: "Appointment Created 📅", on: viewController)
    }

    /// Awards memory coins ONLY if not already earned today.
    @discardableResult
    func awardMemoryCoinsIfEligible(on viewController: UIViewController) -> Bool {
        guard !hasEarnedToday(key: DailyKeys.memoryDate) else { return false }
        markEarnedToday(key: DailyKeys.memoryDate)
        return awardCoins(Rewards.memoryCreated, reason: "Memory Created 📸", on: viewController)
    }

    // MARK: - Daily Limit Helpers

    private func hasEarnedToday(key: String) -> Bool {
        guard let savedDate = UserDefaults.standard.object(forKey: key) as? Date else {
            return false
        }
        return Calendar.current.isDateInToday(savedDate)
    }

    private func markEarnedToday(key: String) {
        UserDefaults.standard.set(Date(), forKey: key)
    }

    // MARK: - Coin Celebration Animation

    private func showCoinAnimation(amount: Int, reason: String, on viewController: UIViewController) {
        guard let window = viewController.view.window else { return }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // === Dimmed overlay ===
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.alpha = 0
        window.addSubview(overlay)

        // === Container for content ===
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 260),
            container.heightAnchor.constraint(equalToConstant: 220)
        ])

        // === Glowing circle behind coin ===
        let glowView = UIView()
        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.15)
        glowView.layer.cornerRadius = 55
        container.addSubview(glowView)

        NSLayoutConstraint.activate([
            glowView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            glowView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            glowView.widthAnchor.constraint(equalToConstant: 110),
            glowView.heightAnchor.constraint(equalToConstant: 110)
        ])

        // === Coin icon (bitcoinsign.circle.fill — same as Healing Garden storyboard) ===
        let coinSize: CGFloat = 64
        let coinConfig = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        let coinImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: coinConfig)
        let coinImageView = UIImageView(image: coinImage)
        coinImageView.tintColor = .systemYellow
        coinImageView.contentMode = .scaleAspectFit
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(coinImageView)

        NSLayoutConstraint.activate([
            coinImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            coinImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            coinImageView.widthAnchor.constraint(equalToConstant: coinSize),
            coinImageView.heightAnchor.constraint(equalToConstant: coinSize)
        ])

        // === "+X Coins!" label ===
        let coinsLabel = UILabel()
        coinsLabel.text = "+\(amount) Coins!"
        coinsLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        coinsLabel.textColor = .systemYellow
        coinsLabel.textAlignment = .center
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(coinsLabel)

        NSLayoutConstraint.activate([
            coinsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            coinsLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 12)
        ])

        // === Reason label ===
        let reasonLabel = UILabel()
        reasonLabel.text = reason
        reasonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        reasonLabel.textColor = .white
        reasonLabel.textAlignment = .center
        reasonLabel.alpha = 0.85
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(reasonLabel)

        NSLayoutConstraint.activate([
            reasonLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            reasonLabel.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 6)
        ])

        // === Sparkle particles ===
        addSparkles(to: overlay, center: CGPoint(x: window.bounds.midX, y: window.bounds.midY - 20))

        // === Animate In ===
        container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        coinImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            overlay.alpha = 1
            container.transform = .identity
            coinImageView.transform = .identity
        }

        // Pulse the glow
        UIView.animate(withDuration: 0.8,
                       delay: 0.3,
                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
            glowView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            glowView.alpha = 0.6
        }

        // === Animate Out after 2 seconds ===
        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseIn) {
            overlay.alpha = 0
            container.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            overlay.removeFromSuperview()
        }
    }

    // MARK: - Sparkle Particles

    private func addSparkles(to parentView: UIView, center: CGPoint) {
        let sparkleEmoji = ["✨", "⭐️", "💫", "🌟"]
        let particleCount = 12

        for i in 0..<particleCount {
            let label = UILabel()
            label.text = sparkleEmoji[i % sparkleEmoji.count]
            label.font = UIFont.systemFont(ofSize: CGFloat.random(in: 14...24))
            label.sizeToFit()
            label.center = center
            label.alpha = 0
            parentView.addSubview(label)

            let angle = (CGFloat(i) / CGFloat(particleCount)) * 2 * .pi
            let radius: CGFloat = CGFloat.random(in: 80...160)
            let targetX = center.x + cos(angle) * radius
            let targetY = center.y + sin(angle) * radius

            UIView.animate(withDuration: 0.6,
                           delay: Double.random(in: 0.05...0.3),
                           options: .curveEaseOut) {
                label.alpha = 1
                label.center = CGPoint(x: targetX, y: targetY)
            } completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.8) {
                    label.alpha = 0
                    label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                } completion: { _ in
                    label.removeFromSuperview()
                }
            }
        }
    }
}
