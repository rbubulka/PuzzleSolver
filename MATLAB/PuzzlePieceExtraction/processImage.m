function [output, pieceCount] = processImage(fileName)
    fileName
    img = imread(fileName);
    grayImg = rgb2gray(img);
    
    threshold = 3;
    [hor, ver, sum, mag, rawDir, zeroDir] = sobel(grayImg, threshold);
    
%     imtool(grayImg);
%     boundedPieces = uint8((zeroDir + pi) / (2 * pi) * 255);
%     imtool(boundedPieces);
%     pieceMask = zeros(size(boundedPieces,1), size(boundedPieces,2));
%     find(boundedPieces==0)
%     pieceMask(find(boundedPieces > 0)) = 1;
%     imtool(pieceMask)
     noiseRemoved = imopen(zeroDir, strel('square',3));
%     imtool(noiseRemoved)
    
    pieceImg = noiseRemoved;
%     iter=100;
%     for i=1:iter
%         pieceImg = imclose(pieceImg, strel('square',3));
%     end

    pieceImg = imfill(pieceImg);
    
    imtool(pieceImg);
    output = pieceImg;
    
    pieces = bwlabel(pieceImg);

    sizeThresh = 300;

    count = 0;
    for i=1:max(max(pieces))
        idx = find(pieces==i);
        if(size(idx,1) < sizeThresh)
            pieces(idx) = 0;
        else
            count = count + 1;
        end
    end
    
    pieceCount = count
end

