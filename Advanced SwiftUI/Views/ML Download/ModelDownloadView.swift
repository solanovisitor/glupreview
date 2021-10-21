//
//  ModelDownloadView.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 10/10/2021.
//

import SwiftUI
import CoreML

struct ModelDownloadView: View {
    @State private var showAlertToggle = false
    @State private var showDashboardToggle = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var enableNavigation = false
    @Environment(\.managedObjectContext) private var viewContext
}
extension ModelDownloadView {
    var body: some View {
        NavigationView {
            GeometryReader { r in
                ZStack(alignment: .top) {
                    Image("background-2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    Color("secondaryBackground")
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.5)
                    Group {
                        VStack {
                            VStack {
                                VStack(alignment: .center) {
                                    VStack(alignment:.leading,spacing: 20) {
                                        HStack {
                                            Spacer()
                                        }
                                        Text("Wait until your AI is trained")
                                            .font(Font.largeTitle.bold())
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                            .padding(.top, 150)
                                            .fixedSize(horizontal: false, vertical: true)
                                        VStack {
                                            Text("It should take some minutes until a ") +
                                                Text("customized machine learning model ").font(.headline.bold()).foregroundColor(.white)
                                                + Text("is trained for you.")
                                        }
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding([.leading, .trailing])
                                        .padding(.bottom,20)
                                        Text("You will be notified when ready!")
                                            .font(.headline.bold())
                                            .foregroundColor(Color("secondryText"))
                                            .padding([.leading, .trailing])
                                            .padding(.bottom,100)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2))
                                    .background(Color("secondaryBackground").opacity(0.5))
                                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30)
                                
                            )
                            .cornerRadius(30)
                            .padding([.leading, .trailing])
                        }
                        Image("loading_ml")
                            .resizable()
                            .frame(width: r.size.width/1.35, height: 300)
                            .padding(.top,-150)
                    }
                    .padding(.top,((r.size.height/4)-30))
                }
                .alert(isPresented: $showAlertToggle, content: {
                    if enableNavigation {
                        return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok"), action: {
                            showDashboardToggle.toggle()
                        }))
                    } else {
                       return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
                    }
                })
            }
        }
        .accentColor(.white)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ModelDownloaded)) { obj in
            let modelLink = RCValues.sharedInstance.value(forKey: .modelLink)
            let modelVersion = RCValues.sharedInstance.value(forKey: .modelVersion)
            print(modelLink)
            if let ml = URL(string: modelLink) {
                do {
                    try ml.download(to: .documentDirectory) { url, error in
                        guard let url = url else { return }
                        // MARK:- Downloaded ML Locally
                        
                        print("Downloaded URL of ML Model")
                        print("Path")
                        do {
//                            //MARK:- Initiate ML Model
//                            let compiledModelURL = try MLModel.compileModel(at: url)
//                            let model = try MLModel(contentsOf: compiledModelURL)
//                            //MARK:- Save Reusable Models to a Permanent Location
//                            let fileManager = FileManager.default
//                            let appSupportURL = fileManager.urls(for: .applicationSupportDirectory,
//                                                                 in: .userDomainMask).first!
//                            let compiledModelName = compiledModelURL.lastPathComponentlet
//                            permanentURL = appSupportURL.appendingPathComponent(compiledModelName)
//                            _ = try fileManager.replaceItemAt(permanentURL,withItemAt: compiledModelURL)
                            UserDefaults.standard.set(url, forKey: CurrentModelLocalPath_STR)
                            UserDefaults.standard.set(modelVersion, forKey: CurrentModelVersion_STR)
                            alertTitle = "Let's Go!"
                            alertMessage = "Thanks for the patience. AI is ready to processed, Shall we proced to see the result?"
                            enableNavigation.toggle()
                            showAlertToggle.toggle()
                        } catch let error {
                            print("Machine Model error : \(error.localizedDescription)")
                            alertTitle = "Uh-Oh!"
                            alertMessage = error.localizedDescription
                            showAlertToggle.toggle()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        .fullScreenCover(isPresented: $showDashboardToggle) {
            Dashboard()
//            Dashboard().environment(\.managedObjectContext, self.viewContext)
        }
    }
}
struct ModelDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        ModelDownloadView()
    }
}
