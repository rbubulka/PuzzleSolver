function [output] = processDirectory(dirName)
    totalPieceCount = 0;
    origDirInfo = dir(dirName);
    numDirs = length(origDirInfo);
    output = cell(numDirs - 2,1);
    
    % Start at 3 to avoid . and ..
    for i=3:numDirs
        if(origDirInfo(i).isdir == 1)
            recursivePieces = processDirectory(strcat(dirName, '/', origDirInfo(i).name));
            output = [output; recursivePieces];
        else
            [pieces, currCount] = processImage(strcat(dirName, '/', origDirInfo(i).name));
            totalPieceCount = totalPieceCount + currCount;
            output{i-2} = pieces;
        end
    end
end

