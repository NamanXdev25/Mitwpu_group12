////import Foundation
////
////// MARK: - Notification names
////extension Notification.Name {
////    static let gardenBaseDidChange  = Notification.Name("gardenBaseDidChange")
////    static let gardenLevelDidChange = Notification.Name("gardenLevelDidChange")
////    static let gardenBasesUnlocked  = Notification.Name("gardenBasesUnlocked")
////}
////
////final class GardenManager {
////    static let shared = GardenManager()
////
////    // MARK: - Category
////    enum Category: String, CaseIterable {
////        case yourItems = "Your Items"
////        case nature    = "Nature"
////        case wellness  = "Wellness"
////    }
////
////    enum PurchaseResult {
////        case purchased(remainingCoins: Int)
////        case insufficientCoins(missingCoins: Int, currentCoins: Int, itemPrice: Int)
////        case alreadyUnlocked
////        case notPurchasable
////    }
////
////    static let segmentCategories: [String] = Category.allCases.map(\.rawValue)
////
////    // MARK: - Storage keys (v3)
////    private enum StorageKeys {
////        static let coins          = "garden_coins_v3"
////        static let unlockedIds    = "garden_unlocked_item_ids_v3"
////        static let unlockedBases  = "garden_unlocked_base_ids_v3"
////        static let selectedBaseId = "garden_selected_base_id_v3"
////        static let levelProgress  = "garden_level_progress_v3"
////        static func placedItems(for baseId: String) -> String {
////            "garden_placed_items_\(baseId)_v3"
////        }
////    }
////
////    // MARK: - Public state
////    private(set) var coins: Int = 0
////    private(set) var unlockedItemIds: Set<String> = []
////    var currentCoins: Int { coins }
////
////    private(set) var allBases: [GardenBase] = []
////
////    private(set) var selectedBase: GardenBase {
////        didSet {
////            UserDefaults.standard.set(selectedBase.id, forKey: StorageKeys.selectedBaseId)
////            NotificationCenter.default.post(name: .gardenBaseDidChange, object: selectedBase)
////        }
////    }
////
////    private(set) var levelProgress: GardenLevelProgress = .initial
////
////    // MARK: - Private catalog
////    private var yourItemsCatalog: [StoreItem] = []
////    private var shopCatalog: [StoreItem]      = []
////    private var allItemsOrdered: [StoreItem]  = []
////
////    // MARK: - Derived helpers
////
////    var unlockedBases: [GardenBase] { allBases.filter(\.isUnlocked) }
////
////    /// Items for the bottom tray on GardenViewController:
////    /// • All unlocked bases (tap to switch base)
////    /// • All unlocked shop items across ALL bases
////    var trayItems: [StoreItem] {
////        var result: [StoreItem] = []
////        for base in unlockedBases {
////            result.append(makeBaseStoreItem(from: base))
////        }
////        // FIX: only show items that belong to the currently selected base
////        let shopUnlocked = allItemsOrdered.filter {
////            $0.category != Category.yourItems.rawValue &&
////            unlockedItemIds.contains($0.id) &&
////            effectiveBaseId(of: $0) == selectedBase.id
////        }
////        result.append(contentsOf: shopUnlocked)
////        return result
////    }
////
////    // MARK: - Init
////    private init() {
////        selectedBase = GardenBase(id: "classic", name: "Classic", imageName: "garden_base",
////                                  unlockLevel: 1, isUnlocked: true)
////        loadBases()
////        loadCatalog()
////        restorePersistedState()
////        seedDefaultUnlockedItems()
////        checkDailyReset()
////        persistState()
////    }
////
////    // MARK: - Public API
////
////    func getItems(for category: String) -> [StoreItem] {
////        guard let parsed = Category(rawValue: category) else { return [] }
////        let baseId = selectedBase.id
////
////        switch parsed {
////        case .yourItems:
////            var result: [StoreItem] = []
////            for base in unlockedBases {
////                result.append(makeBaseStoreItem(from: base))
////            }
////            let shopUnlocked = allItemsOrdered.filter {
////                $0.category != Category.yourItems.rawValue &&
////                unlockedItemIds.contains($0.id) &&
////                effectiveBaseId(of: $0) == baseId
////            }
////            result.append(contentsOf: shopUnlocked)
////            return result
////
////        case .nature, .wellness:
////            return shopCatalog.filter {
////                $0.category == parsed.rawValue &&
////                effectiveBaseId(of: $0) == baseId &&
////                !unlockedItemIds.contains($0.id)
////            }
////        }
////    }
////
////    func purchaseResult(for item: StoreItem) -> PurchaseResult {
////        guard item.category != Category.yourItems.rawValue else { return .notPurchasable }
////        guard !unlockedItemIds.contains(item.id)           else { return .alreadyUnlocked }
////        guard coins >= item.price else {
////            return .insufficientCoins(missingCoins: item.price - coins,
////                                      currentCoins: coins, itemPrice: item.price)
////        }
////        coins -= item.price
////        unlockedItemIds.insert(item.id)
////        persistState()
////        return .purchased(remainingCoins: coins)
////    }
////
////    @discardableResult
////    func purchaseItem(_ item: StoreItem) -> Bool {
////        if case .purchased = purchaseResult(for: item) { return true }
////        return false
////    }
////
////    func addCoins(_ amount: Int) {
////        guard amount > 0 else { return }
////        coins += amount
////        creditDailyCoins(amount*5100)
////        persistState()
////    }
////
////    // MARK: - Base Selection
////
////    func selectBase(_ base: GardenBase) {
////        guard base.isUnlocked,
////              let found = allBases.first(where: { $0.id == base.id }) else { return }
////        selectedBase = found
////        UserDefaults.standard.set(found.id, forKey: StorageKeys.selectedBaseId)
////    }
////
////    // MARK: - Per-Base Placed Items
////
////    func savePlacedItems(_ items: [PlacedItem], for baseId: String) {
////        if let data = try? JSONEncoder().encode(items) {
////            UserDefaults.standard.set(data, forKey: StorageKeys.placedItems(for: baseId))
////        }
////    }
////
////    func loadPlacedItems(for baseId: String) -> [PlacedItem] {
////        guard let data  = UserDefaults.standard.data(forKey: StorageKeys.placedItems(for: baseId)),
////              let items = try? JSONDecoder().decode([PlacedItem].self, from: data) else { return [] }
////        return items
////    }
////
////    // MARK: - Daily Reset
////
////    func checkDailyReset() {
////        let today = GardenLevelProgress.todayString()
////        if levelProgress.lastResetDateString != today {
////            levelProgress.dailyCoinsEarned    = 0
////            levelProgress.lastResetDateString = today
////            persistLevelProgress()
////        }
////    }
////
////    // MARK: - Private: Level Crediting
////
////    private func creditDailyCoins(_ amount: Int) {
////        checkDailyReset()
////        levelProgress.dailyCoinsEarned += amount
////
////        let freshPoints = Int(Double(levelProgress.dailyCoinsEarned) * 0.05)
////        if freshPoints > levelProgress.currentPoints {
////            levelProgress.currentPoints = freshPoints
////        }
////
////        while levelProgress.currentPoints >= levelProgress.pointsNeededForNextLevel {
////            levelProgress.currentPoints -= levelProgress.pointsNeededForNextLevel
////            levelProgress.currentLevel  += 1
////            levelProgress.pointsNeededForNextLevel = GardenLevelProgress.pointsPerLevel
////        }
////
////        checkAndUnlockBasesForLevel()
////        persistLevelProgress()
////        NotificationCenter.default.post(name: .gardenLevelDidChange, object: levelProgress)
////    }
////
////    private func checkAndUnlockBasesForLevel() {
////        var changed = false
////        for i in allBases.indices {
////            if !allBases[i].isUnlocked && allBases[i].unlockLevel <= levelProgress.currentLevel {
////                allBases[i].isUnlocked = true
////                changed = true
////            }
////        }
////        if changed { persistBases() }
////    }
////
////    private func effectiveBaseId(of item: StoreItem) -> String {
////        item.baseId ?? "classic"
////    }
////
////    private func makeBaseStoreItem(from base: GardenBase) -> StoreItem {
////        StoreItem(id: "base_\(base.id)", name: base.name, imageName: base.imageName,
////                  price: 0, category: Category.yourItems.rawValue, baseId: base.id)
////    }
////
////    // MARK: - Load Bases
////
////    private func loadBases() {
////        allBases = [
////            GardenBase(id: "classic",  name: "Classic Garden",  imageName: "garden_base",
////                       unlockLevel: 1, isUnlocked: true),
////            GardenBase(id: "zen",      name: "Zen Garden",      imageName: "garden_base_zen",
////                       unlockLevel: 3, isUnlocked: false),
////            GardenBase(id: "tropical", name: "Tropical Garden", imageName: "garden_base_tropical",
////                       unlockLevel: 5, isUnlocked: false),
////        ]
////
////        let savedIds = Set(UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedBases) ?? [])
////        for i in allBases.indices where savedIds.contains(allBases[i].id) {
////            allBases[i].isUnlocked = true
////        }
////        if let idx = allBases.firstIndex(where: { $0.id == "classic" }) {
////            allBases[idx].isUnlocked = true
////        }
////
////        let savedBaseId = UserDefaults.standard.string(forKey: StorageKeys.selectedBaseId) ?? "classic"
////        selectedBase = allBases.first(where: { $0.id == savedBaseId && $0.isUnlocked })
////                    ?? allBases.first(where: { $0.id == "classic" })
////                    ?? allBases[0]
////    }
////
////    private func persistBases() {
////        UserDefaults.standard.set(allBases.filter(\.isUnlocked).map(\.id),
////                                  forKey: StorageKeys.unlockedBases)
////    }
////
////    // MARK: - Load Catalog
////
////    private func loadCatalog() {
////        let payload      = loadPayloadFromJSON() ?? Self.fallbackPayload
////        yourItemsCatalog = payload.yourItems.enumerated().map { makeYourItem(from: $1, index: $0) }
////        let nature       = payload.nature.enumerated().map   { makeShopItem(from: $1, category: .nature,   index: $0) }
////        let wellness     = payload.wellness.enumerated().map { makeShopItem(from: $1, category: .wellness, index: $0) }
////        shopCatalog      = nature + wellness
////        allItemsOrdered  = yourItemsCatalog + shopCatalog
////    }
////
////    // MARK: - State Persistence
////
////    private func restorePersistedState() {
////        let d = UserDefaults.standard
////        coins = d.object(forKey: StorageKeys.coins) != nil ? d.integer(forKey: StorageKeys.coins) : 0
////        unlockedItemIds = Set(d.stringArray(forKey: StorageKeys.unlockedIds) ?? [])
////
////        if let data     = d.data(forKey: StorageKeys.levelProgress),
////           let progress = try? JSONDecoder().decode(GardenLevelProgress.self, from: data) {
////            levelProgress = progress
////        } else {
////            levelProgress = .initial
////        }
////    }
////
////    private func persistState() {
////        let d = UserDefaults.standard
////        d.set(coins,                    forKey: StorageKeys.coins)
////        d.set(Array(unlockedItemIds),   forKey: StorageKeys.unlockedIds)
////        persistBases()
////        persistLevelProgress()
////    }
////
////    private func persistLevelProgress() {
////        if let data = try? JSONEncoder().encode(levelProgress) {
////            UserDefaults.standard.set(data, forKey: StorageKeys.levelProgress)
////        }
////    }
////
////    private func seedDefaultUnlockedItems() {
////        unlockedItemIds.formUnion(yourItemsCatalog.map(\.id))
////        checkAndUnlockBasesForLevel()
////    }
////
////    // MARK: - Item Factory
////
////    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
////        let id   = resolvedId(explicitId: dto.id, category: .yourItems,
////                              imageName: dto.imageName, index: index)
////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
////        return StoreItem(id: id, name: name, imageName: dto.imageName, price: 0,
////                         category: Category.yourItems.rawValue, baseId: dto.baseId ?? "classic")
////    }
////
////    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
////        let id   = resolvedId(explicitId: dto.id, category: category,
////                              imageName: dto.imageName, index: index)
////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
////        return StoreItem(id: id, name: name, imageName: dto.imageName, price: max(dto.price, 0),
////                         category: category.rawValue, baseId: dto.baseId ?? "classic")
////    }
////
////    private func resolvedId(explicitId: String?, category: Category,
////                            imageName: String, index: Int) -> String {
////        if let e = explicitId, let clean = e.trimmedNonEmpty { return clean }
////        let cat   = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
////        let image = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
////        return "\(cat)_\(image)_\(index)"
////    }
////
////    private static func displayName(fromImageName imageName: String) -> String {
////        let s = imageName
////            .replacingOccurrences(of: "_", with: " ")
////            .replacingOccurrences(of: "-", with: " ")
////            .trimmingCharacters(in: .whitespacesAndNewlines)
////        guard !s.isEmpty else { return "Item" }
////        return s.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
////    }
////
////    // MARK: - JSON Loading
////
////    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
////        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else { return nil }
////        do {
////            return try JSONDecoder().decode(GardenCatalogPayload.self, from: Data(contentsOf: url))
////        } catch {
////            print("Failed to decode garden_items.json: \(error)")
////            return nil
////        }
////    }
////
////    private static let fallbackPayload = GardenCatalogPayload(
////        yourItems: [],
////        nature: [
////            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea",
////                        price: 3000, baseId: "classic"),
////            ShopItemDTO(id: "nature_tulips",    name: "Tulips",    imageName: "tulips",
////                        price: 2300, baseId: "classic")
////        ],
////        wellness: [
////            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath",
////                        price: 1500, baseId: "classic"),
////            ShopItemDTO(id: "wellness_fountain",  name: "Fountain",  imageName: "fountain",
////                        price: 3000, baseId: "classic")
////        ]
////    )
////}
////
////// MARK: - Private DTO types
////
////private struct GardenCatalogPayload: Decodable {
////    let yourItems: [UnlockedItemDTO]
////    let nature:    [ShopItemDTO]
////    let wellness:  [ShopItemDTO]
////
////    enum CodingKeys: String, CodingKey {
////        case yourItemsSnake = "your_items"
////        case yourItemsTitle = "Your Items"
////        case natureLower    = "nature"
////        case natureTitle    = "Nature"
////        case wellnessLower  = "wellness"
////        case wellnessTitle  = "Wellness"
////    }
////
////    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
////        self.yourItems = yourItems; self.nature = nature; self.wellness = wellness
////    }
////
////    init(from decoder: Decoder) throws {
////        let c = try decoder.container(keyedBy: CodingKeys.self)
////        yourItems = (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake))
////                 ?? (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle))
////                 ?? []
////        nature    = (try? c.decode([ShopItemDTO].self, forKey: .natureLower))
////                 ?? (try? c.decode([ShopItemDTO].self, forKey: .natureTitle))
////                 ?? []
////        wellness  = (try? c.decode([ShopItemDTO].self, forKey: .wellnessLower))
////                 ?? (try? c.decode([ShopItemDTO].self, forKey: .wellnessTitle))
////                 ?? []
////    }
////}
////
////private struct UnlockedItemDTO: Decodable {
////    let id: String?
////    let name: String?
////    let imageName: String
////    let baseId: String?
////
////    enum CodingKeys: String, CodingKey {
////        case id, name, image, imageName, baseId = "base_id"
////    }
////
////    init(id: String? = nil, name: String? = nil, imageName: String, baseId: String? = nil) {
////        self.id = id; self.name = name; self.imageName = imageName; self.baseId = baseId
////    }
////
////    init(from decoder: Decoder) throws {
////        let c  = try decoder.container(keyedBy: CodingKeys.self)
////        id     = try? c.decode(String.self, forKey: .id)
////        name   = try? c.decode(String.self, forKey: .name)
////        baseId = try? c.decode(String.self, forKey: .baseId)
////        // Try imageName first, fall back to image — both wrapped in do/catch to avoid ambiguous try
////        if let v = try? c.decode(String.self, forKey: .imageName) {
////            imageName = v
////        } else {
////            imageName = try c.decode(String.self, forKey: .image)
////        }
////    }
////}
////
////private struct ShopItemDTO: Decodable {
////    let id: String?
////    let name: String?
////    let imageName: String
////    let price: Int
////    let baseId: String?
////
////    enum CodingKeys: String, CodingKey {
////        case id, name, image, imageName, price, baseId = "base_id"
////    }
////
////    init(id: String? = nil, name: String? = nil, imageName: String,
////         price: Int, baseId: String? = nil) {
////        self.id = id; self.name = name; self.imageName = imageName
////        self.price = price; self.baseId = baseId
////    }
////
////    init(from decoder: Decoder) throws {
////        let c  = try decoder.container(keyedBy: CodingKeys.self)
////        id     = try? c.decode(String.self, forKey: .id)
////        name   = try? c.decode(String.self, forKey: .name)
////        baseId = try? c.decode(String.self, forKey: .baseId)
////        // imageName: try imageName key first, then image key
////        if let v = try? c.decode(String.self, forKey: .imageName) {
////            imageName = v
////        } else {
////            imageName = try c.decode(String.self, forKey: .image)
////        }
////        // price: try Int first, then String
////        if let p = try? c.decode(Int.self, forKey: .price) {
////            price = p
////        } else if let s = try? c.decode(String.self, forKey: .price),
////                  let p = Int(s.replacingOccurrences(of: ",", with: "")) {
////            price = p
////        } else {
////            price = 0
////        }
////    }
////}
////
////private extension String {
////    var trimmedNonEmpty: String? {
////        let v = trimmingCharacters(in: .whitespacesAndNewlines)
////        return v.isEmpty ? nil : v
////    }
////}
//
//import Foundation
//
//// MARK: - Notification names
//extension Notification.Name {
//    static let gardenBaseDidChange  = Notification.Name("gardenBaseDidChange")
//    static let gardenLevelDidChange = Notification.Name("gardenLevelDidChange")
//}
//
//final class GardenManager {
//    static let shared = GardenManager()
//
//    // MARK: - Category
//    enum Category: String, CaseIterable {
//        case yourItems = "Your Items"
//        case nature    = "Nature"
//        case wellness  = "Wellness"
//    }
//
//    enum PurchaseResult {
//        case purchased(remainingCoins: Int)
//        case insufficientCoins(missingCoins: Int, currentCoins: Int, itemPrice: Int)
//        case alreadyUnlocked
//        case notPurchasable
//    }
//
//    static let segmentCategories: [String] = Category.allCases.map(\.rawValue)
//
//    // MARK: - Storage keys (v3)
//    private enum StorageKeys {
//        static let coins          = "garden_coins_v3"
//        static let unlockedIds    = "garden_unlocked_item_ids_v3"
//        static let unlockedBases  = "garden_unlocked_base_ids_v3"
//        static let selectedBaseId = "garden_selected_base_id_v3"
//        static let levelProgress  = "garden_level_progress_v3"
//        static func placedItems(for baseId: String) -> String {
//            "garden_placed_items_\(baseId)_v3"
//        }
//    }
//
//    // MARK: - Public state
//    private(set) var coins: Int = 0
//    private(set) var unlockedItemIds: Set<String> = []
//    var currentCoins: Int { coins }
//
//    private(set) var allBases: [GardenBase] = []
//
//    private(set) var selectedBase: GardenBase {
//        didSet {
//            UserDefaults.standard.set(selectedBase.id, forKey: StorageKeys.selectedBaseId)
//            NotificationCenter.default.post(name: .gardenBaseDidChange, object: selectedBase)
//        }
//    }
//
//    private(set) var levelProgress: GardenLevelProgress = .initial
//
//    // MARK: - Private catalog
//    private var yourItemsCatalog: [StoreItem] = []
//    private var shopCatalog: [StoreItem]      = []
//    private var allItemsOrdered: [StoreItem]  = []
//
//    // MARK: - Derived helpers
//
//    var unlockedBases: [GardenBase] { allBases.filter(\.isUnlocked) }
//
//    /// Items for the bottom tray on GardenViewController:
//    /// • All unlocked bases (tap to switch base)
//    /// • All unlocked shop items across ALL bases
//    var trayItems: [StoreItem] {
//        var result: [StoreItem] = []
//        for base in unlockedBases {
//            result.append(makeBaseStoreItem(from: base))
//        }
//        let shopUnlocked = allItemsOrdered.filter {
//            $0.category != Category.yourItems.rawValue &&
//            unlockedItemIds.contains($0.id)
//        }
//        result.append(contentsOf: shopUnlocked)
//        return result
//    }
//
//    // MARK: - Init
//    private init() {
//        selectedBase = GardenBase(id: "classic", name: "Classic", imageName: "garden_base",
//                                  unlockLevel: 1, isUnlocked: true)
//        loadBases()
//        loadCatalog()
//        restorePersistedState()
//        seedDefaultUnlockedItems()
//        checkDailyReset()
//        persistState()
//    }
//
//    // MARK: - Public API
//
//    func getItems(for category: String) -> [StoreItem] {
//        guard let parsed = Category(rawValue: category) else { return [] }
//        let baseId = selectedBase.id
//
//        switch parsed {
//        case .yourItems:
//            var result: [StoreItem] = []
//            for base in unlockedBases {
//                result.append(makeBaseStoreItem(from: base))
//            }
//            let shopUnlocked = allItemsOrdered.filter {
//                $0.category != Category.yourItems.rawValue &&
//                unlockedItemIds.contains($0.id) &&
//                effectiveBaseId(of: $0) == baseId
//            }
//            result.append(contentsOf: shopUnlocked)
//            return result
//
//        case .nature, .wellness:
//            return shopCatalog.filter {
//                $0.category == parsed.rawValue &&
//                effectiveBaseId(of: $0) == baseId &&
//                !unlockedItemIds.contains($0.id)
//            }
//        }
//    }
//
//    func purchaseResult(for item: StoreItem) -> PurchaseResult {
//        guard item.category != Category.yourItems.rawValue else { return .notPurchasable }
//        guard !unlockedItemIds.contains(item.id)           else { return .alreadyUnlocked }
//        guard coins >= item.price else {
//            return .insufficientCoins(missingCoins: item.price - coins,
//                                      currentCoins: coins, itemPrice: item.price)
//        }
//        coins -= item.price
//        unlockedItemIds.insert(item.id)
//        persistState()
//        return .purchased(remainingCoins: coins)
//    }
//
//    @discardableResult
//    func purchaseItem(_ item: StoreItem) -> Bool {
//        if case .purchased = purchaseResult(for: item) { return true }
//        return false
//    }
//
//    func addCoins(_ amount: Int) {
//        guard amount > 0 else { return }
//        coins += amount
//        creditDailyCoins(amount*5100)
//        persistState()
//    }
//
//    // MARK: - Base Selection
//
//    func selectBase(_ base: GardenBase) {
//        guard base.isUnlocked,
//              let found = allBases.first(where: { $0.id == base.id }) else { return }
//        selectedBase = found
//        UserDefaults.standard.set(found.id, forKey: StorageKeys.selectedBaseId)
//    }
//
//    // MARK: - Per-Base Placed Items
//
//    func savePlacedItems(_ items: [PlacedItem], for baseId: String) {
//        if let data = try? JSONEncoder().encode(items) {
//            UserDefaults.standard.set(data, forKey: StorageKeys.placedItems(for: baseId))
//        }
//    }
//
//    func loadPlacedItems(for baseId: String) -> [PlacedItem] {
//        guard let data  = UserDefaults.standard.data(forKey: StorageKeys.placedItems(for: baseId)),
//              let items = try? JSONDecoder().decode([PlacedItem].self, from: data) else { return [] }
//        return items
//    }
//
//    // MARK: - Daily Reset
//
//    func checkDailyReset() {
//        let today = GardenLevelProgress.todayString()
//        if levelProgress.lastResetDateString != today {
//            levelProgress.dailyCoinsEarned    = 0
//            levelProgress.lastResetDateString = today
//            persistLevelProgress()
//        }
//    }
//
//    // MARK: - Private: Level Crediting
//
//    private func creditDailyCoins(_ amount: Int) {
//        checkDailyReset()
//        levelProgress.dailyCoinsEarned += amount
//
//        let freshPoints = Int(Double(levelProgress.dailyCoinsEarned) * 0.05)
//        if freshPoints > levelProgress.currentPoints {
//            levelProgress.currentPoints = freshPoints
//        }
//
//        // Level up while total earned points exceed the cumulative threshold for this level.
//        // Level 1 threshold = 1 * 5000, Level 2 = 2 * 5000, Level 3 = 3 * 5000, ...
//        // currentPoints here is the RUNNING TOTAL (not reset between levels).
//        while levelProgress.currentPoints >= levelProgress.currentLevel * GardenLevelProgress.pointsPerLevel {
//            levelProgress.currentLevel += 1
//            // Update pointsNeededForNextLevel to the new level's cumulative target
//            levelProgress.pointsNeededForNextLevel = levelProgress.currentLevel * GardenLevelProgress.pointsPerLevel
//        }
//
//        checkAndUnlockBasesForLevel()
//        persistLevelProgress()
//        NotificationCenter.default.post(name: .gardenLevelDidChange, object: levelProgress)
//    }
//
//    private func checkAndUnlockBasesForLevel() {
//        var changed = false
//        for i in allBases.indices {
//            if !allBases[i].isUnlocked && allBases[i].unlockLevel <= levelProgress.currentLevel {
//                allBases[i].isUnlocked = true
//                changed = true
//            }
//        }
//        if changed { persistBases() }
//    }
//
//    private func effectiveBaseId(of item: StoreItem) -> String {
//        item.baseId ?? "classic"
//    }
//
//    private func makeBaseStoreItem(from base: GardenBase) -> StoreItem {
//        StoreItem(id: "base_\(base.id)", name: base.name, imageName: base.imageName,
//                  price: 0, category: Category.yourItems.rawValue, baseId: base.id)
//    }
//
//    // MARK: - Load Bases
//
//    private func loadBases() {
//        allBases = [
//            GardenBase(id: "classic",  name: "Classic Garden",  imageName: "garden_base",
//                       unlockLevel: 1, isUnlocked: true),
//            GardenBase(id: "zen",      name: "Zen Garden",      imageName: "garden_base_zen",
//                       unlockLevel: 3, isUnlocked: false),
//            GardenBase(id: "tropical", name: "Tropical Garden", imageName: "garden_base_tropical",
//                       unlockLevel: 5, isUnlocked: false),
//        ]
//
//        let savedIds = Set(UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedBases) ?? [])
//        for i in allBases.indices where savedIds.contains(allBases[i].id) {
//            allBases[i].isUnlocked = true
//        }
//        if let idx = allBases.firstIndex(where: { $0.id == "classic" }) {
//            allBases[idx].isUnlocked = true
//        }
//
//        let savedBaseId = UserDefaults.standard.string(forKey: StorageKeys.selectedBaseId) ?? "classic"
//        selectedBase = allBases.first(where: { $0.id == savedBaseId && $0.isUnlocked })
//                    ?? allBases.first(where: { $0.id == "classic" })
//                    ?? allBases[0]
//    }
//
//    private func persistBases() {
//        UserDefaults.standard.set(allBases.filter(\.isUnlocked).map(\.id),
//                                  forKey: StorageKeys.unlockedBases)
//    }
//
//    // MARK: - Load Catalog
//
//    private func loadCatalog() {
//        let payload      = loadPayloadFromJSON() ?? Self.fallbackPayload
//        yourItemsCatalog = payload.yourItems.enumerated().map { makeYourItem(from: $1, index: $0) }
//        let nature       = payload.nature.enumerated().map   { makeShopItem(from: $1, category: .nature,   index: $0) }
//        let wellness     = payload.wellness.enumerated().map { makeShopItem(from: $1, category: .wellness, index: $0) }
//        shopCatalog      = nature + wellness
//        allItemsOrdered  = yourItemsCatalog + shopCatalog
//    }
//
//    // MARK: - State Persistence
//
//    private func restorePersistedState() {
//        let d = UserDefaults.standard
//        coins = d.object(forKey: StorageKeys.coins) != nil ? d.integer(forKey: StorageKeys.coins) : 0
//        unlockedItemIds = Set(d.stringArray(forKey: StorageKeys.unlockedIds) ?? [])
//
//        if let data     = d.data(forKey: StorageKeys.levelProgress),
//           let progress = try? JSONDecoder().decode(GardenLevelProgress.self, from: data) {
//            levelProgress = progress
//        } else {
//            levelProgress = .initial
//        }
//    }
//
//    private func persistState() {
//        let d = UserDefaults.standard
//        d.set(coins,                    forKey: StorageKeys.coins)
//        d.set(Array(unlockedItemIds),   forKey: StorageKeys.unlockedIds)
//        persistBases()
//        persistLevelProgress()
//    }
//
//    private func persistLevelProgress() {
//        if let data = try? JSONEncoder().encode(levelProgress) {
//            UserDefaults.standard.set(data, forKey: StorageKeys.levelProgress)
//        }
//    }
//
//    private func seedDefaultUnlockedItems() {
//        unlockedItemIds.formUnion(yourItemsCatalog.map(\.id))
//        checkAndUnlockBasesForLevel()
//    }
//
//    // MARK: - Item Factory
//
//    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
//        let id   = resolvedId(explicitId: dto.id, category: .yourItems,
//                              imageName: dto.imageName, index: index)
//        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
//        return StoreItem(id: id, name: name, imageName: dto.imageName, price: 0,
//                         category: Category.yourItems.rawValue, baseId: dto.baseId ?? "classic")
//    }
//
//    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
//        let id   = resolvedId(explicitId: dto.id, category: category,
//                              imageName: dto.imageName, index: index)
//        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
//        return StoreItem(id: id, name: name, imageName: dto.imageName, price: max(dto.price, 0),
//                         category: category.rawValue, baseId: dto.baseId ?? "classic")
//    }
//
//    private func resolvedId(explicitId: String?, category: Category,
//                            imageName: String, index: Int) -> String {
//        if let e = explicitId, let clean = e.trimmedNonEmpty { return clean }
//        let cat   = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
//        let image = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
//        return "\(cat)_\(image)_\(index)"
//    }
//
//    private static func displayName(fromImageName imageName: String) -> String {
//        let s = imageName
//            .replacingOccurrences(of: "_", with: " ")
//            .replacingOccurrences(of: "-", with: " ")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !s.isEmpty else { return "Item" }
//        return s.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
//    }
//
//    // MARK: - JSON Loading
//
//    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
//        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else { return nil }
//        do {
//            return try JSONDecoder().decode(GardenCatalogPayload.self, from: Data(contentsOf: url))
//        } catch {
//            print("Failed to decode garden_items.json: \(error)")
//            return nil
//        }
//    }
//
//    private static let fallbackPayload = GardenCatalogPayload(
//        yourItems: [],
//        nature: [
//            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea",
//                        price: 3000, baseId: "classic"),
//            ShopItemDTO(id: "nature_tulips",    name: "Tulips",    imageName: "tulips",
//                        price: 2300, baseId: "classic")
//        ],
//        wellness: [
//            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath",
//                        price: 1500, baseId: "classic"),
//            ShopItemDTO(id: "wellness_fountain",  name: "Fountain",  imageName: "fountain",
//                        price: 3000, baseId: "classic")
//        ]
//    )
//}
//
//// MARK: - Private DTO types
//
//private struct GardenCatalogPayload: Decodable {
//    let yourItems: [UnlockedItemDTO]
//    let nature:    [ShopItemDTO]
//    let wellness:  [ShopItemDTO]
//
//    enum CodingKeys: String, CodingKey {
//        case yourItemsSnake = "your_items"
//        case yourItemsTitle = "Your Items"
//        case natureLower    = "nature"
//        case natureTitle    = "Nature"
//        case wellnessLower  = "wellness"
//        case wellnessTitle  = "Wellness"
//    }
//
//    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
//        self.yourItems = yourItems; self.nature = nature; self.wellness = wellness
//    }
//
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        yourItems = (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake))
//                 ?? (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle))
//                 ?? []
//        nature    = (try? c.decode([ShopItemDTO].self, forKey: .natureLower))
//                 ?? (try? c.decode([ShopItemDTO].self, forKey: .natureTitle))
//                 ?? []
//        wellness  = (try? c.decode([ShopItemDTO].self, forKey: .wellnessLower))
//                 ?? (try? c.decode([ShopItemDTO].self, forKey: .wellnessTitle))
//                 ?? []
//    }
//}
//
//private struct UnlockedItemDTO: Decodable {
//    let id: String?
//    let name: String?
//    let imageName: String
//    let baseId: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, image, imageName, baseId = "base_id"
//    }
//
//    init(id: String? = nil, name: String? = nil, imageName: String, baseId: String? = nil) {
//        self.id = id; self.name = name; self.imageName = imageName; self.baseId = baseId
//    }
//
//    init(from decoder: Decoder) throws {
//        let c  = try decoder.container(keyedBy: CodingKeys.self)
//        id     = try? c.decode(String.self, forKey: .id)
//        name   = try? c.decode(String.self, forKey: .name)
//        baseId = try? c.decode(String.self, forKey: .baseId)
//        // Try imageName first, fall back to image — both wrapped in do/catch to avoid ambiguous try
//        if let v = try? c.decode(String.self, forKey: .imageName) {
//            imageName = v
//        } else {
//            imageName = try c.decode(String.self, forKey: .image)
//        }
//    }
//}
//
//private struct ShopItemDTO: Decodable {
//    let id: String?
//    let name: String?
//    let imageName: String
//    let price: Int
//    let baseId: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, image, imageName, price, baseId = "base_id"
//    }
//
//    init(id: String? = nil, name: String? = nil, imageName: String,
//         price: Int, baseId: String? = nil) {
//        self.id = id; self.name = name; self.imageName = imageName
//        self.price = price; self.baseId = baseId
//    }
//
//    init(from decoder: Decoder) throws {
//        let c  = try decoder.container(keyedBy: CodingKeys.self)
//        id     = try? c.decode(String.self, forKey: .id)
//        name   = try? c.decode(String.self, forKey: .name)
//        baseId = try? c.decode(String.self, forKey: .baseId)
//        // imageName: try imageName key first, then image key
//        if let v = try? c.decode(String.self, forKey: .imageName) {
//            imageName = v
//        } else {
//            imageName = try c.decode(String.self, forKey: .image)
//        }
//        // price: try Int first, then String
//        if let p = try? c.decode(Int.self, forKey: .price) {
//            price = p
//        } else if let s = try? c.decode(String.self, forKey: .price),
//                  let p = Int(s.replacingOccurrences(of: ",", with: "")) {
//            price = p
//        } else {
//            price = 0
//        }
//    }
//}
//
//private extension String {
//    var trimmedNonEmpty: String? {
//        let v = trimmingCharacters(in: .whitespacesAndNewlines)
//        return v.isEmpty ? nil : v
//    }
//}

