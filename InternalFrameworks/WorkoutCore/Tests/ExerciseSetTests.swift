import XCTest
@testable import WorkoutCore

class ExerciseSetTests: XCTestCase {

  func testAlternating() {
    let sets = ExerciseSet.alternating(2, [
      .pushUps : 30,
      .jumpingJacks : 60
    ])
    
    let expectedSets = [
      ExerciseSet(exercise: .pushUps, duration: 30),
      ExerciseSet(exercise: .jumpingJacks, duration: 60),
      ExerciseSet(exercise: .pushUps, duration: 30),
      ExerciseSet(exercise: .jumpingJacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expectedSets)
  }
  
  func testBatchWithPause() {
    let sets = ExerciseSet.sets(2, exercise: .jumpingJacks, duration: 60, pauseInBetween: 15)
    let expected = [
      ExerciseSet(exercise: .jumpingJacks, duration: 60),
      .recovery(15),
      ExerciseSet(exercise: .jumpingJacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expected)
  }
  
  func testBatchWithoutPause() {
    let sets = ExerciseSet.sets(2, exercise: .jumpingJacks, duration: 60)
    let expected = [
      ExerciseSet(exercise: .jumpingJacks, duration: 60),
      ExerciseSet(exercise: .jumpingJacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expected)
  }

}
