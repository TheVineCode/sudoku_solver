import { Sudoku } from "./src/sudoku.js";

class SudokuApp {
  constructor(boardEl) {
    this.boardEl = boardEl;
    this.game = new Sudoku();
    this.selectedCell = null;
  }

  init() {
    this.render();
    this.registerEventListeners();
  }

  render() {
    this.boardEl.replaceChildren();

    this.game.board.forEach((row, rowIndex) => {
      row.forEach((value, colIndex) => {
        let block = document.createElement("button");
        block.className = "game_block";
        block.dataset.row = rowIndex;
        block.dataset.col = colIndex;
        block.textContent = value === null ? "" : String(value);

        if (
          this.selectedCell?.row === rowIndex &&
          this.selectedCell?.col === colIndex
        ) {
          block.classList.add("active");
        }

        this.needsBorder(block, rowIndex, colIndex);

        this.boardEl.append(block);
      });
    });
  }

  registerEventListeners() {
    this.boardEl.addEventListener("click", (event) => {
      if (!(event.target instanceof Element)) return;

      const block = event.target.closest(".game_block");
      if (!block) return;

      this.selectedCell = {
        row: Number(block.dataset.row),
        col: Number(block.dataset.col),
      };

      this.render();
    });

    document.addEventListener("keydown", (event) => {
      if (!this.selectedCell) return;

      const { row, col } = this.selectedCell;

      if (/^[1-9]$/.test(event.key)) {
        const accepted = this.game.setValue(row, col, Number(event.key));

        if (accepted) {
          this.render();
        }

        return;
      }

      if (event.key === "Backspace" || event.key === "Delete") {
        this.game.clearValue(row, col);
        this.render();
      }
    });

    const resetBtn = document.getElementById("reset_btn");
    resetBtn.addEventListener("click", async () => {
      this.game.initBoard();
      await this.game.seedGame();
      this.render();
    });

    const solveBtn = document.getElementById("solve_btn");
    solveBtn.addEventListener("click", () => {
      this.game.solve();
      this.render();
    });
  }

  needsBorder(el, rowIndex, colIndex) {
    if (rowIndex === 2 || rowIndex === 5) {
      el.classList.add("border_b");
    }

    if (colIndex === 2 || colIndex === 5) {
      el.classList.add("border_r");
    }
  }
}

const boardElement = document.getElementById("game_board");
const game = new SudokuApp(boardElement);

game.init();
