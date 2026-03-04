//////////
//////////  GardenManager.swift
//////////  healinggarden2
//////////
//////////  Created by Naman Bhansali on 27/01/26.
//////////
////////
////////import Foundation
////////
////////class GardenManager {
////////    static let shared = GardenManager()
////////    
////////    private init() {
////////        // Mocking some initially unlocked items for testing
////////        unlockedItemIds.insert("1")
////////        unlockedItemIds.insert("2")
////////    }
////////    
////////    // User State
////////    var coins: Int = 32000
////////    var unlockedItemIds: Set<String> = []
////////    
////////    // FIXED: Added a computed property 'unlockedItems' so the ViewController can access it
////////    var unlockedItems: [StoreItem] {
////////        return storeCatalog.filter { unlockedItemIds.contains($0.id) }
////////    }
////////    
////////    // Store Data
////////    let storeCatalog: [StoreItem] = [
////////        StoreItem(id: "1", name: "Fountain", imageName: "fountain", price: 3000, category: "Wellness"),
////////        StoreItem(id: "2", name: "Bench", imageName: "bench", price: 2300, category: "Nature"),
////////        StoreItem(id: "3", name: "Hydrangea", imageName: "hydrangea", price: 3000, category: "Nature"),
////////        StoreItem(id: "4", name: "Tulips", imageName: "tulips", price: 2300, category: "Nature"),
////////        StoreItem(id: "5", name: "Bird Bath", imageName: "bird_bath", price: 1500, category: "Wellness")
////////    ]
////////    
////////    func getItems(for category: String) -> [StoreItem] {
////////        if category == "Your Items" {
////////            return unlockedItems
////////        }
////////        return storeCatalog.filter { $0.category == category }
////////    }
////////    
////////    func purchaseItem(_ item: StoreItem) -> Bool {
////////        if coins >= item.price && !unlockedItemIds.contains(item.id) {
////////            coins -= item.price
////////            unlockedItemIds.insert(item.id)
////////            return true
////////        }
////////        return false
////////    }
////////}
//////
////////
////////  GardenManager.swift
////////  BreastCancerApp
////////
//////
//////import Foundation
//////
//////final class GardenManager {
//////    static let shared = GardenManager()
//////
//////    enum Category: String, CaseIterable {
//////        case yourItems = "Your Items"
//////        case nature = "Nature"
//////        case wellness = "Wellness"
//////    }
//////
//////    static let segmentCategories: [String] = Category.allCases.map(\.rawValue)
//////
//////    private(set) var coins: Int = 32000
//////    private(set) var unlockedItemIds: Set<String> = []
//////
//////    private var yourItemsCatalog: [StoreItem] = []
//////    private var shopCatalog: [StoreItem] = []
//////    private var allItemsOrdered: [StoreItem] = []
//////
//////    var unlockedItems: [StoreItem] {
//////        allItemsOrdered.filter { unlockedItemIds.contains($0.id) }
//////    }
//////
//////    private init() {
//////        loadCatalog()
//////        seedDefaultUnlockedItems()
//////    }
//////
//////    func getItems(for category: String) -> [StoreItem] {
//////        guard let parsedCategory = Category(rawValue: category) else { return [] }
//////
//////        switch parsedCategory {
//////        case .yourItems:
//////            return unlockedItems
//////        case .nature, .wellness:
//////            return shopCatalog.filter { $0.category == parsedCategory.rawValue }
//////        }
//////    }
//////
//////    @discardableResult
//////    func purchaseItem(_ item: StoreItem) -> Bool {
//////        guard item.category != Category.yourItems.rawValue else { return false }
//////        guard !unlockedItemIds.contains(item.id) else { return false }
//////        guard coins >= item.price else { return false }
//////
//////        coins -= item.price
//////        unlockedItemIds.insert(item.id)
//////        return true
//////    }
//////
//////    private func loadCatalog() {
//////        let payload = loadPayloadFromJSON() ?? Self.fallbackPayload
//////
//////        yourItemsCatalog = payload.yourItems.enumerated().map { index, dto in
//////            makeYourItem(from: dto, index: index)
//////        }
//////
//////        let natureItems = payload.nature.enumerated().map { index, dto in
//////            makeShopItem(from: dto, category: .nature, index: index)
//////        }
//////
//////        let wellnessItems = payload.wellness.enumerated().map { index, dto in
//////            makeShopItem(from: dto, category: .wellness, index: index)
//////        }
//////
//////        shopCatalog = natureItems + wellnessItems
//////        allItemsOrdered = yourItemsCatalog + shopCatalog
//////    }
//////
//////    private func seedDefaultUnlockedItems() {
//////        let defaultUnlockedIds = Set(yourItemsCatalog.map(\.id))
//////        unlockedItemIds.formUnion(defaultUnlockedIds)
//////    }
//////
//////    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
//////        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else {
//////            print("garden_items.json not found in bundle. Using fallback catalog.")
//////            return nil
//////        }
//////
//////        do {
//////            let data = try Data(contentsOf: url)
//////            return try JSONDecoder().decode(GardenCatalogPayload.self, from: data)
//////        } catch {
//////            print("Failed to decode garden_items.json: \(error). Using fallback catalog.")
//////            return nil
//////        }
//////    }
//////
//////    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
//////        let imageName = dto.imageName
//////        let id = resolvedId(explicitId: dto.id, category: .yourItems, imageName: imageName, index: index)
//////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)
//////
//////        return StoreItem(
//////            id: id,
//////            name: name,
//////            imageName: imageName,
//////            price: 0,
//////            category: Category.yourItems.rawValue
//////        )
//////    }
//////
//////    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
//////        let imageName = dto.imageName
//////        let id = resolvedId(explicitId: dto.id, category: category, imageName: imageName, index: index)
//////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)
//////
//////        return StoreItem(
//////            id: id,
//////            name: name,
//////            imageName: imageName,
//////            price: max(dto.price, 0),
//////            category: category.rawValue
//////        )
//////    }
//////
//////    private func resolvedId(explicitId: String?, category: Category, imageName: String, index: Int) -> String {
//////        if let explicitId, let clean = explicitId.trimmedNonEmpty {
//////            return clean
//////        }
//////
//////        let safeCategory = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
//////        let safeImage = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
//////        return "\(safeCategory)_\(safeImage)_\(index)"
//////    }
//////
//////    private static func displayName(fromImageName imageName: String) -> String {
//////        let cleaned = imageName
//////            .replacingOccurrences(of: "_", with: " ")
//////            .replacingOccurrences(of: "-", with: " ")
//////            .trimmingCharacters(in: .whitespacesAndNewlines)
//////
//////        guard !cleaned.isEmpty else { return "Item" }
//////
//////        return cleaned
//////            .split(separator: " ")
//////            .map { $0.capitalized }
//////            .joined(separator: " ")
//////    }
//////
//////    private static let fallbackPayload = GardenCatalogPayload(
//////        yourItems: [
//////            UnlockedItemDTO(id: "your_garden_base", name: "Garden Base", imageName: "garden_base")
//////        ],
//////        nature: [
//////            ShopItemDTO(id: "nature_bench", name: "Bench", imageName: "bench", price: 2300),
//////            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea", price: 3000),
//////            ShopItemDTO(id: "nature_tulips", name: "Tulips", imageName: "tulips", price: 2300)
//////        ],
//////        wellness: [
//////            ShopItemDTO(id: "wellness_fountain", name: "Fountain", imageName: "fountain", price: 3000),
//////            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath", price: 1500)
//////        ]
//////    )
//////}
//////
//////private struct GardenCatalogPayload: Decodable {
//////    let yourItems: [UnlockedItemDTO]
//////    let nature: [ShopItemDTO]
//////    let wellness: [ShopItemDTO]
//////
//////    enum CodingKeys: String, CodingKey {
//////        case yourItemsSnake = "your_items"
//////        case yourItemsTitle = "Your Items"
//////        case natureLower = "nature"
//////        case natureTitle = "Nature"
//////        case wellnessLower = "wellness"
//////        case wellnessTitle = "Wellness"
//////    }
//////
//////    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
//////        self.yourItems = yourItems
//////        self.nature = nature
//////        self.wellness = wellness
//////    }
//////
//////    init(from decoder: Decoder) throws {
//////        let container = try decoder.container(keyedBy: CodingKeys.self)
//////
//////        yourItems =
//////            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake)) ??
//////            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle)) ??
//////            []
//////
//////        nature =
//////            (try? container.decode([ShopItemDTO].self, forKey: .natureLower)) ??
//////            (try? container.decode([ShopItemDTO].self, forKey: .natureTitle)) ??
//////            []
//////
//////        wellness =
//////            (try? container.decode([ShopItemDTO].self, forKey: .wellnessLower)) ??
//////            (try? container.decode([ShopItemDTO].self, forKey: .wellnessTitle)) ??
//////            []
//////    }
//////}
//////
//////private struct UnlockedItemDTO: Decodable {
//////    let id: String?
//////    let name: String?
//////    let imageName: String
//////
//////    enum CodingKeys: String, CodingKey {
//////        case id
//////        case name
//////        case image
//////        case imageName
//////    }
//////
//////    init(id: String? = nil, name: String? = nil, imageName: String) {
//////        self.id = id
//////        self.name = name
//////        self.imageName = imageName
//////    }
//////
//////    init(from decoder: Decoder) throws {
//////        let container = try decoder.container(keyedBy: CodingKeys.self)
//////        id = try container.decodeIfPresent(String.self, forKey: .id)
//////        name = try container.decodeIfPresent(String.self, forKey: .name)
//////
//////        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
//////            imageName = imageNameValue
//////        } else {
//////            imageName = try container.decode(String.self, forKey: .image)
//////        }
//////    }
//////}
//////
//////private struct ShopItemDTO: Decodable {
//////    let id: String?
//////    let name: String?
//////    let imageName: String
//////    let price: Int
//////
//////    enum CodingKeys: String, CodingKey {
//////        case id
//////        case name
//////        case image
//////        case imageName
//////        case price
//////    }
//////
//////    init(id: String? = nil, name: String? = nil, imageName: String, price: Int) {
//////        self.id = id
//////        self.name = name
//////        self.imageName = imageName
//////        self.price = price
//////    }
//////
//////    init(from decoder: Decoder) throws {
//////        let container = try decoder.container(keyedBy: CodingKeys.self)
//////
//////        id = try container.decodeIfPresent(String.self, forKey: .id)
//////        name = try container.decodeIfPresent(String.self, forKey: .name)
//////
//////        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
//////            imageName = imageNameValue
//////        } else {
//////            imageName = try container.decode(String.self, forKey: .image)
//////        }
//////
//////        if let directPrice = try container.decodeIfPresent(Int.self, forKey: .price) {
//////            price = directPrice
//////        } else if let stringPrice = try container.decodeIfPresent(String.self, forKey: .price),
//////                  let parsed = Int(stringPrice.replacingOccurrences(of: ",", with: "")) {
//////            price = parsed
//////        } else {
//////            price = 0
//////        }
//////    }
//////}
//////private extension String {
//////    var trimmedNonEmpty: String? {
//////        let value = trimmingCharacters(in: .whitespacesAndNewlines)
//////        return value.isEmpty ? nil : value
//////    }
//////}
////
//////
//////  GardenManager.swift
//////  BreastCancerApp
//////
////
////import Foundation
////
////final class GardenManager {
////    static let shared = GardenManager()
////
////    enum Category: String, CaseIterable {
////        case yourItems = "Your Items"
////        case nature = "Nature"
////        case wellness = "Wellness"
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
////    private enum StorageKeys {
////        static let coins = "garden_coins_v1"
////        static let unlockedIds = "garden_unlocked_item_ids_v1"
////    }
////
////    private(set) var coins: Int = 32000
////    private(set) var unlockedItemIds: Set<String> = []
////
////    var currentCoins: Int { coins }
////
////    private var yourItemsCatalog: [StoreItem] = []
////    private var shopCatalog: [StoreItem] = []
////    private var allItemsOrdered: [StoreItem] = []
////
////    var unlockedItems: [StoreItem] {
////        allItemsOrdered.filter { unlockedItemIds.contains($0.id) }
////    }
////
////    private init() {
////        loadCatalog()
////        restorePersistedState()
////        seedDefaultUnlockedItems()
////        persistState()
////    }
////
////    func getItems(for category: String) -> [StoreItem] {
////        guard let parsedCategory = Category(rawValue: category) else { return [] }
////
////        switch parsedCategory {
////        case .yourItems:
////            return unlockedItems
////        case .nature, .wellness:
////            return shopCatalog.filter { $0.category == parsedCategory.rawValue }
////        }
////    }
////
////    func purchaseResult(for item: StoreItem) -> PurchaseResult {
////        guard item.category != Category.yourItems.rawValue else {
////            return .notPurchasable
////        }
////
////        guard !unlockedItemIds.contains(item.id) else {
////            return .alreadyUnlocked
////        }
////
////        guard coins >= item.price else {
////            return .insufficientCoins(
////                missingCoins: item.price - coins,
////                currentCoins: coins,
////                itemPrice: item.price
////            )
////        }
////
////        coins -= item.price
////        unlockedItemIds.insert(item.id)
////        persistState()
////        return .purchased(remainingCoins: coins)
////    }
////
////    @discardableResult
////    func purchaseItem(_ item: StoreItem) -> Bool {
////        if case .purchased = purchaseResult(for: item) {
////            return true
////        }
////        return false
////    }
////
////    func addCoins(_ amount: Int) {
////        guard amount > 0 else { return }
////        coins += amount
////        persistState()
////    }
////
////    private func loadCatalog() {
////        let payload = loadPayloadFromJSON() ?? Self.fallbackPayload
////
////        yourItemsCatalog = payload.yourItems.enumerated().map { index, dto in
////            makeYourItem(from: dto, index: index)
////        }
////
////        let natureItems = payload.nature.enumerated().map { index, dto in
////            makeShopItem(from: dto, category: .nature, index: index)
////        }
////
////        let wellnessItems = payload.wellness.enumerated().map { index, dto in
////            makeShopItem(from: dto, category: .wellness, index: index)
////        }
////
////        shopCatalog = natureItems + wellnessItems
////        allItemsOrdered = yourItemsCatalog + shopCatalog
////    }
////
////    private func restorePersistedState() {
////        let defaults = UserDefaults.standard
////
////        if defaults.object(forKey: StorageKeys.coins) != nil {
////            coins = defaults.integer(forKey: StorageKeys.coins)
////        } else {
////            coins = 32000
////        }
////
////        let ids = defaults.stringArray(forKey: StorageKeys.unlockedIds) ?? []
////        unlockedItemIds = Set(ids)
////    }
////
////    private func persistState() {
////        let defaults = UserDefaults.standard
////        defaults.set(coins, forKey: StorageKeys.coins)
////        defaults.set(Array(unlockedItemIds), forKey: StorageKeys.unlockedIds)
////    }
////
////    private func seedDefaultUnlockedItems() {
////        let defaultUnlockedIds = Set(yourItemsCatalog.map(\.id))
////        unlockedItemIds.formUnion(defaultUnlockedIds)
////    }
////
////    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
////        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else {
////            print("garden_items.json not found in bundle. Using fallback catalog.")
////            return nil
////        }
////
////        do {
////            let data = try Data(contentsOf: url)
////            return try JSONDecoder().decode(GardenCatalogPayload.self, from: data)
////        } catch {
////            print("Failed to decode garden_items.json: \(error). Using fallback catalog.")
////            return nil
////        }
////    }
////
////    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
////        let imageName = dto.imageName
////        let id = resolvedId(explicitId: dto.id, category: .yourItems, imageName: imageName, index: index)
////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)
////
////        return StoreItem(
////            id: id,
////            name: name,
////            imageName: imageName,
////            price: 0,
////            category: Category.yourItems.rawValue
////        )
////    }
////
////    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
////        let imageName = dto.imageName
////        let id = resolvedId(explicitId: dto.id, category: category, imageName: imageName, index: index)
////        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)
////
////        return StoreItem(
////            id: id,
////            name: name,
////            imageName: imageName,
////            price: max(dto.price, 0),
////            category: category.rawValue
////        )
////    }
////
////    private func resolvedId(explicitId: String?, category: Category, imageName: String, index: Int) -> String {
////        if let explicitId, let clean = explicitId.trimmedNonEmpty {
////            return clean
////        }
////
////        let safeCategory = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
////        let safeImage = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
////        return "\(safeCategory)_\(safeImage)_\(index)"
////    }
////
////    private static func displayName(fromImageName imageName: String) -> String {
////        let cleaned = imageName
////            .replacingOccurrences(of: "_", with: " ")
////            .replacingOccurrences(of: "-", with: " ")
////            .trimmingCharacters(in: .whitespacesAndNewlines)
////
////        guard !cleaned.isEmpty else { return "Item" }
////
////        return cleaned
////            .split(separator: " ")
////            .map { $0.capitalized }
////            .joined(separator: " ")
////    }
////
////    private static let fallbackPayload = GardenCatalogPayload(
////        yourItems: [
////            UnlockedItemDTO(id: "your_garden_base", name: "Garden Base", imageName: "garden_base")
////        ],
////        nature: [
////            ShopItemDTO(id: "nature_bench", name: "Bench", imageName: "bench", price: 2300),
////            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea", price: 3000),
////            ShopItemDTO(id: "nature_tulips", name: "Tulips", imageName: "tulips", price: 2300)
////        ],
////        wellness: [
////            ShopItemDTO(id: "wellness_fountain", name: "Fountain", imageName: "fountain", price: 3000),
////            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath", price: 1500)
////        ]
////    )
////}
////
////private struct GardenCatalogPayload: Decodable {
////    let yourItems: [UnlockedItemDTO]
////    let nature: [ShopItemDTO]
////    let wellness: [ShopItemDTO]
////
////    enum CodingKeys: String, CodingKey {
////        case yourItemsSnake = "your_items"
////        case yourItemsTitle = "Your Items"
////        case natureLower = "nature"
////        case natureTitle = "Nature"
////        case wellnessLower = "wellness"
////        case wellnessTitle = "Wellness"
////    }
////
////    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
////        self.yourItems = yourItems
////        self.nature = nature
////        self.wellness = wellness
////    }
////
////    init(from decoder: Decoder) throws {
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////
////        yourItems =
////            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake)) ??
////            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle)) ??
////            []
////
////        nature =
////            (try? container.decode([ShopItemDTO].self, forKey: .natureLower)) ??
////            (try? container.decode([ShopItemDTO].self, forKey: .natureTitle)) ??
////            []
////
////        wellness =
////            (try? container.decode([ShopItemDTO].self, forKey: .wellnessLower)) ??
////            (try? container.decode([ShopItemDTO].self, forKey: .wellnessTitle)) ??
////            []
////    }
////}
////
////private struct UnlockedItemDTO: Decodable {
////    let id: String?
////    let name: String?
////    let imageName: String
////
////    enum CodingKeys: String, CodingKey {
////        case id
////        case name
////        case image
////        case imageName
////    }
////
////    init(id: String? = nil, name: String? = nil, imageName: String) {
////        self.id = id
////        self.name = name
////        self.imageName = imageName
////    }
////
////    init(from decoder: Decoder) throws {
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////        id = try container.decodeIfPresent(String.self, forKey: .id)
////        name = try container.decodeIfPresent(String.self, forKey: .name)
////
////        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
////            imageName = imageNameValue
////        } else {
////            imageName = try container.decode(String.self, forKey: .image)
////        }
////    }
////}
////
////private struct ShopItemDTO: Decodable {
////    let id: String?
////    let name: String?
////    let imageName: String
////    let price: Int
////
////    enum CodingKeys: String, CodingKey {
////        case id
////        case name
////        case image
////        case imageName
////        case price
////    }
////
////    init(id: String? = nil, name: String? = nil, imageName: String, price: Int) {
////        self.id = id
////        self.name = name
////        self.imageName = imageName
////        self.price = price
////    }
////
////    init(from decoder: Decoder) throws {
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////
////        id = try container.decodeIfPresent(String.self, forKey: .id)
////        name = try container.decodeIfPresent(String.self, forKey: .name)
////
////        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
////            imageName = imageNameValue
////        } else {
////            imageName = try container.decode(String.self, forKey: .image)
////        }
////
////        if let directPrice = try container.decodeIfPresent(Int.self, forKey: .price) {
////            price = directPrice
////        } else if let stringPrice = try container.decodeIfPresent(String.self, forKey: .price),
////                  let parsed = Int(stringPrice.replacingOccurrences(of: ",", with: "")) {
////            price = parsed
////        } else {
////            price = 0
////        }
////    }
////}
////
////private extension String {
////    var trimmedNonEmpty: String? {
////        let value = trimmingCharacters(in: .whitespacesAndNewlines)
////        return value.isEmpty ? nil : value
////    }
////}
//
////
////  GardenManager.swift
////  BreastCancerApp
////
//
//import Foundation
//
//final class GardenManager {
//    static let shared = GardenManager()
//
//    enum Category: String, CaseIterable {
//        case yourItems = "Your Items"
//        case nature = "Nature"
//        case wellness = "Wellness"
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
//    private enum StorageKeys {
//        static let coins = "garden_coins_v1"
//        static let unlockedIds = "garden_unlocked_item_ids_v1"
//    }
//
//    private(set) var coins: Int = 32000
//    private(set) var unlockedItemIds: Set<String> = []
//
//    var currentCoins: Int { coins }
//
//    private var yourItemsCatalog: [StoreItem] = []
//    private var shopCatalog: [StoreItem] = []
//    private var allItemsOrdered: [StoreItem] = []
//
//    var unlockedItems: [StoreItem] {
//        allItemsOrdered.filter { unlockedItemIds.contains($0.id) }
//    }
//
//    private init() {
//        loadCatalog()
//        restorePersistedState()
//        seedDefaultUnlockedItems()
//        persistState()
//    }
//
//    func getItems(for category: String) -> [StoreItem] {
//        guard let parsedCategory = Category(rawValue: category) else { return [] }
//
//        switch parsedCategory {
//        case .yourItems:
//            return unlockedItems
//
//        case .nature, .wellness:
//            return shopCatalog.filter {
//                $0.category == parsedCategory.rawValue && !unlockedItemIds.contains($0.id)
//            }
//        }
//    }
//
//    func purchaseResult(for item: StoreItem) -> PurchaseResult {
//        guard item.category != Category.yourItems.rawValue else {
//            return .notPurchasable
//        }
//
//        guard !unlockedItemIds.contains(item.id) else {
//            return .alreadyUnlocked
//        }
//
//        guard coins >= item.price else {
//            return .insufficientCoins(
//                missingCoins: item.price - coins,
//                currentCoins: coins,
//                itemPrice: item.price
//            )
//        }
//
//        coins -= item.price
//        unlockedItemIds.insert(item.id)
//        persistState()
//        return .purchased(remainingCoins: coins)
//    }
//
//    @discardableResult
//    func purchaseItem(_ item: StoreItem) -> Bool {
//        if case .purchased = purchaseResult(for: item) {
//            return true
//        }
//        return false
//    }
//
//    func addCoins(_ amount: Int) {
//        guard amount > 0 else { return }
//        coins += amount
//        persistState()
//    }
//
//    private func loadCatalog() {
//        let payload = loadPayloadFromJSON() ?? Self.fallbackPayload
//
//        yourItemsCatalog = payload.yourItems.enumerated().map { index, dto in
//            makeYourItem(from: dto, index: index)
//        }
//
//        let natureItems = payload.nature.enumerated().map { index, dto in
//            makeShopItem(from: dto, category: .nature, index: index)
//        }
//
//        let wellnessItems = payload.wellness.enumerated().map { index, dto in
//            makeShopItem(from: dto, category: .wellness, index: index)
//        }
//
//        shopCatalog = natureItems + wellnessItems
//        allItemsOrdered = yourItemsCatalog + shopCatalog
//    }
//
//    private func restorePersistedState() {
//        let defaults = UserDefaults.standard
//
//        if defaults.object(forKey: StorageKeys.coins) != nil {
//            coins = defaults.integer(forKey: StorageKeys.coins)
//        } else {
//            coins = 32000
//        }
//
//        let ids = defaults.stringArray(forKey: StorageKeys.unlockedIds) ?? []
//        unlockedItemIds = Set(ids)
//    }
//
//    private func persistState() {
//        let defaults = UserDefaults.standard
//        defaults.set(coins, forKey: StorageKeys.coins)
//        defaults.set(Array(unlockedItemIds), forKey: StorageKeys.unlockedIds)
//    }
//
//    private func seedDefaultUnlockedItems() {
//        let defaultUnlockedIds = Set(yourItemsCatalog.map(\.id))
//        unlockedItemIds.formUnion(defaultUnlockedIds)
//    }
//
//    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
//        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else {
//            print("garden_items.json not found in bundle. Using fallback catalog.")
//            return nil
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            return try JSONDecoder().decode(GardenCatalogPayload.self, from: data)
//        } catch {
//            print("Failed to decode garden_items.json: \(error). Using fallback catalog.")
//            return nil
//        }
//    }
//
//    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
//        let imageName = dto.imageName
//        let id = resolvedId(explicitId: dto.id, category: .yourItems, imageName: imageName, index: index)
//        let finalName = dto.name.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        return StoreItem(
//            id: id,
//            name: finalName.isEmpty ? "Item" : finalName,
//            imageName: imageName,
//            price: 0,
//            category: Category.yourItems.rawValue
//        )
//    }
//
//
//    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
//        let imageName = dto.imageName
//        let id = resolvedId(explicitId: dto.id, category: category, imageName: imageName, index: index)
//        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)
//
//        return StoreItem(
//            id: id,
//            name: name,
//            imageName: imageName,
//            price: max(dto.price, 0),
//            category: category.rawValue
//        )
//    }
//
//    private func resolvedId(explicitId: String?, category: Category, imageName: String, index: Int) -> String {
//        if let explicitId, let clean = explicitId.trimmedNonEmpty {
//            return clean
//        }
//
//        let safeCategory = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
//        let safeImage = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
//        return "\(safeCategory)_\(safeImage)_\(index)"
//    }
//
//    private static func displayName(fromImageName imageName: String) -> String {
//        let cleaned = imageName
//            .replacingOccurrences(of: "_", with: " ")
//            .replacingOccurrences(of: "-", with: " ")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !cleaned.isEmpty else { return "Item" }
//
//        return cleaned
//            .split(separator: " ")
//            .map { $0.capitalized }
//            .joined(separator: " ")
//    }
//
//    private static let fallbackPayload = GardenCatalogPayload(
//        yourItems: [
//            UnlockedItemDTO(id: "your_garden_base", name: "Garden Base", imageName: "garden_base")
//        ],
//        nature: [
//            ShopItemDTO(id: "nature_bench", name: "Bench", imageName: "bench", price: 2300),
//            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea", price: 3000),
//            ShopItemDTO(id: "nature_tulips", name: "Tulips", imageName: "tulips", price: 2300)
//        ],
//        wellness: [
//            ShopItemDTO(id: "wellness_fountain", name: "Fountain", imageName: "fountain", price: 3000),
//            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath", price: 1500)
//        ]
//    )
//}
//
//private struct GardenCatalogPayload: Decodable {
//    let yourItems: [UnlockedItemDTO]
//    let nature: [ShopItemDTO]
//    let wellness: [ShopItemDTO]
//
//    enum CodingKeys: String, CodingKey {
//        case yourItemsSnake = "your_items"
//        case yourItemsTitle = "Your Items"
//        case natureLower = "nature"
//        case natureTitle = "Nature"
//        case wellnessLower = "wellness"
//        case wellnessTitle = "Wellness"
//    }
//
//    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
//        self.yourItems = yourItems
//        self.nature = nature
//        self.wellness = wellness
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        yourItems =
//            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake)) ??
//            (try? container.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle)) ??
//            []
//
//        nature =
//            (try? container.decode([ShopItemDTO].self, forKey: .natureLower)) ??
//            (try? container.decode([ShopItemDTO].self, forKey: .natureTitle)) ??
//            []
//
//        wellness =
//            (try? container.decode([ShopItemDTO].self, forKey: .wellnessLower)) ??
//            (try? container.decode([ShopItemDTO].self, forKey: .wellnessTitle)) ??
//            []
//    }
//}
//
//private struct UnlockedItemDTO: Decodable {
//    let id: String?
//    let name: String
//    let imageName: String
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case image
//        case imageName
//    }
//
//    init(id: String? = nil, name: String, imageName: String) {
//        self.id = id
//        self.name = name
//        self.imageName = imageName
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try container.decodeIfPresent(String.self, forKey: .id)
//
//        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
//            imageName = imageNameValue
//        } else {
//            imageName = try container.decode(String.self, forKey: .image)
//        }
//
//        let decodedName = try container.decodeIfPresent(String.self, forKey: .name)?
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if let decodedName, !decodedName.isEmpty {
//            name = decodedName
//        } else {
//            // fallback if name is missing in JSON
//            name = imageName
//                .replacingOccurrences(of: "_", with: " ")
//                .replacingOccurrences(of: "-", with: " ")
//                .split(separator: " ")
//                .map { $0.capitalized }
//                .joined(separator: " ")
//        }
//    }
//}
//
//private struct ShopItemDTO: Decodable {
//    let id: String?
//    let name: String?
//    let imageName: String
//    let price: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case image
//        case imageName
//        case price
//    }
//
//    init(id: String? = nil, name: String? = nil, imageName: String, price: Int) {
//        self.id = id
//        self.name = name
//        self.imageName = imageName
//        self.price = price
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try container.decodeIfPresent(String.self, forKey: .id)
//        name = try container.decodeIfPresent(String.self, forKey: .name)
//
//        if let imageNameValue = try container.decodeIfPresent(String.self, forKey: .imageName) {
//            imageName = imageNameValue
//        } else {
//            imageName = try container.decode(String.self, forKey: .image)
//        }
//
//        if let directPrice = try container.decodeIfPresent(Int.self, forKey: .price) {
//            price = directPrice
//        } else if let stringPrice = try container.decodeIfPresent(String.self, forKey: .price),
//                  let parsed = Int(stringPrice.replacingOccurrences(of: ",", with: "")) {
//            price = parsed
//        } else {
//            price = 0
//        }
//    }
//}
//
//private extension String {
//    var trimmedNonEmpty: String? {
//        let value = trimmingCharacters(in: .whitespacesAndNewlines)
//        return value.isEmpty ? nil : value
//    }
//}

//
//  GardenManager.swift
//  BreastCancerApp
//

import Foundation

final class GardenManager {
    static let shared = GardenManager()

    enum Category: String, CaseIterable {
        case yourItems = "Your Items"
        case nature = "Nature"
        case wellness = "Wellness"
    }

    enum PurchaseResult {
        case purchased(remainingCoins: Int)
        case insufficientCoins(missingCoins: Int, currentCoins: Int, itemPrice: Int)
        case alreadyUnlocked
        case notPurchasable
    }

    static let segmentCategories: [String] = Category.allCases.map(\.rawValue)

    // bumped to v2 so old saved coins/items are ignored and app starts fresh
    private enum StorageKeys {
        static let coins = "garden_coins_v2"
        static let unlockedIds = "garden_unlocked_item_ids_v2"
    }

    private(set) var coins: Int = 0
    private(set) var unlockedItemIds: Set<String> = []
    var currentCoins: Int { coins }

    private var yourItemsCatalog: [StoreItem] = []
    private var shopCatalog: [StoreItem] = []
    private var allItemsOrdered: [StoreItem] = []

    var unlockedItems: [StoreItem] {
        allItemsOrdered.filter { unlockedItemIds.contains($0.id) }
    }

    private init() {
        loadCatalog()
        restorePersistedState()
        seedDefaultUnlockedItems()
        persistState()
    }

    func getItems(for category: String) -> [StoreItem] {
        guard let parsed = Category(rawValue: category) else { return [] }

        switch parsed {
        case .yourItems:
            return unlockedItems
        case .nature, .wellness:
            // hide unlocked items from store tabs
            return shopCatalog.filter { $0.category == parsed.rawValue && !unlockedItemIds.contains($0.id) }
        }
    }

    func purchaseResult(for item: StoreItem) -> PurchaseResult {
        guard item.category != Category.yourItems.rawValue else { return .notPurchasable }
        guard !unlockedItemIds.contains(item.id) else { return .alreadyUnlocked }

        guard coins >= item.price else {
            return .insufficientCoins(
                missingCoins: item.price - coins,
                currentCoins: coins,
                itemPrice: item.price
            )
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
        persistState()
    }

    private func loadCatalog() {
        let payload = loadPayloadFromJSON() ?? Self.fallbackPayload

        yourItemsCatalog = payload.yourItems.enumerated().map { index, dto in
            makeYourItem(from: dto, index: index)
        }

        let natureItems = payload.nature.enumerated().map { index, dto in
            makeShopItem(from: dto, category: .nature, index: index)
        }

        let wellnessItems = payload.wellness.enumerated().map { index, dto in
            makeShopItem(from: dto, category: .wellness, index: index)
        }

        shopCatalog = natureItems + wellnessItems
        allItemsOrdered = yourItemsCatalog + shopCatalog
    }

    private func restorePersistedState() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: StorageKeys.coins) != nil {
            coins = defaults.integer(forKey: StorageKeys.coins)
        } else {
            coins = 0
        }

        let ids = defaults.stringArray(forKey: StorageKeys.unlockedIds) ?? []
        unlockedItemIds = Set(ids)
    }

    private func persistState() {
        let defaults = UserDefaults.standard
        defaults.set(coins, forKey: StorageKeys.coins)
        defaults.set(Array(unlockedItemIds), forKey: StorageKeys.unlockedIds)
    }

    private func seedDefaultUnlockedItems() {
        // if your_items is empty in JSON, nothing is unlocked at start
        let defaults = Set(yourItemsCatalog.map(\.id))
        unlockedItemIds.formUnion(defaults)
    }

    private func loadPayloadFromJSON() -> GardenCatalogPayload? {
        guard let url = Bundle.main.url(forResource: "garden_items", withExtension: "json") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(GardenCatalogPayload.self, from: data)
        } catch {
            print("Failed to decode garden_items.json: \(error)")
            return nil
        }
    }

    private func makeYourItem(from dto: UnlockedItemDTO, index: Int) -> StoreItem {
        let imageName = dto.imageName
        let id = resolvedId(explicitId: dto.id, category: .yourItems, imageName: imageName, index: index)
        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)

        return StoreItem(
            id: id,
            name: name,
            imageName: imageName,
            price: 0,
            category: Category.yourItems.rawValue
        )
    }

    private func makeShopItem(from dto: ShopItemDTO, category: Category, index: Int) -> StoreItem {
        let imageName = dto.imageName
        let id = resolvedId(explicitId: dto.id, category: category, imageName: imageName, index: index)
        let name = dto.name?.trimmedNonEmpty ?? Self.displayName(fromImageName: imageName)

        return StoreItem(
            id: id,
            name: name,
            imageName: imageName,
            price: max(dto.price, 0),
            category: category.rawValue
        )
    }

    private func resolvedId(explicitId: String?, category: Category, imageName: String, index: Int) -> String {
        if let explicitId, let clean = explicitId.trimmedNonEmpty {
            return clean
        }
        let safeCategory = category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
        let safeImage = imageName.lowercased().replacingOccurrences(of: " ", with: "_")
        return "\(safeCategory)_\(safeImage)_\(index)"
    }

    private static func displayName(fromImageName imageName: String) -> String {
        let cleaned = imageName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return "Item" }

        return cleaned
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    private static let fallbackPayload = GardenCatalogPayload(
        yourItems: [],
        nature: [
            ShopItemDTO(id: "nature_hydrangea", name: "Hydrangea", imageName: "hydrangea", price: 3000),
            ShopItemDTO(id: "nature_tulips", name: "Tulips", imageName: "tulips", price: 2300)
        ],
        wellness: [
            ShopItemDTO(id: "wellness_bird_bath", name: "Bird Bath", imageName: "bird_bath", price: 1500),
            ShopItemDTO(id: "wellness_fountain", name: "Fountain", imageName: "fountain", price: 3000)
        ]
    )
}

