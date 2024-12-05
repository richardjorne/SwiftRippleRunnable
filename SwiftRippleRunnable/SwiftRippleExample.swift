//
//  SwiftRippleExample.swift
//  SwiftRippleRunnable
//
//  Created by Richard Jorne on 2024/10/23.
//

import SwiftUI
import SwiftRipple
import AllTouchGestureModifier


struct RippleExamplePreviewProvider: View {
    var body: some View {
        ZStack {
            // SwiftRipple Example
            RippleDiversityExample()
//            HeartRippleExample()
//            CircleExtendExample()
//            CircleExample()
            
            // RippleButton Example
//            RippleButtonExample()
            
            // Pulse Example
//            PulseRippleExample()
//            HoldHeartRippleExample()
//            SwiftRippleExample()
        }
        .multilineTextAlignment(.center)
        .frame(width: 360, height: 400, alignment: .center)
    }
}

fileprivate struct RippleDiversityExample: View {
    
    @State private var allowedArea: CGRect = .zero
    @State private var forbiddenArea: CGRect = .zero
    @State private var pos: CGPoint = .zero
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack {
                        Color.green.opacity(0.6)
                        Text("Allowed to touch")
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .bold))
                    }
                    .onChange(of: geometry.frame(in: .global)) { newValue in
                        allowedArea = geometry.frame(in: .global)
                    }
                }
                GeometryReader { geometry in
                    ZStack {
                        Color.red.opacity(0.6)
                        Text("Forbidden to touch")
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .bold))
                    }
                    .onChange(of: geometry.frame(in: .global)) { newValue in
                        forbiddenArea = geometry.frame(in: .global)
                    }
                }
            }
            .overlay {
                SwiftRipple(ripple: { position in
                    ZStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .foregroundStyle(.green)
                            .frame(width: 50, height: 50, alignment: .center)
                            .opacity(allowedArea.contains(pos) ? 1 : 0)
                        Image(systemName: "xmark")
                            .resizable()
                            .foregroundStyle(.red)
                            .frame(width: 50, height: 50, alignment: .center)
                            .opacity(forbiddenArea.contains(pos) ? 1 : 0)
                    }
                    .onAppear {
                        self.pos = position
                    }
                }, appearDuration: 0.3, disappearDuration: 0.7, ripplePercent: 0.7, disappearApproach: .extendOpacityDisappear)
            }
        }
        .background(.white)
    }
}

fileprivate struct HeartRippleExample: View {
    var body: some View {
        VStack {
            SwiftRipple(ripple: {_ in
                Image(systemName: "heart.fill")
                    .resizable()
                    .foregroundStyle(.red)
                    .frame(width: 50, height: 50, alignment: .center)
            }, appearDuration: 0.3, disappearDuration: 0.7, ripplePercent: 0.7, disappearApproach: .extendOpacityDisappear)
        }
        .background(.white)
    }
}

fileprivate struct CircleExtendExample: View {
    var body: some View {
        VStack {
            SwiftRipple(ripple: {_ in
                Circle()
                    .foregroundStyle(.yellow.opacity(0.6))
            }, appearDuration: 0.3, disappearDuration: 0.7, ripplePercent: 0.4, disappearApproach: .extendOpacityDisappear)
        }
        .background(.white)
    }
}

fileprivate struct CircleExample: View {
    var body: some View {
        VStack {
            SwiftRipple(ripple: {_ in
                Circle()
                    .foregroundStyle(.yellow.opacity(0.6))
            }, appearDuration: 0.3, disappearDuration: 0.7, ripplePercent: 0.4, disappearApproach: .opacityDisappear)
        }
        .background(.white)
    }
}

fileprivate struct RippleButtonExample: View {
    @State var pressing: Bool = false
    @State var n1: Float = 3
    @State var n2: Float = 2
    var body: some View {
        VStack {
            Text("\(String(format: "%.4f", n1))/\(String(format: "%.4f", n2))=\(String(format: "%.4f", n1/n2))")
            RippleButton(content: { pressing, _ in
                Text("Happy \(pressing ? "Impressed " : "Unpressed")")
                    .animation(nil, value: pressing)
                    .padding(.all)
            }, background: { pressing, _ in
                Color(red: 255.0/256.0, green: 158.0/256.0, blue: (pressing ? 105.0 : 11.0)/256.0)
                    .animation(.linear, value: pressing)
                
                if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
                    Color.clear
                        .onChange(of: pressing) { newValue in
                            self.pressing = newValue
                        }
                }
            }, ripple: {_ in
                Color.yellow.opacity(0.6).clipShape(.circle)
            }, action: {_ in
                n1 = Float.random(in: -999...999)
                n2 = Float.random(in: 1...999)
            }, ripplePercent: 0.7)
            .cornerRadius(14)
            .scaleEffect(x: pressing ? 0.94 : 1.0, y: pressing ? 0.94 : 1.0, anchor: .center)
            .animation(.easeInOut(duration: 0.1), value: pressing)
        }
        .frame(width: 300, height: 300, alignment: .center)
    }
}

