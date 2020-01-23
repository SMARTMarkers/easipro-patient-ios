EASI-PRO Home App
================

### A Health app for Patient Generated Health Data

EASI-PRO Home is a standalone patient facing iOS app built on the [SMART on FHIR][[sf] open specification and powered by the [SMART Markers][sm] [framework] to receive and respond to practitioner's _requests_ with PGHD data generated through survey like modules in-app. Built using Swift for iOS.

### PGHD Instruments

The app relies on the SMART Markers framework's supported PGHD instruments to create a data generating user session. Many types of instruments are supported out of the box with more being actively developed. Some examples include: FHIR Questionnaire encoded surveys, [PROMIS][promis] CAT surveys, activity data, sensor based activity tests and more. [Check here][ilist] for a complete list.


Functionality
-------------

1. Users can login to their SMART enabled health system
2. Fetch all practitioner dispatched _requests_ for data
3. Users generate or aggregate health data as per the request and/or the Instrument requested
4. Users submit data to their health systems through the app.


Configuration
------------
0. You will need Xcode version 11.3 and Swift 5.0 and a `FHIR Server` endpoints and optionally their SMART credentials.
1. Clone repository: `$ git clone --recursive https://github.com/smartmarkers/easipro-patient-ios`
2. Make sure SMARTMarkers and its submodules are downloaded
1. Add SMARTMarkers.xcodeproj, ResearchKit.xcodeproj, SMART.xcodeproj to the application's project workspace
4. Compile ResearchKit and SMARTMarkers.xcodeproj
5. Go to Project Settings -> General Tab and add the three frameworks and HealthKit to the `Frameworks, Libraries, and Embedded Content`.
6. Build and run the app


You will need a SMART on FHIR endpoint to get started
```swift
extension FHIRManager {

    /**
     SMART Sandbox Credentials take from Config.xcconfig via App's
     - REPLACE Settings or create a new Client for other FHIR Servers
     */
    class func SMARTSandbox() -> FHIRManager {

        let infoDict = Bundle.main.infoDictionary!
        guard var baseURI = infoDict["FHIR_BASE_URL"] as? String else {
            fatalError("Need FHIR Endpoint")
        }
        if !baseURI.hasPrefix("http") {
            baseURI = "https://" + baseURI
        }

        let settings = [
            "client_name"   : "easipro-clinic",
            "client_id"     : "easipro-clinic-id",
            "redirect"      : "smartmarkers-home://smartcallback",
            "scope"         : "openid profile user/*.* launch"
        ]
        let smart_baseURL = URL(string: baseURI)!
        let client = Client(baseURL: smart_baseURL, settings: settings)
        client.authProperties.granularity = .tokenOnly

        //Initalize PROMIS FHIR server client with base uri, id, secret
        let promis = PROMISClient(..)
        return FHIRManager(main: client, promis: promis)
    }
}

  /*
  Initialize FHIRManager
  Can be done in AppDelegate
  */

lazy var fhir: FHIRManager! = {
        return FHIRManager.SMARTSandbox()
    }()


// Catch callback for SMART authorization
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if fhir.main.awaitingAuthCallback {
            return fhir.main.didRedirect(to: url)
        }

        return false
    }
```

SMART Markers
-------------
This app was built on top of the SMART Markers framework but with its own custom interface and user experience designed specifically for PROMIS instruments and has now expanded to include various instruments enabled by the framework. [ResearchKit][rk] and [SwiftSMART][sw] are used as its submodules


[sm]: https://github.com/smartmarkers/smartmarkers-ios
[sf]: https://docs.smarthealthit.org
[promis]: https://healthmeasures.net
[ilist]: https://github.com/SMARTMarkers/smartmarkers-ios/tree/master/Sources/Instruments
[rk]: https://researchkit.org
[sw]: https://github.com/smart-on-fhir/Swift-SMART


