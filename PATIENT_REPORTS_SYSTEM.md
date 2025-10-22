# Mental Health Reports System with AI

## General Description

This system allows generating detailed mental health reports using artificial intelligence (DeepSeek) to analyze responses from the initial evaluation questionnaire. Reports are stored in Firebase and provide personalized analysis, recommendations and next steps for each user.

## System Architecture

### Main Components

1. **PatientReportModel** (`lib/models/patient_report_model.dart`)
   - Data model that represents a complete report
   - Includes analysis, risk level, recommendations and wellness score
   - Support for JSON serialization and Firebase

2. **PatientReportService** (`lib/services/patient_report_service.dart`)
   - Service that handles communication with DeepSeek API
   - Generates reports using AI based on questionnaire responses
   - Processes and validates AI responses

3. **PatientReportRepository** (`lib/repositories/patient_report_repository.dart`)
   - Handles storage and retrieval of reports in Firebase
   - CRUD operations for user reports
   - Statistics and date filters

4. **PatientReportViewModel** (`lib/viewmodels/patient_report_view_model.dart`)
   - ViewModel that handles report business logic
   - Application state and service communication
   - Error handling and loading states

### User Screens

1. **PatientReportScreen** (`lib/ui/view/patient_report_screen.dart`)
   - Shows the detailed patient report
   - Includes complete analysis, recommendations and next steps
   - Responsive design with custom widgets

2. **PatientReportsListScreen** (`lib/ui/view/patient_report_screen.dart`)
   - Lists all user reports
   - Allows navigation to specific reports
   - Refresh functionality and error handling

3. **ReportGenerationScreen** (`lib/ui/view/report_generation_screen.dart`)
   - Loading screen during report generation
   - Animations and visual feedback
   - Error handling and retry options

### Custom Widgets

1. **ReportCardWidget** (`lib/ui/widgets/report_widgets.dart`)
   - Reusable card for displaying report sections
   - Customizable icons and titles

2. **RiskLevelIndicator** (`lib/ui/widgets/report_widgets.dart`)
   - Shows risk level with colors and icons
   - Contextual description of risk level

3. **WellnessScoreWidget** (`lib/ui/widgets/report_widgets.dart`)
   - Visualizes wellness score (0-100)
   - Dynamic colors based on score

## Report Generation Flow

### 1. Complete Questionnaire
- User answers the 10 mental health questionnaire questions
- Answers are validated before proceeding

### 2. AI Generation
- Detailed prompt is built with user responses
- Sent to DeepSeek API for analysis
- AI generates structured report in JSON

### 3. Processing and Storage
- AI response is parsed
- PatientReportModel is created with all data
- Saved to Firebase Firestore

### 4. Visualization
- Generation screen is shown with progress
- Upon completion, navigates to detailed report
- User can access reports from menu

## Integration with Existing System

### Modifications Made

1. **QuestionViewModel** (`lib/viewmodels/question_view_model.dart`)
   - Added `saveAnswersAndGenerateReport()` method
   - Integration with report services

2. **QuestionWidget** (`lib/ui/widgets/question_widget.dart`)
   - Modified "Finish" button to generate report
   - Navigation to generation screen

3. **EndDrawer** (`lib/ui/widgets/end_drawer.dart`)
   - Added "My Reports" option in menu
   - Navigation to report list

## Firebase Data Structure

### Collection: `patient_reports`
```json
{
  "userId": "string",
  "createdAt": "timestamp",
  "lastUpdated": "timestamp",
  "reports": [
    {
      "id": "uuid",
      "userId": "string",
      "createdAt": "timestamp",
      "lastUpdated": "timestamp",
      "executiveSummary": "string",
      "symptomAnalysis": "string",
      "riskLevel": "low|medium|high",
      "recommendations": ["string"],
      "suggestedResources": ["string"],
      "nextSteps": "string",
      "additionalNotes": "string",
      "wellnessScore": "number",
      "questionnaireAnswers": ["string"],
      "questionnaireDate": "timestamp"
    }
  ]
}
```

## Required Configuration

### Environment Variables
- `DEEPSEEK_API_KEY`: DeepSeek API key for generating reports

### Dependencies
- `http`: For communication with DeepSeek API
- `uuid`: For generating unique IDs
- `flutter_dotenv`: For environment variables
- `lottie`: For animations

## System Features

### AI Analysis
- Professional evaluation of mental symptoms
- Identification of behavior patterns
- Risk analysis based on responses

### Risk Levels
- **Low**: Positive indicators of wellness
- **Medium**: Some areas require attention
- **High**: Requires immediate attention

### Personalized Recommendations
- Specific strategies based on analysis
- Suggested resources (therapy, support groups, etc.)
- Clear and actionable next steps

### Security and Privacy
- Data stored securely in Firebase
- Authentication required to access reports
- Anonymous user handling

## System Usage

### For Users
1. Complete the mental health questionnaire
2. Wait for report generation (30-60 seconds)
3. Review analysis and recommendations
4. Access previous reports from menu

### For Developers
1. System integrates automatically with existing flow
2. Reports are generated when questionnaire is completed
3. Navigation is handled automatically
4. Errors are shown with clear messages

## Future Considerations

### Potential Improvements
- Export reports to PDF
- Share reports with health professionals
- Progress history over time
- Notifications for follow-up
- Calendar integration for appointments

### Scalability
- System is designed to handle multiple users
- Reports are stored efficiently in Firebase
- AI generation is scalable with DeepSeek

## Support and Maintenance

### Monitoring
- Error logs in report generation
- DeepSeek API usage metrics
- Generated reports statistics

### Updates
- AI prompt improvements for more accurate analysis
- New features based on user feedback
- Performance optimizations
