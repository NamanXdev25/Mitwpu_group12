import Foundation

// MARK: - Exercise Image Mapping

private func imageForExercise(_ name: String) -> String {
    let lower = name.lowercased()
    if lower.contains("wall climb") || lower.contains("wall crawl") || lower.contains("wall walk") {
        return "wall_climbing"
    } else if lower.contains("heel raise") {
        return "standing_heel_raises"
    } else if lower.contains("shoulder blade") || lower.contains("scapular") || lower.contains("shoulder roll") || lower.contains("shoulder shrug") {
        return "shoulder_blade_squeeze"
    } else if lower.contains("posture alignment") {
        return "posture_alignment_against_wall"
    } else if lower.contains("chest open") || lower.contains("chest-open") || lower.contains("corner stretch") {
        return "chest_open"
    } else if lower.contains("arm raise") || lower.contains("arm lift") || lower.contains("arm stretch") ||
        lower.contains("shoulder abduction") || lower.contains("shoulder flexion") ||
        lower.contains("arm circle") || lower.contains("elbow") || lower.contains("resistance band") ||
        lower.contains("band pull") || lower.contains("pendulum") {
        return "arm_lift"
    } else if lower.contains("cat") || lower.contains("yoga") || lower.contains("breathing") || lower.contains("diaphragmatic") {
        return "girl_stretch"
    } else {
        return "girl_stretch"
    }
}

// MARK: - YouTube URL Mapping

private enum YouTubeLinks {
    static let shoulderShrug = "https://youtu.be/YT6qn6HVQyE?si=PpHh1leGZrKPQtIb"
    static let shoulderRoll = "https://youtu.be/X7NtgY9kCCM?si=Nvhx1KA62Tvmsgwn"
    static let elbowFlexExtend = "https://youtu.be/F5N6ubrWmmw?si=qCXqC0WH8lE5z-UW"
    static let wristCircles = "https://youtu.be/wRSk1_C6yOM?si=nscY-V5smyRzTIfi"
    static let shoulderBladeSqueeze = "https://youtu.be/YejnTLIA9K8?si=vfQ_tG2-FT8ThKAh"
    static let pendulumArmSwing = "https://youtu.be/YYvl59eU78M?si=JTUdsj-TtyO4y7mP"
    static let wallCrawlFront = "https://youtu.be/bfOEqkWTvZo?si=qVtYTZIP-g-a7z6C"
    static let wallCrawlSide = "https://youtu.be/Zaz48x6XVLQ?si=Xz6tyHEppgfkd1Qw"
    static let gentleShoulderAbduction = "https://youtu.be/t6bOQbTdT6M?si=kMNiepwFvY_l-35r"
    static let chestOpeningStretch = "https://youtu.be/4CAsFh26GGo?si=GgIiAbRlY8f2qx4Y"
    static let neckSideStretch = "https://youtu.be/R0lkMPT53qA?si=ir-oXmi7pb-ZAMpf"
    static let diaphragmaticBreathing = "https://youtu.be/qhcBjSirMss?si=Cx7U1HAa1efkm345"
    static let sitToStand = "https://youtu.be/2rVOvOU_vmE?si=wD1YH1YD5QSbRxrV"
    static let seatedKneeExtension = "https://youtu.be/3f1k1huhRgI?si=nzQBbXkjsktyZN-j"
    static let standingHeelRaises = "https://youtu.be/fbqEjN9pyxI?si=92LN3XaSgtfwsblD"
    static let resistanceBandRow = "https://youtu.be/AFm1M-2UnPw?si=QXt5zlVmlSiIBHTb"
    static let wallPushUp = "https://youtu.be/w8in7tdjsaY?si=0hETEILuEQt6MgDd"
    static let bodyweightMiniSquat = "https://youtu.be/wqCvuhfRXRU?si=GInTZD7llKb2QAbB"
    static let seatedCoreBracing = "https://youtu.be/jDu3wEFGJTE?si=PyKe4zakk7igb1nv"
    static let singleLegStand = "https://youtu.be/ZLxyh_PEstI?si=_cpdUClY9NkZe2gr"
    static let tandemStand = "https://youtu.be/hcsAEpw3DW4?si=a4vgFpL2A0w_6TpU"
    static let seatedCatCow = "https://youtu.be/PMxA3xlFpAk?si=pFR1quEJJecKdthE"
}

