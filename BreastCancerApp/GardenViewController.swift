//import UIKit
//import SpriteKit
//
//// MARK: - GardenViewController
//
//class GardenViewController: UIViewController {
//
//    // MARK: - Existing Storyboard Outlets
//    @IBOutlet weak var gardenSKView: SKView!
//    @IBOutlet weak var itemCollectionView: UICollectionView!
//    @IBOutlet weak var storeButton: UIButton!
//
//    // MARK: - Level Card Outlets  ← Connect these in your storyboard
//    /// The "Level 1" label (top-left of the card)
//    @IBOutlet weak var levelTitleLabel: UILabel!
//    /// The "500 Points to next garden" subtitle label
//    @IBOutlet weak var pointsToNextLabel: UILabel!
//    /// Connect your UIProgressView here (the pink bar)
//    @IBOutlet weak var levelProgressView: UIProgressView!
//    /// The "4200" current-points label (left side of fraction)
//    @IBOutlet weak var currentPointsLabel: UILabel!
//    /// The "5000" total-points label (right side of fraction)
//    @IBOutlet weak var totalPointsLabel: UILabel!
//
//    var gardenScene: GardenScene?
//    private let gardenManager = GardenManager.shared
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupSpriteKit()
//        setupGestures()
//        observeNotifications()
//        // Style the progress view tint to match your pink colour
//        levelProgressView?.progressTintColor = UIColor(red: 0.93, green: 0.29, blue: 0.47, alpha: 1.0)
//        levelProgressView?.trackTintColor    = UIColor.systemGray5
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.title = "Healing Garden"
//        itemCollectionView.reloadData()
//        updateLevelCard()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let scene = gardenScene, scene.size != gardenSKView.bounds.size {
//            scene.size = gardenSKView.bounds.size
//            scene.handleSceneSizeUpdate()
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    // MARK: - Level Card Update
//
//    private func updateLevelCard() {
//        let p = gardenManager.levelProgress
//
//        levelTitleLabel?.text    = "Level \(p.currentLevel)"
//        pointsToNextLabel?.text  = "\(p.pointsNeededForNextLevel) Points to next garden"
//        currentPointsLabel?.text = "\(p.currentPoints)"
//        totalPointsLabel?.text   = "\(p.pointsNeededForNextLevel)"
//
//        // UIProgressView takes a Float from 0.0 to 1.0
//        let ratio = Float(p.currentPoints) / Float(p.pointsNeededForNextLevel)
//        UIView.animate(withDuration: 0.5) {
//            self.levelProgressView?.setProgress(min(ratio, 1.0), animated: true)
//        }
//    }
//
//    // MARK: - Notifications
//
//    private func observeNotifications() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleBaseChanged(_:)),
//            name: .gardenBaseDidChange,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleLevelChanged(_:)),
//            name: .gardenLevelDidChange,
//            object: nil
//        )
//        // FIX: observe new-base-unlocked events separately so we can alert + reload
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleBasesUnlocked(_:)),
//            name: .gardenBasesUnlocked,
//            object: nil
//        )
//    }
//
//    @objc private func handleBaseChanged(_ note: Notification) {
//        guard let base = note.object as? GardenBase else { return }
//        gardenScene?.switchBase(to: base)
//        itemCollectionView.reloadData()
//    }
//
//    @objc private func handleLevelChanged(_ note: Notification) {
//        // Already on main thread via DispatchQueue.main.async in GardenManager
//        updateLevelCard()
//        itemCollectionView.reloadData()
//    }
//
//    // FIX: called when checkAndUnlockBasesForLevel() unlocks one or more bases
//    @objc private func handleBasesUnlocked(_ note: Notification) {
//        // Reload tray immediately so new base tile appears
//        itemCollectionView.reloadData()
//
//        // Show an alert for each newly unlocked base
//        guard let bases = note.object as? [GardenBase] else { return }
//        for base in bases {
//            let alert = UIAlertController(
//                title: "🌿 New Garden Unlocked!",
//                message: "\(base.name) is now available. Tap its tile in the tray to switch.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "Let's go!", style: .default))
//            present(alert, animated: true)
//        }
//    }
//
//    // MARK: - Gestures
//
//    private func setupGestures() {
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        gardenSKView.addGestureRecognizer(pinch)
//
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        pan.minimumNumberOfTouches = 1
//        pan.cancelsTouchesInView   = false
//        gardenSKView.addGestureRecognizer(pan)
//    }
//
//    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        gardenScene?.handlePinch(sender)
//    }
//
//    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
//        gardenScene?.handlePan(sender)
//    }
//
//    // MARK: - Collection View Setup
//
//    private func setupCollectionView() {
//        itemCollectionView.delegate    = self
//        itemCollectionView.dataSource  = self
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection         = .horizontal
//        layout.minimumLineSpacing      = 0
//        layout.minimumInteritemSpacing = 0
//        layout.itemSize                = CGSize(width: 85, height: 100)
//        itemCollectionView.collectionViewLayout = layout
//        itemCollectionView.showsHorizontalScrollIndicator = false
//        itemCollectionView.showsVerticalScrollIndicator   = false
//    }
//
//    // MARK: - SpriteKit Setup
//
//    private func setupSpriteKit() {
//        let scene = GardenScene(size: gardenSKView.bounds.size)
//        scene.scaleMode       = .resizeFill
//        scene.backgroundColor = .clear
//        scene.gardenManager   = gardenManager
//        gardenSKView.presentScene(scene)
//        gardenSKView.allowsTransparency = true
//        self.gardenScene = scene
//    }
//
//    // MARK: - Store Button
//
//    @IBAction func storeButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
//        if let storeVC = storyboard.instantiateViewController(
//            withIdentifier: "StoreViewController") as? StoreViewController {
//            self.navigationController?.pushViewController(storeVC, animated: true)
//        }
//    }
//}
//
//// MARK: - UICollectionView DataSource / Delegate
//
//extension GardenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    private var trayItems: [StoreItem] {
//        return gardenManager.trayItems
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        return trayItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
//            return UICollectionViewCell()
//        }
//        let items  = trayItems
//        let item   = items[indexPath.item]
//        let isLast = indexPath.item == items.count - 1
//        cell.configure(with: item, isLast: isLast)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        let item = trayItems[indexPath.item]
//
//        // Tapping a base tile switches the active garden base
//        if item.id.hasPrefix("base_") {
//            if let base = gardenManager.allBases.first(where: {
//                $0.id == item.baseId && $0.isUnlocked
//            }) {
//                gardenManager.selectBase(base)
//            }
//            return
//        }
//
//        // Tapping a regular item enters placement mode
//        gardenScene?.enterPlacementMode(for: item.imageName)
//    }
//}
//
//// MARK: - GardenScene
//
//class GardenScene: SKScene {
//
//    var gardenManager: GardenManager?
//    var activePlacementNode: SKNode?
//    var isDragging = false
//    var gardenBaseNode: SKSpriteNode?
//
//    let cameraNode = SKCameraNode()
//    private var initialCameraScale: CGFloat = 1.0
//    private var isPlacementValid: Bool = true
//    private var loadedBaseId: String = "classic"
//
//    // MARK: - Lifecycle
//
//    override func didMove(to view: SKView) {
//        setupCamera()
//        let baseId    = gardenManager?.selectedBase.id        ?? "classic"
//        let imageName = gardenManager?.selectedBase.imageName ?? "garden_base"
//        setupGardenBase(imageName: imageName)
//        loadedBaseId = baseId
//        restorePlacedItems(for: baseId)
//    }
//
//    func handleSceneSizeUpdate() {
//        updateCameraPosition()
//        if let base = gardenBaseNode { repositionBase(base) }
//    }
//
//    // MARK: - Base Switching
//
//    func switchBase(to base: GardenBase) {
//        guard base.id != loadedBaseId else { return }
//        savePlacedItems(for: loadedBaseId)
//        children.filter { $0.name == "placed_item" }.forEach { $0.removeFromParent() }
//        cancelPlacement()
//        gardenBaseNode?.removeFromParent()
//        gardenBaseNode = nil
//        setupGardenBase(imageName: base.imageName)
//        loadedBaseId = base.id
//        restorePlacedItems(for: base.id)
//    }
//
//    // MARK: - Placed Items Persistence
//
//    private func savePlacedItems(for baseId: String) {
//        var items: [PlacedItem] = []
//        for node in children where node.name == "placed_item" {
//            guard let sprite    = node as? SKSpriteNode,
//                  let assetName = sprite.userData?["assetName"] as? String else { continue }
//            items.append(PlacedItem(
//                id: UUID().uuidString, imageName: assetName,
//                positionX: sprite.position.x, positionY: sprite.position.y,
//                zPosition: sprite.zPosition
//            ))
//        }
//        gardenManager?.savePlacedItems(items, for: baseId)
//    }
//
//    private func restorePlacedItems(for baseId: String) {
//        guard let items = gardenManager?.loadPlacedItems(for: baseId) else { return }
//        for item in items {
//            let sprite         = SKSpriteNode(imageNamed: item.imageName)
//            sprite.position    = CGPoint(x: item.positionX, y: item.positionY)
//            sprite.zPosition   = item.zPosition
//            sprite.name        = "placed_item"
//            sprite.userData    = ["assetName": item.imageName]
//            sprite.setScale(0.15)
//            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.2)
//            addChild(sprite)
//        }
//    }
//
//    // MARK: - Camera
//
//    func updateCameraPosition() {
//        if cameraNode.position == .zero {
//            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        }
//        constrainCamera()
//    }
//
//    private func setupCamera() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        addChild(cameraNode)
//        self.camera = cameraNode
//    }
//
//    private func setupGardenBase(imageName: String) {
//        if gardenBaseNode == nil {
//            let base       = SKSpriteNode(imageNamed: imageName)
//            base.name      = "garden_base"
//            base.zPosition = -1
//            addChild(base)
//            self.gardenBaseNode = base
//        }
//        guard let base = gardenBaseNode else { return }
//        repositionBase(base)
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        constrainCamera()
//    }
//
//    private func repositionBase(_ base: SKSpriteNode) {
//        let t = base.texture?.size() ?? CGSize(width: 1, height: 1)
//        base.setScale(max(self.size.width / t.width, self.size.height / t.height))
//        base.position = CGPoint(x: frame.midX, y: frame.midY)
//    }
//
//    // MARK: - Zoom / Pan
//
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        if sender.state == .began { initialCameraScale = cameraNode.xScale }
//        let newScale = initialCameraScale / sender.scale
//        if let base = gardenBaseNode {
//            let maxPossible = min(base.size.width / self.size.width,
//                                  base.size.height / self.size.height)
//            cameraNode.setScale(max(0.4, min(newScale, maxPossible)))
//        }
//        constrainCamera()
//    }
//
//    func handlePan(_ sender: UIPanGestureRecognizer) {
//        if isDragging { return }
//        let t = sender.translation(in: self.view)
//        cameraNode.position = CGPoint(
//            x: cameraNode.position.x - t.x * cameraNode.xScale,
//            y: cameraNode.position.y + t.y * cameraNode.yScale
//        )
//        constrainCamera()
//        sender.setTranslation(.zero, in: self.view)
//    }
//
//    private func constrainCamera() {
//        guard let base = gardenBaseNode else { return }
//        let hw = max(0, (base.size.width  - self.size.width  * cameraNode.xScale) / 2)
//        let hh = max(0, (base.size.height - self.size.height * cameraNode.yScale) / 2)
//        let cx = base.position.x, cy = base.position.y
//        cameraNode.position.x = max(cx - hw, min(cameraNode.position.x, cx + hw))
//        cameraNode.position.y = max(cy - hh, min(cameraNode.position.y, cy + hh))
//    }
//
//    // MARK: - Placement Mode
//
//    func enterPlacementMode(for imageName: String) {
//        cancelPlacement()
//        let container       = SKNode()
//        container.position  = cameraNode.position
//        container.zPosition = 1000
//        container.name      = "placement_container"
//        container.addChild(makeDiamondHighlight(valid: true))
//        let item            = SKSpriteNode(imageNamed: imageName)
//        item.name           = "moving_item"
//        item.alpha          = 0.85
//        item.userData       = ["assetName": imageName]
//        item.setScale(0.15)
//        item.anchorPoint    = CGPoint(x: 0.5, y: 0.2)
//        container.addChild(item)
//        addConfirmButtons(to: container)
//        addChild(container)
//        activePlacementNode = container
//        isDragging          = true
//        isPlacementValid    = true
//        updateButtonStates(in: container, valid: true)
//    }
//
//    // MARK: - Move Mode
//
//    private func enterMoveMode(for node: SKSpriteNode) {
//        cancelPlacement()
//        let container       = SKNode()
//        container.position  = node.position
//        container.zPosition = 1000
//        container.name      = "placement_container"
//        container.addChild(makeDiamondHighlight(valid: true))
//        let item            = SKSpriteNode(imageNamed: node.userData?["assetName"] as? String ?? "")
//        item.name           = "moving_item"
//        item.alpha          = 0.85
//        item.userData       = node.userData
//        item.setScale(node.xScale)
//        item.anchorPoint    = node.anchorPoint
//        container.addChild(item)
//        addDirectionalArrows(to: container)
//        addConfirmButtons(to: container)
//        node.removeFromParent()
//        addChild(container)
//        activePlacementNode = container
//        isDragging          = false
//        isPlacementValid    = true
//        updateButtonStates(in: container, valid: true)
//    }
//
//    // MARK: - Diamond Highlight
//
//    private func makeDiamondHighlight(valid: Bool) -> SKShapeNode {
//        let d = SKShapeNode(), p = CGMutablePath()
//        p.move(to: CGPoint(x: 0, y: 12)); p.addLine(to: CGPoint(x: 22, y: 0))
//        p.addLine(to: CGPoint(x: 0, y: -12)); p.addLine(to: CGPoint(x: -22, y: 0))
//        p.closeSubpath()
//        d.path        = p
//        d.fillColor   = valid ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
//                               : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
//        d.strokeColor = valid ? UIColor(red: 0.0,  green: 0.7,  blue: 0.0, alpha: 0.8)
//                               : UIColor(red: 0.8,  green: 0.0,  blue: 0.0, alpha: 0.8)
//        d.lineWidth = 1.5; d.zPosition = -0.5; d.name = "placement_highlight"
//        return d
//    }
//
//    // MARK: - Confirm Buttons
//
//    private func addConfirmButtons(to container: SKNode) {
//        let cancelBtn       = makeRoundedButton(symbol: "✕",
//            bgColor: UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1.0), size: 26)
//        cancelBtn.position  = CGPoint(x: -30, y: 55); cancelBtn.name = "btn_cancel"
//        container.addChild(cancelBtn)
//        let confirmBtn      = makeRoundedButton(symbol: "✓",
//            bgColor: UIColor(white: 0.55, alpha: 1.0), size: 26)
//        confirmBtn.position = CGPoint(x: 30, y: 55); confirmBtn.name = "btn_confirm"
//        container.addChild(confirmBtn)
//    }
//
//    private func makeRoundedButton(symbol: String, bgColor: UIColor, size: CGFloat) -> SKNode {
//        let node = SKNode()
//        let bg   = SKShapeNode(rectOf: CGSize(width: size * 1.9, height: size * 1.9),
//                               cornerRadius: size * 0.4)
//        bg.fillColor = bgColor; bg.strokeColor = UIColor.white.withAlphaComponent(0.3)
//        bg.lineWidth = 1.5; bg.name = "button_bg"; node.addChild(bg)
//        let lbl = SKLabelNode(text: symbol)
//        lbl.fontName = "Helvetica-Bold"; lbl.fontSize = size * 0.75; lbl.fontColor = .white
//        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
//        lbl.name = "button_label"; node.addChild(lbl)
//        return node
//    }
//
//    private func updateButtonStates(in container: SKNode, valid: Bool) {
//        if let h = container.childNode(withName: "placement_highlight") as? SKShapeNode {
//            h.fillColor   = valid ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
//                                  : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
//            h.strokeColor = valid ? UIColor(red: 0.0,  green: 0.7,  blue: 0.0, alpha: 0.8)
//                                  : UIColor(red: 0.8,  green: 0.0,  blue: 0.0, alpha: 0.8)
//        }
//        if let btn = container.childNode(withName: "btn_confirm"),
//           let bg  = btn.childNode(withName: "button_bg") as? SKShapeNode {
//            bg.fillColor = valid ? UIColor(red: 0.1, green: 0.75, blue: 0.1, alpha: 1.0)
//                                 : UIColor(white: 0.55, alpha: 1.0)
//        }
//    }
//
//    // MARK: - Overlap / Boundary
//
//    private func radiusFor(_ node: SKNode) -> CGFloat {
//        if let s = node as? SKSpriteNode { return s.size.width * 0.18 }
//        if let s = node.childNode(withName: "moving_item") as? SKSpriteNode { return s.size.width * 0.18 }
//        return 6
//    }
//
//    private func isOverlappingPlacedItem(at pos: CGPoint, excluding container: SKNode) -> Bool {
//        let r = radiusFor(container)
//        for node in children where node.name == "placed_item" && node !== container {
//            if hypot(node.position.x - pos.x, node.position.y - pos.y) < r + radiusFor(node) { return true }
//        }
//        return false
//    }
//
//    private func isInsideGrassArea(_ pos: CGPoint) -> Bool {
//        guard let base = gardenBaseNode else { return true }
//        let cx  = base.position.x
//        let cy  = base.position.y - base.size.height * base.yScale * 0.02
//        let px  = pos.x - cx, py = pos.y - cy
//        let hw  = base.size.width  * base.xScale * 0.80
//        let hhu = base.size.height * base.yScale * 0.25
//        let hhd = base.size.height * base.yScale * 0.13
//        return (abs(px / hw) + abs(py / (py >= 0 ? hhu : hhd))) <= 1.0
//    }
//
//    // MARK: - Directional Arrows
//
//    private func addDirectionalArrows(to container: SKNode) {
//        let offset: CGFloat = 22, vs: CGFloat = 20
//        [(CGFloat(0), CGFloat(0), offset + vs),
//         (.pi, 0, -offset + vs), (.pi/2, -offset, vs), (-.pi/2, offset, vs)].forEach { r, dx, dy in
//            let a = makeArrowNode(); a.zRotation = r; a.position = CGPoint(x: dx, y: dy)
//            container.addChild(a)
//        }
//    }
//
//    private func makeArrowNode() -> SKShapeNode {
//        let a = SKShapeNode(), p = CGMutablePath()
//        p.move(to: CGPoint(x: 0, y: 16))
//        p.addLine(to: CGPoint(x: 12, y: 2)); p.addLine(to: CGPoint(x: 6, y: 2))
//        p.addLine(to: CGPoint(x: 6, y: -12)); p.addLine(to: CGPoint(x: -6, y: -12))
//        p.addLine(to: CGPoint(x: -6, y: 2)); p.addLine(to: CGPoint(x: -12, y: 2))
//        p.closeSubpath()
//        a.path = p
//        a.fillColor   = UIColor(red: 0.15, green: 0.82, blue: 0.15, alpha: 1.0)
//        a.strokeColor = UIColor(red: 0.05, green: 0.45, blue: 0.05, alpha: 1.0)
//        a.lineWidth = 1.5; a.name = "placement_arrow"; a.isUserInteractionEnabled = false
//        let up = SKAction.scale(to: 1.12, duration: 0.45)
//        let dn = SKAction.scale(to: 0.92, duration: 0.45)
//        up.timingMode = .easeInEaseOut; dn.timingMode = .easeInEaseOut
//        a.run(SKAction.repeatForever(SKAction.sequence([up, dn])))
//        return a
//    }
//
//    // MARK: - Touch Handling
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let loc   = touch.location(in: self)
//        let nodes = nodes(at: loc)
//        if let active = activePlacementNode {
//            for n in nodes {
//                if n.name == "btn_cancel"  || n.parent?.name == "btn_cancel"  { cancelPlacement(); return }
//                if n.name == "btn_confirm" || n.parent?.name == "btn_confirm" { if isPlacementValid { confirmPlacement() }; return }
//            }
//            for n in nodes where n.name == "moving_item" || n.parent == active { isDragging = true; return }
//            if isPlacementValid { confirmPlacement() }
//            return
//        }
//        for n in nodes {
//            if n.name == "placed_item", let s = n as? SKSpriteNode { enterMoveMode(for: s); isDragging = false; return }
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let c = activePlacementNode else { return }
//        isDragging = true
//        c.children.filter { $0.name == "placement_arrow" }.forEach { $0.isHidden = true }
//        let pos = touch.location(in: self)
//        c.position   = pos
//        isPlacementValid = isInsideGrassArea(pos) && !isOverlappingPlacedItem(at: pos, excluding: c)
//        updateButtonStates(in: c, valid: isPlacementValid)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isDragging else { return }
//        isDragging = false
//        activePlacementNode?.children.filter { $0.name == "placement_arrow" }.forEach { $0.isHidden = false }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { isDragging = false }
//
//    // MARK: - Confirm / Cancel
//
//    func confirmPlacement() {
//        guard isPlacementValid,
//              let c     = activePlacementNode,
//              let ghost = c.childNode(withName: "moving_item") as? SKSpriteNode else { cancelPlacement(); return }
//        let assetName = ghost.userData?["assetName"] as? String ?? ""
//        let f         = SKSpriteNode(imageNamed: assetName)
//        f.position    = c.position; f.anchorPoint = ghost.anchorPoint
//        f.setScale(ghost.xScale); f.name = "placed_item"
//        f.userData    = ["assetName": assetName]
//        f.zPosition   = 1000 - c.position.y; f.alpha = 1.0
//        addChild(f); cancelPlacement()
//        savePlacedItems(for: loadedBaseId)
//    }
//
//    func cancelPlacement() {
//        activePlacementNode?.removeFromParent()
//        activePlacementNode = nil; isDragging = false; isPlacementValid = true
//    }
//
//    override func willMove(from view: SKView) {
//        savePlacedItems(for: loadedBaseId)
//    }
//}

