//
//  ViewController.swift
//  FirstGameCircle
//
//  Created by Борис Ларионов on 16.05.2026.
//

import UIKit

final class ViewController: UIViewController {

    private var circles: [GameCircleView] = []
    private var initialCenters: [ObjectIdentifier: CGPoint] = [:]
    private let growthFactor: CGFloat = 1.2
    private let mergeAnimationDuration: TimeInterval = 2.0
    private let colorAnimationStartFraction: Double = 0.125

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureCircles()
    }

    private func configureAppearance() {
        view.backgroundColor = UIColor(red: 0.97, green: 0.95, blue: 0.90, alpha: 1.0)
    }

    private func configureCircles() {
        circles = view.subviews.compactMap { $0 as? GameCircleView }

        for circle in circles {
            circle.configure(totalCircleCount: circles.count)
            initialCenters[ObjectIdentifier(circle)] = circle.center
            attachRecognizers(to: circle)
        }
    }

    private func attachRecognizers(to circle: GameCircleView) {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))

        panRecognizer.maximumNumberOfTouches = 1
        longPressRecognizer.minimumPressDuration = 0.35
        tapRecognizer.require(toFail: longPressRecognizer)

        circle.addGestureRecognizer(panRecognizer)
        circle.addGestureRecognizer(tapRecognizer)
        circle.addGestureRecognizer(longPressRecognizer)
    }

    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let circle = recognizer.view as? GameCircleView, !circle.isHidden else { return }
        circle.setSelected(!circle.isSelectedForDemo)
    }

    @objc
    private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let circle = recognizer.view as? GameCircleView, !circle.isHidden else { return }

        switch recognizer.state {
        case .began:
            circle.setPressed(true)
        case .ended, .cancelled, .failed:
            circle.setPressed(false)
        default:
            break
        }
    }

    @objc
    private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let circle = recognizer.view as? GameCircleView, !circle.isHidden else { return }

        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .began:
            view.bringSubviewToFront(circle)
            circle.setSelected(true)
        case .changed:
            circle.center = boundedCenter(for: circle.center.applying(.init(translationX: translation.x, y: translation.y)),
                                          size: circle.bounds.size)
            recognizer.setTranslation(.zero, in: view)
        case .ended:
            finishPan(for: circle)
        case .cancelled, .failed:
            resetPosition(for: circle)
        default:
            break
        }
    }

    private func finishPan(for draggedCircle: GameCircleView) {
        guard let targetCircle = mergeTarget(for: draggedCircle) else {
            savePosition(for: draggedCircle)
            draggedCircle.setSelected(false)
            draggedCircle.setPressed(false)
            return
        }

        merge(draggedCircle, into: targetCircle)
    }

    private func mergeTarget(for draggedCircle: GameCircleView) -> GameCircleView? {
        circles.first { candidate in
            candidate !== draggedCircle &&
            !candidate.isHidden &&
            draggedCircle.frame.intersects(candidate.frame.insetBy(dx: 8, dy: 8))
        }
    }

    private func merge(_ draggedCircle: GameCircleView, into targetCircle: GameCircleView) {
        let transferredCircleCount = draggedCircle.representedCircleCount
        draggedCircle.setSelected(false)
        draggedCircle.setPressed(false)
        targetCircle.setSelected(false)

        animateMerge(
            draggedCircle,
            into: targetCircle,
            transferredCircleCount: transferredCircleCount
        )
    }

    private func animateMerge(
        _ draggedCircle: GameCircleView,
        into targetCircle: GameCircleView,
        transferredCircleCount: Int
    ) {
        let targetColor = targetCircle.projectedColor(afterMerging: transferredCircleCount)
        let targetScale = targetCircle.mergeScale * growthFactor
        let disappearingScale: CGFloat = 0.82

        draggedCircle.isUserInteractionEnabled = false
        targetCircle.isUserInteractionEnabled = false
        view.bringSubviewToFront(draggedCircle)
        view.bringSubviewToFront(targetCircle)

        UIView.animateKeyframes(
            withDuration: mergeAnimationDuration,
            delay: 0,
            options: [.calculationModeCubic, .beginFromCurrentState],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.45) {
                    targetCircle.applyMergeScale(targetScale)
                }

                UIView.addKeyframe(
                    withRelativeStartTime: self.colorAnimationStartFraction,
                    relativeDuration: 1.0 - self.colorAnimationStartFraction
                ) {
                    targetCircle.setBodyColor(targetColor)
                }

                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    draggedCircle.alpha = 0.0
                    draggedCircle.transform = CGAffineTransform(scaleX: disappearingScale, y: disappearingScale)
                }
            },
            completion: { [weak self] _ in
                guard let self else { return }

                targetCircle.mergeIn(circleCount: transferredCircleCount)
                targetCircle.applyMergeScale(targetScale)

                draggedCircle.removeFromSuperview()
                self.circles.removeAll { $0 === draggedCircle }
                self.initialCenters.removeValue(forKey: ObjectIdentifier(draggedCircle))

                self.savePosition(for: targetCircle)
                targetCircle.isUserInteractionEnabled = true
            }
        )
    }

    private func resetPosition(for circle: GameCircleView) {
        if let initialCenter = initialCenters[ObjectIdentifier(circle)] {
            circle.center = initialCenter
        }
        circle.setSelected(false)
        circle.setPressed(false)
    }

    private func savePosition(for circle: GameCircleView) {
        initialCenters[ObjectIdentifier(circle)] = circle.center
    }

    private func boundedCenter(for proposedCenter: CGPoint, size: CGSize) -> CGPoint {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        return CGPoint(
            x: min(max(proposedCenter.x, halfWidth), view.bounds.width - halfWidth),
            y: min(max(proposedCenter.y, halfHeight + view.safeAreaInsets.top),
                   view.bounds.height - halfHeight - view.safeAreaInsets.bottom)
        )
    }
}
