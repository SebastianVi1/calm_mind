import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:calm_mind/ui/view/meditation_picker.dart';
import 'package:calm_mind/ui/view/relaxing_music_picker.dart.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';



class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Foro',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          // Botón para abrir el drawer global
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => openGlobalEndDrawer(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _meditatioRoomCards(context),
        ],
      )
    );
  }

  Widget _meditatioRoomCards(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 10,
        children: [
          InkWell( // Meditation room card
            
            borderRadius: BorderRadius.circular(8),
            splashColor: Theme.of(context).colorScheme.primary.withAlpha(120),
            highlightColor: Theme.of(context).colorScheme.primary.withAlpha(25),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Proximamente...'),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.blue[400],
                  
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                    
                    blurRadius: 4,
                    offset: Offset(3,5)
                    
                  )
                ],
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFECD2),
                    Color(0xFFFCB69F)
                  ]
              )
            ),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Lottie.asset(
                      'assets/animations/meditation_room.json',
                      fit: BoxFit.cover
                    ),
                  ),
                  
                  Text(
                    'Unirse a una sala de meditacion',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            spacing: 10,
            children: [
              Expanded( // Relaxing card
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                        
                        blurRadius: 4,
                        offset: Offset(3,5)
                        
                      )
                    ],
                    gradient: LinearGradient(colors: [Colors.purple, Colors.deepOrange, Colors.orange]),
                    borderRadius: BorderRadius.circular(16)
                  ),
                   child: Column(
                    spacing: 5,
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        child: Lottie.asset('assets/animations/music_hearing.json',width: 100),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Relajacion',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Musica',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '3-10 MIN',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          SizedBox(
                            height: 40,
                            
                            child: FilledButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                              
                              ),
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RelaxingMusicPicker()));
                              },
                              child: HugeIcon(icon: HugeIcons.strokeRoundedPlay, color: Colors.white)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,)
                
                    ],
                   ),
                ),
              ),
              Expanded( //Meditation card
                child: Container(
                  
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0,1)
                        
                      )
                    ],
                    gradient: LinearGradient(colors: [Color(0xFFD8B5FF), Color(0xFF1EAE98)]),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                
                        alignment: Alignment.topRight,
                        child: Lottie.asset('assets/animations/focus_brain.json', 
                        width: 100
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Concentrate',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Meditacion',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '3-10 MIN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        SizedBox(
                          height: 40,
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                            ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MeditationPicker()));
                            },
                            child: HugeIcon(icon: HugeIcons.strokeRoundedPlay, color: Colors.white)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,)
                    ],
                  ),
                ),
              )
              
            ],
          )
        ],
      ),
    );
  }
}
