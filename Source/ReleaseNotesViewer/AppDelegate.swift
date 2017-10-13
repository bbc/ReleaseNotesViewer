//
//  Created by Michael May on 13/10/2017.
//  Copyright © 2017 Michael May. All rights reserved.
//

import UIKit

enum KnownAppIDs : String {
    case BBCNews = "364147881"
    case CityMapper = "469463298"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let mainViewController = WhatsNewReleaseNoteViewController(appID: KnownAppIDs.CityMapper.rawValue)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()

        return true
    }
}

