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

import UIKit
import OptimizelySDKiOS

class OPTLYEventDispatcherProxy: NSObject, OPTLYEventDispatcher {
    
    var events = [[String : Any]]()
    
    private let logger: OPTLYLogger
    
    init(withLogger logger: OPTLYLogger?) {
        self.logger = logger ?? OPTLYLoggerDefault()
    }
    
    func dispatchImpressionEvent(_ params: [AnyHashable : Any], callback: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.dispatchEvent(params, toURL: "https://logx.optimizely.com/v1/events", callback: callback)
    }
    
    func dispatchConversionEvent(_ params: [AnyHashable : Any], callback: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.dispatchEvent(params, toURL: "https://logx.optimizely.com/v1/events", callback: callback)
    }
    
    func dispatchEvent(_ params: [AnyHashable : Any], toURL url: String, callback: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> Void {
        let event : [String : Any] = [
            "url"       : url,
            "params"    : params,
            "http_verb"  : "POST",
            "headers"   : [
                "Content-Type": "application/json"
            ]
        ]
        events.append(event)
        logger.logMessage("Event dispatcher called to proxy event back to application", with: .debug)
    }
}
