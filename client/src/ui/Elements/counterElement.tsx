import React, { CSSProperties } from "react";

interface CounterElementProps {
    value: number;
    setValue: (value: number) => void;
}

const containerStyle: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: "start",
    gap: "15%",
    alignItems: "center",
}

const additionalButtonStyle: CSSProperties = {
    fontSize: "2rem",  
    width: "min(10%, 40px)",
    aspectRatio: "1/1",
    display: "flex", 
    justifyContent: "center", 
    alignItems: "center"
};


const CounterElement: React.FC<CounterElementProps> = ({ value, setValue }) => {
    return (
        <div style={containerStyle}>
            <div className="global-button-style" onMouseDown={() => { setValue(value - 1) }} style={additionalButtonStyle}> - </div>
            <h2 style={{fontSize:"2.5rem", fontWeight:"100"}}>{value}</h2>
            <div className="global-button-style" onMouseDown={() => { setValue(value + 1) }} style={additionalButtonStyle}> + </div>
        </div>
    );
};

export default CounterElement;


