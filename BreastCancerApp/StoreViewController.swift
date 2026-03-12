import UIKit
import AVFoundation
import AudioToolbox

class StoreViewController: UIViewController {

    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var currentcoinvalue: UILabel!
    @IBOutlet weak var coinimage: UIImageView!

    private let gardenManager = GardenManager.shared
    private var currentData: [StoreItem] = []

    private var unlockAudioPlayer: AVAudioPlayer?
    private var activeConfettiLayer: CAEmitterLayer?

    private var categories: [String] {
        GardenManager.segmentCategories
    }

    private var isShowingYourItems: Bool {
        selectedCategory() == GardenManager.Category.yourItems.rawValue
    }

    private lazy var emptyYourItemsLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.text = "No items are unlocked yet.\nPlease complete daily tasks to unlock items."
        lbl.isHidden = true
        return lbl
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentControl()
        setupCoinHeader()
        setupEmptyState()
        updateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gardenManager.checkDailyReset()
        updateData()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        storeCollectionView.dataSource = self
        storeCollectionView.delegate   = self
        storeCollectionView.setCollectionViewLayout(createLayout(), animated: false)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupSegmentControl() {
        categorySegmentedControl.removeTarget(nil, action: nil, for: .valueChanged)
        categorySegmentedControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
    }

    private func setupCoinHeader() {
        coinimage.tintColor = .systemYellow
        refreshCoinHeader()
    }

    private func setupEmptyState() {
        view.addSubview(emptyYourItemsLabel)
        NSLayoutConstraint.activate([
            emptyYourItemsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyYourItemsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emptyYourItemsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyYourItemsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshCoinHeader() {
        currentcoinvalue.text = "\(gardenManager.currentCoins)"
    }

    // MARK: - Segment / Data

    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        updateData()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateData()
    }

    private func selectedCategory() -> String {
        let index = categorySegmentedControl.selectedSegmentIndex
        guard index >= 0 && index < categories.count else { return GardenManager.Category.yourItems.rawValue }
        return categories[index]
    }

    private func updateEmptyState() {
        let showEmpty = isShowingYourItems && currentData.isEmpty
        emptyYourItemsLabel.isHidden = !showEmpty
        storeCollectionView.isHidden  = showEmpty
    }

    private func updateData() {
        currentData = gardenManager.getItems(for: selectedCategory())
        storeCollectionView.reloadData()
        refreshCoinHeader()
        updateEmptyState()
    }

    private func switchToYourItemsAndReload() {
        categorySegmentedControl.selectedSegmentIndex = 0
        updateData()
    }

    // MARK: - Base Selection (from "Your Items")

    private func handleBaseItemTapped(_ item: StoreItem) {
        guard let baseId = item.baseId,
              let base = gardenManager.allBases.first(where: { $0.id == baseId }),
              base.isUnlocked else { return }

        gardenManager.selectBase(base)

        let alert = UIAlertController(
            title: "Base Changed",
            message: "Now viewing \(base.name).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.updateData()
        })
        present(alert, animated: true)
    }

    // MARK: - Purchase Confirmation

    private func showPurchaseConfirmation(for item: StoreItem) {
        guard item.category != GardenManager.Category.yourItems.rawValue else { return }

        if gardenManager.unlockedItemIds.contains(item.id) {
            showAlreadyUnlockedAlert(for: item)
            return
        }

        if gardenManager.currentCoins < item.price {
            let missing = item.price - gardenManager.currentCoins
            showInsufficientCoinsAlert(for: item, missing: missing)
            return
        }

        let alert = UIAlertController(
            title: "Purchase Item?",
            message: "Are you sure you want to purchase \"\(item.name)\" for \(item.price) coins?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes, Buy!", style: .default) { [weak self] _ in
            guard let self = self else { return }
            switch self.gardenManager.purchaseResult(for: item) {
            case .purchased:
                self.updateData()
                self.showUnlockCelebration(for: item) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            case .insufficientCoins(let missingCoins, _, _):
                self.showInsufficientCoinsAlert(for: item, missing: missingCoins)
            case .alreadyUnlocked:
                self.showAlreadyUnlockedAlert(for: item)
            case .notPurchasable:
                break
            }
        })

        present(alert, animated: true)
    }

    // MARK: - Alerts

