import { getEntityIdFromKeys, parseComponentValueFromGraphQLEntity, setComponentFromGraphQLEntity } from "@dojoengine/utils";
import { setComponent, Components, ComponentValue, getComponentValue, getComponentValueStrict, updateComponent } from "@latticexyz/recs";
import { getTileIndex } from "../phaser/constants";
import { GAME_CONFIG_ID } from "./settingsConstants";
import { Game, GameEntityCounter, Outpost } from "../generated/graphql";
import { ClientComponents } from "../dojo/createClientComponents";


//region Names

export const namesArray: string[] = [
    "Mireth", "Vexara", "Zorion", "Caelix",
    "Elyndor", "Tharion", "Sylphren", "Aravax",
    "Vexil", "Lyrandar", "Nyxen", "Theralis",
    "Qyra", "Fenrix", "Atheris", "Lorvael",
    "Xyris", "Zephyron", "Calaer", "Drakos",
    "Velixar", "Syrana", "Morvran", "Elithran",
    "Kaelith", "Tyrven", "Ysara", "Vorenth",
    "Alarix", "Ethrios", "Nyrax", "Thrayce",
    "Vynora", "Kerith", "Jorvax", "Lysandor",
    "Eremon", "Xanthe", "Zanther", "Cindris",
    "Baelor", "Lyvar", "Eryth", "Zalvor",
    "Gormath", "Sylvanix", "Quorin", "Taryx",
    "Nyvar", "Oryth", "Valeran", "Myrthil",
    "Zorvath", "Kyrand", "Thalren", "Vexim",
    "Aelar", "Grendar", "Xylar", "Zorael",
    "Calyph", "Vyrak", "Thandor", "Lyrax",
    "Riven", "Drexel", "Yvaris", "Zenthil",
    "Aravorn", "Morthil", "Sylvar", "Quinix",
    "Tharix", "Valthorn", "Nythar", "Lorvax",
    "Exar", "Zilthar", "Cynthis", "Veldor",
    "Arix", "Thyras", "Mordran", "Elyx",
    "Kythor", "Rendal", "Xanor", "Yrthil",
    "Zarvix", "Caelum", "Lythor", "Qyron",
    "Thoran", "Vexor", "Nyxil", "Orith",
    "Valix", "Myrand", "Zorath", "Kaelor"
];

export const surnamesArray: string[] = [
    "Velindor", "Tharaxis", "Sylphara", "Aelvorn",
    "Morvath", "Elynara", "Xyreth", "Zephris",
    "Kaelyth", "Nyraen", "Lorvex", "Quorinax",
    "Dravys", "Aeryth", "Thundris", "Gryfora",
    "Luminaer", "Orythus", "Veximyr", "Zanthyr",
    "Caelarix", "Nythara", "Vaelorix", "Myrendar",
    "Zorvyn", "Ethrios", "Mordraen", "Xanthara",
    "Yrthalis", "Zarvixan", "Calarun", "Vyrakar",
    "Thandoril", "Lyraxin", "Drexis", "Yvarix",
    "Zenithar", "Aravor", "Morthal", "Sylvoran",
    "Quinixar", "Tharixan", "Valthornus", "Nytharion",
    "Lorvax", "Exarion", "Ziltharix", "Cynthara",
    "Veldoran", "Arxian", "Thyras", "Elyxis",
    "Kythoran", "Rendalar", "Xanorath", "Yrthilix",
    "Zarvixar", "Caelumeth", "Lythorix", "Qyronar",
    "Thoranis", "Vexorath", "Nyxilar", "Orithan",
    "Valixor", "Myrandar", "Zorathel", "Kaeloran",
    "Skyrindar", "Nighsearix", "Flamveilar", "Thornvalix",
    "Stormwieldor", "Emberwindar", "Ironwhisparia", "Ravenfrostix",
    "Shadowgleamar", "Frostechoar", "Moonriftar", "Starbinderix",
    "Voidshaperix", "Earthmeldar", "Sunweaverix", "Seablazix",
    "Wraithbloomar", "Windshardix", "Lightchasar", "Darkwhirlar",
    "Thornspiritix", "Stormglowar", "Firegazix", "Nightstreamar",
    "Duskwingar", "Frostrealmar", "Shadowsparkix", "Ironbloomar",
    "Ravenmistar", "Embermarkix", "Gloomveinar", "Moonshroudar"
];

