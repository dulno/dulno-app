import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ScanHistoryPage extends StatelessWidget {
  final List<TimelineEvent> events = [
    TimelineEvent(
      icon: CupertinoIcons.checkmark,
      iconColor: Colors.green,
      backgroundColor: Colors.green[50]!,
      title: 'Karte erhalten',
      date: "01.06.2025 12:36",
      description: 'Kickoff meeting and team introductions.',
    ),
    TimelineEvent(
      icon: CupertinoIcons.plus,
      iconColor: Colors.black,
      backgroundColor: Colors.white,
      title: 'Stempel gesammelt',
      date: "02.06.2025 12:36",
      description: 'Development of core features and unit testing.',
    ),
    TimelineEvent(
      icon: CupertinoIcons.minus,
      iconColor: Colors.black,
      backgroundColor: Colors.white,
      title: 'Stempel abgebucht',
      date: "01.06.2025 15:26",
      description: 'Development of core features and unit testing.',
    ),
    TimelineEvent(
      icon: CupertinoIcons.xmark,
      iconColor: Colors.red,
      backgroundColor: Colors.red[50]!,
      title: 'Karte aufgebraucht',
      date: "01.06.2025 11:59",
      description: 'Product released to production with marketing launch.',
    ),
  ];

  ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: LocaleText(
                "product.scan.history.title",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 14),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isLast = index == events.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 30.0 : 0.0),
                        child: TimelineTile(
                          isFirst: index == 0,
                          isLast: index == events.length - 1,
                          indicatorStyle: IndicatorStyle(
                            width: 30,
                            height: 30,
                            indicator: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: event.backgroundColor,
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              child: Center(
                                child: Icon(
                                  event.icon,
                                  size: 18,
                                  color: event.iconColor,
                                ),
                              ),
                            ),
                          ),
                          beforeLineStyle:
                              LineStyle(color: Colors.grey[300]!, thickness: 1),
                          afterLineStyle:
                              LineStyle(color: Colors.grey[300]!, thickness: 1),
                          endChild: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(event.date,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  Text(
                                    event.description,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 60,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFAFAFA).withOpacity(0.0),
                              Color(0xFFFAFAFA).withOpacity(0.75),
                              Color(0xFFFAFAFA),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class TimelineEvent {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String date;
  final String description;

  TimelineEvent({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.date,
    required this.description,
  });
}
