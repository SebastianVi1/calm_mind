# Mental Health Reports System

## Structure

### Firebase Data (`patient_reports` collection)

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
      "executiveSummary": "string",
      "riskLevel": "low|medium|high",
      "recommendations": ["string"],
      "wellnessScore": "number",
      "questionnaireAnswers": ["string"]
    }
  ]
}
```

### Key Components

1. **Models**

   - `PatientReportModel`: Report data structure

2. **Services**

   - `PatientReportService`: AI report generation
   - `PatientReportRepository`: Firebase operations

3. **ViewModels**
   - `PatientReportViewModel`: Business logic and state

### Flow

1. User completes questionnaire
2. AI generates report
3. Report saved to Firebase
4. User can view report

### Risk Levels

- **Low**: Good mental health
- **Medium**: Needs attention
- **High**: Immediate attention required

### Configuration

- Requires DeepSeek API key in .env
- Firebase setup for storage
