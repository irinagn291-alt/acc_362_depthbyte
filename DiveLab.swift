import SwiftUI

struct DiveLab: View {
    @EnvironmentObject private var log: DiveLog
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var still
    let dive: Dive
    @State private var state: Checkpoint
    @State private var complete = false
    @State private var fullProgram = false
    @State private var newPart = false
    @State private var replay = false

    init(dive: Dive, checkpoint: Checkpoint) {
        self.dive = dive
        #if DEBUG && targetEnvironment(simulator)
        if CaptureLaunch.enabled && dive.id == 1 {
            if CaptureLaunch.screen == "dive-briefing" {
                _fullProgram = State(initialValue: true)
            } else if CaptureLaunch.screen == "dive-complete" {
                var finished = Checkpoint()
                finished.phase = 1
                finished.choice = dive.answer(for: 1)
                finished.checked = true
                _state = State(initialValue: finished)
                _complete = State(initialValue: true)
                return
            }
        }
        #endif
        _state = State(initialValue: checkpoint)
    }

    private var correct: Bool { state.choice == dive.answer(for: state.phase) }
    private var actionText: String {
        if complete { return "Return to bridge" }
        if state.phase < 0 { return "Enter test chamber" }
        if !state.checked { return state.phase == 0 ? "Check prediction" : "Test repair" }
        if !correct { return "Adjust answer" }
        return state.phase == 0 ? "Open repair bench" : "Log dive"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.down").font(.body.bold()).frame(width: 42, height: 42)
                        .consolePlate(Sea.panel, radius: 21)
                }.buttonStyle(.plain).accessibilityLabel("Surface and save")
                VStack(alignment: .leading, spacing: 5) {
                    Plate(String(format: "Dive %03d / %@", dive.id, dive.sector.name), Sea.foam)
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Rectangle().fill(complete || i <= state.phase + 1 ? Sea.foam : Sea.rim).frame(height: 3)
                        }
                    }
                }
                Image(systemName: dive.sector.icon).foregroundStyle(Sea.gold)
            }.padding(.vertical, 6)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if complete { recovery }
                    else if state.phase < 0 { briefing }
                    else { exercise }
                }.padding(.vertical, 12).frame(maxWidth: .infinity, alignment: .leading)
            }.id(complete ? 3 : state.phase)
            if state.checked && !complete {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: correct ? "checkmark.seal.fill" : "wrench.adjustable.fill")
                        .foregroundStyle(correct ? Sea.foam : Sea.gold)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(correct ? "Signal confirmed" : "Nori’s repair note").font(.subheadline.bold())
                        Text(correct ? (state.phase == 0 ? "The console prints " + dive.output + "." : "The restored program matches the target.") : dive.briefing)
                            .font(.footnote).foregroundStyle(Sea.muted)
                    }
                    Spacer(minLength: 0)
                }.padding(10).consolePlate().padding(.top, 4)
            }
            ConsoleButton(actionText, icon: complete ? "arrow.uturn.left" : "arrow.right",
                          enabled: complete || state.phase < 0 || state.choice != nil, action: advance)
                .padding(.vertical, 6).accessibilityIdentifier("lab-action")
        }.padding(.horizontal, 18).frame(maxWidth: 690).frame(maxWidth: .infinity)
            .foregroundStyle(Sea.paper).background(Sea.deep.ignoresSafeArea())
            .sensoryFeedback(.success, trigger: state.checked && correct)
    }

    @ViewBuilder private var briefing: some View {
        Plate("Dive briefing", Sea.coral)
        Display(dive.title, 36)
        HStack(alignment: .center, spacing: 11) {
            Nori().frame(width: 65, height: 75)
            VStack(alignment: .leading, spacing: 4) {
                Plate("Nori / Engineering", Sea.gold)
                Text(dive.briefing).font(.subheadline).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading).consolePlate()
        Button {
            fullProgram.toggle()
        } label: {
            HStack {
                Text(fullProgram ? "Show lesson excerpt" : "Show complete program")
                Spacer()
                Image(systemName: fullProgram ? "chevron.up" : "chevron.down")
            }.font(.subheadline.bold()).frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(Sea.foam).contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityIdentifier("full-program")
        Listing(code: fullProgram ? dive.program : dive.source, file: "dive.c")
        Text("Trace the output, then restore the missing code.").font(.footnote).foregroundStyle(Sea.muted)
    }

    @ViewBuilder private var exercise: some View {
        Plate(state.phase == 0 ? "01 / Output probe" : "02 / Repair bench", Sea.coral)
        Display(state.phase == 0 ? "Read the console" : "Restore the line", 33)
        if state.phase == 1 {
            HStack(spacing: 10) {
                Plate("Target output", Sea.foam)
                Text(verbatim: dive.output).font(.system(.body, design: .monospaced, weight: .bold))
            }.padding(.horizontal, 12).padding(.vertical, 8).consolePlate()
        }
        Listing(code: state.phase == 0 ? dive.source : dive.repairSource, file: "dive.c")
        Text(state.phase == 0 ? "Which output reaches the console?" : "Which fragment belongs in the marked gap?")
            .font(.subheadline.weight(.semibold))
        ForEach(Array(dive.options(for: state.phase).enumerated()), id: \.offset) { index, option in
            let selected = state.choice == option
            Button {
                state.choice = option
                log.save(state, for: dive)
            } label: {
                HStack(spacing: 12) {
                    Text(["A","B","C"][index]).font(.system(.caption, design: .monospaced, weight: .bold))
                        .frame(width: 25, height: 25).foregroundStyle(selected ? Sea.deep : Sea.foam)
                        .background(selected ? Sea.foam : Sea.deep, in: Circle())
                    Text(verbatim: option.trimmingCharacters(in: .whitespaces)).font(.system(.body, design: .monospaced))
                    Spacer()
                    if selected { Image(systemName: "circle.inset.filled").foregroundStyle(Sea.foam) }
                }.padding(.horizontal, 12).padding(.vertical, 9)
                    .consolePlate(selected ? Sea.panel : Sea.hull, radius: 9)
                    .overlay { if selected { RoundedRectangle(cornerRadius: 9).strokeBorder(Sea.foam) } }
            }.buttonStyle(.plain).disabled(state.checked)
                .accessibilityIdentifier("option-\(index)").accessibilityAddTraits(selected ? .isSelected : [])
        }
    }

    @ViewBuilder private var recovery: some View {
        VStack(spacing: 11) {
            ZStack {
                Circle().stroke(Sea.foam.opacity(0.22), lineWidth: 1).frame(width: 156, height: 156)
                Circle().fill(Sea.panel).frame(width: 132, height: 132)
                Nori().frame(width: 132, height: 132)
            }.padding(.top, 6)
            Plate(dive.id == 100 ? "Expedition complete" : "Dive logged", Sea.foam)
            Display(dive.id == 100 ? "Station online" : "Back on deck", 36)
            Text(dive.title).font(.headline)
            HStack {
                receipt("\(dive.depth) m", "Dive depth")
                receipt("\(2 - state.corrected.count)/2", "First try")
            }
            if newPart {
                Label(dive.sector.salvage + " recovered", systemImage: dive.sector.icon)
                    .font(.headline).foregroundStyle(Sea.gold).padding().frame(maxWidth: .infinity).consolePlate()
            }
            Text(dive.id == 100 ? "All 100 dives are logged. The Hadal engine is running." : replay ? "Practice recorded in your dive log." : "Dive \(dive.id + 1) is ready on the bridge.")
                .font(.subheadline).foregroundStyle(Sea.muted)
        }.frame(maxWidth: .infinity)
    }

    private func receipt(_ value: String, _ caption: String) -> some View {
        VStack(spacing: 3) { Display(value, 25); Plate(caption) }
            .padding(11).frame(maxWidth: .infinity).consolePlate()
    }

    private func advance() {
        if complete { dismiss(); return }
        withAnimation(still ? nil : .easeOut(duration: 0.17)) {
            if state.phase < 0 {
                state.phase = 0
            } else if !state.checked {
                state.checked = true
                if !correct { state.corrected.insert(state.phase) }
            } else if correct && state.phase == 1 {
                replay = log.done(dive)
                log.finish(state, for: dive)
                newPart = !replay && dive.id.isMultiple(of: 10)
                complete = true
                return
            } else {
                if correct { state.phase += 1 }
                state.checked = false
                state.choice = nil
            }
            log.save(state, for: dive)
        }
    }
}

private struct Listing: View {
    let code, file: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Circle().fill(Sea.coral).frame(width: 6, height: 6)
                Plate(file, Sea.paper)
                Spacer()
                Plate("C17", Sea.foam)
            }.padding(.horizontal, 13).padding(.vertical, 9).background(Sea.panel)
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(code.components(separatedBy: "\n").enumerated()), id: \.offset) { n, line in
                        HStack(alignment: .firstTextBaseline, spacing: 9) {
                            Text(String(format: "%02d", n+1)).foregroundStyle(Sea.muted)
                            Text(verbatim: line.isEmpty ? " " : line)
                                .foregroundStyle(line.contains("▧") ? Sea.gold : Sea.foam)
                        }
                    }
                }.font(.system(.footnote, design: .monospaced)).fixedSize(horizontal: true, vertical: false).padding(13)
            }
        }.background(Sea.hull).clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay { RoundedRectangle(cornerRadius: 10).strokeBorder(Sea.rim) }
            .accessibilityElement(children: .ignore).accessibilityLabel("C source code. " + code)
    }
}
