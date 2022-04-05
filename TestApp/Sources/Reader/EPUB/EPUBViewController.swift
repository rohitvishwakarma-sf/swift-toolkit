//
//  EPUBViewController.swift
//  r2-testapp-swift
//
//  Created by Alexandre Camilleri on 7/3/17.
//
//  Copyright 2018 European Digital Reading Lab. All rights reserved.
//  Licensed to the Readium Foundation under one or more contributor license agreements.
//  Use of this source code is governed by a BSD-style license which is detailed in the
//  LICENSE file present in the project repository where this source code is maintained.
//

import UIKit
import R2Shared
import R2Navigator

class EPUBViewController: ReaderViewController {
  
    var popoverUserconfigurationAnchor: UIBarButtonItem?
    var userSettingNavigationController: UserSettingsNavigationController
    
    @objc func highlightSelection() {
            if let navigator = navigator as? SelectableNavigator, let selection = navigator.currentSelection {
                let highlight = Highlight(bookId: bookId, locator: selection.locator, color: .yellow,annotation: .normal)
                saveHighlight(highlight)
                navigator.clearSelection()
            }
        }
    
    @objc func underlineSelection() {
        if let navigator = navigator as? SelectableNavigator, let selection = navigator.currentSelection {
            let highlight = Highlight(bookId: bookId, locator: selection.locator, color: .yellow,annotation: .underline)
            saveHighlight(highlight)
            navigator.clearSelection()
        }
        
        }
    @objc func sideMarkSelection(){
        if let navigator = navigator as? SelectableNavigator, let selection = navigator.currentSelection {
            let highlight = Highlight(bookId: bookId, locator: selection.locator, color: .yellow,annotation: .sideMark)
            saveHighlight(highlight)
            navigator.clearSelection()
        }
        
    }
    @objc func strikeThroughSelection(){
        if let navigator = navigator as? SelectableNavigator, let selection = navigator.currentSelection {
            let highlight = Highlight(bookId: bookId, locator: selection.locator, color: .yellow,annotation: .strikeThrough)
            saveHighlight(highlight)
            navigator.clearSelection()
        }
        
    }
    @objc func noteSelection(){
        if let navigator = navigator as? SelectableNavigator, let selection = navigator.currentSelection {
            let highlight = Highlight(bookId: bookId, locator: selection.locator, color: .yellow,annotation: .note)
            saveHighlight(highlight)
            navigator.clearSelection()
        }
        
    }
    
