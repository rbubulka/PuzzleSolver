function [rotatedPiece] = handleRotation(singlePieceMask)
    covarM = computeCovarianceM(singlePieceMask);
    [maxVec, maxVal] = eigs(covarM,1);
    angle = radtodeg(atan2(maxVec(2),maxVec(1)));
    
    rotatedPiece = imrotate(singlePieceMask, angle);
end

