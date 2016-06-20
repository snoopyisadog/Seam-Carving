function imageEnlarged = enlargeImageByMask(image, seamMask, isVerical)
% removes pixels by input mask
% removes vertical line if isVerical == 1, otherwise horizontal
    if (isVerical)
        imageEnlarged = enlargeImageByMaskVertical(image, seamMask);
    else
        imageEnlarged = enlargeImageByMaskHorizontal(image, seamMask');
    end;
end

function imageEnlarged = enlargeImageByMaskVertical(image, seamMask)

    avg = @(image, i, j, k) (image(i, max(1,j-1), k) + image(i, min(end,j+1), k))/2;

    imageEnlarged = zeros(size(image, 1), size(image, 2) + 1, size(image, 3));
    for i = 1 : size(seamMask, 1)
        j = find(seamMask(i, :) ~= 1);
        imageEnlarged(i, :, 1) = [image(i, 1:j, 1), avg(image, i, j, 1), image(i, j+1:end, 1)];
        imageEnlarged(i, :, 2) = [image(i, 1:j, 2), avg(image, i, j, 2), image(i, j+1:end, 2)];
        imageEnlarged(i, :, 3) = [image(i, 1:j, 3), avg(image, i, j, 3), image(i, j+1:end, 3)];
    end;
end

function imageEnlarged = enlargeImageByMaskHorizontal(image, seamMask)

    avg = @(image, i, j, k) ( image(max(1,i-1), j, k) + image(min(i+1,end), j, k) )/2;

    imageEnlarged = zeros(size(image, 1) + 1, size(image, 2), size(image, 3));
    for j = 1 : size(seamMask, 2)
        i = find(seamMask(:, j) ~= 1);
        imageEnlarged(:, j, 1) = [image(1:i, j, 1); avg(image, i, j, 1); image(i+1:end, j, 1)];
        imageEnlarged(:, j, 2) = [image(1:i, j, 2); avg(image, i, j, 2); image(i+1:end, j, 2)];
        imageEnlarged(:, j, 3) = [image(1:i, j, 3); avg(image, i, j, 3); image(i+1:end, j, 3)];
    end;
end