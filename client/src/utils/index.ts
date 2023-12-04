

import { getEntityIdFromKeys, parseComponentValueFromGraphQLEntity, setComponentFromGraphQLEntity } from "@dojoengine/utils";
import { setComponent, Components, ComponentValue } from "@latticexyz/recs";




//region Names

export const namesArray: string[] = [
    "Mireth",
    "Vexara",
    "Zorion",
    "Caelix",
    "Elyndor",
    "Tharion",
    "Sylphren",
    "Aravax",
    "Vexil",
    "Lyrandar",
    "Nyxen",
    "Theralis",
    "Qyra",
    "Fenrix",
    "Atheris",
    "Lorvael",
    "Xyris",
    "Zephyron",
    "Calaer",
    "Drakos",
    "Velixar",
    "Syrana",
    "Morvran",
    "Elithran",
    "Kaelith",
    "Tyrven",
    "Ysara",
    "Vorenth",
    "Alarix",
    "Ethrios",
    "Nyrax",
    "Thrayce",
    "Vynora",
    "Kerith",
    "Jorvax",
    "Lysandor",
    "Eremon",
    "Xanthe",
    "Zanther",
    "Cindris",
    "Baelor",
    "Lyvar",
    "Eryth",
    "Zalvor",
    "Gormath",
    "Sylvanix",
    "Quorin",
    "Taryx",
    "Nyvar",
    "Oryth",
    "Valeran",
    "Myrthil",
    "Zorvath",
    "Kyrand",
    "Thalren",
    "Vexim",
    "Aelar",
    "Grendar",
    "Xylar",
    "Zorael",
    "Calyph",
    "Vyrak",
    "Thandor",
    "Lyrax",
    "Riven",
    "Drexel",
    "Yvaris",
    "Zenthil",
    "Aravorn",
    "Morthil",
    "Sylvar",
    "Quinix",
    "Tharix",
    "Valthorn",
    "Nythar",
    "Lorvax",
    "Exar",
    "Zilthar",
    "Cynthis",
    "Veldor",
    "Arix",
    "Thyras",
    "Mordran",
    "Elyx",
    "Kythor",
    "Rendal",
    "Xanor",
    "Yrthil",
    "Zarvix",
    "Caelum",
    "Lythor",
    "Qyron",
    "Thoran",
    "Vexor",
    "Nyxil",
    "Orith",
    "Valix",
    "Myrand",
    "Zorath",
    "Kaelor"
];

export const surnamesArray: string[] = [
    "Velindor",
    "Tharaxis",
    "Sylphara",
    "Aelvorn",
    "Morvath",
    "Elynara",
    "Xyreth",
    "Zephris",
    "Kaelyth",
    "Nyraen",
    "Lorvex",
    "Quorinax",
    "Dravys",
    "Aeryth",
    "Thundris",
    "Gryfora",
    "Luminaer",
    "Orythus",
    "Veximyr",
    "Zanthyr",
    "Caelarix",
    "Nythara",
    "Vaelorix",
    "Myrendar",
    "Zorvyn",
    "Ethrios",
    "Mordraen",
    "Xanthara",
    "Yrthalis",
    "Zarvixan",
    "Calarun",
    "Vyrakar",
    "Thandoril",
    "Lyraxin",
    "Drexis",
    "Yvarix",
    "Zenithar",
    "Aravor",
    "Morthal",
    "Sylvoran",
    "Quinixar",
    "Tharixan",
    "Valthornus",
    "Nytharion",
    "Lorvax",
    "Exarion",
    "Ziltharix",
    "Cynthara",
    "Veldoran",
    "Arxian",
    "Thyras",
    "Elyxis",
    "Kythoran",
    "Rendalar",
    "Xanorath",
    "Yrthilix",
    "Zarvixar",
    "Caelumeth",
    "Lythorix",
    "Qyronar",
    "Thoranis",
    "Vexorath",
    "Nyxilar",
    "Orithan",
    "Valixor",
    "Myrandar",
    "Zorathel",
    "Kaeloran",
    "Skyrindar",
    "Nighsearix",
    "Flamveilar",
    "Thornvalix",
    "Stormwieldor",
    "Emberwindar",
    "Ironwhisparia",
    "Ravenfrostix",
    "Shadowgleamar",
    "Frostechoar",
    "Moonriftar",
    "Starbinderix",
    "Voidshaperix",
    "Earthmeldar",
    "Sunweaverix",
    "Seablazix",
    "Wraithbloomar",
    "Windshardix",
    "Lightchasar",
    "Darkwhirlar",
    "Thornspiritix",
    "Stormglowar",
    "Firegazix",
    "Nightstreamar",
    "Duskwingar",
    "Frostrealmar",
    "Shadowsparkix",
    "Ironbloomar",
    "Ravenmistar",
    "Embermarkix",
    "Gloomveinar",
    "Moonshroudar"
];