import Foundation

// MARK: - Notification names
extension Notification.Name {
    static let gardenBaseDidChange  = Notification.Name("gardenBaseDidChange")
    static let gardenLevelDidChange = Notification.Name("gardenLevelDidChange")
}

final class GardenManager {
    static let shared = GardenManager()

    // MARK: - Category
    enum Category: String, CaseIterable {
        case yourItems = "Your Items"
        case nature    = "Nature"
        case wellness  = "Wellness"
    }

    enum PurchaseResult {
        case purchased(remainingCoins: Int)
        case insufficientCoins(missingCoins: Int, currentCoins: Int, itemPrice: Int)
        case alreadyUnlocked
        case notPurchasable
    }

    static let segmentCategories: [String] = Category.allCases.map(\.rawValue)

    // MARK: - Storage keys (v3)
    private enum StorageKeys {
        static let coins          = "garden_coins_v3"
        static let unlockedIds    = "garden_unlocked_item_ids_v3"
        static let unlockedBases  = "garden_unlocked_base_ids_v3"
        static let selectedBaseId = "garden_selected_base_id_v3"
        static let levelProgress  = "garden_level_progress_v3"
        static func placedItems(for baseId: String) -> String {
            "garden_placed_items_\(baseId)_v3"
        }
    }

    // MARK: - Public state
    private(set) var coins: Int = 0
    private(set) var unlockedItemIds: Set<String> = []
    var currentCoins: Int { coins }

