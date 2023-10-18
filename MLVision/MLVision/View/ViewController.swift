//
//  ViewController.swift
//  MLVision
//
//  Created by Aleksey Libin on 18.10.2023.
//

import UIKit
import CoreML

protocol MLVisionViewControllerProtocol {
  /// Handles an error by presenting an alert to the user
  func showAlert(with error: Error)
  func resultLabel(updateValue text: String)
}

final class MLVisionViewController: UIViewController {
  private var presenter: MLVisionPresenterProtocol?
  private let picker: UIImagePickerController
  private let imageView: UIImageView
  private let selectImageButton: UIButton
  private let resultLabel: UILabel
  
  init() {
    imageView = UIImageView()
    selectImageButton = UIButton(type: .system)
    resultLabel = UILabel()
    picker = UIImagePickerController()
    super.init(nibName:  nil, bundle: nil)
    
    presenter = MLVisionPresenter(viewController: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  /// Shows an Image Picker to let user choose an image from photo library
  @objc private func selectImage() {
    present(picker, animated: true)
  }
}

// MARK: - MLVisionViewControllerProtocol
extension MLVisionViewController: MLVisionViewControllerProtocol {
  func showAlert(with error: Error) {
    let alertController = UIAlertController(title: "Error",
                                            message: error.localizedDescription,
                                            preferredStyle: .alert)
    let confirmButton = UIAlertAction(title: "Confirm", style: .default)
    alertController.addAction(confirmButton)
    present(alertController, animated: true)
  }
  
  func resultLabel(updateValue text: String) {
    resultLabel.text = text
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MLVisionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
    picker.dismiss(animated: true)
    imageView.image = image
    presenter?.analyzeImage(image: image)
  }
}

// MARK: - Views
extension MLVisionViewController {
  private func setupViews() {
    view.backgroundColor = UIColor(named: "BackgroundColor")
    
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .systemBlue
    imageView.image = UIImage(systemName: "photo")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    
    picker.sourceType = .photoLibrary
    picker.delegate = self
    
    selectImageButton.setTitle("Select image", for: .normal)
    selectImageButton.setTitleColor(.white, for: .normal)
    selectImageButton.backgroundColor = .systemBlue
    selectImageButton.layer.masksToBounds = true
    selectImageButton.layer.cornerRadius = 20
    selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
    selectImageButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(selectImageButton)
    
    resultLabel.textAlignment = .center
    resultLabel.textColor = UIColor(named: "AccentColor")
    resultLabel.font = .boldSystemFont(ofSize: 20)
    resultLabel.numberOfLines = 0
    resultLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(resultLabel)
    
    activateConstraints()
  }
  
  private func activateConstraints() {
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
      resultLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor),
      resultLabel.heightAnchor.constraint(equalToConstant: 100),
      resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      selectImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
      selectImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
      selectImageButton.heightAnchor.constraint(equalTo: selectImageButton.widthAnchor, multiplier: 0.2),
      selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
}
