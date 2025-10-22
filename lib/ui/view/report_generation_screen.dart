import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/patient_report_model.dart';
import '../../viewmodels/patient_report_view_model.dart';
import 'main_screen.dart';
import 'patient_report_screen.dart';

/// Screen that shows the report generation progress
class ReportGenerationScreen extends StatefulWidget {
  final Future<PatientReportModel> reportFuture;

  const ReportGenerationScreen({
    super.key,
    required this.reportFuture,
  });

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
  PatientReportModel? _generatedReport;
  String? _errorMessage;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    try {
      final report = await widget.reportFuture;
      if (mounted) {
        setState(() {
          _generatedReport = report;
          _isGenerating = false;
        });
        
        // Navigate to report screen after a brief delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReportTransitionScreen(report: report),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGenerating) ...[
                _buildGeneratingContent(context),
              ] else if (_errorMessage != null) ...[
                _buildErrorContent(context),
              ] else if (_generatedReport != null) ...[
                _buildSuccessContent(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingContent(BuildContext context) {
    return Column(
      children: [
        // Loading animation
        SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/animations/loading.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        
        // Title
        Text(
          'Generando tu Reporte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Description
        Text(
          'Nuestra IA está analizando tus respuestas para crear un reporte personalizado de tu salud mental.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Progress indicator
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Esto puede tomar unos momentos...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 32),
        
        Text(
          '¡Reporte Generado!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        Text(
          'Tu reporte de salud mental ha sido creado exitosamente. Redirigiendo...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      children: [
        // Error icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 32),
        
        Text(
          'Error al Generar Reporte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        Text(
          _errorMessage ?? 'Ocurrió un error inesperado',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGenerating = true;
                  _errorMessage = null;
                });
                _generateReport();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Transition screen that shows the generated report
class ReportTransitionScreen extends StatelessWidget {
  final PatientReportModel report;

  const ReportTransitionScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assessment,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                '¡Reporte Listo!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Tu análisis de salud mental está completo. Descubre tus resultados y recomendaciones personalizadas.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Button to view the report
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientReportScreen(report: report),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ver Mi Reporte',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Button to go to home
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Ir al Inicio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Button to view all reports
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => PatientReportViewModel()..loadUserReports(),
                          child: const PatientReportsListScreen(),
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Text(
                    'Ver Todos Mis Reportes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
