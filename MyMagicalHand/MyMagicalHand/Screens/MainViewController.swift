//
//  MyMagicalHand - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class MainViewController: UIViewController {
    
    private let tempImageView = UIImageView()
    private let canvasView = UIView()
    private let shapeLabel = ResultLabel()
    private let probabilityLabel = ResultLabel()
    private let estimateButton = UIButton()
    private let resetButton = UIButton()
    private let mainStackView = MainStackView()
    private let buttonStackView = ButtonStackView()
    
    private var lastPoint = CGPoint.zero
    private var Inkcolor = UIColor.black
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray
        configureEstimateButton()
        configureResetButton()
        configureTempImageView()
        configureCanvasView()
        configureButtonStackView()
        configureResultLabel()
        configureProbabilityLabel()
        configureMainStackView()
    }
    
    /// Functional Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        shapeLabel.text = nil
        probabilityLabel.text = nil
        swiped = false
        lastPoint = touch.location(in: canvasView)
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
      UIGraphicsBeginImageContext(canvasView.frame.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        return
      }
        
      tempImageView.image?.draw(in: canvasView.bounds)
      
      context.move(to: fromPoint)
      context.addLine(to: toPoint)
      context.setLineCap(.round)
      context.setBlendMode(.normal)
      context.setLineWidth(brushWidth)
      context.setStrokeColor(Inkcolor.cgColor)
      
      context.strokePath()
      
      tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      tempImageView.alpha = opacity
      UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
        swiped = true
        let currentPoint = touch.location(in: canvasView)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      if !swiped {
        drawLine(from: lastPoint, to: lastPoint)
      }
      
      UIGraphicsBeginImageContext(tempImageView.frame.size)
      tempImageView.image?.draw(in: canvasView.bounds, blendMode: .normal, alpha:opacity)
      tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }
    
    @objc func resultPressed() {
        shapeLabel.text = "어떤 모양일까요?"
        probabilityLabel.text = "0 %"
    }
    
    @objc func resetPressed() {
        tempImageView.image = nil
        shapeLabel.text = nil
        probabilityLabel.text = nil
    }
    
    /// UI Layout Configure Methods
    func configureTempImageView() {
        canvasView.addSubview(tempImageView)
        tempImageView.backgroundColor = UIColor.white
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tempImageView.topAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.topAnchor),
            tempImageView.bottomAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.bottomAnchor),
            tempImageView.leadingAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.leadingAnchor),
            tempImageView.trailingAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func configureEstimateButton() {
        buttonStackView.addArrangedSubview(estimateButton)
        estimateButton.setTitle("결과보기", for: .normal)
        estimateButton.setTitleColor(UIColor.systemOrange, for: .normal)
        estimateButton.addTarget(self, action: #selector(resultPressed), for: .touchUpInside)
    }
    
    func configureResetButton() {
        buttonStackView.addArrangedSubview(resetButton)
        resetButton.setTitle("지우기", for: .normal)
        resetButton.setTitleColor(UIColor.white, for: .normal)
        resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
    }
    
    func configureCanvasView() {
        mainStackView.addArrangedSubview(canvasView)
    }
    
    func configureButtonStackView() {
        mainStackView.addArrangedSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: view.frame.size.height / 20)
        ])
    }
    
    func configureResultLabel() {
        mainStackView.addArrangedSubview(shapeLabel)
        
        NSLayoutConstraint.activate([
            shapeLabel.heightAnchor.constraint(equalToConstant: view.frame.height / 20)
        ])
    }
    
    func configureProbabilityLabel() {
        mainStackView.addArrangedSubview(probabilityLabel)
        
        NSLayoutConstraint.activate([
            probabilityLabel.heightAnchor.constraint(equalToConstant: view.frame.height / 20)
        ])
    }
    
    func configureMainStackView() {
        view.addSubview(mainStackView)
        mainStackView.layoutMargins = UIEdgeInsets(top: view.frame.size.height / 6, left: view.frame.size.width / 20,
                                                   bottom: view.frame.size.height / 6, right: view.frame.size.width / 20)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
