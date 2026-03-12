
import Foundation

class SampleProfilesManager {
    static let shared = SampleProfilesManager()
    
    private init() {}
    let sampleProfiles: [UserProfile] = [

        UserProfile(
            id: "profile_1",
            name: "Sophie Anderson",
            email: "sophie@example.com",
            password: "sophie123",
            treatmentStatus: "Currently in treatment",
            hobbies: ["Reading", "Meditation"],
            profileImageName: "profile_sophie",
            diagnosisDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            currentAge: "36-45",
            currentStage: "Stage II",
            lastCheckupDate: nil,
            followUpFrequency: nil,
            treatmentCompletionDate: nil,
            interests: nil
        ),

        UserProfile(
            id: "profile_2",
            name: "Emma Williams",
            email: "emma@example.com",
            password: "emma123",
            treatmentStatus: "Under Observation",
            hobbies: ["Painting", "Gardening"],
            profileImageName: "profile_emma",
            diagnosisDate: nil,
            currentAge: nil,
            currentStage: nil,
            lastCheckupDate: Date(),
            followUpFrequency: "Every 2 months",
            treatmentCompletionDate: nil,
            interests: nil
        )
    ]
    
    func getStatsForProfile(id: String) -> HealingGardenStats {
        switch id {
        case "profile_1":
            return HealingGardenStats(
                currentPoints: 3200,
                totalPointsNeeded: 6000,
                currentLevel: 1,
                nextLevel: 2
            )
        case "profile_2":
            return HealingGardenStats(
                currentPoints: 4800,
                totalPointsNeeded: 6000,
                currentLevel: 2,
                nextLevel: 3
            )
        case "profile_3":
            return HealingGardenStats(
                currentPoints: 8500,
                totalPointsNeeded: 9000,
                currentLevel: 3,
                nextLevel: 4
            )
        default:
            return HealingGardenStats(
                currentPoints: 0,
                totalPointsNeeded: 4000,
                currentLevel: 0,
                nextLevel: 1
            )
        }
    }
    
    func getProfileSubtitle(for profile: UserProfile) -> String {
        switch profile.treatmentStatus {
        case "Currently in treatment":
            if let stage = profile.currentStage {
                return "\(stage) • Active Treatment"
            }
            return "Active Treatment"
            
        case "Under Observation":
            if let frequency = profile.followUpFrequency {
                return "Under Observation • \(frequency)"
            }
            return "Under Observation"
            
        case "Post-treatment / in recovery":
            return "Post-treatment Recovery"
            
        case "Prefer not to say":
            return "Wellness Journey"
            
        default:
            return profile.treatmentStatus
        }
    }
    
    func loadProfileIntoOnboardingData(_ profile: UserProfile) {
        OnboardingData.shared.userName = profile.name
        OnboardingData.shared.treatmentStatus = profile.treatmentStatus
        OnboardingData.shared.selectedHobbies = profile.hobbies
        
        switch profile.treatmentStatus {
        case "Currently in treatment":
            OnboardingData.shared.diagnosisDate = profile.diagnosisDate
            OnboardingData.shared.currentAge = profile.currentAge
            OnboardingData.shared.currentStage = profile.currentStage
            
        case "Under Observation":
            OnboardingData.shared.lastCheckupDate = profile.lastCheckupDate
            OnboardingData.shared.followUpFrequency = profile.followUpFrequency
            
        case "Post-treatment / in recovery":
            OnboardingData.shared.treatmentCompletionDate = profile.treatmentCompletionDate
            OnboardingData.shared.selectedInterests = profile.interests ?? []
            
        case "Prefer not to say":
            OnboardingData.shared.selectedInterests = profile.interests ?? []
            
        default:
            break
        }
    }
}

