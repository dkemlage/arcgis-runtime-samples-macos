//
// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Cocoa
import ArcGIS

class TimeBasedQueryVC: NSViewController {
    
    @IBOutlet var mapView: AGSMapView!
    
    private var map:AGSMap!
    
    private var featureTable:AGSServiceFeatureTable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize map with oceans basemap
        self.map = AGSMap(basemap: AGSBasemap.oceans())
        
        //assign map to the map view
        self.mapView.map = self.map
        
        //create feature table using a url
        self.featureTable = AGSServiceFeatureTable(url: URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Hurricanes/MapServer/0")!)
        
        //define the request mode
        self.featureTable.featureRequestMode = .manualCache
            
        //create feature layer using the feature table
        let layer = AGSFeatureLayer(featureTable: self.featureTable)
        
        //add feature layer to map's operational layers
        self.map.operationalLayers.add(layer)
        
        //populate features based on a time-based query
        self.populateFeaturesWithQuery()
        
    }
    
    func populateFeaturesWithQuery(){
        
        //create query parameters
        let queryParams = AGSQueryParameters()
        
        //create a new time extent that covers the desired interval from September 1st to September 22th, 2000
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let startTime = formatter.date(from: "2000/9/1 00:00")
        let endTime = formatter.date(from: "2000/9/22 00:00")
        
        let timeExtent = AGSTimeExtent(startTime: startTime, endTime: endTime)
        
        //apply the time extent to query parameters to filter features based on time
        queryParams.timeExtent = timeExtent
        
        //populate features based on query parameters
        self.featureTable.populateFromService(with: queryParams, clearCache: true, outFields: ["*"]) {[weak self] (result:AGSFeatureQueryResult?, error:Error?) -> Void in
            
            guard error == nil else {
                //show error
                self?.showAlert(messageText: "Error", informativeText: error!.localizedDescription)
                return
            }
            
            //the resulting features should be displayed on the map
            //you can print the count of features
            print("Hurricane features during the time inverval: \(result?.featureEnumerator().allObjects.count ?? 0)")
            
        }
    }
    
    //MARK: - Helper methods
    private func showAlert(messageText:String, informativeText:String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
}

