import { describe, expect, it } from "vitest";
import { Sudoku } from "../src/sudoku";

describe("Sudoku Solver", () => {
  it("Solver fills in values", () => {
    const sudoku = new Sudoku();

    expect(sudoku.solve()).toBe(undefined);


  })
})