    private(set) var allBases: [GardenBase] = []

    private(set) var selectedBase: GardenBase {
        didSet {
            UserDefaults.standard.set(selectedBase.id, forKey: StorageKeys.selectedBaseId)
            NotificationCenter.default.post(name: .gardenBaseDidChange, object: selectedBase)
        }
    }

    private(set) var levelProgress: GardenLevelProgress = .initial

    // MARK: - Private catalog
    private var yourItemsCatalog: [StoreItem] = []
    private var shopCatalog: [StoreItem]      = []
    private var allItemsOrdered: [StoreItem]  = []

    // MARK: - Derived helpers

    var unlockedBases: [GardenBase] { allBases.filter(\.isUnlocked) }

    /// Items for the bottom tray on GardenViewController:
    /// • All unlocked bases (tap to switch base)
    /// • All unlocked shop items across ALL bases
    var trayItems: [StoreItem] {
        var result: [StoreItem] = []
        for base in unlockedBases {
            result.append(makeBaseStoreItem(from: base))
        }
        // Only show unlocked items that belong to the currently selected base
        let shopUnlocked = allItemsOrdered.filter {
            $0.category != Category.yourItems.rawValue &&
            unlockedItemIds.contains($0.id) &&
            effectiveBaseId(of: $0) == selectedBase.id
        }
        result.append(contentsOf: shopUnlocked)
        return result
    }

