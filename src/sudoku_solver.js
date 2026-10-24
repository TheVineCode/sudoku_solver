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
    while (!this.game.checkComplete()) {
      for (let i = 0; i < this.game.board.length; i++) {
        for (let j = 0; j < this.game.board.length; j++) {
          if (this.rows[i][j] !== null) continue;

          const row_column_vals = new Set(
            this.game
              .rowValues(i)
              .concat(this.game.colValues(j))
              .concat(this.game.blockValues(i, j))
              .filter((cell) => cell !== null),
          );
          const validValues = this.validNumbers.difference(row_column_vals);
          this.cellNonePossibleAnswers.push({
            row: i,
            col: j,
            invalid: row_column_vals,
            valid: validValues,
          });

          const vals = validValues.values();
          if (validValues.size === 1) {
            this.game.board[i][j] = vals.next().value;
          }
        }
      }
    }
    return true;
  }

  buildData() {
    for (let i = 0; i < this.game.board.length; i++) {
      const column = [];
      for (let j = 0; j < this.game.board.length; j++) {
        column.push(this.game.board[j][i]);
      }
      this.columns.push(column);
    }
  }
}
