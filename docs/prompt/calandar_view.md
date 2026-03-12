### **The "Infinite Weekly Calendar" Prompt (V2)**

**Task:** Create a Flutter `StatelessWidget` for a high-fidelity, infinite horizontal weekly calendar slider.

**Architecture & Logic:**
* **Infinite Scroll:** Use a `PageView.builder` with a high virtual center index (e.g., 10,000). This allows infinite scrolling into the past and future by calculating dates mathematically based on the `index` rather than storing them in a list.
* **State Management:** Do **not** use a `StatefulWidget`. Use `ValueNotifier` and `ValueListenableBuilder` to handle UI updates (like the header text) to keep the widget lightweight and performant.

**Dynamic Header Logic:**
* **Date Display:** Show the month name and the last day of the currently visible week.
* **Conditional Year:** Implement logic to check if the visible year is the current year. Display the year (e.g., "Dec 31, 2025") **only if** it differs from the current year; otherwise, show only the month and day (e.g., "Mar 12").

**Interface & Style:**
* **Controls:** Include two arrow icons (`Icons.arrow_back_ios_new_rounded` and `Icons.arrow_forward_ios_rounded`) that programmatically control the `PageController` with an `easeInOut` curve and a duration of 300ms.
* **Glassmorphism Aesthetic:** Design the daily cards with a minimalist, high-end look: translucent white backgrounds (`opacity`), thin borders, and rounded corners (`BorderRadius.circular(12)`).
* **Today Highlight:** Visually distinguish the "Today" card using a specific color accent (e.g., `blueAccent` with low opacity background).

**Output:** Provide clean, production-ready Dart code using modern Flutter best practices.