import SwiftUI

public struct GameState {
    public var player1: Player
    public var player2: Player
    public var isPlayer1Turn: Bool

    public init(player1: Player = Player(), player2: Player = Player(), isPlayer1Turn: Bool = true) {
        self.player1 = player1
        self.player2 = player2
        self.isPlayer1Turn = isPlayer1Turn
    }
}
