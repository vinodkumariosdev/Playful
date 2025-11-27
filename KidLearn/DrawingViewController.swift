// DrawingViewController.swift
// KidLearn drawing feature for kids
// Provides a simple canvas with color palette, brush size, clear and save functionality.

import UIKit
import Photos

final class DrawingViewController: UIViewController {
    // MARK: - Canvas State
    private var path = UIBezierPath()
    private var lines: [(path: UIBezierPath, color: UIColor, width: CGFloat)] = []
    private var currentColor: UIColor = .black
    private var currentLineWidth: CGFloat = 5.0

    // MARK: - UI Elements
    private let canvasView = UIImageView()
    private let colorStack = UIStackView()
    private let brushSlider = UISlider()
    private let clearButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Draw"
        setupCanvas()
        setupControls()
    }

    // MARK: - Setup UI
    private func setupCanvas() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isUserInteractionEnabled = true
        canvasView.backgroundColor = .white
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupControls() {
        // Color palette
        let colors: [UIColor] = [.black, .red, .blue, .green, .orange, .purple]
        colorStack.axis = .horizontal
        colorStack.distribution = .fillEqually
        colorStack.spacing = 8
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        for c in colors {
            let btn = UIButton(type: .system)
            btn.backgroundColor = c
            btn.layer.cornerRadius = 15
            btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
            colorStack.addArrangedSubview(btn)
        }
        view.addSubview(colorStack)

        // Brush size slider
        brushSlider.minimumValue = 1
        brushSlider.maximumValue = 20
        brushSlider.value = Float(currentLineWidth)
        brushSlider.addTarget(self, action: #selector(brushSizeChanged(_:)), for: .valueChanged)
        brushSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(brushSlider)

        // Clear button
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveCanvas), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        // Layout controls
        NSLayoutConstraint.activate([
            colorStack.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 20),
            colorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            colorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            brushSlider.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 12),
            brushSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            brushSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearButton.topAnchor.constraint(equalTo: brushSlider.bottomAnchor, constant: 12),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.topAnchor.constraint(equalTo: brushSlider.bottomAnchor, constant: 12),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    // MARK: - Color & Brush Actions
    @objc private func colorSelected(_ sender: UIButton) {
        guard let bg = sender.backgroundColor else { return }
        currentColor = bg
    }

    @objc private func brushSizeChanged(_ sender: UISlider) {
        currentLineWidth = CGFloat(sender.value)
    }

    // MARK: - Canvas Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: canvasView)
        path = UIBezierPath()
        path.lineWidth = currentLineWidth
        path.lineCapStyle = .round
        path.move(to: point)
        lines.append((path: path, color: currentColor, width: currentLineWidth))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: canvasView)
        path.addLine(to: point)
        redrawCanvas()
    }

    private func redrawCanvas() {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        // Fill background
        UIColor.white.setFill()
        UIBezierPath(rect: canvasView.bounds).fill()
        // Draw all stored lines
        for line in lines {
            line.color.setStroke()
            line.path.lineWidth = line.width
            line.path.stroke()
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        canvasView.image = img
    }

    // MARK: - Control Actions
    @objc private func clearCanvas() {
        lines.removeAll()
        canvasView.image = nil
    }

    @objc private func saveCanvas() {
        guard let img = canvasView.image else { return }
        // Request permission if needed
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: success ? "Saved" : "Error",
                                                  message: success ? "Your drawing was saved to Photos." : (error?.localizedDescription ?? "Failed to save."),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
