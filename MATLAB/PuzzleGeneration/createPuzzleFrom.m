function puzzleImage = createPuzzleFrom(image, numRows, numCols)
[rows, cols, depth] = size(image);

%create a new larger image for adding the pieces
newRows = floor((numRows + 1)*rows/numRows);
newCols = floor((numCols + 1) * cols/numCols);
puzzleImage = uint8(ones(newRows,newCols,depth));

%Loop Over Pieces
for i = 1:numRows
    for j = 1:numCols
        rowStart = floor((i-1)*rows/numRows) + 1;
        rowEnd = floor(i*rows/numRows);
        colStart = floor((j-1)*cols/numCols) + 1;
        colEnd = floor(j*cols/numCols);
        mask = zeros(rows,cols);
        mask(rowStart:rowEnd, colStart:colEnd) = 1;
        if i < numRows
            mask = addBottomPuzzleNotchToMask(mask,rowStart,rowEnd,colStart,colEnd, i, j);
        end
        if j < numCols
            mask = addRightPuzzleNotchToMask(mask,rowStart,rowEnd,colStart,colEnd, i, j);
        end
        [maskrow,maskcol]  = find(mask == 1);
        
        %trim
        rowOffset = floor((rowEnd - rowStart)*6/20);
        if maskcol > 1
            s = rowStart + rowOffset;
            e = rowEnd - rowOffset;
            buffer = maskcol(1) - floor((rowEnd - rowStart)/2);
            mask(s:e,buffer:colStart) = 1;
        end
        colOffset = floor((colEnd - colStart)*6/20);
        if maskrow > 1
            s = colStart + colOffset;
            e = colEnd - colOffset;
            buffer = maskrow(1) - floor((colEnd - colStart)/2);
            mask(buffer:rowStart,s:e) = 1;
        end
        
        %Remove the piece from the image
        threeDmask = repmat(mask,[1,1,3]);
        pieceImage = uint8(threeDmask .* double(image));
        pieceImage(find(threeDmask == 0)) = 255;
        image(find(threeDmask==1)) = 255;
        
        %imtool(pieceImage)
        %props = regionprops3(threeDmask, "SubarrayIdx");
        %disp(props);
        %newPieceImage = threeDmasks(props);
        %newPieceImage = newPieceImage + pieceImage(min(pieceRows):max(pieceRows), min(pieceCols):max(pieceCols));
        imtool(pieceImage);
    end
end


