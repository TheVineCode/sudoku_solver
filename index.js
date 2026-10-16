class Sudoku{
  constructor() {
    this.boardSize = 9;
    this.board = null;
  }

  generateBoard() {
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

  render() {
    const gameBoardEl = document.getElementById('game_board')
    this.board.forEach((row, i) => {
      row.forEach((el, index) => {
        const blockEl = document.createElement('div');
        blockEl.setAttribute('data-row', i);
        blockEl.setAttribute('data-col', index);
        blockEl.setAttribute('class', 'game_block')
        blockEl.innerHTML = el;

        gameBoardEl.append(blockEl);
      });
    })
  }

  seedBoard() {

  }
}

game = new Sudoku();

game.generateBoard();
game.render();

class Game {

}
