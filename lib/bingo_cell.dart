import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // <--- NEW IMPORT

// A StatefulWidget to manage the individual cell's pressed state and animation
class BingoCell extends StatefulWidget {
  final String phrase;
  final bool isMarked;
  final bool isWinningCell; // Prop for winning cell status
  final VoidCallback onTap; // Callback when the cell is tapped

  const BingoCell({
    required this.phrase,
    required this.isMarked,
    required this.onTap,
    required this.isWinningCell,
    super.key,
  });

  @override
  State<BingoCell> createState() => _BingoCellState();
}

class _BingoCellState extends State<BingoCell> {
  bool _isPressed = false; // Internal state to track if the cell is currently being pressed

  // This method is called when the user initially presses down on the cell
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  // This method is called when the user lifts their finger from the cell
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTap(); // Call the onTap callback passed from the parent (BingoCard)
  }

  // This method is called if the tap is cancelled (e.g., user drags finger away or another gesture interferes)
  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine cell background color and text color based on winning status, then marked status
    Color cellBackgroundColor;
    Color cellTextColor;

    if (widget.isWinningCell) {
      cellBackgroundColor = Colors.red[800]!; // Darker red for winning cells
      cellTextColor = Colors.white; // White text for contrast on dark background
    } else if (widget.isMarked) {
      cellBackgroundColor = Colors.red[100]!; // Pale red if just marked
      cellTextColor = Colors.red[800]!; // Darker red text for strikethrough
    } else {
      cellBackgroundColor = Colors.white; // Default white
      cellTextColor = Colors.black; // Default black text
    }

    return GestureDetector( // Using GestureDetector to detect tap down/up events
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      // The main tap action (toggle marked status) is handled by onTapUp,
      // so onTap is intentionally empty to prevent double-triggering logic.
      onTap: () { /* Tap logic is handled in onTapUp */ },
      child: AnimatedScale( // Animates the scale of its child
        scale: _isPressed ? 0.95 : 1.0, // Scale down to 95% when pressed, back to 100% when released
        duration: const Duration(milliseconds: 100), // How fast the animation plays
        curve: Curves.easeOut, // Animation curve for a smooth feel
        child: Card(
          // Use widget.isMarked to access the marked status passed from the parent
          color: cellBackgroundColor, // Use the determined background color
          elevation: 2.0, // Slight shadow for cards
          child: Center(
            child: Padding( // Add padding for text to breathe
              padding: const EdgeInsets.all(4.0),
              child: AutoSizeText( // <-- NEW: AutoSizeText for dynamic font sizing
                widget.phrase, // Use widget.phrase to access data from parent
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0, // This will be the max font size if it fits
                  fontWeight: FontWeight.bold,
                  decoration: widget.isMarked ? TextDecoration.lineThrough : TextDecoration.none,
                  color: cellTextColor, // Use the determined text color
                ),
                minFontSize: 8.0, // <-- Minimum font size to shrink to
                maxLines: 3,      // <-- Maximum number of lines for the text
                overflow: TextOverflow.ellipsis, // Add '...' if text can't fit even at min size
                // group: AutoSizeTextGroup.of(context), // Optional: Uncomment if you want to group font sizing
              ),
            ),
          ),
        ),
      ),
    );
  }
}