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

struct Test: ParameterableModel {
    
    var attributes: [String : String]?
    var context: Context?
    var event_tags: [String : Any]?
    var user_id, feature_flag_key, event_key, variable_key, experiment_key, forced_variation_key: String?
    
    enum CodingKeys: String, CodingKey {
        case attributes, context, feature_flag_key, user_id, event_key, event_tags
        case variable_key, experiment_key, forced_variation_key
    }
    
    // MARK: Init
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = Context.init(representation: representation[self.primaryKey()])
            else { return nil }
        
        self.context = primaryValue
        self.attributes = representation[CodingKeys.attributes.stringValue] as? [String : String]
        self.event_tags = representation[CodingKeys.event_tags.stringValue] as? [String : Any]
        self.user_id = representation[CodingKeys.user_id.stringValue] as? String
        self.feature_flag_key = representation[CodingKeys.feature_flag_key.stringValue] as? String
        self.event_key = representation[CodingKeys.event_key.stringValue] as? String
        self.variable_key = representation[CodingKeys.variable_key.stringValue] as? String
        self.experiment_key = representation[CodingKeys.experiment_key.stringValue] as? String
        self.forced_variation_key = representation[CodingKeys.forced_variation_key.stringValue] as? String
    }
    
    func primaryKey() -> String {
        return CodingKeys.context.stringValue
    }
}

struct Context: ParameterableModel {
    
    var datafile: String?
    var force_variations = [ForceVariation]()
    var custom_event_dispatcher: String?
    var dispatched_events = [DispatchedEvent]()
    var user_profile_service: String?
    var user_profiles = [UserProfile]()
    var with_listener = [WithListener]()
    
    enum CodingKeys: String, CodingKey {
        case datafile
        case force_variations, custom_event_dispatcher, dispatched_events, user_profile_service, user_profiles, with_listener
    }
    
    // MARK: Init
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = representation[self.primaryKey()] as? String
            else { return nil }
        
        self.datafile = primaryValue
        self.custom_event_dispatcher = representation[CodingKeys.custom_event_dispatcher.stringValue] as? String
        self.user_profile_service = representation[CodingKeys.user_profile_service.stringValue] as? String
        if let variations = representation[CodingKeys.force_variations.stringValue] as? [[String : Any]] {
            for variation in variations {
                guard let forceVariation = ForceVariation.init(representation: variation) else { continue }
                self.force_variations.append(forceVariation)
            }
        }
        if let events = representation[CodingKeys.dispatched_events.stringValue] as? [[String : Any]] {
            for event in events {
                guard let dispatchedEvent = DispatchedEvent.init(representation: event) else { continue }
                self.dispatched_events.append(dispatchedEvent)
            }
        }
        if let profiles = representation[CodingKeys.user_profiles.stringValue] as? [[String : Any]] {
            for profile in profiles {
                guard let userProfile = UserProfile.init(representation: profile) else { continue }
                self.user_profiles.append(userProfile)
            }
        }
        if let listeners = representation[CodingKeys.with_listener.stringValue] as? [[String : Any]] {
            for listener in listeners {
                guard let withListener = WithListener.init(representation: listener) else { continue }
                self.with_listener.append(withListener)
            }
        }
    }
    
    func primaryKey() -> String {
        return CodingKeys.datafile.stringValue
    }
}

struct DispatchedEvent: ParameterableModel {
    
    var url: String?
    var params: [String : Any]?
    var http_verb: String?
    var headers: [String : String]?
    
    // MARK: Parameterization
    
    enum CodingKeys: String, CodingKey {
        case url, params, http_verb, headers
    }
    
    // MARK: Init
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = representation[primaryKey()] as? [String : Any]
            else { return nil }
        
        self.url = representation[CodingKeys.url.stringValue] as? String
        self.params = primaryValue
        self.http_verb = representation[CodingKeys.http_verb.stringValue] as? String
        self.headers = representation[CodingKeys.headers.stringValue] as? [String : String]
    }
    
    func primaryKey() -> String {
        return CodingKeys.params.stringValue
    }
}

struct UserProfile: ParameterableModel {
    var experiment_bucket_map: [String : Any]?
    var user_id: String?
    
    enum CodingKeys: String, CodingKey {
        case experiment_bucket_map, user_id
    }
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = representation[self.primaryKey()] as? String
            else { return nil }
        
        self.user_id = primaryValue
        self.experiment_bucket_map = representation[CodingKeys.experiment_bucket_map.stringValue] as? [String : Any]
    }
    
    func primaryKey() -> String {
        return CodingKeys.user_id.stringValue
    }
}

struct ForceVariation: ParameterableModel {
    var experiment_bucket_map: [String : Any]?
    var user_id: String?
    
    enum CodingKeys: String, CodingKey {
        case experiment_bucket_map, user_id
    }
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = representation[self.primaryKey()] as? String
            else { return nil }
        
        self.user_id = primaryValue
        self.experiment_bucket_map = representation[CodingKeys.experiment_bucket_map.stringValue] as? [String : Any]
    }
    
    func primaryKey() -> String {
        return CodingKeys.user_id.stringValue
    }
}

struct WithListener: Codable {
    var type: String?
    var count: Int?
    
    enum CodingKeys: String, CodingKey {
        case type, count
    }
    
    init?(representation: Any?) {
        guard
            let representation = representation as? [String: Any],
            let primaryValue = representation[self.primaryKey()] as? String
            else { return nil }
        
        self.type = primaryValue
        self.count = representation[CodingKeys.count.stringValue] as? Int ?? 0
    }
    
    func primaryKey() -> String {
        return CodingKeys.type.stringValue
    }
}
