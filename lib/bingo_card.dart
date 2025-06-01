import 'package:flutter/material.dart';
import 'dart:math'; // Import for randomization
import 'package:bingo_game/bingo_cell.dart'; // IMPORTANT: Make sure this import is correct

// StatefulWidget is used when a widget needs to manage mutable state.
class BingoCard extends StatefulWidget {
  final List<String> phrases; // Phrases are passed from parent (main.dart)

  const BingoCard({required this.phrases, super.key});

  @override
  State<BingoCard> createState() => _BingoCardState();
}

// The State class holds the mutable state of the widget.
class _BingoCardState extends State<BingoCard> {
  late List<String> _currentCardPhrases; // Phrases for THIS specific card
  late List<bool> _markedCells; // Tracks which cells are marked
  late List<bool> _winningCells; // To track cells in winning rows/columns
  int _score = 0; // The player's current score
  int _cardKey = 0; // Used to animate card changes with AnimatedSwitcher

  @override
  void initState() {
    super.initState();
    _generateNewCard(); // Initialize the card phrases and marked status when widget is created
  }

  // Generates a new random set of 12 phrases for the card
  void _generateNewCard() {
    final random = Random();
    // Create a shuffled copy of the full phrase list received from the parent
    final shuffledPhrases = List<String>.from(widget.phrases)..shuffle(random);

    // Select the first 12 phrases for this card
    _currentCardPhrases = shuffledPhrases.take(12).toList();
    // Reset all cells to unmarked for the new card
    _markedCells = List.generate(12, (index) => false);
    // Reset all winning cells to false for the new card
    _winningCells = List.generate(12, (index) => false);
    _cardKey++; // Increment key to trigger AnimatedSwitcher for a new card
  }

  // Method to handle a cell tap (passed to BingoCell)
  void _toggleCell(int index) {
    setState(() {
      _markedCells[index] = !_markedCells[index]; // Toggle marked status

      // After a cell is marked/unmarked, check for win conditions
      _checkWinConditions();
    });
  }

