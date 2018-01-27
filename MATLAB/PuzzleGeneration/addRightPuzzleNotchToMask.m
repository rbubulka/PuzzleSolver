
function newMask = addRightPuzzleNotchToMask(mask,rStart,rEnd,cStart,cEnd, rowMult,colMult)
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
centerY = rowMult*rDist+ - floor(rDist/2);
if notchDirection
    centerX = colMult*cDist+offset-2+radius;
    connectionX = centerX - radius + 2 - floor(offset/2);
else
    centerX = colMult*cDist-offset+2-radius;
    connectionX = centerX + radius - 2 + floor(offset/2);
end


%creates a math 'mesh' where each entry is the number of it's row or col in
%the original mask
[xgrid, ygrid] = meshgrid(1:size(mask,2), 1:size(mask,1));

%Computes truth value of equation in mask
circleMask = ((xgrid-centerX).^2 + (ygrid-centerY).^2) <= radius.^2;

rS = connectionX - offset;
rE = connectionX + offset;
cS = centerY - offset;
cE = centerY + offset;

connectionMask = (((ygrid-centerY).^2)-(xgrid-connectionX).^2  <= 40) & ...
    (rS <= xgrid) & (xgrid <= rE+3) & (cS <= ygrid) &(ygrid <= cE) ;

%Puts the circle on the mask
mask(circleMask) = notchDirection;
mask(connectionMask) = notchDirection;


newMask = mask;