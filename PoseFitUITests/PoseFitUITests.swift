
import XCTest

final class PoseFitUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
      
        continueAfterFailure = false
        app.launch()

       
    }

    override func tearDownWithError() throws {
     
    }
    
  
    

   
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
 
    
    func testNavigationFromHomeToInWorkoutAndBack() throws {
        
      
        app.staticTexts["Fekvőtámasz"].tap()
           app.buttons["Edzés indítása"].tap()
           XCTAssertTrue(app.buttons["Befejezés"].exists, "Az InWorkoutView nem jelenik meg.")

          
           app.buttons["Befejezés"].tap()
           XCTAssertTrue(app.buttons["Edzés indítása"].exists, "A HomeView nem jelenik meg a Befejezés után.")
       }
   
}
