import SwiftUI

struct Player {
    var leftHand: Int
    var rightHand: Int
}

struct GameState {
    var player1: Player
    var player2: Player
    var isPlayer1Turn: Bool
}

struct ChopsticksGame {
    var state: GameState

    mutating func attack(from: Bool, to: Bool, isPlayer1Attacking: Bool) {
        // `from` and `to` are booleans indicating left (false) or right (true)
        var attacker = isPlayer1Attacking ? state.player1 : state.player2
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



struct ChopsticksGameView: View {
    @State private var game = ChopsticksGame(state: GameState(
        player1: Player(leftHand: 1, rightHand: 1),
        player2: Player(leftHand: 1, rightHand: 1),
        isPlayer1Turn: true
    ))
    @State private var selectedAttackingHand: (isRight: Bool, player: Bool)? = nil
    @State private var isGameOver = GameOverState(isOver: false, isPlayer1Winner: nil)
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
            
            if let selected = selectedAttackingHand {
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
        .alert("Game Over!", isPresented: $isGameOver.isOver) {
            Button("Rematch") {
                game = ChopsticksGame(state: GameState(
                    player1: Player(leftHand: 1, rightHand: 1),
                    player2: Player(leftHand: 1, rightHand: 1),
                    isPlayer1Turn: true
                ))
                isGameOver = GameOverState(isOver: false, isPlayer1Winner: nil)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(isGameOver.isPlayer1Winner == true ? "Player 1 Wins!" : "Player 2 Wins!")
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
                    isGameOver = GameOverState(isOver: isOver, isPlayer1Winner: winner)
                    
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
            if leftNum >= 0 && leftNum < 5 && rightNum >= 0 && rightNum < 5 && (leftNum + rightNum) == playerLeftHand + playerRightHand {
                game.transferHands(isPlayer1Turn: isPlayer1, leftNum: leftNum, rightNum: rightNum)
                let (isOver, winner) = game.gameOver()
                isGameOver = GameOverState(isOver: isOver, isPlayer1Winner: winner)
            } else {
                transferError = true
            }
            
        }
        selectedAttackingHand = nil

}
}

struct PlayerView: View {
    // @State private var leftHandInput: String = ""
    // @State private var rightHandInput: String = ""
    // @State private var isPromptingLeftHand: Bool = false
    // @State private var isPromptingRightHand: Bool = false
    
    let player: Player
    let isFlipped: Bool
    let isCurrentPlayer: Bool
    let handleHandSelection: (Bool) -> Void
    let selectedAttackingHand: (isRight: Bool, player: Bool)?
    let transferFunc: (Int, Int) -> Void

    @State private var showingInputSheet = false
    @State private var leftHandInput: String = ""
    @State private var rightHandInput: String = ""
    
    var body: some View {
        HStack(spacing: 20) {
            HandView(
                fingers: player.leftHand,
                isCurrentPlayer: isCurrentPlayer,
                handleTap: { handleHandSelection(false) },
                selectedHand: selectedAttackingHand != nil && isCurrentPlayer && !selectedAttackingHand!.isRight
            )
            
            
            Button(action: {
                if isCurrentPlayer {
                    showingInputSheet = true
                }
            }) {
                Image(systemName:"arrow.left.arrow.right")
            }
            .opacity(isCurrentPlayer ? 1.0 : 0.3)
            .sheet(isPresented: $showingInputSheet) {
                NavigationView {
                    VStack {
                        HStack {
                            VStack {
                                Text("Left Hand")
                                    .font(.caption)
                                TextField("0", text: $leftHandInput)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .multilineTextAlignment(.center)
                            }
                            
                            VStack {
                                Text("Right Hand")
                                    .font(.caption)
                                TextField("0", text: $rightHandInput)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        
                        Button("Submit") {
                            if let leftNum = Int(leftHandInput), let rightNum = Int(rightHandInput) {
                                transferFunc(leftNum,rightNum)
                            }
                            showingInputSheet = false
                        }
                        .padding()
                    }
                    .navigationTitle("Transfer Fingers")
                    .navigationBarItems(trailing: Button("Cancel") {
                        showingInputSheet = false
                    })
                }
                .frame(height: 200)
            }
            
            
            HandView(
                fingers: player.rightHand,
                isCurrentPlayer: isCurrentPlayer,
                handleTap: { handleHandSelection(true) },
                selectedHand: selectedAttackingHand != nil && isCurrentPlayer && selectedAttackingHand!.isRight
            )
            
        }
        .rotationEffect(isFlipped ? .degrees(180) : .degrees(0))
    }
}

struct HandView: View {
    let fingers: Int
    let isCurrentPlayer: Bool
    let handleTap: () -> Void
    let selectedHand: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.001)) // Add invisible fill to capture taps
                .frame(width: 60, height: 60)
            
            Circle()
                .stroke((isCurrentPlayer && selectedHand) ? Color.red : (isCurrentPlayer ? Color.blue : Color.gray), lineWidth: 2)
                .frame(width: 60, height: 60)
            
            Text("\(fingers)")
                .font(.title)
                .rotationEffect(.degrees(0))
        }
        .opacity(fingers == 0 ? 0.5 : 1.0)
        .contentShape(Circle()) // Explicitly set the tap area
        .onTapGesture {
            handleTap()
        }
    }
}

struct GameOverState {
    var isOver: Bool
    var isPlayer1Winner: Bool?
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
