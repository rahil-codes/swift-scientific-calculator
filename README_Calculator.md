# Calculator App 🧮

A fully-featured scientific calculator built with Swift and SwiftUI. Clean, dark-themed iOS calculator with memory functions, calculation history, haptic feedback, and radian/degree mode toggle.

## Screenshots
<!-- Add your simulator screenshots here -->

## Features

### Core Calculator
- Basic arithmetic — addition, subtraction, multiplication, division
- Decimal support with input validation
- Sign toggle (±) and percentage (%)
- Division by zero protection with error handling
- Chained calculations — pressing an operator after a result continues the chain correctly
- 12-digit input cap to prevent overflow

### Scientific Functions
- Trigonometric — sin, cos, tan (with undefined angle detection e.g. tan 90°)
- Square root (√) with negative number protection
- Power functions — x² (square) and xʸ (custom exponent)
- Pi (π) constant
- RAD/DEG mode toggle — switch between radian and degree input for all trig functions

### Memory Functions
| Button | Action |
|--------|--------|
| MC | Clear memory |
| MR | Recall memory to display |
| M+ | Add current display value to memory |
| M− | Subtract current display value from memory |

Memory indicator badge appears in the top right when memory holds a non-zero value.

### Calculation History
- Tap the 🕘 button to show/hide the last 5 calculations
- Stores up to 20 entries internally
- Shows both scientific operations and arithmetic results
- Displayed in reverse order — most recent at top

### UX & Animations
- Haptic feedback on every button press (light impact)
- Success haptic when storing to memory (M+/M−)
- Error haptic on invalid operations (divide by zero, √ of negative, tan undefined)
- Shake animation on the display when an error occurs
- Button press scale animation for tactile feel
- Active operator highlights with a white border so you always know what operation is pending
- Smooth history panel slide animation
- Dynamic font sizing — display text shrinks automatically for long numbers

## Tech Stack
- Swift 5
- SwiftUI
- UIKit (UIImpactFeedbackGenerator, UINotificationFeedbackGenerator)
- Foundation

## Project Structure
```
Calculator/
├── ContentView.swift    — Main view, all calculator logic and state
└── CalculatorButton.swift — Reusable button component (embedded in ContentView)
```

## How to Run
1. Clone the repository
```bash
git clone https://github.com/rahil-codes/calculator-app.git
```
2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode
3. Select a simulator (iPhone 15 or later recommended)
4. Press **Cmd + R** to build and run

## Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

## What I Learned
- SwiftUI state management with `@State` for complex multi-variable UI
- Haptic feedback using `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
- Animation chaining with `withAnimation` and `DispatchQueue.main.asyncAfter`
- Edge case handling in calculators — chained operations, undefined trig values, floating point formatting
- Building reusable SwiftUI components with dynamic styling
- Clean number formatting — removing trailing zeros without breaking decimal precision

## Author
**Rahil** — [github.com/rahil-codes](https://github.com/rahil-codes)