    // MARK: - Init
    private init() {
        selectedBase = GardenBase(id: "classic", name: "Classic", imageName: "garden_base",
                                  unlockLevel: 1, isUnlocked: true)
        loadBases()
        loadCatalog()
        restorePersistedState()
        seedDefaultUnlockedItems()
        checkDailyReset()
        persistState()
    }

    // MARK: - Public API

    func getItems(for category: String) -> [StoreItem] {
        guard let parsed = Category(rawValue: category) else { return [] }
        let baseId = selectedBase.id

        switch parsed {
        case .yourItems:
            var result: [StoreItem] = []
            for base in unlockedBases {
                result.append(makeBaseStoreItem(from: base))
            }
            let shopUnlocked = allItemsOrdered.filter {
                $0.category != Category.yourItems.rawValue &&
                unlockedItemIds.contains($0.id) &&
                effectiveBaseId(of: $0) == baseId
            }
            result.append(contentsOf: shopUnlocked)
            return result

        case .nature, .wellness:
            return shopCatalog.filter {
                $0.category == parsed.rawValue &&
                effectiveBaseId(of: $0) == baseId &&
                !unlockedItemIds.contains($0.id)
            }
        }
    }

    func purchaseResult(for item: StoreItem) -> PurchaseResult {
        guard item.category != Category.yourItems.rawValue else { return .notPurchasable }
        guard !unlockedItemIds.contains(item.id)           else { return .alreadyUnlocked }
        guard coins >= item.price else {
            return .insufficientCoins(missingCoins: item.price - coins,
                                      currentCoins: coins, itemPrice: item.price)
        }
        coins -= item.price
        unlockedItemIds.insert(item.id)
        persistState()
        return .purchased(remainingCoins: coins)
    }

