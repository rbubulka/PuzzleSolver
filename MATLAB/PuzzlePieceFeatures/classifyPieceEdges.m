function [] = classifyPieceEdges(singlePieceMask)

    covarM = computeCovarianceM(singlePieceMask);
    [maxVec, maxVal] = eigs(covarM,1);
    angle = radtodeg(atan2(maxVec(2),maxVec(1)));
    
    rotatedPiece = imrotate(singlePieceMask, angle);

    % Find pixels along perimeter of piece
    [r,c] = find(rotatedPiece == 1);
    minCol = min(c);
    minColIdx = min(find(c == minCol));
    startingPt = [r(minColIdx), c(minColIdx)];
    perimCoords = bwtraceboundary(rotatedPiece, startingPt, 'E',8);
    numPerimPts = size(perimCoords,1);

    % Find way to define convex hull?
    pieceConvexHull = bwconvhull(rotatedPiece);
    [r,c] = find(rotatedPiece == 1);
    minCol = min(c);
    minColIdx = min(find(c == minCol));
    startingPt = [r(minColIdx), c(minColIdx)];
    convexHullPerim = bwtraceboundary(pieceConvexHull, startingPt, 'E',8);
    
    % Find points where perimeter is not straight
    imtool(pieceConvexHull);
    stepSize = 4;
    wrapIndex = @(a, n) (mod(a-1, n) + 1);
    
    curvature = zeros(1, numPerimPts);
    distToConvexHull = zeros(1, numPerimPts);
    for j = 1:numPerimPts
        % Find whether current point is part of curve
        precedingIdx = wrapIndex(j-stepSize, numPerimPts);
        currIdx = j;
        laterIdx = wrapIndex(j + stepSize, numPerimPts);
        prevX = perimCoords(precedingIdx, 1);
        prevY = perimCoords(precedingIdx, 2);
        currX = perimCoords(currIdx, 1);
        currY = perimCoords(currIdx, 2);
        futureX = perimCoords(laterIdx, 1);
        futureY = perimCoords(laterIdx, 2);
        
        prevVectorX = currX - prevX;
        prevVectorY = currY - prevY;
        prevVectorAngle = atan2(prevVectorY, prevVectorX);
        
        futureVectorX = futureX - currX;
        futureVectorY = futureY - currY;
        futureVectorAngle = atan2(futureVectorY, futureVectorX);
        
        angleChange = radtodeg(futureVectorAngle - prevVectorAngle);
        if(angleChange > 180)
           angleChange = 360 - angleChange; 
        end
        curvature(j) = angleChange;
        
        % Find distnace from perimiter point to convex hull
        allDistsToHull = sqrt((convexHullPerim(:,1) - currX).^2 + (convexHullPerim(:,2) - currY).^2);
        distToConvexHull(j) = min(allDistsToHull);
    end
    curvatureThresh = 30;
    curvedIdx = find(curvature > curvatureThresh | curvature < 0-curvatureThresh);
    
    farHullThresh = 3;
    farFromHullIdx = find(distToConvexHull > farHullThresh);
    
    closeHullThresh = 1;
    closeToHullIdx = find(distToConvexHull < closeHullThresh);
    imshow(rotatedPiece);
    hold on;
    plot(perimCoords(closeToHullIdx, 2), perimCoords(closeToHullIdx, 1), 'bd');
    plot(perimCoords(curvedIdx, 2), perimCoords(curvedIdx, 1), 'ro');
    plot(perimCoords(farFromHullIdx, 2), perimCoords(farFromHullIdx, 1), 'gs');
end

