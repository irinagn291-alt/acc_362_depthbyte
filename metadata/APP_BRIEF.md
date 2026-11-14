<!-- gf-brief source=7eafa320a288bea3ad90a14ad09f59fa00c36ea7495cf47e567db0a15f7f55ae written=2026-11-14T15:50:45+03:00 -->
# Depthbyte

## What it is

Depthbyte is an underwater-themed C programming learning app built around 100 short exercises called dives. It is for people who want to practise reading C code, predicting its output and identifying missing code.

## Launch and onboarding

On a fresh launch, the app opens directly to the “Bridge” tab. There is no separate onboarding.

1. The header shows “DEPTHBYTE” and “C17”. The page begins with “Expedition  /  C programming” and “Dive control”.
2. The first card shows “Nori // Dive lead”, “Dive 001 / 100”, “30 m”, “Hello, ocean” and “First transmissions”. Tap “Launch dive” to open it.
3. The briefing shows “Dive briefing”, “Hello, ocean”, “Nori / Engineering” and: “A C statement ends with a semicolon. puts sends the characters between its quotes to the console and adds a newline.” It also shows the code and “Trace the output, then restore the missing code.”
4. “Show complete program” expands the example; “Show lesson excerpt” switches back. “Enter test chamber” starts the first question.

On later launches, the bridge features the next unfinished dive. An in-progress dive offers “Resume dive”.

## Screens

### Bridge — “Dive control”

The featured card shows the next dive’s number, depth, title and sector subject. “Launch dive” opens its briefing; “Resume dive” returns to a saved exercise. After all 100 dives are complete, “Replay first dive” opens the first dive again.

“Expedition log” shows “Dives logged”, “Depth reached” and progress in the featured sector. “Chart” opens “Depth chart” at that sector.

The bottom controls “Bridge”, “Depth chart” and “Salvage” switch between the three main screens.

### Depth chart

“Depth chart” shows “10 sectors / 3,000 m”, the selected sector’s name, subject and completed-dive count, followed by its ten dives. Each row shows a number, title and depth. Tap an unlocked dive to open it; completed dives can be replayed.

The arrow controls, accessible as “Previous sector” and “Next sector”, move between sectors. Opening the tab initially selects the sector containing the featured dive.

The sectors, subjects and recoverable parts are:

| Sector | Subject | Part |
| --- | --- | --- |
| “Surface lock” | “First transmissions” | “Signal lamp” |
| “Ballast bay” | “Numbers & conversions” | “Trim wheel” |
| “Switch gallery” | “Logic & branches” | “Gate selector” |
| “Rotor chamber” | “Loops & counters” | “Rotor blade” |
| “Sample vault” | “Arrays & strings” | “Sample cassette” |
| “Relay workshop” | “Functions & scope” | “Relay module” |
| “Address trench” | “Pointers & indirection” | “Address probe” |
| “Archive dome” | “Records, bits & types” | “Archive prism” |
| “Memory reef” | “Allocation & lifetime” | “Memory core” |
| “Hadal engine” | “Debugging & algorithms” | “Hadal drive” |

### Salvage — “Salvage locker”

“Recovered hardware” and “Salvage locker” head a display of “Parts fitted” and “Clean dives”. The explanation reads: “Finish a sector to recover its part. Clear both checks on your first try to log a clean dive.”

Each sector’s part is shown with either its completed-dive count, such as “0/10 dives”, or “Recovered”. The part cards are displays, not controls.

### Dive

The dive opens full screen with its number and sector, a progress indicator and a down-arrow control accessible as “Surface and save”. That control closes the dive and saves its current place.

- The “Dive briefing” presents the dive title, a note from “Nori / Engineering” and a code listing. “Show complete program” and “Show lesson excerpt” switch the listing. “Enter test chamber” opens the exercise.
- “01 / Output probe” and “Read the console” ask “Which output reaches the console?” Select one of three labelled answers, “A”, “B” or “C”, then tap “Check prediction”.
- “02 / Repair bench” and “Restore the line” show “Target output” and ask “Which fragment belongs in the marked gap?” Select one of three answers, then tap “Test repair”.
- A correct check shows “Signal confirmed”. The first check also states “The console prints” followed by the output; the second says “The restored program matches the target.” “Open repair bench” advances after the first check, and “Log dive” finishes after the second.
- An incorrect check shows “Nori’s repair note” and the dive’s explanatory briefing. “Adjust answer” returns to the choices for another attempt.
- Completion shows “Dive logged”, “Back on deck”, the dive title, “Dive depth” and “First try”. A newly earned part appears as its name followed by “recovered”. The screen says the next dive is ready on the bridge, or “Practice recorded in your dive log.” for a replay. “Return to bridge” closes the dive. The final dive instead shows “Expedition complete”, “Station online” and “All 100 dives are logged. The Hadal engine is running.”

## Features

- A 100-dive “Expedition  /  C programming” across ten sectors and 3,000 metres.
- Briefings with lesson excerpts and complete programs.
- An “Output probe” and “Repair bench” in each dive, with feedback and retries.
- An “Expedition log” with “Dives logged” and “Depth reached”.
- A “Depth chart” for sector navigation and replaying completed dives.
- A “Salvage locker” with a part for each completed sector and a count of “Clean dives”.
- Saved dive progress and a “Resume dive” control.

## Behaviours that can look like bugs

- Later dive rows are locked until the preceding dive is completed. Finish the current dive to unlock the next one; completed dives remain available for replay.
- “Previous sector” is disabled in the first sector and “Next sector” in the last. Use the other arrow to move back through the chart.
- “Check prediction” and “Test repair” are disabled until an answer is selected. Tap an answer first.
- Answers are temporarily disabled after a check. If the answer is wrong, tap “Adjust answer” to choose again; if correct, use “Open repair bench” or “Log dive”.
- Before any dives are completed, the log and locker show zero progress, and parts show “0/10 dives”. Complete dives to fill the counts; finish all ten dives in a sector to mark its part “Recovered”.
- A “First try” score can be less than “2/2” after a wrong answer. A clean dive requires both checks to be cleared on the first try.
- After all dives are logged, the bridge offers “Replay first dive”. Replaying a completed dive records practice without increasing the number of logged dives.

## Starter content and resume

The app includes 100 prepared dives, beginning with “Hello, ocean”; these are the course content, not user-created samples. Unfinished exercise progress, including a selected answer and checked state, can be resumed. Completed dives can be replayed.

## Permissions

None.

## Absent

Login or accounts, in-app purchases, ads, analytics, user-generated content, an account deletion flow and an App Tracking Transparency prompt are absent.

## Data and support

Dive progress and results stay on the device. There is no on-screen Contact or Support control.

## Scanning and health

None. The app does not scan barcodes or QR codes and does not show health, medical or product-health information.

## Platform

The interface is in English, with no region-specific behaviour shown. The app supports iPhone and iPad on iOS 17.0 or later. iPhone is portrait only; iPad supports portrait, upside-down portrait and both landscape orientations.

## Category

Education.
