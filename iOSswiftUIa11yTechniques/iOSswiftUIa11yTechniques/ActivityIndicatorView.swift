import SwiftUI

struct ActivityRing: View {
    var percentage: CGFloat
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment:.center) {
                Circle()
                   .trim(from: 0.0, to: CGFloat(min(percentage, 100)) / 100)
                   .stroke(AngularGradient(gradient: Gradient(colors: [.blue]), center:.center), lineWidth: 10)
                   .rotationEffect(.degrees(-90))
                
            }
           .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .accessibilityLabel("Calories Burned")
        .accessibilityValue(String(format: "%.0f", percentage)) // Convert CGFloat to String
    }
}

struct ActivityIndicatorView: View {
    @State private var percentage = 75.0
    
    var body: some View {
        ActivityRing(percentage: percentage)
           .frame(width: 200, height: 200)
           .padding()
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView()
    }
}
