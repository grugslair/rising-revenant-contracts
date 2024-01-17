import { useEffect, useRef, useState } from "react";

export const useResizeableHeight = (colNum: number, rowNum: number, setWidth: string) => {
    const clickWrapperRef = useRef<HTMLDivElement>(null);
    const [heightValue, setHeight] = useState<number>(0);
  
    useEffect(() => {
      const updateHeight = () => {
        if (clickWrapperRef.current) {
          setHeight((clickWrapperRef.current.offsetWidth / colNum) * rowNum);
        }
      };
  
      window.addEventListener('resize', updateHeight);
  
      updateHeight();
  
      return () => {
        window.removeEventListener('resize', updateHeight);
      };
    }, []);
  
    const clickWrapperStyle: React.CSSProperties = {
      height: `${heightValue}px`,
      width: setWidth
    };
  
    return { clickWrapperRef, clickWrapperStyle };
  };
  