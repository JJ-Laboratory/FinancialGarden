//
//  Button.swift
//  FIG
//
//  Created by estelle on 8/25/25.
//

import UIKit

class CustomButton: UIButton {
    
    enum ButtonStyle {
        case plain
        case filled
        case outline
        case underline
    }
    
    var style: ButtonStyle {
        didSet { setNeedsUpdateConfiguration() }
    }
    
    init(style: ButtonStyle, frame: CGRect = .zero) {
        self.style = style
        super.init(frame: frame)
        setupHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let newHeight = max(originalSize.height, 48)
        let newWidth = max(originalSize.width, 60)
        return CGSize(width: newWidth, height: (style == .outline) ? originalSize.height : newHeight)
    }
    
    private func setupHandler() {
        configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            
            var config: UIButton.Configuration = (style == .filled) ? .filled() : .plain()
            config.cornerStyle = .medium
            config.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: (style == .outline) ? .body : .headline),
                .paragraphStyle: paragraphStyle
            ]
            
            switch style {
            case .plain:
                attributes[.foregroundColor] = UIColor.primary
            case .filled:
                config.baseBackgroundColor = .primary
                attributes[.foregroundColor] = UIColor.white
            case .outline:
                config.background.strokeWidth = 1
                config.background.strokeColor = .gray1
                attributes[.foregroundColor] = UIColor.gray1
            case .underline:
                attributes[.foregroundColor] = UIColor.gray1
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            
            let title = button.currentTitle ?? ""
            let attributedString = NSAttributedString(string: title, attributes: attributes)
            config.attributedTitle = AttributedString(attributedString)
            
            button.configuration = config
        }
    }
}
