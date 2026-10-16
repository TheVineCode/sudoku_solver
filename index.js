class Sudoku{
  constructor() {
    this.boardSize = 9;
    this.registeredKeys = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    this.board = null;
    this.lastActive = {row: -1, col: -1};
  }

  init() {
    this.generateBoard();
    this.render();
    this.registerEventListeners();
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
    const gameBoardEl = document.getElementById('game_board');
    gameBoardEl.innerHTML = '';

    this.board.forEach((row, row_i) => {
      row.forEach((col, col_i) => {
        let blockEl = document.createElement('div');
        blockEl.setAttribute('data-row', row_i);
        blockEl.setAttribute('data-col', col_i);
        blockEl.setAttribute('class', 'game_block');
        if (this.lastActive.row === row_i && this.lastActive.col === col_i) {
          blockEl.classList.add('active');
        }

        this.needsBorder(blockEl, row_i, col_i);

        blockEl.innerHTML = col;
        gameBoardEl.append(blockEl);
      });
    });

  }

  registerEventListeners() {
    document.addEventListener('keypress', (event) => {
      const key = Number(event.key);
      if (this.registeredKeys.includes(key)) {
        let el = document.querySelector('.active');
        if (el) {
          const rowID = Number(el.dataset.row);
          const colID = Number(el.dataset.col);
          const previousVal = this.board[rowID][colID];
          this.board[rowID][colID] = key;
          if (!this.isValid(rowID, colID, key)) {
            this.board[rowID][colID] = previousVal;
          }
          this.render();
        }
      }
    });

    document.addEventListener('click', (el) => {
      this.lastActive = { row: Number(el.target.dataset.row), col: Number(el.target.dataset.col) };
      this.clearActives();
      el.target.classList.add('active');
    });
  }

  isValid(rowID, colID, key) {
    if (!this.rowIsValid(rowID, key)) return false;
    if (!this.colIsValid(colID, key)) return false;
    if (!this.blockIsValid(rowID, colID, key)) return false;
    return true;
  }

  rowIsValid(rowID, key) {
    let row = this.board[rowID];
    let cleanRow = row.filter(el => el !== 0);
    let setRow = new Set(cleanRow);

    return cleanRow.length === setRow.size;
  }

  colIsValid(colID, key) {
    let col = this.board.map(row => {
      return row[colID];
    });

    let cleanCol = col.filter(el => el !== 0);
    let setCol = new Set(cleanCol);

    return cleanCol.length === setCol.size;
  }

  blockIsValid(rowID, colID, key) {
    let block = this.getBlock(rowID, colID);

    let cleanBlock = block.filter(el => el !== 0);
    let setBlock = new Set(cleanBlock);

    return cleanBlock.length === setBlock.size;
  }

  getBlock(rowID, colID) {
    let block = [];
    let blockInd = {row: -1, col: -1};
    if (rowID < 3) {
      blockInd.row = 0;
    } else if(rowID < 6) {
      blockInd.row = 1;
    } else {
      blockInd.row = 2;
    }

    if (colID < 3) {
      blockInd.col = 0;
    } else if(colID < 6) {
      blockInd.col = 1;
    } else {
      blockInd.col = 2;
    }

    for (let i = 0; i < this.boardSize; i++) {
      if (i < blockInd.row * 3) continue;

      for (let j = 0; j < this.boardSize; j++) {
        if (j < blockInd.col * 3) continue;

        block.push(this.board[i][j]);
      }
    }

    return block;
  }

  clearActives() {
    document.querySelector('.active')?.classList.remove('active');
  }

  needsBorder(el, row_i, col_i) {
    if (row_i === 2 || row_i === 5) {
      el.classList.add('border_b');
    }

    if (col_i === 2 || col_i === 5) {
      el.classList.add('border_r');
    }
  }

  seedBoard() {

  }
}

game = new Sudoku();

game.init();

class Game {

}
