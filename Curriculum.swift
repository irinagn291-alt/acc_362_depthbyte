import Foundation
import Combine

struct Sector {
    let name, subject, icon, salvage: String
    init(_ name: String, _ subject: String, _ icon: String, _ salvage: String) {
        self.name = name
        self.subject = subject
        self.icon = icon
        self.salvage = salvage
    }
}

struct Dive: Identifiable {
    let id: Int
    let title, briefing, code, output, helpers: String
    let otherOutputs, patches: [String]

    init(_ id: Int, _ title: String, _ briefing: String, _ code: String, _ output: String,
         _ otherOutputs: [String], _ patches: [String], helpers: String = "") {
        self.id = id
        self.title = title
        self.briefing = briefing
        self.code = code
        self.output = output
        self.otherOutputs = otherOutputs
        self.patches = patches
        self.helpers = helpers
    }

    var sectorIndex: Int { (id - 1) / 10 }
    var sector: Sector { Course.sectors[sectorIndex] }
    var depth: Int { id * 30 }
    var source: String {
        if helpers.isEmpty { return code }
        let body = code.components(separatedBy: "\n").map { "    " + $0 }.joined(separator: "\n")
        return helpers + "\n\nint main(void) {\n" + body + "\n}"
    }
    var program: String {
        var headers = ["#include <stdio.h>"]
        if ["malloc(", "calloc(", "realloc(", "free("].contains(where: code.contains) {
            headers.append("#include <stdlib.h>")
        }
        if ["strlen(", "strcmp(", "strcpy(", "memcpy(", "memmove(", "memset("].contains(where: code.contains) {
            headers.append("#include <string.h>")
        }
        let body = code.components(separatedBy: "\n").map { "    " + $0 }.joined(separator: "\n")
        let main = "int main(void) {\n" + body + "\n    return 0;\n}"
        return [headers.joined(separator: "\n"), helpers, main].filter { !$0.isEmpty }.joined(separator: "\n\n")
    }
    var repairSource: String {
        guard let r = source.range(of: patches[0], options: .backwards) else { return source }
        return source.replacingCharacters(in: r, with: "▧")
    }
    func options(for phase: Int) -> [String] {
        let values = phase == 0 ? [output] + otherOutputs : patches
        let rotation = (id + phase) % values.count
        return Array(values.dropFirst(rotation)) + values.prefix(rotation)
    }
    func answer(for phase: Int) -> String { phase == 0 ? output : patches[0] }
}

