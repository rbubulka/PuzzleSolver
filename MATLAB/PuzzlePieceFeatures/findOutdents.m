function [outdentRegions] = findOutdents(singlePieceMask, perimCoords, curvedIdx, closeToHullIdx)
    wrapIndex = @(a, n) (mod(a-1, n) + 1);
    
    % Find outdents by considering points between inflection points
    numInflPts = size(curvedIdx, 1);
    
    numPerimPts = size(perimCoords, 1);
    
    allOutdentEndingPts = [];
    neighborDistance = 2;
    outdentRegions = zeros(size(singlePieceMask, 1), size(singlePieceMask, 2));
    numOutdentsFound = 0;
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
        
        numOutdents = size(allOutdentPtIdx,1);
        minOutdentSizeThreshold = 2;
        % Not bounded by two inflection points or is too small, so not an outdent
        if(finalInflPtIdx == -1 | numOutdents <= minOutdentSizeThreshold)
            continue;
        end
        
        % Ensure part of an old segment is not reconsidered unless this 
        % one is better
        [r, c] = find(allOutdentEndingPts == finalInflPtIdx);
        if(size(r,1) > 0 & allOutdentEndingPts(r, 2) >= numOutdents)
            continue;
        end
        
        % Eliminate any potential outdents that don't undergo frequent changes in direction
        minAngleChange = 20;
        noChangeCount = 0;
        stepSize = 2;
        angleChanges = [];
        for i=1:stepSize:numOutdents
            firstIdx = wrapIndex(allOutdentPtIdx(i) - 6, numPerimPts);
            firstPt = perimCoords(firstIdx, :);
            
            middlePt = perimCoords(allOutdentPtIdx(i), :);
            
            lastIdx = wrapIndex(allOutdentPtIdx(i) + 6, numPerimPts);
            lastPt = perimCoords(lastIdx, :);
            
            angleChange = computeChangeInVectorDirection(firstPt, middlePt, lastPt);
            angleChanges = [angleChanges; angleChange];
            if(abs(angleChange) < minAngleChange)
                noChangeCount = noChangeCount + 1;
            end
        end
        
        if(noChangeCount < 3)
            plot(perimCoords(startInflPtIdx, 2), perimCoords(startInflPtIdx, 1), 'ro');
            plot(perimCoords(finalInflPtIdx, 2), perimCoords(finalInflPtIdx, 1), 'rs');
            plot(perimCoords(allOutdentPtIdx, 2), perimCoords(allOutdentPtIdx, 1), 'bd');
            
            allOutdentEndingPts = [allOutdentEndingPts; finalInflPtIdx, numOutdents];
            idx = sub2ind(size(singlePieceMask), perimCoords(allOutdentPtIdx, 1), perimCoords(allOutdentPtIdx, 2));
            numOutdentsFound = numOutdentsFound + 1;
            outdentRegions(idx) = numOutdentsFound;
        end
    end
end

