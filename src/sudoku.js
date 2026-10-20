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
    if (!this.isValidMainBlockPlacement(row, col, val)) return false;
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

  isValidMainBlockPlacement(row, col, val) {
    let block = this.getMainBlockValues(row, col);

    return !block.includes(val);
  }

  getMainBlockValues(rowID, colID) {
    let block = [];
    let blockInd = {row: -1, col: -1, row_end: -1, col_end: -1};
    if (rowID < 3) {
      blockInd.row = 0;
      blockInd.row_end = 3;
    } else if(rowID < 6) {
      blockInd.row = 1 * 3;
      blockInd.row_end = 6;
    } else {
      blockInd.row = 2 * 3;
      blockInd.row_end = 9;
    }

    if (colID < 3) {
      blockInd.col = 0;
      blockInd.col_end = 3;
    } else if(colID < 6) {
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
}
