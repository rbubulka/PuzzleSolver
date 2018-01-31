fileName = 'ImageRecProjectImages/randomPuzzlePiece.png';
[piecesLabeled, pieceCount] = processImage(fileName);

for i = 1:max(max(piecesLabeled))
    if(size(find(piecesLabeled == i),1) > 0)
        singlePieceMask = piecesLabeled;
        
        singlePieceMask = zeros(size(piecesLabeled,1),size(piecesLabeled,2));
        singlePieceMask(find(piecesLabeled == i)) = 1;
        
        angle = fitEllipseToEdges(singlePieceMask);
        imtool(singlePieceMask);
        imtool(imrotate(singlePieceMask, angle));
        
    end
end
    