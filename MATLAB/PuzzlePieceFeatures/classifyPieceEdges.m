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
    
%     imshow(singlePieceMask);
%     hold on;
    
    
    indentRegions = findIndents(singlePieceMask, perimCoords, curvedIdx, farFromHullIdx);
    outdentRegions = findOutdents(singlePieceMask, perimCoords, curvedIdx, closeToHullIdx);

    % Grab center of each indent
    numIndents = max(max(indentRegions));
    indentCenters = zeros(numIndents, 2);
    for i=1:numIndents
        [rows, cols] = find(indentRegions == i);
        rowMean = mean(rows);
        colMean = mean(cols);
        currCenter = [rowMean, colMean];
        indentCenters(i,:) = currCenter;
    end 
    
    % Grab center of each outdent
    numOutdents = max(max(outdentRegions));
    outdentCenters = zeros(numOutdents, 2);
    for i=1:numOutdents
        [rows, cols] = find(outdentRegions == i);
        rowMean = mean(rows);
        colMean = mean(cols);
        currCenter = [rowMean, colMean];
        outdentCenters(i,:) = currCenter;
        
        sameCoordinateThreshold = 4;
        % Check if there is a nearby center for indents
        xAndYDifferences = indentCenters - currCenter;
        [sameXCoordinateRow, c] = find(abs(xAndYDifferences(:,1)) < sameCoordinateThreshold);
        
        % If multiple points on same line, determine which point is closer
        % to piece's center --> likely the actual indent/outdent
        if(size(sameXCoordinateRow, 1) > 0)
            indentX = indentCenters(sameXCoordinateRow, 1);
            indentY = indentCenters(sameXCoordinateRow, 2);
            indentToCenter = sqrt((indentX - pieceCenter(1)) .^2 + (indentY - pieceCenter(2)) .^2);
            outdentToCenter = sqrt((currCenter(1) - pieceCenter(1)) .^2 + (currCenter(2) - pieceCenter(2)) .^2);

            if(indentToCenter < outdentToCenter)
                outdentCenters(i,:) = -1;
                outdentRegions(find(outdentRegions == i)) = 0;
            else
                indentToCenter(sameXCoordinate, :) = -1;
                indentRegions(find(indentRegions == sameXCoordinate)) = 0;
            end
        end
            
        [sameYCoordinateRow, c] = find(abs(xAndYDifferences(:,2)) < sameCoordinateThreshold);
        % If multiple points on same line, determine which point is closer
        % to piece's center --> likely the actual indent/outdent
        if(size(sameYCoordinateRow, 1) > 0)
            indentX = indentCenters(sameYCoordinateRow, 1);
            indentY = indentCenters(sameYCoordinateRow, 2);
            indentToCenter = sqrt((indentX - pieceCenter(1)) .^2 + (indentY - pieceCenter(2)) .^2);
            outdentToCenter = sqrt((currCenter(1) - pieceCenter(1)) .^2 + (currCenter(2) - pieceCenter(2)) .^2);

            if(indentToCenter < outdentToCenter)
                outdentCenters(i,:) = -1;
                outdentRegions(find(outdentRegions == i)) = 0;
            else
                indentToCenter(sameXCoordinate, :) = -1;
                indentRegions(find(indentRegions == sameYCoordinate)) = 0;
            end
        end
    end
 
    numIndents = size(unique(indentRegions),1) - 1;
    displayIndentRegions = indentRegions;
    nonIndentIdx = find(indentRegions == 0 & singlePieceMask == 1);
    firstColorIdx = find(indentRegions == 1);
    displayIndentRegions(nonIndentIdx) = 1;
    displayIndentRegions(firstColorIdx) = numIndents+1;
    displayIndentRegions = label2rgb(displayIndentRegions, @jet, 'k');
    
    numOutdents = size(unique(outdentRegions),1) - 1;    
    displayOutdentRegions = outdentRegions;
    nonOutdentIdx = find(outdentRegions == 0 & singlePieceMask == 1);
    firstColorIdx = find(outdentRegions == 1);
    displayOutdentRegions(nonOutdentIdx) = 1;
    displayOutdentRegions(firstColorIdx) = numOutdents+1;
    displayOutdentRegions = label2rgb(displayOutdentRegions, @jet, 'k');
    
    figure(1);
    subplot(1,3,1);
    imshow(singlePieceMask);
    title('Original Piece');
    
    subplot(1,3,2);
    imshow(displayIndentRegions);
    indentTitle = sprintf("Detected %d Indents", numIndents);
    title(indentTitle);

    subplot(1,3,3);
    imshow(displayOutdentRegions);
    outdentTitle = sprintf("Detected %d Outdents", numOutdents);
    title(outdentTitle);

end

