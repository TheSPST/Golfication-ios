 
 import UIKit
 
 public enum AnimationType{
    case clockwise
    case anticlockwise
 }
 
 public class Settings {
    static var _backGround = UIColor.black.withAlphaComponent(0.3)
    static var _spinnerBackGround = UIColor.black.withAlphaComponent(0.5)
    static var _font = UIFont(name: "SFProDisplay-Medium", size: 30)
    static var _textColor = UIColor.white
    static var _message = "Loading..."
    static var _sectorColor:CGColor = UIColor.white.cgColor
    static var _numberofSectors:Int = 8
    static var _spacing:Double = 0.2
    static var _lineWidth:CGFloat = 8
    static var _duration:CFTimeInterval = 1
    static var _cornerradius:CGFloat = 10
    static var _animationType:AnimationType = .clockwise
 }
 
 public class SDLoader{
    public var backGroundColor:UIColor?
    public var spinner : Spinner?
    private var baseView: UIView?
    public var isAnimating : Bool?{
        get{
            return self._isAnimating
        }
    }
    
    private var _isAnimating : Bool = false
    
    public init() {
        self.baseView = UIView()
        self.spinner = Spinner()
    }
    
    public  func show(atView view :UIView, navItem: UINavigationItem){
        navItem.rightBarButtonItem?.isEnabled = false

        let frame = view.frame
        baseView?.frame = frame
        let viewcenter = view.center
        baseView?.center = viewcenter
        baseView?.backgroundColor = self.backGroundColor ?? Settings._backGround
        
        //spinner
        let spinnerFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner?.frame = spinnerFrame
        spinner?.center = viewcenter
 
        baseView?.addSubview(spinner!)
        spinner?.startAnimation()
        view.addSubview(baseView!)
        _isAnimating = true
    }
    
    public  func hide(navItem: UINavigationItem){
        navItem.rightBarButtonItem?.isEnabled = true

        if let spinner = spinner{
            spinner.stopanimation()
        }
        if let baseview = baseView{
            baseview.removeFromSuperview()
        }
        _isAnimating = false
    }
    public  func show(){
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let frame = window.frame
                self.baseView?.frame = frame
                
                let viewcenter = window.center
                self.baseView?.center = viewcenter
                self.baseView?.backgroundColor = self.backGroundColor ?? Settings._backGround
                
                //spinner
                let spinnerFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                self.spinner?.frame = spinnerFrame
                self.spinner?.center = viewcenter
                
                self.baseView?.addSubview(self.spinner!)
                self.spinner?.startAnimation()
                window.addSubview(self.baseView!)
                self._isAnimating = true
            }
        }


    }
    public  func hide(){
        if let spinner = spinner{
            spinner.stopanimation()
        }
        if let baseview = baseView{
            baseview.removeFromSuperview()
        }
        _isAnimating = false
    }
    
 }
 
