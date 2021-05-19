//
//  RefreshableScrollView.swift
//  iOS
//
//  Created by Chris Hodge on 7/20/20.
//

// This article helped me a lot: https://swiftui-lab.com/scrollview-pull-to-refresh/ Thanks!

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var frozen: Bool = false
    @State private var rotation: Angle = .degrees(0)
    @State private var spokes: Int = 0
    
    var threshold: CGFloat = 80
    @Binding var refreshing: Bool
    @Binding var scrollTarget: Int?
    @Binding var scrollTargetTop: Int?
    let content: Content

    init(height: CGFloat = 80, refreshing: Binding<Bool>, scrollTarget: Binding<Int?>, scrollTargetTop: Binding<Int?>, @ViewBuilder content: () -> Content) {
        self.threshold = height
        self._refreshing = refreshing
        self._scrollTarget = scrollTarget
        self._scrollTargetTop = scrollTargetTop
        self.content = content()
    }
    
    var body: some View {
        return VStack {
            ScrollView {
              ScrollViewReader { scrollProxy in
                ZStack(alignment: .top) {
                    MovingView()
                    
                    LazyVStack { self.content }
                    .alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen) ? -self.threshold : 0.0 })
                    .onChange(of: scrollTarget) { target in
                        if let target = target {
                            self.scrollTarget = nil
                            withAnimation {
                                scrollProxy.scrollTo(target)
                            }
                        }
                    }
                    .onChange(of: scrollTargetTop) { targetTop in
                        if let targetTop = targetTop {
                            self.scrollTargetTop = nil
                            withAnimation {
                                scrollProxy.scrollTo(targetTop, anchor: .top)
                            }
                        }
                    }
                    .onReceive(chatStore.$scrollTargetThread) { target in
                        scrollProxy.scrollTo(target)
                    }
                    .onReceive(chatStore.$scrollTargetThreadTop) { targetTop in
                        scrollProxy.scrollTo(targetTop, anchor: .top)
                    }
                    
                    ProgressViewIndicator(height: self.threshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation, spokes: self.spokes)
                }
              }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            if self.scrollOffset < 6.0 {
                self.spokes = 0
            } else {
                let spokePercent = self.scrollOffset / self.threshold
                self.spokes = Int(8.0 * spokePercent)
            }
            
            if !self.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
                self.refreshing = true
                #if os(iOS)
                haptic(type: .success)
                #endif
            }
            
            if self.refreshing {
                if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
                    self.frozen = true
                }
            } else {
                self.frozen = false
            }
            
            self.previousScrollOffset = self.scrollOffset
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            let h = Double(self.threshold)
            let d = Double(scrollOffset)
            let v = max(min(d - (h * 0.6), h * 0.4), 0)
            return .degrees(180 * v / (h * 0.4))
        }
    }
    
    struct ProgressViewIndicator: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var rotation: Angle
        var spokes: Int

        @State var spokeCount = 0
        
        private func width(_ proxy: GeometryProxy) -> CGFloat {
            minDimension(proxy) * 0.105
        }
        
        private func height(_ proxy: GeometryProxy) -> CGFloat {
            (minDimension(proxy) / 2) - (minDimension(proxy) * 0.2)
        }
        
        internal func minDimension(_ proxy: GeometryProxy) -> CGFloat {
            min(proxy.size.width, proxy.size.height)
        }
        
        internal func maxDimension(_ proxy: GeometryProxy) -> CGFloat {
            max(proxy.size.width, proxy.size.height)
        }
        
        var body: some View {
            Group {
                if self.loading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }.frame(height: height).fixedSize()
                        .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
                } else {
                    HStack {
                        GeometryReader { proxy in
                            ForEach(0...spokes, id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .cornerRadius(2)
                                        .frame(width: self.width(proxy),
                                               height: self.height(proxy))
                                        .position(x: proxy.frame(in: .local).midX,
                                                  y: proxy.frame(in: .local).minY + (self.height(proxy) / 2))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .opacity(0.8)
                                .rotationEffect(.radians(2 * Double.pi * (Double(index) / 8)))
                            }
                        }
                        .frame(width: 20, height: 20)
                    }
                    .padding(.top, height * 0.375)
                    .offset(y: -height + (loading && frozen ? +height : 0.0))
                }
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }

    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            /*
            for val in nextValue() {
                if !value.contains(val) {
                    value.append(val)
                }
            }
            */
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

struct MovingView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
        }.frame(height: 0)
    }
}

struct FixedView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
        }
    }
}
