import UIKit
import SpriteKit

class GardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var gardenSKView: SKView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var storeButton: UIButton!
    
    var gardenScene: GardenScene?
    private let gardenManager = GardenManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSpriteKit()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemCollectionView.reloadData()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Healing Garden"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let scene = gardenScene {
            if scene.size != gardenSKView.bounds.size {
                scene.size = gardenSKView.bounds.size
                scene.handleSceneSizeUpdate()
            }
        }
    }

    private func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        gardenSKView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.cancelsTouchesInView = false
        gardenSKView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        gardenScene?.handlePinch(sender)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        gardenScene?.handlePan(sender)
    }

    private func setupCollectionView() {
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 85, height: 100)
        itemCollectionView.collectionViewLayout = layout
        itemCollectionView.showsHorizontalScrollIndicator = false
        itemCollectionView.showsVerticalScrollIndicator = false
    }

    private func setupSpriteKit() {
        let scene = GardenScene(size: gardenSKView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        gardenSKView.presentScene(scene)
        gardenSKView.allowsTransparency = true
        self.gardenScene = scene
    }

    @IBAction func storeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
            self.navigationController?.pushViewController(storeVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gardenManager.unlockedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
            return UICollectionViewCell()
        }
        let item = gardenManager.unlockedItems[indexPath.item]
        let isLast = indexPath.item == gardenManager.unlockedItems.count - 1
        cell.configure(with: item, isLast: isLast)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = gardenManager.unlockedItems[indexPath.item]
        gardenScene?.enterPlacementMode(for: item.imageName)
    }
}

// MARK: - Garden SpriteKit Scene
class GardenScene: SKScene {
    var activePlacementNode: SKNode?
    var isDragging = false
    var gardenBaseNode: SKSpriteNode?
    
    let cameraNode = SKCameraNode()
    private var initialCameraScale: CGFloat = 1.0