    init(publication: Publication, locator: Locator?, bookId: Book.Id, books: BookRepository, bookmarks: BookmarkRepository,highlights:HighlightRepository, resourcesServer: ResourcesServer) {
        
        
        var configuration = EPUBNavigatorViewController.Configuration()
        configuration.decorationTemplates["sidemark"] = TemplateFactory.getSideMarkTemplate()
        configuration.decorationTemplates["strikethrough"] = TemplateFactory.getStrikeThroughTemplate()
        configuration.decorationTemplates["note"] = TemplateFactory.getNoteTemplate()
        configuration.editingActions.append(EditingAction(title: "Highlight", action: #selector(highlightSelection)))
        configuration.editingActions.append(EditingAction(title: "Underline", action: #selector(underlineSelection)))
        configuration.editingActions.append(EditingAction(title: "Sidemark", action: #selector(sideMarkSelection)))
        configuration.editingActions.append(EditingAction(title: "Strike Through", action: #selector(strikeThroughSelection)))
        configuration.editingActions.append(EditingAction(title: "Add Note", action: #selector(noteSelection)))
        let navigator = EPUBNavigatorViewController(publication: publication, initialLocation: locator, resourcesServer: resourcesServer,config: configuration)

        let settingsStoryboard = UIStoryboard(name: "UserSettings", bundle: nil)
        userSettingNavigationController = settingsStoryboard.instantiateViewController(withIdentifier: "UserSettingsNavigationController") as! UserSettingsNavigationController
        userSettingNavigationController.fontSelectionViewController =
            (settingsStoryboard.instantiateViewController(withIdentifier: "FontSelectionViewController") as! FontSelectionViewController)
        userSettingNavigationController.advancedSettingsViewController =
            (settingsStoryboard.instantiateViewController(withIdentifier: "AdvancedSettingsViewController") as! AdvancedSettingsViewController)
        
        super.init(navigator: navigator, publication: publication, bookId: bookId, books: books, bookmarks: bookmarks,highlights: highlights)
        
        navigator.delegate = self
    }
    
    var epubNavigator: EPUBNavigatorViewController {
        return navigator as! EPUBNavigatorViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
  
        /// Set initial UI appearance.
        if let appearance = publication.userProperties.getProperty(reference: ReadiumCSSReference.appearance.rawValue) {
            setUIColor(for: appearance)
        }
        
        let userSettings = epubNavigator.userSettings
        userSettingNavigationController.userSettings = userSettings
        userSettingNavigationController.modalPresentationStyle = .popover
        userSettingNavigationController.usdelegate = self
        userSettingNavigationController.userSettingsTableViewController.publication = publication
        

        publication.userSettingsUIPresetUpdated = { [weak self] preset in
            guard let `self` = self, let presetScrollValue:Bool = preset?[.scroll] else {
                return
            }
            
            if let scroll = self.userSettingNavigationController.userSettings.userProperties.getProperty(reference: ReadiumCSSReference.scroll.rawValue) as? Switchable {
                if scroll.on != presetScrollValue {
                    self.userSettingNavigationController.scrollModeDidChange()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        epubNavigator.userSettings.save()
    }

    override func makeNavigationBarButtons() -> [UIBarButtonItem] {
        var buttons = super.makeNavigationBarButtons()

        // User configuration button
        let userSettingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settingsIcon"), style: .plain, target: self, action: #selector(presentUserSettings))
        buttons.insert(userSettingsButton, at: 1)
        popoverUserconfigurationAnchor = userSettingsButton

        return buttons
    }
    
    override var currentBookmark: Bookmark? {
        guard let locator = navigator.currentLocation else {
            return nil
        }
        
        return Bookmark(bookId: bookId, locator: locator)
    }
    
    @objc func presentUserSettings() {
        let popoverPresentationController = userSettingNavigationController.popoverPresentationController!
        
        popoverPresentationController.delegate = self
        popoverPresentationController.barButtonItem = popoverUserconfigurationAnchor

        userSettingNavigationController.publication = publication
        present(userSettingNavigationController, animated: true) {
            // Makes sure that the popover is dismissed also when tapping on one of the other UIBarButtonItems.
            // ie. http://karmeye.com/2014/11/20/ios8-popovers-and-passthroughviews/
            popoverPresentationController.passthroughViews = nil
        }
    }

}

extension EPUBViewController: EPUBNavigatorDelegate {
    
}

extension EPUBViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension EPUBViewController: UserSettingsNavigationControllerDelegate {

    internal func getUserSettings() -> UserSettings {
        return epubNavigator.userSettings
    }
    
    internal func updateUserSettingsStyle() {
        DispatchQueue.main.async {
            self.epubNavigator.updateUserSettingStyle()
        }
    }
    
    /// Synchronyze the UI appearance to the UserSettings.Appearance.
    ///
    /// - Parameter appearance: The appearance.
    internal func setUIColor(for appearance: UserProperty) {
        let colors = AssociatedColors.getColors(for: appearance)
        
        navigator.view.backgroundColor = colors.mainColor
        view.backgroundColor = colors.mainColor
        //
        navigationController?.navigationBar.barTintColor = colors.mainColor
        navigationController?.navigationBar.tintColor = colors.textColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.textColor]
    }
    
}

//extension EPUBViewController: UIPopoverPresentationControllerDelegate {
//    // Prevent the popOver to be presented fullscreen on iPhones.
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
//    {
//        return .none
//    }
//}

// MARK: Decoration Template
class TemplateFactory {
  public static func getSideMarkTemplate()->HTMLDecorationTemplate {
         
        
        return HTMLDecorationTemplate(
            layout: .bounds,
            width: .page,
            element: { decoration in
                let config = decoration.style.config as! SidemarkConfig
                let tint = config.tint ?? UIColor.red
                var css = ""
                css += "background-color: \(tint.cssValue(alpha: 100)) !important;"
                return """
                        <div><div class="sidemark" style="--tint: \(tint.cssValue(alpha:0.5))"/></div>
                        """
            },
            stylesheet: """
                .sidemark {
                    float: left;
                    width: 5px;
                    height: 100%;
                    background-color: var(--tint);
                    margin-left: 20px;
                    border-radius: 3px;
                }
                [dir=rtl] .sidemark {
                    float: right;
                    margin-left: 0px;
                    margin-right: 20px;
                }
                """
        )
    }
    
    public static func getStrikeThroughTemplate()-> HTMLDecorationTemplate {
        let padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        let cornerRadius:Int = 3
        let className = "strikethrough"
        return HTMLDecorationTemplate(
            layout: .boxes,
            element: { decoration in
                let config = decoration.style.config as! StrikeThroughConfig
                let tint = config.tint ?? UIColor.red
                var css = ""
                css += "border-bottom: 2px \(tint.cssValue(alpha: 1)) solid !important;"
                return "<div class=\"\(className)\" style=\"\(css)\"/>"
            },
            
            stylesheet:
            """
            .\(className) {
                margin-left: \(-padding.left)px;
                padding-right: \(padding.left + padding.right)px;
                margin-top: \(-padding.top)px;
                padding-bottom: \(padding.top + padding.bottom)px;
                border-radius: \(cornerRadius)px;
                transform: translateY(-45%);
                
            }
            """
        )
    }
    public static func getNoteTemplate()-> HTMLDecorationTemplate {
        let padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        let cornerRadius:Int = 3
        let className = "note"
        return HTMLDecorationTemplate(
            layout: .bounds,
            
            element: { decoration in
                let config = decoration.style.config as! NoteConfig
                let tint = config.tint ?? UIColor.red
                var css = ""
//                css += "background-color: \(tint.cssValue(alpha: 0.5)) !important;"
//                css += "border-bottom: 2px \(tint.cssValue(alpha: 1)) solid !important;"
                return """
                        <div>
                            <div class="\(className)">
                                <img src='data:image/png;base64,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fAMiJTEAEOmM2Tz5uIDjjmVEhVnxA47pJR1hACDSOU/jjjfva8O5Kxx37InVz4T7Pp+IH309EzHhVqWXQySGAYDIYDyNO67e34b2bt4fuMGeG4UXHsrBgjkc00v6wwBAZHAcd/xpWcmuMb1rijiml/SLAYCIxljc7g8YbdzxjTG93717NgI4ppd0jgGAiG7K07jjd+tbceGaPsYd3xjTu/7BLMRxTC8ZBAMAEd0yT+OON+9rRacG2xWXLYnECw9lY0lmqNJLIfIpBgAimjFP9wd2HunAkIrvDyTHBuBHX8/EvasTYOKrPjIgBgAiEuF+f0Ct446DAi34x79JxWPr0mAL4Dk/GRcDABF5hfu44yttQ9h1xHV/4M97WnCxxbfjjm+M6V3/YBZSOaaXiAGAiHwjPurm9wfe29uC7j6H1352bk4YXnwoG8ULI7z2M4i0hgGAiBThadzxjkPtGHHc/nlBQnQAnrqPY3qJPgsDABEpzn3ccXefA/XHOrGxthnv7GnBmUvTa1d8Y0zv01/LQFgwf80RfRb+m0FEqhMaNH5/4MWHc3D6Uv/1y4St2HagHW03GXdsCzBjnT0e37t3Dsf0Ek2BAYCIVC8j0YaMLybhG190PTc8eLIbe4914dyVfgwMOhETYcXijFBULItCaJBF6eUSaQIDABFpisVsQl5OGPJywpReCpGm8REsERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEAEBERGZBJ6QWQuDcArFN6EUREOtQEIEXpRUjhDgAREZEBMQAQEREZEAMAERGRATEAEBERGRADABERkQExABARERkQAwAREZEBMQAQEREZEAMAERGRATEA6E+P0gsgItKpLqUXIIkBQH8uK70AIiKduqT0AiQxAOhPg9ILICLSKV39fuUwIP0JBNAMIETphRAR6UwhgDqlFyGFOwD6MwDg50ovgohIZ+oA1Cu9CEncAdCnCADHAMQrvRAiIh0YAVACnQUA7gDoUweAtQAGlV4IEZEOPAqdffgDDAB6tgfAGgBtSi+EiEijHAD+HsDLSi/EGyxKL4C86gyAPwBIAzBX2aUQEWnKIQDrAPxO6YV4C+8AGEcugLsB2AEkA4hTdjlERKrSAdc7/90A/hPAuwCciq7Iy/4/Ci+gzBJR9hsAAAAASUVORK5CYII='/>
                            </div>
                        </div>
                        """
            },
            
            stylesheet:
            """
            .\(className) {
                width: 40px;
                height:40px;
                position: relative;
                /* margin-left: \(-padding.left)px;
                padding-right: \(padding.left + padding.right)px; */
                margin-top: \(-padding.top)px;
                padding-bottom: \(padding.top + padding.bottom)px;
                border-radius: \(cornerRadius);
                color: red;
                background-color: red important;
                transform: translateY(-45%);
            }
            
            img {
                display: inline-block;
                }
            """
        )
    }
}

public struct SidemarkConfig: Hashable {
    public var tint: UIColor?
    public var isActive: Bool
    public init(tint: UIColor? = nil, isActive: Bool = false) {
        self.tint = tint
        self.isActive = isActive
    }
}

public struct StrikeThroughConfig: Hashable {
    public var tint: UIColor?
    public var isActive: Bool
    public init(tint: UIColor? = nil, isActive: Bool = false) {
        self.tint = tint
        self.isActive = isActive
    }
}

public struct NoteConfig: Hashable {
    public var tint: UIColor?
    public var isActive: Bool
    public var locator: Locator
    public init(tint: UIColor? = nil, isActive: Bool = false,locator: Locator) {
        self.tint = tint
        self.isActive = isActive
        self.locator = locator
    }
}


