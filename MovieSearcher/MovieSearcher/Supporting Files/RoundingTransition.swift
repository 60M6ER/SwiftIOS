//
//  RoundingTransition.swift
//  MovieSearcher
//
//  Created by OpenAI on 21.05.2026.
//

import UIKit

final class RoundingTransition: NSObject {
    // Режим переключает открытие и закрытие fullscreen.
    enum TransitionProfile {
        case show
        case dismiss
    }

    // Фрейм картинки, из которой стартует fullscreen.
    var sourceFrame = CGRect.zero

    // Длительность перехода.
    var duration: TimeInterval = 0.7

    // Текущее состояние перехода.
    var transitionProfile: TransitionProfile = .show
}

extension RoundingTransition: UIViewControllerAnimatedTransitioning {
    // Длительность возвращается прямо из свойства.
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    // Переход выбирается по текущему состоянию.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionProfile {
        case .show:
            animateShowTransition(using: transitionContext)
        case .dismiss:
            animateDismissTransition(using: transitionContext)
        }
    }
}

private extension RoundingTransition {
    // Открытие растягивает fullscreen из прямоугольника картинки.
    func animateShowTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let showedView = transitionContext.view(forKey: .to),
            let showedViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: showedViewController)
        let startFrame = sourceFrame == .zero ? finalFrame : sourceFrame

        showedView.frame = finalFrame
        showedView.transform = startTransform(from: startFrame, to: finalFrame)
        showedView.layer.cornerRadius = 18
        showedView.layer.cornerCurve = .continuous
        showedView.clipsToBounds = true

        if let navigationController = showedViewController as? UINavigationController {
            navigationController.navigationBar.alpha = 0
        }

        containerView.addSubview(showedView)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.96,
            initialSpringVelocity: 0.12,
            options: [.curveEaseInOut]
        ) {
            showedView.transform = .identity
            showedView.layer.cornerRadius = 0
        } completion: { finished in
            showedView.clipsToBounds = false
            transitionContext.completeTransition(finished)
        }
    }

    // Закрытие уводит fullscreen вниз.
    func animateDismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let returnableView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let targetCenterY = transitionContext.containerView.bounds.maxY + (returnableView.bounds.height / 2)

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            returnableView.center.y = targetCenterY
            returnableView.alpha = 0.92
        } completion: { finished in
            returnableView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }

    // Стартовая геометрия fullscreen.
    func startTransform(from sourceFrame: CGRect, to finalFrame: CGRect) -> CGAffineTransform {
        let scaleX = sourceFrame.width / max(finalFrame.width, 1)
        let scaleY = sourceFrame.height / max(finalFrame.height, 1)
        let translateX = sourceFrame.midX - finalFrame.midX
        let translateY = sourceFrame.midY - finalFrame.midY

        return CGAffineTransform(translationX: translateX, y: translateY)
            .scaledBy(x: scaleX, y: scaleY)
    }
}
