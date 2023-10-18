//
//  Presenter.swift
//  MLVision
//
//  Created by Aleksey Libin on 18.10.2023.
//

import UIKit
import CoreML

protocol MLVisionPresenterProtocol {
  /// Analyzes the provided image and displays a relevant description on the screen./
  func analyzeImage(image: UIImage?)
}

final class MLVisionPresenter {
  private unowned var viewController: MLVisionViewController
  
  init(viewController: MLVisionViewController) {
    self.viewController = viewController
  }
  
}

// MARK: - MLVisionPresenterProtocol
extension MLVisionPresenter: MLVisionPresenterProtocol {
  func analyzeImage(image: UIImage?) {
    guard let resized = image?.resize(size: CGSize(width: 224, height: 224)),
          let buffer = resized.getCVPixelBuffer()
    else { return }
    
    do {
      try handleConfiguration(with: buffer)
    } catch {
      viewController.showAlert(with: error)
    }
  }
}

// MARK: - Business logic
extension MLVisionPresenter {
  /// Processes the machine learning model configuration for scene classification based on the provided image
  private func handleConfiguration(with buffer: CVPixelBuffer) throws {
    let config = MLModelConfiguration()
    let model = try GoogLeNetPlaces(configuration: config)
    let input = GoogLeNetPlacesInput(sceneImage: buffer)
    
    let output = try model.prediction(input: input)
    let text = output.sceneLabel
    viewController.resultLabel(updateValue: text)
  }
}
