import SwiftUI
import CoreLocation
import AVFoundation
import AppKit

// MARK: - Diagnostic Model
struct Diagnostic {
let name: String
let symptoms: [String]
let recommendation: String
let emergencyContact: String
}

// MARK: - Patient Model
struct Patient {
let name: String
let age: Int
var pulse: Int
var temperature: Double
var menopause: Bool
var diagnoses: [Diagnostic]
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
@Published var userLocation: CLLocationCoordinate2D?
private var manager = CLLocationManager()

override init() {
super.init()
manager.delegate = self
manager.requestWhenInUseAuthorization()
manager.startUpdatingLocation()
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
userLocation = locations.last?.coordinate
}
}

// MARK: - Speech Helper
class SpeechHelper {
private let synthesizer = AVSpeechSynthesizer()

func speak(_ text: String) {
let utterance = AVSpeechUtterance(string: text)
utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
utterance.rate = 0.45
utterance.volume = 1.0
synthesizer.speak(utterance)
}
}

// MARK: - Sample Diagnoses
let cardiologyDiagnoses: [Diagnostic] = [
Diagnostic(name: "Angina Pectoris",
symptoms: ["chest pain", "pressure", "fatigue"],
recommendation: "Stop activity, rest, use nitroglycerin if prescribed, take aspirin 75mg, call 112 if pain persists.",
emergencyContact: "Call 112 immediately if chest pain lasts more than 15 minutes."),
Diagnostic(name: "Myocardial Infarction",
symptoms: ["severe chest pain", "nausea", "sweating", "shortness of breath"],
recommendation: "Take aspirin, call 112 immediately. Life-threatening emergency.",
emergencyContact: "Emergency — Call 112 NOW."),
Diagnostic(name: "Chronic Heart Failure",
symptoms: ["swollen legs", "shortness of breath", "fatigue"],
recommendation: "Reduce salt and fluids, take prescribed diuretics (furosemide 40mg).",
emergencyContact: "Call 112 if severe shortness of breath."),
Diagnostic(name: "Pulmonary Edema",
symptoms: ["severe shortness of breath", "restlessness"],
recommendation: "Sit upright, call 112 immediately.",
emergencyContact: "Call 112 — medical emergency."),
Diagnostic(name: "Syncope",
symptoms: ["fainting", "loss of consciousness", "paleness"],
recommendation: "Lay the person on their side, call 112 if unconscious.",
emergencyContact: "Call 112 immediately."),
Diagnostic(name: "Lipothymia",
symptoms: ["lightheadedness", "dizziness"],
recommendation: "Sit or lie down, hydrate, call family if needed.",
emergencyContact: "Call family or 112 if condition worsens."),
Diagnostic(name: "Aortic Dissection",
symptoms: ["severe chest pain", "unequal pulse", "blood pressure difference"],
recommendation: "Call 112 immediately, remain calm, avoid movement.",
emergencyContact: "Call 112."),
Diagnostic(name: "Acute Limb Ischemia",
symptoms: ["leg pain", "cold leg", "absent pulse"],
recommendation: "Elevate leg, avoid massage/heat, call 112.",
emergencyContact: "Call 112 urgently."),
Diagnostic(name: "Thrombophlebitis",
symptoms: ["leg pain", "swelling", "tenderness"],
recommendation: "Elevate leg, cold compress, consult doctor, call 112 if severe.",
emergencyContact: "Call 112 if symptoms worsen."),
Diagnostic(name: "Pulmonary Embolism",
symptoms: ["shortness of breath", "agitation", "fainting"],
recommendation: "Call 112 urgently, diagnostic imaging, anticoagulant treatment.",
emergencyContact: "Call 112."),
Diagnostic(name: "Stroke",
symptoms: ["face paralysis", "speech difficulty", "arm weakness"],
recommendation: "Lay patient on side, call 112 immediately.",
emergencyContact: "Call 112."),
Diagnostic(name: "Cardiac Arrest",
symptoms: ["no pulse", "not breathing", "unconscious"],
recommendation: "Start CPR, call 112.",
emergencyContact: "Call 112 immediately."),
Diagnostic(name: "Endocarditis",
symptoms: ["fever", "fatigue", "shortness of breath", "heart murmur"],
recommendation: "Seek medical attention immediately, call 112 if severe.",
emergencyContact: "Call 112."),
Diagnostic(name: "Menopause-related Fainting",
symptoms: ["dizziness", "hot flashes", "syncope"],
recommendation: "Sit or lie down immediately, hydrate, call family and monitor pulse.",
emergencyContact: "Call children/family and 112 if unconscious.")
]

// MARK: - Sample Patient
var patient = Patient(
name: "Jane Doe",
age: 62,
pulse: 78,
temperature: 36.8,
menopause: true,
diagnoses: cardiologyDiagnoses
)

