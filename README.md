# AI Insights Platform - Flutter Web Frontend

A modern, responsive Flutter web application for uploading datasets and viewing AI-generated insights.

## 🚀 Features

- **Modern UI**: Clean, Material Design 3 interface with smooth animations
- **File Upload**: Drag-and-drop file upload with validation
- **Data Preview**: Interactive table showing first 5 rows of uploaded data
- **Real-time Processing**: Live status updates during insight generation
- **Interactive Insights**: Detailed insight cards with confidence indicators
- **Responsive Design**: Works seamlessly across different screen sizes
- **Error Handling**: Comprehensive error handling with user-friendly messages

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Chrome or other modern web browser

### Installation

1. **Create Flutter Project**
```bash
flutter create ai_insights_platform
cd ai_insights_platform
```


2. **Install Dependencies**
```bash
flutter pub get
```

3. **Run the Application**
```bash
flutter run -d chrome --web-port 3000
```

## 📱 Usage Flow

1. **Upload File**: Click or drag-and-drop a CSV/Excel file
2. **Preview Data**: Review the first 5 rows of your dataset
3. **Generate Insights**: Click "Generate Insights" to start analysis
4. **View Results**: Explore AI-generated insights with confidence scores

## 🎨 UI Components

### File Upload Widget
- Drag-and-drop interface
- File validation (type, size)
- Upload progress indication
- Error handling with user feedback

### Data Preview Widget
- Responsive data table
- Column headers with styling
- Overflow handling for large datasets
- Row count indicator

### Insight Card Widget
- Category-based color coding
- Confidence score visualization
- Interactive details dialog
- Affected columns/rows display

### Loading Widget
- Animated loading indicators
- Status messages
- Progress tracking
- Smooth transitions

## 🔧 Configuration

### API Configuration
Edit `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

### UI Customization
Modify colors, fonts, and animations in `constants.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1);
static const Duration mediumAnimation = Duration(milliseconds: 400);
```

## 🏗️ Architecture

```
Frontend Architecture:
├── Screens (UI Pages)
├── Widgets (Reusable Components)  
├── Services (API Communication)