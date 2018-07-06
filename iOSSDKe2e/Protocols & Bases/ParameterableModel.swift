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

enum SerializationError: Error {
    // We only support structs
    case StructRequired
}

protocol ParameterableModel {
    func primaryKey() -> String
    func toParams() -> [String: Any]
    func allKeys() -> [String]
    func mirror() throws -> Mirror
}

extension ParameterableModel
{    
    func mirror() throws -> Mirror {
        let mirror = Mirror(reflecting: self)
        
        guard mirror.displayStyle == .struct else {
            //throw some error
            throw SerializationError.StructRequired
        }
        return mirror
    }
    
    func toParams() -> [String: Any] {
        var result: [String: Any] = [:]
        var mirror : Mirror
        
        do {
            mirror = try self.mirror()
        } catch {
            // unable to get mirror of self so return empty result
            return result
        }
        
        for (labelMaybe, var value) in mirror.children {
            guard let label = labelMaybe, (unwrap(any: value) != nil) else {
                continue
            }
            if let parameterable = value as? ParameterableModel {
                value = parameterable.toParams()
            } else if let values = value as? Array<Any> {
                var _value = [Any]()
                for item in values {
                    if let parameterable = item as? ParameterableModel {
                        _value.append(parameterable.toParams())
                    }
                }
                value = _value
            }
            result[label] = value
        }
        return result
    }
    
    func allKeys() -> [String] {
        let keys = Array.init(self.toParams().keys)
        return keys
    }
    
    func unwrap(any: Any) -> Any? {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        if mi.children.count == 0 { return nil }
        let (_, some) = mi.children.first!
        return some
    }
}
