//
//  TimeRemainingIndicator.swift
//  shackchatty
//
//  Created by Chris Hodge on 4/16/20.
//  Copyright © 2020 Chris Hodge. All rights reserved.
//

import SwiftUI

struct TimeRemainingIndicator: View {
    @Binding var percent: Double
    
    var body: some View {
        return drawRing()
    }
    
    private func drawRing() -> some View{
        return ZStack(alignment: .top) {
            TimeRemainingIndicatorShape(percent: 100)
                .stroke(style: StrokeStyle(lineWidth: 3))
                .fill(Color.gray.opacity(0.2))
            TimeRemainingIndicatorShape(percent: self.percent)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: CGLineCap.round))
                .fill(
                    LinearGradient(
                        gradient: .init(colors: [Color.gray, Color.gray]), startPoint: .init(x: 0.2, y: 0.4), endPoint:  .init(x: 0.5, y: 1)
                    )
            )
        }
    }
}

struct TimeRemainingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        TimeRemainingIndicator(percent: .constant(50))
    }
}

struct TimeRemainingIndicatorShape: Shape {
    var percent: Double
    var radius: CGFloat = 100
    
    var animatableData: Double{
        get{
            return percent
        }
        
        set{
            percent = newValue
        }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let endAngle = Angle(degrees: ( percent / 100 * 360) - 90)
        let radius = width / 2
        
        return Path{ path in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: -90.0) , endAngle: endAngle, clockwise: false)
        }
    }
}
