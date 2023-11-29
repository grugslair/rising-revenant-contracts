import { EntityIndex } from "@latticexyz/recs";

export enum Scenes {
    Main = "Main",
}

export enum Maps {
    Main = "Main",
}

export enum Sprites {
    Map,
    Castle
}

export enum Assets {
    MapPicture = "MapPicture",
    CastleHealthySelfAsset = "CastleHealthySelfAsset",
    CastleDamagedAsset = "CastleDamagedAsset",
    CastleHealthyEnemyAsset = "CastleHealthyEnemyAsset",
    CastleDestroyedAsset = "CastleDestroyedAsset",
    CaslteSelectedAsset = "CaslteSelectedAsset",
}

export const MAP_WIDTH = 10240;
export const MAP_HEIGHT = 5164;

export const GAME_CONFIG : EntityIndex = 1 as EntityIndex;
export const SCALE = 0.15;

export let OUTPOST_WIDTH = 0;
export let OUTPOST_HEIGHT = 0;

export function setWidthAndHeight(widht:number, height: number): void {
    OUTPOST_WIDTH = widht;
    OUTPOST_HEIGHT = height;
}



//all the functions below are to either redo or delete as some are not used

export const COLOUMNS_NUMBER = 50;
export const ROWS_NUMBER = 25;

export const TILE_WIDTH = MAP_WIDTH / COLOUMNS_NUMBER;
export const TILE_HEIGHT = MAP_HEIGHT / ROWS_NUMBER;

const tileArray: EntityIndex[][] = new Array(COLOUMNS_NUMBER * ROWS_NUMBER).fill([])
    .map(() => new Array<EntityIndex>());

export function getEntityArrayAtIndex(tileIndex: number): EntityIndex[] {
    return tileArray[tileIndex] || [];
}

export function deleteEntityAtIndex(tileIndex: number, entityIndex: EntityIndex): void {
    const entityArray = tileArray[tileIndex];
    if (entityArray) {
        const indexToRemove = entityArray.indexOf(entityIndex);
        if (indexToRemove !== -1) {
            entityArray.splice(indexToRemove, 1);
        }
    }
}

export function addEntityAtIndex(tileIndex: number, entityIndex: EntityIndex): void {
    const entityArray = tileArray[tileIndex];
    if (entityArray && entityArray.indexOf(entityIndex) === -1) {
        entityArray.push(entityIndex);
    }
}

export function getTileIndex(x: number, y: number): number {
    return Math.floor(x / TILE_WIDTH) + Math.floor(y / TILE_HEIGHT) * COLOUMNS_NUMBER;
}

export function getMoveDirection(originalIndex: number, destinationIndex: number): string | null {
    const width = COLOUMNS_NUMBER;   // doenst have to be a var 

    const originalX = originalIndex % width;
    const originalY = Math.floor(originalIndex / width);
    const destinationX = destinationIndex % width;
    const destinationY = Math.floor(destinationIndex / width);

    if (Math.abs(originalX - destinationX) === 1 && originalY === destinationY) {
        return originalX < destinationX ? "right" : "left";
    } else if (Math.abs(originalY - destinationY) === 1 && originalX === destinationX) {
        return originalY < destinationY ? "down" : "up";
    } else if (Math.abs(originalX - destinationX) > 1 || Math.abs(originalY - destinationY) > 1) {
        return null;
    }

    return null;
}

export function getAdjacentIndexes(originalIndex: number, direction: string): { newAdjacent: number[], removedAdjacent: number[] } {
    const width = 8; // Assuming 8 tiles in a row

    // Calculate x and y coordinates for the original index
    const originalX = originalIndex % width;
    const originalY = Math.floor(originalIndex / width);

    // Function to calculate the index for a given x and y
    const getIndex = (x: number, y: number) => y * width + x;

    // Arrays to store new and removed adjacent indexes
    const newAdjacent: number[] = [];
    const removedAdjacent: number[] = [];

    let dx = 0;
    let dy = 0;

    if (direction === "up") {
        dy = -1;
    } else if (direction === "down") {
        dy = 1;
    } else if (direction === "left") {
        dx = -1;
    } else if (direction === "right") {
        dx = 1;
    }

    // Calculate the new and removed adjacent indexes
    for (let i = -1; i <= 1; i++) {
        for (let j = -1; j <= 1; j++) {
            const newX = originalX + i;
            const newY = originalY + j;
            const newIndex = getIndex(newX, newY);

            if (i === dx && j === dy) {
                newAdjacent.push(newIndex);
            } else {
                removedAdjacent.push(newIndex);
            }
        }
    }

    return { newAdjacent, removedAdjacent };
}

export function getAdjacentIndexesAllDirections(originalIndex: number, adjecentNum: number): number[] {
    const x = originalIndex % COLOUMNS_NUMBER;
    const y = Math.floor(originalIndex / COLOUMNS_NUMBER);

    // Function to calculate the index for a given x and y
    const getIndex = (x: number, y: number) => y * COLOUMNS_NUMBER + x;

    // Array to store all adjacent indexes
    const adjacentIndexes: number[] = [];

    // Iterate over all possible neighbors
    for (let i = (adjecentNum * -1); i <= adjecentNum; i++) {
        for (let j = (adjecentNum* -1); j <= adjecentNum; j++) {
            
            const newX = x + i;
            const newY = y + j;

            // Check if the neighbor is within bounds
            if (newX >= 0 && newX < COLOUMNS_NUMBER && newY >= 0) {
                adjacentIndexes.push(getIndex(newX, newY));
            }
        }
    }

    return adjacentIndexes;
}

export function compareAdjacentIndexes(oldIndexes: number[], newIndexes: number[]): {
    newAdjacent: number[];
    removedAdjacent: number[];
} {
    // Find new adjacent indexes
    const newAdjacent = newIndexes.filter(index => !oldIndexes.includes(index));

    // Find removed adjacent indexes
    const removedAdjacent = oldIndexes.filter(index => !newIndexes.includes(index));

    return {
        newAdjacent,
        removedAdjacent,
    };
}


 
