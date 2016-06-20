function res = contentAmplify( I, scale )
    [hei,wid,~] = size(I);
    res = imresize(I, scale);
    [x, y, ~] = size(res);
    res = seamCarving( [hei, wid], zeros(x, y), res);
end

