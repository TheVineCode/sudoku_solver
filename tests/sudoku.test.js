import { describe, expect, it } from "vitest";
import { Sudoku } from "../src/sudoku.js";

describe("Sudoku", () => {
  it("a new Sudoku board is a 9 by 9 empty board", () => {
    const sudoku = new Sudoku();

    expect(sudoku.board).toHaveLength(9);
    expect(sudoku.board.every((row) => row.length === 9)).toBe(true);
    expect(sudoku.board.flat().every((cell) => cell === 0)).toBe(true);
  });
});

describe("Sudoku", () => {
  it("A value can be set in a block", () => {
    const sudoku = new Sudoku();
    expect(sudoku.setValue(0, 0, 5)).toBe(true);
    expect(sudoku.board[0][0]).toBe(5);
  });
});

describe("Sudoku", () => {
  it("A duplicate value cannot be set in the same row", () => {
    const sudoku = new Sudoku();
    expect(sudoku.setValue(0, 0, 5)).toBe(true);
    expect(sudoku.setValue(0, 1, 5)).toBe(false);
    expect(sudoku.board[0][1]).toBe(0);
  });
});
