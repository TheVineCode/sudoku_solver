import { SudokuSolver } from "./sudoku_solver";

export class Sudoku {
  constructor() {
    this.boardSize = 9;

    this.initBoard();
  }

  initBoard() {
    let board = [];

    for (let i = 0; i < this.boardSize; i++) {
      let row = [];
      for (let j = 0; j < this.boardSize; j++) {
        row.push(null);
      }
      board.push(row);
    }

    this.board = board;
    this.boardLevelStart = this.copyBoard(board);
  }

  copyBoard(board) {
    return board.map((row) => [...row]);
  }

  reset() {
    this.board = this.copyBoard(this.boardLevelStart);
  }

  clearValue(row, col) {
    this.board[row][col] = null;
    return true;
  }

  setValue(row, col, val) {
    if (val < 1 || val > 9) {
      return false;
    }

    console.log(this.boardLevelStart);
    if (this.isValid(row, col, val)) {
      this.board[row][col] = val;

      if (this.checkComplete()) this.showCompleteGame();
      return true;
    }

    return false;
  }

  isValid(row, col, val) {
    if (!this.clearToPlaceValue(this.rowValues(row), val)) return false;
    if (!this.clearToPlaceValue(this.colValues(col), val)) return false;
    if (!this.clearToPlaceValue(this.blockValues(row, col), val)) return false;

    return true;
  }

  clearToPlaceValue(arr, val) {
    return !arr.includes(val);
  }

  rowValues(row) {
    return this.board[row];
  }

  colValues(col) {
    return this.board.map((row) => {
      return row[col];
    });
  }

  blockValues(row, col) {
    return this.getMainBlockValues(row, col);
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
    return this.board.flat().every((cell) => cell !== null);
  }

  showCompleteGame() {
    console.log("Game completed");
  }

  async seedGame(difficulty) {
    await fetch( `https://api.api-ninjas.com/v1/sudokugenerate?difficulty=${difficulty}&width=3&height=3`,
      {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-Api-Key": "",
        }
      }
    ).then(async result => {
      const data = await result.json();
      this.board = this.copyBoard(data.puzzle);
      this.boardLevelStart = this.copyBoard(data.puzzle);
      this.solvedBoard = data.solution;
    });

    return true;
  }

  solve() {
    const solver = new SudokuSolver(this);
    return solver.solve();
  }
}
