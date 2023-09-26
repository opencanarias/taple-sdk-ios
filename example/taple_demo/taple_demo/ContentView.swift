//
//  ContentView.swift
//  taple_demo
//
//  Created by Pmolmar on 12/9/23.
//

import SwiftUI
import taple_sdk

class NotificationHandler: taple_sdk.NotificationHandlerInterface {
    
    func processNotification(notification: taple_sdk.TapleNotification) {
        debugPrint("New Notification: \(notification)")
    }
}

struct ContentView: View {
    @State private var enableStart = true
    @State private var showStart = false
    @State private var enableSubject = false
    @State private var showSubject = false
    @State private var enableEvent = false
    @State private var showEvent = false
    
    @State private var isLoading = false
    
    @State private var api: taple_sdk.TapleApi? = nil
    @State private var builder: taple_sdk.SubjectBuilder? = nil
    @State private var my_subject: taple_sdk.UserSubject? = nil
    
    fileprivate func customButton(name: String, enable: Bool, task: @escaping () -> Void) -> some View {
        Button(name, action: task)
            .padding(.vertical)
            .frame(width: /*@START_MENU_TOKEN@*/200.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/)
            .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.orange/*@END_MENU_TOKEN@*/)
            .buttonBorderShape(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=shape: ButtonBorderShape@*/.capsule/*@END_MENU_TOKEN@*/)
            .accentColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
            .cornerRadius(/*@START_MENU_TOKEN@*/20.0/*@END_MENU_TOKEN@*/)
            .disabled(!enable)
    }
    
    func tapleInit(){
        isLoading = true
        debugPrint("Initializing Taple ...");
        
        let db_manager = taple_sdk.SQLManager(table_name: "taple ")!
        let keyDerivator = taple_sdk.TapleKeyDerivator.ed25519
        let settings = taple_sdk.TapleSettings(
            listenAddr: ["/ip4/0.0.0.0/tcp/50000"],
            keyDerivator: keyDerivator,
            privateKey:[132, 132, 108, 146, 86, 21, 162, 145, 116, 64, 183, 193, 63, 18, 93, 214, 162, 25, 149,139, 224, 135, 149, 208, 183, 173, 254, 61, 181, 198, 197, 51],
            knownNodes: remote_knows_nodes_multi_addr)
        
        let node = try! taple_sdk.start(manager: db_manager, settings: settings );
        
        debugPrint("Taple node Initialized !")
        
        debugPrint("Adding BoostrapNode and governace ID")
        api = node.getApi()
        builder = node.getSubjectBuilder()
        try! api!.addPreauthorizeSubject(subjectId:governance_id, providers: remote_nodes)
        
        debugPrint("BoostrapNode added")
        
        Task {
            let notifications = NotificationHandler()
            try! node.handleNotifications(handler: notifications)
        }
        
        Task{
            debugPrint("Retrieving governance")
            var tries = 10
            while(enableStart){
                if ( tries > 0) {
                    debugPrint("Governance try number: \(tries)")
                    tries = tries - 1
                    let governance = try! api!.getGovernances(namespace: "", from: nil, quantity: nil)
                    if(governance.count > 0){
                        enableStart = false
                        showStart = true
                        enableSubject = true
                        break
                    }
                    try await Task.sleep(for: .seconds(2))
                } else {
                    debugPrint("Governance retrieving failed")
                    break
                }
            }
            isLoading = false
        }
    }
    
    func createSubject(){
        isLoading = true
        Task{
            do{
                try builder!.withName(name: "IOS_Subject")
                try builder!.withNamespace(namespace: "")
                let new_subject = try builder!.build(governanceId: governance_id, schemaId: schema_id)
                
                while(new_subject.getSubjectId() == Optional.none){
                    try new_subject.refresh()
                    try await Task.sleep(for: .seconds(3))
                }
                
                my_subject = new_subject
                
                debugPrint("Creating subject: \(String(describing: my_subject?.getSubjectId()))")
                showSubject = true
                enableEvent = true
                isLoading = false
            }
            catch {
                debugPrint("Error creating subject: \(error)")
            }
        }
    }
    
    func createEvent(){
        isLoading = true
        Task {
            if(my_subject != nil){
                do {
                    let fact = "{\"ModTwo\":{\"data\":1000}}"
                    let event_id = try my_subject!.newFactEvent(payload: fact)
                    debugPrint("Creating event with ID: \(event_id)")
                    showEvent = true
                }catch {
                    debugPrint("Error creating event: \(error)")
                }
            }
            isLoading = false
        }
    }
    
    var body: some View {
        VStack {
            Image("TapleLogo")
                .resizable()
                .frame(width: 100, height: 100, alignment: .bottom)
                .padding()

            customButton(name:"Start Taple",enable: enableStart, task: {
                tapleInit()
            })
            .alert(isPresented: $showStart, content:{
                Alert(
                    title: Text("New Node"),
                    message: Text("Started node and conection with boostrap node"),
                    dismissButton: .default(Text("Ok"))
                )
            })
            
            customButton(name: "New subject", enable: enableSubject ,task: {
                createSubject()
            })
            .alert(isPresented: $showSubject, content:{
                Alert(
                    title: Text("New subject"),
                    message: Text("Created subject and sended to the governance"),
                    dismissButton: .default(Text("Ok"))
                )
            })
            
            customButton(name: "New Event",enable: enableEvent, task: {
                createEvent()
            })
            .alert(isPresented: $showEvent, content:{
                Alert(
                    title: Text("New event"),
                    message: Text("Created event and sended to the governance"),
                    dismissButton: .default(Text("Ok"))
                )
            })
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
