import UIKit
import RangeSeekSlider

class RangeValuesTableViewCell : UITableViewCell , RangeSeekSliderDelegate{
    
    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtMinPrice: UITextField!

    @IBOutlet weak var txtMaxPrice: UITextField!
    
    
    
    //MARK:- Properties
    var minimumValue = ""
    var maximumValue = ""
    var fieldName = ""
    let bgColor = UserDefaults.standard.string(forKey: "mainColor")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rangeSlider.delegate = self
        rangeSlider.disableRange = false
        rangeSlider.enableStep = true
        rangeSlider.step = 5
        if let bgColor = UserDefaults.standard.string(forKey: "mainColor") {
            rangeSlider.tintColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.minLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.maxLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.handleColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.handleBorderColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.colorBetweenHandles = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.initialColor = Constants.hexStringToUIColor(hex: bgColor)
        }
       
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: 30.0, width: txtMinPrice.frame.size.width + 18, height: 0.5)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        txtMinPrice.layer.addSublayer(bottomBorder)
        
        let bottomBorder2 = CALayer()
        bottomBorder2.frame = CGRect(x: 0.0, y: 30.0, width: txtMaxPrice.frame.size.width + 18, height: 0.5)
        bottomBorder2.backgroundColor = UIColor.lightGray.cgColor
        txtMaxPrice.layer.addSublayer(bottomBorder2)
        

    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === rangeSlider {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
            let mxValue = maxValue
            self.maximumValue = "\(mxValue)"
            
            if let index = self.maximumValue.range(of: ".")?.lowerBound {
                let substring = self.maximumValue[..<index]
                let string = String(substring)
                print(string)
                self.maximumValue = string
            }
    
            let minValue = minValue
            self.minimumValue = "\(minValue)"
            if let index = self.minimumValue.range(of: ".")?.lowerBound {
                let substring = self.minimumValue[..<index]
                let string = String(substring)
                print(string)
                self.minimumValue = string
            }
            txtMinPrice.text = "\(minimumValue)"
            txtMaxPrice.text = "\(maximumValue)"
            
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
