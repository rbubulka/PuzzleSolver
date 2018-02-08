function [outdentRegions] = findOutdents(singlePieceMask, perimCoords, curvedIdx, closeToHullIdx)
    wrapIndex = @(a, n) (mod(a-1, n) + 1);
    
    % Find outdents by considering points between inflection points
    numInflPts = size(curvedIdx, 1);
    
    numPerimPts = size(perimCoords, 1);
    
    allOutdentEndingPts = [];
    neighborDistance = 2;
    outdentRegions = zeros(size(singlePieceMask, 1), size(singlePieceMask, 2));
    for j = 1:numInflPts
        % Speculatively search for a point that is close to convex hull in
        % next few points
        startInflPtIdx = curvedIdx(j);
        firstOutdentPtIdx = -1;
        for k = startInflPtIdx : startInflPtIdx + neighborDistance
            idxToCheck = wrapIndex(k, numPerimPts);
            matchingHullIdx = find(closeToHullIdx == idxToCheck);
            if(size(matchingHullIdx, 1) > 0)
                firstOutdentPtIdx = closeToHullIdx(matchingHullIdx);
                break;
            end
        end
        
        % If we didn't find a point close to convex hull, try next 
        % inflection point
        if(firstOutdentPtIdx == -1)
            continue
        end
        
        % Check neighbors to ensure this is not middle of an outdent
        isMidOutdent = 1;
        for k = startInflPtIdx - neighborDistance : startInflPtIdx + neighborDistance
            idxToCheck = wrapIndex(k, numPerimPts);
            matchingHullIdx = find(closeToHullIdx == idxToCheck);
            if(size(matchingHullIdx, 1) == 0)
                isMidOutdent = -1;
                break;
            end
        end
        
        if(isMidOutdent == 1)
            continue
        end
        
        
        
        % Follow current segment of points (all close to convex hull)
        % until it ends
        finalInflPtIdx = -1;

        allOutdentPtIdx = [];
        lastOutdentPtIdx = -1;
        nextOutdentPtIdx = firstOutdentPtIdx;
        while size(find(closeToHullIdx == nextOutdentPtIdx), 1) > 0
            allOutdentPtIdx = [allOutdentPtIdx; nextOutdentPtIdx];
            
            % Find inflection points along the way
            inflPt = find(curvedIdx == nextOutdentPtIdx);
            if(size(inflPt,1) > 0)
                finalInflPtIdx = curvedIdx(inflPt);
            end
            
            lastOutdentPtIdx = nextOutdentPtIdx;
            nextOutdentPtIdx = wrapIndex(nextOutdentPtIdx + 1, numPerimPts);
        end
        
        % Check next few points for an inflection point to mark the "end"
        % of the outdent. If one isn't found, use last one encountered in
        % set of outdent points
        potentialInflPtIdx = -1;
        for k = nextOutdentPtIdx : nextOutdentPtIdx + neighborDistance
            idxToCheck = wrapIndex(k, numPerimPts);
            matchingInflPtIdx = find(curvedIdx == idxToCheck);
            if(size(matchingHullIdx, 1) > 0)
                potentialInflPtIdx = curvedIdx(matchingInflPtIdx);
            end
        end
        
        if(potentialInflPtIdx ~= -1)
            finalInflPtIdx = potentialInflPtIdx;
        end
        
        minOutdentSizeThreshold = 2;
        % Not bounded by two inflection points or is too small, so not an outdent
        if(finalInflPtIdx == -1 | size(find(allOutdentEndingPts == finalInflPtIdx), 1) > 0 ...
            | size(allOutdentPtIdx,1) <= minOutdentSizeThreshold)
            continue;
        end
        
        % Eliminate any potential outdents whose perimeter changes direction
        % immediately after the outdent relative to the perimeter before the
        % outdent (eliminates regions near outdents)        
        outdentStartX = perimCoords(firstOutdentPtIdx, 1);
        outdentStartY = perimCoords(firstOutdentPtIdx, 2);

        middleIdx = round(size(allOutdentPtIdx,1) / 2);
        middleOutdentIdx = allOutdentPtIdx(middleIdx);
        middleOutdentX = perimCoords(middleOutdentIdx, 1);
        middleOutdentY = perimCoords(middleOutdentIdx, 2);
        
        outdentEndX = perimCoords(lastOutdentPtIdx, 1);
        outdentEndY = perimCoords(lastOutdentPtIdx, 2);
        
        startVectorX = middleOutdentX - outdentStartX;
        startVectorY = middleOutdentY - outdentStartY;
        startVectorAngle = atan2(startVectorY, startVectorX);
        
        endVectorX = outdentEndX - middleOutdentX;
        endVectorY = outdentEndY - middleOutdentY;
        endVectorAngle = atan2(endVectorY, endVectorX);
        
        angleChange = radtodeg(endVectorAngle - startVectorAngle);
        if(angleChange > 180)
           angleChange = 360 - angleChange; 
        elseif (angleChange < -180)
           angleChange = 360 + angleChange;
        end
        
%         plot(perimCoords(beforeOutdentStartIdx, 2), perimCoords(beforeOutdentStartIdx, 1), 'ro');
        plot(perimCoords(startInflPtIdx, 2), perimCoords(startInflPtIdx, 1), 'ro');
         plot(middleOutdentY, middleOutdentX, 'rd');
        plot(perimCoords(finalInflPtIdx, 2), perimCoords(finalInflPtIdx, 1), 'rs');
%         plot(perimCoords(afterOutdentEndIdx, 2), perimCoords(afterOutdentEndIdx, 1), 'rs');
        
        angleChange
        maxAngleChangeOverOutdent = 80;
        minAngleChangeOverOutdent = 40;
        if(abs(angleChange) > minAngleChangeOverOutdent & abs(angleChange) < maxAngleChangeOverOutdent)
            plot(perimCoords(allOutdentPtIdx, 2), perimCoords(allOutdentPtIdx, 1), 'bd');
        end
        
        idx = sub2ind(size(singlePieceMask), perimCoords(allOutdentPtIdx, 1), perimCoords(allOutdentPtIdx, 2));
        outdentRegions(idx) = j;
    end
end