    private var isPlacementValid: Bool = true

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupCamera()
        setupGardenBase()
    }
    
    func handleSceneSizeUpdate() {
        updateCameraPosition()
        setupGardenBase()
    }
    
    func updateCameraPosition() {
        if cameraNode.position == .zero {
            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        }
        constrainCamera()
    }
    
    private func setupCamera() {
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(cameraNode)
        self.camera = cameraNode
    }
    
    private func setupGardenBase() {
        if gardenBaseNode == nil {
            let base = SKSpriteNode(imageNamed: "garden_base")
            base.name = "garden_base"
            base.zPosition = -1
            addChild(base)
            self.gardenBaseNode = base
        }
        
        guard let base = gardenBaseNode else { return }
        let textureSize = base.texture?.size() ?? CGSize(width: 1, height: 1)
        let scaleX = self.size.width / textureSize.width
        let scaleY = self.size.height / textureSize.height
        let scaleFactor = max(scaleX, scaleY)
        base.setScale(scaleFactor)
        base.position = CGPoint(x: frame.midX, y: frame.midY)

        // Reset camera to center then constrain
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        constrainCamera()
    }

    // MARK: - Zoom and Pan
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            initialCameraScale = cameraNode.xScale
        }
        let newScale = initialCameraScale / sender.scale
        if let base = gardenBaseNode {
            let maxScaleX = base.size.width / self.size.width
            let maxScaleY = base.size.height / self.size.height
            let maxPossibleScale = min(maxScaleX, maxScaleY)
            let clampedScale = max(0.4, min(newScale, maxPossibleScale))
            cameraNode.setScale(clampedScale)
        }
        constrainCamera()
    }

    func handlePan(_ sender: UIPanGestureRecognizer) {
        if isDragging { return }
        let translation = sender.translation(in: self.view)
        let dx = translation.x * cameraNode.xScale
        let dy = translation.y * cameraNode.yScale
        cameraNode.position = CGPoint(
            x: cameraNode.position.x - dx,
            y: cameraNode.position.y + dy
        )
        constrainCamera()
        sender.setTranslation(.zero, in: self.view)
    }
    
    private func constrainCamera() {
        guard let base = gardenBaseNode else { return }

        let camXScale = cameraNode.xScale
        let camYScale = cameraNode.yScale

        // How much of the scene is visible at current zoom
        let visibleWidth  = self.size.width  * camXScale
        let visibleHeight = self.size.height * camYScale

        // The actual rendered size of the base sprite (size already includes setScale)
        let baseWidth  = base.size.width
        let baseHeight = base.size.height

        // How far the camera can move from center before revealing outside the base
        let halfWidthDiff  = max(0, (baseWidth  - visibleWidth)  / 2)
        let halfHeightDiff = max(0, (baseHeight - visibleHeight) / 2)

        let cx = base.position.x
        let cy = base.position.y

        cameraNode.position.x = max(cx - halfWidthDiff,  min(cameraNode.position.x, cx + halfWidthDiff))
        cameraNode.position.y = max(cy - halfHeightDiff, min(cameraNode.position.y, cy + halfHeightDiff))
    }
    
    // MARK: - Placement Mode (from tray)
    func enterPlacementMode(for imageName: String) {
        cancelPlacement()

        let container = SKNode()
        container.position = cameraNode.position
        container.zPosition = 1000
        container.name = "placement_container"

        let highlight = makeDiamondHighlight(valid: true)
        highlight.name = "placement_highlight"
        container.addChild(highlight)

        let item = SKSpriteNode(imageNamed: imageName)
        item.name = "moving_item"
        item.alpha = 0.85
        item.userData = ["assetName": imageName]
        item.setScale(0.15)
        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        container.addChild(item)

        addConfirmButtons(to: container)

        addChild(container)
        activePlacementNode = container
        isDragging = true

        isPlacementValid = true
        updateButtonStates(in: container, valid: true)
    }
    
    // MARK: - Move Mode (tap already-placed item)
    private func enterMoveMode(for node: SKSpriteNode) {
        cancelPlacement()

        let container = SKNode()
        container.position = node.position
        container.zPosition = 1000
        container.name = "placement_container"

        let highlight = makeDiamondHighlight(valid: true)
        highlight.name = "placement_highlight"
        container.addChild(highlight)

        let item = SKSpriteNode(imageNamed: node.userData?["assetName"] as? String ?? "")
        item.name = "moving_item"
        item.alpha = 0.85
        item.userData = node.userData
        item.setScale(node.xScale)
        item.anchorPoint = node.anchorPoint
        container.addChild(item)

        addDirectionalArrows(to: container)
        addConfirmButtons(to: container)

        node.removeFromParent()
        addChild(container)
        activePlacementNode = container
        isDragging = false

        isPlacementValid = true
        updateButtonStates(in: container, valid: true)
    }

    // MARK: - Diamond highlight under item
    private func makeDiamondHighlight(valid: Bool) -> SKShapeNode {
        let diamond = SKShapeNode()
        let path = CGMutablePath()
        let w: CGFloat = 22
        let h: CGFloat = 12
        path.move(to: CGPoint(x: 0,  y:  h))
        path.addLine(to: CGPoint(x:  w, y: 0))
        path.addLine(to: CGPoint(x: 0,  y: -h))
        path.addLine(to: CGPoint(x: -w, y: 0))
        path.closeSubpath()
        diamond.path = path
        diamond.fillColor   = valid
            ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
            : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
        diamond.strokeColor = valid
            ? UIColor(red: 0.0, green: 0.7,  blue: 0.0, alpha: 0.8)
            : UIColor(red: 0.8, green: 0.0,  blue: 0.0, alpha: 0.8)
        diamond.lineWidth  = 1.5
        diamond.zPosition  = -0.5
        diamond.name       = "placement_highlight"
        return diamond
    }

    // MARK: - CoC-style Cross + Tick buttons
    private func addConfirmButtons(to container: SKNode) {
        let buttonY: CGFloat = 55
        let spacing: CGFloat = 30

        let cancelBtn = makeRoundedButton(
            symbol: "✕",
            bgColor: UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1.0),
            size: 26
        )
        cancelBtn.position = CGPoint(x: -spacing, y: buttonY)
        cancelBtn.name = "btn_cancel"
        container.addChild(cancelBtn)

        let confirmBtn = makeRoundedButton(
            symbol: "✓",
            bgColor: UIColor(white: 0.55, alpha: 1.0),
            size: 26
        )
        confirmBtn.position = CGPoint(x: spacing, y: buttonY)
        confirmBtn.name = "btn_confirm"
        container.addChild(confirmBtn)
    }

    private func makeRoundedButton(symbol: String, bgColor: UIColor, size: CGFloat) -> SKNode {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: CGSize(width: size * 1.9, height: size * 1.9), cornerRadius: size * 0.4)
        bg.fillColor   = bgColor
        bg.strokeColor = UIColor.white.withAlphaComponent(0.3)
        bg.lineWidth   = 1.5
        bg.name        = "button_bg"
        node.addChild(bg)
        let label = SKLabelNode(text: symbol)
        label.fontName  = "Helvetica-Bold"
        label.fontSize  = size * 0.75
        label.fontColor = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.name     = "button_label"
        node.addChild(label)
        return node
    }

    private func updateButtonStates(in container: SKNode, valid: Bool) {
        if let highlight = container.childNode(withName: "placement_highlight") as? SKShapeNode {
            highlight.fillColor   = valid
                ? UIColor(red: 0.0,  green: 0.85, blue: 0.0, alpha: 0.35)
                : UIColor(red: 0.95, green: 0.1,  blue: 0.1, alpha: 0.45)
            highlight.strokeColor = valid
                ? UIColor(red: 0.0, green: 0.7,  blue: 0.0, alpha: 0.8)
                : UIColor(red: 0.8, green: 0.0,  blue: 0.0, alpha: 0.8)
        }
        if let confirmBtn = container.childNode(withName: "btn_confirm"),
           let bg = confirmBtn.childNode(withName: "button_bg") as? SKShapeNode {
            bg.fillColor = valid
                ? UIColor(red: 0.1, green: 0.75, blue: 0.1, alpha: 1.0)
                : UIColor(white: 0.55, alpha: 1.0)
        }
    }

    // MARK: - Overlap Detection
    private func radiusFor(_ node: SKNode) -> CGFloat {
        if let sprite = node as? SKSpriteNode {
            return sprite.size.width * 0.18
        }
        if let sprite = node.childNode(withName: "moving_item") as? SKSpriteNode {
            return sprite.size.width * 0.18
        }
        return 6
    }

    private func isOverlappingPlacedItem(at position: CGPoint, excluding container: SKNode) -> Bool {
        let movingRadius = radiusFor(container)
        for node in children {
            guard node.name == "placed_item", node !== container else { continue }
            let placedRadius = radiusFor(node)
            let minDist = movingRadius + placedRadius
            let dist = hypot(node.position.x - position.x, node.position.y - position.y)
            if dist < minDist { return true }
        }
        return false
    }

    // MARK: - Grass Area Boundary Check
    private func isInsideGrassArea(_ position: CGPoint) -> Bool {
        guard let base = gardenBaseNode else { return true }

        let cx = base.position.x
        let cy = base.position.y - base.size.height * base.yScale * 0.02

        let halfH_up    = base.size.height * base.yScale * 0.25
        let halfH_down  = base.size.height * base.yScale * 0.13
        let halfW_left  = base.size.width  * base.xScale * 0.80
        let halfW_right = base.size.width  * base.xScale * 0.80

        let px = position.x - cx
        let py = position.y - cy

        let halfW = px >= 0 ? halfW_right : halfW_left
        let halfH = py >= 0 ? halfH_up    : halfH_down

        let u = px / halfW
        let v = py / halfH

        return (abs(u) + abs(v)) <= 1.0
    }

    // MARK: - Directional Arrows
    private func addDirectionalArrows(to container: SKNode) {
        let offset: CGFloat = 22
        let verticalShift: CGFloat = 20
        let arrowConfigs: [(rotation: CGFloat, dx: CGFloat, dy: CGFloat)] = [
            (0,          0,       offset + verticalShift),
            (.pi,        0,      -offset + verticalShift),
            (.pi / 2,   -offset,           verticalShift),
            (-.pi / 2,   offset,           verticalShift)
        ]
        for config in arrowConfigs {
            let arrow = makeArrowNode()
            arrow.zRotation = config.rotation
            arrow.position  = CGPoint(x: config.dx, y: config.dy)
            container.addChild(arrow)
        }
    }

    private func makeArrowNode() -> SKShapeNode {
        let arrow = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0,    y:  16))
        path.addLine(to: CGPoint(x:  12, y:  2))
        path.addLine(to: CGPoint(x:   6, y:  2))
        path.addLine(to: CGPoint(x:   6, y: -12))
        path.addLine(to: CGPoint(x:  -6, y: -12))
        path.addLine(to: CGPoint(x:  -6, y:  2))
        path.addLine(to: CGPoint(x: -12, y:  2))
        path.closeSubpath()
        arrow.path        = path
        arrow.fillColor   = UIColor(red: 0.15, green: 0.82, blue: 0.15, alpha: 1.0)
        arrow.strokeColor = UIColor(red: 0.05, green: 0.45, blue: 0.05, alpha: 1.0)
        arrow.lineWidth   = 1.5
        arrow.name        = "placement_arrow"
        arrow.isUserInteractionEnabled = false
        let pulseUp   = SKAction.scale(to: 1.12, duration: 0.45)
        let pulseDown = SKAction.scale(to: 0.92, duration: 0.45)
        pulseUp.timingMode   = .easeInEaseOut
        pulseDown.timingMode = .easeInEaseOut
        arrow.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        return arrow
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location     = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        if let active = activePlacementNode {
            for node in touchedNodes {
                if node.name == "btn_cancel" || node.parent?.name == "btn_cancel" {
                    cancelPlacement()
                    return
                }
                if node.name == "btn_confirm" || node.parent?.name == "btn_confirm" {
                    if isPlacementValid { confirmPlacement() }
                    return
                }
            }
            for node in touchedNodes {
                if node.name == "moving_item" || node.parent == active {
                    isDragging = true
                    return
                }
            }
            if isPlacementValid { confirmPlacement() }
            return
        }

        for node in touchedNodes {
            if node.name == "placed_item", let sprite = node as? SKSpriteNode {
                enterMoveMode(for: sprite)
                isDragging = false
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let container = activePlacementNode else { return }
        isDragging = true

        container.children
            .filter { $0.name == "placement_arrow" }
            .forEach { $0.isHidden = true }

        // Free placement — item follows finger exactly
        let touchPos = touch.location(in: self)
        container.position = touchPos

        // Valid only if inside grass AND not overlapping another item
        let insideGrass  = isInsideGrassArea(touchPos)
        let overlapping  = isOverlappingPlacedItem(at: touchPos, excluding: container)
        isPlacementValid = insideGrass && !overlapping

        updateButtonStates(in: container, valid: isPlacementValid)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        isDragging = false
        if let container = activePlacementNode {
            container.children
                .filter { $0.name == "placement_arrow" }
                .forEach { $0.isHidden = false }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

    // MARK: - Confirm / Cancel
    func confirmPlacement() {
        guard isPlacementValid else { return }
        guard let container = activePlacementNode,
              let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else {
            cancelPlacement()
            return
        }
        let assetName = ghost.userData?["assetName"] as? String ?? ""
        let finalItem = SKSpriteNode(imageNamed: assetName)
        finalItem.position    = container.position
        finalItem.anchorPoint = ghost.anchorPoint
        finalItem.setScale(ghost.xScale)
        finalItem.name        = "placed_item"
        finalItem.userData    = ["assetName": assetName]
        finalItem.zPosition   = 1000 - container.position.y
        finalItem.alpha       = 1.0
        addChild(finalItem)
        cancelPlacement()
    }
    
    func cancelPlacement() {
        activePlacementNode?.removeFromParent()
        activePlacementNode = nil
        isDragging          = false
        isPlacementValid    = true
    }
}