export const revenantsPicturesLinks: string[] = [
    "https://imgur.com/p90bt7l.jpg", "https://imgur.com/44nuJJa.jpg", "https://imgur.com/u1v8OSj.jpg", "https://imgur.com/iNe79VQ.jpg",
    "https://imgur.com/LVzE8Ai.jpg", "https://imgur.com/ASRDy5w.jpg", "https://imgur.com/2lJ8IMg.jpg", "https://imgur.com/3G1tovh.jpg",
    "https://imgur.com/SGSsvEb.jpg", "https://imgur.com/m2qbrPz.jpg", "https://imgur.com/1zOvm8s.jpg", "https://imgur.com/0H7PcaO.jpg",
    "https://imgur.com/rkOnduZ.jpg", "https://imgur.com/GgaP64s.jpg", "https://imgur.com/Sy8ZETi.jpg", "https://imgur.com/SAp8S5V.jpg",
    "https://imgur.com/K3hfQ3I.jpg", "https://imgur.com/mhYmwOI.jpg", "https://imgur.com/UXhqFGI.jpg", "https://imgur.com/E5Czpsb.jpg",
    "https://imgur.com/nxwWqt9.jpg", "https://imgur.com/441wXgh.jpg", "https://imgur.com/9bn7rJ5.jpg", "https://imgur.com/YjTQ78n.jpg",
    "https://imgur.com/cPEvihc.jpg"
];

//endregion

//region Setting Components Easy   we can just get the schema instead of doing it manually)
// use the 



/**
 * Set the value for a given entity in a given component.
 *
 * @param component {@link defineComponent Component} to be updated.
 * @param entity {@link Entity} whose value in the given component should be set.
 * @param value Value to set, schema must match the component schema.
 *
 * @example
 * ```
 * setComponent(Position, entity, { x: 1, y: 2 });
 * ```
 */
// export function setComponent<S extends Schema, T = unknown>(

// from the recs lib instead of this this is all to delete maybe

export function generateRandomNumber(from: number, to: number): number {
    return Math.floor(Math.random() * to) + from;
}


export const loadInClientOutpostData = (game_id: number, contractComponents: any, clientComponents: any , account: any) => {
    const gameEntityCounter: GameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));
    const outpostCount = gameEntityCounter.outpost_count;

    for (let index = 1; index <= outpostCount; index++) {
        const entityId = getEntityIdFromKeys([BigInt(game_id), BigInt(index)]);

        const outpostData: any = getComponentValueStrict(contractComponents.Outpost, entityId);

        let owned = false;

        if (turnBigIntToAddress(outpostData.owner)  === account.address) { owned = true; }

        setComponent(clientComponents.ClientOutpostData, entityId,
            {
                id: Number(outpostData.entity_id),
                owned: owned,
                event_effected: false,
                selected: false,
                visible: false
            }
        )

        setComponent(clientComponents.EntityTileIndex, entityId,
            {
                tile_index: getTileIndex(outpostData.x, outpostData.y),
            }
        )
    }
}

export function clampPercentage(value: number, min: number, max: number): number {
    return Math.min(Math.max(value, min), max);
}


//endregion
export function getCountFromQuery(data: any, nodeName: string): number {
    return data?.[nodeName]?.total_count || 0;
}

// HERE to do when the outpost trading system is in
export function checkOutpostOnSale() {

}

export function convertBlockCountToTime(number: number): string {
    const totalMinutes = number * 20;

    const days = Math.floor(totalMinutes / (24 * 60));
    const hours = Math.floor((totalMinutes % (24 * 60)) / 60);
    const minutes = Math.floor(totalMinutes % 60);
    const seconds = Math.floor((totalMinutes % 1) * 60);

    return `DD: ${days} HH: ${hours} MM: ${minutes} SS: ${seconds}`;
}

export function isValidArray(input: any): input is any[] {
    return Array.isArray(input) && input != null;
}

export function getFirstComponentByType(entities: any[] | null | undefined, typename: string): any | null {
    if (!isValidArray(entities)) return null;

    for (let entity of entities) {
        if (isValidArray(entity?.node.components)) {
            const foundComponent = entity.node.components.find((comp: any) => comp.__typename === typename);
            if (foundComponent) return foundComponent;
        }
    }
    return null;
}

export function extractAndCleanKey(entities?: any[] | null | undefined): string | null {

    if (!isValidArray(entities) || !entities[0]?.keys) return null;

    return entities[0].keys.replace(/,/g, '');
}


//what?
export function addPrefix0x(input: string | number): string {
    return `0x${input}`;
}

export function decimalToHexadecimal(number: number): string {
    if (isNaN(number) || !isFinite(number)) {
        throw new Error(`Input must be a valid number ${number}`);
    }

    const hexadecimalString = number.toString(16).toUpperCase();
    return `0x${hexadecimalString}`;
}

export function hexToNumber(hexString: string): number {
    return parseInt(hexString, 16);
}



export function truncateString(inputString: string, prefixLength: number): string {
    if (inputString.length <= prefixLength) {
        return inputString; // No need to truncate if the string is already short enough
    }

    const prefix = inputString.substring(0, prefixLength);
    const suffix = inputString.slice(-3);

    return `${prefix}...${suffix}`;
}

