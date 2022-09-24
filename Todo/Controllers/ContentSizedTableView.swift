//
//  ContentSizedTableView.swift
//  Todo
//
//  Created by Arden Zhakhin on 15.08.2022.
//

import UIKit

//class for stretchable tableViews
final class ContentSizedTableView: UITableView {

    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}