private struct GardenCatalogPayload: Decodable {
    let yourItems: [UnlockedItemDTO]
    let nature: [ShopItemDTO]
    let wellness: [ShopItemDTO]

    enum CodingKeys: String, CodingKey {
        case yourItemsSnake = "your_items"
        case yourItemsTitle = "Your Items"
        case natureLower = "nature"
        case natureTitle = "Nature"
        case wellnessLower = "wellness"
        case wellnessTitle = "Wellness"
    }

    init(yourItems: [UnlockedItemDTO], nature: [ShopItemDTO], wellness: [ShopItemDTO]) {
        self.yourItems = yourItems
        self.nature = nature
        self.wellness = wellness
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        yourItems =
            (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsSnake)) ??
            (try? c.decode([UnlockedItemDTO].self, forKey: .yourItemsTitle)) ?? []
        nature =
            (try? c.decode([ShopItemDTO].self, forKey: .natureLower)) ??
            (try? c.decode([ShopItemDTO].self, forKey: .natureTitle)) ?? []
        wellness =
            (try? c.decode([ShopItemDTO].self, forKey: .wellnessLower)) ??
            (try? c.decode([ShopItemDTO].self, forKey: .wellnessTitle)) ?? []
    }
}

private struct UnlockedItemDTO: Decodable {
    let id: String?
    let name: String?
    let imageName: String

    enum CodingKeys: String, CodingKey {
        case id, name, image, imageName
    }

    init(id: String? = nil, name: String? = nil, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        if let v = try c.decodeIfPresent(String.self, forKey: .imageName) {
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

    enum CodingKeys: String, CodingKey {
        case id, name, image, imageName, price
    }

    init(id: String? = nil, name: String? = nil, imageName: String, price: Int) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.price = price
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(String.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        if let v = try c.decodeIfPresent(String.self, forKey: .imageName) {
            imageName = v
        } else {
            imageName = try c.decode(String.self, forKey: .image)
        }

        if let p = try c.decodeIfPresent(Int.self, forKey: .price) {
            price = p
        } else if let s = try c.decodeIfPresent(String.self, forKey: .price),
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