// MARK: - Sample Data

extension ExercisePlanCategory {
    static let allCategories: [ExercisePlanCategory] = [
        ExercisePlanCategory(
            id: 1,
            title: "Before Chemotherapy",
            subtitle: "6 exercises · 20–30 min",
            importantNote: "Build strength and stamina before treatment starts. Stop if dizziness, pain, or unusual fatigue occurs.",
            exercises: [
                CategoryExercise(
                    name: "Sit-to-Stand",
                    details: "4 min",
                    imageName: imageForExercise("Sit-to-Stand"),
                    youtubeURL: YouTubeLinks.sitToStand
                ),
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Bodyweight Mini Squat",
                    details: "4 min",
                    imageName: imageForExercise("Bodyweight Mini Squat"),
                    youtubeURL: YouTubeLinks.bodyweightMiniSquat
                ),
                CategoryExercise(
                    name: "Shoulder Blade Squeeze",
                    details: "3 min",
                    imageName: imageForExercise("Shoulder Blade Squeeze"),
                    youtubeURL: YouTubeLinks.shoulderBladeSqueeze
                ),
                CategoryExercise(
                    name: "Chest Opening Stretch",
                    details: "2.5 min",
                    imageName: imageForExercise("Chest Opening Stretch"),
                    youtubeURL: YouTubeLinks.chestOpeningStretch
                ),
                CategoryExercise(
                    name: "Diaphragmatic Breathing",
                    details: "5 min",
                    imageName: imageForExercise("Diaphragmatic Breathing"),
                    youtubeURL: YouTubeLinks.diaphragmaticBreathing
                ),
            ],
            imageName: "standing_heel_raises"
        ),

        ExercisePlanCategory(
            id: 2,
            title: "During Chemotherapy",
            subtitle: "6 exercises · 10–20 min",
            importantNote: "Some movement is better than none. On very tired days, even 5 minutes counts.",
            exercises: [
                CategoryExercise(
                    name: "Seated Knee Extension",
                    details: "3 min",
                    imageName: imageForExercise("Seated Knee Extension"),
                    youtubeURL: YouTubeLinks.seatedKneeExtension
                ),
                CategoryExercise(
                    name: "Sit-to-Stand",
                    details: "4 min",
                    imageName: imageForExercise("Sit-to-Stand"),
                    youtubeURL: YouTubeLinks.sitToStand
                ),
                CategoryExercise(
                    name: "Shoulder Shrug",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Shrug"),
                    youtubeURL: YouTubeLinks.shoulderShrug
                ),
                CategoryExercise(
                    name: "Shoulder Roll",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Roll"),
                    youtubeURL: YouTubeLinks.shoulderRoll
                ),
                CategoryExercise(
                    name: "Seated Cat-Cow",
                    details: "4 min",
                    imageName: imageForExercise("Seated Cat-Cow"),
                    youtubeURL: YouTubeLinks.seatedCatCow
                ),
                CategoryExercise(
                    name: "Diaphragmatic Breathing",
                    details: "5 min",
                    imageName: imageForExercise("Diaphragmatic Breathing"),
                    youtubeURL: YouTubeLinks.diaphragmaticBreathing
                ),
            ],
            imageName: "arm_lift"
        ),

