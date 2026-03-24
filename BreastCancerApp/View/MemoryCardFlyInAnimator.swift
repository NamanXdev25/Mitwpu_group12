//
//  MemoryCardFlyInAnimator.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 24/03/26.
//


import UIKit

final class MemoryCardFlyInAnimator {

    static func show(memory: Memory, in container: UIView, tabBar: UITabBar?) {
        let animator = MemoryCardFlyInAnimator()
        animator.present(memory: memory, in: container, tabBar: tabBar)
        objc_setAssociatedObject(container, &AssociatedKey.animatorKey, animator,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private enum AssociatedKey { static var animatorKey = "MemoryCardFlyInAnimator" }

    private var cardWidth:  CGFloat = 220
    private var cardHeight: CGFloat = 242

    private func present(memory: Memory, in container: UIView, tabBar: UITabBar?) {
        let dim = UIView(frame: container.bounds)
        dim.backgroundColor = UIColor.black.withAlphaComponent(0)
        dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(dim)

        let card = buildCard(memory: memory)
        card.frame.size = CGSize(width: cardWidth, height: cardHeight)
        card.center = CGPoint(x: container.bounds.midX,
                              y: container.bounds.midY - 30)
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.45, y: 0.45)
        container.addSubview(card)

        let badge = buildSavedBadge()
        badge.center = CGPoint(x: cardWidth - 18, y: 18)
        badge.alpha = 0
        badge.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        card.addSubview(badge)

        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.60,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: {
                card.alpha = 1
                card.transform = .identity
                dim.backgroundColor = UIColor.black.withAlphaComponent(0.28)
            }
        )

        UIView.animate(
            withDuration: 0.40,
            delay: 0.30,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 1.0,
            options: [],
            animations: {
                badge.alpha = 1
                badge.transform = .identity
            }
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            UIView.animate(
                withDuration: 0.45,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction],
                animations: {
                    card.transform = CGAffineTransform(scaleX: 1.035, y: 1.035)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.30) {
                        card.transform = .identity
                    }
                }
            )
        }

        // MARK: – "Saved to Little Moments" toast
        let toast = buildToast(text: "Saved to Little Moments")
        let tabBarHeight = tabBar?.bounds.height ?? 83
        let toastBottomPadding: CGFloat = 12
        toast.center = CGPoint(
            x: container.bounds.midX,
            y: container.bounds.maxY - tabBarHeight - toast.bounds.height / 2 - toastBottomPadding
        )
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 10)
        container.addSubview(toast)

        UIView.animate(
            withDuration: 0.30,
            delay: 0.45,
            options: [.curveEaseOut],
            animations: {
                toast.alpha = 1
                toast.transform = .identity
            }
        )

        let holdDuration: Double = 1.85

        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
            UIView.animate(withDuration: 0.25) {
                dim.backgroundColor = UIColor.black.withAlphaComponent(0)
                toast.alpha = 0
            } completion: { _ in
                dim.removeFromSuperview()
                toast.removeFromSuperview()
            }

            // -- Compute the Mindfulness tab landing point (index 2 of 4 tabs) --
            let totalTabs = 4
            let mindfulnessIndex = 2
            let tabBarHeight = tabBar?.bounds.height ?? 83

            // Try to read real tab bar button frames; fall back to equal-width estimate
            let tabBarButtons = tabBar?.subviews
                .filter { String(describing: type(of: $0)) == "UITabBarButton" }
                .sorted { $0.frame.minX < $1.frame.minX } ?? []

            let tabBarOriginX = tabBar.map { $0.convert($0.bounds, to: container).minX } ?? 0

            let landingX: CGFloat
            if tabBarButtons.count > mindfulnessIndex {
                landingX = tabBarOriginX + tabBarButtons[mindfulnessIndex].frame.midX
            } else {
                landingX = container.bounds.width / CGFloat(totalTabs) * (CGFloat(mindfulnessIndex) + 0.5)
            }
            let landingY = container.bounds.maxY - tabBarHeight / 2

            let startCenter = card.center

            // -- Brief squeeze before launch --
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    card.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
                }
            )

            // -- Arc toward Mindfulness tab using a keyframe path --
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                Self.emitSparkles(from: startCenter, in: container)

                let flyDuration: Double = 0.55

                // CAKeyframeAnimation for a smooth curved arc
                let pathAnim = CAKeyframeAnimation(keyPath: "position")
                let path = UIBezierPath()
                path.move(to: startCenter)
                // Control point arcs slightly upward then swoops down to the tab
                let controlPoint = CGPoint(
                    x: (startCenter.x + landingX) / 2,
                    y: startCenter.y - 60
                )
                path.addQuadCurve(to: CGPoint(x: landingX, y: landingY),
                                  controlPoint: controlPoint)
                pathAnim.path = path.cgPath
                pathAnim.duration = flyDuration
                pathAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
                pathAnim.fillMode = .forwards
                pathAnim.isRemovedOnCompletion = false

                // Shrink + fade simultaneously
                UIView.animate(
                    withDuration: flyDuration,
                    delay: 0,
                    options: [.curveEaseIn],
                    animations: {
                        card.transform = CGAffineTransform(scaleX: 0.08, y: 0.08)
                        card.alpha = 0
                    },
                    completion: { _ in
                        card.removeFromSuperview()
                        objc_setAssociatedObject(container, &AssociatedKey.animatorKey, nil,
                                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    }
                )

                card.layer.add(pathAnim, forKey: "flyToTab")
            }
        }
    }

    private func buildCard(memory: Memory) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor  = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.18
        card.layer.shadowRadius  = 22
        card.layer.shadowOffset  = CGSize(width: 0, height: 8)
        card.clipsToBounds = false

        let imageView = UIImageView(frame: CGRect(x: 12, y: 12, width: cardWidth - 24, height: 148))
        imageView.image = memory.image ?? UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        card.addSubview(imageView)

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let dateLabel = UILabel(frame: CGRect(x: 14, y: 168, width: cardWidth - 28, height: 16))
        dateLabel.text = formatter.string(from: memory.date)
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = UIColor(white: 0.45, alpha: 1)
        card.addSubview(dateLabel)

        let noteLabel = UILabel(frame: CGRect(x: 14, y: 186, width: cardWidth - 28, height: 40))
        noteLabel.text = memory.note ?? "Memory"
        noteLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        noteLabel.textColor = UIColor(white: 0.10, alpha: 1)
        noteLabel.numberOfLines = 2
        card.addSubview(noteLabel)

        return card
    }

    private func buildToast(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.80)
        label.layer.cornerRadius = 18
        label.clipsToBounds = true

        let maxWidth: CGFloat = 280
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        let textSize = label.sizeThatFits(CGSize(width: maxWidth - padding.left - padding.right,
                                                  height: .greatestFiniteMagnitude))
        let width  = min(textSize.width + padding.left + padding.right, maxWidth)
        let height = textSize.height + padding.top + padding.bottom
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return label
    }

    private func buildSavedBadge() -> UIView {
        let size: CGFloat = 36
        let pill = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        pill.backgroundColor = UIColor(red: 0.98, green: 0.67, blue: 0.82, alpha: 1)
        pill.layer.cornerRadius = size / 2
        pill.layer.shadowColor  = UIColor(red: 0.95, green: 0.45, blue: 0.65, alpha: 1).cgColor
        pill.layer.shadowOpacity = 0.45
        pill.layer.shadowRadius  = 8
        pill.layer.shadowOffset  = CGSize(width: 0, height: 3)

        let checkmark = UIImageView(frame: pill.bounds.insetBy(dx: 8, dy: 8))
        checkmark.image = UIImage(systemName: "checkmark")
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        pill.addSubview(checkmark)

        return pill
    }

    private static func emitSparkles(from point: CGPoint, in view: UIView) {
        let colors: [UIColor] = [
            UIColor(red: 0.98, green: 0.67, blue: 0.82, alpha: 1),
            UIColor(red: 0.95, green: 0.56, blue: 0.71, alpha: 1),
            UIColor(red: 1.00, green: 0.85, blue: 0.70, alpha: 1),
            UIColor(red: 0.75, green: 0.60, blue: 0.98, alpha: 1),
        ]

        for i in 0..<10 {
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            dot.backgroundColor = colors[i % colors.count]
            dot.layer.cornerRadius = 3.5
            dot.center = point
            view.addSubview(dot)

            let angle = CGFloat(i) / 10.0 * .pi * 2 + CGFloat.random(in: -0.3 ... 0.3)
            let distance = CGFloat.random(in: 55 ... 110)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance

            UIView.animate(
                withDuration: Double.random(in: 0.45 ... 0.70),
                delay: Double(i) * 0.018,
                options: [.curveEaseOut],
                animations: {
                    dot.center = CGPoint(x: point.x + dx, y: point.y + dy)
                    dot.alpha  = 0
                    dot.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                },
                completion: { _ in dot.removeFromSuperview() }
            )
        }
    }
}
