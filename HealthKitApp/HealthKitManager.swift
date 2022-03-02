//
//  HealthKitManager.swift
//  HealthKitApp
//
//  Created by Neil Francis Hipona on 3/2/22.
//

import Foundation
import HealthKit

class HealthKitManager {

    static let shared = HealthKitManager()
    private(set) lazy var store = { HKHealthStore() }()

    var hasHealthKitSupport: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    static let stepSamples: Set<HKSampleType> = {
        Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])
    }()

    func requestAuthorization(toShare: Set<HKSampleType>, read: Set<HKSampleType>) {
        guard hasHealthKitSupport else { return }
        store.requestAuthorization(toShare: toShare, read: read) { success, error in
            print("Status: \(success) -- error: \(error)")
        }
    }

    func saveSample(sample: HKSample) {
        guard hasHealthKitSupport else { return }
        store.save(sample) { success, error in
            print("Status: \(success) -- error: \(error)")
        }
    }

    func execute(query: HKQuery) {
        guard hasHealthKitSupport else { return }
        store.execute(query)
    }

    func stop(query: HKQuery) {
        store.stop(query)
    }
}
