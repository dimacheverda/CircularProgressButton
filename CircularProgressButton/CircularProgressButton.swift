//
//  CircularProgressButton.swift
//  CircularProgressButton
//
//  Created by Dima Cheverda on 2/21/15.
//  Copyright (c) 2015 Dima Cheverda. All rights reserved.
//

import UIKit

enum ButtonState: String {
  case Original = "Original"
  case Animating = "Animating"
  case Small = "Small"
}

class CircularProgressButton: UIButton {
  
  // MARK: - Public Properties
  
  var progress: CGFloat = 0.0 {
    didSet {
      if progress < 0.0 {
        progress = 0.0
      } else if progress >= 1.0 {
        progress = 1.0
      }
      
      circularProgressLayer.strokeEnd = progress
      
      if Int(progress) == Int(1) {
        buttonState = .Animating
        self.makeOriginalWithDelay(0.2)
      }
    }
  }
  
  
  // MARK: - Private Properties
  
  private var animationDuration: CFTimeInterval = 0.2
  var buttonState: ButtonState = .Original
  private var borderWidth: CGFloat = 5.0
  
  var originalCornerRadius: CGFloat = 0
  var originalBounds: CGRect = CGRectZero
  var originalColor: CGColorRef = UIColor(red:0.14, green:0.6, blue:0.79, alpha:1).CGColor
  var originalBorderColor: CGColorRef = UIColor(red:0.14, green:0.6, blue:0.79, alpha:1).CGColor
  
  var smallCornerRadius: CGFloat = 0
  var smallBounds: CGRect = CGRectZero
  var smallColor: CGColorRef = UIColor.whiteColor().CGColor
  var smallBorderColor: CGColorRef = UIColor(white: 0.9, alpha: 1).CGColor
  
  var pressedColor: CGColorRef = UIColor(red:0.14, green:0.6, blue:0.49, alpha:1).CGColor
  
  var circularProgressLayer: CAShapeLayer
  var foregroundLayer: CALayer
  
  
  // MARK: - Initializers
  
  init(frame: CGRect, cornerRadius: CGFloat) {
    
    foregroundLayer = CALayer()
    circularProgressLayer = CAShapeLayer()
    
    super.init(frame: frame)
    
    prepare()
  }
  
  required init(coder aDecoder: NSCoder) {
    
    foregroundLayer = CALayer()
    circularProgressLayer = CAShapeLayer()
    
    super.init(coder: aDecoder)
    
    prepare()
  }

  private func prepare() {
    prepareParameters()
    prepareForegroundLayer()
    prepareCircularLayer()
    
    layer.masksToBounds = true
  }
  
  private func prepareParameters() {
    originalBounds = layer.bounds
    
    smallBounds = layer.bounds
    smallBounds.size.width = smallBounds.height
    smallCornerRadius = smallBounds.height/2
  }
  
  func prepareForegroundLayer() {
    foregroundLayer.frame = layer.frame
    foregroundLayer.masksToBounds = true
    foregroundLayer.cornerRadius = originalCornerRadius
    foregroundLayer.backgroundColor = originalColor
//    foregroundLayer.bounds = originalBounds
    foregroundLayer.borderWidth = borderWidth
    foregroundLayer.borderColor = originalBorderColor
    
    layer.addSublayer(foregroundLayer)
  }
  
  func prepareCircularLayer() {
    circularProgressLayer.frame = CGRectMake(0, 0, layer.bounds.height, layer.bounds.height)
    circularProgressLayer.position = layer.position
    circularProgressLayer.hidden = false
    circularProgressLayer.backgroundColor = UIColor.clearColor().CGColor
    circularProgressLayer.path = circlePath().CGPath
    circularProgressLayer.strokeStart = 0
    circularProgressLayer.strokeEnd = 0
    circularProgressLayer.lineWidth = borderWidth
    circularProgressLayer.fillColor = UIColor.clearColor().CGColor
    circularProgressLayer.strokeColor = originalBorderColor
    
    layer.addSublayer(circularProgressLayer)
  }
  
  func resetProgressLayer() {
    progress = 0
    circularProgressLayer.strokeEnd = 0
  }
  
  
  // MARK: - Helpers
  
  private func circlePath() -> UIBezierPath {
    let radius = CGRectGetHeight(circularProgressLayer.bounds)/2 - borderWidth/2
    let arcCenterXY = radius + borderWidth/2
    let arcCenter = CGPoint(x: arcCenterXY, y: arcCenterXY)
    let startAngle = CGFloat(-M_PI_2)
    let endAngle = startAngle + CGFloat(M_PI*2)
    let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    return path
  }
  
