import UIKit

// MARK: - Chart Mode
enum HydrationChartMode {
    case weekly
    case monthly
}

class HydrationViewController: UIViewController {

    // MARK: - Reuse Identifiers
    private enum CellReuseID {
        static let topCard = "HydrationTopCardCell"
        static let chart = "HydrationChartCell"
    }

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - State
    private var chartMode: HydrationChartMode = .weekly

    // MARK: - Selector UI State
    private var selectorOverlayView: UIView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "baground")
        setupCollectionView()
    }

    // MARK: - Setup
    private func setupCollectionView() {

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 1
            layout.sectionInset = .zero
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(named: "baground")

        collectionView.register(
            UINib(nibName: "HydrationTopCardCell", bundle: nil),
            forCellWithReuseIdentifier: CellReuseID.topCard
        )

        collectionView.register(
            UINib(nibName: "HydrationChartCell", bundle: nil),
            forCellWithReuseIdentifier: CellReuseID.chart
        )
    }
}

// MARK: - UICollectionViewDataSource
extension HydrationViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // TOP CARD
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellReuseID.topCard,
                for: indexPath
            ) as! HydrationTopCardCell

            let consumedML = HydrationModel.consumedTodayML()
            let goalLiters = HydrationModel.currentGoal()
            let cupML = Int(HydrationModel.currentCupSize() * 1000)

            cell.configure(
                consumedML: consumedML,
                goal: goalLiters,
                cupSize: cupML
            )

            cell.onGoalTapped = { [weak self] in
                self?.showGoalSelector()
            }

            cell.onCupTapped = { [weak self] in
                self?.showCupSelector()
            }

            // ✅ FIXED: increment strictly in mL
            cell.onDropTapped = { [weak self] in
                guard let self else { return }

                let cupML = Int(HydrationModel.currentCupSize() * 1000)

                HydrationModel.addWaterML(cupML)
                HydrationHistoryModel.addWaterML(cupML)

                self.collectionView.reloadItems(
                    at: [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0)
                    ]
                )
            }

            return cell
        }

        // CHART
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.chart,
            for: indexPath
        ) as! HydrationChartCell

        let period: HydrationHistoryModel.Period =
            chartMode == .weekly ? .weekly : .monthly

        let average = HydrationHistoryModel.average(for: period)
        cell.configure(average: average, mode: chartMode)

        cell.onSegmentChanged = { [weak self] newMode in
            self?.chartMode = newMode
            self?.collectionView.reloadItems(
                at: [IndexPath(item: 1, section: 0)]
            )
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HydrationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: collectionView.bounds.width, height: 370)
    }
}

// MARK: - Glass Selector (ONLY GlassOptionCell.xib)
extension HydrationViewController {

    private func showSelector(
        title: String,
        subtitle: String,
        options: [String],
        onSelect: @escaping (Int) -> Void
    ) {

        guard selectorOverlayView == nil else { return }

        // Overlay
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)

        let blur = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterial)
        )
        blur.frame = overlay.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addSubview(blur)

        // Card
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(card)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24)
        ])

        // Stack
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .center

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        // OPTIONS
        for (index, text) in options.enumerated() {
            let cell = Bundle.main
                .loadNibNamed("GlassOptionCell", owner: nil)?
                .first as! GlassOptionCell

            cell.configure(
                text: text,
                hideDivider: index == options.count - 1
            )

            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: 50).isActive = true

            cell.onTap = { [weak self] in
                self?.dismissSelector()
                onSelect(index)
            }

            stack.addArrangedSubview(cell)
        }

        // Cancel
        let cancelCell = Bundle.main
            .loadNibNamed("GlassOptionCell", owner: nil)?
            .first as! GlassOptionCell

        cancelCell.configure(text: "Cancel", hideDivider: true)
        cancelCell.translatesAutoresizingMaskIntoConstraints = false
        cancelCell.heightAnchor.constraint(equalToConstant: 50).isActive = true

        cancelCell.onTap = { [weak self] in
            self?.dismissSelector()
        }

        stack.addArrangedSubview(cancelCell)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelector))
        overlay.addGestureRecognizer(tap)

        selectorOverlayView = overlay
    }

    @objc private func dismissSelector() {
        selectorOverlayView?.removeFromSuperview()
        selectorOverlayView = nil
    }
}

// MARK: - Goal / Cup Selectors
extension HydrationViewController {

    func showGoalSelector() {
        let values = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
        let titles = values.map { "\($0) L" }

        showSelector(
            title: "Daily Goal",
            subtitle: "Select your daily water goal",
            options: titles
        ) { index in
            HydrationModel.setGoal(values[index])
            self.reloadTopCard()
        }
    }

    func showCupSelector() {
        let values: [Double] = [0.1, 0.15, 0.2, 0.25, 0.3, 0.5]
        let titles = values.map { "\(Int($0 * 1000)) mL" }

        showSelector(
            title: "Cup Size",
            subtitle: "Select your cup size",
            options: titles
        ) { index in
            HydrationModel.setCupSize(values[index])
            self.reloadTopCard()
        }
    }

    func reloadTopCard() {
        collectionView.reloadItems(
            at: [IndexPath(item: 0, section: 0)]
        )
    }
}
