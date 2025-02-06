import SwiftUI
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
                            leftHandInput = ""
                            rightHandInput = ""
                        }
                        .padding()
                    }
                    .navigationTitle("Transfer Fingers")
                    .navigationBarItems(trailing: Button("Cancel") {
                        showingInputSheet = false
                    })
                }
                .presentationDetents([.height(200)])
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
