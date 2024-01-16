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
}

const CustomSlider: React.FC<SliderProps> = ({ minValue, maxValue, startingValue, onChange, trackStyle, buttonStyle, containerStyle, precision = 0 }) => {

    const [value, setValue] = useState(startingValue);
    const [buttonPos, setButtonPos] = useState< number >( findPercentageDecimal(minValue, maxValue, startingValue) );
    const [isDragging, setIsDragging] = useState(false);
    const sliderRef = useRef<HTMLDivElement>(null);
    const buttonRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        setValue(startingValue);
        setButtonPos(findPercentageDecimal(minValue, maxValue, startingValue) * 100 );
    }, []);

    function calculatePercentage(min: number, max: number, percentage: number): number {
        const range: number = max - min;
        const result: number = min + percentage * range;
        return result;
    }

    function findPercentageDecimal(min: number, max: number, value: number): number {
        const range: number = max - min;
        const percentage: number = (value - min) / range;
        return percentage;
    }

    const handleMouseDown = (event: MouseEvent<HTMLDivElement>) => {
        setIsDragging(true);
    };

    const handleMouseMove = (event: MouseEvent<HTMLDivElement>) => {

        if (isDragging && sliderRef.current && buttonRef.current) {
            const rect = sliderRef.current.getBoundingClientRect();
            const button = buttonRef.current.getBoundingClientRect();
            const leeway = 1.4;
            
            if (event.clientX >= rect.x + button.width/2  &&  event.clientX <= rect.x + rect.width- button.width/2){
                const percentageButtonPos = (event.clientX - rect.x)/ rect.width;
                setButtonPos(percentageButtonPos*100)

                const percDec = findPercentageDecimal(rect.x + (button.width/2 )* leeway, rect.x + rect.width - (button.width/2 )* leeway, button.x + button.width/2);

                let val =  Math.round( calculatePercentage(minValue, maxValue, percDec) * Math.pow(10,precision)) / Math.pow(10,precision);

                if (val < minValue){
                    val = minValue
                }
                else if (val > maxValue) {
                    val = maxValue
                }

                setValue(val);
                onChange(val);
            }
        }
    }

    const handleMouseUp = () => {
        setIsDragging(false);
    };

    const positionOfButton: React.CSSProperties = {
        left: `${buttonPos}%`,
        transform: 'translate(-50%, 0%)',
        position: 'absolute',
        cursor: 'pointer',
        ...buttonStyle,
    };

    return (
        <div
            ref={sliderRef}
            style={{ ...containerStyle, position: 'relative' }}
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={handleMouseUp}
            onMouseLeave={handleMouseUp}
        >
            <div style={{ ...trackStyle }}></div>
            <div ref={buttonRef} style={{ ...positionOfButton}} className='pointer'></div>
        </div>
    );
};

export default CustomSlider;
