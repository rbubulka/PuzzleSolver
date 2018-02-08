function [] = classifyPieceEdges(singlePieceMask)
    wrapIndex = @(a, n) (mod(a-1, n) + 1);
    
    % Find pixels along perimeter of piece
    [r,c] = find(singlePieceMask == 1);
    minCol = min(c);
    minColIdx = min(find(c == minCol));
    startingPt = [r(minColIdx), c(minColIdx)];
    perimCoords = bwtraceboundary(singlePieceMask, startingPt, 'E',8);
    numPerimPts = size(perimCoords,1);
    
    % Find piece center
    rowMean = mean(r);
    colMean = mean(c);
    pieceCenter = [round(rowMean), round(colMean)];

    % Define outside of convex hull
    pieceConvexHull = bwconvhull(singlePieceMask);
    [r,c] = find(singlePieceMask == 1);
    minCol = min(c);
    minColIdx = min(find(c == minCol));
    startingPt = [r(minColIdx), c(minColIdx)];
    convexHullPerim = bwtraceboundary(pieceConvexHull, startingPt, 'E',8);
    
    % Find points where perimeter is not straight
%     imtool(pieceConvexHull);
    stepSize = 2;
    
    curvature = zeros(numPerimPts, 1);
    distToConvexHull = zeros(numPerimPts, 1);
    for j = 1:numPerimPts
        % Find whether current point is part of curve
        precedingIdx = wrapIndex(j-stepSize, numPerimPts);
        currIdx = j;
        laterIdx = wrapIndex(j + stepSize, numPerimPts);
        prevPt = perimCoords(precedingIdx, :);
        currPt = perimCoords(currIdx, :);
        futurePt = perimCoords(laterIdx, :);
        
        curvature(j) = computeChangeInVectorDirection(prevPt, currPt, futurePt);
        
        % Find distnace from perimiter point to convex hull
        allDistsToHull = sqrt((convexHullPerim(:,1) - currPt(1)).^2 + (convexHullPerim(:,2) - currPt(2)).^2);
        distToConvexHull(j) = min(allDistsToHull);
    end
    curvatureThresh = 30;
    curvedIdx = find(curvature > curvatureThresh | curvature < 0-curvatureThresh);
    
    farHullThresh = 3;
    farFromHullIdx = find(distToConvexHull > farHullThresh);
    
    closeHullThresh = 1.5;
    closeToHullIdx = find(distToConvexHull < closeHullThresh);
    imshow(singlePieceMask);
    hold on;
    
    indentRegions = findIndents(singlePieceMask, perimCoords, curvedIdx, farFromHullIdx);
    outdentRegions = findOutdents(singlePieceMask, perimCoords, curvedIdx, closeToHullIdx);
    idx = sub2ind(size(singlePieceMask), pieceCenter(1), pieceCenter(2));
    indentRegions(idx) = 1;
    
%     plot(perimCoords(closeToHullIdx, 2), perimCoords(closeToHullIdx, 1), 'gs');
    
    
%     imtool(label2rgb(outdentRegions, @jet, 'k'));
end

