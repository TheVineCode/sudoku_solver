export class SudokuSolver {
  constructor(board, fn) {
    this.board = board;
    this.setValue = fn;
  }

  solve() {
    this.board.forEach((row, index) => {
      console.log(row, index);
    })
    return true;
  }
}
