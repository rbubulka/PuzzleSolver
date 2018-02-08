function [angle] = computeAngleFrom3Points(p1, p2, p3)
    vec1 = (p2 - p1) / norm(p2 - p1);
    vec2 = (p2 - p3) / norm(p3 - p2);
    
    angle = rad2deg(atan2(norm(det([vec1; vec2])), dot(vec1, vec2)));
end