enum Course {
    static let sectors = [

        Sector("Surface lock", "First transmissions", "dot.radiowaves.left.and.right", "Signal lamp"),
        Sector("Ballast bay", "Numbers & conversions", "dial.medium.fill", "Trim wheel"),
        Sector("Switch gallery", "Logic & branches", "switch.2", "Gate selector"),
        Sector("Rotor chamber", "Loops & counters", "fanblades.fill", "Rotor blade"),
        Sector("Sample vault", "Arrays & strings", "square.grid.3x3.fill", "Sample cassette"),
        Sector("Relay workshop", "Functions & scope", "wrench.and.screwdriver.fill", "Relay module"),
        Sector("Address trench", "Pointers & indirection", "arrow.triangle.branch", "Address probe"),
        Sector("Archive dome", "Records, bits & types", "archivebox.fill", "Archive prism"),
        Sector("Memory reef", "Allocation & lifetime", "memorychip.fill", "Memory core"),
        Sector("Hadal engine", "Debugging & algorithms", "gearshape.2.fill", "Hadal drive")
    ]
    static let dives = [
        Dive(1, "Hello, ocean", "A C statement ends with a semicolon. puts sends the characters between its quotes to the console and adds a newline.", "puts(\"Dive ready\");", "Dive ready", ["\"Dive ready\"", "puts"], ["puts", "putchar", "strlen"]),
        Dive(2, "The nameplate", "A string literal holds text. printf writes literal text exactly as it appears between the quotes.", "printf(\"Nori\");", "Nori", ["\"Nori\"", "N"], ["printf", "putchar", "strlen"]),
        Dive(3, "One character", "Single quotes surround a character constant. putchar writes one character to standard output.", "putchar('C');", "C", ["'C'", "67"], ["putchar", "puts", "strlen"]),
        Dive(4, "Lamp sequence", "Separate statements run in source order. printf can write two pieces of text on the same output line.", "printf(\"SEA\");\nprintf(\"LAB\");", "SEALAB", ["LABSEA", "SEA LAB"], ["\"LAB\"", "\"SEA\"", "\" LAB\""]),
        Dive(5, "First reading", "An int holds a whole number. The %d conversion prints its signed decimal value.", "int depth = 12;\nprintf(\"%d\", depth);", "12", ["depth", "%d"], ["depth);", "0);", "1);"]),
        Dive(6, "Recalibrate", "Assignment replaces the old value in a variable. Later reads see the most recent value.", "int dial = 3;\ndial = 8;\nprintf(\"%d\", dial);", "8", ["3", "11"], ["8", "3", "0"]),
        Dive(7, "Name your buoy", "A character array initialized with a string includes a terminating zero. %s prints up to that terminator.", "char name[] = \"Kelp\";\nprintf(\"%s\", name);", "Kelp", ["name", "K"], ["%s", "%.1s", "%.2s"]),
        Dive(8, "Pair of gauges", "printf matches conversion specifications to arguments from left to right. Literal punctuation appears between the readings.", "int a = 2, b = 7;\nprintf(\"%d/%d\", a, b);", "2/7", ["7/2", "27"], ["a, b", "b, a", "a, a"]),
        Dive(9, "Width marks", "A decimal field width sets a minimum width. A leading zero in %03d fills empty positions with zeroes.", "int code = 7;\nprintf(\"%03d\", code);", "007", ["7", "700"], ["%03d", "%d", "%02d"]),
        Dive(10, "Percent gauge", "In a printf format, %% emits one percent sign. It consumes no additional argument.", "printf(\"%d%%\", 80);", "80%", ["80%%", "%80"], ["80", "8", "0"]),
        Dive(11, "Ballast load", "The + operator adds two integer values. Store the result or pass it directly to printf.", "int port = 4, star = 7;\nprintf(\"%d\", port + star);", "11", ["47", "3"], [" + ", " - ", " * "]),
        Dive(12, "Reserve tank", "Use subtraction to calculate what remains after a transfer.", "int tank = 18;\nprintf(\"%d\", tank - 5);", "13", ["23", "90"], [" - ", " + ", " * "]),
        Dive(13, "Crate weight", "Multiplication calculates the combined mass of equal loads.", "int crates = 6;\nprintf(\"%d\", crates * 3);", "18", ["9", "3"], [" * ", " + ", " - "]),
        Dive(14, "Whole shifts", "Dividing two positive integers gives the whole-number quotient. Any fractional part is discarded.", "int cells = 17;\nprintf(\"%d\", cells / 4);", "4", ["4.25", "1"], [" / ", " % ", " * "]),
        Dive(15, "Leftover seals", "The remainder operator % gives the amount left after integer division.", "int seals = 17;\nprintf(\"%d\", seals % 5);", "2", ["3", "3.4"], [" % ", " / ", " + "]),
        Dive(16, "Paired tanks", "Multiplication has higher precedence than addition. Trace the product first.", "printf(\"%d\", 2 + 4 * 3);", "14", ["18", "9"], [" * ", " + ", " - "]),
        Dive(17, "Pressure groups", "Calculate an expression in parentheses before applying the outer multiplication.", "printf(\"%d\", (2 + 4) * 3);", "18", ["14", "9"], ["(2 + 4)", "(2 - 4)", "(2 * 4)"]),
        Dive(18, "Fractional depth", "A double preserves a fractional measurement. %.1f displays one digit after the decimal point.", "double d = 4.0 / 2.5;\nprintf(\"%.1f\", d);", "1.6", ["1", "1.60"], ["%.1f", "%.0f", "%.2f"]),
        Dive(19, "Trim a reading", "A conversion from an in-range floating value to int discards the fractional part toward zero.", "double depth = -3.8;\nprintf(\"%d\", (int)depth);", "-3", ["-4", "3"], ["(int)depth", "-(int)depth", "0"]),
        Dive(20, "Signed drift", "A negative integer quotient also truncates toward zero. Follow the signs before choosing the reading.", "printf(\"%d\", -7 / 3);", "-2", ["-3", "2"], [" / ", " % ", " * "]),
        Dive(21, "Twin readings", "The equality operator compares two values. It yields the int value 1 for true and 0 for false.", "int a = 4, b = 4;\nprintf(\"%d\", a == b);", "1", ["4", "0"], [" == ", " != ", " < "]),
        Dive(22, "Different seals", "Use != to detect unequal values. It produces a numeric truth value.", "int a = 3, b = 7;\nprintf(\"%d\", a != b);", "1", ["0", "7"], [" != ", " == ", " > "]),
        Dive(23, "Minimum depth", "The >= relation includes the boundary itself. Check a reading exactly on the limit.", "int m = 20;\nprintf(\"%d\", m >= 20);", "1", ["0", "20"], [" >= ", " > ", " < "]),
        Dive(24, "Two interlocks", "Logical AND yields true only when both input expressions are nonzero.", "int hatch = 1, pump = 0;\nprintf(\"%d\", hatch && pump);", "0", ["1", "2"], [" && ", " || ", " + "]),
        Dive(25, "Backup power", "Logical OR accepts either active supply. Its result is always 0 or 1.", "int a = 0, b = 2;\nprintf(\"%d\", a || b);", "1", ["0", "2"], [" || ", " && ", " + "]),
        Dive(26, "Invert the flag", "The ! operator maps zero to 1 and every nonzero value to 0.", "int alarm = 0;\nprintf(\"%d\", !alarm);", "1", ["0", "-1"], ["!alarm", "alarm", "-alarm"]),
        Dive(27, "Select a hatch", "An if statement takes the first branch when its condition is true. Otherwise execution goes to else.", "int pressure = 8;\nif (pressure < 6) puts(\"Open\");\nelse puts(\"Hold\");", "Hold", ["Open", "OpenHold"], [" < ", " > ", " >= "]),
        Dive(28, "Three bands", "An else-if chain checks conditions in order. The first matching branch handles the reading.", "int d = 12;\nif (d < 5) puts(\"A\");\nelse if (d < 20) puts(\"B\");\nelse puts(\"C\");", "B", ["A", "C"], ["20", "10", "8"]),
        Dive(29, "Mode switch", "switch selects a matching case. break exits the switch before the next label executes.", "int mode = 2;\nswitch (mode) {\ncase 1: puts(\"Fill\"); break;\ncase 2: puts(\"Drain\"); break;\ndefault: puts(\"Idle\");\n}", "Drain", ["Fill", "Idle"], ["mode = 2", "mode = 1", "mode = 0"]),
        Dive(30, "Quick route", "The conditional operator selects its middle expression when the test is true and its last expression otherwise.", "int clear = 0;\nputs(clear ? \"Go\" : \"Wait\");", "Wait", ["Go", "0"], ["clear ?", "!clear ?", "1 ?"]),
        Dive(31, "Three pings", "A for loop runs its body while its condition stays true. The update runs after each pass.", "for (int i = 0; i < 3; ++i)\n    putchar('A');", "AAA", ["AA", "AAAA"], ["i < 3", "i < 2", "i <= 3"]),
        Dive(32, "Wind down", "A while loop checks its condition before each pass. Decrement the counter to reach zero.", "int n = 3;\nwhile (n > 0) {\n    printf(\"%d\", n);\n    --n;\n}", "321", ["012", "3210"], ["n > 0", "n > 1", "n > 2"]),
        Dive(33, "Prime the pump", "A do-while loop executes its body once before the first condition check.", "int n = 0;\ndo { ++n; } while (n < 0);\nprintf(\"%d\", n);", "1", ["0", "2"], ["++n", "n += 2", "n += 3"]),
        Dive(34, "Two-step drive", "A compound update can advance by more than one position. Track each value before the update.", "for (int i = 0; i < 6; i += 2)\n    printf(\"%d\", i);", "024", ["246", "0246"], ["i += 2", "i += 3", "++i"]),
        Dive(35, "Early stop", "break leaves the loop immediately. Statements lower in the body are skipped on that pass.", "for (int i = 1; i < 6; ++i) {\n    if (i == 3) break;\n    printf(\"%d\", i);\n}", "12", ["123", "1245"], ["i == 3", "i == 2", "i == 4"]),
        Dive(36, "Skip a tooth", "continue jumps to the loop update in a for loop, then checks the condition for the next pass.", "for (int i = 1; i <= 4; ++i) {\n    if (i == 2) continue;\n    printf(\"%d\", i);\n}", "134", ["1234", "34"], ["i == 2", "i == 1", "i == 3"]),
        Dive(37, "Rotor tally", "An accumulator carries its value from one iteration to the next. Start at zero before adding each reading.", "int sum = 0;\nfor (int i = 1; i <= 4; ++i)\n    sum += i;\nprintf(\"%d\", sum);", "10", ["4", "6"], ["sum += i", "sum = i", "sum -= i"]),
        Dive(38, "Gear pairs", "For every outer loop iteration, the inner loop runs from its own initial value.", "int pairs = 0;\nfor (int a = 0; a < 2; ++a)\n    for (int b = 0; b < 3; ++b)\n        ++pairs;\nprintf(\"%d\", pairs);", "6", ["5", "3"], ["a < 2", "a < 3", "a < 1"]),
        Dive(39, "Postfix capture", "Postfix increment supplies the old value, then increments the variable. Read the updated variable in the next statement.", "int n = 4;\nint old = n++;\nprintf(\"%d/%d\", old, n);", "4/5", ["5/5", "4/4"], ["n++", "++n", "n--"]),
        Dive(40, "Countdown sum", "Compound subtraction changes the running total. Trace the number of loop passes as well as the update.", "int n = 10;\nfor (int k = 0; k < 3; ++k)\n    n -= 2;\nprintf(\"%d\", n);", "4", ["8", "6"], ["n -= 2", "n += 2", "n -= 1"]),
        Dive(41, "Tray position", "Array indices begin at zero. Index 1 reads the second element.", "int tray[] = {4, 8, 3};\nprintf(\"%d\", tray[1]);", "8", ["4", "3"], ["[1]", "[0]", "[2]"]),
        Dive(42, "Replace a vial", "Assigning through an index replaces only that element.", "int v[] = {3, 4};\nv[0] = 8;\nprintf(\"%d\", v[0] + v[1]);", "12", ["7", "8"], [" = 8", " = 3", " = 0"]),
        Dive(43, "Empty slots", "When an array has an initializer with too few elements, the remaining elements are initialized to zero.", "int v[4] = {7, 2};\nprintf(\"%d\", v[3]);", "0", ["7", "2"], ["v[3]);", "v[0]);", "v[1]);"]),
        Dive(44, "Tray capacity", "For an array in its defining scope, divide the entire byte size by the size of one element to count the elements.", "int v[] = {1, 4, 9, 16};\nprintf(\"%zu\", sizeof v / sizeof v[0]);", "4", ["3", "1"], ["sizeof v / sizeof v[0]", "sizeof v[0] / sizeof v", "sizeof v / sizeof v"]),
        Dive(45, "Row and column", "In a two-dimensional array, the first subscript selects a row, the second selects a column.", "int rack[2][2] = {{1, 2}, {4, 8}};\nprintf(\"%d\", rack[1][0]);", "4", ["2", "8"], ["[1][0]", "[0][1]", "[1][1]"]),
        Dive(46, "Read a label", "strlen counts characters before the first zero byte. The terminator is excluded.", "char label[] = \"Nori\";\nprintf(\"%zu\", strlen(label));", "4", ["5", "3"], ["strlen(label)", "sizeof label", "strlen(label) - 1"]),
        Dive(47, "Hidden stop", "An embedded zero terminates the string seen by puts. Later bytes may still be present in the array.", "char tag[] = \"Reef\";\ntag[2] = 0;\nputs(tag);", "Re", ["Reef", "Rf"], ["tag[2]", "tag[1]", "tag[3]"]),
        Dive(48, "Edit a label", "A character array has writable elements. Replacing a character preserves the terminator at the end.", "char tag[] = \"fin\";\ntag[0] = 'p';\nputs(tag);", "pin", ["fin", "p"], ["tag[0]", "tag[1]", "tag[2]"]),
        Dive(49, "Compare tags", "strcmp returns zero for equal strings. Compare its result with zero to turn equality into 1.", "char a[] = \"buoy\";\nprintf(\"%d\", strcmp(a, \"buoy\") == 0);", "1", ["0", "4"], [" == ", " != ", " < "]),
        Dive(50, "Bounded label", "snprintf writes at most capacity minus one characters plus a terminator when capacity is nonzero.", "char tag[4];\nsnprintf(tag, sizeof tag, \"%s\", \"Ocean\");\nputs(tag);", "Oce", ["Ocea", "Ocean"], ["sizeof tag", "2", "3"]),
        Dive(51, "Return channel", "A function can send one value back with return. The caller can print or store that result.", "printf(\"%d\", boost(4));", "8", ["4", "16"], ["boost(4)", "boost(2)", "boost(6)"], helpers: "int boost(int x) { return x * 2; }"),
        Dive(52, "Two inputs", "Parameters receive values in the same order as the call arguments. Subtraction makes their order visible.", "printf(\"%d\", gap(9, 4));", "5", ["-5", "13"], ["9, 4", "4, 9", "9, 9"], helpers: "int gap(int a, int b) { return a - b; }"),
        Dive(53, "Pass a copy", "C passes an int argument by value. Changing a parameter does not change the caller’s variable.", "int n = 6;\nint result = raise_one(n);\nprintf(\"%d/%d\", n, result);", "6/7", ["7/7", "6/6"], ["n, result", "result, n", "result, result"], helpers: "int raise_one(int x) { return ++x; }"),
        Dive(54, "Guard return", "A return ends the current function call immediately. Later statements in that function are skipped.", "printf(\"%d\", clamp_low(-5));", "0", ["-5", "5"], ["-5", "3", "8"], helpers: "int clamp_low(int n) {\n    if (n < 0) return 0;\n    return n;\n}"),
        Dive(55, "Nested calls", "The result of an inner call becomes an argument to the outer function.", "printf(\"%d\", twice(plus(3)));", "8", ["7", "6"], ["plus(3)", "plus(2)", "3"], helpers: "int plus(int n) { return n + 1; }\nint twice(int n) { return 2 * n; }"),
        Dive(56, "Inner cabin", "A name declared inside a block can shadow an outer name. The outer object still exists after the inner block ends.", "int n = 4;\n{ int n = 9; printf(\"%d/\", n); }\nprintf(\"%d\", n);", "9/4", ["9/9", "4/9"], ["n = 9", "n = 3", "n = 1"]),
        Dive(57, "Persistent dial", "A static local object retains its value between calls. Its initializer runs only once.", "int a = tick();\nint b = tick();\nprintf(\"%d/%d\", a, b);", "1/2", ["1/1", "2/2"], ["a, b", "b, a", "b, b"], helpers: "int tick(void) {\n    static int n = 0;\n    return ++n;\n}"),
        Dive(58, "Select a tool", "A function pointer can hold the address of a compatible function. Call it with ordinary parentheses.", "int (*tool)(int) = twice;\nprintf(\"%d\", tool(5));", "10", ["5", "25"], ["tool(5)", "tool(4)", "tool(2)"], helpers: "int twice(int x) { return 2 * x; }"),
        Dive(59, "Call stack", "A recursive call uses a smaller argument. A base case returns directly so the calls eventually stop.", "printf(\"%d\", sum_to(4));", "10", ["4", "24"], ["sum_to(4)", "sum_to(3)", "sum_to(5)"], helpers: "int sum_to(int n) {\n    if (n == 0) return 0;\n    return n + sum_to(n - 1);\n}"),
        Dive(60, "Return a status", "A caller can interpret zero as success and a nonzero result as failure. These functions define their own convention.", "int status = check(-1);\nputs(status == 0 ? \"OK\" : \"Fault\");", "Fault", ["OK", "1"], ["check(-1)", "check(0)", "check(4)"], helpers: "int check(int power) { return power < 0; }"),
        Dive(61, "Find the gauge", "& takes an object’s address. Dereferencing its pointer with * reads the object at that address.", "int gauge = 7;\nint *p = &gauge;\nprintf(\"%d\", *p);", "7", ["0", "gauge"], ["*p);", "0);", "1);"]),
        Dive(62, "Remote write", "Assignment through a valid pointer writes to the pointed-to object.", "int gauge = 3;\nint *p = &gauge;\n*p = 9;\nprintf(\"%d\", gauge);", "9", ["3", "12"], ["*p = 9", "*p = 4", "*p = 0"]),
        Dive(63, "Two probes", "Pointers can refer to the same object. An update through one is visible through the other.", "int x = 5;\nint *a = &x, *b = &x;\n*a += 2;\nprintf(\"%d\", *b);", "7", ["5", "2"], ["+= 2", "-= 2", "*= 2"]),
        Dive(64, "Slide the probe", "Adding one to a pointer moves by one element within its array. Dereference only valid element positions.", "int v[] = {2, 5, 9};\nint *p = v;\nprintf(\"%d\", *(p + 1));", "5", ["2", "9"], ["p + 1", "p + 2", "p + 0"]),
        Dive(65, "Span count", "Subtracting pointers into the same array gives the difference in element indices, as ptrdiff_t.", "int v[6] = {0};\nprintf(\"%td\", &v[5] - &v[1]);", "4", ["5", "6"], ["&v[1]", "&v[0]", "&v[2]"]),
        Dive(66, "Repoint the lead", "Assigning a new address changes which object a pointer refers to. The earlier object keeps its value.", "int a = 3, b = 8;\nint *p = &a;\np = &b;\n*p = 6;\nprintf(\"%d/%d\", a, b);", "3/6", ["6/8", "6/6"], ["p = &b;", "p = &a;", "b = a;"]),
        Dive(67, "Empty socket", "Compare a pointer with NULL before dereferencing it. A conditional expression evaluates only the selected branch.", "int *p = NULL;\nprintf(\"%d\", p ? *p : 4);", "4", ["0", "1"], [" : 4", " : 0", " : 1"]),
        Dive(68, "Double lead", "A pointer to a pointer holds the address of another pointer. Two dereferences reach the original int.", "int n = 4;\nint *p = &n;\nint **pp = &p;\n**pp += 3;\nprintf(\"%d\", n);", "7", ["4", "3"], ["+= 3", "-= 3", "*= 3"]),
        Dive(69, "Service port", "A function can change a caller’s int through a pointer parameter when given its address.", "int load = 6;\ntrim(&load);\nprintf(\"%d\", load);", "4", ["6", "8"], ["-= 2", "+= 2", "*= 2"], helpers: "void trim(int *n) { *n -= 2; }"),
        Dive(70, "Read-only probe", "A pointer to const int allows reads through that pointer. The original mutable object can still change through its own name.", "int n = 2;\nconst int *view = &n;\nn = 7;\nprintf(\"%d\", *view);", "7", ["2", "0"], ["n = 7", "n = 5", "n = 0"]),
        Dive(71, "Cargo record", "A struct groups named members. The dot operator selects a member of a struct object.", "struct Pod { int id, mass; };\nstruct Pod p = {4, 9};\nprintf(\"%d\", p.mass);", "9", ["4", "13"], ["p.mass", "p.id", "p.id + p.mass"]),
        Dive(72, "Port label", "Designated initializers name the members explicitly. Their order need not follow the declaration.", "struct Pos { int x, y; };\nstruct Pos p = {.y = 8, .x = 3};\nprintf(\"%d/%d\", p.x, p.y);", "3/8", ["8/3", "3/3"], ["p.x, p.y", "p.y, p.x", "p.x, p.x"]),
        Dive(73, "Record probe", "The arrow operator accesses a struct member through a pointer to that struct.", "struct Pod { int mass; };\nstruct Pod p = {6};\nstruct Pod *ptr = &p;\nprintf(\"%d\", ptr->mass);", "6", ["0", "1"], ["ptr->mass", "0", "1"]),
        Dive(74, "Duplicate record", "Assigning a struct copies its member values. Later writes to an int member of the copy affect only the copy.", "struct Pod { int n; };\nstruct Pod a = {5}, b = a;\nb.n = 2;\nprintf(\"%d/%d\", a.n, b.n);", "5/2", ["2/2", "5/5"], ["a.n, b.n", "b.n, a.n", "b.n, b.n"]),
        Dive(75, "Named modes", "Enumerators increment by one from the preceding value when no explicit value is given.", "enum Mode { IDLE = 2, FILL, DRAIN };\nprintf(\"%d\", DRAIN);", "4", ["3", "2"], ["DRAIN);", "FILL);", "IDLE);"]),
        Dive(76, "Type shorthand", "typedef creates an alternative name for an existing type. Here Count has the behavior of unsigned int.", "typedef unsigned int Count;\nCount n = 7u;\nprintf(\"%u\", n + 2u);", "9", ["7", "5"], ["n + 2u", "n - 2u", "n * 2u"]),
        Dive(77, "Mask a flag", "Bitwise AND keeps a bit only when both operands contain it. Work with unsigned masks.", "unsigned flags = 6u;\nprintf(\"%u\", flags & 2u);", "2", ["6", "0"], [" & ", " ^ ", " + "]),
        Dive(78, "Set the latch", "Bitwise OR sets each bit present in either operand. Here the low bit is newly switched on.", "unsigned flags = 4u;\nprintf(\"%u\", flags | 1u);", "5", ["4", "0"], [" | ", " & ", " - "]),
        Dive(79, "Toggle a relay", "Exclusive OR flips the positions selected by a mask. Applying it to an already-set bit clears that bit.", "unsigned flags = 7u;\nprintf(\"%u\", flags ^ 2u);", "5", ["7", "2"], [" ^ ", " | ", " & "]),
        Dive(80, "Shift bank", "A left shift moves the bits toward larger place values. This small unsigned value fits after the shift.", "unsigned flag = 1u;\nprintf(\"%u\", flag << 3);", "8", ["3", "4"], [" << ", " >> ", " + "]),
        Dive(81, "Request a slot", "malloc reserves uninitialized storage. Check the pointer, write a value before reading, then free it. Assume allocation succeeds.", "int *p = malloc(sizeof *p);\nif (!p) return 1;\n*p = 8;\nprintf(\"%d\", *p);\nfree(p);", "8", ["0", "1"], ["*p = 8", "*p = 4", "*p = 2"]),
        Dive(82, "Zero nursery", "calloc sets the allocated bytes to zero. For these int elements the initial values are zero. Assume allocation succeeds.", "int *p = calloc(3, sizeof *p);\nif (!p) return 1;\np[0] = 3; p[2] = 5;\nprintf(\"%d\", p[1]);\nfree(p);", "0", ["3", "5"], ["p[1]);", "p[0]);", "p[2]);"]),
        Dive(83, "Heap row", "Allocated storage can hold several elements. Reserve enough bytes and access only initialized indices. Assume allocation succeeds.", "int *p = malloc(3 * sizeof *p);\nif (!p) return 1;\np[0] = 2; p[1] = 4; p[2] = 7;\nprintf(\"%d\", p[2] - p[0]);\nfree(p);", "5", ["7", "9"], [" - ", " + ", " * "]),
        Dive(84, "Grow the tray", "Successful realloc preserves the old contents up to the smaller size. Keep the old pointer until success is known. Assume both allocations succeed.", "int *p = malloc(sizeof *p);\nif (!p) return 1;\np[0] = 3;\nint *q = realloc(p, 2 * sizeof *p);\nif (!q) { free(p); return 1; }\nq[1] = 6;\nprintf(\"%d\", q[0] + q[1]);\nfree(q);", "9", ["6", "3"], ["q[0] + q[1]", "q[1] - q[0]", "q[0] * q[1]"]),
        Dive(85, "Retire a lead", "After free, discard the old pointer value. Assign NULL before using this variable as an empty-slot marker.", "int *p = malloc(sizeof *p);\nif (!p) return 1;\nfree(p);\np = NULL;\nputs(p == NULL ? \"Empty\" : \"Live\");", "Empty", ["Live", "NULL"], [" == ", " != ", " && "]),
        Dive(86, "Byte transfer", "memcpy copies a specified byte count between nonoverlapping regions. sizeof src includes the string terminator here.", "char src[] = \"ROV\", dst[4];\nmemcpy(dst, src, sizeof src);\nputs(dst);", "ROV", ["RO", "dst"], ["\"ROV\"", "\"RO\"", "\"OV\""]),
        Dive(87, "Overlapping move", "memmove supports overlapping regions. The original two source bytes arrive at their destinations in order.", "char word[] = \"ABCD\";\nmemmove(word + 1, word, 2);\nputs(word);", "AABD", ["AAAD", "ABCD"], ["word, 2", "word, 1", "word, 3"]),
        Dive(88, "Reset bytes", "memset fills the first byte-count positions with the given unsigned-char value. The terminator stays untouched.", "char word[] = \"ABCD\";\nmemset(word, 'X', 2);\nputs(word);", "XXCD", ["XXXX", "XBCD"], ["'X', 2", "'X', 1", "'X', 3"]),
        Dive(89, "Owned copy", "Allocate enough bytes for the string and its terminator before copying. The source and copy can then change independently. Assume allocation succeeds.", "char src[] = \"tide\";\nchar *copy = malloc(strlen(src) + 1);\nif (!copy) return 1;\nstrcpy(copy, src);\ncopy[0] = 'r';\nputs(src);\nfree(copy);", "tide", ["ride", "r"], ["puts(src)", "puts(copy)", "puts(\"r\")"]),
        Dive(90, "Bound the read", "A function receiving an array as a pointer needs a separate length. The loop visits just the provided number of elements.", "int samples[] = {2, 3, 7};\nprintf(\"%d\", total(samples, 2));", "5", ["12", "2"], ["samples, 2", "samples, 1", "samples, 3"], helpers: "int total(const int *p, size_t n) {\n    int s = 0;\n    for (size_t i = 0; i < n; ++i) s += p[i];\n    return s;\n}"),
        Dive(91, "Parse a gauge", "sscanf returns the number of successful assignments. For %d it needs the address of an int destination.", "int n = 0;\nint ok = sscanf(\"17m\", \"%d\", &n);\nprintf(\"%d/%d\", ok, n);", "1/17", ["17/1", "0/0"], ["ok, n", "n, ok", "ok, ok"]),
        Dive(92, "Guard the divisor", "Logical AND evaluates its right side only if the left side is nonzero. This lets the first test guard division.", "int n = 0;\nif (n != 0 && 12 / n > 1) puts(\"Run\");\nelse puts(\"Safe\");", "Safe", ["Run", "0"], ["n = 0", "n = 2", "n = 3"]),
        Dive(93, "Search the grid", "Linear search checks entries in order. Save the index and break as soon as the target is found.", "int v[] = {8, 4, 2, 4};\nint hit = -1;\nfor (int i = 0; i < 4; ++i) {\n    if (v[i] == 4) { hit = i; break; }\n}\nprintf(\"%d\", hit);", "1", ["3", "4"], ["v[i] == 4", "v[i] == 2", "v[i] == 8"]),
        Dive(94, "Rank the tanks", "A running maximum starts with an actual entry. Replace it only when a larger sample is found.", "int v[] = {-5, -2, -8};\nint best = v[0];\nfor (int i = 1; i < 3; ++i)\n    if (v[i] > best) best = v[i];\nprintf(\"%d\", best);", "-2", ["0", "-8"], [" > ", " < ", " == "]),
        Dive(95, "Swap two pods", "A temporary variable holds the first value while the second one is moved. Trace both slots after the swap.", "int a = 2, b = 8;\nint t = a; a = b; b = t;\nprintf(\"%d/%d\", a, b);", "8/2", ["2/8", "8/8"], ["a, b", "b, a", "a, a"]),
        Dive(96, "Bubble pass", "One left-to-right pass swaps adjacent out-of-order entries. The largest value reaches the final position.", "int v[] = {7, 2, 4};\nfor (int i = 0; i < 2; ++i) {\n    if (v[i] > v[i+1]) {\n        int t = v[i]; v[i] = v[i+1]; v[i+1] = t;\n    }\n}\nprintf(\"%d\", v[2]);", "7", ["4", "2"], ["v[2]);", "v[0]);", "v[1]);"]),
        Dive(97, "Bisect the range", "Binary search narrows a sorted interval. If the middle value is smaller than the target, continue to its right.", "int v[] = {2, 4, 7, 9, 12};\nint lo = 0, hi = 4, target = 9;\nwhile (lo < hi) {\n    int mid = lo + (hi - lo) / 2;\n    if (v[mid] < target) lo = mid + 1;\n    else hi = mid;\n}\nprintf(\"%d\", lo);", "3", ["9", "2"], ["target = 9", "target = 7", "target = 12"]),
        Dive(98, "Count active bits", "On each pass, inspect the low bit before shifting the unsigned value right. Stop when no bits remain.", "unsigned m = 13u, n = 0u;\nwhile (m) {\n    n += m & 1u;\n    m >>= 1;\n}\nprintf(\"%u\", n);", "3", ["4", "13"], ["m = 13u", "m = 8u", "m = 3u"]),
        Dive(99, "Packet checksum", "Add the bytes, then keep only the low four bits with an unsigned mask. Trace the accumulator and the mask separately.", "unsigned data[] = {9u, 6u, 5u};\nunsigned sum = 0u;\nfor (int i = 0; i < 3; ++i) sum += data[i];\nprintf(\"%u\", sum & 15u);", "4", ["20", "15"], [" & ", " | ", " ^ "]),
        Dive(100, "Restart the deep", "Combine records, a bounded array traversal and a condition. Sum the power of the ready modules to bring the station online.", "struct Unit { int ready, power; };\nstruct Unit u[] = {{1, 4}, {0, 8}, {1, 7}};\nint sum = 0;\nfor (int i = 0; i < 3; ++i) {\n    if (u[i].ready) sum += u[i].power;\n}\nprintf(\"%d\", sum);", "11", ["19", "8"], ["u[i].ready)", "!u[i].ready)", "1)"])
    ]
}

