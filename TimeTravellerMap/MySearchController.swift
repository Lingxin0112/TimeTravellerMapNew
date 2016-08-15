//
//  MySearchController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 10/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class MySearchController: UISearchController {
    
    lazy var mySearchBar: MySearchBar = {
        [unowned self] in
        let result = MySearchBar()
        result.delegate = self
        return result
        }()
    
    override var searchBar: UISearchBar {
        get {
            return mySearchBar
        }
    }
    
    override init(searchResultsController: UIViewController!) {
        super.init(searchResultsController: searchResultsController)
        
        searchBar.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}

extension MySearchController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchBar.text!.isEmpty)
        {
            self.active=true
        }
        else
        {
            self.active=false
        }
    }
}
