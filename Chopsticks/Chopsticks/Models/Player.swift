public struct Player {
    public var leftHand: Int
    public var rightHand: Int
    
    public init?(leftHand: Int, rightHand: Int) {
        guard (0...4).contains(leftHand), (0...4).contains(rightHand) else{ return nil } 
        self.leftHand = leftHand
        self.rightHand = rightHand
    }
    
    public init() {
        self.leftHand = 1
        self.rightHand = 1
    }
}
