//
//  spotAnnotationView.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import Foundation
import MapKit

protocol SpotAnnotationViewDelegate: AnyObject {
    func SpoAnnotationViewDelegateDidTapButton(_ spotAnnotationView: SpotAnnotationView)
}

class SpotAnnotationView: MKMarkerAnnotationView {
    
    static let identifier = "SpotAnnotationView"
    
    weak var delegate: SpotAnnotationViewDelegate?
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let _myAnnotation = newValue as? spotAnnotation else {return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let mapButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapButton.addTarget(self, action: #selector(didTapMapButton), for: .touchUpInside)
            mapButton.setBackgroundImage(UIImage(systemName: ""), for: .normal)
            mapButton.isUserInteractionEnabled = true
            rightCalloutAccessoryView = mapButton
            markerTintColor = _myAnnotation.markerTintColor
            if let imageName = _myAnnotation.imageName {
                glyphImage = UIImage(systemName: imageName)
            } else {
                glyphImage = UIImage(systemName: "questionmark.circle.fill")
            }
        }
    }
    
    @objc func didTapMapButton() {
        delegate?.SpoAnnotationViewDelegateDidTapButton(self)
    
    }
}
