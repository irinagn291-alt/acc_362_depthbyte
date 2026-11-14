import SwiftUI

private enum Deck: String, CaseIterable {
    case bridge = "Bridge", chart = "Depth chart", locker = "Salvage"
    var icon: String {
        switch self {
        case .bridge: "gauge.with.dots.needle.67percent"
        case .chart: "water.waves"
        case .locker: "shippingbox.fill"
        }
    }
}

struct Substation: View {
    @EnvironmentObject private var log: DiveLog
    @State private var deck = Deck.bridge
    @State private var sectorIndex = 0
    @State private var dive: Dive?
    private var featured: Dive { log.next ?? Course.dives[0] }

    init() {
        #if DEBUG && targetEnvironment(simulator)
        if CaptureLaunch.enabled {
            switch CaptureLaunch.screen {
            case "depth-chart": _deck = State(initialValue: .chart)
            case "salvage-locker": _deck = State(initialValue: .locker)
            case "dive-briefing", "output-probe", "repair-bench", "dive-complete":
                _dive = State(initialValue: Course.dives[0])
            default: break
            }
        }
        #endif
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                SonarMark().frame(width: 31, height: 31)
                Text("DEPTHBYTE").font(.system(.title3, design: .rounded, weight: .black)).italic().tracking(-0.8)
                Spacer()
                Image(systemName: "chevron.left.forwardslash.chevron.right").font(.caption.bold()).foregroundStyle(Sea.foam)
                Plate("C17", Sea.paper)
            }.padding(.horizontal, 19).padding(.vertical, 8)
            ScrollView {
                VStack(alignment: .leading, spacing: 17) {
                    switch deck {
                    case .bridge: bridge
                    case .chart: chart
                    case .locker: locker
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 18)
                    .padding(.top, 5).padding(.bottom, 20)
            }.id(deck)
            HStack(spacing: 5) {
                ForEach(Deck.allCases, id: \.self) { item in
                    Button {
                        if item == .chart { sectorIndex = featured.sectorIndex }
                        deck = item
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.icon).font(.subheadline.weight(.bold))
                            Text(item.rawValue).font(.caption.weight(.bold))
                        }.frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(deck == item ? Sea.deep : Sea.muted)
                            .background(deck == item ? Sea.foam : .clear, in: Capsule())
                    }.buttonStyle(.plain)
                        .accessibilityIdentifier("tab-\(item.rawValue)")
                        .accessibilityAddTraits(deck == item ? .isSelected : [])
                }
            }.padding(5).consolePlate(Sea.hull, radius: 28).padding(.horizontal, 18).padding(.bottom, 3)
        }
        .frame(maxWidth: 690).frame(maxWidth: .infinity)
        .foregroundStyle(Sea.paper).background(Sea.deep.ignoresSafeArea())
        .fullScreenCover(item: $dive) { item in
            DiveLab(dive: item, checkpoint: log.checkpoint(for: item)).environmentObject(log)
        }
    }

    @ViewBuilder private var bridge: some View {
        VStack(alignment: .leading, spacing: 2) {
            Plate("Expedition  /  C programming", Sea.foam)
            Display("Dive control", 44).accessibilityAddTraits(.isHeader)
        }
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { proxy in
                    Image("Seafloor").resizable().scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading).clipped()
                }
                Nori().frame(width: 122, height: 122).padding(.trailing, 16).padding(.bottom, 1)
            }
            .frame(height: 150)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 6) {
                    Circle().fill(Sea.foam).frame(width: 6, height: 6)
                    Plate("Nori // Dive lead", Sea.paper)
                }.padding(.horizontal, 8).padding(.vertical, 5).background(Sea.deep.opacity(0.9), in: Capsule()).padding(10)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Plate(String(format: "Dive %03d / 100", featured.id), Sea.foam)
                    Spacer()
                    Plate("\(featured.depth) m", Sea.muted)
                }
                Display(featured.title, 31)
                Text(featured.sector.subject).font(.subheadline).foregroundStyle(Sea.muted)
                ConsoleButton(log.next == nil ? "Replay first dive" : log.checkpoint(for: featured).phase < 0 ? "Launch dive" : "Resume dive",
                              icon: "arrow.down.right") { dive = featured }
                    .padding(.top, 4).accessibilityIdentifier("launch")
            }.padding(14)
        }.background(Sea.hull).clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(Sea.rim) }

        HStack {
            Display("Expedition log", 24)
            Spacer()
            Button { sectorIndex = featured.sectorIndex; deck = .chart } label: {
                Label("Chart", systemImage: "arrow.up.right").font(.caption.bold()).foregroundStyle(Sea.foam).padding(6)
            }.buttonStyle(.plain)
        }
        HStack(spacing: 8) {
            stat("\(log.count)/100", "Dives logged", "checkmark.circle")
            stat("\(log.count * 30) m", "Depth reached", "arrow.down.to.line")
        }.padding(.top, -8)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: featured.sector.icon).foregroundStyle(Sea.gold)
                Text(featured.sector.name).font(.headline)
                Spacer()
                Plate("\(log.secured(in: featured.sectorIndex))/10")
            }
            SegmentMeter(filled: log.secured(in: featured.sectorIndex))
        }.padding(13).consolePlate()
    }

    private func stat(_ number: String, _ label: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack { Plate(label); Spacer(minLength: 1); Image(systemName: icon).font(.caption).foregroundStyle(Sea.foam) }
            Display(number, 25)
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading).consolePlate()
    }

    @ViewBuilder private var chart: some View {
        let sector = Course.sectors[sectorIndex]
        VStack(alignment: .leading, spacing: 2) {
            Plate("10 sectors / 3,000 m", Sea.foam)
            Display("Depth chart", 41).accessibilityAddTraits(.isHeader)
        }
        HStack {
            Button { sectorIndex -= 1 } label: { sectorArrow("chevron.left") }
                .disabled(sectorIndex == 0).accessibilityLabel("Previous sector")
            Spacer()
            VStack(spacing: 3) {
                Plate(String(format: "Sector %02d", sectorIndex + 1), Sea.gold)
                Text(sector.name).font(.headline.bold())
            }
            Spacer()
            Button { sectorIndex += 1 } label: { sectorArrow("chevron.right") }
                .disabled(sectorIndex == Course.sectors.count - 1).accessibilityLabel("Next sector")
        }.buttonStyle(.plain)
        VStack(alignment: .leading, spacing: 9) {
            HStack { Plate(sector.subject, Sea.foam); Spacer(); Plate("\(log.secured(in: sectorIndex)) / 10") }
            SegmentMeter(filled: log.secured(in: sectorIndex))
        }.padding(.bottom, 1)
        VStack(spacing: 0) {
            ForEach(Course.dives.filter { $0.sectorIndex == sectorIndex }) { item in
                let unlocked = log.unlocked(item)
                Button { dive = item } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Rectangle().fill(Sea.rim).frame(width: 2)
                            Circle().fill(log.done(item) ? Sea.foam : unlocked ? Sea.coral : Sea.panel)
                                .frame(width: 25, height: 25)
                            Image(systemName: log.done(item) ? "checkmark" : unlocked ? "arrow.down.right" : "lock.fill")
                                .font(.caption2.bold()).foregroundStyle(unlocked ? Sea.deep : Sea.muted)
                        }.frame(width: 28)
                        Text(String(format: "%03d", item.id)).font(.system(.caption, design: .monospaced)).foregroundStyle(Sea.muted)
                        Text(item.title).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(item.depth) m").font(.system(.caption2, design: .monospaced)).foregroundStyle(Sea.muted)
                    }.frame(minHeight: 46).contentShape(Rectangle())
                }.buttonStyle(.plain).disabled(!unlocked)
                    .accessibilityIdentifier("dive-\(item.id)")
            }
        }.padding(.horizontal, 12).consolePlate()
    }

    private func sectorArrow(_ icon: String) -> some View {
        Image(systemName: icon).frame(width: 44, height: 44).consolePlate()
    }

    @ViewBuilder private var locker: some View {
        VStack(alignment: .leading, spacing: 2) {
            Plate("Recovered hardware", Sea.gold)
            Display("Salvage locker", 38).accessibilityAddTraits(.isHeader)
        }
        HStack(spacing: 8) {
            stat("\(log.count / 10)/10", "Parts fitted", "wrench.adjustable")
            stat("\(log.cleanCount)", "Clean dives", "sparkles")
        }
        Text("Finish a sector to recover its part. Clear both checks on your first try to log a clean dive.")
            .font(.subheadline).foregroundStyle(Sea.muted)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 146), spacing: 10)], spacing: 10) {
            ForEach(Course.sectors.indices, id: \.self) { idx in
                let sector = Course.sectors[idx]
                let collected = log.secured(in: idx) == 10
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: sector.icon).font(.title2.weight(.semibold)).foregroundStyle(collected ? Sea.gold : Sea.muted)
                        Spacer()
                        Plate(String(format: "%02d", idx + 1))
                    }
                    Text(sector.salvage).font(.headline).fixedSize(horizontal: false, vertical: true)
                    Plate(collected ? "Recovered" : "\(log.secured(in: idx))/10 dives", collected ? Sea.gold : Sea.muted)
                }.padding(13).frame(maxWidth: .infinity, alignment: .leading).consolePlate(collected ? Sea.panel : Sea.hull)
            }
        }
    }
}
