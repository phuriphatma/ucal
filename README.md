# ucal - Universal Calculator

A web-based calculator application with multiple tools:

## Features

### 1. GA Calculator (Gestational Age Calculator)
- Calculate gestational age from Last Menstrual Period (LMP)
- Calculate Expected Date of Confinement (EDC)
- Interactive pregnancy wheel
- Calendar view for date selection
- Support for known GA calculations

### 2. Average Calculator
- **Smart input system** with configurable number of initial input boxes
- **Configurable decimal precision** (0, 1, or 2+ decimals)
- **Automatic cursor jumping** based on decimal precision settings
- **Backspace navigation** between input boxes
- **Manual input management** - users control when to add more boxes
- **Individual clear buttons** for each input box
- **Clear all button** to reset all inputs at once
- **Live average calculation** displayed at the top
- **Support for pasting** multiple numbers

### 3. Settings
- **Default box count**: Configure how many input boxes to show initially (1-10)
- **Default decimal precision**: Set your preferred precision level (0-5 decimals)
- **Default starting tab**: Choose which tab opens first (GA Calculator or Average Calculator)
- **Persistent settings**: Your preferences are saved in the browser
- **Reset to defaults**: Easy way to restore original settings

## Mobile & Offline Features

### 📱 Mobile Optimized
- **Numeric keyboard**: Automatically shows number input keyboard on mobile devices
- **Viewport optimization**: Average result stays visible when keyboard appears
- **Touch-friendly interface**: All controls work perfectly on touch devices
- **Responsive design**: Adapts to different screen sizes

### 🔄 Offline Support
- **Progressive Web App (PWA)**: Can be installed on your device like a native app
- **Works offline**: Once loaded, the app works without internet connection
- **Auto-caching**: Automatically caches all necessary files for offline use
- **Service Worker**: Ensures fast loading and offline functionality

## How to Use

### Average Calculator
1. **Configure Settings**: Go to Settings tab to set your preferred defaults
2. **Select decimal precision**: Choose 0, 1, or 2+ decimals
3. **Enter numbers**: Type in the input boxes - cursor will jump automatically based on precision
4. **Navigation**: Use backspace to move to previous boxes
5. **Manage inputs**: Use "Clear" to clear individual boxes or "Clear All" for all boxes
6. **Add more boxes**: Click "Add More Box" button when needed
7. **View results**: Average is displayed at the top and updates in real-time

### Settings Configuration
- **Default Number of Input Boxes**: Choose how many boxes to start with (1-10)
- **Default Decimal Precision**: Set your preferred precision (0-5 decimals)
- Settings are automatically saved and will be remembered on your next visit

## Development

To run the project locally:

1. Clone the repository
2. Open the project in VS Code
3. Run the "Start Live Server" task (Ctrl+Shift+P → Tasks: Run Task → Start Live Server)
4. Open http://localhost:8000 in your browser

## Technologies Used

- HTML5
- CSS3
- Vanilla JavaScript
- Local Storage (for settings persistence)
- Flatpickr (for date picking)
- SVG (for pregnancy wheel)