    @discardableResult
    func purchaseItem(_ item: StoreItem) -> Bool {
        if case .purchased = purchaseResult(for: item) { return true }
        return false
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        creditDailyCoins(amount*10100)
        persistState()
    }

    // MARK: - Base Selection

    func selectBase(_ base: GardenBase) {
        guard base.isUnlocked,
              let found = allBases.first(where: { $0.id == base.id }) else { return }
        selectedBase = found
        UserDefaults.standard.set(found.id, forKey: StorageKeys.selectedBaseId)
    }

    // MARK: - Per-Base Placed Items

    func savePlacedItems(_ items: [PlacedItem], for baseId: String) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: StorageKeys.placedItems(for: baseId))
        }
    }

    func loadPlacedItems(for baseId: String) -> [PlacedItem] {
        guard let data  = UserDefaults.standard.data(forKey: StorageKeys.placedItems(for: baseId)),
              let items = try? JSONDecoder().decode([PlacedItem].self, from: data) else { return [] }
        return items
    }

    // MARK: - Daily Reset

    func checkDailyReset() {
        let today = GardenLevelProgress.todayString()
        if levelProgress.lastResetDateString != today {
            levelProgress.dailyCoinsEarned    = 0
            levelProgress.lastResetDateString = today
            persistLevelProgress()
        }
    }

    // MARK: - Private: Level Crediting

    private func creditDailyCoins(_ amount: Int) {
        checkDailyReset()
        levelProgress.dailyCoinsEarned += amount

        let freshPoints = Int(Double(levelProgress.dailyCoinsEarned) * 0.05)
        if freshPoints > levelProgress.currentPoints {
            levelProgress.currentPoints = freshPoints
        }

        while levelProgress.currentPoints >= levelProgress.pointsNeededForNextLevel {
            levelProgress.currentPoints -= levelProgress.pointsNeededForNextLevel
            levelProgress.currentLevel  += 1
            levelProgress.pointsNeededForNextLevel = GardenLevelProgress.pointsPerLevel
        }

        checkAndUnlockBasesForLevel()
        persistLevelProgress()
        NotificationCenter.default.post(name: .gardenLevelDidChange, object: levelProgress)
    }

    private func checkAndUnlockBasesForLevel() {
        var changed = false
        for i in allBases.indices {
            if !allBases[i].isUnlocked && allBases[i].unlockLevel <= levelProgress.currentLevel {
                allBases[i].isUnlocked = true
                changed = true
            }
        }
        if changed { persistBases() }
    }

    private func effectiveBaseId(of item: StoreItem) -> String {
        item.baseId ?? "classic"
    }

    private func makeBaseStoreItem(from base: GardenBase) -> StoreItem {
        StoreItem(id: "base_\(base.id)", name: base.name, imageName: base.imageName,
                  price: 0, category: Category.yourItems.rawValue, baseId: base.id)
    }

    // MARK: - Load Bases

    private func loadBases() {
        allBases = [
            GardenBase(id: "classic",  name: "Classic Garden",  imageName: "garden_base",
                       unlockLevel: 1, isUnlocked: true),
            GardenBase(id: "zen",      name: "Zen Garden",      imageName: "garden_base_zen",
                       unlockLevel: 3, isUnlocked: false),
            GardenBase(id: "tropical", name: "Tropical Garden", imageName: "garden_base_tropical",
                       unlockLevel: 5, isUnlocked: false),
        ]

        let savedIds = Set(UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedBases) ?? [])
        for i in allBases.indices where savedIds.contains(allBases[i].id) {
            allBases[i].isUnlocked = true
        }
        if let idx = allBases.firstIndex(where: { $0.id == "classic" }) {
            allBases[idx].isUnlocked = true
        }

        let savedBaseId = UserDefaults.standard.string(forKey: StorageKeys.selectedBaseId) ?? "classic"
        selectedBase = allBases.first(where: { $0.id == savedBaseId && $0.isUnlocked })
                    ?? allBases.first(where: { $0.id == "classic" })
                    ?? allBases[0]
    }

    private func persistBases() {
        UserDefaults.standard.set(allBases.filter(\.isUnlocked).map(\.id),
                                  forKey: StorageKeys.unlockedBases)
    }

    // MARK: - Load Catalog

    private func loadCatalog() {
        let payload      = loadPayloadFromJSON() ?? Self.fallbackPayload
        yourItemsCatalog = payload.yourItems.enumerated().map { makeYourItem(from: $1, index: $0) }
        let nature       = payload.nature.enumerated().map   { makeShopItem(from: $1, category: .nature,   index: $0) }
        let wellness     = payload.wellness.enumerated().map { makeShopItem(from: $1, category: .wellness, index: $0) }
        shopCatalog      = nature + wellness
        allItemsOrdered  = yourItemsCatalog + shopCatalog
    }

    // MARK: - State Persistence

    private func restorePersistedState() {
        let d = UserDefaults.standard
        coins = d.object(forKey: StorageKeys.coins) != nil ? d.integer(forKey: StorageKeys.coins) : 0
        unlockedItemIds = Set(d.stringArray(forKey: StorageKeys.unlockedIds) ?? [])

        if let data     = d.data(forKey: StorageKeys.levelProgress),
           let progress = try? JSONDecoder().decode(GardenLevelProgress.self, from: data) {
            levelProgress = progress
        } else {
            levelProgress = .initial
        }
    }

    private func persistState() {
        let d = UserDefaults.standard
        d.set(coins,                    forKey: StorageKeys.coins)
        d.set(Array(unlockedItemIds),   forKey: StorageKeys.unlockedIds)
        persistBases()
        persistLevelProgress()
    }

    private func persistLevelProgress() {
        if let data = try? JSONEncoder().encode(levelProgress) {
            UserDefaults.standard.set(data, forKey: StorageKeys.levelProgress)
        }
    }

    private func seedDefaultUnlockedItems() {
        unlockedItemIds.formUnion(yourItemsCatalog.map(\.id))
        checkAndUnlockBasesForLevel()
    }

    // MARK: - Item Factory

    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
        let id   = resolvedId(explicitId: dto.id, category: .yourItems,
                              imageName: dto.imageName, index: index)
        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
        return StoreItem(id: id, name: name, imageName: dto.imageName, price: 0,
                         category: Category.yourItems.rawValue, baseId: dto.baseId ?? "classic")
    }

    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
        let id   = resolvedId(explicitId: dto.id, category: category,
                              imageName: dto.imageName, index: index)
        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: dto.imageName)
        return StoreItem(id: id, name: name, imageName: dto.imageName, price: max(dto.price, 0),
                         category: category.rawValue, baseId: dto.baseId ?? "classic")
    }

    private func resolvedId(explicitId: String?, category: Category,
                            imageName: String, index: Int) -> String {
        if let e = explicitId, let clean = e.trimmedNonEmpty { return clean }
        let cat   = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
        let image = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
        return "\(cat)_\(image)_\(index)"
    }

    private static func displayName(fromImageName imageName: String) -> String {
        let s = imageName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return "Item" }
        return s.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
    }

    // MARK: - JSON Loading

    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else { return nil }
        do {
            return try JSONDecoder().decode(GardenCatalogPayload.self, from: Data(contentsOf: url))
        } catch {
            print("Failed to decode garden_items.json: \(error)")
            return nil
        }
    }

    private static let fallbackPayload = GardenCatalogPayload(
        yourItems: [],
        nature: [
            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea",
                        price: 3000, baseId: "classic"),
            ShopItemDTO(id: "nature_tulips",    name: "Tulips",    imageName: "tulips",
                        price: 2300, baseId: "classic")
        ],
        wellness: [
            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath",
                        price: 1500, baseId: "classic"),
            ShopItemDTO(id: "wellness_fountain",  name: "Fountain",  imageName: "fountain",
                        price: 3000, baseId: "classic")
        ]
    )
}

