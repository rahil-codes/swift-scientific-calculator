import SwiftUI
import Foundation

struct ContentView: View {
    @State private var display = "0"
    @State private var firstNumber: Double?
    @State private var operation: String?
    @State private var waitingForNumber = false
    @State private var memory: Double = 0
    @State private var history: [String] = []
    @State private var showHistory = false
    @State private var isRadianMode = false
    @State private var shakeOffset: CGFloat = 0
    @State private var activeOperation: String? = nil
    @State private var justCalculated = false

    let buttons: [[String]] = [
        ["AC", "±", "%", "÷"],
        ["sin", "cos", "tan", "√"],
        ["MC", "MR", "M−", "M+"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["π", "0", ".", "="],
        ["x²", "xʸ", "RAD", "🕘"]
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 15) {
                HStack {
                    Text(isRadianMode ? "RAD" : "DEG")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())

                    Spacer()

                    if memory != 0 {
                        Text("M: \(formatNumber(memory))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.indigo.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                if showHistory && !history.isEmpty {
                    ScrollView {
                        VStack(alignment: .trailing, spacing: 6) {
                            ForEach(history.suffix(5).reversed(), id: \.self) { entry in
                                Text(entry)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .frame(maxHeight: 120)
                    .transition(.opacity)
                }

                Text(display)
                    .font(.system(size: display.count > 9 ? 40 : 60, weight: .light))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 25)
                    .offset(x: shakeOffset)
                    .animation(.default, value: shakeOffset)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButton(
                                title: button,
                                isActive: button == activeOperation,
                                action: {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    buttonPressed(button)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                }

                Spacer().frame(height: 10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showHistory)
    }

    func buttonPressed(_ button: String) {
        if let number = button.first, number.isNumber {
            if justCalculated {
                firstNumber = nil
                operation = nil
                justCalculated = false
            }
            enterNumber(button)
            activeOperation = nil
            return
        }

        if button == "." {
            enterDecimal()
            return
        }

        switch button {
        case "AC":
            clear()
            activeOperation = nil

        case "±":
            toggleSign()

        case "%":
            percentage()

        case "π":
            display = formatNumber(Double.pi)
            waitingForNumber = true

        case "sin":
            scientificOperation(.sin)

        case "cos":
            scientificOperation(.cos)

        case "tan":
            scientificOperation(.tan)

        case "√":
            scientificOperation(.sqrt)

        case "x²":
            scientificOperation(.square)

        case "xʸ":
            setOperation("^")
            activeOperation = "xʸ"

        case "MC":
            memory = 0

        case "MR":
            display = formatNumber(memory)
            waitingForNumber = true

        case "M+":
            if let value = Double(display) {
                memory += value
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            }

        case "M−":
            if let value = Double(display) {
                memory -= value
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            }

        case "RAD":
            isRadianMode.toggle()

        case "🕘":
            withAnimation {
                showHistory.toggle()
            }

        case "+", "−", "×", "÷":
            setOperation(button)
            activeOperation = button

        case "=":
            calculateResult()
            activeOperation = nil

        default:
            break
        }
    }

    func enterNumber(_ number: String) {
        if waitingForNumber || display == "0" {
            display = number
            waitingForNumber = false
        } else {
            if display.count < 12 {
                display += number
            }
        }
    }

    func enterDecimal() {
        if waitingForNumber {
            display = "0."
            waitingForNumber = false
        } else if !display.contains(".") {
            display += "."
        }
    }

    func clear() {
        display = "0"
        firstNumber = nil
        operation = nil
        waitingForNumber = false
        justCalculated = false
    }

    func toggleSign() {
        guard let value = Double(display) else { return }
        display = formatNumber(-value)
    }

    func percentage() {
        guard let value = Double(display) else { return }
        display = formatNumber(value / 100)
    }

    func scientificOperation(_ op: ScientificOperation) {
        guard let value = Double(display) else { return }
        var result: Double

        switch op {
        case .sin:
            result = isRadianMode ? sin(value) : sin(value * Double.pi / 180)
        case .cos:
            result = isRadianMode ? cos(value) : cos(value * Double.pi / 180)
        case .tan:
            let angle = isRadianMode ? value : value * Double.pi / 180
            if abs(cos(angle)) < 1e-10 {
                triggerError()
                return
            }
            result = tan(angle)
        case .sqrt:
            if value < 0 {
                triggerError()
                return
            }
            result = sqrt(value)
        case .square:
            result = value * value
        }

        let entry = "\(opSymbol(op))(\(display)) = \(formatNumber(result))"
        addToHistory(entry)
        display = formatNumber(result)
        waitingForNumber = true
    }

    func opSymbol(_ op: ScientificOperation) -> String {
        switch op {
        case .sin: return "sin"
        case .cos: return "cos"
        case .tan: return "tan"
        case .sqrt: return "√"
        case .square: return "²"
        }
    }

    func setOperation(_ newOperation: String) {
        guard let value = Double(display) else { return }
        if let first = firstNumber, let op = operation, !waitingForNumber {
            if let second = Double(display) {
                firstNumber = performCalc(first, second, op)
                display = formatNumber(firstNumber!)
            }
        } else {
            firstNumber = value
        }
        operation = newOperation
        waitingForNumber = true
    }

    func calculateResult() {
        guard
            let first = firstNumber,
            let second = Double(display),
            let operation = operation
        else { return }

        if operation == "÷" && second == 0 {
            triggerError()
            return
        }

        let result = performCalc(first, second, operation)
        let entry = "\(formatNumber(first)) \(operation) \(formatNumber(second)) = \(formatNumber(result))"
        addToHistory(entry)

        display = formatNumber(result)
        firstNumber = nil
        self.operation = nil
        waitingForNumber = true
        justCalculated = true
    }

    func performCalc(_ first: Double, _ second: Double, _ op: String) -> Double {
        switch op {
        case "+": return first + second
        case "−": return first - second
        case "×": return first * second
        case "÷": return second == 0 ? 0 : first / second
        case "^": return pow(first, second)
        default: return second
        }
    }

    func triggerError() {
        display = "Error"
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
        withAnimation(.easeInOut(duration: 0.05).repeatCount(5, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeOffset = 0
        }
    }

    func addToHistory(_ entry: String) {
        history.append(entry)
        if history.count > 20 {
            history.removeFirst()
        }
    }

    func formatNumber(_ number: Double) -> String {
        if number.isNaN || number.isInfinite { return "Error" }
        if number.truncatingRemainder(dividingBy: 1) == 0 && abs(number) < 1e15 {
            return String(format: "%.0f", number)
        }
        let formatted = String(format: "%.8f", number)
        var result = formatted
        if result.contains(".") {
            while result.hasSuffix("0") { result.removeLast() }
            if result.hasSuffix(".") { result.removeLast() }
        }
        return result
    }
}

enum ScientificOperation {
    case sin, cos, tan, sqrt, square
}

struct CalculatorButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.05)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
            }
            action()
        }) {
            Text(title)
                .font(.system(size: title.count > 2 ? 18 : 24, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 65)
                .background(isActive ? buttonColor.opacity(0.5) : buttonColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .scaleEffect(isPressed ? 0.93 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isActive ? Color.white.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
        }
    }

    var buttonColor: Color {
        switch title {
        case "AC", "±", "%": return Color.gray.opacity(0.7)
        case "÷", "×", "−", "+", "=": return Color.blue
        case "sin", "cos", "tan", "√", "x²", "xʸ", "π": return Color.indigo
        case "MC", "MR", "M+", "M−": return Color.purple.opacity(0.8)
        case "RAD": return Color.teal.opacity(0.8)
        case "🕘": return Color.gray.opacity(0.5)
        default: return Color(.darkGray)
        }
    }
}

#Preview {
    ContentView()
}
