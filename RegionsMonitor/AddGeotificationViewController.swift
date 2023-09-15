//
//  AddGeotificationViewController.swift
//  RegionsMonitor
//
//  Created by lizitao on 2023-09-13.
//

import Foundation
import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate: AnyObject {
    func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: CGFloat, identifier: String, note: String, eventType: EventType)
}

class AddGeotificationViewController: UITableViewController {

    weak var delegate: AddGeotificationsViewControllerDelegate?
    
    private var addButton: UIBarButtonItem!
    private var zoomButton: UIBarButtonItem!
    private var eventTypeSegmentedControl: UISegmentedControl!
    private var radiusTextField: UITextField!
    private var noteTextField: UITextField!
    private var mapView: MKMapView!
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Geotification"
        
        addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(onAdd(_:)))
        addButton.isEnabled = false
        
        zoomButton = UIBarButtonItem(title: "Zoom", style: .plain, target: self, action: #selector(onZoomToCurrentLocation(_:)))
        
        eventTypeSegmentedControl = UISegmentedControl(items: ["On Entry", "On Exit"])
        eventTypeSegmentedControl.selectedSegmentIndex = 0
        
        radiusTextField = UITextField()
        radiusTextField.placeholder = "Radius (meters)"
        radiusTextField.keyboardType = .numberPad
        radiusTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        
        noteTextField = UITextField()
        noteTextField.placeholder = "Note"
        noteTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        
        mapView = MKMapView()
        
        tableView.tableFooterView = UIView()
        
        let cancelButton = UIBarButtonItem(title: "Left", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton

        // 创建导航栏右侧按钮
        let addButton = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
    }
    
    @objc func cancelButtonTapped() {
        // 左侧按钮点击事件处理
    }

    @objc func addButtonTapped() {
       
    }

    // 在这里配置UI元素的布局和约束
    // ...

    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        addButton.isEnabled = !(radiusTextField.text?.isEmpty ?? true) && !(noteTextField.text?.isEmpty ?? true)
    }

    @objc private func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func onAdd(_ sender: Any) {
        let coordinate = mapView.centerCoordinate
        if let radiusText = radiusTextField.text, let radius = Double(radiusText),
           let note = noteTextField.text {
            let identifier = UUID().uuidString
            let eventType = eventTypeSegmentedControl.selectedSegmentIndex == 0 ? EventType.OnEntry : EventType.OnExit
            delegate?.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
        }
    }

    @objc private func onZoomToCurrentLocation(_ sender: Any) {
        // 在这里实现地图缩放到当前位置的逻辑
    }
}




