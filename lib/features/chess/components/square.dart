import 'package:flutter/material.dart';
import 'package:photographers/features/chess/components/piece.dart';
import 'package:photographers/features/chess/values/colors.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    // if selected square is green
    if (isSelected) {
      squareColor = Colors.red[200];
    } else if (isValidMove) {
      squareColor = Colors.red[100];
    } else {
      squareColor = isWhite ? foregroundColor : bagroundColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                color: piece!.isWhite ? Colors.white : Colors.black,
                scale: 3.5,
              )
            : null,
      ),
    );
  }
}
