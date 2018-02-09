function [angleChange] = computeChangeInVectorDirection(p1, p2, p3)  
    startVectorX = p2(1) - p1(1);
    startVectorY = p2(2) - p1(2);
    startVectorAngle = atan2(startVectorY, startVectorX);

    endVectorX = p3(1) - p2(1);
    endVectorY = p3(2) - p2(2);
    endVectorAngle = atan2(endVectorY, endVectorX);

    angleChange = radtodeg(endVectorAngle - startVectorAngle);
    if(angleChange > 180)
       angleChange = 360 - angleChange; 
    elseif (angleChange < -180)
       angleChange = 360 + angleChange;
    end
end

