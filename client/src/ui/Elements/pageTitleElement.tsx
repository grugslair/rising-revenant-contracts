import React, { CSSProperties } from "react";
import { ClickWrapper } from "../clickWrapper";
import { functionDeclaration } from "@babel/types";

interface PageTitleElementProps {
    imagePosition: ImagesPosition,
    name: string,

    rightPicture?:string,
    leftPicture?:string,

    rightImageFunction? : () => void,
    leftImageFunction? : () => void,

    htmlContentsRight?:any,
    htmlContentsLeft?:any,
    styleContainerRight?:any,
    styleContainerLeft?:any,
}

export enum ImagesPosition{
    LEFT,
    RIGHT,
    BOTH,
    NONE
}

const size: string = "clamp(1.1rem, 1vw + 0.8rem, 8rem)"; // this is test-h1 size

// const leftContainerStyle: CSSProperties = {    
//     display: "flex",
//     flexDirection: "row",
//     justifyContent: "space-between",
//     alignItems: "center",
    
//     position: "relative",

//     color: "white",

//     boxSizing: "border-box",
// }

const leftContainerStyle: CSSProperties = {
    flex: "1",
    height: "100%",

    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-start",
    alignItems: "center",
}

const rightContainerStyle: CSSProperties = {
    flex: "1",
    height: "100%",

    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-end",
    alignItems: "center",
}

const titleContainerStyle: CSSProperties = {
    flex: "1",
    height: "100%",

    display: "flex",
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",

    fontSize: "1cqw",
    fontFamily: "Zelda",
}

const PageTitleElement: React.FC<PageTitleElementProps> = ({ name, rightImageFunction,leftImageFunction,rightPicture,imagePosition, leftPicture, htmlContentsLeft, htmlContentsRight, styleContainerRight, styleContainerLeft}) => {
    return (
        <div style={{
            height: "15%",
            width: "100%",
            boxSizing: "border-box",
            display: "flex",
            flexDirection: "row",
            position: "relative",
            justifyContent: "space-between",
            alignItems: "center",
        }}>
            <div style={{ width: size}}></div>

            {imagePosition === ImagesPosition.LEFT || imagePosition === ImagesPosition.BOTH ? (
                <img
                    src={leftPicture}
                    style={{ width: size, height: size, cursor: 'pointer',verticalAlign:"middle",paddingBottom:"0.1em" }}
                    alt="Left Image"
                    onClick={leftImageFunction}
                />
            ) : <div style={{ width: size }} />}

            <div style={{height:"100%", flex:"1", ...styleContainerLeft}}>
                {htmlContentsLeft}
            </div>


            <h1 className="no-margin test-h1-75" style={{ whiteSpace: "nowrap", fontWeight: "100", fontFamily:"Zelda", color:"white" }}>{name}</h1>
            
            <div style={{height:"100%", flex:"1", ...styleContainerRight}}>
                {htmlContentsRight}
            </div>

            {imagePosition === ImagesPosition.RIGHT || imagePosition === ImagesPosition.BOTH ? (
                <img
                    src={rightPicture}
                    style={{ width: size, height: size, cursor: 'pointer', verticalAlign:"middle", paddingBottom:"0.1em" }}
                    alt="Right Image"
                    onClick={rightImageFunction}
                />
            ) : <div style={{ width: size }} />}
            <div style={{ width: size}}></div>
        </div>
    );
};

export default PageTitleElement;


