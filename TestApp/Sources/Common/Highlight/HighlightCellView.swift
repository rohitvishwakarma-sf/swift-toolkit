//
//  HighlightCellView.swift
//  TestApp
//
//  Created by Rohit  Vishwakarma on 23/03/22.
//

import Foundation
import UIKit
import SwiftUI
import R2Shared

struct HighlightCellView: View {
    let highlight: Highlight

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(highlight.color.uiColor))
                .frame(maxWidth: 20, maxHeight: .infinity)

            Spacer()
            Text(highlight.locator.text.highlight ?? "")
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    func sanitizedText()->Locator.Text {
        return Locator.Text(after: highlight.locator.text.after?.coalescingWhitespaces().removingSuffix(" "), before: highlight.locator.text.before?.coalescingWhitespaces().removingPrefix(" "), highlight: highlight.locator.text.highlight?.coalescingWhitespaces())
        
    }
}

// This UITableView-SwiftUI wrapper is from here: https://stackoverflow.com/a/59474133
class HostingTableViewCell<Content: View>: UITableViewCell {

    private weak var controller: UIHostingController<Content>?

    func host(_ view: Content, parent: UIViewController) {
        if let controller = controller {
            controller.rootView = view
            controller.view.layoutIfNeeded()
        } else {
            let swiftUICellViewController = UIHostingController(rootView: view)
            controller = swiftUICellViewController
            swiftUICellViewController.view.backgroundColor = .clear

            layoutIfNeeded()

            parent.addChild(swiftUICellViewController)
            contentView.addSubview(swiftUICellViewController.view)
            swiftUICellViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
            contentView.addConstraint(NSLayoutConstraint(item: swiftUICellViewController.view!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))

            swiftUICellViewController.didMove(toParent: parent)
            swiftUICellViewController.view.layoutIfNeeded()
        }
    }
}
