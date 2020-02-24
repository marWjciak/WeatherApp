//
//  NetworkStatusController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 22/02/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import Network

class NetworkStatusController {
    static let shared = NetworkStatusController()

    var monitor: NWPathMonitor?
    var isMonitoring = false
    var isConnected: Bool {
        guard let monitor = self.monitor else { return false }

        return monitor.currentPath.status == .satisfied
    }

    var interfaceType: NWInterface.InterfaceType? {
        guard let monitor = self.monitor else { return nil }

        return monitor.currentPath.availableInterfaces.filter { (interface) -> Bool in
            monitor.currentPath.usesInterfaceType(interface.type) }.first?.type
    }

    var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = self.monitor else { return nil }

        return monitor.currentPath.availableInterfaces.map { (interface) -> NWInterface.InterfaceType in
            interface.type
        }
    }

    var isExpensive: Bool {
        return monitor?.currentPath.isExpensive ?? false
    }

    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var netStatusChangeHandler: (() -> Void)?

    private init() {

    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkStatusMonitor")
        monitor?.start(queue: queue)

        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }

        isMonitoring = true
        didStartMonitoringHandler?()
    }

    func stopMonitoring() {
        guard isMonitoring, let monitor = self.monitor else { return }

        monitor.cancel()

        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
}
