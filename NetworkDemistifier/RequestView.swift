//
//  RequestView.swift
//  NetworkDemistifier
//
//  Created by Justin Allen on 7/8/21.
//

import Foundation
import SwiftUI
import UIKit

struct NodeView: View {
    @ObservedObject var node: Header

    var body: some View {
        HStack {
            TextField("Key", text: self.$node.key).autocapitalization(.none)
            TextField("Value", text: self.$node.value).autocapitalization(.none)
        }
    }
}

struct AddNodePopover: View{
    @ObservedObject var node: Header
    
    
    var body: some View {
        List {
            Text("Will have form here")
            TextField("Key", text: self.$node.key).autocapitalization(.none)
            TextField("Value", text: self.$node.value).autocapitalization(.none)
            Button ("Add") {
                // TODO: add here and hide the modal.
            }
        }.listStyle(InsetGroupedListStyle())
    }
}

class Header: ObservableObject, Identifiable {
    @Published var key: String
    @Published var value: String
    let id: String = UUID().uuidString
    
    init() {
        self.key = "";
        self.value = "";
    }

    init(key _key: String, value _val: String) {
        self.key = _key
        self.value = _val
    }
}

struct ResultView: View {
    @State var text: String
//    @ObservedObject var text: String
    var body: some View {
        ScrollView {
            Text(text)
        }
//        Text(text)
    }
}

struct RequestView: View {
    @State var url: String = "http://192.168.10.173:5555/test"
    @State var method: String = "POST"
    @State private var items: [Header] = [
        Header(key: "Content-Type", value: "application/json")
    ]
    @State private var showingHeaderAddItemPopover = false
    @State var requestBody: String =
        """
        {
            "first_name" : "Justin",
            "last_name": "Allen" ,
            "email_address": "test@test.com"
        }
        """
    
    @State private var resultText: String =  "Will show result text here"
    @State private var showingResultPopover = false
    @ObservedObject var networkManager = NetworkManager()
    
//    var navigationDest = NavigationDestination
    
    let Methods = ["GET", "POST"]
    
    func removeRow(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func getLineCount() -> Int {
        // TODO: get the size of the characters and the padding.
        return requestBody.filter { $0 == "\n" }.count + 1
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
//                            showingHeaderAddItemPopover = true
                            addRow()
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus")
                                Spacer()
                            }
                            
                        }).popover(isPresented: $showingHeaderAddItemPopover) {
                            AddNodePopover(node: Header())
                        }
                    }
                    
//                    Section {
//                        Text(getLineCount().description)
//                    }
                    
                    Section {
                        TextEditor(text: $requestBody)
//                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: CGFloat(getLineCount() * 26))
//                            .padding(.vertical)
                    }
                    
                    Section {
                        
                        NavigationLink(destination: ScrollView{
//                            TextField("", text: .constant(networkManager.myResonse))
                            Text(networkManager.myResonse)
//                            TextEditor(text: .constant(networkManager.myResonse))
//                                .contextMenu(ContextMenu(menuItems: {
//                                Button("Copy", action: {
//                                  UIPasteboard.general.string = networkManager.myResonse
//                                })
//                              }))
//                            TextField("", text: networkManager.$myResonse)
                                .onAppear(perform: {
                                networkManager.execNetworkCall(url: url, method: method, headers: items, body: requestBody)
                                })
                                .disabled(true)
                                .navigationTitle(networkManager.url)
                        }, isActive: $showingResultPopover) {
//                          EmptyView()
                            Button("Request") {
                                self.showingResultPopover = true
                            }
                        }
                        
                    }
                }
    //            .border(Color.black, width: 1 )
                .listStyle(InsetGroupedListStyle())
    //            .listStyle(GroupedListStyle())
            }.navigationBarTitle("Network Demistifier", displayMode: .inline)

        }
    }
    

    
}

//MARK: - Your network manager
class NetworkManager: ObservableObject {

    @Published var myResonse = ""
    @Published var url = ""
    
    func execNetworkCall(url: String, method: String, headers: [Header]? = nil, body: String? = nil) {
        guard let _url = URL(string: url) else { return }
        var request = URLRequest(url: _url)
//        request.addValue(<#T##value: String##String#>, forHTTPHeaderField: <#T##String#>)
        request.httpMethod = method
        if let headerPairs = headers {
            headerPairs.forEach { header in
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
//        https://learnappmaking.com/urlsession-swift-networking-how-to/ 
        
        if method == "POST" {
            if let bodyStr = body {
                
    //            let string = "[{\"form_id\":3465,\"canonical_name\":\"df_SAWERQ\",\"form_name\":\"Activity 4 with Images\",\"form_desc\":null}]"
                let data = bodyStr.data(using: .utf8)!
                request.httpBody = data
            }
        }
        
        
//        request.httpBody = Data(
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
//                return
//            }
//            request.httpBody = httpBody)
        // TODO: actually change the method! and add headers
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    let str = String(decoding: data!, as: UTF8.self)
                    print(str)
                    self.myResonse = str
                    print(self.myResonse)
                }
                else {
//                    print(error)
                    self.myResonse = error?.localizedDescription ?? error.debugDescription
                }
                
    //                self.showingResultPopover = true

            }
        }.resume()
        self.url = url
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