// MARK: - Main ContentView
struct ContentView: View {
@State private var inputSymptoms = ""
@State private var result = ""
@State private var tapCount = 0
@State private var emergencyAlert = false
@State private var familyAlert = false
@State private var fallAlert = false

@ObservedObject var locationManager = LocationManager()
@Environment(\.openURL) var openURL
let speech = SpeechHelper()

var body: some View {
NavigationView {
ScrollView {
VStack(spacing: 25) {
Text("🫀 SilverCare+ Geriatric Assistant")
.font(.system(size: 30, weight: .bold))
.multilineTextAlignment(.center)

Divider()

VStack(alignment: .leading, spacing: 10) {
Text("👤 Patient: \(patient.name)").font(.system(size: 24, weight: .bold))
Text("🎂 Age: \(patient.age)").font(.system(size: 24, weight: .bold))
Text("💓 Pulse: \(patient.pulse) bpm")
.font(.system(size: 24, weight: .bold))
.foregroundColor(patient.pulse < 60 || patient.pulse > 100 ? .red : .green)
Text("🌡️ Temperature: \(String(format: "%.1f", patient.temperature)) °C")
.font(.system(size: 24, weight: .bold))
.foregroundColor(patient.temperature > 37.5 ? .orange : .blue)
Text("⚠️ Menopause: \(patient.menopause ? "Yes" : "No")")
.font(.system(size: 24, weight: .bold))
.foregroundColor(patient.menopause ? .purple : .gray)
}
.padding()
.background(Color.gray.opacity(0.2))
.cornerRadius(12)

TextField("Enter symptoms separated by commas", text: $inputSymptoms)
.font(.system(size: 20))
.textFieldStyle(RoundedBorderTextFieldStyle())
.padding(.horizontal)

Button(action: {
result = checkSymptoms(input: inputSymptoms)
speech.speak("Analyzing symptoms.")
}) {
Text("🔍 Check Diagnosis")
.font(.system(size: 24, weight: .bold))
.padding()
.frame(maxWidth: .infinity)
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(12)
}
.padding(.horizontal)

if !result.isEmpty {
Text(result)
.font(.system(size: 20, weight: .medium))
.padding()
.foregroundColor(.blue)
.multilineTextAlignment(.leading)
}

if let location = locationManager.userLocation {
VStack {
Text("📍 Location:").font(.system(size: 20, weight: .bold))
Text("Lat: \(location.latitude), Lon: \(location.longitude)")
.font(.system(size: 16))
.foregroundColor(.gray)
}
} else {
Text("📍 Locating patient...")
.font(.system(size: 16))
.foregroundColor(.gray)
}

// MARK: - Necklace Emergency Button
Button(action: handleNecklaceTap) {
Text("📿 Emergency Button")
.font(.system(size: 26, weight: .bold))
.padding()
.frame(maxWidth: .infinity)
.background(Color.purple)
.foregroundColor(.white)
.cornerRadius(14)
}
.alert("📞 Family Call", isPresented: $familyAlert) {
Button("OK", role: .cancel) {}
} message: {
Text("Calling family contact...")
}
.alert("🚨 Ambulance", isPresented: $emergencyAlert) {
Button("Call 112", role: .destructive) {
call(number: "112")
speech.speak("Calling ambulance now.")
}
Button("Cancel", role: .cancel) {}
} message: {
Text("Emergency activated. Ambulance on the way.")
}
}
.padding()
.onChange(of: patient.pulse) { newValue in
// Fall / menopause alert
if newValue < 40 || (patient.menopause && newValue < 50) {
fallAlert = true
speech.speak("Fall detected due to menopause or cardiac issue. Calling children and ambulance.")
}
}
.alert("🚑 Fall Detected", isPresented: $fallAlert) {
Button("Call 112", role: .destructive) {
call(number: "112")
}
} message: {
Text("Fall or cardiac/menopause emergency detected — children alerted and ambulance dispatched.")
}
}
.navigationTitle("SilverCare+")
}
}

// MARK: - Tap Logic
func handleNecklaceTap() {
tapCount += 1
DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
if tapCount == 1 {
familyAlert = true
speech.speak("Calling family contact.")
call(number: "07xxxxxxxx") // replace with actual family number
} else if tapCount == 2 {
emergencyAlert = true
speech.speak("Calling ambulance now.")
call(number: "112")
}
tapCount = 0
}
}

func call(number: String) {
   let phone = "tell://\(number)"
    
    if let url = URL(string: phone){
        NSWorkspace.shared.open(url)
  }
}

// MARK: - Symptom Checking
func checkSymptoms(input: String) -> String {
let patientSymptoms = input.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
var output = ""
var found = false

for d in patient.diagnoses {
var score = 0
for s in d.symptoms {
if patientSymptoms.contains(where: { $0.contains(s) }) {
score += 1
}
}
if score >= 2 {
output += "\n📋 Possible Diagnosis: \(d.name)"
output += "\n💡 Recommendation: \(d.recommendation)"
output += "\n📞 \(d.emergencyContact)\n"
found = true
}
}

if !found {
output += "\n❗ No clear diagnosis found. Contact your doctor or caregiver."
}

return output
}
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
static var previews: some View {
ContentView()
}
}