//endregion










//region Setting Components Easy

function createComponentStructure(componentSchema: any, keys: string[], componentName: string): any {
    return {
        "node": {
            "keys": keys,
            "models": [
                {
                    "__typename": componentName,
                    ...componentSchema
                }
            ]
        }
    };
}

export const setClientGameComponent = async (phase: number, game_id: number, current_block: number, guest: boolean, clientComponents: any) => {

    const componentSchemaClientGameData = {
        "current_game_state": phase,
        "current_game_id": game_id,
        "current_block_number": current_block,
        "guest": guest,
    };

    const craftedEdgeClientGameComp = createComponentStructure(componentSchemaClientGameData, ["0x1"], "ClientGameData");
    setComponentFromGraphQLEntity(clientComponents, craftedEdgeClientGameComp);
}

export const setClientOutpostComponent = async (id: number, owned: boolean, event_effected: boolean, selected: boolean, visible: boolean, clientComponents: any, game_id: number, entity_id, number) => {

    const componentSchemaClientOutpostData = {
        "id": id,
        "owned": owned,
        "event_effected": event_effected,
        "selected": selected,
        "visible": visible,
    };

    const craftedEdgeClientOutpostComp = createComponentStructure(componentSchemaClientOutpostData, [decimalToHexadecimal(game_id), decimalToHexadecimal(entity_id)], "ClientOutpostData");
    setComponentFromGraphQLEntity(clientComponents, craftedEdgeClientOutpostComp);
}

/**
 * Sets the client click position component based on provided coordinates.
 * 
 * @param xFromOrigin - The x-coordinate from the origin (top left).
 * @param yFromOrigin - The y-coordinate from the origin (top left).
 * @param xFromMiddle - The x-coordinate from the middle of the screen.
 * @param yFromMiddle - The y-coordinate from the middle of the screen.
 */
export const setClientClickPositionComponent = async (xFromOrigin: number, yFromOrigin: number, xFromMiddle: number, yFromMiddle: number, clientComponents: any) => {

    const componentSchemaClientClickPosition = {
        "xFromOrigin": xFromOrigin,
        "yFromOrigin": yFromOrigin,
        "xFromMiddle": xFromMiddle,
        "yFromMiddle": yFromMiddle,
    };

    const craftedEdgeClientClickPositionComp = createComponentStructure(componentSchemaClientClickPosition, ["0x1"], "ClientClickPosition");
    setComponentFromGraphQLEntity(clientComponents, craftedEdgeClientClickPositionComp);
}

export const setClientCameraComponent = async (x: number, y: number, tile_index: number, clientComponents: any) => {

    const componentSchemaClientCamera = {
        "x": x,
        "y": y,
        "tile_index": tile_index,
    };

    const craftedEdgeClientCameraComp = createComponentStructure(componentSchemaClientCamera, ["0x1"], "ClientCameraPosition");
    setComponentFromGraphQLEntity(clientComponents, craftedEdgeClientCameraComp);
}

//endregion



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


// export function addPrefix0x(input: string | number): string {
//     // Add '0x' prefix to the input
//     return `0x${input}`;
// }

export function decimalToHexadecimal(number: number): string {
    if (isNaN(number) || !isFinite(number)) {
        throw new Error("Input must be a valid number");
    }

    // Using toString with base 16 to convert the number to hexadecimal
    const hexadecimalString = number.toString(16).toUpperCase();
    return `0x${hexadecimalString}`;
}

export function truncateString(inputString: string, prefixLength: number): string {
    if (inputString.length <= prefixLength) {
        return inputString; // No need to truncate if the string is already short enough
    }

    const prefix = inputString.substring(0, prefixLength);
    const suffix = inputString.slice(-3);

    return `${prefix}...${suffix}`;
}



export function setComponentFromGraphQLEntityTemp(components: Components, entity: any) {
    const keys = entity.keys.map((key: string) => BigInt(key));
    const entityIndex = getEntityIdFromKeys(keys);

    entity.models.forEach((model: any) => {
        const componentName = model.__typename;
        const component = components[componentName];

        if (!component) {
            console.error(`Component ${componentName} not found`);
            return;
        }

        const componentValues = Object.keys(component.schema).reduce((acc: ComponentValue, key) => {
            const value = model[key];
            const parsedValue = parseComponentValueFromGraphQLEntity(value, component.schema[key]);
            acc[key] = parsedValue;
            return acc;
        }, {});

        console.log(componentValues)
        setComponent(component, entityIndex, componentValues);
    });
}

