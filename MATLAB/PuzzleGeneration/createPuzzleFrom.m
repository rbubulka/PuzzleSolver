function puzzleImage = createPuzzleFrom(image, numRows, numCols)
%Append 20xRows and Columns to  be able to separate the pieces
[rows, cols, depth] = size(image);
puzzleImage = uint8(zeros(rows+numRows*20,cols+numCols*20,depth));

%Random Number
x = mod(randi(100),2);

%Loop Over Pieces
for i = 1:(numRows-1)
    for j = 1:(numCols-1)
        rowStart = floor((i-1)*rows/numRows) + 1;
        rowEnd = floor(i*rows/numRows);
        colStart = floor((j-1)*cols/numCols) + 1;
        colEnd = floor(j*cols/numCols);
        mask = zeros(rows,cols);
        mask(rowStart:rowEnd, colStart:colEnd) = 1;
        mask = addBottomPuzzleNotchToMask(mask,rowStart,rowEnd,colStart,colEnd, i, j);
        mask = addRightPuzzleNotchToMask(mask,rowStart,rowEnd,colStart,colEnd, i, j);
        maskPerimeter = bwperim(mask,8);
        
        threeDperimeter = repmat(maskPerimeter,[1,1,3]);
        threeDmask = repmat(mask,[1,1,3]);
        
        
        pieceImage = uint8(threeDmask .* double(image));
        pieceImage(find(threeDmask == 0)) = 255;
        pieceImage(threeDperimeter) = 0;
        imtool(pieceImage)
    end
end


