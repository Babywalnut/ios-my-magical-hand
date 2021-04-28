import UIKit
import Vision

class ViewController: UIViewController {
    // MARK: UI Components
    private let blurBackgroundView: UIVisualEffectView = {
        let blurBackgroundView = UIVisualEffectView()
        blurBackgroundView.effect = UIBlurEffect(style: .dark)
        return blurBackgroundView
    }()
    private let canvasView = CanvasView()
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        return buttonStackView
    }()
    private let showingResultButton: UIButton = {
        let showingResultButton = UIButton(type: .system)
        showingResultButton.setTitle("결과보기", for: .normal)
        showingResultButton.setTitleColor(.systemOrange, for: .normal)
        showingResultButton.addTarget(self, action: #selector(showResult), for: .touchUpInside)
        return showingResultButton
    }()
    private let removalButton: UIButton = {
        let removalButton = UIButton(type: .system)
        removalButton.setTitle("지우기", for: .normal)
        removalButton.setTitleColor(.systemGray2, for: .normal)
        removalButton.addTarget(self, action: #selector(removeDrawing), for: .touchUpInside)
        return removalButton
    }()
    private let labelStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.spacing = 12
        labelStackView.distribution = .equalSpacing
        labelStackView.isHidden = true
        return labelStackView
    }()
    private let returnResultLabel: UILabel = {
        let returnResultLabel = UILabel()
        returnResultLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        returnResultLabel.textColor = .systemGray6
        returnResultLabel.numberOfLines = 0
        return returnResultLabel
    }()
    private let similarProportionLabel: UILabel = {
        let similarProportionLabel = UILabel()
        similarProportionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        similarProportionLabel.textColor = .systemGray2
        similarProportionLabel.numberOfLines = 0
        return similarProportionLabel
    }()
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
//            let model = try VNCoreMLModel(for: ShapeImageClassifier().model)
            let model = try VNCoreMLModel(for: ShapeDetectorKeras().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()

    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
    }
}

// MARK:- Extensions
extension ViewController {
    //MARK: Methods
    private func setConstraints() {
        view.addSubview(blurBackgroundView)
        view.addSubview(canvasView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(showingResultButton)
        buttonStackView.addArrangedSubview(removalButton)
        view.addSubview(labelStackView)
        labelStackView.addArrangedSubview(returnResultLabel)
        labelStackView.addArrangedSubview(similarProportionLabel)

        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        showingResultButton.translatesAutoresizingMaskIntoConstraints = false
        removalButton.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        returnResultLabel.translatesAutoresizingMaskIntoConstraints = false
        similarProportionLabel.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            blurBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            blurBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            canvasView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            canvasView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -50),
            canvasView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            canvasView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            canvasView.heightAnchor.constraint(equalTo: canvasView.widthAnchor),

            buttonStackView.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30),

            labelStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 32),
            labelStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            labelStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: -100)
        ])
    }

    //MARK: Selectors
    @objc private func removeDrawing() {
        returnResultLabel.text = ""
        similarProportionLabel.text = ""
        labelStackView.isHidden = true
        canvasView.eraseAll()
    }

    @objc private func showResult() {
        guard let image = canvasView.exportDrawing() else {
            return
        }
        updateClassifications(for: image)
        labelStackView.isHidden = false
    }
    
    private func updateClassifications(for image: UIImage) {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            return
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results,
                  let classifications = results as? [VNClassificationObservation] else {
                return
            }
            let topClassifications = classifications.prefix(1)
            let descriptions = topClassifications.map { classification in
                return (confidence: classification.confidence, identifier: classification.identifier)
            }
            guard let shape = descriptions.first?.identifier,
                  let confidence = descriptions.first?.confidence else {
                self.returnResultLabel.text = "결과를 도출할 수 없습니다."
                return
            }
            let similarProportion = (confidence * 100).rounded()
            self.returnResultLabel.text = "\(shape)처럼 보이네요."
            self.similarProportionLabel.text = "\(similarProportion) %"
        }
    }
}
