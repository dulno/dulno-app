import 'package:dulno/product/scan/scan_history.dart';
import 'package:dulno/product/scan/scan_history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ScanHistoryTimeline extends StatelessWidget {
  const ScanHistoryTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScanHistoryEntry>>(
      future: ScanHistory().find(),
      builder:
          (context, AsyncSnapshot<List<ScanHistoryEntry>> historySnapshot) {
        if (!historySnapshot.hasData) {
          return SizedBox.shrink();
        }
        var entries = historySnapshot.data!;
        if (entries.isEmpty) {
          return Align(
            alignment: Alignment.center,
            child: LocaleText("product.scan.history.empty"),
          );
        }
        return Stack(
          children: [
            ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isLast = index == entries.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 30.0 : 0.0),
                  child: TimelineTile(
                    isFirst: index == 0,
                    isLast: index == entries.length - 1,
                    indicatorStyle: IndicatorStyle(
                      width: 30,
                      height: 30,
                      indicator: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entry.backgroundColor(),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            entry.icon(),
                            size: 18,
                            color: entry.iconColor(),
                          ),
                        ),
                      ),
                    ),
                    beforeLineStyle: LineStyle(
                      color: Colors.grey[300]!,
                      thickness: 1,
                    ),
                    afterLineStyle: LineStyle(
                      color: Colors.grey[300]!,
                      thickness: 1,
                    ),
                    endChild: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                        bottom: 16,
                      ),
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
                            Text(
                              entry.title(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              entry.date(context),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.description(context),
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
        );
      },
    );
  }
}
