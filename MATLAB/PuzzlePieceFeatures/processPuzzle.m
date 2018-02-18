dirName = 'ImageRecProjectImages/report';
setOfImages = processDirectory(dirName);
numImages = length(setOfImages);

pieceMasks = cell(0);
for k = 1:numImages
    piecesLabeled = setOfImages{k};
    numPieces = max(max(piecesLabeled));
    newPieces = cell(0);
    
    for i = 1:numPieces
        if(size(find(piecesLabeled == i),1) > 0)
            singlePieceMask = zeros(size(piecesLabeled,1),size(piecesLabeled,2));
            singlePieceMask(find(piecesLabeled == i)) = 1;

            rotatedPiece = handleRotation(singlePieceMask);
            newPieces = [newPieces; rotatedPiece];
            classifyPieceEdges(rotatedPiece);  
        end
    end
    pieceMasks = [pieceMasks; newPieces];
end

returnPieceComparison(pieceMasks{1}, pieceMasks{2}, 4);
    