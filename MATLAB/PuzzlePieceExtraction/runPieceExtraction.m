piecesImg = processImage('ImageRecProjectImages/mandala1.jpg');
pieces = bwlabel(piecesImg);

sizeThresh = 100;

count = 0;
for i=1:max(max(pieces))
    idx = find(pieces==i);
    if(size(idx,1) < sizeThresh)
        pieces(idx) = 0;
    else
        count = count + 1;
    end
end
    
count