  // Checks if any row or column is complete
  void _checkWinConditions() {
    bool winOccurred = false;

    // Check Rows (3 rows of 4 cells)
    for (int row = 0; row < 3; row++) {
      bool rowComplete = true;
      for (int col = 0; col < 4; col++) {
        if (!_markedCells[row * 4 + col]) { // Calculate index for current cell in row
          rowComplete = false;
          break;
        }
      }
      if (rowComplete) {
        _score += 10; // 10 points for a row
        winOccurred = true;
        print('Row $row completed! Score: $_score'); // For debugging in console
        // Mark all cells in this winning row as winning cells
        for (int c = 0; c < 4; c++) {
          _winningCells[row * 4 + c] = true;
        }
      }
    }

    // Check Columns (4 columns of 3 cells)
    for (int col = 0; col < 4; col++) {
      bool colComplete = true;
      for (int row = 0; row < 3; row++) {
        if (!_markedCells[row * 4 + col]) { // Calculate index for current cell in column
          colComplete = false;
          break;
        }
      }
      if (colComplete) {
        _score += 5; // 5 points for a column
        winOccurred = true;
        print('Column $col completed! Score: $_score'); // For debugging in console
        // Mark all cells in this winning column as winning cells
        for (int r = 0; r < 3; r++) {
          _winningCells[r * 4 + col] = true;
        }
      }
    }

    // If any win occurred, trigger a UI update for winning cells, then a delayed new card
    if (winOccurred) {
       // This setState will trigger a rebuild to show the _winningCells in darker red
       setState(() {}); // Immediately update UI to show winning cells in dark red

       // Then, after a short delay, generate a new card with animation
       Future.delayed(const Duration(milliseconds: 700), () {
         setState(() { // The setState here is crucial to trigger the new card display
           _generateNewCard();
         });
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the max available width and height for this widget
    return AnimatedSwitcher( // ANIMATEDSWITCHER WRAPS THE ENTIRE GAME CONTENT
      duration: const Duration(milliseconds: 500), // Duration of the slide animation
      // Custom transition: old slides out left, new slides in from right
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Animation for the new child (child): slides in from right
        final inAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Starts from off-screen right
          end: Offset.zero,             // Ends at its normal position
        ).animate(animation);

        // Animation for the outgoing child: slides out to the left
        // Note: AnimatedSwitcher automatically handles the outgoing child.
        // The 'animation' passed to this builder is primarily for the *incoming* child.
        // We often rely on AnimatedSwitcher's default behavior for the outgoing child
        // or customize with a specific key. For a slide transition, we use a Stack.
        final outAnimation = Tween<Offset>(
          begin: Offset.zero,             // Starts at its normal position
          end: const Offset(-1.0, 0.0),  // Ends off-screen left
        ).animate(animation);


        // Use a Stack to layer the outgoing and incoming widgets during the transition
        // This pattern allows both widgets to be visible during the transition.
        return Stack(
          children: <Widget>[
            // The outgoing widget is implicitly managed by AnimatedSwitcher.
            // We apply the 'outAnimation' to it when it's exiting.
            // The 'key' ensures AnimatedSwitcher tracks the old child.
            // This 'child' is actually the *new* child coming in.
            // AnimatedSwitcher will use the `child` from the previous build frame (the old card).
            // The condition `animation.status == AnimationStatus.reverse` typically means
            // the old widget is being removed (animating from 1.0 to 0.0 for its removal).
            // A common pattern is to wrap the child in the builder.
            // However, AnimatedSwitcher handles the replacement.
            // For a simultaneous slide, this is a common approach:
             if (animation.status == AnimationStatus.reverse) // This part handles the old child
               SlideTransition(
                 position: outAnimation,
                 // Pass the the old widget that is being removed
                 child: child, // This 'child' is the widget from the previous build.
               ),
            // The incoming widget (new child)
            SlideTransition(
              position: inAnimation,
              child: child, // This 'child' is the new card being animated in.
            ),
          ],
        );
      },
      child: Column( // This Column is the child of AnimatedSwitcher
        key: ValueKey<int>(_cardKey), // IMPORTANT: Unique key to trigger AnimatedSwitcher
        children: [
          // Display the current score
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Expanded( // Make GridView take remaining space
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double mainAxisSpacing = 8.0; // Spacing between rows
                const double crossAxisSpacing = 8.0; // Spacing between columns
                const int crossAxisCount = 4; // Number of columns (fixed for 3x4 grid)
                const int numRows = 3; // Desired number of rows (fixed for 3x4 grid)

                // Calculate total vertical spacing
                final double totalMainAxisSpacing = mainAxisSpacing * (numRows - 1);
                final double availableHeightForCells = constraints.maxHeight - totalMainAxisSpacing - (2 * 8.0); // 2 * padding (8.0 top/bottom)
                final double cellHeight = availableHeightForCells / numRows;

                // Calculate total horizontal spacing
                final double totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
                final double availableWidthForCells = constraints.maxWidth - totalCrossAxisSpacing - (2 * 8.0); // 2 * padding (8.0 left/right)
                final double cellWidth = availableWidthForCells / crossAxisCount;

                // Calculate the aspect ratio (width / height) to make cells fit
                final double calculatedChildAspectRatio = cellWidth / cellHeight;

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0), // Padding around the entire grid
                  physics: const NeverScrollableScrollPhysics(), // Prevents scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // 4 columns
                    crossAxisSpacing: crossAxisSpacing, // Spacing between columns
                    mainAxisSpacing: mainAxisSpacing, // Spacing between rows
                    childAspectRatio: calculatedChildAspectRatio,
                  ),
                  itemCount: 12, // 12 cells total (3 rows * 4 columns)
                  itemBuilder: (context, index) {
                    final isMarked = _markedCells[index];
                    final isWinningCell = _winningCells[index];

                    // Use the new BingoCell widget for each grid item
                    return BingoCell(
                      phrase: _currentCardPhrases[index],
                      isMarked: isMarked,
                      isWinningCell: isWinningCell,
                      onTap: () => _toggleCell(index), // Pass the toggle function
                    );
                  },
                );
              },
            ),
          ),
        ],
      ), // END OF COLUMN (child of AnimatedSwitcher)
    ); // END OF ANIMATEDSWITCHER
  }
}