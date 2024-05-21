//
//  OnboardingView.swift
//  Meteor
//
//  Created by 장기화 on 5/4/24.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @State private var scale: CGFloat = 1
    @State private var isPresent = false
    var dismissAction: (() -> Void)?
    
    var body: some View {
        OnboardingContentView(scale: $scale)
            .onAppear {
                Task {
                    try await Task.sleep(for: .seconds(0.5))
                    withAnimation(.default.speed(0.7)) {
                        scale = 0.4
                        isPresent = true
                    }
                }
            }
        if isPresent {
            OnboardingContinueButtonView(viewModel: viewModel)
        }
    }
}

struct OnboardingContentView: View {
    @Binding var scale: CGFloat
    
    var body: some View {
        ScrollView {
            OnboardingImageView(scale: $scale)
                .frame(height: 900 * scale - 50)
                .clipped()
            
            Spacer(minLength: 28)
            
            Text("Get Started")
                .font(.system(size: 32, weight: .bold))
            
            Spacer(minLength: 16)
            
            Text("Take a Note at the Nearest Place.")
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal, 28)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 24)
            
            VStack(alignment: .leading, spacing: 20) {
                OnboardingDescriptionView(
                    systemName: "clock.badge",
                    title: "Three Ways of Notification",
                    description: "Immediately, Specified Time Interval or using ‘Live Activity’ to display notifications on the Lock Screen or Notification Center.",
                    primaryColor: .red,
                    secondaryColor: .primary
                )
                
                OnboardingDescriptionView(
                    systemName: "bubble.left.and.exclamationmark.bubble.right.fill",
                    title: "Get What's Important",
                    description: "Time Sensitive notifications are always delivered immediately and remain on the Lock Screen for an hour.",
                    primaryColor: .yellow,
                    secondaryColor: .primary
                )
            }
        }
    }
}

struct OnboardingImageView: View {
    @State private var notificationViewScale: CGFloat = 1
    @Binding var scale: CGFloat
    private let colorList: [Color] = [.red, .black, .secondary]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.secondary.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
            RoundedRectangle(cornerRadius: 32)
                .frame(width: 400 * scale, height: 700 * scale)
                .opacity(0.2)
                .offset(x: 0, y: 100 * scale)
            
            VStack(spacing: 6) {
                Text("9:41")
                    .font(.system(size: 100 * scale, weight: .semibold))
                    .foregroundStyle(.white).opacity(0.5)
                
                ForEach(colorList, id: \.self) { color in
                    OnboardingNotificationView(scale: $scale, color: color)
                        .frame(width: 370 * scale, height: 120 * scale)
                        .scaleEffect(notificationViewScale)
                        .onAppear {
                            withAnimation(.spring.delay(0.3).speed(0.5)
                                .repeatForever(autoreverses: true)) {
                                    notificationViewScale = 0.9
                                }
                        }
                }
            }
            .offset(x: 0, y: 100 * scale)
        }
    }
}

struct OnboardingNotificationView: View {
    @Binding var scale: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(color.opacity(0.7))
            HStack {
                VStack(alignment: .leading, spacing: 20 * scale) {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(maxWidth: 100 * scale, maxHeight: 16 * scale)
                    RoundedRectangle(cornerRadius: 3)
                        .frame(maxWidth: 200 * scale, maxHeight: 16 * scale)
                }
                .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
            }
            .offset(x: 10, y: 0)
        }
    }
}

struct OnboardingDescriptionView: View {
    let systemName: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let primaryColor: Color
    let secondaryColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 32)
                .foregroundStyle(primaryColor, secondaryColor)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(description)
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                    .lineSpacing(2)
            }
        }
        .padding(.leading, 32)
        .padding(.trailing, 32)
    }
}

struct OnboardingContinueButtonView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.requestAuth()
                dismiss()
            }
        } label: {
            HStack {
                Spacer()
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(8)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .padding(.horizontal, 24)
        .padding(.top, 20)
//        .navigationDestination(isPresented: $viewModel.isPresented) {
//            OnboardingTabView(dismissAction: dismissAction ?? {} )
//        }
        
        Spacer(minLength: 52)
    }
}

//struct OnboardingTabView: View {
//    var dismissAction: (() -> Void)?
//
//    var body: some View {
//        TabView {
//            ForEach(0..<3) { index in
////                switch index {
////                case 0 :
////
////                default:
//                    Text("\(index)")
////                }
//            }
//        }
//        .tabViewStyle(.page)
//        .indexViewStyle(.page(backgroundDisplayMode: .always))
//        .navigationBarBackButtonHidden()
////        .navigationTitle("Start to Meteor")
//        .toolbar {
//            Button {
//                dismissAction?()
////                isPresented = false
//            } label: {
//                Text("건너뛰기")
//                    .foregroundStyle(.orange)
//            }
//        }
//    }
//}

#Preview {
    OnboardingView()
        .environment(OnboardingViewModel())
}
