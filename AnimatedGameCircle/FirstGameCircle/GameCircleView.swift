//
//  GameCircleView.swift
//  FirstGameCircle
//
//  Created by Codex on 16.05.2026.
//

import UIKit

@IBDesignable
final class GameCircleView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var circleBodyView: UIView!

    private(set) var isSelectedForDemo = false
    private let selectedBorderColor = UIColor(red: 0.99, green: 0.78, blue: 0.18, alpha: 1.0)
    private let startColor = UIColor(red: 0.08, green: 0.48, blue: 0.98, alpha: 1.0)
    private let finishColor = UIColor(red: 0.03, green: 0.16, blue: 0.43, alpha: 1.0)
    private(set) var representedCircleCount = 1
    private var totalCircleCount = 7
    private(set) var mergeScale: CGFloat = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        circleBodyView.frame = contentView.bounds
        circleBodyView.layer.cornerRadius = bounds.width / 2
    }

    func configure(totalCircleCount: Int) {
        self.totalCircleCount = max(totalCircleCount, 1)
        updateColor()
    }

    func mergeIn(circleCount: Int) {
        representedCircleCount += circleCount
        updateColor()
        circleBodyView.layer.borderColor = UIColor.clear.cgColor
    }

    func projectedColor(afterMerging circleCount: Int) -> UIColor {
        let futureCount = representedCircleCount + circleCount
        let progressDenominator = max(totalCircleCount - 1, 1)
        let progress = CGFloat(futureCount - 1) / CGFloat(progressDenominator)
        return interpolatedColor(progress: progress)
    }

    func applyMergeScale(_ scale: CGFloat) {
        mergeScale = scale
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    func bodyColor() -> UIColor {
        circleBodyView.backgroundColor ?? startColor
    }

    func setBodyColor(_ color: UIColor) {
        circleBodyView.backgroundColor = color
    }

    func setSelected(_ isSelected: Bool) {
        isSelectedForDemo = isSelected
        circleBodyView.layer.borderWidth = isSelected ? 4 : 0
        circleBodyView.layer.borderColor = isSelected ? selectedBorderColor.cgColor : UIColor.clear.cgColor
    }

    func setPressed(_ isPressed: Bool) {
        alpha = isPressed ? 0.7 : 1.0
    }

    private func commonInit() {
        guard contentView == nil else { return }

        Bundle(for: GameCircleView.self).loadNibNamed(
            String(describing: GameCircleView.self),
            owner: self,
            options: nil
        )
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.backgroundColor = .clear

        circleBodyView.frame = contentView.bounds
        circleBodyView.translatesAutoresizingMaskIntoConstraints = true
        circleBodyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circleBodyView.layer.masksToBounds = true
        circleBodyView.backgroundColor = startColor

        isUserInteractionEnabled = true
        backgroundColor = .clear
        clipsToBounds = false
    }

    private func updateColor() {
        let progressDenominator = max(totalCircleCount - 1, 1)
        let progress = CGFloat(representedCircleCount - 1) / CGFloat(progressDenominator)
        setBodyColor(interpolatedColor(progress: progress))
    }

    private func interpolatedColor(progress: CGFloat) -> UIColor {
        let clampedProgress = min(max(progress, 0), 1)

        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0
        var finishRed: CGFloat = 0
        var finishGreen: CGFloat = 0
        var finishBlue: CGFloat = 0
        var finishAlpha: CGFloat = 0

        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        finishColor.getRed(&finishRed, green: &finishGreen, blue: &finishBlue, alpha: &finishAlpha)

        return UIColor(
            red: startRed + (finishRed - startRed) * clampedProgress,
            green: startGreen + (finishGreen - startGreen) * clampedProgress,
            blue: startBlue + (finishBlue - startBlue) * clampedProgress,
            alpha: startAlpha + (finishAlpha - startAlpha) * clampedProgress
        )
    }
}
