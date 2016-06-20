function image = objectRemoving(energyOffset, image)
% apply object removing to the image
    energyOffsetVertical = energyOffset;
    [imageDeleteVerticalSeam, sizeReduction, energyOffsetVertical] = deleteObjectSeams(energyOffsetVertical, image, 1);
    imageDeleteVerticalSeam = addSeams(sizeReduction, energyOffsetVertical, imageDeleteVerticalSeam, 1);
    energyOffsetHorizontal = energyOffset;
    [imageDeleteHorizontalSeam, sizeReduction, energyOffsetHorizontal] = deleteObjectSeams(energyOffsetHorizontal, image, 0);
    imageDeleteHorizontalSeam = addSeams(sizeReduction, energyOffsetHorizontal, imageDeleteHorizontalSeam, 0);
    
    energyImage = energyRGB( image);
    energyDeleteVerticalSeam = energyRGB(imageDeleteVerticalSeam);
    energyDeleteHorizontalSeam = energyRGB(imageDeleteHorizontalSeam);
    %ResidualImgDeleteVerticalSeam = calculateResidualImg( image, imageDeleteVerticalSeam );
    ResidualImgDeleteVerticalSeam = calculateResidualImg( energyImage, energyDeleteVerticalSeam, energyOffset );
    %ResidualImgDeleteHorizontalSeam = calculateResidualImg( image, imageDeleteHorizontalSeam );
    ResidualImgDeleteHorizontalSeam = calculateResidualImg( energyImage, energyDeleteHorizontalSeam, energyOffset );
    
    ResidualImgDeleteVerticalSeamSum = sum(sum(sum(ResidualImgDeleteVerticalSeam)));
    ResidualImgDeleteHorizontalSeamSum = sum(sum(sum(ResidualImgDeleteHorizontalSeam)));
%     figure;
%     subplot(1, 2, 1);
%     imshow(imageDeleteVerticalSeam);
%     subplot(1, 2, 2);
%     imshow(imageDeleteHorizontalSeam);
%     if energyDeleteVerticalSeam > energyDeleteHorizontalSeam
%         image = imageDeleteVerticalSeam;
%     else
%         image = imageDeleteHorizontalSeam;
%     end
%    imwrite(imageDeleteVerticalSeam, 'remove_by_vertical.png');
%    imwrite(imageDeleteHorizontalSeam, 'remove_by_horizental.png');
%imwrite( ResidualImgDeleteVerticalSeam, 'residual_energy_vertical.png');
%imwrite( ResidualImgDeleteHorizontalSeam, 'residual_energy_horizental.png');
%    fprintf('ResidualImgDeleteVerticalSeamSum = %f\n', ResidualImgDeleteVerticalSeamSum);
%    fprintf('ResidualImgDeleteHorizontalSeamSum = %f\n', ResidualImgDeleteHorizontalSeamSum);
    
    a = psnr( imageDeleteVerticalSeam, image);
    b = psnr( imageDeleteHorizontalSeam, image);
%    fprintf('PSNR of vertical: %f\n', a);
%    fprintf('PSNR of horizontal: %f\n', b);
    if a > b
        image = imageDeleteVerticalSeam;
    else
        image = imageDeleteHorizontalSeam;
    end
%{        
    if ResidualImgDeleteVerticalSeamSum < ResidualImgDeleteHorizontalSeamSum
        image = imageDeleteVerticalSeam;
    else
        image = imageDeleteHorizontalSeam;
    end
%}    
end

function [image, sizeReduction, energyOffset] = deleteObjectSeams(energyOffset, image, isVertical)
% delete seams following optimal way
    sizeReduction = 0;
    while sum(find(energyOffset < 0)) ~= 0
        energy = energyRGB(image);
        energy = energy + energyOffset;
        if isVertical == 0
            [optSeamMask, seamEnergyRaw] = findOptSeam(energy');
            image = reduceImageByMask(image, optSeamMask, 0);
            energyOffset = reduceOffsetByMask(energyOffset, optSeamMask, 0);
        else
            [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
            image = reduceImageByMask(image, optSeamMask, 1);
            energyOffset = reduceOffsetByMask(energyOffset, optSeamMask, 1);
        end
        sizeReduction = sizeReduction + 1;        
        imshow(image);
        drawnow;
    end;    
end

function image = addSeams(sizeReduction, energyOffset, image, isVertical)
% add seams following optimal way(computed by DP)

    for it = 1 : sizeReduction        
        energy = energyRGB(image);
		energy = energy + energyOffset;
        if isVertical == 0
            [optSeamMask, seamEnergyRaw] = findOptSeam(energy');
            image = enlargeImageByMask(image, optSeamMask, 0);
            energyOffset = enlargeOffsetByMask(energyOffset, optSeamMask, 0);
        else
            [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
            image = enlargeImageByMask(image, optSeamMask, 1);
            energyOffset = enlargeOffsetByMask(energyOffset, optSeamMask, 1);
        end        
        imshow(image);
        drawnow;
    end;
end

function imageReduced = reduceImageByMask( image, seamMask, isVerical )
% removes pixels by input mask
% removes vertical line if isVerical == 1, otherwise horizontal
    if (isVerical)
        imageReduced = reduceImageByMaskVertical(image, seamMask);
    else
        imageReduced = reduceImageByMaskHorizontal(image, seamMask');
    end;
end

% could not find a more elegant way to do it
function imageReduced = reduceImageByMaskVertical(image, seamMask)
    imageReduced = zeros(size(image, 1), size(image, 2) - 1, size(image, 3));
    for i = 1 : size(seamMask, 1)
        imageReduced(i, :, 1) = image(i, seamMask(i, :), 1);
        imageReduced(i, :, 2) = image(i, seamMask(i, :), 2);
        imageReduced(i, :, 3) = image(i, seamMask(i, :), 3);
    end
end

function imageReduced = reduceImageByMaskHorizontal(image, seamMask)
    imageReduced = zeros(size(image, 1) - 1, size(image, 2), size(image, 3));
    for j = 1 : size(seamMask, 2)
        imageReduced(:, j, 1) = image(seamMask(:, j), j, 1);
        imageReduced(:, j, 2) = image(seamMask(:, j), j, 2);
        imageReduced(:, j, 3) = image(seamMask(:, j), j, 3);
    end
end
