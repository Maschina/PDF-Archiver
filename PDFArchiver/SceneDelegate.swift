//
//  SceneDelegate.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 30.10.19.
//  Copyright © 2019 Julian Kahnert. All rights reserved.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private static let sharedContainerIdentifier = "group.PDFArchiverShared"
    
    var window: UIWindow?
    private let viewModel = MainTabViewModel()
    private var isCurrentlyProcessing = Atomic(false)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller
        if let windowScene = scene as? UIWindowScene {

            let view = MainTabView(viewModel: viewModel)
                .accentColor(Color(.paDarkGray))
                .environmentObject(OrientationInfo())
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = KeyCommandHostingController(rootView: view, viewModel: viewModel)

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                !self.isCurrentlyProcessing.value else { return }
            self.isCurrentlyProcessing.mutate { $0 = true }
            
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.sharedContainerIdentifier) else {
                Log.send(.critical, "Failed to get url for forSecurityApplicationGroupIdentifier.")
                return
            }
            let urls = ((try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])) ?? [])
                .filter { !$0.hasDirectoryPath }
            
            if !urls.isEmpty {
                DispatchQueue.main.async {
                    // show scan tab with document processing, after importing a document
                    self.viewModel.currentTab = .scan
                }
            }
            
            for url in urls {
                self.handle(url: url)
            }
            self.isCurrentlyProcessing.mutate { $0 = false }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // send logs in background
        let application = UIApplication.shared
        Log.sendOrPersistInBackground(application)
    }

    private func handle(url: URL) {
        Log.send(.info, "Handling shared document", extra: ["filetype": url.pathExtension])

        do {
            _ = url.startAccessingSecurityScopedResource()
            try StorageHelper.handle(url)
            url.stopAccessingSecurityScopedResource()
        } catch let error {
            url.stopAccessingSecurityScopedResource()
            Log.send(.error, "Unable to handle file.", extra: ["filetype": url.pathExtension, "error": error.localizedDescription])
            try? FileManager.default.removeItem(at: url)

            AlertViewModel.createAndPost(message: error, primaryButtonTitle: "OK")
        }
    }
}
