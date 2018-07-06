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

class TestWorker {
    
    static let shared = TestWorker()
    private var testURL = ""
    private var testJSON = ""
    
    private var test: Test?
    
    private init() { }
    
    func serialize(testJSON json: String, forAPIUrl url: String) -> Bool {
        self.testJSON = json
        self.testURL = url
        guard
            let data = testJSON.data(using: String.Encoding.utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let test = Test.init(representation: json)
            else { return false }
        self.test = test
        return true
    }
    
    func dataFileName() -> String {
        let fileName = self.test?.context?.datafile
        return fileName ?? ""
    }
    
    func forceVariations() -> [ForceVariation]? {
        let forceVariations = self.test?.context?.force_variations
        return forceVariations
    }
    
    func eventDispatcher() -> String {
        let eventDispatcher = self.test?.context?.custom_event_dispatcher
        return eventDispatcher ?? ""
    }
    
    func userProfileService() -> String {
        let userProfileService = self.test?.context?.user_profile_service
        return userProfileService ?? ""
    }
    
    func userProfiles() -> [[AnyHashable : Any]]? {
        let userProfiles = self.test?.context?.toParams()[Context.CodingKeys.user_profiles.stringValue]
        return userProfiles as? [[AnyHashable : Any]]
    }
    
    func listenersCount(forType type: String) -> Int? {
        if let index = self.test?.context?.with_listener.index(where: { (listener) -> Bool in
            listener.type == type
        }){
            return self.test?.context?.with_listener[index].count
        }
        return nil
    }
    
    func getResult() -> String? {
        switch self.testURL {
        case "activate":
            return self.testActivate()
        case "get_variation":
            return self.testGetVariation()
        case "track":
            return self.testTrack()
        case "get_enabled_features":
            return self.testGetEnabledFeatures()
        case "get_feature_variable_boolean":
            return self.testGetFeatureVariableBoolean()
        case "get_feature_variable_double":
            return self.testGetFeatureVariableDouble()
        case "get_feature_variable_integer":
            return self.testGetFeatureVariableInteger()
        case "get_feature_variable_string":
            return self.testGetFeatureVariableString()
        case "is_feature_enabled":
            return self.testIsFeatureEnabled()
        case "set_forced_variation":
            return self.testSetForcedVariation()
        case "get_forced_variation":
            return self.testGetForcedVariation()
        default:
            return nil
        }
    }
    
    // MARK: - Private
    
    private func deSerialize(result: Any?, listeners: Any?) -> String {
        let context = self.getContext()
        let json = [
            "context": context,
            "listener_called": listeners,
            "result": result
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options:.prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
    
    private func getContext() -> [String : Any]? {
        
        // modify objects
        var contextMutable = self.test?.context
        contextMutable?.force_variations = TestWorker.shared.getForceVariations()
        contextMutable?.dispatched_events = TestWorker.shared.getDispatchedEvents()
        contextMutable?.user_profiles = TestWorker.shared.getUserProfiles()
        
        // convert to json
        let context = contextMutable?.toParams()
        return context
    }
    
    func getDispatchedEvents() -> [DispatchedEvent] {
        var dispatchedEvents = [DispatchedEvent]()
        let events = OptimizelyWorker.shared.dispatchedEvents()
        
        for event in events {
            guard let dispatchedEvent = DispatchedEvent.init(representation: event) else { continue }
            dispatchedEvents.append(dispatchedEvent)
        }
        return dispatchedEvents
    }
    
    func getUserProfiles() -> [UserProfile] {
        var updatedUserProfiles = [UserProfile]()
        guard let userProfiles = self.test?.context?.user_profiles else { return updatedUserProfiles }
        
        for userProfile in userProfiles {
            guard
                let userId = userProfile.user_id,
                let profile = OptimizelyWorker.shared.profile(forUser: userId) else { continue }
            
            guard let updatedUserProfile = UserProfile.init(representation: profile) else { continue }
            updatedUserProfiles.append(updatedUserProfile)
        }
        
        return updatedUserProfiles
    }
    
    func getForceVariations() -> [ForceVariation] {
        var updatedForceVariations = self.test?.context?.force_variations ?? [ForceVariation]()
        
        guard
            let experimentKey = self.test?.experiment_key,
            let userId = self.test?.user_id,
            let variation = OptimizelyWorker.shared.getForcedVariation(experimentKey: experimentKey, userId: userId)
            else { return updatedForceVariations }
        
        let variationMap = [
            "variation_id": variation
        ]
        if let index = updatedForceVariations.index(where: { (variation) -> Bool in
            variation.user_id == userId
        }) {
            updatedForceVariations[index].experiment_bucket_map?[experimentKey] = variationMap
            return updatedForceVariations
        }
        
        let forceVariationJSON : [String : Any] = [
            ForceVariation.CodingKeys.user_id.stringValue               : userId,
            ForceVariation.CodingKeys.experiment_bucket_map.stringValue : [
                experimentKey : variationMap
            ]
        ]
        
        guard let forceVariation = ForceVariation.init(representation: forceVariationJSON) else { return updatedForceVariations}
        updatedForceVariations.append(forceVariation)
        
        return updatedForceVariations
    }
    
    private func testActivate() -> String? {
        guard
            let expKey = self.test?.experiment_key,
            let userId = self.test?.user_id
            else { return nil }
        let resultTuple = OptimizelyWorker.shared.activate(experiment: expKey,
                                                           userId: userId,
                                                           attributes: self.test?.attributes,
                                                           listenerCount: self.listenersCount(forType: "Activate"))

        return self.deSerialize(result: resultTuple.0, listeners: resultTuple.1)
    }
    
    private func testGetVariation() -> String? {
        guard
            let expKey = self.test?.experiment_key,
            let userId = self.test?.user_id
            else { return nil }
        let result = OptimizelyWorker.shared.getVariation(experiment: expKey,
                                                          userId: userId,
                                                          attributes: self.test?.attributes)
        
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testTrack() -> String? {
        guard
            let eventKey = self.test?.event_key,
            let userId = self.test?.user_id
            else { return nil }
        
        let listeners = OptimizelyWorker.shared.track(event: eventKey,
                                                      userId: userId,
                                                      attributes: self.test?.attributes,
                                                      eventTags: self.test?.event_tags,
                                                      listenerCount: self.listenersCount(forType: "Track"))
        
        return self.deSerialize(result: nil, listeners: listeners)
    }
    
    private func testGetEnabledFeatures() -> String? {
        let result = OptimizelyWorker.shared.getEnabledFeatures(userId: self.test?.user_id, attributes: self.test?.attributes)
        
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testGetFeatureVariableBoolean() -> String? {
        let result = OptimizelyWorker.shared.getFeatureVariableBoolean(featureKey: self.test?.feature_flag_key,
                                                                       variableKey: self.test?.variable_key,
                                                                       userId: self.test?.user_id,
                                                                       attributes: self.test?.attributes)
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testGetFeatureVariableDouble() -> String? {
        let result = OptimizelyWorker.shared.getFeatureVariableDouble(featureKey: self.test?.feature_flag_key,
                                                                      variableKey: self.test?.variable_key,
                                                                      userId: self.test?.user_id,
                                                                      attributes: self.test?.attributes)
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testGetFeatureVariableInteger() -> String? {
        let result = OptimizelyWorker.shared.getFeatureVariableInteger(featureKey: self.test?.feature_flag_key,
                                                                       variableKey: self.test?.variable_key,
                                                                       userId: self.test?.user_id,
                                                                       attributes: self.test?.attributes)
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testGetFeatureVariableString() -> String? {
        let result = OptimizelyWorker.shared.getFeatureVariableString(featureKey: self.test?.feature_flag_key,
                                                                      variableKey: self.test?.variable_key,
                                                                      userId: self.test?.user_id,
                                                                      attributes: self.test?.attributes)
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testIsFeatureEnabled() -> String? {
        let result = OptimizelyWorker.shared.isFeatureEnabled(featureKey: self.test?.feature_flag_key,
                                                              userId: self.test?.user_id,
                                                              attributes: self.test?.attributes)
        
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testSetForcedVariation() -> String? {
        guard
            let experimentKey = self.test?.experiment_key,
            let forcedVariationKey = self.test?.forced_variation_key,
            let userId = self.test?.user_id
            else { return nil }
        
        let result = OptimizelyWorker.shared.setForcedVariation(experimentKey: experimentKey,
                                                                variationKey: forcedVariationKey,
                                                                userId: userId)
        
        return self.deSerialize(result: result, listeners: nil)
    }
    
    private func testGetForcedVariation() -> String? {
        guard
            let experimentKey = self.test?.experiment_key,
            let userId = self.test?.user_id
            else { return nil }
        
        let result = OptimizelyWorker.shared.getForcedVariation(experimentKey: experimentKey, userId: userId)
        
        
        return self.deSerialize(result: result, listeners: nil)
    }    
}
