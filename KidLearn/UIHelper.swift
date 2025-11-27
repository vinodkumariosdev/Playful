import UIKit

/// Utility helpers for UI-related rendering.
enum UIHelper {
    /// Generate an image from an emoji string for a given size.
    static func image(from emoji: String, size: CGSize) -> UIImage? {
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = emoji
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: min(size.width, size.height) * 0.6)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    /// Generate a stylized circular icon image with gradient and emoji.
    static func makeStylizedIcon(emoji: String, size: CGFloat, bgColor: UIColor) -> UIImage? {
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        // gradient circle background
        let rect = CGRect(origin: .zero, size: imageSize)
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2))
        ctx.saveGState()
        path.addClip()
        let start = bgColor.withAlphaComponent(1.0).cgColor
        let end = bgColor.withAlphaComponent(0.95).cgColor
        let colors = [start, end] as CFArray
        if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0,1]) {
            ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: imageSize.height), options: [])
        }
        ctx.restoreGState()

        // soft shadow
        ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 8, color: Theme.cardShadow.cgColor)

        // inner highlight
        let innerRect = rect.insetBy(dx: size * 0.08, dy: size * 0.08)
        let innerPath = UIBezierPath(ovalIn: innerRect)
        UIColor.white.withAlphaComponent(0.06).setFill()
        innerPath.fill()

        // emoji
        let emojiFont = UIFont.systemFont(ofSize: size * 0.55)
        let attrs: [NSAttributedString.Key: Any] = [ .font: emojiFont ]
        let attrStr = NSAttributedString(string: emoji, attributes: attrs)
        let textSize = attrStr.size()
        let textRect = CGRect(x: (imageSize.width - textSize.width)/2, y: (imageSize.height - textSize.height)/2, width: textSize.width, height: textSize.height)
        attrStr.draw(in: textRect)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