import UIKit
import SpriteKit

// MARK: - GardenViewController

class GardenViewController: UIViewController {

    // MARK: - Existing Storyboard Outlets
    @IBOutlet weak var gardenSKView: SKView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var storeButton: UIButton!

    // MARK: - Level Card Outlets  ← Connect these in your storyboard
    /// The "Level 1" label (top-left of the card)
    @IBOutlet weak var levelTitleLabel: UILabel!
    /// The "500 Points to next garden" subtitle label
    @IBOutlet weak var pointsToNextLabel: UILabel!
    /// Connect your UIProgressView here (the pink bar)
    @IBOutlet weak var levelProgressView: UIProgressView!
    /// The "4200" current-points label (left side of fraction)
    @IBOutlet weak var currentPointsLabel: UILabel!
    /// The "5000" total-points label (right side of fraction)
    @IBOutlet weak var totalPointsLabel: UILabel!

    var gardenScene: GardenScene?
    private let gardenManager = GardenManager.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSpriteKit()
        setupGestures()
        observeNotifications()
        // Style the progress view tint to match your pink colour
        levelProgressView?.progressTintColor = UIColor(red: 0.93, green: 0.29, blue: 0.47, alpha: 1.0)
        levelProgressView?.trackTintColor    = UIColor.systemGray5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Healing Garden"
        itemCollectionView.reloadData()
        updateLevelCard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let scene = gardenScene, scene.size != gardenSKView.bounds.size {
            scene.size = gardenSKView.bounds.size
            scene.handleSceneSizeUpdate()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Level Card Update

    private func updateLevelCard() {
        let p = gardenManager.levelProgress

        // Total points needed to complete the current level
        // Level 1 = 5000, Level 2 = 10000, Level 3 = 15000, ...
        let levelTotal    = p.currentLevel * GardenLevelProgress.pointsPerLevel
        let pointsLeft    = levelTotal - p.currentPoints

        levelTitleLabel?.text    = "Level \(p.currentLevel)"
        pointsToNextLabel?.text  = "\(pointsLeft) Points to next garden"
        currentPointsLabel?.text = "\(p.currentPoints)"
        totalPointsLabel?.text   = "\(levelTotal)"

        // Progress within this level: currentPoints / levelTotal
        let ratio = Float(p.currentPoints) / Float(levelTotal)
        UIView.animate(withDuration: 0.5) {
            self.levelProgressView?.setProgress(min(ratio, 1.0), animated: true)
        }
    }

    // MARK: - Notifications

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBaseChanged(_:)),
            name: .gardenBaseDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLevelChanged(_:)),
            name: .gardenLevelDidChange,
            object: nil
        )
    }

    @objc private func handleBaseChanged(_ note: Notification) {
        guard let base = note.object as? GardenBase else { return }
        gardenScene?.switchBase(to: base)
        itemCollectionView.reloadData()
    }

    @objc private func handleLevelChanged(_ note: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updateLevelCard()
            self?.itemCollectionView.reloadData()
        }
    }

    // MARK: - Gestures

    private func setupGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        gardenSKView.addGestureRecognizer(pinch)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView   = false
        gardenSKView.addGestureRecognizer(pan)
    }

    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        gardenScene?.handlePinch(sender)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        gardenScene?.handlePan(sender)
    }

    // MARK: - Collection View Setup

    private func setupCollectionView() {
        itemCollectionView.delegate    = self
        itemCollectionView.dataSource  = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.minimumLineSpacing      = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize                = CGSize(width: 85, height: 100)
        itemCollectionView.collectionViewLayout = layout
        itemCollectionView.showsHorizontalScrollIndicator = false
        itemCollectionView.showsVerticalScrollIndicator   = false
    }

    // MARK: - SpriteKit Setup

    private func setupSpriteKit() {
        let scene = GardenScene(size: gardenSKView.bounds.size)
        scene.scaleMode       = .resizeFill
        scene.backgroundColor = .clear
        scene.gardenManager   = gardenManager
        gardenSKView.presentScene(scene)
        gardenSKView.allowsTransparency = true
        self.gardenScene = scene
    }

    // MARK: - Store Button

    @IBAction func storeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
        if let storeVC = storyboard.instantiateViewController(
            withIdentifier: "StoreViewController") as? StoreViewController {
            self.navigationController?.pushViewController(storeVC, animated: true)
        }
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension GardenViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    private var trayItems: [StoreItem] {
        return gardenManager.trayItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return trayItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
            return UICollectionViewCell()
        }
        let items  = trayItems
        let item   = items[indexPath.item]
        let isLast = indexPath.item == items.count - 1
        cell.configure(with: item, isLast: isLast)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let item = trayItems[indexPath.item]

        // Tapping a base tile switches the active garden base
        if item.id.hasPrefix("base_") {
            if let base = gardenManager.allBases.first(where: {
                $0.id == item.baseId && $0.isUnlocked
            }) {
                gardenManager.selectBase(base)
            }
            return
        }

        // Tapping a regular item enters placement mode
        gardenScene?.enterPlacementMode(for: item.imageName)
    }
}

