function [indentRegions] = findIndents(singlePieceMask, perimCoords, curvedIdx, farFromHullIdx)
    wrapIndex = @(a, n) (mod(a-1, n) + 1);
    
    % Find indents by considering points between inflection points
    numInflPts = size(curvedIdx, 1);
    
    numPerimPts = size(perimCoords, 1);
    
    allIndentEndingPts = [];
    neighborDistance = 4;
    indentRegions = zeros(size(singlePieceMask, 1), size(singlePieceMask, 2));
    for j = 1:numInflPts
        % Speculatively search for a point that is far from convex hull in
        % next few points
        startInflPtIdx = curvedIdx(j);
        firstIndentPtIdx = -1;
        for k = startInflPtIdx : startInflPtIdx + neighborDistance
            idxToCheck = wrapIndex(k, numPerimPts);
            matchingHullIdx = find(farFromHullIdx == idxToCheck);
            if(size(matchingHullIdx, 1) > 0)
                firstIndentPtIdx = farFromHullIdx(matchingHullIdx);
                break;
            end
        end
        
        % If we didn't find a point far from convex hull, try next 
        % inflection point
        if(firstIndentPtIdx == -1)
            continue
        end
        
        % Follow current segment of points (all far from convex hull)
        % until it ends
        finalInflPtIdx = -1;

        allIndentPtIdx = [];
        lastIndentPtIdx = -1;
        nextIndentPtIdx = firstIndentPtIdx;
        while size(find(farFromHullIdx == nextIndentPtIdx), 1) > 0
            allIndentPtIdx = [allIndentPtIdx; nextIndentPtIdx];
            
            % Find inflection points along the way
            inflPt = find(curvedIdx == nextIndentPtIdx);
            if(size(inflPt,1) > 0)
                finalInflPtIdx = curvedIdx(inflPt);
            end
            
            lastIndentPtIdx = nextIndentPtIdx;
            nextIndentPtIdx = wrapIndex(nextIndentPtIdx + 1, numPerimPts);
        end
        
        % Check next few points for an inflection point to mark the "end"
        % of the indent. If one isn't found, use last one encountered in
        % set of indent points
        potentialInflPtIdx = -1;
        for k = nextIndentPtIdx : nextIndentPtIdx + neighborDistance
            idxToCheck = wrapIndex(k, numPerimPts);
            matchingInflPtIdx = find(curvedIdx == idxToCheck);
            if(size(matchingHullIdx, 1) > 0)
                potentialInflPtIdx = curvedIdx(matchingInflPtIdx);
            end
        end
        
        if(potentialInflPtIdx ~= -1)
            finalInflPtIdx = potentialInflPtIdx;
        end
       
        minIndentSizeThreshold = 2;
        % Not bounded by two inflection points or is too small, so not an indent
        if(finalInflPtIdx == -1 | size(find(allIndentEndingPts == finalInflPtIdx), 1) > 0 ...
            | size(allIndentPtIdx,1) <= minIndentSizeThreshold)
            continue;
        end
        
        
        % Store ending point to avoid duplicate work with sub-segments of
        % current indent
        allIndentEndingPts = [allIndentEndingPts; finalInflPtIdx];
        
        % Eliminate any potential indents whose perimeter changes direction
        % immediately after the indent relative to the perimeter before the
        % indent (eliminates regions near outdents)        
        indentStartPt = perimCoords(firstIndentPtIdx, :);

        middleIdx = round(size(allIndentPtIdx,1) / 2);
        middleIndentIdx = allIndentPtIdx(middleIdx);
        middleIndentPt = perimCoords(middleIndentIdx, :);       
        
        indentEndPt = perimCoords(lastIndentPtIdx, :); 
        
        angleChange = computeAngleFrom3Points(indentStartPt, middleIndentPt, indentEndPt);
        
%                 plot(perimCoords(firstIndentPtIdx, 2), perimCoords(firstIndentPtIdx, 1), 'gs');
%         plot(perimCoords(beforeIndentStartIdx, 2), perimCoords(beforeIndentStartIdx, 1), 'ro');
%         plot(perimCoords(startInflPtIdx, 2), perimCoords(startInflPtIdx, 1), 'ro');
%          plot(middleIndentY, middleIndentX, 'rd');
%         plot(perimCoords(finalInflPtIdx, 2), perimCoords(finalInflPtIdx, 1), 'rs');
%         plot(perimCoords(afterIndentEndIdx, 2), perimCoords(afterIndentEndIdx, 1), 'rs');
        
        maxAngleChangeAfterIndent = 40;
        if(abs(angleChange) < maxAngleChangeAfterIndent)
%             plot(perimCoords(allIndentPtIdx, 2), perimCoords(allIndentPtIdx, 1), 'bd');
        end
        
        idx = sub2ind(size(singlePieceMask), perimCoords(allIndentPtIdx, 1), perimCoords(allIndentPtIdx, 2));
        indentRegions(idx) = j;
    end
end

