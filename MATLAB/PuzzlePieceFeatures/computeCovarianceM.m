function [covarM] = computeCovarianceM(imgMask)
    [r,c] = find(imgMask == 1);
    
    covarM = zeros(2,2);
    cMean=  mean(c);
    rMean = mean(r);
    cNorm = c-cMean;
    rNorm = r-rMean;
    covarM(1,1) = sum(cNorm.^2)/size(cNorm,1);
    covarM(2,2) = sum(rNorm.^2)/size(rNorm,1);
    covarM(1,2) = sum(cNorm.*rNorm)/size(cNorm,1);
    covarM(2,1) = sum(cNorm.*rNorm)/size(cNorm,1);
end

