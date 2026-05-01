# High Achiever

High Achiever is a mobile application built with Flutter, designed to improve productivity, focus, and time management for studying or working through concentration techniques (like Pomodoro), daily goals, and study tools.

## 🚀 Key Features

### ⏱️ Pomodoro Timer (Focus)
- **Focus & Break Sessions:** Alternate between focused work time (Pomodoro) and break time.
- **Customizable Duration:** Adjust the minutes and seconds for both Pomodoros and breaks directly from the settings.
- **Fullscreen Mode:** A clean, immersive interface to help you avoid distractions while studying or working.
- **Flip Mode:** Rotate your phone 180° in fullscreen mode to automatically start the next session without pressing any buttons.
- **Motivational Quotes:** Displays random, famous quotes on the main screen to keep you inspired.
- **Skip Break:** Option to skip your break time and continue working immediately.

### 🎯 Daily Goals & Progress
- **Set Daily Goals:** Define a target number of sessions you want to complete each day.
- **Progress Bar:** Visually track how many sessions you've completed today compared to your daily goal.
- **Session Reset:** Option to manually reset your completed sessions counter.

### 🔔 Sounds & Notifications
- **Local Notifications:** Built-in alerts notify you when your focus session or break is over, even when the app is in the background.
- **Custom Sounds:** Choose from various predefined sound effects to identify the end of a Pomodoro or break.
- **Independent Volume Control:** Adjust the volume of sound effects directly within the app's settings.

## 🛠️ Technologies Used
- **State Management:** Provider
- **Local Storage:** SharedPreferences (for saving settings, progress, and goals)
- **Audio:** Audioplayers (for alert playback)
- **Sensors:** Sensors_plus (used for device rotation detection in Flip Mode)
- **Notifications:** Flutter Local Notifications and Timezone
- **Keep Awake:** Wakelock_plus (to prevent the device from sleeping during focus mode)