fileprivate struct PulseRippleExample: View {
    
    enum PulsePreviewType {
        case single
        case ripple
    }
    
    var type: PulsePreviewType = .ripple
    
    @State private var ripples: [RippleParameter] = []
    @State private var timer: Timer?
    @State private var size: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Pulse(ripple: {_,_ in
                    Color.blue.clipShape(.circle).opacity(type == .ripple ? 0.6 : 1.0)
                }, appearAnimation: .timingCurve(0.726, 0.025, 0.124, 0.69, duration: 0.8), disappearAnimation: .spring, defaultRipplePercent: 0.6,ripples: $ripples, allowTouch: true)
                .onAppear {
                    size = geo.size
                    timer?.invalidate()
                    if type == .single {
                        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats:    true) { _ in
                            DispatchQueue.main.async {
                                ripples.append(RippleParameter(pos: CGPoint(x:  size.width/2, y: size.height/2), diameter: -1, isInternal: true))
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.82, repeats:    false) { _ in
                                DispatchQueue.main.async {
                                    ripples.removeFirstInternalRipple()
                                }
                            }
                        }
                    } else if type == .ripple {
                        timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats:    true) { _ in
                            for delay in [0.0,0.15,0.3] {
                                Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                                    DispatchQueue.main.async {
                                        ripples.append(RippleParameter(pos: CGPoint(x:  size.width/2, y: size.height/2), diameter: -1, scale: 1-delay, isInternal: true))
                                    }
                                }
                            }
                            
                            Timer.scheduledTimer(withTimeInterval: 0.8, repeats:    false) { _ in
                                for delay in [0.0,0.1,0.2] {
                                    Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                                        DispatchQueue.main.async {
                                            ripples.removeFirstInternalRipple()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            .frame(width: 300, height: 300, alignment: .center)
            .background(.white)
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
        .background(.white)
    }
}


fileprivate struct HoldHeartRippleExample: View {
    
    @State private var ripples: [RippleParameter] = []
    @State private var timer: Timer?
    @State private var point: CGPoint = .zero
    @State private var holding = false
    @State private var time: Int = 0
    
    var body: some View {
        VStack {
            Pulse(ripple: { _, _ in
                Image(systemName: "heart.fill")
                    .resizable()
                    .foregroundStyle(.red)
                    .frame(width: 50, height: 50, alignment: .center)
            }, appearAnimation: .easeOut, disappearAnimation: .spring(duration: 1.0), defaultRipplePercent: 0.6,ripples: $ripples, allowTouch: false)
            .onAppear {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    ripples.removeFirstExternalRipple()
                    if holding {
                        DispatchQueue.main.async {
                            ripples.append(RippleParameter(pos: point, diameter: -1, scale: 0.3, isInternal: false))
                        }
                    }
                }
            }
        }
        .overlay(content: {
            Color.white.opacity(0.00000001)
                .allTouchGesture { pos in
                    holding = true
                    point = pos
                } onTouchUp: { pos in
                    holding = false
                    point = pos
                } onDragging: { pos in
                    point = pos
                }
            
        })
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .background(.white)
    }
}

fileprivate struct SwiftRippleExample: View {
    
    @State private var ripples: [RippleParameter] = []
    @State private var timer: Timer?
    @State private var point: CGPoint = .zero
    @State private var holding = false
    @State private var time: Int = 0
    @State private var color: Color = .red
    
    var body: some View {
        VStack {
            Pulse(ripple: { _, _ in
                Image(systemName: "heart.fill")
                    .resizable()
                    .foregroundStyle(color)
                    .frame(width: 50, height: 50, alignment: .center)
            }, appearAnimation: .easeOut, disappearAnimation: .spring(duration: 1.0), defaultRipplePercent: 0.6,ripples: $ripples, allowTouch: false)
            .onAppear {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    ripples.removeFirstExternalRipple()
                    if holding {
                        DispatchQueue.main.async {
                            ripples.append(RippleParameter(pos: point, diameter: -1, scale: 0.3, isInternal: false))
                        }
                    } else {
                        color = Color(hue: .random(in: 0...1), saturation: .random(in: 0.3...0.8), brightness: .random(in: 0.6...0.9))
                    }
                }
            }
        }
        .overlay(content: {
            Color.white.opacity(0.00000001)
                .allTouchGesture { pos in
                    holding = true
                    point = pos
                } onTouchUp: { pos in
                    holding = false
                    point = pos
                } onDragging: { pos in
                    point = pos
                }
            
        })
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .background(.white)
    }
}
