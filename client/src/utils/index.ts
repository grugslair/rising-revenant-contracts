

import { getEntityIdFromKeys, parseComponentValueFromGraphQLEntity } from "@dojoengine/utils";
import { setComponent, Components, ComponentValue } from "@latticexyz/recs";





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

