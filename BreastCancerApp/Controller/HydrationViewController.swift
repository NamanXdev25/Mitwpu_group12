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

            cell.configure(
                consumedML: Int(HydrationModel.consumedToday() * 1000),
                goal: HydrationModel.currentGoal(),
                cupSize: Int(HydrationModel.currentCupSize() * 1000)
            )

            cell.onGoalTapped = { [weak self] in
                self?.showGoalSelector()
            }

            cell.onCupTapped = { [weak self] in
                self?.showCupSelector()
            }

            cell.onDropTapped = { [weak self] in
                guard let self else { return }

                // Update today
                HydrationModel.addCup()

                // Update history (for chart)
                HydrationHistoryModel.addWater(
                    amount: HydrationModel.currentCupSize()
                )

                // Reload top card + chart
                self.collectionView.reloadItems(
                    at: [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0)
                    ]
                )
            }

            return cell
        }

        // CHART CARD
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

// MARK: - Goal / Cup Selectors
extension HydrationViewController {

    func showGoalSelector() {
        let options: [Double] = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0]

        let alert = UIAlertController(
            title: "Daily Goal",
            message: "Select your daily water goal",
            preferredStyle: .actionSheet
        )

        options.forEach { value in
            alert.addAction(
                UIAlertAction(title: "\(value) L", style: .default) { _ in
                    HydrationModel.setGoal(value)
                    self.reloadTopCard()
                }
            )
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func showCupSelector() {
        let options: [Double] = [0.1, 0.15, 0.2, 0.25, 0.3, 0.5]

        let alert = UIAlertController(
            title: "Cup Size",
            message: "Select your cup size",
            preferredStyle: .actionSheet
        )

        options.forEach { value in
            let ml = Int(value * 1000)
            alert.addAction(
                UIAlertAction(title: "\(ml) mL", style: .default) { _ in
                    HydrationModel.setCupSize(value)
                    self.reloadTopCard()
                }
            )
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func reloadTopCard() {
        collectionView.reloadItems(
            at: [IndexPath(item: 0, section: 0)]
        )
    }
}
