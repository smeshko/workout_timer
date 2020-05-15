import XCTest
@testable import WorkoutCore

class ExerciseSetTests: XCTestCase {
  
  let pushUp = Exercise(title: "Push up")
  let jacks = Exercise(title: "Jumping Jacks")

  func testAlternating() {
    let sets = ExerciseSet.alternating([
      pushUp : 30,
      jacks : 60
    ], count: 2)
    
    let expectedSets = [
      ExerciseSet(exercise: pushUp, duration: 30),
      ExerciseSet(exercise: jacks, duration: 60),
      ExerciseSet(exercise: pushUp, duration: 30),
      ExerciseSet(exercise: jacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expectedSets)
  }
  
  func testBatchWithPause() {
    let sets = ExerciseSet.sets(2, exercise: jacks, duration: 60, pauseInBetween: 15)
    let expected = [
      ExerciseSet(exercise: jacks, duration: 60),
      .recovery(15),
      ExerciseSet(exercise: jacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expected)
  }
  
  func testBatchWithoutPause() {
    let sets = ExerciseSet.sets(2, exercise: jacks, duration: 60)
    let expected = [
      ExerciseSet(exercise: jacks, duration: 60),
      ExerciseSet(exercise: jacks, duration: 60)
    ]
    
    XCTAssertEqual(sets, expected)
  }

}