    private func showInsufficientCoinsAlert(for item: StoreItem, missing: Int) {
        let message = """
        You are lacking \(missing) coins to unlock "\(item.name)".
        Please complete other activities to gain that.
        """
        let alert = UIAlertController(title: "Not Enough Coins", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showAlreadyUnlockedAlert(for item: StoreItem) {
        let alert = UIAlertController(
            title: "Already Unlocked",
            message: "\"\(item.name)\" is already in Your Items.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "View Your Items", style: .default) { [weak self] _ in
            self?.switchToYourItemsAndReload()
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Unlock Animation

    private func showUnlockCelebration(for item: StoreItem, completion: (() -> Void)? = nil) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        playUnlockSound()
        startConfetti()

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        overlay.alpha = 0
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let card = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        card.alpha = 0
        overlay.addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -24),
            card.widthAnchor.constraint(equalToConstant: 300)
        ])

        let container = card.contentView

        let icon = UIImageView(image: UIImage(named: item.imageName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.layer.shadowColor = UIColor.systemYellow.cgColor
        icon.layer.shadowOpacity = 0
        icon.layer.shadowRadius  = 0

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text      = "Hurray!"
        title.font      = .systemFont(ofSize: 28, weight: .black)
        title.textAlignment = .center
        title.textColor = .label

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text      = "You unlocked \(item.name)"
        subtitle.font      = .systemFont(ofSize: 18, weight: .semibold)
        subtitle.textAlignment = .center
        subtitle.textColor = .label
        subtitle.numberOfLines = 2

        let sparkle = UIImageView(image: UIImage(systemName: "sparkles"))
        sparkle.translatesAutoresizingMaskIntoConstraints = false
        sparkle.tintColor = .systemYellow

        container.addSubview(title)
        container.addSubview(icon)
        container.addSubview(subtitle)
        container.addSubview(sparkle)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            icon.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 120),
            icon.heightAnchor.constraint(equalToConstant: 120),

            subtitle.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 14),
            subtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            subtitle.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -22),

            sparkle.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            sparkle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            sparkle.widthAnchor.constraint(equalToConstant: 22),
            sparkle.heightAnchor.constraint(equalToConstant: 22)
        ])

        card.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).translatedBy(x: 0, y: 40)
        UIView.animate(withDuration: 0.25) { overlay.alpha = 1 }
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.65) {
            card.alpha     = 1
            card.transform = .identity
        }

        addGlowPulse(on: icon.layer)
        addCardPulse(on: card.layer)
        addSparkleSpin(on: sparkle.layer)
        addShimmer(on: card)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.stopConfetti()
            UIView.animate(withDuration: 0.25, animations: {
                card.alpha    = 0
                overlay.alpha = 0
            }, completion: { _ in
                overlay.removeFromSuperview()
                completion?()
            })
        }
    }

    private func addGlowPulse(on layer: CALayer) {
        layer.shadowColor  = UIColor.systemYellow.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 18
        let glow = CABasicAnimation(keyPath: "shadowOpacity")
        glow.fromValue = 0; glow.toValue = 0.95; glow.duration = 0.22
        glow.autoreverses = true; glow.repeatCount = 5
        layer.add(glow, forKey: "unlockGlow")
    }

    private func addCardPulse(on layer: CALayer) {
        let pulse = CAKeyframeAnimation(keyPath: "transform.scale")
        pulse.values   = [1.0, 1.10, 0.97, 1.06, 1.0]
        pulse.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        pulse.duration = 0.65
        layer.add(pulse, forKey: "unlockPulse")
    }

    private func addSparkleSpin(on layer: CALayer) {
        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0; spin.toValue = CGFloat.pi * 2
        spin.duration = 0.9; spin.repeatCount = 2
        layer.add(spin, forKey: "sparkleSpin")
    }

    private func addShimmer(on target: UIView) {
        target.layoutIfNeeded()
        let shimmer = CAGradientLayer()
        shimmer.frame = CGRect(x: -target.bounds.width, y: 0,
                               width: target.bounds.width * 2, height: target.bounds.height)
        shimmer.colors    = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.55).cgColor, UIColor.clear.cgColor]
        shimmer.locations = [0, 0.5, 1]
        target.layer.addSublayer(shimmer)
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -target.bounds.width; animation.toValue = target.bounds.width
        animation.duration  = 0.9
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shimmer.add(animation, forKey: "shimmerMove")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { shimmer.removeFromSuperlayer() }
    }

    private func startConfetti() {
        activeConfettiLayer?.removeFromSuperlayer()
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -20)
        emitter.emitterShape    = .line
        emitter.emitterSize     = CGSize(width: view.bounds.width, height: 2)
        emitter.birthRate       = 1
        emitter.zPosition       = 9999
        let colors: [UIColor] = [.systemPink, .systemYellow, .systemMint, .systemTeal, .systemOrange]
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 8; cell.lifetime = 3.5; cell.velocity = 220
            cell.velocityRange = 70; cell.emissionLongitude = .pi; cell.emissionRange = .pi / 5
            cell.spin = 2.5; cell.spinRange = 3.5; cell.scale = 0.22; cell.scaleRange = 0.12
            cell.color    = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            return cell
        }
        view.layer.addSublayer(emitter)
        activeConfettiLayer = emitter
    }

    private func stopConfetti() {
        guard let emitter = activeConfettiLayer else { return }
        emitter.birthRate = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { emitter.removeFromSuperlayer() }
        activeConfettiLayer = nil
    }

    private func playUnlockSound() {
        UnlockSoundPlayer.shared.playUnlock()
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCell", for: indexPath) as! StoreItemCell
        let item = currentData[indexPath.item]

        if isShowingYourItems {
            let isBase = item.id.hasPrefix("base_")
            let isSelected = isBase && (item.baseId == gardenManager.selectedBase.id)
            cell.configureAsYourItem(item, isBase: isBase, isSelectedBase: isSelected)
        } else {
            cell.configure(with: item, showPrice: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = currentData[indexPath.item]

        if isShowingYourItems {
            if item.id.hasPrefix("base_") {
                handleBaseItemTapped(item)
            }
            return
        }

        showPurchaseConfirmation(for: item)
    }
}
