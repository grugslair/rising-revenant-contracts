import React, { CSSProperties, useEffect } from "react";

interface CounterElementProps {
    value: number;
    setValue: (value: number) => void;
    minVal?: number;
    maxVal?: number;
    containerStyleAddition?: CSSProperties;
    additionalButtonStyleAdd?: CSSProperties;
    textAddtionalStyle?: CSSProperties;
}

const containerStyle: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: "space-between",
    gap: "15%",
    alignItems: "center",
}

const additionalButtonStyle: CSSProperties = {
    fontSize: "2rem",
    width: "min(10%, 40px)",
    aspectRatio: "1/1",
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
};

const CounterElement: React.FC<CounterElementProps> = ({ value, setValue, containerStyleAddition, additionalButtonStyleAdd, textAddtionalStyle, minVal, maxVal }) => {


    useEffect(() => {
        if (value < 1) {
            setValue(1);
            return;
        }

        if (minVal !== undefined) {
            if (value < minVal) {
                setValue(minVal);
            }
        }

        if (maxVal !== undefined) {
            if (value > maxVal) {
                setValue(maxVal);
            }
        }

    }, [value]);

    return (
        <div style={{ ...containerStyle, ...containerStyleAddition }}>

            {minVal === undefined ?
                <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value - 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd }}>
                    <img src="Icons//minus.png" alt="minus" style={{ width: "100%", height: "100%" }} />
                </div>
                :
                <>
                    {minVal === value ?
                        <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value - 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd, pointerEvents: "none", opacity: "0%" }}>
                            <img src="Icons//minus.png" alt="minus" style={{ width: "100%", height: "100%" }} />
                        </div>
                        :
                        <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value - 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd }}>
                            <img src="Icons//minus.png" alt="minus" style={{ width: "100%", height: "100%" }} />
                        </div>
                    }
                </>
            }

            <h2 style={{ fontSize: "2.5rem", fontWeight: "100", fontFamily: "OL", ...textAddtionalStyle }}>{value}</h2>

            {maxVal === undefined ?
                <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value + 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd }}>
                    <img src="Icons//plus.png" alt="plus" style={{ width: "100%", height: "100%" }} />
                </div>
                :
                <>
                    {maxVal === value ?
                        <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value + 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd, pointerEvents: "none", opacity: "0%" }}>
                            <img src="Icons//plus.png" alt="plus" style={{ width: "100%", height: "100%" }} />
                        </div>
                        :
                        <div className="global-button-style invert-colors " onMouseDown={() => { setValue(value + 1) }} style={{ ...additionalButtonStyle, ...additionalButtonStyleAdd }}>
                            <img src="Icons//plus.png" alt="plus" style={{ width: "100%", height: "100%" }} />
                        </div>
                    }
                </>
            }

        </div>
    );
};

export default CounterElement;


