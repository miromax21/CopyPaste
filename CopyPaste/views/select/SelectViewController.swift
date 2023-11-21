//
//  SelectUserViewController.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 17.10.2022.
//

import Foundation
import UIKit

final class SelectViewController: UIViewController, CustomPresentable {
  var completion: ((CustomPresentableCopletion) -> Void)?
  var transitionManager: UIViewControllerTransitioningDelegate?
  var viewModel: SelectViewModel! {
    didSet {
      setViews()
    }
  }
  var isLoaded: Bool! {
    didSet {
      if !isLoaded {
        loader = Loading()
        present(loader!, animated: true)
      } else {
        loader?.dismiss(animated: true, completion: { [weak self] in
          self?.loader = nil
        })
      }
    }
  }
  private var loader: Loading?
  private (set) var topView: UIView!
  private (set) var bottomView: UIView!
  private (set) var listView: (UIDataSourceTranslating & UIView)!

  convenience init(selectButtonText: String?) {
    self.init()
    customInit(selectButtonText: selectButtonText)

  }
  override func viewDidLoad() {
    super.viewDidLoad()
    isLoaded = false
    setViewsCustomisations()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.configuration.initComplete?(listView)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    completion?(.cancel)
  }
}

// MARK: - controll state
extension SelectViewController {
  private func customInit(selectButtonText: String?) {
    if let text = selectButtonText {
      let selectButton = ViewBuilder(title: text, style: .filled).makeButton()
      selectButton.setTitle(title, for: .normal)
      selectButton.onClick = { [weak self] in
        self?.completion?(.emit(callBack: nil))
      }
      selectButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
      bottomView = selectButton
    }
  }
}

// MARK: - render
private extension SelectViewController {
  func setViewsCustomisations() {
    self.view.backgroundColor = AppColors.backgroundMain.color
  }

  func initView(from: SelectViewModeConfiguration.SubviewType?, intoTop: Bool = false) -> UIView? {
    switch from {
      case .someView(let view): return view
      case .defaultForPlacement(let text, let setttings):
        if intoTop {
          if let setttings = setttings {
            return CustomLabel(settings: setttings)
          }
          let titleLabel = UILabel()
          titleLabel.backgroundColor = AppColors.backgroundMain.color
          titleLabel.textColor = AppColors.text.color
          titleLabel.textAlignment = .center
          titleLabel.text = text
          return titleLabel
        } else {

          let builder = setttings == nil
            ? ViewBuilder(title: text, style: .filled)
            : ViewBuilder(title: text, settings: setttings!)
          let selectButton = builder.makeButton()

          selectButton.onClick = { [weak self] in
           // self?.viewModel.configuration.emit?(self?.viewModel.configuration.datasource)
            self?.completion?(.emit(callBack: nil))
          }
          viewModel.configuration.horizontallMetrics[.bottomView] = "[v0(>=130,<=240)]"

          let footerView = UIView()
          footerView.addSubview(selectButton)
          footerView.addConstraintsWithFormat("H:[v0(>=130,<=240)]", options: .alignAllCenterX, views: selectButton)
          let btnSize = (viewModel.configuration.vertivalMetrics[.bottomView] ?? 60) - 20
          footerView.addConstraintsWithFormat("V:[v0(\(btnSize))]", options: .alignAllCenterY, views: selectButton)
          return footerView
        }
      case .emptySpace(let size):
        viewModel.configuration.horizontallMetrics[.bottomView] = "[v0(\(size))]"
        return UIView()
      default: return nil
    }
  }

  func setViews() {
    let config = viewModel.configuration
    listView = viewModel.configuration.collectionView
    bottomView = initView(from: config?.bottomView)
    topView = initView(from: config?.topView, intoTop: true)
    setViewConstraints()
  }

  func setViewConstraints() {
    typealias Metrics = SelectViewModeConfiguration.Metrics
    var views: [String: UIView] = [:]
    var stringFormat = ""
    let configuration: SelectViewModeConfiguration! = viewModel.configuration!
    let options : [(view: UIView?, name: String, constraint: String)] =
    [
      (topView, "topView", "-\(viewModel.configuration.topMargin)-[topView(\(configuration.vertivalMetrics[.topView] ?? 50))]"),
      (listView, "listView", "-[listView(>=\(configuration.vertivalMetrics[.listView] ?? 300)@900)]"),
      (bottomView, "bottomView", "-(>=0)-[bottomView(\(configuration.vertivalMetrics[.bottomView] ?? 60))]")
    ]

    options.forEach {
      if let subview = $0.view {
        stringFormat += $0.constraint
        view.addSubview(subview)
        var horizontalConstraint = "H:|[v0]|"
        if let metric = Metrics(rawValue: $0.name), let value = configuration.horizontallMetrics[metric] {
          horizontalConstraint = value
        }
        view.addConstraintsWithFormat(horizontalConstraint, options: .alignAllCenterY, views: subview)
        views[$0.name] = subview
      }
    }
    var metrics: [String: String] = [:]
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
      completion?(.cancel)
      self.dismiss(animated: true)
    }
  }
}
