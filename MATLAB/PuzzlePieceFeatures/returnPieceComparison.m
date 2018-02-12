function[] = returnPieceComparison(outdentPiece,indentPiece)
    box1 = regionprops(outdentPiece,'BoundingBox');
    box2 = regionprops(indentPiece,'BoundingBox');
    b1w = box1.BoundingBox(3);
    b1h = box1.BoundingBox(4);
    b2w = box2.BoundingBox(3);
    b2h = box2.BoundingBox(4);
    dh=int8((b1h-b2h)/2);
    dw=floor((b1w-b2w)/2);
    computespace = zeros(max(b1h,b2h),max(b1w,b2w));
    size(computespace)
    for i=1:b2w
        for j=1:b2h
            col = uint8(i+dw);
            computespace(j,col)=indentPiece(j+box2.BoundingBox(2)-.5,i+box2.BoundingBox(1)-.5);
        end 
    end 
    computespace = flip(computespace,1);
    computespace = flip(computespace,2);
    imtool(computespace)
    for i=1:b1w
        for j=1:b1h
            computespace(j,i)=computespace(j,i)-outdentPiece(j+box1.BoundingBox(2)-.5,i+box1.BoundingBox(1)-.5);
        end 
    end 
   computespace(find(computespace <= 0))=0;
   imtool(computespace);
   immse(computespace,flip(computespace,1))
    
end