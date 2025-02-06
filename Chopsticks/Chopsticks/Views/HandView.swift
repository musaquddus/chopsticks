import SwiftUI
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
