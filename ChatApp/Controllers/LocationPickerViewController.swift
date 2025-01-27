//
//  LocationPickerViewController.swift
//  ChatApp
//
//  Created by Umman on 09.07.24.
//

import UIKit
import MapKit
import CoreLocation

final class LocationPickerViewController: UIViewController
{
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true
    
    private let map: MKMapView =
    {
        let map = MKMapView()
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?)
    {
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if isPickable
        {
            let sendButton = UIButton(type: .system)
            sendButton.setTitle("Send", for: .normal)
            sendButton.setTitleColor(.black, for: .normal)
            sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
            let sendBarButtonItem = UIBarButtonItem(customView: sendButton)
            navigationItem.rightBarButtonItem = sendBarButtonItem
            navigationItem.rightBarButtonItem?.tintColor = .black
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_ :)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        }
        else
        {
            // Just showing location
            guard let coordinates = self.coordinates else { return }
        
            // Drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        view.addSubview(map)
    }
    
    override func viewWillDisappear(_ animated: Bool) 
    {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func sendButtonTapped()
    {
        guard let coordinates = coordinates else { return }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer)
    {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        for annotation in map.annotations { map.removeAnnotation(annotation) }
    
        // Drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
}
