/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import Foundation
import OptimizelySDKiOS

private let projectId               = "123456"
private let noopEventDispatcher     = "NoopEventDispatcher"
private let proxyEventDispatcher    = "ProxyEventDispatcher"
private let normalService           = "NormalService"
private let keyExperiment           = "experiment_key"
private let keyUserId               = "user_id"
private let keyAttributes           = "attributes"
private let keyVariation            = "variation_key"
private let keyEvent                = "event_key"
private let keyEventTags            = "event_tags"

class OptimizelyWorker {
    
    static let shared = OptimizelyWorker()
    
    private init() { }
    
    private lazy var datafile: Data? = {
        return FileWorker.shared.getDataFrom(file: TestWorker.shared.dataFileName())
    }()
    
    // ---- Create the Event Dispatcher ----
    private lazy var eventDispatcher: OPTLYEventDispatcher? = {
        switch TestWorker.shared.eventDispatcher() {
        case noopEventDispatcher:
            return OPTLYEventDispatcherNoOp()
        case proxyEventDispatcher:
            return OPTLYEventDispatcherProxy(withLogger: nil)
        default:
            return nil
        }
    }()
    
    // ---- Create the User Profile Service ----
    private lazy var userProfileService: OPTLYUserProfileService? = {
        switch TestWorker.shared.userProfileService() {
        case normalService:
            let userProfileService = OPTLYUserProfileServiceDefault()
            if let profiles = TestWorker.shared.userProfiles() {
                for profile in profiles {
                    userProfileService.save(profile)
                }
            }
            return userProfileService
        default:
            return nil
        }
    }()
    
    
    // ---- Create the Manager ----
    private lazy var optimizelyManager: OPTLYManager? = {
        let optimizelyManager: OPTLYManager? = OPTLYManager.init {(builder) in
            builder!.datafile = self.datafile
            builder!.projectId = projectId
            builder!.eventDispatcher = self.eventDispatcher
            builder!.userProfileService = self.userProfileService
        }
        return optimizelyManager
    }()
    
    public lazy var optimizelyClient: OPTLYClient? = {
        let optimizelyClient : OPTLYClient? = self.optimizelyManager?.initialize()
        return optimizelyClient
    }()
    
    func setForcedVariations() -> Void {
        guard let forceVariationMaps = TestWorker.shared.forceVariations() else { return }
        for forceVariationMap in forceVariationMaps {
            guard let experimentKeys = forceVariationMap.experiment_bucket_map?.keys else { continue }
            for experimentKey in experimentKeys {
                guard
                    let variationMap = forceVariationMap.experiment_bucket_map?[experimentKey] as? [String : String],
                    let variationKey = variationMap["variation_id"],
                    let userId = forceVariationMap.user_id
                    else { continue }
                _ = self.setForcedVariation(experimentKey: experimentKey, variationKey: variationKey, userId: userId)
            }
        }
    }
    
    func dispatchedEvents() -> [[String : Any]] {
        guard let dispatcher = self.optimizelyClient?.optimizely?.eventDispatcher as? OPTLYEventDispatcherProxy else { return [[:]] }
        let events = dispatcher.events
        return events
    }
    
    func profile(forUser userId: String) -> [AnyHashable : Any]? {
        let profile = self.optimizelyClient?.optimizely?.userProfileService?.lookup(userId)
        return profile
    }
    
    func activate(experiment experimentKey: String, userId: String, attributes: [String : String]?, listenerCount: Int?) -> (String?, [[String : Any]]) {
        var listeners = [[String : Any]]()
        if let _listenerCount = listenerCount {
            for _ in 0..<_listenerCount {
                let listner : ActivateListener = { (experiment, userId, attributes, variation, logEvents) in
                    let listnerDict : [String : Any] = [
                        keyExperiment   : experiment.experimentKey,
                        keyUserId       : userId,
                        keyAttributes   : attributes,
                        keyVariation    : variation.variationKey
                        ]
                    listeners.append(listnerDict)
                }
                self.optimizelyClient?.notificationCenter()?.addActivateNotificationListener(listner)
            }
        }
        let variation = self.optimizelyClient?.activate(experimentKey, userId: userId, attributes: attributes)
        self.optimizelyClient?.notificationCenter()?.clearAllNotificationListeners()
        return (variation?.variationKey , listeners)
    }
    
    func getVariation(experiment experimentKey: String, userId: String, attributes: [String : String]?) -> String? {
        let variation = self.optimizelyClient?.variation(experimentKey, userId: userId, attributes: attributes)
        return variation?.variationKey
    }

    func track(event eventKey: String, userId: String, attributes: [String : String]?, eventTags: [String : Any]?, listenerCount: Int?) -> [[String : Any]] {
        var listeners = [[String : Any]]()
        if let _listenerCount = listenerCount {
            for _ in 0..<_listenerCount {
                let listner : TrackListener = { (eventKey, userId, attributes, eventTags, event) in
                    let listnerDict : [String : Any] = [
                        keyAttributes   : attributes,
                        keyEvent        : eventKey,
                        keyEventTags    : eventTags,
                        keyUserId       : userId
                    ]
                    listeners.append(listnerDict)
                }
                self.optimizelyClient?.notificationCenter()?.addTrackNotificationListener(listner)
            }
        }
        self.optimizelyClient?.track(eventKey, userId: userId, attributes: attributes, eventTags: eventTags)
        return listeners
    }
    
    func getEnabledFeatures(userId: String?, attributes: [String : String]?) -> [String]? {
        let features = self.optimizelyClient?.getEnabledFeatures(userId, attributes: attributes)
        return features
    }
    
    
    func getFeatureVariableBoolean(featureKey: String?, variableKey: String?, userId: String?, attributes: [String : String]?) -> Bool? {
        let booleanVariable = self.optimizelyClient?.getFeatureVariableBoolean(featureKey, variableKey: variableKey, userId: userId, attributes: attributes)
        return booleanVariable
    }
    
    func getFeatureVariableDouble(featureKey: String?, variableKey: String?, userId: String?, attributes: [String : String]?) -> Double? {
        let doubleVariable = self.optimizelyClient?.getFeatureVariableDouble(featureKey, variableKey: variableKey, userId: userId, attributes: attributes)
        return doubleVariable
    }
    
    func getFeatureVariableInteger(featureKey: String?, variableKey: String?, userId: String?, attributes: [String : String]?) -> Int32? {
        let integerVariable = self.optimizelyClient?.getFeatureVariableInteger(featureKey, variableKey: variableKey, userId: userId, attributes: attributes)
        return integerVariable
    }
    
    func getFeatureVariableString(featureKey: String?, variableKey: String?, userId: String?, attributes: [String : String]?) -> String? {
        let stringVariable = self.optimizelyClient?.getFeatureVariableString(featureKey, variableKey: variableKey, userId: userId, attributes: attributes)
        return stringVariable
    }
    
    func isFeatureEnabled(featureKey: String?, userId: String?, attributes: [String : String]?) -> String? {
        let enabled = self.optimizelyClient?.isFeatureEnabled(featureKey, userId: userId, attributes: attributes)
        return enabled?.description
    }
    
    func setForcedVariation(experimentKey: String, variationKey: String, userId: String) -> String? {
        let isSet = self.optimizelyClient?.setForcedVariation(experimentKey, userId: userId, variationKey: variationKey)
        return isSet == true ? variationKey : nil
    }
    
    func getForcedVariation(experimentKey: String, userId: String) -> String? {
        let forcedVariation = self.optimizelyClient?.getForcedVariation(experimentKey, userId: userId)
        return forcedVariation?.variationKey
    }
}
