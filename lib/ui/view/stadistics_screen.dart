import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/emotions_screen.dart';

import 'package:calm_mind/ui/widgets/mood_lottie_title.dart';
import 'package:calm_mind/viewmodels/mood_view_model.dart';


class StadisticsScreen extends StatefulWidget {
  const StadisticsScreen({super.key});

  @override
  State<StadisticsScreen> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<StadisticsScreen> {
  int _currentChartPage = 0;
  
  late PageController _chartsPageController;

  @override
  void initState() {
    super.initState();
    _chartsPageController = PageController();
    
    
    _chartsPageController.addListener(() {
      int page = _chartsPageController.page?.round() ?? 0;
      if (page != _currentChartPage) {
        setState(() {
          _currentChartPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _chartsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
      ),
      body: Consumer<MoodViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildInfoContainer(context, viewModel),
                _buildChartsScrollView(context, viewModel),
                const SizedBox(height: 10,),
                  FilledButton(
                  onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => EmotionsScreen()));},
                  child: Text(
                    'Ver historial de emaciones y notas'
                  ),
                )
              ]
            )
          );
        }
      )
    );
  }
  
  Widget _buildChartsScrollView(BuildContext context, MoodViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView(
            controller: _chartsPageController,
            physics: const PageScrollPhysics(),
            children: [
              _buildPieChart(context, viewModel),
              
              _buildLineChart(context, viewModel),
            ],
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 2; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i != _currentChartPage 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ],
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

  Widget _buildLineChart(BuildContext context, MoodViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tendencia mensual de tu estado de ánimo',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AspectRatio(
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
                          Colors.orange,
                          Colors.red,
                          Colors.purple
                        ],
                      ),
                      barWidth: 4,
                      isCurved: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Theme.of(context).colorScheme.secondary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary.withAlpha(80),
                            Theme.of(context).primaryColor,
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
                        color: Theme.of(context).dividerColor.withAlpha(50),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withAlpha(50),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, MoodViewModel viewModel){
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Registros historicos de estados de animo',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.4,
            child: PieChart(
              PieChartData(

                pieTouchData: PieTouchData(

                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse ) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null){
                        viewModel.setTouchedIndex(-1);
                        return;
                      }
                      viewModel.setTouchedIndex(pieTouchResponse.touchedSection!.touchedSectionIndex);
                    });
                  }
                ),
               
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(context),
              ),
              duration: Duration(milliseconds: 150),
              curve: Curves.easeInQuad,

            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }


  List<PieChartSectionData> showingSections(BuildContext context) {

    var viewModel = Provider.of<MoodViewModel>(context);
    var map = viewModel.logicPieChart(viewModel);
    final Map<String, int> valuesMap = context.read<MoodViewModel>().logicPieChart(viewModel);
    return List.generate(4, (i) {
      
      final isTouched = i ==  viewModel.tochedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 150.0 : 130.0;
      final widgetSize = isTouched ? 65.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: valuesMap['happy']!.toDouble(),
            title: '${viewModel.porcentage('happy').toStringAsFixed(2)} %',

            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              isTouched: isTouched,
              'assets/animations/happy_emoji.json',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: valuesMap['neutral']!.toDouble(),
            title: '${viewModel.porcentage('neutral').toStringAsFixed(2)} %',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              isTouched: isTouched,
              'assets/animations/neutral_emoji.json',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red,
            value: valuesMap['angry']!.toDouble(),
            title: '${viewModel.porcentage('angry').toStringAsFixed(2)} %',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              isTouched: isTouched,
              'assets/animations/angry_emoji.json',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            
            badgePositionPercentageOffset: .98,
          );
        case 3:
          return PieChartSectionData(
            color: Colors.green,
            value: valuesMap['sad']!.toDouble(),
            title: "${viewModel.porcentage('sad').toStringAsFixed(2)} %",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              isTouched: isTouched,
              'assets/animations/sad_emoji.json',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Exception('Oh no');
      
      }
    });
  }

  
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.asset, {
    required this.size,
    required this.borderColor,
    required this.isTouched,
  });
  final String asset;
  final double size;
  final Color borderColor;
  final bool isTouched;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Lottie.asset(asset,animate: isTouched ? true : false)
      ),
    );
  }
}