        ExercisePlanCategory(
            id: 3,
            title: "Post-Chemo",
            subtitle: "6 exercises · 20–25 min",
            importantNote: "Focus on restoring energy without stressing the body before surgery.",
            exercises: [
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Bodyweight Mini Squat",
                    details: "4 min",
                    imageName: imageForExercise("Bodyweight Mini Squat"),
                    youtubeURL: YouTubeLinks.bodyweightMiniSquat
                ),
                CategoryExercise(
                    name: "Standing Heel Raises",
                    details: "3 min",
                    imageName: imageForExercise("Standing Heel Raises"),
                    youtubeURL: YouTubeLinks.standingHeelRaises
                ),
                CategoryExercise(
                    name: "Shoulder Blade Squeeze",
                    details: "3 min",
                    imageName: imageForExercise("Shoulder Blade Squeeze"),
                    youtubeURL: YouTubeLinks.shoulderBladeSqueeze
                ),
                CategoryExercise(
                    name: "Neck Side Stretch",
                    details: "2 min",
                    imageName: imageForExercise("Neck Side Stretch"),
                    youtubeURL: YouTubeLinks.neckSideStretch
                ),
                CategoryExercise(
                    name: "Diaphragmatic Breathing",
                    details: "5 min",
                    imageName: imageForExercise("Diaphragmatic Breathing"),
                    youtubeURL: YouTubeLinks.diaphragmaticBreathing
                ),
            ],
            imageName: "chest_open"
        ),

        ExercisePlanCategory(
            id: 4,
            title: "Early Post-Surgery (Week 1)",
            subtitle: "5 exercises · 10–15 min",
            importantNote: "Start the day after surgery and continue for 7 days unless your doctor says otherwise.",
            exercises: [
                CategoryExercise(
                    name: "Shoulder Shrug",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Shrug"),
                    youtubeURL: YouTubeLinks.shoulderShrug
                ),
                CategoryExercise(
                    name: "Shoulder Roll",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Roll"),
                    youtubeURL: YouTubeLinks.shoulderRoll
                ),
                CategoryExercise(
                    name: "Wrist Circles",
                    details: "2 min",
                    imageName: imageForExercise("Wrist Circles"),
                    youtubeURL: YouTubeLinks.wristCircles
                ),
                CategoryExercise(
                    name: "Elbow Flex & Extend",
                    details: "3 min",
                    imageName: imageForExercise("Elbow Flex & Extend"),
                    youtubeURL: YouTubeLinks.elbowFlexExtend
                ),
                CategoryExercise(
                    name: "Shoulder Blade Squeeze",
                    details: "3 min",
                    imageName: imageForExercise("Shoulder Blade Squeeze"),
                    youtubeURL: YouTubeLinks.shoulderBladeSqueeze
                ),
            ],
            imageName: "wall_climbing"
        ),

        ExercisePlanCategory(
            id: 5,
            title: "Post-Surgery (Week 2)",
            subtitle: "5 exercises · 15–20 min",
            importantNote: "Continue building strength and mobility. Listen to your body.",
            exercises: [
                CategoryExercise(
                    name: "Pendulum Arm Swing",
                    details: "2.5 min",
                    imageName: imageForExercise("Pendulum Arm Swing"),
                    youtubeURL: YouTubeLinks.pendulumArmSwing
                ),
                CategoryExercise(
                    name: "Wall Crawl (Front)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Front)"),
                    youtubeURL: YouTubeLinks.wallCrawlFront
                ),
                CategoryExercise(
                    name: "Wall Crawl (Side)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Side)"),
                    youtubeURL: YouTubeLinks.wallCrawlSide
                ),
                CategoryExercise(
                    name: "Shoulder Blade Squeeze",
                    details: "3 min",
                    imageName: imageForExercise("Shoulder Blade Squeeze"),
                    youtubeURL: YouTubeLinks.shoulderBladeSqueeze
                ),
                CategoryExercise(
                    name: "Gentle Shoulder Abduction",
                    details: "3 min",
                    imageName: imageForExercise("Gentle Shoulder Abduction"),
                    youtubeURL: YouTubeLinks.gentleShoulderAbduction
                ),
            ],
            imageName: "arm_lift"
        ),

        ExercisePlanCategory(
            id: 6,
            title: "Post-Surgery Recovery",
            subtitle: "6 exercises · 20–25 min",
            importantNote: "Gradually improve shoulder movement. Watch for swelling, heaviness, or pain.",
            exercises: [
                CategoryExercise(
                    name: "Wall Crawl (Front)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Front)"),
                    youtubeURL: YouTubeLinks.wallCrawlFront
                ),
                CategoryExercise(
                    name: "Wall Crawl (Side)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Side)"),
                    youtubeURL: YouTubeLinks.wallCrawlSide
                ),
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Sit-to-Stand",
                    details: "4 min",
                    imageName: imageForExercise("Sit-to-Stand"),
                    youtubeURL: YouTubeLinks.sitToStand
                ),
                CategoryExercise(
                    name: "Standing Heel Raises",
                    details: "3 min",
                    imageName: imageForExercise("Standing Heel Raises"),
                    youtubeURL: YouTubeLinks.standingHeelRaises
                ),
                CategoryExercise(
                    name: "Chest Opening Stretch",
                    details: "2.5 min",
                    imageName: imageForExercise("Chest Opening Stretch"),
                    youtubeURL: YouTubeLinks.chestOpeningStretch
                ),
            ],
            imageName: nil
        ),

        ExercisePlanCategory(
            id: 7,
            title: "After Breast Reconstruction",
            subtitle: "5 exercises · 15–20 min",
            importantNote: "Protect reconstructed tissue. Avoid chest loading and sudden arm movements.",
            exercises: [
                CategoryExercise(
                    name: "Shoulder Shrug",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Shrug"),
                    youtubeURL: YouTubeLinks.shoulderShrug
                ),
                CategoryExercise(
                    name: "Shoulder Roll",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Roll"),
                    youtubeURL: YouTubeLinks.shoulderRoll
                ),
                CategoryExercise(
                    name: "Gentle Shoulder Abduction",
                    details: "3 min",
                    imageName: imageForExercise("Gentle Shoulder Abduction"),
                    youtubeURL: YouTubeLinks.gentleShoulderAbduction
                ),
                CategoryExercise(
                    name: "Chest Opening Stretch",
                    details: "2.5 min",
                    imageName: imageForExercise("Chest Opening Stretch"),
                    youtubeURL: YouTubeLinks.chestOpeningStretch
                ),
                CategoryExercise(
                    name: "Diaphragmatic Breathing",
                    details: "5 min",
                    imageName: imageForExercise("Diaphragmatic Breathing"),
                    youtubeURL: YouTubeLinks.diaphragmaticBreathing
                ),
            ],
            imageName: nil
        ),

        ExercisePlanCategory(
            id: 8,
            title: "Pre-Radiation Therapy",
            subtitle: "5 exercises · 15–20 min",
            importantNote: "Good shoulder mobility helps with radiation positioning.",
            exercises: [
                CategoryExercise(
                    name: "Wall Crawl (Front)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Front)"),
                    youtubeURL: YouTubeLinks.wallCrawlFront
                ),
                CategoryExercise(
                    name: "Wall Crawl (Side)",
                    details: "3 min",
                    imageName: imageForExercise("Wall Crawl (Side)"),
                    youtubeURL: YouTubeLinks.wallCrawlSide
                ),
                CategoryExercise(
                    name: "Shoulder Blade Squeeze",
                    details: "3 min",
                    imageName: imageForExercise("Shoulder Blade Squeeze"),
                    youtubeURL: YouTubeLinks.shoulderBladeSqueeze
                ),
                CategoryExercise(
                    name: "Chest Opening Stretch",
                    details: "2.5 min",
                    imageName: imageForExercise("Chest Opening Stretch"),
                    youtubeURL: YouTubeLinks.chestOpeningStretch
                ),
                CategoryExercise(
                    name: "Seated Cat-Cow",
                    details: "4 min",
                    imageName: imageForExercise("Seated Cat-Cow"),
                    youtubeURL: YouTubeLinks.seatedCatCow
                ),
            ],
            imageName: nil
        ),

        ExercisePlanCategory(
            id: 9,
            title: "During & After Radiation",
            subtitle: "5 exercises · 15–20 min",
            importantNote: "Fatigue and skin sensitivity are common. Reduce intensity if skin irritation increases.",
            exercises: [
                CategoryExercise(
                    name: "Shoulder Shrug",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Shrug"),
                    youtubeURL: YouTubeLinks.shoulderShrug
                ),
                CategoryExercise(
                    name: "Shoulder Roll",
                    details: "2 min",
                    imageName: imageForExercise("Shoulder Roll"),
                    youtubeURL: YouTubeLinks.shoulderRoll
                ),
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Bodyweight Mini Squat",
                    details: "4 min",
                    imageName: imageForExercise("Bodyweight Mini Squat"),
                    youtubeURL: YouTubeLinks.bodyweightMiniSquat
                ),
                CategoryExercise(
                    name: "Diaphragmatic Breathing",
                    details: "5 min",
                    imageName: imageForExercise("Diaphragmatic Breathing"),
                    youtubeURL: YouTubeLinks.diaphragmaticBreathing
                ),
            ],
            imageName: "girl_stretch"
        ),

        ExercisePlanCategory(
            id: 10,
            title: "Post-Treatment Recovery",
            subtitle: "6 exercises · 25–30 min",
            importantNote: "Gradually rebuild strength and endurance. Progress slowly.",
            exercises: [
                CategoryExercise(
                    name: "Sit-to-Stand",
                    details: "4 min",
                    imageName: imageForExercise("Sit-to-Stand"),
                    youtubeURL: YouTubeLinks.sitToStand
                ),
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Bodyweight Mini Squat",
                    details: "4 min",
                    imageName: imageForExercise("Bodyweight Mini Squat"),
                    youtubeURL: YouTubeLinks.bodyweightMiniSquat
                ),
                CategoryExercise(
                    name: "Wall Push-Up",
                    details: "3 min",
                    imageName: imageForExercise("Wall Push-Up"),
                    youtubeURL: YouTubeLinks.wallPushUp
                ),
                CategoryExercise(
                    name: "Single Leg Stand",
                    details: "3 min",
                    imageName: imageForExercise("Single Leg Stand"),
                    youtubeURL: YouTubeLinks.singleLegStand
                ),
                CategoryExercise(
                    name: "Chest Opening Stretch",
                    details: "2.5 min",
                    imageName: imageForExercise("Chest Opening Stretch"),
                    youtubeURL: YouTubeLinks.chestOpeningStretch
                ),
            ],
            imageName: "shoulder_blade_squeeze"
        ),

        ExercisePlanCategory(
            id: 11,
            title: "Remission / Survivorship",
            subtitle: "7 exercises · 30 min",
            importantNote: "Regular exercise supports long-term health and reduces recurrence risk.",
            exercises: [
                CategoryExercise(
                    name: "Bodyweight Mini Squat",
                    details: "4 min",
                    imageName: imageForExercise("Bodyweight Mini Squat"),
                    youtubeURL: YouTubeLinks.bodyweightMiniSquat
                ),
                CategoryExercise(
                    name: "Resistance Band Row",
                    details: "4 min",
                    imageName: imageForExercise("Resistance Band Row"),
                    youtubeURL: YouTubeLinks.resistanceBandRow
                ),
                CategoryExercise(
                    name: "Wall Push-Up",
                    details: "3 min",
                    imageName: imageForExercise("Wall Push-Up"),
                    youtubeURL: YouTubeLinks.wallPushUp
                ),
                CategoryExercise(
                    name: "Standing Heel Raises",
                    details: "3 min",
                    imageName: imageForExercise("Standing Heel Raises"),
                    youtubeURL: YouTubeLinks.standingHeelRaises
                ),
                CategoryExercise(
                    name: "Single Leg Stand",
                    details: "3 min",
                    imageName: imageForExercise("Single Leg Stand"),
                    youtubeURL: YouTubeLinks.singleLegStand
                ),
                CategoryExercise(
                    name: "Tandem Stand",
                    details: "2.5 min",
                    imageName: imageForExercise("Tandem Stand"),
                    youtubeURL: YouTubeLinks.tandemStand
                ),
                CategoryExercise(
                    name: "Seated Cat-Cow",
                    details: "4 min",
                    imageName: imageForExercise("Seated Cat-Cow"),
                    youtubeURL: YouTubeLinks.seatedCatCow
                ),
            ],
            imageName: "posture_alignment_against_wall"
        ),
    ]

    static var postSurgeryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 4 || $0.id == 5 }
    }

    static var postRecoveryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 6 }
    }

    static var chemotherapyCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 1 || $0.id == 2 || $0.id == 3 }
    }

    static var radiationCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 8 || $0.id == 9 }
    }

    static var reconstructionCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 7 }
    }

    static var recoveryCategories: [ExercisePlanCategory] {
        return allCategories.filter { $0.id == 10 || $0.id == 11 }
    }
}
