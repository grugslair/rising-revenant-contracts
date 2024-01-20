import { useEffect, useState } from "react";
import { useDojo } from "../../hooks/useDojo";
import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue } from "@latticexyz/recs";

export const useOutpostAmountData = () => {
    const [outpostsLeftNumber, setOutpostsLeft] = useState<number>(0);

    const {
        networkLayer: {
            network: { contractComponents, clientComponents}
        }
    } = useDojo();

    const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
    const totalOutpostsQuery = useEntityQuery([Has(contractComponents.Outpost)]);
    const ownOutpostsQuery = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true })]);
    const outpostsHitQuery = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { event_effected: true })]);

    useEffect(() => {
       console.error("\n\n\n\n\n")
        console.error(outpostDeadQuery.length)
        console.error(totalOutpostsQuery.length)
        console.error(ownOutpostsQuery.length)
        console.error(outpostsHitQuery.length)
        console.error(outpostsLeftNumber)

    }, [outpostDeadQuery, totalOutpostsQuery, ownOutpostsQuery, outpostsHitQuery, outpostsLeftNumber]);

    //can be custom hooked
    useEffect(() => {
        setOutpostsLeft(totalOutpostsQuery.length - outpostDeadQuery.length)
    }, [outpostDeadQuery]);

    return { totalOutpostsQuery, outpostDeadQuery, ownOutpostsQuery,outpostsHitQuery, outpostsLeftNumber };
};
