//
//  ColorPickerView.swift
//  TestColorPicker
//
//  Created by Sarath Vijay on 20/10/16.
//  Copyright © 2016 jango. All rights reserved.
//

import UIKit

fileprivate enum ColorPickerViewConstant {
    static let colorPickerSliderHeightMin: CGFloat = 2.0
    static let uiSliderHeightDefault: CGFloat = 31.0
}

public typealias ColorChangeBlock = (_ color: UIColor?, _ value: CGFloat) -> Void

open class ColorPickerView: UIView {
    
    //MARK:- Open constant
    //MARK:-
    /**
     User can use this value to change the slider height.
     */
    open var colorPickerSliderHeight: CGFloat = 2.0 //Min value
    
    //MARK:- Private variables
    //MARK:-
    fileprivate var currentHueValue : CGFloat = 0.0
    fileprivate var currentSliderColor = UIColor.red
    fileprivate var currentSliderValue : CGFloat = 0.0
    fileprivate var hueImage: UIImage!
    fileprivate var slider: UISlider!
    
    fileprivate var splitCoefBW: CGFloat = 0.3
    
    //MARK:- Open variables
    //MARK:-
    open var didChangeColor: ColorChangeBlock?
    
    //MARK:- Override Functions
    //MARK:-
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        backgroundColor = UIColor.clear
        update()
    }
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        if slider == nil {
            let sliderRect = CGRect(x: rect.origin.x, y:  (rect.size.height - ColorPickerViewConstant.uiSliderHeightDefault) * 0.5,
                                    width: rect.width, height: ColorPickerViewConstant.uiSliderHeightDefault)
            slider = UISlider(frame: sliderRect)
            slider.setValue(0, animated: false)
            slider.addTarget(self, action: #selector(onSliderValueChange), for: UIControlEvents.valueChanged)
            slider.minimumTrackTintColor = UIColor.clear
            slider.maximumTrackTintColor = UIColor.clear
            
            addSubview(slider)
            
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.leadingAnchor.constraint(equalTo: slider.superview!.leadingAnchor, constant: 0).isActive = true
            slider.topAnchor.constraint(equalTo: slider.superview!.topAnchor, constant: 0).isActive = true
            slider.trailingAnchor.constraint(equalTo: slider.superview!.trailingAnchor, constant: 0).isActive = true
            slider.bottomAnchor.constraint(equalTo: slider.superview!.bottomAnchor, constant: 0).isActive = true
            
            
        }
        
        let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerViewConstant.colorPickerSliderHeightMin)
        let sliderImageRect = CGRect(x: rect.origin.x, y: (rect.size.height - heigthForSliderImage) * 0.5,
                                     width: rect.width, height: heigthForSliderImage)
        if hueImage != nil {
            hueImage.draw(in: sliderImageRect)
        }
        
    }
    
    
    public func resetSliderValue(){
        slider.value = 0.0;
    }
    
    public func setSliderValue(newValue: Float, animated: Bool){
        
        if animated == true{
            UIView.animate(withDuration: 0.25) {
                self.slider.setValue(newValue, animated: true)
            }
        }else{
            slider.value = newValue;
        }
        
    }
    
    //MARK:- Internal Functions
    //MARK:-
    func onSliderValueChange(slider: UISlider) {
        
        currentSliderValue = CGFloat(slider.value)
        
        if  CGFloat(slider.value) <= 1.0 * splitCoefBW {
             currentHueValue = 1.0 - CGFloat(slider.value) * (1.0 / splitCoefBW)
             currentSliderColor = UIColor(hue: 0.0, saturation: 0.0, brightness: (currentHueValue), alpha: 1)
         }else{
             currentHueValue = ((CGFloat(slider.value) - 1.0 * splitCoefBW) * (1 / (1.0-splitCoefBW)) / 1.0)
             currentSliderColor = UIColor(hue: (currentHueValue), saturation: 1.0, brightness: 1.0, alpha: 1)
         }
        
        self.didChangeColor?(currentSliderColor, currentSliderValue)
    }
}

fileprivate extension ColorPickerView {
    
    func update() {
        
        if hueImage == nil {
            let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerViewConstant.colorPickerSliderHeightMin)
            let size: CGSize = CGSize(width: frame.width, height: heigthForSliderImage)
            hueImage = generateHUEImage(size)
        }
    }
    
    func generateHUEImage(_ size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerViewConstant.colorPickerSliderHeightMin)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: heigthForSliderImage * 0.5).addClip()
        for x: Int in 0 ..< Int(size.width) {

            if(x <= Int(size.width * splitCoefBW)){
                UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0 - (CGFloat(CGFloat(x) / (size.width * splitCoefBW))), alpha: 1.0).set()
            }else{
                UIColor(hue: ((CGFloat(x)-size.width * splitCoefBW) * (1 / (1.0-splitCoefBW)) / size.width), saturation: 1.0, brightness: 1.0, alpha: 1.0).set()
            }
 
            let temp = CGRect(x: CGFloat(x), y: 0, width: 1, height: size.height)
            UIRectFill(temp)
        }
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