struct Checkpoint: Codable {
    var phase = -1
    var choice: String?
    var checked = false
    var corrected: Set<Int> = []
}

private struct Expedition: Codable {
    var completed: Set<Int> = []
    var clean: Set<Int> = []
    var resumes: [Int: Checkpoint] = [:]
}

final class DiveLog: ObservableObject {
    private let defaults: UserDefaults
    private let key = "depthbyte.expedition.v1"
    @Published private var expedition: Expedition

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        expedition = defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(Expedition.self, from: $0) } ?? Expedition()
    }

    var count: Int { expedition.completed.count }
    var cleanCount: Int { expedition.clean.count }
    var next: Dive? { Course.dives.first { !done($0) } }
    func done(_ dive: Dive) -> Bool { expedition.completed.contains(dive.id) }
    func unlocked(_ dive: Dive) -> Bool { done(dive) || dive.id == 1 || expedition.completed.contains(dive.id - 1) }
    func secured(in sector: Int) -> Int { Course.dives.filter { $0.sectorIndex == sector && done($0) }.count }
    func checkpoint(for dive: Dive) -> Checkpoint { expedition.resumes[dive.id] ?? Checkpoint() }
    func save(_ state: Checkpoint, for dive: Dive) {
        expedition.resumes[dive.id] = state
        persist()
    }
    func finish(_ state: Checkpoint, for dive: Dive) {
        expedition.completed.insert(dive.id)
        if state.corrected.isEmpty { expedition.clean.insert(dive.id) }
        expedition.resumes.removeValue(forKey: dive.id)
        persist()
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(expedition) { defaults.set(data, forKey: key) }
    }
}