  func makeSmallWithDelay(delay: CFTimeInterval) {
    changeTo(.Small, targetLayer: foregroundLayer, delay: delay)
  }
  
  func makeOriginalWithDelay(delay: CFTimeInterval) {
    changeTo(.Original, targetLayer: foregroundLayer, delay: delay)
  }
  
  private func changeTo(state: ButtonState, targetLayer: CALayer, delay: CFTimeInterval) {
    
    let group = CAAnimationGroup()
    group.duration = animationDuration
    group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    group.beginTime = CACurrentMediaTime() + delay
    group.fillMode = kCAFillModeForwards
    group.removedOnCompletion = false
    group.delegate = self
    
    let name = (state == .Small) ? "makeSmall" : "makeOriginal"
    group.setValue(name, forKey: "name")
    group.setValue(targetLayer, forKey: "layer")
    
    // bounds
    let sizeAnimation = CABasicAnimation(keyPath: "bounds")
    let toBounds = (state == .Original) ? originalBounds : smallBounds
    sizeAnimation.toValue = NSValue(CGRect: toBounds)
    
    // cornerRadius
    let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
    let toCornerRadius = (state == .Original) ? originalCornerRadius : smallCornerRadius
    cornerRadiusAnimation.toValue = toCornerRadius
    
    // backgroundColor
    let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
    let toColor = (state == .Original) ? originalColor : smallColor
    backgroundColorAnimation.toValue = toColor
    
    // borderColor
    let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
    let toBorderColor = (state == .Original) ? originalBorderColor : smallBorderColor
    borderColorAnimation.toValue = toBorderColor
    
    group.animations = [sizeAnimation, cornerRadiusAnimation, backgroundColorAnimation, borderColorAnimation]
    
    targetLayer.addAnimation(group, forKey: "anim")
  }
  
  func changeButtonColorTo(color: CGColorRef) {
    foregroundLayer.backgroundColor = color
    foregroundLayer.borderColor = color
  }
  
  
  // MARK: - Touch Tracking
  
  override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
    super.beginTrackingWithTouch(touch, withEvent: event)
    
    println("begin")
    
    if event.type == UIEventType.Touches {
      println("beginChange")
      changeButtonColorTo(pressedColor)
    }
    return true
  }
  
  override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
    super.continueTrackingWithTouch(touch, withEvent: event)
    
    println("continue")
    
    var touchEnd = touch.locationInView(self)
    if !CGRectContainsPoint(bounds, touchEnd) {
      changeButtonColorTo(originalColor)
      println("continueOutOfBounds")
      
      return false
    }
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    super.endTrackingWithTouch(touch, withEvent: event)
    
    if event.type == UIEventType.Touches {
      
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      println("endTracking")
      changeButtonColorTo(originalColor)
      CATransaction.commit()
      
      var touchEnd = touch.locationInView(self)
      if CGRectContainsPoint(bounds, touchEnd) {
        if buttonState == .Original {
          makeSmallWithDelay(0)
        }
      }
    }
    println()
  }
  
  
  // MARK: - Animation Delegate
  
  override func animationDidStart(anim: CAAnimation!) {
    
    self.buttonState = .Animating
    
    let nameValue = anim.valueForKey("name") as? String
    if let name = nameValue {
      if name == "makeSmall" {
      }
      if name == "makeOriginal" {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circularProgressLayer.hidden = true
        CATransaction.commit()
      }
    }
  }
  
  override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
    
   let nameValue = anim.valueForKey("name") as? String
    if let name = nameValue {
      if name == "makeSmall" {
        
        if flag == true {
          let targetLayer: CALayer = anim.valueForKey("layer")! as CALayer
          
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          targetLayer.backgroundColor = smallColor
          targetLayer.bounds = smallBounds
          targetLayer.cornerRadius = smallCornerRadius
          targetLayer.borderColor = smallBorderColor
          circularProgressLayer.hidden = false
          
          resetProgressLayer()
          CATransaction.commit()
          
          buttonState = .Small
        }
      }
      if name == "makeOriginal" {
        if flag == true {
          let targetLayer: CALayer = anim.valueForKey("layer")! as CALayer
          
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          targetLayer.backgroundColor = originalColor
          targetLayer.bounds = originalBounds
          targetLayer.cornerRadius = originalCornerRadius
          targetLayer.borderColor = originalBorderColor
          CATransaction.commit()
          
          buttonState = .Original
        }
      }
    }
  }
  
}
