//
//  Bloomora_SplashScreen.swift
//  BreastCancerApp
//
//  Created by Shloka on 22/03/26.
//

import SwiftUI

struct BloomSplashView: View {

    @State private var bgOpacity: Double = 0
    @State private var logoOffsetY: CGFloat = -500
    @State private var logoOpacity: Double = 0
    @State private var logoFlipDegrees: Double = 0
    @State private var logoScale: CGFloat = 1.0
    @State private var titleText: String = ""
    @State private var titleOpacity: Double = 0
    @State private var dividerWidth: CGFloat = 0
    @State private var dividerOpacity: Double = 0
    @State private var taglineText: String = ""
    @State private var taglineOpacity: Double = 0
    @State private var cursorVisible: Bool = true
    @State private var showCursor: Bool = false

    private let fullTitle = "bloomora"
    private let fullTagline = "YOUR COMPANION THROUGH EVERY STEP"

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.98, green: 0.78, blue: 0.85), location: 0.0),
                    .init(color: Color(red: 0.95, green: 0.45, blue: 0.62), location: 0.55),
                    .init(color: Color(red: 0.90, green: 0.35, blue: 0.52), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(bgOpacity)

            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.25), Color.clear]),
                center: .init(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .opacity(bgOpacity)

            // ── Single centered group ──
            // Logo + name sit flush, whole block is centered by ZStack
            VStack(spacing: 0) {

                // Logo — big, no bottom padding
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .scaleEffect(logoScale)
                    .rotation3DEffect(
                        .degrees(logoFlipDegrees),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.4
                    )
                    .offset(y: logoOffsetY)
                    .opacity(logoOpacity)

                // "bloomora" — flush under logo
                ZStack {
                    Text(fullTitle)
                        .font(.custom("Georgia", size: 48))
                        .fontWeight(.light)
                        .tracking(2)
                        .opacity(0)

                    HStack(spacing: 0) {
                        Text(titleText)
                            .font(.custom("Georgia", size: 48))
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .tracking(2)

                        if showCursor && taglineText.isEmpty {
                            Text("|")
                                .font(.custom("Georgia", size: 48))
                                .foregroundColor(.white.opacity(cursorVisible ? 0.7 : 0))
                        }
                    }
                }
                .opacity(titleOpacity)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: dividerWidth, height: 0.7)
                    .opacity(dividerOpacity)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                // Tagline
                ZStack {
                    Text(fullTagline)
                        .font(.system(size: 11, weight: .regular))
                        .tracking(3.5)
                        .opacity(0)

                    HStack(spacing: 0) {
                        Text(taglineText)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white)
                            .tracking(3.5)

                        if showCursor && !taglineText.isEmpty && taglineText.count < fullTagline.count {
                            Text("|")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.white.opacity(cursorVisible ? 0.7 : 0))
                        }
                    }
                }
                .opacity(taglineOpacity)
            }
            .offset(y: -50) // nudge whole group above true center
        }
        .onAppear {
            runAnimation()
            startCursorBlink()
        }
    }

    func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.15)) { cursorVisible.toggle() }
            if taglineText == fullTagline {
                timer.invalidate()
                withAnimation(.easeOut(duration: 0.3)) { showCursor = false }
            }
        }
    }

    func runAnimation() {
        withAnimation(.easeIn(duration: 0.35)) { bgOpacity = 1 }

        withAnimation(.interpolatingSpring(stiffness: 110, damping: 11).delay(0.25)) {
            logoOffsetY = 0
            logoOpacity = 1
        }

        withAnimation(.easeInOut(duration: 0.4).delay(0.85)) {
            logoFlipDegrees = -180
            logoScale = 1.08
        }

        withAnimation(.easeInOut(duration: 0.4).delay(1.27)) {
            logoFlipDegrees = -360
            logoScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.85) {
            withAnimation(.easeIn(duration: 0.1)) {
                titleOpacity = 1
                showCursor = true
            }
            typeWriter(text: fullTitle, into: \BloomSplashView.titleText, interval: 0.09)
        }

        let dividerStart = 1.85 + Double(fullTitle.count) * 0.09 + 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + dividerStart) {
            withAnimation(.easeInOut(duration: 0.4)) {
                dividerWidth = 220
                dividerOpacity = 1
            }
        }

        let taglineStart = dividerStart + 0.45
        DispatchQueue.main.asyncAfter(deadline: .now() + taglineStart) {
            withAnimation(.easeIn(duration: 0.1)) { taglineOpacity = 1 }
            typeWriter(text: fullTagline, into: \BloomSplashView.taglineText, interval: 0.04)
        }
    }

    func typeWriter(text: String, into keyPath: ReferenceWritableKeyPath<BloomSplashView, String>, interval: Double) {
        for (i, char) in Array(text).enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                self[keyPath: keyPath].append(char)
            }
        }
    }
}

#Preview {
    BloomSplashView()
}