export function setComponentsFromGraphQlEntitiesHM(data: any, components: Components, isModel: boolean): void {

    if (data === null && data === undefined) {
        console.error(`something sent to the setComponent func was not correct ${data}`)
        return;
    }

    for (const edge of data.edges) {

        let node = edge.node;

        if (isModel) {
            node = edge.node.entity;
        }

        const keys = node.keys.map((key: string) => BigInt(key));
        const entityIndex = getEntityIdFromKeys(keys);

        for (const model of node.models) {

            const modelKeys = Object.keys(model);
            if (modelKeys.length !== 1) {
                const componentName = model.__typename;
                const component = components[componentName];

                const componentValues = Object.keys(component.schema).reduce((acc: ComponentValue, key) => {
                    const value = model[key];
                    const parsedValue = parseComponentValueFromGraphQLEntity(value, component.schema[key]);
                    acc[key] = parsedValue;
                    return acc;
                }, {});

                // console.log(componentValues)
                setComponent(component, entityIndex, componentValues);
            }
        }
    }
}

export function checkAndSetPhaseClientSide(game_id: number, currentBlockNumber: number, contractComp: any, clientComp: any): { phase: number; blockLeft: number } {
    const gameData: Game = getComponentValueStrict(contractComp.Game, getEntityIdFromKeys([BigInt(game_id)]));
 
    let phase = 1;
    //30                           //10                         //39
    const blockLeft = (gameData.start_block_number + gameData.preparation_phase_interval) - currentBlockNumber

    if (blockLeft <= 0) {
        phase = 2;
    }

    updateComponent(clientComp.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {current_game_state: phase, current_game_id: game_id, current_block_number: currentBlockNumber});
    
    return { phase, blockLeft };
}

export function mapEntityToImage(entityId: number, entityName: string, totalImages: number = 100): number {
    const seed: number = entityId * 1000 + entityName.length;
    const randomNum: number = Math.abs(Math.sin(seed) * 10000);
    const scaledRandom: number = Math.floor(randomNum * totalImages);
    return scaledRandom % totalImages; 
}

export function turnBigIntToAddress(bigint: number): string {
    return "0x"+ BigInt(bigint).toString(16)
}


//there might be issues in the future where the graphql request gets too big i dont think the Models specifc request work correctly honeslty 
// it better to do the entities one


//region Fetch Requests

export const fetchGameTracker = async (graphSDK_: any): Promise<any> => {
    const {
        data: { entities },
    } = await graphSDK_().getGameTracker({ config: decimalToHexadecimal(GAME_CONFIG_ID as number) });

    return entities;
}

export const fetchGameData = async (graphSDK_: any, game_id: number): Promise<any> => {
    const {
        data: { entities },
    } = await graphSDK_().getGameData({ game_id: decimalToHexadecimal(game_id) });

    return entities;
}

export const fetchPlayerInfo = async (graphSDK_: any, game_id: number, owner: string): Promise<any> => {

    const {
        data: { entities },
    } = await graphSDK_().getPlayerInfo({ game_id: decimalToHexadecimal(game_id), owner: owner });

    return entities;
}

export const fetchAllEvents = async (graphSDK_: any, game_id: number, numOfEvents: number): Promise<any> => {

    const {
        data: { worldeventModels },
    } = await graphSDK_().getAllEvents({ game_id: game_id, eventsNumber: numOfEvents });

    return worldeventModels;
}

export const fetchSpecificEvent = async (graphSDK_: any, game_id: number, entity_id: number): Promise<any> => {

    const {
        data: { entities },
    } = await graphSDK_().fetchSpecificEvent({ game_id: decimalToHexadecimal(game_id), entity_id: decimalToHexadecimal(entity_id) });

    return entities;
}

export const fetchSortedPlayerReinforcementList = async (graphSDK_: any, game_id: number, numOfPlayers: number): Promise<any> => {

    const {
        data: { playerinfoModels },
    } = await graphSDK_().getSortedPlayerReinforcements({ game_id: game_id, playersNum: numOfPlayers });

    return playerinfoModels;
}

export const fetchAllOutRevData = async (graphSDK_: any, game_id: number, numOfObjects: number): Promise<any> => {

    const {
        data: { outpostModels },
    } = await graphSDK_().getAllOutRev({ game_id: game_id, outpostCount: numOfObjects });

    return outpostModels;
}

export const fetchAllTrades = async (graphSDK_: any, game_id: number, state: number): Promise<any> => {

    const {
        data: { tradeModels },
    } = await graphSDK_().getTradesAvailable({ game_id: game_id, tradeStatus: state });

    return tradeModels;
}

export const fetchSpecificOutRevData = async (graphSDK_: any, game_id: number, entity_id: number): Promise<any> => {

    const {
        data: { entities },
    } = await graphSDK_().fetchSpecificOutRev({ game_id: decimalToHexadecimal(game_id), entity_id: decimalToHexadecimal(entity_id) });

    return entities;
}

export const fetchAllOwnOutRevData = async (graphSDK_: any, game_id: number, numOfObjects: number, account: any): Promise<any> => {

    const {
        data: { outpostModels },
    } = await graphSDK_().getAllOwnRevOut({ game_id: game_id, outpostCount: numOfObjects, owner: account.address });

    return outpostModels;
}

//endregion