//
//  RequestView.swift
//  NetworkDemistifier
//
//  Created by Justin Allen on 7/8/21.
//

import Foundation
import SwiftUI

struct NodeView: View {
    @ObservedObject var node: Header

    var body: some View {
        HStack {
            TextField("Key", text: self.$node.key)
            TextField("Value", text: self.$node.value)
        }
    }
}

class Header: ObservableObject, Identifiable {
    @Published var key: String
    @Published var value: String
    let id: String = UUID().uuidString

    init(key _key: String, value _val: String) {
        self.key = _key
        self.value = _val
    }
}

struct RequestView: View {
    @State var url: String = "https://"
    @State var method: String = "GET"
    @State private var items: [Header] = [
        Header(key: "Content-Type", value: "application/json")
    ]
    
    let Methods = ["GET", "POST"]
    
    func removeRow(at offsets: IndexSet) {
//        print(items.count)
//        print(offsets)
//        items.remove(at: offsets)
        items.remove(atOffsets: offsets)
    }
    
    func addRow() {
        items.append(Header(key: "", value: ""))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                
                List {
                    Section(header: Text("")) {
                        HStack {
                            Text("URL")
                            TextField("Web Address", text: $url)
                        }
                        Picker("Method", selection: $method) {
                            ForEach(Methods, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    Section(header: Text("Header").bold()) {
                        ForEach(items.indices, id: \.self) { index in
                            let item = items[index]
                            NodeView(node: item)
                        }
                        .onDelete(perform: removeRow)
                        
                        Button(action: {
                            addRow()
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus")
                                Spacer()
                            }
                            
                        })
                    }
                    
                    Section {
                        Button(action: {
                            print("Setup")
                        }, label: {
                            Text("Request")
                        })
                    }
                    

                }
    //            .border(Color.black, width: 1 )
                .listStyle(InsetGroupedListStyle())
    //            .listStyle(GroupedListStyle())
            }.navigationBarTitle("Network Demistifier", displayMode: .inline)
        }
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
