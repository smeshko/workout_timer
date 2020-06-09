import UIKit
import SwiftUI

struct UITabBarWrapper: View {
    var controllers: [UIHostingController<TabBarElement>]
    @Binding var isBarHidden: Bool
    
    init(_ elements: [TabBarElement], isBarHidden: Binding<Bool>) {
        self.controllers = elements.enumerated().map {
            let hostingController = UIHostingController(rootView: $1)
            
            hostingController.tabBarItem = UITabBarItem(
                title: $1.tabBarElementItem.title,
                image: UIImage(systemName: $1.tabBarElementItem.systemImageName),
                tag: $0
            )
            
            return hostingController
        }
        self._isBarHidden = isBarHidden
    }
    
    var body: some View {
        UITabBarControllerWrapper(viewControllers: self.controllers, isBarHidden: $isBarHidden) // 5
    }
}

struct UITabBarWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UITabBarWrapper([
            TabBarElement(tabBarElementItem:
                TabBarElementItem(title: "Test 1", systemImageName: "house.fill")) {
                    Text("Test 1 Text")
            }
        ], isBarHidden: .constant(false))
    }
}

struct TabBarElementItem {
    var title: String
    var systemImageName: String
}

protocol TabBarElementView: View {
    associatedtype Content
    
    var content: Content { get set }
    var tabBarElementItem: TabBarElementItem { get set }
}

struct TabBarElement: TabBarElementView { // 1
    internal var content: AnyView // 2
    
    var tabBarElementItem: TabBarElementItem
    
    init<Content: View>(tabBarElementItem: TabBarElementItem, // 3
         @ViewBuilder _ content: () -> Content) { // 4
        self.tabBarElementItem = tabBarElementItem
        self.content = AnyView(content()) // 5
    }
    
    var body: some View { self.content } // 6
}

struct TabBarElement_Previews: PreviewProvider {
    static var previews: some View {
        TabBarElement(tabBarElementItem: .init(title: "Test", systemImageName: "house.fill")) {
            Text("Hello, world!")
        }
    }
}

// 1
fileprivate struct UITabBarControllerWrapper: UIViewControllerRepresentable {
    var viewControllers: [UIViewController]
    
    @Binding var isBarHidden: Bool
    
    // 2
    func makeUIViewController(context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) -> UITabBarController {
        let tabBar = UITabBarController()
        return tabBar
    }
    
    // 3
    func updateUIViewController(_ uiViewController: UITabBarController, context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) {
        uiViewController.setViewControllers(self.viewControllers, animated: true)
        uiViewController.tabBar.isHidden = isBarHidden
    }
    
    // 4
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: UITabBarControllerWrapper
        
        init(_ controller: UITabBarControllerWrapper) {
            self.parent = controller
        }
    }
}
