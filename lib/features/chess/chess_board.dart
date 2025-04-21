import 'package:flutter/material.dart';
import 'package:photographers/features/chess/components/deadPiece.dart';
import 'package:photographers/features/chess/components/piece.dart';
import 'package:photographers/features/chess/components/square.dart';
import 'package:photographers/features/chess/helper/helper_fiuction.dart';
import 'package:photographers/features/chess/responsive/constraintscaffold.dart';
import 'package:photographers/features/chess/values/colors.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
//A-Z diemensional list representing the chessboard
// with each position possibly a chess piece
  late List<List<ChessPiece?>> board;

  //The currently selected piece on the chess board
  //if no piece is selected this is null
  ChessPiece? selectedPiece;

  //The row index of the selected piece
  //defauld value -1 indicated no piece is currrently selected;
  int selectedRow = -1;

  //The row index of the selected piece
  //defauld value -1 indicated no piece is currrently selected;
  int selectedCol = -1;

  //A list of valid moves for the currently selected piece
  //each move is represented as a list with 2 elements : row and column

  List<List<int>> validMoves = [];

// A list of white piece that have been taken by the black player
  List<ChessPiece> whitePieceTaken = [];

// A list Of black pieces that have been taken  by the white players
  List<ChessPiece> blackPieceTaken = [];

  //A boolean to indiacte whos turn it is bool
  bool isWhiteTurn = true;

  // initial position of king(keep track of this to make it easier later to see the king)
  List<int> whiteKingPosition = [7, 4];
  List<int> blacKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //Arrange pieces in the board or initialize the board

  void _initializeBoard() {
    late List<List<ChessPiece?>> newboard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    for (int i = 0; i < 8; i++) {
      newboard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newboard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }

    //rooks
    newboard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/Rook.png');
    newboard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/Rook.png');
    newboard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/Rook.png');
    newboard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/Rook.png');

    //knights
    newboard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newboard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newboard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newboard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    //bishop
    newboard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newboard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newboard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newboard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');

    //queens

    newboard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/Queen.png');

    newboard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/Queen.png');

    // kings
    newboard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');

    newboard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newboard;
  }

  //USER SELECTED a PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // If the same piece is tapped again, deselect it
      if (selectedPiece != null && selectedRow == row && selectedCol == col) {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
        return;
      }

      // No piece is selected yet, select a piece
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // If a piece is already selected, allow selecting another piece of the same color
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == isWhiteTurn) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // If a piece is selected and a valid move is tapped, move the piece
      else if (selectedPiece != null &&
          validMoves.any((move) => move[0] == row && move[1] == col)) {
        movePiece(row, col);
      }

      // If a piece is selected, calculate its valid moves
      validMoves = selectedPiece != null
          ? calculateRealValidMoves(
              selectedRow, selectedCol, selectedPiece, true)
          : [];
    });
  }

  // calculate row valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candnidateMoves = [];

    if (piece == null) {
      return [];
    }
    //different directoin based on the color
    int direction = piece.isWhite ? -1 : 1;

    /// find the meaning of theis code  " int direction = piece!.isWhite ? -1 : 1;"

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candnidateMoves.add([row + direction, col]);
        }

        // pawns can move 2 square forward if they are their initial postion
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candnidateMoves.add([row + 2 * direction, col]);
          }
        }
        //pawan can capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            //  for left diagonal move
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candnidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] !=
                null && // for right diagonal move
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candnidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // horizontal and vertical direction
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1] //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candnidateMoves.add([newRow, newCol]); //cut
              }
              break; // blocked
            }
            candnidateMoves.add([newRow, newCol]);
            i++; // check the meaning
          }
        }
        break;
      case ChessPieceType.knight:
        //all eight possible L shapes the knight can move

        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1] //down 2 right 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candnidateMoves.add([newRow, newCol]);
            }
            continue; // blocked
          }
          candnidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        //diagonal direction
        var directions = [
          [-1, -1], // up to left
          [-1, 1], // up to right
          [1, -1], // down to left
          [1, 1], //down to right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candnidateMoves.add([newRow, newCol]); //capture
              }
              break; // block
            }
            candnidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        //queen has  eight direction up ,down ,left,right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], //left
          [0, 1], // right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candnidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candnidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // all eight direction
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candnidateMoves.add([newRow, newCol]); // capture
            }
            continue; //blocked
          }
          candnidateMoves.add([newRow, newCol]);
        }

        break;
    }
    return candnidateMoves;
  }

  // CALCULATE REAL VALID MOVE
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> canidateMoves = calculateRawValidMoves(
      row,
      col,
      piece,
    );
    if (checkSimulation) {
      for (var move in canidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        //this will simulate the future move to see if its safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = canidateMoves;
    }
    return realValidMoves;
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    //if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      //add the captures piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePieceTaken.add(capturedPiece);
      } else {
        blackPieceTaken.add(capturedPiece);
      }
    }
    //check if the piece being moved in a king
    if (selectedPiece!.type == ChessPieceType.king) {
      //update the appropriate king pos
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blacKingPosition = [newRow, newCol];
      }
    }

    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see If any king are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //clear
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    // check if check mate or not
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("CHECK MATE!"),
                actions: [
                  //play again button
                  TextButton(onPressed: resetGame, child: Text("play again"))
                ],
              ));
    }

    //change turn
    isWhiteTurn = !isWhiteTurn;
  }

  //IS KING CHECK?
  bool isKingInCheck(bool isWhiteKing) {
    //get the postion of the king
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blacKingPosition;

    //check if any enemoy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty square and piece of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);
        //check if the king position is in the piece valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

// simulate a future move to see if its safe (doesnt put your own king under attack)

  bool simulatedMoveIsSafe(
      ChessPiece piece, int starRow, int startCol, int endRow, int endCol) {
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    // if the piece is the king save its current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blacKingPosition;

      // update king pos
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blacKingPosition = [endRow, endCol];
      }
    }
    // simulate the move
    board[endRow][endCol] = piece;
    board[starRow][startCol] = null;
    //check if the own king s attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore the board to orginal state

    board[starRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the piece was the king it original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blacKingPosition = originalKingPosition!;
      }
    }
    //if king is in check then the piece is not in safe.safe move = false
    return !kingInCheck;
  }

  //check mate?
  bool isCheckMate(bool isWhiteKing) {
//if king is not check then its not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

// if there is at least on legal move for any of the pieces, then its not check mate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty square and pieces of the other colors
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        // if this piece has  any valid moves then it not check mate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
// if none of the above condition are met, then there is no legal move left to make

//its check mate!
    return true;
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePieceTaken.clear();
    blackPieceTaken.clear();
    whiteKingPosition = [7, 4];
    blacKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
        appBar: AppBar(
          title: Text(
            "Play a Game",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: foregroundColor,
        ),
        body: Column(
          children: [
            /// WHITE PIE----------CE TAKEN
            Expanded(
                child: GridView.builder(
                    itemCount: whitePieceTaken.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemBuilder: (context, index) => Deadpiece(
                        imagePath: whitePieceTaken[index].imagePath,
                        isWhite: true))),

            /// GAME STATUS
            Text(
              checkStatus ? "check!" : "",
              style: TextStyle(color: Colors.white),
            ),

            ///CHESS BOARD
            Expanded(
              flex: 4,
              child: GridView.builder(
                  itemCount: 8 * 8,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    /// get index of row and col posistion of this square
                    int row = index ~/ 8;
                    int col = index % 8;

                    // check if the square is selected
                    bool isSelected = selectedRow == row && selectedCol == col;

                    // check if this square is a valid move
                    bool isValidMove = false;
                    for (var position in validMoves) {
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;
                      }
                    }
                    return Square(
                      isWhite: isWhite(index),
                      piece: board[row][col],
                      isSelected: isSelected,
                      onTap: () => pieceSelected(row, col),
                      isValidMove: isValidMove,
                    );
                  }),
            ),

            /// Black PIECE TAKEN
            Expanded(
                child: GridView.builder(
                    itemCount: blackPieceTaken.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemBuilder: (context, index) {
                      if (index < blackPieceTaken.length) {
                        return Deadpiece(
                          imagePath: blackPieceTaken[index].imagePath,
                          isWhite: false,
                        );
                      } else {
                        return SizedBox(); // Return an empty widget if index is out of bounds
                      }
                    })),
          ],
        ));
  }
}
