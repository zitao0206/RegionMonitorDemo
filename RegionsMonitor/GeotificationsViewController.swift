//
//  GeotificationsViewController.swift
//  RegionsMonitor
//
//  Created by lizitao on 2023-09-13.
//

import UIKit
import CoreLocation
import MapKit

class GeotificationsViewController: UIViewController, MKMapViewDelegate, AddGeotificationsViewControllerDelegate, CLLocationManagerDelegate {
    var mapView: MKMapView!
    var geotifications = [Geotification]()
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化地图视图
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        let leftButton = UIBarButtonItem(title: "Left", style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.leftBarButtonItem = leftButton

        // 创建导航栏右侧按钮
        let rightButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        
        view.backgroundColor = UIColor.white
    }
    
    @objc func leftButtonTapped() {
        Utilities.zoomToUserLocation(in: mapView)
    }

    @objc func rightButtonTapped() {
//        // 创建AddGeotificationViewController
//         let addGeotificationViewController = AddGeotificationViewController()
//         addGeotificationViewController.delegate = self // 设置代理，以便在完成时接收回调
//
//         // 使用导航控制器包装AddGeotificationViewController，并进行模态呈现
//         let navigationController = UINavigationController(rootViewController: addGeotificationViewController)
//         present(navigationController, animated: true, completion: nil)
        
        let textInputAlertVC = TextInputAlertViewController()
        present(textInputAlertVC, animated: true, completion: nil)

    }
    
    func addGeotification(_ geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlayForGeotification(geotification)
        updateGeotificationsCount()
    }

    func removeGeotification(_ geotification: Geotification) {
        if let index = geotifications.firstIndex(where: { $0 === geotification }) {
            geotifications.remove(at: index)
            mapView.removeAnnotation(geotification)
            removeRadiusOverlayForGeotification(geotification)
            updateGeotificationsCount()
        }
    }

    func updateGeotificationsCount() {
        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = geotifications.count < 20
    }

    
    func addRadiusOverlayForGeotification(_ geotification: Geotification) {
        if mapView != nil {
            mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
        }
    }

    func removeRadiusOverlayForGeotification(_ geotification: Geotification) {
        if mapView != nil {
            let overlays = mapView.overlays
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    let coordinate = circleOverlay.coordinate
                    if coordinate.latitude == geotification.coordinate.latitude && coordinate.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                        mapView.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
    }

    
    func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: CGFloat, identifier: String, note: String, eventType: EventType) {
        controller.dismiss(animated: true, completion: nil)
        
        let clampedRadius = radius > locationManager.maximumRegionMonitoringDistance ? locationManager.maximumRegionMonitoringDistance : radius
        
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        addGeotification(geotification)
        startMonitoringGeotification(geotification)
   
    }
    
    func startMonitoringGeotification(_ geotification: Geotification) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            Utilities.showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            
            return
        }
        
        if locationManager.authorizationStatus != .authorizedAlways {
            Utilities.showSimpleAlertWithTitle("Warning", message: "Your geotification is saved but will only be activated once you grant GeofencesTest permission to access the device location.", viewController: self)
        }
        
        let region = regionWithGeotification(geotification)
        locationManager.startMonitoring(for: region)
    }

    func stopMonitoringGeotification(_ geotification: Geotification) {
        for circularRegion in locationManager.monitoredRegions {
            if let circularRegion = circularRegion as? CLCircularRegion, circularRegion.identifier == geotification.identifier {
                locationManager.stopMonitoring(for: circularRegion)
            }
        }
    }

    func regionWithGeotification(_ geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = geotification.eventType == .OnEntry
        region.notifyOnExit = !region.notifyOnEntry
        
        return region
    }
    
    //CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion {
            handleRegionEvent(circularRegion)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion {
            handleRegionEvent(circularRegion)
        }
    }

    func handleRegionEvent(_ region: CLCircularRegion) {
        // 处理进入或退出区域事件的代码
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let regionIdentifier = region?.identifier {
            print("Monitoring failed for region with identifier: \(regionIdentifier)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error.localizedDescription)")
    }




}


class TextInputAlertViewController: UIViewController {
    
    private let textField = UITextField()
    private let cancelButton = UIButton()
    private let submitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景颜色
        view.backgroundColor = .white
        
        // 添加文本输入框
        textField.placeholder = "在这里输入文本"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        // 添加取消按钮
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.blue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        // 添加提交按钮
        submitButton.setTitle("提交", for: .normal)
        submitButton.setTitleColor(.blue, for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        
        // 布局约束
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            submitButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitButtonTapped() {
        if let text = textField.text {
            // 处理用户输入的文本
            print("用户输入的文本是: \(text)")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
