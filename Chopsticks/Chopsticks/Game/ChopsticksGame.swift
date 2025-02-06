import SwiftUI

public struct ChopsticksGame {
    var state: GameState

    public init(state: GameState = GameState()) {
        self.state = state
    }

    mutating func attack(from: Bool, to: Bool, isPlayer1Attacking: Bool) {
        // `from` and `to` are booleans indicating left (false) or right (true)
        let attacker = isPlayer1Attacking ? state.player1 : state.player2
        var defender = isPlayer1Attacking ? state.player2 : state.player1


        let attackValue = from ? attacker.rightHand : attacker.leftHand
        if to {
            defender.rightHand = defender.rightHand + attackValue >= 5 ? 0 : defender.rightHand + attackValue
        } else {
            defender.leftHand = defender.leftHand + attackValue >= 5 ? 0 : defender.leftHand + attackValue
        }

        // Update the state with modified players
        if isPlayer1Attacking {
            state.player2 = defender
        } else {
            state.player1 = defender
        }

        state.isPlayer1Turn.toggle()
    }

    
    mutating func transferHands(isPlayer1Turn: Bool, leftNum: Int, rightNum: Int) {
        if isPlayer1Turn {
            state.player1.leftHand = leftNum
            state.player1.rightHand = rightNum
        } else {
            state.player2.leftHand = leftNum
            state.player2.rightHand = rightNum
        }
        state.isPlayer1Turn.toggle()  // Don't forget to toggle the turn!
    }


    mutating func gameOver() -> (Bool, Bool?) {
        if state.player1.leftHand == 0 && state.player1.rightHand == 0{
            return (true, false)
        }
        if state.player2.leftHand == 0 && state.player2.rightHand == 0{
            return (true, true)
        }
        return (false, nil)

    }
}
