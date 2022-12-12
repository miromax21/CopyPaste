import UIKit
class SlideView: UIView {

  @IBOutlet weak var lableTitle: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var labelDesc: UITextView!

  func configure(model: SliderModel) {
    imageView.image = model.image
    labelDesc.text = model.message
    lableTitle.text = model.title
    labelDesc.font = FontsEnum.base.getFont(size: 15.0)
    labelDesc.textColor = AppColors.black.color
  }
}
