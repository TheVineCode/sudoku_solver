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

describe("Sudoku", () => {
  it("A duplicate value cannot be set in the same column", () => {
    const sudoku = new Sudoku();
    expect(sudoku.setValue(0, 0, 5)).toBe(true);
    expect(sudoku.setValue(1, 0, 5)).toBe(false);
    expect(sudoku.board[1][0]).toBe(0);
  });
});

describe("Sudoku", () => {
  it("A duplicate value cannot be set in the same main block", () => {
    const sudoku = new Sudoku();
    expect(sudoku.setValue(0, 0, 5)).toBe(true);
    expect(sudoku.setValue(2, 2, 5)).toBe(false);
    expect(sudoku.board[2][2]).toBe(0);

    //middle block
    expect(sudoku.setValue(3, 4, 1)).toBe(true);
    expect(sudoku.setValue(4, 5, 1)).toBe(false);
    expect(sudoku.board[4][5]).toBe(0);
  });
});
