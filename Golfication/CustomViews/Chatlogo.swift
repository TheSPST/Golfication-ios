
import UIKit
class ChatLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.white
        self.font = UIFont.glfTextStyle5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerRadius: 48)
        rectanglePath.fill()
        
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 120, y: 90.5))
        starPath.addLine(to: CGPoint(x: 131.24, y: 106.33))
        starPath.addLine(to: CGPoint(x: 146.5, y: 118))
        starPath.addLine(to: CGPoint(x: 131.24, y: 129.67))
        starPath.addLine(to: CGPoint(x: 120, y: 145.5))
        starPath.addLine(to: CGPoint(x: 108.76, y: 129.67))
        starPath.addLine(to: CGPoint(x: 93.5, y: 118))
        starPath.addLine(to: CGPoint(x: 108.76, y: 106.33))
        starPath.close()
        Chatlogo.color.setFill()
        starPath.fill()


        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = rectanglePath.cgPath
        shapeLayer.fillColor =  UIColor.glfFlatBlue.cgColor
        
        
        
        self.layer.addSublayer(shapeLayer)
    }
    
}
public class Chatlogo : NSObject {

    //// Cache

    private struct Cache {
        static let color: UIColor = UIColor(red: 0.228, green: 0.488, blue: 0.645, alpha: 1.000)
    }

    //// Colors

    @objc dynamic public class var color: UIColor { return Cache.color }

    //// Drawing Methods

    @objc dynamic public class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 145), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 145), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 145)


        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: -0, width: 240, height: 118), cornerRadius: 48)
        Chatlogo.color.setFill()
        rectanglePath.fill()


        //// Star Drawing
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 77, y: 90))
        starPath.addLine(to: CGPoint(x: 88.24, y: 105.83))
        starPath.addLine(to: CGPoint(x: 103.5, y: 117.5))
        starPath.addLine(to: CGPoint(x: 88.24, y: 129.17))
        starPath.addLine(to: CGPoint(x: 77, y: 145))
        starPath.addLine(to: CGPoint(x: 65.76, y: 129.17))
        starPath.addLine(to: CGPoint(x: 50.5, y: 117.5))
        starPath.addLine(to: CGPoint(x: 65.76, y: 105.83))
        starPath.close()
        Chatlogo.color.setFill()
        starPath.fill()
        
        context.restoreGState()

    }




    @objc(ChatlogoResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
