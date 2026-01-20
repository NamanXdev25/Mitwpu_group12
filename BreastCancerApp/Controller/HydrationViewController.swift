import UIKit

// MARK: - Chart Mode
enum HydrationChartMode {
    case weekly
    case monthly
}

final class HydrationViewController: UIViewController {

    // MARK: - Reuse Identifiers
    private enum CellReuseID {
        static let topCard = "HydrationTopCardCell"
        static let chart = "HydrationChartCell"
    }

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - State
    private var chartMode: HydrationChartMode = .weekly

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "baground")
        configureCollectionView()
    }

    // MARK: - Setup
    private func configureCollectionView() {

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 1
            layout.sectionInset = .zero
        }

        collectionView.backgroundColor = UIColor(named: "baground")
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: CellReuseID.topCard, bundle: nil),
            forCellWithReuseIdentifier: CellReuseID.topCard
        )

        collectionView.register(
            UINib(nibName: CellReuseID.chart, bundle: nil),
            forCellWithReuseIdentifier: CellReuseID.chart
        )
    }
}

// MARK: - UICollectionViewDataSource
extension HydrationViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if indexPath.item == 0 {
            return makeTopCardCell(for: indexPath)
        }

        return makeChartCell(for: indexPath)
    }

    // MARK: - Cell Builders
    private func makeTopCardCell(
        for indexPath: IndexPath
    ) -> UICollectionViewCell {

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

    private func makeChartCell(
        for indexPath: IndexPath
    ) -> UICollectionViewCell {

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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: collectionView.bounds.width,
            height: 370
        )
    }
}

// MARK: - Selector Presentation
extension HydrationViewController {

    private func presentOptionSelector(
        title: String,
        subtitle: String,
        options: [String],
        onSelect: @escaping (Int) -> Void
    ) {
        let vc = HydrationOptionSelectorViewController(
            nibName: "HydrationOptionSelectorViewController",
            bundle: nil
        )

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        vc.titleText = title
        vc.subtitleText = subtitle
        vc.options = options
        vc.onSelect = onSelect

        present(vc, animated: true)
    }
}

// MARK: - Goal / Cup Selectors
extension HydrationViewController {

    func showGoalSelector() {
        let values = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
        let titles = values.map { "\($0) L" }

        presentOptionSelector(
            title: "Daily Goal",
            subtitle: "Select your daily water goal",
            options: titles
        ) { [weak self] index in
            HydrationModel.setGoal(values[index])
            self?.reloadTopCard()
        }
    }

    func showCupSelector() {
        let values: [Double] = [0.1, 0.15, 0.2, 0.25, 0.3, 0.5]
        let titles = values.map { "\(Int($0 * 1000)) mL" }

        presentOptionSelector(
            title: "Cup Size",
            subtitle: "Select your cup size",
            options: titles
        ) { [weak self] index in
            HydrationModel.setCupSize(values[index])
            self?.reloadTopCard()
        }
    }

    func reloadTopCard() {
        collectionView.reloadItems(
            at: [IndexPath(item: 0, section: 0)]
        )
    }
}