// MARK: - Private DTO types

private struct GardenCatalogPayload: Decodable {
    let yourItems: [UnlockedItemDTO]
    let nature:    [ShopItemDTO]
    let wellness:  [ShopItemDTO]

    enum CodingKeys: String, CodingKey {
        case yourItemsSnake = "your_items"
        case yourItemsTitle = "Your Items"
        case natureLower    = "nature"
        case natureTitle    = "Nature"
        case wellnessLower  = "wellness"
        case wellnessTitle  = "Wellness"
    }

    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
        self.yourItems = yourItems; self.nature = nature; self.wellness = wellness
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        yourItems = (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake))
                 ?? (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle))
                 ?? []
        nature    = (try? c.decode([ShopItemDTO].self, forKey: .natureLower))
                 ?? (try? c.decode([ShopItemDTO].self, forKey: .natureTitle))
                 ?? []
        wellness  = (try? c.decode([ShopItemDTO].self, forKey: .wellnessLower))
                 ?? (try? c.decode([ShopItemDTO].self, forKey: .wellnessTitle))
                 ?? []
    }
}

private struct UnlockedItemDTO: Decodable {
    let id: String?
    let name: String?
    let imageName: String
    let baseId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, imageName, baseId = "base_id"
    }

    init(id: String? = nil, name: String? = nil, imageName: String, baseId: String? = nil) {
        self.id = id; self.name = name; self.imageName = imageName; self.baseId = baseId
    }

    init(from decoder: Decoder) throws {
        let c  = try decoder.container(keyedBy: CodingKeys.self)
        id     = try? c.decode(String.self, forKey: .id)
        name   = try? c.decode(String.self, forKey: .name)
        baseId = try? c.decode(String.self, forKey: .baseId)
        // Try imageName first, fall back to image — both wrapped in do/catch to avoid ambiguous try
        if let v = try? c.decode(String.self, forKey: .imageName) {
            imageName = v
        } else {
            imageName = try c.decode(String.self, forKey: .image)
        }
    }
}

