import React, { CSSProperties } from "react";
import { ClickWrapper } from "../clickWrapper";

export enum ImagesPosition {
    NONE,
    LEFT,
    RIGHT,
    BOTH
}

interface PageTitleElementProps {
    name: string;
    imagePosition?: ImagesPosition;

    rightPicture?: string;
    leftPicture?: string;
    rightImageFunction?: () => void;
    leftImageFunction?: () => void;

    htmlContentsLeft?: any;
    htmlContentsRight?: any;
    styleContainerLeft?: any;
    styleContainerRight?: any;
}

const size: string = "clamp(1.1rem, 1.6vw + 0.9rem, 10rem)"; // this is test-h1 size

const PageTitleElement: React.FC<PageTitleElementProps> = ({ name, imagePosition = ImagesPosition.NONE, rightPicture, leftPicture, rightImageFunction, leftImageFunction, htmlContentsLeft, htmlContentsRight, styleContainerLeft, styleContainerRight }) => {
    
    const handleLeftImageClick = () => {
        if (leftImageFunction) {
            leftImageFunction();
        }
    };

    const handleRightImageClick = () => {
        if (rightImageFunction) {
            rightImageFunction();
        }
    };

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
                    style={{ width: size, height: size, cursor: 'pointer',verticalAlign:"middle",paddingBottom:"0.3em" }}
                    alt="Left Image"
                    onClick={handleLeftImageClick}
                />
            ) : <div style={{ width: size }} />}

            <div style={{height:"100%", flex:"1", ...styleContainerLeft}}>
                {htmlContentsLeft}
            </div>


            <h1 className="no-margin test-h1" style={{ whiteSpace: "nowrap", fontWeight: "100", fontFamily:"Zelda", color:"white" }}>{name}</h1>
            
            <div style={{height:"100%", flex:"1", ...styleContainerRight}}>
                {htmlContentsRight}
            </div>

            {imagePosition === ImagesPosition.RIGHT || imagePosition === ImagesPosition.BOTH ? (
                <img
                    src={rightPicture}
                    style={{ width: size, height: size, cursor: 'pointer', verticalAlign:"middle", paddingBottom:"0.3em" }}
                    alt="Right Image"
                    onClick={handleRightImageClick}
                />
            ) : <div style={{ width: size }} />}
            <div style={{ width: size}}></div>
        </div>
    );
};

export default PageTitleElement;