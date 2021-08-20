//
//  CanvasView.swift
//  MyMagicalHand
//
//  Created by 김민성 on 2021/08/19.
//

import UIKit

final class CanvasView: UIImageView {
    
    private var lastPoint = CGPoint.zero
    private var inkColor = UIColor.black
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var swiped = false
    
    override init(image: UIImage?) {
        super.init(image: image)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("fuck")
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name("screenDidTouched"), object: nil)
        swiped = false
        lastPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
        swiped = true
        let currentPoint = touch.location(in: self)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      if !swiped {
        drawLine(from: lastPoint, to: lastPoint)
      }
        UIGraphicsBeginImageContext(frame.size)
        image?.draw(in: bounds, blendMode: .normal, alpha:opacity)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
      UIGraphicsBeginImageContext(self.frame.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        return
      }
        
      self.image?.draw(in: self.bounds)
      
      context.move(to: fromPoint)
      context.addLine(to: toPoint)
      context.setLineCap(.round)
      context.setBlendMode(.normal)
      context.setLineWidth(brushWidth)
      context.setStrokeColor(inkColor.cgColor)
      
      context.strokePath()
      
      self.image = UIGraphicsGetImageFromCurrentImageContext()
      self.alpha = opacity
      UIGraphicsEndImageContext()
    }
    
    private func configure() {
        backgroundColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
    }
}