private struct ShopItemDTO: Decodable {
    let id: String?
    let name: String?
    let imageName: String
    let price: Int
    let baseId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, imageName, price, baseId = "base_id"
    }

    init(id: String? = nil, name: String? = nil, imageName: String,
         price: Int, baseId: String? = nil) {
        self.id = id; self.name = name; self.imageName = imageName
        self.price = price; self.baseId = baseId
    }

    init(from decoder: Decoder) throws {
        let c  = try decoder.container(keyedBy: CodingKeys.self)
        id     = try? c.decode(String.self, forKey: .id)
        name   = try? c.decode(String.self, forKey: .name)
        baseId = try? c.decode(String.self, forKey: .baseId)
        // imageName: try imageName key first, then image key
        if let v = try? c.decode(String.self, forKey: .imageName) {
            imageName = v
        } else {
            imageName = try c.decode(String.self, forKey: .image)
        }
        // price: try Int first, then String
        if let p = try? c.decode(Int.self, forKey: .price) {
            price = p
        } else if let s = try? c.decode(String.self, forKey: .price),
                  let p = Int(s.replacingOccurrences(of: ",", with: "")) {
            price = p
        } else {
            price = 0
        }
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let v = trimmingCharacters(in: .whitespacesAndNewlines)
        return v.isEmpty ? nil : v
    }
}
