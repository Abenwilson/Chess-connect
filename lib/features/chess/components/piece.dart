enum ChessPieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king
} //it define the the piece type

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece(
      {required this.type, required this.isWhite, required this.imagePath});
}
