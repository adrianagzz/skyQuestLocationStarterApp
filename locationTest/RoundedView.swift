//
//  RoundedView.swift
//  locationTest
//
//  Created by Adriana González on 9/6/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet{
            setupView()
        }
    }
    
    @IBInspectable var backColor: UIColor = UIColor.lightGray{
        didSet{
            self.backgroundColor = backColor
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = cornerRadius
        
        
    }


}
