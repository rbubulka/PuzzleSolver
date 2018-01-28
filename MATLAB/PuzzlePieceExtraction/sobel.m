function [hor, ver, sum, mag, rawDir, zeroDir] = sobel(grayImg, threshold)
    hor = filter2([-1/8, 0, 1/8; -1/4, 0, 1/4; -1/8, 0, 1/8], grayImg);
    ver = filter2([-1/8, -1/4, -1/8; 0, 0, 0; 1/8, 1/4, 1/8], grayImg);
    sum = hor + ver;
    mag = sqrt(hor .^2 + ver .^ 2);
    rawDir = atan2(ver,hor);
    zeroDir = mag;
    zeroDir(find(mag < threshold)) = 0;
 return
end

