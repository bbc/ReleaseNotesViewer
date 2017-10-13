//
//  Created by Michael May on 13/10/2017.
//  Copyright © 2017 Michael May. All rights reserved.
//
//  You need to know your App ID, which is not always easy to find. The simplest
//  way is
//  * go to https://duckduckgo.com
//  * search for your app: e.g. "itunes.apple.com: bbc news"
//  * look for the link that looks like this https://itunes.apple.com/us/app/bbc-news/id364147881?mt=8
//  * You want the number at the end after the id prefix and before the ?mt=8 suffix

import UIKit
import Foundation

class WhatsNewReleaseNoteViewController: UIViewController {
    @IBOutlet fileprivate weak var whatsNew: UILabel?
    @IBOutlet fileprivate weak var releaseNote: UITextView?

    private let appID: String
    private var task: URLSessionDataTask?

    init(appID: String) {
        self.appID = appID

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.requestLatestFromAppStore()
    }

    private func requestLatestFromAppStore() {
        self.task?.cancel()
        self.task = AppStoreFetch.task(for: self.appID, whatsNew: self.whatsNew, releaseNote: self.releaseNote)
        self.task?.resume()
    }
}

@objc protocol TextSettable : class {
    var text : String? { get set }
}

extension UILabel : TextSettable { }
extension UITextView : TextSettable { }

fileprivate class AppStoreFetch {
    class func task(for appID: String, whatsNew: TextSettable?, releaseNote: TextSettable?) -> URLSessionDataTask {
        var appStoreURLString : String { return "https://itunes.apple.com/lookup?id=\(appID)" }
        let appStoreURL = URL(string: appStoreURLString)!
        let request = URLRequest(url: appStoreURL)

        return URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                print(error ?? "unknown error")
                return
            }

            guard let jsonElements = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) else {
                return
            }

            guard let jsonDictionary = jsonElements as? Dictionary<String, AnyObject> else {
                return
            }

            guard let resultsDictionary = jsonDictionary["results"] as? Array<Dictionary<String, AnyObject>> else {
                return
            }

            guard let releaseNotes = resultsDictionary[0]["releaseNotes"] as? String  else {
                return
            }

            guard let releaseVersion = resultsDictionary[0]["version"] as? String  else {
                return
            }

            let whatsNewText: String = {
                let placeholder = Bundle.main.localizedString(forKey: "whatsnew.title.text",
                                                              value: "${releaseVersion}",
                                                              table: nil)

                return placeholder.replacingOccurrences(of: "${releaseVersion}", with: releaseVersion)
            }()

            weak var weakWhatsNew = whatsNew
            weak var weakReleaseNote = releaseNote

            DispatchQueue.main.async {
                weakWhatsNew?.text = whatsNewText
                weakReleaseNote?.text =  releaseNotes
            }
        }
    }
}
