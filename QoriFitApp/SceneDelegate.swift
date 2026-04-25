import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let token = UserDefaults.standard.string(forKey: "user_jwt")
        let rootViewController: UIViewController
        
        if token != nil && !token!.isEmpty {
            // CASO 1: USUARIO CON SESIÓN (Cargamos del Storyboard "Home")
            let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
            rootViewController = homeStoryboard.instantiateViewController(withIdentifier: "MainHomeViewController")
        } else {
            // CASO 2: USUARIO SIN SESIÓN (Cargamos del Storyboard "Main")
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController")
        }
        
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Guardamos el contexto de Core Data si es necesario al pasar a segundo plano
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    // El resto de métodos los puedes dejar vacíos por ahora para mantener el archivo limpio
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
}
