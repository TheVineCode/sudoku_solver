export class Sudoku {
  constructor() {
    this.boardSize = 9;
    this.board = null;

    this.initBoard();
  }

  initBoard() {
    let board = [];

    for (let i = 0; i < this.boardSize; i++) {
      let row = [];
      for (let j = 0; j < this.boardSize; j++) {
        row.push(0);
      }
      board.push(row);
    }

    this.board = board;
  }

  setValue(row, col, val) {
    if (this.isValid(row, col, val)) {
      this.board[row][col] = val;
      return true;
    }

    return false;
  }

  isValid(row, col, val) {
    if (!this.isValidRowPlacement(row, val)) return false;
    if (!this.isValidColPlacement(col, val)) return false;
    return true;
  }

  isValidRowPlacement(row, val) {
    let validRow = this.board[row];

    return !validRow.includes(val);
  }

  isValidColPlacement(col, val) {
    let validCol = this.board.map(row => {
      return row[col];
    });

    return !validCol.includes(val);
  }
}