// MARK: - GardenScene

class GardenScene: SKScene {

    var gardenManager: GardenManager?
    var activePlacementNode: SKNode?
    var isDragging = false
    var gardenBaseNode: SKSpriteNode?

    let cameraNode = SKCameraNode()
    private var initialCameraScale: CGFloat = 1.0
    private var isPlacementValid: Bool = true
    private var loadedBaseId: String = "classic"

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupCamera()
        let baseId    = gardenManager?.selectedBase.id        ?? "classic"
        let imageName = gardenManager?.selectedBase.imageName ?? "garden_base"
        setupGardenBase(imageName: imageName)
        loadedBaseId = baseId
        restorePlacedItems(for: baseId)
    }

    func handleSceneSizeUpdate() {
        updateCameraPosition()
        if let base = gardenBaseNode { repositionBase(base) }
    }

    // MARK: - Base Switching

    func switchBase(to base: GardenBase) {
        guard base.id != loadedBaseId else { return }
        savePlacedItems(for: loadedBaseId)
        children.filter { $0.name == "placed_item" }.forEach { $0.removeFromParent() }
        cancelPlacement()
        gardenBaseNode?.removeFromParent()
        gardenBaseNode = nil
        setupGardenBase(imageName: base.imageName)
        loadedBaseId = base.id
        restorePlacedItems(for: base.id)
    }

    // MARK: - Placed Items Persistence

    private func savePlacedItems(for baseId: String) {
        var items: [PlacedItem] = []
        for node in children where node.name == "placed_item" {
            guard let sprite    = node as? SKSpriteNode,
                  let assetName = sprite.userData?["assetName"] as? String else { continue }
            items.append(PlacedItem(
                id: UUID().uuidString, imageName: assetName,
                positionX: sprite.position.x, positionY: sprite.position.y,
                zPosition: sprite.zPosition
            ))
        }
        gardenManager?.savePlacedItems(items, for: baseId)
    }

    private func restorePlacedItems(for baseId: String) {
        guard let items = gardenManager?.loadPlacedItems(for: baseId) else { return }
        for item in items {
            let sprite         = SKSpriteNode(imageNamed: item.imageName)
            sprite.position    = CGPoint(x: item.positionX, y: item.positionY)
            sprite.zPosition   = item.zPosition
            sprite.name        = "placed_item"
            sprite.userData    = ["assetName": item.imageName]
            sprite.setScale(0.15)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.2)
            addChild(sprite)
        }
    }

    // MARK: - Camera

    func updateCameraPosition() {
        if cameraNode.position == .zero {
            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        }
        constrainCamera()
    }

    private func setupCamera() {
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(cameraNode)
        self.camera = cameraNode
    }

    private func setupGardenBase(imageName: String) {
        if gardenBaseNode == nil {
            let base       = SKSpriteNode(imageNamed: imageName)
            base.name      = "garden_base"
            base.zPosition = -1
            addChild(base)
            self.gardenBaseNode = base
        }
        guard let base = gardenBaseNode else { return }
        repositionBase(base)
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        constrainCamera()
    }

    private func repositionBase(_ base: SKSpriteNode) {
        let t = base.texture?.size() ?? CGSize(width: 1, height: 1)
        base.setScale(max(self.size.width / t.width, self.size.height / t.height))
        base.position = CGPoint(x: frame.midX, y: frame.midY)
    }

    // MARK: - Zoom / Pan

    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began { initialCameraScale = cameraNode.xScale }
        let newScale = initialCameraScale / sender.scale
        if let base = gardenBaseNode {
            let maxPossible = min(base.size.width / self.size.width,
                                  base.size.height / self.size.height)
            cameraNode.setScale(max(0.4, min(newScale, maxPossible)))
        }
        constrainCamera()
    }

    func handlePan(_ sender: UIPanGestureRecognizer) {
        if isDragging { return }
        let t = sender.translation(in: self.view)
        cameraNode.position = CGPoint(
            x: cameraNode.position.x - t.x * cameraNode.xScale,
            y: cameraNode.position.y + t.y * cameraNode.yScale
        )
        constrainCamera()
        sender.setTranslation(.zero, in: self.view)
    }

    private func constrainCamera() {
        guard let base = gardenBaseNode else { return }
        let hw = max(0, (base.size.width  - self.size.width  * cameraNode.xScale) / 2)
        let hh = max(0, (base.size.height - self.size.height * cameraNode.yScale) / 2)
        let cx = base.position.x, cy = base.position.y
        cameraNode.position.x = max(cx - hw, min(cameraNode.position.x, cx + hw))
        cameraNode.position.y = max(cy - hh, min(cameraNode.position.y, cy + hh))
    }

    // MARK: - Placement Mode

    func enterPlacementMode(for imageName: String) {
        cancelPlacement()
        let container       = SKNode()
        container.position  = cameraNode.position
        container.zPosition = 1000
        container.name      = "placement_container"
        container.addChild(makeDiamondHighlight(valid: true))
        let item            = SKSpriteNode(imageNamed: imageName)
        item.name           = "moving_item"
        item.alpha          = 0.85
        item.userData       = ["assetName": imageName]
        item.setScale(0.15)
        item.anchorPoint    = CGPoint(x: 0.5, y: 0.2)
        container.addChild(item)
        addConfirmButtons(to: container)
        addChild(container)
        activePlacementNode = container
        isDragging          = true
        isPlacementValid    = true
        updateButtonStates(in: container, valid: true)
    }

    // MARK: - Move Mode

    private func enterMoveMode(for node: SKSpriteNode) {
        cancelPlacement()
        let container       = SKNode()
        container.position  = node.position
        container.zPosition = 1000
        container.name      = "placement_container"
        container.addChild(makeDiamondHighlight(valid: true))
        let item            = SKSpriteNode(imageNamed: node.userData?["assetName"] as? String ?? "")
        item.name           = "moving_item"
        item.alpha          = 0.85
        item.userData       = node.userData
        item.setScale(node.xScale)
        item.anchorPoint    = node.anchorPoint
        container.addChild(item)
        addDirectionalArrows(to: container)
        addConfirmButtons(to: container)
        node.removeFromParent()
        addChild(container)
        activePlacementNode = container
        isDragging          = false
        isPlacementValid    = true
        updateButtonStates(in: container, valid: true)
    }

    // MARK: - Diamond Highlight

    private func makeDiamondHighlight(valid: Bool) -> SKShapeNode {
        let d = SKShapeNode(), p = CGMutablePath()
        p.move(to: CGPoint(x: 0, y: 12)); p.addLine(to: CGPoint(x: 22, y: 0))
        p.addLine(to: CGPoint(x: 0, y: -12)); p.addLine(to: CGPoint(x: -22, y: 0))
        p.closeSubpath()
        d.path        = p
        d.fillColor   = valid ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
                               : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
        d.strokeColor = valid ? UIColor(red: 0.0,  green: 0.7,  blue: 0.0, alpha: 0.8)
                               : UIColor(red: 0.8,  green: 0.0,  blue: 0.0, alpha: 0.8)
        d.lineWidth = 1.5; d.zPosition = -0.5; d.name = "placement_highlight"
        return d
    }

    // MARK: - Confirm Buttons

    private func addConfirmButtons(to container: SKNode) {
        let cancelBtn       = makeRoundedButton(symbol: "✕",
            bgColor: UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1.0), size: 26)
        cancelBtn.position  = CGPoint(x: -30, y: 55); cancelBtn.name = "btn_cancel"
        container.addChild(cancelBtn)
        let confirmBtn      = makeRoundedButton(symbol: "✓",
            bgColor: UIColor(white: 0.55, alpha: 1.0), size: 26)
        confirmBtn.position = CGPoint(x: 30, y: 55); confirmBtn.name = "btn_confirm"
        container.addChild(confirmBtn)
    }

    private func makeRoundedButton(symbol: String, bgColor: UIColor, size: CGFloat) -> SKNode {
        let node = SKNode()
        let bg   = SKShapeNode(rectOf: CGSize(width: size * 1.9, height: size * 1.9),
                               cornerRadius: size * 0.4)
        bg.fillColor = bgColor; bg.strokeColor = UIColor.white.withAlphaComponent(0.3)
        bg.lineWidth = 1.5; bg.name = "button_bg"; node.addChild(bg)
        let lbl = SKLabelNode(text: symbol)
        lbl.fontName = "Helvetica-Bold"; lbl.fontSize = size * 0.75; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
        lbl.name = "button_label"; node.addChild(lbl)
        return node
    }

    private func updateButtonStates(in container: SKNode, valid: Bool) {
        if let h = container.childNode(withName: "placement_highlight") as? SKShapeNode {
            h.fillColor   = valid ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
                                  : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
            h.strokeColor = valid ? UIColor(red: 0.0,  green: 0.7,  blue: 0.0, alpha: 0.8)
                                  : UIColor(red: 0.8,  green: 0.0,  blue: 0.0, alpha: 0.8)
        }
        if let btn = container.childNode(withName: "btn_confirm"),
           let bg  = btn.childNode(withName: "button_bg") as? SKShapeNode {
            bg.fillColor = valid ? UIColor(red: 0.1, green: 0.75, blue: 0.1, alpha: 1.0)
                                 : UIColor(white: 0.55, alpha: 1.0)
        }
    }

    // MARK: - Overlap / Boundary

    private func radiusFor(_ node: SKNode) -> CGFloat {
        if let s = node as? SKSpriteNode { return s.size.width * 0.18 }
        if let s = node.childNode(withName: "moving_item") as? SKSpriteNode { return s.size.width * 0.18 }
        return 6
    }

    private func isOverlappingPlacedItem(at pos: CGPoint, excluding container: SKNode) -> Bool {
        let r = radiusFor(container)
        for node in children where node.name == "placed_item" && node !== container {
            if hypot(node.position.x - pos.x, node.position.y - pos.y) < r + radiusFor(node) { return true }
        }
        return false
    }

    private func isInsideGrassArea(_ pos: CGPoint) -> Bool {
        guard let base = gardenBaseNode else { return true }
        let cx  = base.position.x
        let cy  = base.position.y - base.size.height * base.yScale * 0.02
        let px  = pos.x - cx, py = pos.y - cy
        let hw  = base.size.width  * base.xScale * 0.80
        let hhu = base.size.height * base.yScale * 0.25
        let hhd = base.size.height * base.yScale * 0.13
        return (abs(px / hw) + abs(py / (py >= 0 ? hhu : hhd))) <= 1.0
    }

    // MARK: - Directional Arrows

    private func addDirectionalArrows(to container: SKNode) {
        let offset: CGFloat = 22, vs: CGFloat = 20
        [(CGFloat(0), CGFloat(0), offset + vs),
         (.pi, 0, -offset + vs), (.pi/2, -offset, vs), (-.pi/2, offset, vs)].forEach { r, dx, dy in
            let a = makeArrowNode(); a.zRotation = r; a.position = CGPoint(x: dx, y: dy)
            container.addChild(a)
        }
    }

    private func makeArrowNode() -> SKShapeNode {
        let a = SKShapeNode(), p = CGMutablePath()
        p.move(to: CGPoint(x: 0, y: 16))
        p.addLine(to: CGPoint(x: 12, y: 2)); p.addLine(to: CGPoint(x: 6, y: 2))
        p.addLine(to: CGPoint(x: 6, y: -12)); p.addLine(to: CGPoint(x: -6, y: -12))
        p.addLine(to: CGPoint(x: -6, y: 2)); p.addLine(to: CGPoint(x: -12, y: 2))
        p.closeSubpath()
        a.path = p
        a.fillColor   = UIColor(red: 0.15, green: 0.82, blue: 0.15, alpha: 1.0)
        a.strokeColor = UIColor(red: 0.05, green: 0.45, blue: 0.05, alpha: 1.0)
        a.lineWidth = 1.5; a.name = "placement_arrow"; a.isUserInteractionEnabled = false
        let up = SKAction.scale(to: 1.12, duration: 0.45)
        let dn = SKAction.scale(to: 0.92, duration: 0.45)
        up.timingMode = .easeInEaseOut; dn.timingMode = .easeInEaseOut
        a.run(SKAction.repeatForever(SKAction.sequence([up, dn])))
        return a
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc   = touch.location(in: self)
        let nodes = nodes(at: loc)
        if let active = activePlacementNode {
            for n in nodes {
                if n.name == "btn_cancel"  || n.parent?.name == "btn_cancel"  { cancelPlacement(); return }
                if n.name == "btn_confirm" || n.parent?.name == "btn_confirm" { if isPlacementValid { confirmPlacement() }; return }
            }
            for n in nodes where n.name == "moving_item" || n.parent == active { isDragging = true; return }
            if isPlacementValid { confirmPlacement() }
            return
        }
        for n in nodes {
            if n.name == "placed_item", let s = n as? SKSpriteNode { enterMoveMode(for: s); isDragging = false; return }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let c = activePlacementNode else { return }
        isDragging = true
        c.children.filter { $0.name == "placement_arrow" }.forEach { $0.isHidden = true }
        let pos = touch.location(in: self)
        c.position   = pos
        isPlacementValid = isInsideGrassArea(pos) && !isOverlappingPlacedItem(at: pos, excluding: c)
        updateButtonStates(in: c, valid: isPlacementValid)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        isDragging = false
        activePlacementNode?.children.filter { $0.name == "placement_arrow" }.forEach { $0.isHidden = false }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { isDragging = false }

    // MARK: - Confirm / Cancel

    func confirmPlacement() {
        guard isPlacementValid,
              let c     = activePlacementNode,
              let ghost = c.childNode(withName: "moving_item") as? SKSpriteNode else { cancelPlacement(); return }
        let assetName = ghost.userData?["assetName"] as? String ?? ""
        let f         = SKSpriteNode(imageNamed: assetName)
        f.position    = c.position; f.anchorPoint = ghost.anchorPoint
        f.setScale(ghost.xScale); f.name = "placed_item"
        f.userData    = ["assetName": assetName]
        f.zPosition   = 1000 - c.position.y; f.alpha = 1.0
        addChild(f); cancelPlacement()
        savePlacedItems(for: loadedBaseId)
    }

    func cancelPlacement() {
        activePlacementNode?.removeFromParent()
        activePlacementNode = nil; isDragging = false; isPlacementValid = true
    }

    override func willMove(from view: SKView) {
        savePlacedItems(for: loadedBaseId)
    }
}
