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

    const totalOutpostsQuery = useEntityQuery([Has(contractComponents.Outpost)], {
        updateOnValueChange: false,
    });
    const ownOutpostsQuery = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true })], {
        updateOnValueChange: false,
    });

    const outpostsHitQuery = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { event_effected: true })]);

    //can be custom hooked
    useEffect(() => {
        setOutpostsLeft(totalOutpostsQuery.length - outpostDeadQuery.length)
    }, [outpostDeadQuery]);

    return { totalOutpostsQuery, outpostDeadQuery, ownOutpostsQuery,outpostsHitQuery, outpostsLeftNumber };
};
