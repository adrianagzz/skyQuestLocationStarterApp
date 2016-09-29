//
//  SettingsVC.swift
//  locationTest
//
//  Created by Adriana González on 9/5/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit
import MapKit

protocol UpdateDelegate: class {
    func updateRangerLocation(_ location: CLLocationCoordinate2D)
    func updateBalloonLocation(_ location: CLLocationCoordinate2D)
}

class SettingsVC: UIViewController {

    @IBOutlet weak var txtRangerCoord: UITextField!
    @IBOutlet weak var txtBalloonCoord: UITextField!
    @IBOutlet weak var rangerStackView: UIStackView!
    
    weak var delegate:UpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if Singleton.sharedInstance.asRanger == true {
            rangerStackView.isHidden = true
            txtRangerCoord.isHidden = true
        }else{
            rangerStackView.isHidden = false
            txtRangerCoord.isHidden = false
        }
        
    }

    @IBAction func rangerUpdateCoordPressed(_ sender: AnyObject) {
        
        if let text = txtRangerCoord.text{
            let coordinatesAray = text.characters.split{$0 == "/"}.map(String.init)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(coordinatesAray[0])!, longitude: Double(coordinatesAray[1])!)
            self.delegate?.updateRangerLocation(location)
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func balloonUpdateCoordPressed(_ sender: AnyObject) {
        
        if let text = txtBalloonCoord.text{
            let coordinatesAray = text.characters.split{$0 == "/"}.map(String.init)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(coordinatesAray[0])!, longitude: Double(coordinatesAray[1])!)
            self.delegate?.updateBalloonLocation(location)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
}
