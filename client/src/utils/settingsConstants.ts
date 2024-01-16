
import { EntityIndex } from "@latticexyz/recs";


export const GAME_CONFIG_ID: EntityIndex = 1 as EntityIndex;

export const MAP_WIDTH = 10240;
export const MAP_HEIGHT = 5164;

export const test_1_size = "clamp(1.2rem, 2.2vw + 0.9rem, 10rem)";
export const test_1_75_size = "clamp(1.1rem, 1.4vw + 0.8rem, 8rem)";
export const test_1_5_size = "clamp(1rem, 1vw + 0.8rem, 8rem)";
export const test_2_size = "clamp(0.8rem, 0.7vw + 0.7rem, 7rem)";
export const test_3_size = "clamp(0.5rem, 0.5vw + 0.5rem, 4rem)";
export const test_4_size = "clamp(0.3rem, 0.4vw + 0.4rem, 3rem)";
export const test_5_size = "clamp(0.2rem, 0.3vw + 0.3rem, 2rem)";

//HERE should this be based on the range of sight instead
export const COLOUMNS_NUMBER = 50;
export const ROWS_NUMBER = 25;

let refreshOwnOutpostDataTimer: number = 90;
export function setRefreshOwnOutpostDataTimer(newFOV: number): void {
    refreshOwnOutpostDataTimer = newFOV;
}
export function getRefreshOwnOutpostDataTimer(): number {
  return refreshOwnOutpostDataTimer;
}