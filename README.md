# 🔐 W-Secure

**W-Secure** is a hybrid project that combines mobile app-based safety features with AI-powered CCTV surveillance to enhance women's safety in public and private spaces.

---

## 📱 Mobile App Features

The **W-Secure Android App** is designed with discreet but powerful security tools to help women in distress:

- 🛰️ **Live Location Sharing**: Send real-time location updates to emergency contacts instantly.
- ☎️ **Quick Helpline Calling**: One-tap call to predefined emergency numbers.
- 🎥 **Stealth Video Recording**: Automatically records video in the background without opening the camera UI. The footage is stored on a secure cloud server to prevent tampering or deletion.
- 🗺️ **Safe Space Mapping**: View and mark nearby safe zones where help can be sought.
- 🆘 **SOS Mode**: Emergency trigger button that shares live location with trusted contacts and initiates other security protocols.
- 🔒 **Shutdown Protection**: Prevents unauthorized attempts to power off the phone during an emergency.

> 🔄 **Update in Progress**: We are currently working on making the **location-based Safe Space detection more dynamic**, with deeper analysis of surrounding areas using geofencing and real-time data.

---

## 🧠 AI-Powered CCTV Monitoring (Backend Model)

The backend AI system is designed to integrate with CCTV feeds in public spaces and includes the following capabilities:

- 👥 **Suspicious Following Detection**:
  - Tracks individuals and identifies situations where one woman is being followed by a group of men.
  - Uses object detection and person tracking models to analyze motion patterns.

- ✋ **Distress Gesture Recognition**:
  - Recognizes gestures such as raised hands or rapid arm movements that may indicate distress.
  - Uses lightweight gesture recognition models based on MediaPipe or custom CNN-RNN architectures.

- 🚨 **Alert Triggering**:
  - When a threat is detected, the system can trigger automated alerts to local authorities or monitoring teams.

---

## 🧩 Tech Stack

### 📱 Mobile App:
- **Platform**: Android (Java/Kotlin/Flutter)
- **Backend**: Firebase (Realtime DB, Storage, Authentication)
- **APIs**: Google Maps, Geolocation Services
- **Cloud**: Firebase/Google Cloud for media storage

### 🧠 AI Models:
- **YOLOv8**: For real-time person detection.
- **ResNet-50**: For gender classification.
- **MediaPipe**: For gesture detection.
- **OpenCV & DeepSORT**: For multi-person tracking in CCTV feeds.

---

## 🚧 Current Work & Future Plans

- [x] Implement background video recording with stealth mode.
- [x] Enable live SOS location sharing.
- [x] Integrate Safe Space tagging on maps.
- [ ] Make Safe Space detection more dynamic using clustering and live crowd data.
- [ ] Deploy AI model on edge devices/CCTV systems.
- [ ] Improve gesture recognition accuracy.
- [ ] Create centralized admin dashboard for authorities.


---

## 🤝 Contributing

We welcome contributions and collaborations from developers, researchers, and security experts. If you're passionate about using AI and tech for social good, feel free to open a pull request or reach out.

---

## 📫 Contact

- 📧 Email: [mayanksharma4352@gmail.com]
- 🧑‍💻 Developer: [Mayank Sharma]
- 🔗 LinkedIn: [[Mayank4352](https://www.linkedin.com/in/mayank4352/)]

---

## ⚠️ Disclaimer

This project is built with the intention of helping people and enhancing safety. The AI-based surveillance is intended for **authorized and ethical use only** and must comply with local data privacy laws and regulations.

---
