//
//  AppDelegate.swift
//  HeraldTest
//
//  Created by Andres Colubri on 8/25/21.
//

import UIKit
import Herald

//@Edison: Same as in Android, I'm following the pattern in the demo Herald app for iOS,
// where all callbacks are defined in the main app, but I think it would make more sense
// to add them to the service class...
@main
class AppDelegate: UIResponder, UIApplicationDelegate, SensorDelegate {

    var payloadDataSupplier: PayloadDataSupplier?
    var sensor: SensorArray?
    
    var peerStatus: [String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // @Edison: I'm following the herald-for-ios example code, where they have all init
        // in a startPhone() function, but that funciton is not called from anywhere. So
        // I'm explicitly calling it here, not sure if this is correct.
        startPhone()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    func startPhone() {
        payloadDataSupplier = ConcreteTestPayloadDataSupplier(identifier: 0)
        sensor = SensorArray(payloadDataSupplier!)
        sensor?.add(delegate: self)
        sensor?.start()
    }
    
    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        print(sensor.rawValue + ",didDetect=" + didDetect.description)
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        print(sensor.rawValue + ",didRead=" + didRead.shortName + ",fromTarget=" + fromTarget.description)
        parsePayload("didRead", sensor, didRead, fromTarget)
    }
    
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {
        print(sensor.rawValue + ",didReceive=" + didReceive.base64EncodedString() + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        let payloads = didShare.map { $0.shortName }
        print(sensor.rawValue + ",didShare=" + payloads.description + ",fromTarget=" + fromTarget.description)
        for payload in didShare {
            parsePayload("didRead", sensor, payload, fromTarget)
        }
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        print(sensor.rawValue + ",didMeasure=" + didMeasure.description + ",fromTarget=" + fromTarget.description)
        
        let prox = didMeasure.value
        
        // @Edison: proximity info but no payload?
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location?) {
        print(sensor.rawValue + ",didVisit=" + String(describing: didVisit))
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier, withPayload: PayloadData) {
        print(sensor.rawValue + ",didMeasure=" + didMeasure.description + ",fromTarget=" + fromTarget.description + ",withPayload=" + withPayload.shortName)
        
        let prox = didMeasure.value
        
        parsePayload("didMeasure", sensor, withPayload, fromTarget)
    }
    
    func sensor(_ sensor: SensorType, didUpdateState: SensorState) {
        print(sensor.rawValue + ",didUpdateState=" + didUpdateState.rawValue)
    }
    
    func parsePayload(_ source: String, _ sensor: SensorType, _ payloadData: PayloadData, _ fromTarget: TargetIdentifier) {
        // @Edison: not really complete... just some ideas of what should be done here...
        let info = payloadData.base64EncodedString()
        
        peerStatus.append(info)
        
        EventHelper.triggerPeerDetect()
    }
}
