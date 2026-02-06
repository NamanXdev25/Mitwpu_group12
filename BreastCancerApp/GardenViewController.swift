//import UIKit
//import SpriteKit
//
//class GardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    @IBOutlet weak var gardenSKView: SKView!
//    @IBOutlet weak var itemCollectionView: UICollectionView!
//    @IBOutlet weak var storeButton: UIButton!
//    
//    var gardenScene: GardenScene?
//    private let gardenManager = GardenManager.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupSpriteKit()
//        setupGestures()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        itemCollectionView.reloadData()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Ensure the scene and camera are updated if the SKView layout changes
//        if let scene = gardenScene, scene.size != gardenSKView.bounds.size {
//            scene.size = gardenSKView.bounds.size
//            scene.updateCameraPosition()
//        }
//    }
//
//    private func setupGestures() {
//        // Pinch for Zooming
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        gardenSKView.addGestureRecognizer(pinchGesture)
//        
//        // Pan for moving the camera
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        // Allow 1 finger to pan the map
//        panGesture.minimumNumberOfTouches = 1
//        // Allow touches to pass through to SpriteKit for item dragging
//        panGesture.cancelsTouchesInView = false
//        gardenSKView.addGestureRecognizer(panGesture)
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
//    private func setupCollectionView() {
//        itemCollectionView.delegate = self
//        itemCollectionView.dataSource = self
//        
//        if let layout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumLineSpacing = 0
//            layout.itemSize = CGSize(width: 90, height: 100)
//        }
//    }
//
//    private func setupSpriteKit() {
//        let scene = GardenScene(size: gardenSKView.bounds.size)
//        scene.scaleMode = .resizeFill
//        scene.backgroundColor = .clear
//        gardenSKView.presentScene(scene)
//        gardenSKView.allowsTransparency = true
//        self.gardenScene = scene
//    }
//
//    @IBAction func storeButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
//        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
//            self.navigationController?.pushViewController(storeVC, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return gardenManager.unlockedItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
//            return UICollectionViewCell()
//        }
//        let item = gardenManager.unlockedItems[indexPath.item]
//        let isLast = indexPath.item == gardenManager.unlockedItems.count - 1
//        cell.configure(with: item, isLast: isLast)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = gardenManager.unlockedItems[indexPath.item]
//        gardenScene?.enterPlacementMode(for: item.imageName)
//    }
//}
//
//// MARK: - Garden SpriteKit Scene
//class GardenScene: SKScene {
//    var activePlacementNode: SKNode?
//    var isDragging = false
//    var gardenBaseNode: SKSpriteNode?
//    
//    let cameraNode = SKCameraNode()
//    private var initialCameraScale: CGFloat = 1.0
//    
//    override func didMove(to view: SKView) {
//        setupCamera()
//        setupGardenBase()
//    }
//    
//    func updateCameraPosition() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        constrainCamera()
//    }
//    
//    private func setupCamera() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(cameraNode)
//        self.camera = cameraNode
//    }
//    
//    private func setupGardenBase() {
//        let base = SKSpriteNode(imageNamed: "garden_base")
//        base.name = "garden_base"
//        
//        // Initial scaling: Use Aspect Fill (max) to ensure it covers the screen
//        let scaleX = self.size.width / base.size.width
//        let scaleY = self.size.height / base.size.height
//        let scaleFactor = max(scaleX, scaleY)
//        base.setScale(scaleFactor)
//        
//        base.position = CGPoint(x: frame.midX, y: frame.midY)
//        base.zPosition = -1
//        
//        addChild(base)
//        self.gardenBaseNode = base
//        
//        // Immediate constraint check
//        constrainCamera()
//    }
//
//    // MARK: - Zoom and Pan Logic
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        if sender.state == .began {
//            initialCameraScale = cameraNode.xScale
//        }
//        
//        let newScale = initialCameraScale / sender.scale
//        
//        // Dynamic Zoom Limit: Prevent zooming out beyond the base size
//        if let base = gardenBaseNode {
//            let maxScaleX = base.size.width / self.size.width
//            let maxScaleY = base.size.height / self.size.height
//            // We use the minimum ratio to ensure no void is shown on any axis
//            let maxPossibleScale = min(maxScaleX, maxScaleY)
//            
//            let clampedScale = max(0.4, min(newScale, maxPossibleScale))
//            cameraNode.setScale(clampedScale)
//        }
//        
//        constrainCamera()
//    }
//
//    func handlePan(_ sender: UIPanGestureRecognizer) {
//        // Only pan the map if we aren't dragging a specific garden item
//        if isDragging { return }
//        
//        let translation = sender.translation(in: self.view)
//        
//        // Convert screen movement to scene movement
//        let dx = translation.x * cameraNode.xScale
//        let dy = translation.y * cameraNode.yScale
//        
//        // Update position: Y is inverted between UIKit and SpriteKit
//        let targetX = cameraNode.position.x - dx
//        let targetY = cameraNode.position.y + dy
//        
//        cameraNode.position = CGPoint(x: targetX, y: targetY)
//        constrainCamera()
//        
//        sender.setTranslation(.zero, in: self.view)
//    }
//    
//    /// Bounding logic to keep camera view strictly within the garden base bounds
//    private func constrainCamera() {
//        guard let base = gardenBaseNode else { return }
//        
//        // Current camera zoom level
//        let xScale = cameraNode.xScale
//        let yScale = cameraNode.yScale
//        
//        // Visible dimensions of the scene
//        let visibleWidth = self.size.width * xScale
//        let visibleHeight = self.size.height * yScale
//        
//        // Calculate boundaries for the camera's center
//        // The camera's center cannot move further than (TotalSize - VisibleSize) / 2 from the base center
//        let halfWidthDiff = (base.size.width - visibleWidth) / 2
//        let halfHeightDiff = (base.size.height - visibleHeight) / 2
//        
//        // Ensure values are at least 0 (in case base is smaller than view)
//        let limitX = max(0, halfWidthDiff)
//        let limitY = max(0, halfHeightDiff)
//        
//        let minX = base.position.x - limitX
//        let maxX = base.position.x + limitX
//        let minY = base.position.y - limitY
//        let maxY = base.position.y + limitY
//        
//        var newX = cameraNode.position.x
//        var newY = cameraNode.position.y
//        
//        // Clamp Horizontal
//        newX = max(minX, min(newX, maxX))
//        
//        // Clamp Vertical
//        newY = max(minY, min(newY, maxY))
//        
//        cameraNode.position = CGPoint(x: newX, y: newY)
//    }
//    
//    func enterPlacementMode(for imageName: String) {
//        cancelPlacement()
//        let container = SKNode()
//        container.position = cameraNode.position
//        container.zPosition = 1000
//        
//        let item = SKSpriteNode(imageNamed: imageName)
//        item.name = "moving_item"
//        item.alpha = 0.7
//        item.userData = ["assetName": imageName]
//        
//        if let baseScale = gardenBaseNode?.xScale {
//            item.setScale(baseScale)
//        }
//        
//        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
//        container.addChild(item)
//        
//        addUIButtons(to: container)
//        addChild(container)
//        activePlacementNode = container
//    }
//    
//    private func addUIButtons(to container: SKNode) {
//        let tick = SKSpriteNode(imageNamed: "button_tick")
//        tick.name = "btn_confirm"; tick.position = CGPoint(x: 60, y: -60)
//        container.addChild(tick)
//        let cross = SKSpriteNode(imageNamed: "button_cross")
//        cross.name = "btn_cancel"; cross.position = CGPoint(x: -60, y: -60)
//        container.addChild(cross)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let touchedNodes = nodes(at: location)
//        
//        for node in touchedNodes {
//            if node.name == "btn_confirm" { confirmPlacement(); return }
//            else if node.name == "btn_cancel" { cancelPlacement(); return }
//            else if node.name == "moving_item" || node.parent == activePlacementNode {
//                isDragging = true
//                return
//            }
//        }
//        
//        for node in touchedNodes {
//            if node.name == "placed_item" {
//                isDragging = true
//                let asset = node.userData?["assetName"] as? String ?? ""
//                let pos = node.position
//                node.removeFromParent()
//                enterPlacementMode(for: asset)
//                activePlacementNode?.position = pos
//                return
//            }
//        }
//        
//        isDragging = false
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isDragging, let touch = touches.first, let node = activePlacementNode else { return }
//        node.position = touch.location(in: self)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    func confirmPlacement() {
//        guard let container = activePlacementNode, let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else { return }
//        let assetName = ghost.userData?["assetName"] as? String ?? ""
//        let finalItem = SKSpriteNode(imageNamed: assetName)
//        finalItem.position = container.position
//        finalItem.anchorPoint = ghost.anchorPoint
//        finalItem.setScale(ghost.xScale)
//        finalItem.name = "placed_item"; finalItem.userData = ["assetName": assetName]
//        finalItem.zPosition = 1000 - container.position.y
//        addChild(finalItem); cancelPlacement()
//    }
//    
//    func cancelPlacement() {
//        activePlacementNode?.removeFromParent()
//        activePlacementNode = nil
//        isDragging = false
//    }
//}

//import UIKit
//import SpriteKit
//
//class GardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    @IBOutlet weak var gardenSKView: SKView!
//    @IBOutlet weak var itemCollectionView: UICollectionView!
//    @IBOutlet weak var storeButton: UIButton!
//    
//    var gardenScene: GardenScene?
//    private let gardenManager = GardenManager.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupSpriteKit()
//        setupGestures()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        itemCollectionView.reloadData()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Ensure the scene and camera are updated if the SKView layout changes
//        if let scene = gardenScene {
//            if scene.size != gardenSKView.bounds.size {
//                scene.size = gardenSKView.bounds.size
//                scene.handleSceneSizeUpdate()
//            }
//        }
//    }
//
//    private func setupGestures() {
//        // Pinch for Zooming
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        gardenSKView.addGestureRecognizer(pinchGesture)
//        
//        // Pan for moving the camera
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.cancelsTouchesInView = false
//        gardenSKView.addGestureRecognizer(panGesture)
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
//    private func setupCollectionView() {
//        itemCollectionView.delegate = self
//        itemCollectionView.dataSource = self
//        
//        if let layout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumLineSpacing = 0
//            layout.itemSize = CGSize(width: 90, height: 100)
//        }
//    }
//
//    private func setupSpriteKit() {
//        let scene = GardenScene(size: gardenSKView.bounds.size)
//        scene.scaleMode = .resizeFill
//        scene.backgroundColor = .clear
//        gardenSKView.presentScene(scene)
//        gardenSKView.allowsTransparency = true
//        self.gardenScene = scene
//    }
//
//    @IBAction func storeButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
//        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
//            self.navigationController?.pushViewController(storeVC, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return gardenManager.unlockedItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
//            return UICollectionViewCell()
//        }
//        let item = gardenManager.unlockedItems[indexPath.item]
//        let isLast = indexPath.item == gardenManager.unlockedItems.count - 1
//        cell.configure(with: item, isLast: isLast)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = gardenManager.unlockedItems[indexPath.item]
//        gardenScene?.enterPlacementMode(for: item.imageName)
//    }
//}
//
//// MARK: - Garden SpriteKit Scene
//class GardenScene: SKScene {
//    var activePlacementNode: SKNode?
//    var isDragging = false
//    var gardenBaseNode: SKSpriteNode?
//    
//    let cameraNode = SKCameraNode()
//    private var initialCameraScale: CGFloat = 1.0
//    
//    override func didMove(to view: SKView) {
//        setupCamera()
//        setupGardenBase()
//    }
//    
//    func handleSceneSizeUpdate() {
//        updateCameraPosition()
//        setupGardenBase() // Recalculate scale if view size changes
//    }
//    
//    func updateCameraPosition() {
//        // Only reset to center if not already positioned, otherwise just constrain
//        if cameraNode.position == .zero {
//            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        }
//        constrainCamera()
//    }
//    
//    private func setupCamera() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(cameraNode)
//        self.camera = cameraNode
//    }
//    
//    private func setupGardenBase() {
//        if gardenBaseNode == nil {
//            let base = SKSpriteNode(imageNamed: "garden_base")
//            base.name = "garden_base"
//            base.zPosition = -1
//            addChild(base)
//            self.gardenBaseNode = base
//        }
//        
//        guard let base = gardenBaseNode else { return }
//        let textureSize = base.texture?.size() ?? CGSize(width: 1, height: 1)
//        
//        // Aspect Fill logic: ensure it covers the whole screen initially
//        let scaleX = self.size.width / textureSize.width
//        let scaleY = self.size.height / textureSize.height
//        let scaleFactor = max(scaleX, scaleY)
//        
//        base.setScale(scaleFactor)
//        base.position = CGPoint(x: frame.midX, y: frame.midY)
//        
//        constrainCamera()
//    }
//
//    // MARK: - Zoom and Pan Logic
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        if sender.state == .began {
//            initialCameraScale = cameraNode.xScale
//        }
//        
//        let newScale = initialCameraScale / sender.scale
//        
//        if let base = gardenBaseNode {
//            // maxScale ensures the visible area never exceeds the garden's height or width
//            let maxScaleX = base.size.width / self.size.width
//            let maxScaleY = base.size.height / self.size.height
//            let maxPossibleScale = min(maxScaleX, maxScaleY)
//            
//            let clampedScale = max(0.4, min(newScale, maxPossibleScale))
//            cameraNode.setScale(clampedScale)
//        }
//        
//        constrainCamera()
//    }
//
//    func handlePan(_ sender: UIPanGestureRecognizer) {
//        if isDragging { return }
//        
//        let translation = sender.translation(in: self.view)
//        
//        let dx = translation.x * cameraNode.xScale
//        let dy = translation.y * cameraNode.yScale
//        
//        // Update camera: Y is up in SpriteKit, translation.y is down in UIKit
//        let targetX = cameraNode.position.x - dx
//        let targetY = cameraNode.position.y + dy
//        
//        cameraNode.position = CGPoint(x: targetX, y: targetY)
//        constrainCamera()
//        
//        sender.setTranslation(.zero, in: self.view)
//    }
//    
//    private func constrainCamera() {
//        guard let base = gardenBaseNode else { return }
//        
//        let xScale = cameraNode.xScale
//        let yScale = cameraNode.yScale
//        
//        // Current visible area dimensions
//        let visibleWidth = self.size.width * xScale
//        let visibleHeight = self.size.height * yScale
//        
//        // Calculate the maximum allowed offset from the center
//        let halfWidthDiff = (base.size.width - visibleWidth) / 2
//        let halfHeightDiff = (base.size.height - visibleHeight) / 2
//        
//        // If the base is smaller than the screen (shouldn't happen with our zoom clamp), lock to center
//        let limitX = max(0, halfWidthDiff)
//        let limitY = max(0, halfHeightDiff)
//        
//        let minX = base.position.x - limitX
//        let maxX = base.position.x + limitX
//        let minY = base.position.y - limitY
//        let maxY = base.position.y + limitY
//        
//        var newX = cameraNode.position.x
//        var newY = cameraNode.position.y
//        
//        // Hard clamping on both axes
//        newX = max(minX, min(newX, maxX))
//        newY = max(minY, min(newY, maxY))
//        
//        cameraNode.position = CGPoint(x: newX, y: newY)
//    }
//    
//    func enterPlacementMode(for imageName: String) {
//        cancelPlacement()
//        let container = SKNode()
//        container.position = cameraNode.position
//        container.zPosition = 1000
//        
//        let item = SKSpriteNode(imageNamed: imageName)
//        item.name = "moving_item"
//        item.alpha = 0.7
//        item.userData = ["assetName": imageName]
//        
//        if let baseScale = gardenBaseNode?.xScale {
//            item.setScale(baseScale)
//        }
//        
//        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
//        container.addChild(item)
//        
//        addUIButtons(to: container)
//        addChild(container)
//        activePlacementNode = container
//    }
//    
//    private func addUIButtons(to container: SKNode) {
//        let tick = SKSpriteNode(imageNamed: "button_tick")
//        tick.name = "btn_confirm"; tick.position = CGPoint(x: 60, y: -60)
//        container.addChild(tick)
//        let cross = SKSpriteNode(imageNamed: "button_cross")
//        cross.name = "btn_cancel"; cross.position = CGPoint(x: -60, y: -60)
//        container.addChild(cross)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let touchedNodes = nodes(at: location)
//        
//        for node in touchedNodes {
//            if node.name == "btn_confirm" { confirmPlacement(); return }
//            else if node.name == "btn_cancel" { cancelPlacement(); return }
//            else if node.name == "moving_item" || node.parent == activePlacementNode {
//                isDragging = true
//                return
//            }
//        }
//        
//        for node in touchedNodes {
//            if node.name == "placed_item" {
//                isDragging = true
//                let asset = node.userData?["assetName"] as? String ?? ""
//                let pos = node.position
//                node.removeFromParent()
//                enterPlacementMode(for: asset)
//                activePlacementNode?.position = pos
//                return
//            }
//        }
//        
//        isDragging = false
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isDragging, let touch = touches.first, let node = activePlacementNode else { return }
//        node.position = touch.location(in: self)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    func confirmPlacement() {
//        guard let container = activePlacementNode, let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else { return }
//        let assetName = ghost.userData?["assetName"] as? String ?? ""
//        let finalItem = SKSpriteNode(imageNamed: assetName)
//        finalItem.position = container.position
//        finalItem.anchorPoint = ghost.anchorPoint
//        finalItem.setScale(ghost.xScale)
//        finalItem.name = "placed_item"; finalItem.userData = ["assetName": assetName]
//        finalItem.zPosition = 1000 - container.position.y
//        addChild(finalItem); cancelPlacement()
//    }
//    
//    func cancelPlacement() {
//        activePlacementNode?.removeFromParent()
//        activePlacementNode = nil
//        isDragging = false
//    }
//}

//import UIKit
//import SpriteKit
//
//class GardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    @IBOutlet weak var gardenSKView: SKView!
//    @IBOutlet weak var itemCollectionView: UICollectionView!
//    @IBOutlet weak var storeButton: UIButton!
//    
//    var gardenScene: GardenScene?
//    private let gardenManager = GardenManager.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupSpriteKit()
//        setupGestures()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        itemCollectionView.reloadData()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Ensure the scene and camera are updated if the SKView layout changes
//        if let scene = gardenScene {
//            if scene.size != gardenSKView.bounds.size {
//                scene.size = gardenSKView.bounds.size
//                scene.handleSceneSizeUpdate()
//            }
//        }
//    }
//
//    private func setupGestures() {
//        // Pinch for Zooming
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        gardenSKView.addGestureRecognizer(pinchGesture)
//        
//        // Pan for moving the camera
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.cancelsTouchesInView = false
//        gardenSKView.addGestureRecognizer(panGesture)
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
//    private func setupCollectionView() {
//        itemCollectionView.delegate = self
//        itemCollectionView.dataSource = self
//        
//        if let layout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumLineSpacing = 0
//            layout.itemSize = CGSize(width: 90, height: 100)
//        }
//    }
//
//    private func setupSpriteKit() {
//        let scene = GardenScene(size: gardenSKView.bounds.size)
//        scene.scaleMode = .resizeFill
//        scene.backgroundColor = .clear
//        gardenSKView.presentScene(scene)
//        gardenSKView.allowsTransparency = true
//        self.gardenScene = scene
//    }
//
//    @IBAction func storeButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
//        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
//            self.navigationController?.pushViewController(storeVC, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return gardenManager.unlockedItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
//            return UICollectionViewCell()
//        }
//        let item = gardenManager.unlockedItems[indexPath.item]
//        let isLast = indexPath.item == gardenManager.unlockedItems.count - 1
//        cell.configure(with: item, isLast: isLast)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = gardenManager.unlockedItems[indexPath.item]
//        gardenScene?.enterPlacementMode(for: item.imageName)
//    }
//}
//
//// MARK: - Garden SpriteKit Scene
//class GardenScene: SKScene {
//    var activePlacementNode: SKNode?
//    var isDragging = false
//    var gardenBaseNode: SKSpriteNode?
//    
//    let cameraNode = SKCameraNode()
//    private var initialCameraScale: CGFloat = 1.0
//    
//    override func didMove(to view: SKView) {
//        setupCamera()
//        setupGardenBase()
//    }
//    
//    func handleSceneSizeUpdate() {
//        updateCameraPosition()
//        setupGardenBase() // Recalculate scale if view size changes
//    }
//    
//    func updateCameraPosition() {
//        // Only reset to center if not already positioned, otherwise just constrain
//        if cameraNode.position == .zero {
//            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        }
//        constrainCamera()
//    }
//    
//    private func setupCamera() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(cameraNode)
//        self.camera = cameraNode
//    }
//    
//    private func setupGardenBase() {
//        if gardenBaseNode == nil {
//            let base = SKSpriteNode(imageNamed: "garden_base")
//            base.name = "garden_base"
//            base.zPosition = -1
//            addChild(base)
//            self.gardenBaseNode = base
//        }
//        
//        guard let base = gardenBaseNode else { return }
//        let textureSize = base.texture?.size() ?? CGSize(width: 1, height: 1)
//        
//        // Aspect Fill logic: ensures the garden covers the visible area
//        let scaleX = self.size.width / textureSize.width
//        let scaleY = self.size.height / textureSize.height
//        let scaleFactor = max(scaleX, scaleY)
//        
//        base.setScale(scaleFactor)
//        base.position = CGPoint(x: frame.midX, y: frame.midY)
//        
//        constrainCamera()
//    }
//
//    // MARK: - Zoom and Pan Logic
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        if sender.state == .began {
//            initialCameraScale = cameraNode.xScale
//        }
//        
//        let newScale = initialCameraScale / sender.scale
//        
//        if let base = gardenBaseNode {
//            // maxScale ensures the visible area never exceeds the garden's height or width
//            let maxScaleX = base.size.width / self.size.width
//            let maxScaleY = base.size.height / self.size.height
//            let maxPossibleScale = min(maxScaleX, maxScaleY)
//            
//            let clampedScale = max(0.4, min(newScale, maxPossibleScale))
//            cameraNode.setScale(clampedScale)
//        }
//        
//        constrainCamera()
//    }
//
//    func handlePan(_ sender: UIPanGestureRecognizer) {
//        if isDragging { return }
//        
//        let translation = sender.translation(in: self.view)
//        
//        let dx = translation.x * cameraNode.xScale
//        let dy = translation.y * cameraNode.yScale
//        
//        // Update camera position
//        let targetX = cameraNode.position.x - dx
//        let targetY = cameraNode.position.y + dy
//        
//        cameraNode.position = CGPoint(x: targetX, y: targetY)
//        constrainCamera()
//        
//        sender.setTranslation(.zero, in: self.view)
//    }
//    
//    /// Strict bounding logic to keep the camera view within the garden's visual area
//    private func constrainCamera() {
//        guard let base = gardenBaseNode else { return }
//        
//        let xScale = cameraNode.xScale
//        let yScale = cameraNode.yScale
//        
//        // Current visible area size through the camera lens
//        let visibleWidth = self.size.width * xScale
//        let visibleHeight = self.size.height * yScale
//        
//        // Buffer to account for minor floating point rounding
//        let epsilon: CGFloat = 0.5
//        
//        // --- Horizontal Constraint ---
//        let halfWidthDiff = (base.size.width - visibleWidth) / 2
//        if halfWidthDiff <= epsilon {
//            // If garden width is smaller or equal to visible width, lock to center
//            cameraNode.position.x = base.position.x
//        } else {
//            let minX = base.position.x - halfWidthDiff
//            let maxX = base.position.x + halfWidthDiff
//            cameraNode.position.x = max(minX, min(cameraNode.position.x, maxX))
//        }
//        
//        // --- Vertical Constraint (Restricting Up/Down) ---
//        let halfHeightDiff = (base.size.height - visibleHeight) / 2
//        if halfHeightDiff <= epsilon {
//            // If garden height is smaller or equal to visible height, lock to center
//            // This stops the initial vertical movement you were seeing
//            cameraNode.position.y = base.position.y
//        } else {
//            let minY = base.position.y - halfHeightDiff
//            let maxY = base.position.y + halfHeightDiff
//            cameraNode.position.y = max(minY, min(cameraNode.position.y, maxY))
//        }
//    }
//    
//    func enterPlacementMode(for imageName: String) {
//        cancelPlacement()
//        let container = SKNode()
//        container.position = cameraNode.position
//        container.zPosition = 1000
//        
//        let item = SKSpriteNode(imageNamed: imageName)
//        item.name = "moving_item"
//        item.alpha = 0.7
//        item.userData = ["assetName": imageName]
//        
//        if let baseScale = gardenBaseNode?.xScale {
//            item.setScale(baseScale)
//        }
//        
//        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
//        container.addChild(item)
//        
//        addUIButtons(to: container)
//        addChild(container)
//        activePlacementNode = container
//    }
//    
//    private func addUIButtons(to container: SKNode) {
//        let tick = SKSpriteNode(imageNamed: "button_tick")
//        tick.name = "btn_confirm"; tick.position = CGPoint(x: 60, y: -60)
//        container.addChild(tick)
//        let cross = SKSpriteNode(imageNamed: "button_cross")
//        cross.name = "btn_cancel"; cross.position = CGPoint(x: -60, y: -60)
//        container.addChild(cross)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let touchedNodes = nodes(at: location)
//        
//        for node in touchedNodes {
//            if node.name == "btn_confirm" { confirmPlacement(); return }
//            else if node.name == "btn_cancel" { cancelPlacement(); return }
//            else if node.name == "moving_item" || node.parent == activePlacementNode {
//                isDragging = true
//                return
//            }
//        }
//        
//        for node in touchedNodes {
//            if node.name == "placed_item" {
//                isDragging = true
//                let asset = node.userData?["assetName"] as? String ?? ""
//                let pos = node.position
//                node.removeFromParent()
//                enterPlacementMode(for: asset)
//                activePlacementNode?.position = pos
//                return
//            }
//        }
//        
//        isDragging = false
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isDragging, let touch = touches.first, let node = activePlacementNode else { return }
//        node.position = touch.location(in: self)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    func confirmPlacement() {
//        guard let container = activePlacementNode, let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else { return }
//        let assetName = ghost.userData?["assetName"] as? String ?? ""
//        let finalItem = SKSpriteNode(imageNamed: assetName)
//        finalItem.position = container.position
//        finalItem.anchorPoint = ghost.anchorPoint
//        finalItem.setScale(ghost.xScale)
//        finalItem.name = "placed_item"; finalItem.userData = ["assetName": assetName]
//        finalItem.zPosition = 1000 - container.position.y
//        addChild(finalItem); cancelPlacement()
//    }
//    
//    func cancelPlacement() {
//        activePlacementNode?.removeFromParent()
//        activePlacementNode = nil
//        isDragging = false
//    }
//}

//import UIKit
//import SpriteKit
//
//class GardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    @IBOutlet weak var gardenSKView: SKView!
//    @IBOutlet weak var itemCollectionView: UICollectionView!
//    @IBOutlet weak var storeButton: UIButton!
//    
//    var gardenScene: GardenScene?
//    private let gardenManager = GardenManager.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        setupSpriteKit()
//        setupGestures()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        itemCollectionView.reloadData()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Ensure the scene and camera are updated if the SKView layout changes
//        if let scene = gardenScene {
//            if scene.size != gardenSKView.bounds.size {
//                scene.size = gardenSKView.bounds.size
//                scene.handleSceneSizeUpdate()
//            }
//        }
//    }
//
//    private func setupGestures() {
//        // Pinch for Zooming
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        gardenSKView.addGestureRecognizer(pinchGesture)
//        
//        // Pan for moving the camera
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.cancelsTouchesInView = false
//        gardenSKView.addGestureRecognizer(panGesture)
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
//    private func setupCollectionView() {
//        itemCollectionView.delegate = self
//        itemCollectionView.dataSource = self
//        
//        if let layout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//            layout.minimumLineSpacing = 0
//            layout.itemSize = CGSize(width: 100, height: 53)
//        }
//    }
//
//    private func setupSpriteKit() {
//        let scene = GardenScene(size: gardenSKView.bounds.size)
//        scene.scaleMode = .resizeFill
//        scene.backgroundColor = .clear
//        gardenSKView.presentScene(scene)
//        gardenSKView.allowsTransparency = true
//        self.gardenScene = scene
//    }
//
//    @IBAction func storeButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Healinggarden", bundle: nil)
//        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
//            self.navigationController?.pushViewController(storeVC, animated: true)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return gardenManager.unlockedItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? GardenItemCell else {
//            return UICollectionViewCell()
//        }
//        let item = gardenManager.unlockedItems[indexPath.item]
//        let isLast = indexPath.item == gardenManager.unlockedItems.count - 1
//        cell.configure(with: item, isLast: isLast)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = gardenManager.unlockedItems[indexPath.item]
//        gardenScene?.enterPlacementMode(for: item.imageName)
//    }
//}
//
//// MARK: - Garden SpriteKit Scene
//class GardenScene: SKScene {
//    var activePlacementNode: SKNode?
//    var isDragging = false
//    var gardenBaseNode: SKSpriteNode?
//    
//    let cameraNode = SKCameraNode()
//    private var initialCameraScale: CGFloat = 1.0
//    
//    override func didMove(to view: SKView) {
//        setupCamera()
//        setupGardenBase()
//    }
//    
//    func handleSceneSizeUpdate() {
//        updateCameraPosition()
//        setupGardenBase() // Recalculate scale if view size changes
//    }
//    
//    func updateCameraPosition() {
//        // Only reset to center if not already positioned, otherwise just constrain
//        if cameraNode.position == .zero {
//            cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        }
//        constrainCamera()
//    }
//    
//    private func setupCamera() {
//        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(cameraNode)
//        self.camera = cameraNode
//    }
//    
//    private func setupGardenBase() {
//        if gardenBaseNode == nil {
//            let base = SKSpriteNode(imageNamed: "garden_base")
//            base.name = "garden_base"
//            base.zPosition = -1
//            addChild(base)
//            self.gardenBaseNode = base
//        }
//        
//        guard let base = gardenBaseNode else { return }
//        let textureSize = base.texture?.size() ?? CGSize(width: 1, height: 1)
//        
//        // Aspect Fill logic: ensures the garden covers the visible area
//        let scaleX = self.size.width / textureSize.width
//        let scaleY = self.size.height / textureSize.height
//        let scaleFactor = max(scaleX, scaleY)
//        
//        base.setScale(scaleFactor)
//        base.position = CGPoint(x: frame.midX, y: frame.midY)
//        
//        constrainCamera()
//    }
//
//    // MARK: - Zoom and Pan Logic
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        if sender.state == .began {
//            initialCameraScale = cameraNode.xScale
//        }
//        
//        let newScale = initialCameraScale / sender.scale
//        
//        if let base = gardenBaseNode {
//            // maxScale ensures the visible area never exceeds the garden's height or width
//            let maxScaleX = base.size.width / self.size.width
//            let maxScaleY = base.size.height / self.size.height
//            let maxPossibleScale = min(maxScaleX, maxScaleY)
//            
//            let clampedScale = max(0.4, min(newScale, maxPossibleScale))
//            cameraNode.setScale(clampedScale)
//        }
//        
//        constrainCamera()
//    }
//
//    func handlePan(_ sender: UIPanGestureRecognizer) {
//        if isDragging { return }
//        
//       
//        if abs(cameraNode.xScale - 1.0) < 0.01 {
//            print("Pan blocked - not zoomed in")
//            return
//        }
//        
//        let translation = sender.translation(in: self.view)
//        
//        let dx = translation.x * cameraNode.xScale
//        let dy = translation.y * cameraNode.yScale
//        
//        let targetX = cameraNode.position.x - dx
//        let targetY = cameraNode.position.y + dy
//        
//        cameraNode.position = CGPoint(x: targetX, y: targetY)
//        constrainCamera()
//        
//        sender.setTranslation(.zero, in: self.view)
//    }
//    
//    /// Strict bounding logic to keep the camera view within the garden's visual area
//    /// Strict bounding logic to keep the camera view within the garden's visual area
//    /// Strict bounding logic to keep the camera view within the garden's visual area
//    private func constrainCamera() {
//        guard let base = gardenBaseNode else { return }
//        
//        let xScale = cameraNode.xScale
//        let yScale = cameraNode.yScale
//        
//        // Current visible area size through the camera lens
//        let visibleWidth = self.size.width * xScale
//        let visibleHeight = self.size.height * yScale
//        
//        // --- Horizontal Constraint ---
//        if base.size.width <= visibleWidth {
//            // Garden is narrower than or equal to visible area - lock horizontally
//            cameraNode.position.x = base.position.x
//        } else {
//            // Garden is wider - allow panning within bounds
//            let halfWidthDiff = (base.size.width - visibleWidth) / 2
//            let minX = base.position.x - halfWidthDiff
//            let maxX = base.position.x + halfWidthDiff
//            cameraNode.position.x = max(minX, min(cameraNode.position.x, maxX))
//        }
//        
//        // --- Vertical Constraint ---
//        if base.size.height <= visibleHeight {
//            // Garden is shorter than or equal to visible area - lock vertically
//            cameraNode.position.y = base.position.y
//        } else {
//            // Garden is taller - allow panning within bounds
//            let halfHeightDiff = (base.size.height - visibleHeight) / 2
//            let minY = base.position.y - halfHeightDiff
//            let maxY = base.position.y + halfHeightDiff
//            cameraNode.position.y = max(minY, min(cameraNode.position.y, maxY))
//        }
//    }
//    
//    func enterPlacementMode(for imageName: String) {
//        cancelPlacement()
//        let container = SKNode()
//        container.position = cameraNode.position
//        container.zPosition = 1000
//        
//        let item = SKSpriteNode(imageNamed: imageName)
//        item.name = "moving_item"
//        item.alpha = 0.7
//        item.userData = ["assetName": imageName]
//        
//        if let baseScale = gardenBaseNode?.xScale {
//            item.setScale(baseScale)
//        }
//        
//        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
//        container.addChild(item)
//        
//        addUIButtons(to: container)
//        addChild(container)
//        activePlacementNode = container
//    }
//    
//    private func addUIButtons(to container: SKNode) {
//        let tick = SKSpriteNode(imageNamed: "button_tick")
//        tick.name = "btn_confirm"; tick.position = CGPoint(x: 60, y: -60)
//        container.addChild(tick)
//        let cross = SKSpriteNode(imageNamed: "button_cross")
//        cross.name = "btn_cancel"; cross.position = CGPoint(x: -60, y: -60)
//        container.addChild(cross)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let touchedNodes = nodes(at: location)
//        
//        for node in touchedNodes {
//            if node.name == "btn_confirm" { confirmPlacement(); return }
//            else if node.name == "btn_cancel" { cancelPlacement(); return }
//            else if node.name == "moving_item" || node.parent == activePlacementNode {
//                isDragging = true
//                return
//            }
//        }
//        
//        for node in touchedNodes {
//            if node.name == "placed_item" {
//                isDragging = true
//                let asset = node.userData?["assetName"] as? String ?? ""
//                let pos = node.position
//                node.removeFromParent()
//                enterPlacementMode(for: asset)
//                activePlacementNode?.position = pos
//                return
//            }
//        }
//        
//        isDragging = false
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isDragging, let touch = touches.first, let node = activePlacementNode else { return }
//        node.position = touch.location(in: self)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isDragging = false
//    }
//    
//    func confirmPlacement() {
//        guard let container = activePlacementNode, let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else { return }
//        let assetName = ghost.userData?["assetName"] as? String ?? ""
//        let finalItem = SKSpriteNode(imageNamed: assetName)
//        finalItem.position = container.position
//        finalItem.anchorPoint = ghost.anchorPoint
//        finalItem.setScale(ghost.xScale)
//        finalItem.name = "placed_item"; finalItem.userData = ["assetName": assetName]
//        finalItem.zPosition = 1000 - container.position.y
//        addChild(finalItem); cancelPlacement()
//    }
//    
//    func cancelPlacement() {
//        activePlacementNode?.removeFromParent()
//        activePlacementNode = nil
//        isDragging = false
//    }    
//}


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
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.title = "Garden"
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
        
        // Apply the new Compositional Layout
        itemCollectionView.setCollectionViewLayout(createCompositionalLayout(), animated: false)
    }

    // MARK: - Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        // 1. Item: Takes up the full size of its group
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 2. Group: Defines the actual size of our card (85x100)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(85),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 3. Section: Controls the horizontal scrolling behavior
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous // Modern horizontal scrolling
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10)
        section.interGroupSpacing = 0 // The separator is inside the cell
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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

    // MARK: - Collection View Data Source
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
        
        constrainCamera()
    }

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
        
        let targetX = cameraNode.position.x - dx
        let targetY = cameraNode.position.y + dy
        
        cameraNode.position = CGPoint(x: targetX, y: targetY)
        constrainCamera()
        
        sender.setTranslation(.zero, in: self.view)
    }
    
    private func constrainCamera() {
        guard let base = gardenBaseNode else { return }
        
        let xScale = cameraNode.xScale
        let yScale = cameraNode.yScale
        let visibleWidth = self.size.width * xScale
        let visibleHeight = self.size.height * yScale
        
        let halfWidthDiff = (base.size.width - visibleWidth) / 2
        let halfHeightDiff = (base.size.height - visibleHeight) / 2
        
        let limitX = max(0, halfWidthDiff)
        let limitY = max(0, halfHeightDiff)
        
        let minX = base.position.x - limitX
        let maxX = base.position.x + limitX
        let minY = base.position.y - limitY
        let maxY = base.position.y + limitY
        
        cameraNode.position.x = max(minX, min(cameraNode.position.x, maxX))
        cameraNode.position.y = max(minY, min(cameraNode.position.y, maxY))
    }
    
    func enterPlacementMode(for imageName: String) {
        cancelPlacement()
        let container = SKNode()
        container.position = cameraNode.position
        container.zPosition = 1000
        
        let item = SKSpriteNode(imageNamed: imageName)
        item.name = "moving_item"
        item.alpha = 0.7
        item.userData = ["assetName": imageName]
        
        if let baseScale = gardenBaseNode?.xScale {
            item.setScale(baseScale)
        }
        
        item.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        container.addChild(item)
        
        addUIButtons(to: container)
        addChild(container)
        activePlacementNode = container
    }
    
    private func addUIButtons(to container: SKNode) {
        let tick = SKSpriteNode(imageNamed: "button_tick")
        tick.name = "btn_confirm"; tick.position = CGPoint(x: 60, y: -60)
        container.addChild(tick)
        let cross = SKSpriteNode(imageNamed: "button_cross")
        cross.name = "btn_cancel"; cross.position = CGPoint(x: -60, y: -60)
        container.addChild(cross)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "btn_confirm" { confirmPlacement(); return }
            else if node.name == "btn_cancel" { cancelPlacement(); return }
            else if node.name == "moving_item" || node.parent == activePlacementNode {
                isDragging = true
                return
            }
        }
        
        for node in touchedNodes {
            if node.name == "placed_item" {
                isDragging = true
                let asset = node.userData?["assetName"] as? String ?? ""
                let pos = node.position
                node.removeFromParent()
                enterPlacementMode(for: asset)
                activePlacementNode?.position = pos
                return
            }
        }
        
        isDragging = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first, let node = activePlacementNode else { return }
        node.position = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
    func confirmPlacement() {
        guard let container = activePlacementNode, let ghost = container.childNode(withName: "moving_item") as? SKSpriteNode else { return }
        let assetName = ghost.userData?["assetName"] as? String ?? ""
        let finalItem = SKSpriteNode(imageNamed: assetName)
        finalItem.position = container.position
        finalItem.anchorPoint = ghost.anchorPoint
        finalItem.setScale(ghost.xScale)
        finalItem.name = "placed_item"; finalItem.userData = ["assetName": assetName]
        finalItem.zPosition = 1000 - container.position.y
        addChild(finalItem); cancelPlacement()
    }
    
    func cancelPlacement() {
        activePlacementNode?.removeFromParent()
        activePlacementNode = nil
        isDragging = false
    }
}
