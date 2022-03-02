//
//  ViewController.swift
//  HealthKitApp
//
//  Created by Neil Francis Hipona on 3/1/22.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    let button : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Request Access", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        button.addTarget(self, action: #selector(requestAccess), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func requestAccess() {
        HealthKitManager.shared
            .requestAuthorization(toShare: HealthKitManager.stepSamples, read: HealthKitManager.stepSamples)
    }

    func createStepCountSample() {
        // create save entry
        let stepsCount = Double.random(in: 100..<9999)
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let quantity = HKQuantity(unit: .count(), doubleValue: stepsCount)
        let today = Date()
        let stepSample = HKQuantitySample(type: type,
                                          quantity: quantity,
                                          start: today,
                                          end: today)
        HealthKitManager.shared.saveSample(sample: stepSample)
    }

    func createSimpleQuery() {
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let query = HKSampleQuery(sampleType: type,
                                  predicate: nil,
                                  limit: 7,
                                  sortDescriptors: sort) { query, samples, error in
            if let samples = samples {
                print("Samples: \(samples)")
            } else {
                print("Error: \(error)")
            }
        }
        HealthKitManager.shared.store.execute(query)
    }

    func createCollectionQuery() {
        // create a cumulative sample collectivequery
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let today = Date()
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let predicate = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: today, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: oneWeekAgo,
                                                intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { query, collection, error in
            if let collection = collection {
                print("Result: \(collection)")
            } else {
                print("Error: \(error)")
            }
        }

        // called when update event happened in db
        query.statisticsUpdateHandler = { query, stats, collection, error in
            if let collection = collection {
                print("Result: \(collection)")
            } else {
                print("Error: \(error)")
            }
        }

        HealthKitManager.shared.execute(query: query)

        // call to stop observers in query
        //HealthKitManager.shared.stop(query:query)
    }
}

