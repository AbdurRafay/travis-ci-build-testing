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

private let datafilesDir = "Datafiles"

enum FileExtension {
    case json
    var string: String {
        switch self {
        case .json:
            return "json"
        }
    }
}

class FileWorker {
    
    static let shared = FileWorker()
    private init() { }
    
    func getDataFrom(file fileName: String, withExtension ext: String = FileExtension.json.string) -> Data? {
        // load the datafile from the app bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: datafilesDir) else { return nil }
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch  {
            print("invalid Data of type %@",ext)
        }
        return data
    }
    
}
