import UIKit

class CustomTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let customTabBar = CustomTabBar()
        setValue(customTabBar, forKey: "tabBar")
        
        let tabBarInset: CGFloat = 120.0
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: tabBarInset, y: self.tabBar.bounds.minY, width: self.tabBar.bounds.width - tabBarInset * 2, height: self.tabBar.bounds.height), cornerRadius: (self.tabBar.frame.width/2)).cgPath
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10.0)
        layer.shadowRadius = 25.0
        layer.shadowOpacity = 1.0
        layer.borderWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor.white.cgColor
        
        self.tabBar.layer.insertSublayer(layer, at: 0)
        tabBar.tintColor = .customPurple
        tabBar.unselectedItemTintColor = .customGray
        tabBar.backgroundColor = .clear
        
        if let items = self.tabBar.items { items.forEach { item in item.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)} }
        
        self.tabBar.itemPositioning = .centered
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.isTranslucent = true
    }
}

class CustomTabBar: UITabBar
{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let hitView = super.hitTest(point, with: event)
        
        if let tabBarButton = hitView as? UIControl
        {
            tabBarButton.addTarget(self, action: #selector(tabBarButtonTouchDown(_:)), for: .touchDown)
            tabBarButton.addTarget(self, action: #selector(tabBarButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        return hitView
    }
    
    @objc private func tabBarButtonTouchDown(_ sender: UIControl)
    {
        UIView.animate(withDuration: 0.1, animations:
        {
            sender.alpha = 0.5
            
        }) { _ in
            sender.setNeedsLayout()
            sender.layoutIfNeeded()
        }
    }
    
    @objc private func tabBarButtonTouchUp(_ sender: UIControl)
    {
        UIView.animate(withDuration: 0.2, animations:
        {
            sender.alpha = 1.0
            
        }) { _ in
            sender.setNeedsLayout()
            sender.layoutIfNeeded()
        }
    }
}
