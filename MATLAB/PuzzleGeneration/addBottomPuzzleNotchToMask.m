
function newMask = addBottomPuzzleNotchToMask(mask,rStart,rEnd,cStart,cEnd, rowMult,colMult)
%Creates a notch on the bottom of the puzzle mask

%Notch in or out?
notchDirection = mod(randi(100),2);

%Ensures sane size of notch
cDist = cEnd-cStart;
rDist = rEnd-rStart;
minimalLen = min(cDist,rDist);
radiusMax = floor(minimalLen/5);
radiusMin = floor(minimalLen/7);

%Radius of circle
radius = randi([radiusMin,radiusMax]);

%Offset from edge of puzzle piece -- Creates a better look and adds more
%randomness
offset = randi([4,floor(radius/3)]);




%Calculate where the center of the circle needs to be
centerX = colMult*cDist - floor(cDist/2);
if notchDirection
    centerY = rowMult*rDist+offset-2+radius;
    connectionY = centerY - radius + 2 - floor(offset/2);
else
    centerY = rowMult*rDist-offset+2-radius;
    connectionY = centerY + radius - 2 + floor(offset/2);
end


%creates a math 'mesh' where each entry is the number of it's row or col in
%the original mask
[xgrid, ygrid] = meshgrid(1:size(mask,2), 1:size(mask,1));

%Computes truth value of equation in mask
circleMask = ((xgrid-centerX).^2 + (ygrid-centerY).^2) <= radius.^2;

rS = centerX - offset;
rE = centerX + offset;
cS = connectionY - offset;
cE = connectionY + offset;

connectionMask = (((xgrid-centerX).^2 - (ygrid-connectionY).^2) <= 40) & ...
    (rS <= xgrid) & (xgrid <= rE) & (cS <= ygrid) &(ygrid <= cE + 3) ;

%Puts the circle on the mask
mask(circleMask) = notchDirection;
mask(connectionMask) = notchDirection;


newMask = mask;