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

        draggedCircle.isHidden = true
        draggedCircle.setSelected(false)
        draggedCircle.setPressed(false)

        targetCircle.mergeIn(circleCount: transferredCircleCount)
        targetCircle.transform = targetCircle.transform.scaledBy(x: growthFactor, y: growthFactor)
        targetCircle.setSelected(false)
        savePosition(for: targetCircle)
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
