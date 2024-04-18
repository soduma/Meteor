//
//  AlwaysViewController.swift
//  Meteor
//
//  Created by 장기화 on 4/18/24.
//

import UIKit
import SnapKit
import SwiftUI

//class AlwaysViewController: UIViewController {
//    private lazy var tableView: UITableView = {
//        let view = UITableView(frame: .zero, style: .insetGrouped)
//        view.dataSource = self
//        view.delegate = self
//        return view
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setLayout()
//    }
//    
//    private func setLayout() {
//        title = "Always On Live"
//        
//        [tableView]
//            .forEach { view.addSubview($0) }
//        
//        tableView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//    }
//}
//
//extension AlwaysViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        4
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        2
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        UITableViewCell()
//    }
//    
//    
//}

struct AlwaysOnLiveView: View {
    var body: some View {
        List {
            
            Section {
            } footer: {
                Text("gggggggg")
            }
            
            Section {
                Text("hi")
                Text("hi")
            } header: {
                Text("zzzzzz")
            } footer: {
                Text("gggggggg")
            }

        }
    }
}
