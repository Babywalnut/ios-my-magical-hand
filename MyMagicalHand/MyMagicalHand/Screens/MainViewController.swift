//
//  MyMagicalHand - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class MainViewController: UIViewController {
    
    private let canvasView = CanvasView(image: nil)
    
    private let shapeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let probabilityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let estimateButton: UIButton = {
        let button = UIButton()
        button.setTitle("결과보기", for: .normal)
        button.setTitleColor(UIColor.systemOrange, for: .normal)
        button.addTarget(self, action: #selector(resultPressed), for: .touchUpInside)
        
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("지우기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
        
        return button
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(resetResultLabels(notification:)), name: Notification.Name("screenDidTouched"), object: nil)
        
        view.backgroundColor = UIColor.systemGray
        view.addSubview(mainStackView)
        canvasView.isUserInteractionEnabled = true
        configureMainStackView()
        configureButtonStackView()
        configureShapeLabel()
        configureProbabilityLabel()
    }
    
    /// Functional Methods
    @objc func resultPressed() {
        shapeLabel.text = "어떤 모양일까요?"
        probabilityLabel.text = "0 %"
    }
    
    @objc func resetPressed() {
        canvasView.image = nil
        shapeLabel.text = nil
        probabilityLabel.text = nil
    }
    
    @objc func resetResultLabels(notification: Notification) {
        shapeLabel.text = nil
        probabilityLabel.text = nil
    }
    
    /// UI Layout Configure Methods
    private func configureButtonStackView() {
        buttonStackView.addArrangedSubview(estimateButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: view.frame.size.height / 20)
        ])
    }
    
    private func configureShapeLabel() {
        NSLayoutConstraint.activate([
            shapeLabel.heightAnchor.constraint(equalToConstant: view.frame.height / 20)
        ])
    }
    
    private func configureProbabilityLabel() {
        NSLayoutConstraint.activate([
            probabilityLabel.heightAnchor.constraint(equalToConstant: view.frame.height / 20)
        ])
    }
    
    private func configureMainStackView() {
        mainStackView.addArrangedSubview(canvasView)
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(shapeLabel)
        mainStackView.addArrangedSubview(probabilityLabel)
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
