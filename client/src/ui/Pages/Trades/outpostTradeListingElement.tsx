import { useState } from "react";

interface ItemListingProp {
    guest: number
    entityData: any
    game_id: number
}

// this should take the trade id 
export const OutpostListingElement: React.FC<ItemListingProp> = ({ guest, entityData, game_id }) => {

    const [shieldsAmount, setShieldsAmount] = useState<number>(5);
    //get the data of the outpost and trade

    return (
        <div className="outpost-sale-element-container">
            <div className="outpost-grid-pic">
                <img src="test_out_pp.png" className="test-embed" alt="" style={{ width: "100%", height: "100%" }} />
            </div>

            <div className="outpost-grid-shield center-via-flex">
                <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: "2px", width: "100%", height: "50%" }}>
                    {Array.from({ length: 5 }, (_, index) => (
                        index < shieldsAmount ? (
                            <img key={index} src="SHIELD.png" alt={`Shield ${index + 1}`} style={{ width: "100%", height: "100%" }} />
                        ) : (
                            <div key={index} style={{ width: "100%", height: "100%" }} />
                        )
                    ))}
                </div>
            </div>

            <div className="outpost-grid-id outpost-flex-layout "># 74</div>
            <div className="outpost-grid-reinf-amount outpost-flex-layout ">Reinforcement: 54</div>
            <div className="outpost-grid-owner outpost-flex-layout" >Owner: 0x636...13</div>
            <div className="outpost-grid-show outpost-flex-layout ">
                <h3 style={{ backgroundColor: "#2F2F2F", padding: "3px 5px" }}>Show on map</h3>
            </div>
            <div className="outpost-grid-cost outpost-flex-layout ">Price: $57 LORDS</div>
            <div className="outpost-grid-buy-button center-via-flex">
                {guest ? (<h3 style={{ fontWeight: "100", fontFamily: "Zelda", color: "black", filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</h3>) : (<h3 style={{ fontWeight: "100", fontFamily: "Zelda", color: "black" }}>BUY NOW</h3>)}
            </div>
        </div>
    )
}