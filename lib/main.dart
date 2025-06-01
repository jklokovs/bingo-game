import 'package:flutter/material.dart';
import 'package:bingo_game/bingo_card.dart'; // Make sure this import is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define your comprehensive list of bingo phrases here
  final List<String> bingoPhrases = const [
    'Corporate requests...',
    'Car Wash subscription',
    'Someone asks about fuel margin',
    'Email asking for explanation',
    'Someone requests JDE access',
    'Invoice stuck/appeared in workflow/ARIBA',
    'Budget JDE upload',
    'Cost center incorrectly assigned',
    'Colleague asks about ...',
    'Vendor invoice is overdue',
    'Discrepancy in intercompany reconciliation',
    'Asked to reclassify AUC costs',
    'GL account mapping issue',
    'FIFO calculation',
    'Someone mentions “JDE glitch” again',
    'Requested to break down OPEX by station',
    'Reporting model numbers don’t tie to Longview P&L',
    'Loyalty program accounting',
    'Manager requests ...',
    'Journal needs correction',
    'Asked to make accruals',
    'Someone flags unusual EBIT result',
    'MEC deadline extended (again)',
    'Journal is missing for ... ',
    'Audit requests arrived/submitted',
    'Someone asks for FRP comment adjustments',
    'Unposted invoice from two weeks ago discovered',
    'KC evidence completeness questioned by IA',
    'Someone says "check the master data"',
    'Asked to explain variance in fuel margin',
    'ARO liability calculation is ...',
    'Cash flow report shows error',
    'Asked to explain margin drop on one Station',
    'New colleague onboarding',
    'Team member uses the phrase ACCA',
    'Someone books a capex expense in OPEX (again)',
    'BL recon doesn’t match trial balance',
    'Controller wants drilldown on ...',
    'Reporting instructions update email goes unread ',
    'Asked to fix prior period accruals',
    'Finance team is exhausted',
    'Finance Cube filters reset for no reason',
    'Discussion starts about ... ends in silence',
    'FinDir uses “materiality” to end the argument',
    'Someone discovers a station that closed months ago still has expenses',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle K Bingo', // Title for OS task switcher
      theme: ThemeData(
        primarySwatch: Colors.red, // Basic theme color
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min, // Make the row only as wide as its children
            children: [
              // **IMPORTANT**: Ensure this path matches your logo file in assets/images/
              Image.asset(
                'assets/images/circle-k-seeklogo.png', // Make sure this path and filename is EXACT!
                height: 30, // Adjust height as needed for your logo
              ),
              const SizedBox(width: 8), // Small space between logo and text
              const Text(
                'Bingo',
                style: TextStyle(
                  fontSize: 24, // Adjust text size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red, // App Bar background color
          foregroundColor: Colors.white, // App Bar text color
        ),
        // Use a Stack to layer the BingoCard and the orientation warning
        body: Stack(
          children: [
            // The BingoCard is always present and mounted here, preserving its state
            BingoCard(phrases: bingoPhrases),

            // Overlay the warning message only when in portrait mode
            OrientationBuilder(
              builder: (context, orientation) {
                return Visibility(
                  visible: orientation == Orientation.portrait, // Show only in portrait
                  // IgnorePointer prevents taps on the BingoCard when the warning is visible
                  child: IgnorePointer(
                    ignoring: orientation == Orientation.landscape, // Ignore when landscape
                    child: Container( // A container to cover the whole screen
                      color: Colors.black.withOpacity(0.8), // Semi-transparent dark overlay
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.screen_rotation, size: 80, color: Colors.white), // White icon
                            SizedBox(height: 20),
                            Text(
                              'Please rotate your device to landscape mode to play Bingo!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // White text
                            ),
                            SizedBox(height: 10),
                            Text(
                              'The game is optimized for landscape view.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}