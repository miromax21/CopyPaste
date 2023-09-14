//
//  SelectUserViewController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 17.10.2022.
//

import Foundation
import UIKit

final class SelectViewController: UIViewController, CustomPresentable {
  var completion: ((Any?) -> Void)?
  var transitionManager: UIViewControllerTransitioningDelegate?
  private (set) var topView: UIView!
  private (set) var bottomView: UIView!
  private (set) var listView: (UIDataSourceTranslating & UIView)!
  var viewModel: SelectViewModel! {
    didSet {
      setUpViews()
    }
  }

  convenience init(selectButtonText: String?) {
    self.init()
    customInit(selectButtonText: selectButtonText)
    initViews()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.configuration.initComplete?(listView)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    completion?(nil)
  }
}

extension SelectViewController {
  private func customInit(selectButtonText: String?) {
    if let text = selectButtonText {
      let selectButton = ViewBuilder(title: text, style: .filled).makeButton()
      selectButton.setTitle(title, for: .normal)
      selectButton.onClick = { [weak self] in
        self?.completion?(nil)
      }
      selectButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
      bottomView = selectButton
    }
  }

  private func initViews() {
    self.view.backgroundColor = AppColors.backgroundMain.color
  }

  private func initView(from: SelectViewModeConfiguration.SubviewType?, intoTop: Bool = false) -> UIView {
    switch from {
      case .someView(let view): return view
      case .defaultForPlacement(let text):
        if intoTop {
          let titleLabel = UILabel()
          titleLabel.backgroundColor = AppColors.white.color
          titleLabel.textAlignment = .center
          return titleLabel
        } else {
          let selectButton: CustomButton = ViewBuilder(title: text, style: .filled).makeButton()
          selectButton.onClick = { [weak self] in
            self?.completion?(nil)
          }
          viewModel.configuration.horizontallMetrics[.bottomView] = "[v0(>=130,<=240)]"
          selectButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
          let footerView = UIView()
          footerView.addSubview(selectButton)
          footerView.addConstraintsWithFormat("H:[v0(>=130,<=240)]", options: .alignAllCenterX, views: selectButton)
          let btnSize = (viewModel.configuration.vertivalMetrics[.bottomView] ?? 60) - 20
          footerView.addConstraintsWithFormat("V:[v0(\(btnSize))]", options: .alignAllCenterY, views: selectButton)
          return footerView
        }
      default: return UIView()
    }
  }

  private func setUpViews() {
    let config = viewModel.configuration
    listView = viewModel.configuration.collectionView
    bottomView = initView(from: config?.bottomView)
    topView = initView(from: config?.topView, intoTop: true)
    setUpLayers()
  }

  private func setUpLayers() {
    typealias Metrics = SelectViewModeConfiguration.Metrics
    var views: [String: UIView] = [:]
    var stringFormat = ""
    let configuration: SelectViewModeConfiguration! = viewModel.configuration!
    let options : [(view: UIView?, name: String, constraint: String)] =
    [
      (topView, "topView", "-15-[topView(\(configuration.vertivalMetrics[.topView] ?? 50))]"),
      (listView, "listView", "-[listView(>=\(configuration.vertivalMetrics[.listMin] ?? 300))]"),
      (bottomView, "bottomView", "-[bottomView(\(configuration.vertivalMetrics[.bottomView] ?? 60))]")
    ]
    
    options.forEach {
      if let subview = $0.view {
        stringFormat += $0.constraint
        view.addSubview(subview)
        if let metric = Metrics(rawValue: $0.name), let value = configuration.horizontallMetrics[metric] {
          view.addConstraintsWithFormat(value, options: .alignAllCenterY, views: subview)
        } else {
          view.addConstraintsWithFormat("H:|[v0]|", options: .alignAllCenterY, views: subview)
        }
        views[$0.name] = subview
      }
    }
    var metrics: [String:String] = [:]
    if let vertivalMetrics = configuration.vertivalMetrics {
      vertivalMetrics.forEach {
        metrics[$0.key.rawValue] = "\($0.value)"
      }
    }
    view.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "V:|\(stringFormat)-|",
      options: .alignAllCenterX,
      metrics: metrics,
      views: views
    ))
    view.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    view.backgroundColor = AppColors.backgroundMain.color
  }

  @nonobjc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.configuration.selectedItem = indexPath
  }
}
// MARK: - UIScrollViewDelegate
extension SelectViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < -1 * viewModel.configuration.scrollForHide {
      completion?(nil)
      self.dismiss(animated: true)
    }
  }
}
