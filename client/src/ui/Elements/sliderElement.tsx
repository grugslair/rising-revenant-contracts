import React, { useState, useEffect, useRef, MouseEvent } from 'react';

interface SliderProps {
    minValue: number;
    maxValue: number;
    startingValue: number;
    onChange: (value: number) => void;
    trackStyle?: React.CSSProperties;
    buttonStyle?: React.CSSProperties;
    containerStyle?: React.CSSProperties;
    precision?: number; // Precision for rounding
    showVal?: boolean;
    left?: boolean;
    gap?: string;
    onDrag?: (isDragging: boolean) => void;
}

const CustomSlider: React.FC<SliderProps> = ({ minValue, maxValue, startingValue, onChange, trackStyle, buttonStyle, containerStyle,onDrag, precision = 0, showVal = false, left = true, gap = "10px" }) => {

    const [value, setValue] = useState(startingValue);
    const [buttonPos, setButtonPos] = useState<number>(findPercentageDecimal(minValue, maxValue, startingValue));
    const [isDragging, setIsDragging] = useState(false);
    const sliderRef = useRef<HTMLDivElement>(null);
    const buttonRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        setValue(startingValue);
        setButtonPos(findPercentageDecimal(minValue, maxValue, startingValue) * 100);
    }, []);

    function calculatePercentage(min: number, max: number, percentage: number): number {
        const range: number = max - min;
        const result: number = min + percentage * range;
        return result;
    };

    function findPercentageDecimal(min: number, max: number, value: number): number {
        const range: number = max - min;
        const percentage: number = (value - min) / range;
        return percentage;
    };

    const handleMouseMove = (event: MouseEvent<HTMLDivElement>) => {

        if (isDragging && sliderRef.current && buttonRef.current) {
            const rect = sliderRef.current.getBoundingClientRect();
            const button = buttonRef.current.getBoundingClientRect();
            const leeway = 1.4;

            if (event.clientX >= rect.x + button.width / 2 && event.clientX <= rect.x + rect.width - button.width / 2) {
                const percentageButtonPos = (event.clientX - rect.x) / rect.width;
                setButtonPos(percentageButtonPos * 100)

                const percDec = findPercentageDecimal(rect.x + (button.width / 2) * leeway, rect.x + rect.width - (button.width / 2) * leeway, button.x + button.width / 2);

                let val = Math.round(calculatePercentage(minValue, maxValue, percDec) * Math.pow(10, precision)) / Math.pow(10, precision);

                if (val < minValue) {
                    val = minValue
                }
                else if (val > maxValue) {
                    val = maxValue
                }

                setValue(val);
                onChange(val);
            }
        }
    };

    const handleMouseDown = (event: MouseEvent<HTMLDivElement>) => {
        setIsDragging(true);
        if (onDrag) {
            onDrag(true);
        }
    };

    const handleMouseUp = () => {
        setIsDragging(false);
        if (onDrag) {
            onDrag(false);
        }
    };

    const positionOfButton: React.CSSProperties = {
        left: `${buttonPos}%`,
        transform: 'translate(-50%, 0%)',
        position: 'absolute',
        cursor: 'pointer',
        ...buttonStyle,
    };

    return (
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: `${gap}` }}>
            {left && showVal && <h2 className='test-h2 no-margin'>{value}</h2>}
            <div
                ref={sliderRef}
                style={{ ...containerStyle, position: 'relative' }}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={handleMouseUp}
            >
                <div style={{ ...trackStyle }}></div>
                <div ref={buttonRef} style={{ ...positionOfButton }} className='pointer'></div>
            </div>
            {!left && showVal && <h2 className='test-h2 no-margin' style={{ marginRight: "10px" }}>{value}</h2>}
        </div>
    );
};

export default CustomSlider;
