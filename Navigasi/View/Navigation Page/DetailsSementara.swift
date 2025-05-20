////
////  DetailsSementara.swift
////  Navigasi
////
////  Created by Akbar Febry on 16/05/25.
////
//
//// Current step indicator
//if !viewModel.routeSteps.isEmpty {
//    VStack(alignment: .leading, spacing: 15) {
//        ForEach(0..<viewModel.routeSteps.count, id: \.self) { index in
//            let step = viewModel.routeSteps[index]
//            HStack(alignment: .top) {
//                Circle()
//                    .fill(index == viewModel.currentStepIndex ? Color.blue : Color.gray)
//                    .frame(width: 10, height: 10)
//                    .padding(.top, 5)
//                
//                VStack(alignment: .leading) {
//                    Text(step.instructions)
//                        .font(.system(size: 14, weight: index == viewModel.currentStepIndex ? .bold : .regular))
//                    
//                    Text("\(step.formattedDistance())")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                }
//            }
//            .opacity(index == viewModel.currentStepIndex ? 1.0 : 0.6)
//        }
//    }
//    .padding(.top, 15)
//}
//} else {
//// Fallback if no route is available
//HStack {
//    Text("5 min")
//        .font(.system(size: 14))
//    
//    Image(systemName: "circle.fill")
//        .font(.system(size: 5))
//    
//    Text("10 m")
//        .font(.system(size: 14))
//}
//}
