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
    [r,c] = size(zeroDir);
    zeroDir(1:10,:) = 0;
    zeroDir(r-9:r,:) = 0;
    zeroDir(:,1:10) = 0;
    zeroDir(:,c-9:c) = 0;
     %noiseRemoved = imopen(zeroDir, strel('square',3));
%     imtool(noiseRemoved)
    
   % pieceImg = noiseRemoved;
%     iter=100;
%     for i=1:iter
%         pieceImg = imclose(pieceImg, strel('square',3));
%     end

    pieceImg = imfill(zeroDir);
    
    cc = bwlabel(pieceImg, 4);
    group_num = max(max(cc));
    max_size = 1;
    count = 0;
    for i = 1:group_num
        s = size(find(cc == i));
        if s(1,1) > max_size
            max_size = s(1,1);
        end
    end
    for i = 1:group_num
        s = size(find(cc == i));
        if s(1,1) * 10 < max_size
            cc(find(cc == i)) = 0;
        else
            count = count + 1;
        end
    end

    output = label2rgb(cc, @jet, 'k');
    imtool(output);
    
    pieceCount = count
end

