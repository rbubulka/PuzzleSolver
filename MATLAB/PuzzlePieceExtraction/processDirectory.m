function [] = processDirectory(dirName)
    totalPieceCount = 0;
    origDirInfo = dir(dirName);
    for i=3:length(origDirInfo)
        if(origDirInfo(i).isdir == 1)
            processDirectory(strcat(dirName, '/', origDirInfo(i).name));
        else
            [pieces, currCount] = processImage(strcat(dirName, '/', origDirInfo(i).name));
            totalPieceCount = totalPieceCount + currCount;
        end
    end
    totalPieceCount
end

