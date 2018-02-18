function[] = returnPieceComparison(outdentPiece,indentPiece,dir)
% direction: 1=up 2=left 3=down 4=right; corresponds to which edge of the 
% outdent piece we are matching along.  
    % Resize images piece masks if different sizes

    outdentBox = regionprops(outdentPiece,'BoundingBox');
    indentBox = regionprops(indentPiece,'BoundingBox');
    b1w = outdentBox.BoundingBox(3);
    b1h = outdentBox.BoundingBox(4);
    b2w = indentBox.BoundingBox(3);
    b2h = indentBox.BoundingBox(4);
    row=0;
    col=0;
    dh=abs(floor((b1h-b2h)/2));
    dw=abs(floor((b1w-b2w)/2));
    computespace = zeros(max(b1h,b2h),max(b1w,b2w));
    computespace1 = zeros(max(b1h,b2h),max(b1w,b2w));
    size(computespace);
    for i=1:b1w
        if b1w < b2w
            col = i+dw;
        else
            col = i;
        end

        for j=1:b1h
            if b1h < b2h
                row = j+dh;
            else
                row = j;
            end
            computespace(row,col)=outdentPiece(j+outdentBox.BoundingBox(2)-.5,i+outdentBox.BoundingBox(1)-.5);
        end 
    end 
    %     imtool(computespace)
    for i=1:b2w
        if b1w > b2w
            col = i+dw;
        else
            col = i;
        end
        for j=1:b2h
            if b1h > b2h
                row = j+dh;
            else 
                row = j;
            end
            val=indentPiece(j-1+indentBox.BoundingBox(2)-.5,i+indentBox.BoundingBox(1)-.5);
            computespace1(row,col)=val;
        end 
    end 
    if dir == 1 || dir == 3
        computespace1 = flip(computespace1);
    else 
        computespace1 = flip(computespace1,2);
    end
    computespace=computespace-computespace1;
    computespace(find(computespace <= 0))=0;
    intermediateMask = computespace;
    if dir == 1 %match along upper edge of the outdent piece
       for i=floor(size(computespace,1)/2):size(computespace,1)
       computespace(i,:)=0;
       end 
    elseif dir == 2 %match along left dege of outdent
       for i=floor(size(computespace,2)/2):size(computespace,2)
       computespace(:,i)=0;
       end
    elseif dir == 3 %bottom edge
         for i=1:floor(size(computespace,1)/2)
            computespace(i,:)=0;
         end
    else %right edfe
       for i=1:floor(size(computespace,2)/2)
       computespace(:,i)=0;
        end
    end

    %    imtool(computespace);
    computespace = double(bwareafilt(imbinarize(computespace),1));
    regionToConsider = computespace;
    standardError = immse(computespace,flip(flip(computespace,1),2));
   
    figure(2);
    subplot(2,2,1);
    imshow(outdentPiece);
    title('Piece with Outdent');

    subplot(2,2,2);
    imshow(indentPiece);
    title('Piece with Indent');

    subplot(2,2,3);
    imshow(intermediateMask);
    title('Difference between Input Pieces');
    
    subplot(2,2,4);
    imshow(regionToConsider);
    mseTitle = sprintf("Indent/Outdent pair with MSE=%0.3f", standardError);
    title(mseTitle);
end