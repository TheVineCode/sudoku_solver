export class SudokuSolver {
  constructor(game) {
    this.game = game;
  }

  solve() {
    this.game.board.forEach((row, index) => {
      console.log(row, index);
    });
    this.game.setValue(0, 0, 6);
    return true;
  }
}
