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

  clearValue(row, col) {
    this.board[row][col] = 0;
    return true;
  }

  setValue(row, col, val) {
    if (val < 1 || val > 9) {
      return false;
    }

    if (this.isValid(row, col, val)) {
      this.board[row][col] = val;

      if (this.checkComplete()) this.showCompleteGame();
      return true;
    }

    return false;
  }

  isValid(row, col, val) {
    if (!this.isValidRowPlacement(row, val)) return false;
    if (!this.isValidColPlacement(col, val)) return false;
    if (!this.isValidMainBlockPlacement(row, col, val)) return false;
    return true;
  }

  clearToPlaceValue(arr, val) {
    return !arr.includes(val);
  }

  isValidRowPlacement(row, val) {
    let validRow = this.board[row];

    return this.clearToPlaceValue(validRow, val);
  }

  isValidColPlacement(col, val) {
    let validCol = this.board.map((row) => {
      return row[col];
    });

    return this.clearToPlaceValue(validCol, val);
  }

  isValidMainBlockPlacement(row, col, val) {
    let block = this.getMainBlockValues(row, col);

    return this.clearToPlaceValue(block, val);
  }

  getMainBlockValues(rowID, colID) {
    let block = [];
    let blockInd = { row: -1, col: -1, row_end: -1, col_end: -1 };
    if (rowID < 3) {
      blockInd.row = 0;
      blockInd.row_end = 3;
    } else if (rowID < 6) {
      blockInd.row = 1 * 3;
      blockInd.row_end = 6;
    } else {
      blockInd.row = 2 * 3;
      blockInd.row_end = 9;
    }

    if (colID < 3) {
      blockInd.col = 0;
      blockInd.col_end = 3;
    } else if (colID < 6) {
      blockInd.col = 1 * 3;
      blockInd.col_end = 6;
    } else {
      blockInd.col = 2 * 3;
      blockInd.col_end = 9;
    }

    for (let i = 0; i < this.boardSize; i++) {
      if (i < blockInd.row || i >= blockInd.row_end) continue;

      for (let j = 0; j < this.boardSize; j++) {
        if (j < blockInd.col || j >= blockInd.col_end) continue;

        block.push(this.board[i][j]);
      }
    }

    return block;
  }

  checkComplete() {
    return this.board.flat().every((cell) => cell !== 0);
  }

  showCompleteGame() {
    console.log("Game completed");
  }

  seedGame() {
    this.setValue(0, 1, 5);
    this.setValue(0, 2, 8);
    this.setValue(0, 4, 3);
    this.setValue(0, 7, 2);

    this.setValue(1, 0, 4);
    this.setValue(1, 2, 2);
    this.setValue(1, 6, 9);
    this.setValue(1, 8, 5);

    this.setValue(2, 2, 7);
    this.setValue(2, 6, 6);
    this.setValue(2, 7, 8);

    this.setValue(3, 0, 2);
    this.setValue(3, 1, 9);
    this.setValue(3, 4, 5);
    this.setValue(3, 5, 4);
    this.setValue(3, 7, 7);

    this.setValue(4, 0, 5);
    this.setValue(4, 4, 6);
    this.setValue(4, 5, 2);

    this.setValue(5, 2, 3);
    this.setValue(5, 3, 8);
    this.setValue(5, 4, 1);
    this.setValue(5, 6, 2);
    this.setValue(5, 7, 5);

    this.setValue(6, 0, 1);
    this.setValue(6, 2, 9);
    this.setValue(6, 5, 3);
    this.setValue(6, 7, 6);
    this.setValue(6, 8, 4);

    this.setValue(7, 0, 8);
    this.setValue(7, 1, 6);
    this.setValue(7, 2, 5);
    this.setValue(7, 3, 4);
    this.setValue(7, 4, 9);
    this.setValue(7, 6, 1);
    this.setValue(7, 7, 3);

    this.setValue(8, 1, 7);
    this.setValue(8, 5, 6);
  }
}
