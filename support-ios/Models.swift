import Foundation
import SwiftUI

enum PlanType: String, CaseIterable, Identifiable {
    case standard
    case pro
    case enterprise
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .pro: return "Pro"
        case .enterprise: return "Enterprise"
        }
    }
    
    var price: Int {
        switch self {
        case .standard: return 9
        case .pro: return 29
        case .enterprise: return 99
        }
    }
    
    var color: Color {
        switch self {
        case .standard: return .blue
        case .pro: return .purple
        case .enterprise: return .green
        }
    }
}

class UserState: ObservableObject {
    @Published var plan: PlanType = .standard
    @AppStorage("userPlan") var storedPlan: String = PlanType.standard.rawValue {
        didSet {
            plan = PlanType(rawValue: storedPlan) ?? .standard
        }
    }
    
    @Published var userId: String = ""
    @AppStorage("userId") var storedUserId: String = "" {
        didSet {
            userId = storedUserId
        }
    }
    
    init() {
        plan = PlanType(rawValue: storedPlan) ?? .standard
        userId = storedUserId
    }
    
    func updatePlan(_ newPlan: PlanType) {
        plan = newPlan
        storedPlan = newPlan.rawValue
    }
    
    func updateUserId(_ newId: String) {
        userId = newId
        storedUserId = newId
    }
} 