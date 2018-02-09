function[] = returnPieceComparison(p1,p2)
    box1 = regionprops(p1,'BoundingBox');
    box2 = regionprops(p2,'BoundingBox');
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
            computespace(j,col)=p2(j+box2.BoundingBox(2)-.5,i+box2.BoundingBox(1)-.5);
        end 
    end 
    computespace = flip(computespace,1);
    computespace = flip(computespace,2);
    imtool(computespace)
    for i=1:b1w
        for j=1:b1h
            computespace(j,i)=computespace(j,i)-p1(j+box1.BoundingBox(2)-.5,i+box1.BoundingBox(1)-.5);
        end 
    end 
   imtool(computespace);
   computespace(find(computespace ~= 0))=1;
   imtool(computespace);
    
end