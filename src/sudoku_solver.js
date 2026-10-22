export class SudokuSolver {
  constructor(game) {
    this.game = game;
    this.gameValidPlacementValues = [];
    this.columns = [];
    this.rows = this.game.board;
    this.validNumbers = new Set([1, 2, 3, 4, 5, 6, 7, 8, 9]);
    this.cellPossibleAnswers = [];
    this.cellNonePossibleAnswers = [];
  }

  solve() {
    this.buildData();
    for (let i = 0; i < this.game.board.length; i++) {
      for (let j = 0; j < this.game.board.length; j++) {
        const row_column_vals = new Set(this.rows[i].concat(this.columns[i]).filter((cell) => cell !== 0));
        this.cellNonePossibleAnswers.push(row_column_vals);
        console.log(this.validNumbers.difference(row_column_vals));
      }
    }
  }

  buildData() {
    for (let i = 0; i < this.game.board.length; i++) {
      const column = []
      for (let j = 0; j < this.game.board.length; j++) {
        column.push(this.game.board[j][i]);
      }
      this.columns.push(column);
    }
  }
}
