import 'package:dulno/localization/locale_text.dart';
import 'package:dulno/localization/locales.dart';
import 'package:dulno/product/scan/scan_history.dart';
import 'package:dulno/product/scan/scan_history_entry.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
                        top: 12,
                        bottom: 12,
                        left: 12,
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
                              Locales.string(context, entry.title()),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 1,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(FontAwesomeIcons.clock,
                                      size: 12, color: Colors.grey[600]),
                                  SizedBox(width: 5),
                                  FutureBuilder<String>(
                                    future: entry.date(context),
                                    builder: (context,
                                        AsyncSnapshot<String> dateSnapshot) {
                                      return dateSnapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? Skeletonizer(
                                              child: Skeleton.leaf(
                                                child: Container(
                                                  height: 15,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              dateSnapshot.hasData
                                                  ? dateSnapshot.data!
                                                  : "",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: Locales.string(
                                            context, entry.description())
                                        .split("%s")[0],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: entry.partnerName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: Locales.string(
                                            context, entry.description())
                                        .split("%s")[1],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
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
