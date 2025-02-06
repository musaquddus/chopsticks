import SwiftUI
struct ChopsticksGameView: View {
    @State private var game = ChopsticksGame()
    @State private var selectedAttackingHand: (isRight: Bool, player: Bool)? = nil
    @State private var isGameOver = false
    @State private var gameWinner: Bool? = nil
    @State private var transferError: Bool = false

    var body: some View {
        VStack(spacing: 50) {
            PlayerView(
                player: game.state.player2,
                isFlipped: true,
                isCurrentPlayer: !game.state.isPlayer1Turn,
                handleHandSelection: { isRightHand in
                    handleTap(isRightHand: isRightHand, isPlayer1: false)
                },
                selectedAttackingHand: selectedAttackingHand,
                transferFunc: { leftNum, rightNum in 
                    handleTransfer(isPlayer1: false, leftNum: leftNum, rightNum: rightNum)
                }
            )
            
            Text(game.state.isPlayer1Turn ? "Player 1's Turn" : "Player 2's Turn")
                .font(.title)
            
            if selectedAttackingHand != nil {
                Text("Select a hand to attack")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            PlayerView(
                player: game.state.player1,
                isFlipped: false,
                isCurrentPlayer: game.state.isPlayer1Turn,
                handleHandSelection: { isRightHand in
                    handleTap(isRightHand: isRightHand, isPlayer1: true)
                },
                selectedAttackingHand: selectedAttackingHand,
                transferFunc: { leftNum, rightNum in 
                    handleTransfer(isPlayer1: true, leftNum: leftNum, rightNum: rightNum)
                }
            )
        }
        .alert(isPresented: $transferError){ 
            let player = game.state.isPlayer1Turn ? game.state.player1 : game.state.player2
            let currentTotal = player.leftHand + player.rightHand
            return Alert(
                title: Text("Invalid Transfer!"),
                message: Text("The sum of your hands must equal \(currentTotal)"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Game Over!", isPresented: $isGameOver) {
            Button("Rematch") {
                game = ChopsticksGame(state: GameState())
                isGameOver = false
                gameWinner = nil
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(gameWinner == true ? "Player 1 Wins!" : "Player 2 Wins!")
        }
        .padding()
    }

    
    private func handleTap(isRightHand: Bool, isPlayer1: Bool) {
        // If there's a selected hand
        if let selected = selectedAttackingHand {
            // If it's an attacking player's turn
            if (game.state.isPlayer1Turn && selected.player) || (!game.state.isPlayer1Turn && !selected.player) {
                // If tapping the defending player's hand
                if isPlayer1 != selected.player {
                    game.attack(from: selected.isRight, to: isRightHand, isPlayer1Attacking: selected.player)
                    selectedAttackingHand = nil
                    let (isOver, winner) = game.gameOver()
                    isGameOver = isOver
                    gameWinner = winner
                    
                } else {
                    selectedAttackingHand = (isRightHand, isPlayer1)
                }
            }
            
        } else {
            // If it's the current player's turn and they're selecting their hand
            if (game.state.isPlayer1Turn && isPlayer1) || (!game.state.isPlayer1Turn && !isPlayer1) {
                if (isPlayer1 && game.state.player1.leftHand > 0 && !isRightHand) ||
                   (isPlayer1 && game.state.player1.rightHand > 0 && isRightHand) ||
                   (!isPlayer1 && game.state.player2.leftHand > 0 && !isRightHand) ||
                   (!isPlayer1 && game.state.player2.rightHand > 0 && isRightHand) {
                    selectedAttackingHand = (isRightHand, isPlayer1)
                }
            }
        }
    }

    private func handleTransfer(isPlayer1: Bool, leftNum: Int, rightNum: Int) {
        if isPlayer1 && game.state.isPlayer1Turn || !isPlayer1 && !game.state.isPlayer1Turn{
            let currentPlayer = isPlayer1 ? game.state.player1 : game.state.player2
            let playerLeftHand = currentPlayer.leftHand
            let playerRightHand = currentPlayer.rightHand
            //Checking the entered values are valid numbers
            if leftNum >= 0 && leftNum < 5 && rightNum >= 0 && rightNum < 5 && (leftNum + rightNum) == playerLeftHand + playerRightHand &&
            playerLeftHand != leftNum{
                game.transferHands(isPlayer1Turn: isPlayer1, leftNum: leftNum, rightNum: rightNum)
                let (isOver, winner) = game.gameOver()
                isGameOver = isOver
                gameWinner = winner
            } else {
                transferError = true
            }
            
        }
        selectedAttackingHand = nil

}
}


struct ChopsticksGameView_Previews: PreviewProvider {
    static var previews: some View {
        ChopsticksGameView()
            .frame(width: 300, height: 400)
    }
}

@main
struct ChopsticksApp: App {
    var body: some Scene {
        WindowGroup {
            ChopsticksGameView()
        }
    }
}
