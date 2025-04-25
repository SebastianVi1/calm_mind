import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/mood_lottie_title.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';

class StadisticsScreen extends StatefulWidget {
  const StadisticsScreen({super.key});

  @override
  State<StadisticsScreen> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<StadisticsScreen> {
  Set<String> _selectedOption = {'todos'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(
          color: Colors.blue
        ),
      ),
      body: Consumer<MoodViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildInfoContainer(context, viewModel),
                _buildChart(context, viewModel),
                _buildMoodCard(context, viewModel),
              ]
            )
          );
        }
      )
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodViewModel viewModel) {
    if (viewModel.moodHistory.isEmpty) {
      return Expanded(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            
            child: Lottie.asset('assets/animations/meditation.json',width: 200,)
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Text(
            'Todas las notas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              
            ),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'hoy',
                  label: Text('Hoy'),
                  icon: Icon(Icons.today),
                ),
                ButtonSegment<String>(
                  value: 'semanal',
                  label: Text('Semanal'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment<String>(
                  value: 'todos',
                  label: Text('Todos'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: _selectedOption,
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedOption = newSelection;
                  
                });
              },
              style: ButtonStyle(
                
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).primaryColor.withOpacity(0.2);
                    }
                    return null;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return Theme.of(context).textTheme.bodyLarge?.color;
                  },
                ),
                side: WidgetStateProperty.resolveWith<BorderSide?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      );
                    }
                    return BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    );
                  },
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filterMoods(_selectedOption.first).length,
              itemBuilder: (context, index) {
                final actualMood = viewModel.filterMoods(_selectedOption.first)[index];
                final date = actualMood.timestamp;
                final dateString = '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}';
                
                return FadeInRight(

                  config: BaseAnimationConfig(
                      useScrollForAnimation: true,
                      delay: 2000.ms,
                      curves: Curves.easeInOut,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Lottie.asset(
                              actualMood.lottieAsset,
                              animate: false,
                              frameRate: FrameRate.max,
                            ),
                            title: Text(
                              actualMood.label,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: actualMood.color,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5
                              ),
                            ),
                            subtitle: Text(
                              dateString,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                            ),
                          ),
                          if (actualMood.note != null) 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Text(
                                  actualMood.note!,
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    )
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(BuildContext context, MoodViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu progreso este mes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.getMoodTrend(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, MoodViewModel viewModel) {
    return AspectRatio(
      aspectRatio: 1.9,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          /// Line chart configuration for displaying mood data
          /// - X axis: Days of the month (1-31)
          /// - Y axis: Mood values (1-4)
          ///   - 4: Happy
          ///   - 3: Neutral
          ///   - 2: Angry
          ///   - 1: Sad
          LineChartData(
            maxX: 31,
            minX: 1,
            maxY: 4,
            minY: 1,
            lineBarsData: [
              LineChartBarData(
                spots: viewModel.getMoodChartData(),

                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withAlpha(100),
                    Theme.of(context).primaryColor,
                  ],
                ),
                barWidth: 4,
                isCurved: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 8,
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.3),
                      Theme.of(context).primaryColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MoodLottieTitle(value: value),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    String mood = '';
                    if (flSpot.y >= 4.0) {mood = 'Happy';}
                    else if (flSpot.y >= 2.5) {mood = 'Neutral';}
                    else if (flSpot.y >= 1.5) {mood = 'Angry';}
                    else {mood = 'Sad';}
                    
                    return LineTooltipItem(
                      'Day ${flSpot.x.toInt()}\n$mood',
                      TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold, 
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  
  }
}