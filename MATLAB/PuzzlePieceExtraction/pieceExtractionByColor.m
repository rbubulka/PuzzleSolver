img = imread('images/cake1.png');
imtool(img);
colors = zeros(256,256,256);
[r,c,g] = size(img);
gray = rgb2gray(img);
histogram = zeros(128,1);
colorMask = ones(r,c);
for i = 1:r
    for j = 1:c
        colors(img(i,j,1)/3 + 1,img(i,j,2)/3 + 1,img(i,j,3)/3 + 1) = colors(img(i,j,1)/3 + 1,img(i,j,2)/3 + 1,img(i,j,3)/3 + 1) + 1;
        histogram((gray(i,j) + 2)/4 + 1) = histogram((gray(i,j) + 2)/4 + 1) + 1;
    end
end
most_common = (find(histogram == max(histogram)) - 1) * 3;
most_commonColor = find(colors == max(max(max(colors))));
most_commonR = ceil(most_commonColor/(256^2)*3 - 1);
mccM = mod(most_commonColor, 256^2);
most_commonG = ceil(mccM/(256)*3 - 1);
most_commonB = mod(mccM, 256)*3 - 1;
%img(find(img(:,:) == most_commonR && img(:,:,2) == most_commonG && img(:,:,3) == most_commonB)) = 0;
%gray(find(gray > most_common - 6 & gray < most_common + 6)) = 0;
colorMask(find(img(:,:,1) > most_commonR - 4 & img(:,:,1) < most_commonR + 4)) = 0; 
colorMask(find(img(:,:,2) > most_commonG - 4 & img(:,:,2) < most_commonG + 4)) = 0; 
colorMask(find(img(:,:,3) > most_commonB - 4 & img(:,:,3) < most_commonB + 4)) = 0;
img(find(img(:,:,1) > most_commonR - 4 & img(:,:,1) < most_commonR + 4)) = 0; 
img(find(img(:,:,2) > most_commonG - 4 & img(:,:,2) < most_commonG + 4) + r*c) = 0; 
img(find(img(:,:,3) > most_commonB - 4 & img(:,:,3) < most_commonB + 4) + 2*r*c) = 0; 
imtool(colorMask);

d1 = strel('disk',1);
sm_erode = imerode(colorMask, d1);
cc = bwlabel(sm_erode, 4);
group_num = max(max(cc));
threshold = 20;
for i = 1:group_num
    s = size(find(cc == i));
    if s(1,1) < threshold
        cc(find(cc == i)) = 0;
    end
end
ccImg = label2rgb(cc, @jet, 'k');
imtool(ccImg);