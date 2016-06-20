% (C) Copyright Kirill Lykov 2013.
%
% Distributed under the FreeBSD Software License (See accompanying file license.txt)

function image = seamCarving(newSize, remainOffset, image)
% apply seam carving to the image
% following paper by Avidan and Shamir '07
    sizeReductionX = size(image, 1) - newSize(1);
    sizeReductionY = size(image, 2) - newSize(2);
    fprintf('Reduction, X: %d, Y: %d\n', sizeReductionX, sizeReductionY);
    mmax = @(left, right) max([left right]);
    
    [image, remainOffset] = seamCarvingReduce([mmax(0, sizeReductionX), mmax(0, sizeReductionY)], remainOffset, image);
    %maybe reduce or enlarge, so use max to bound
    [image, remainOffset] = seamCarvingEnlarge([mmax(0, -sizeReductionX), mmax(0, -sizeReductionY)], remainOffset, image);
end

function [image, remainOffset] = seamCarvingReduce(sizeReduction, remainOffset, image)
    if (sizeReduction == 0)
        return;
    end;
    [T, transBitMask] = findTransportMatrix(sizeReduction, remainOffset, image);
    [image, remainOffset] = deleteSeams(transBitMask, sizeReduction, remainOffset, image);
end

function [image, remainOffset] = seamCarvingEnlarge(sizeEnlarge, remainOffset, image)
    if (sizeEnlarge == 0)
        return;
    end;
    [T, transBitMask] = findTransportMatrix(sizeEnlarge, remainOffset, image);
	[image, remainOffset] = addSeams(transBitMask, sizeEnlarge, remainOffset, image);
end

function [T, transBitMask] = findTransportMatrix(sizeReduction, remainOffset, image)
% find optimal order of removing raws and columns

    T = zeros(sizeReduction(1) + 1, sizeReduction(2) + 1, 'double');
    transBitMask = ones(size(T)) * -1;

    % fill in borders
    imageNoRow = image;
    remainOffsetNoRow = remainOffset;
    for i = 2 : size(T, 1) % delete size(T, 1) horizontal seams
        energy = energyRGB(imageNoRow);
        energy = energy + remainOffsetNoRow;
        [optSeamMask, seamEnergyRow] = findOptSeam(energy');
        imageNoRow = reduceImageByMask(imageNoRow, optSeamMask, 0);
        remainOffsetNoRow = reduceOffsetByMask(remainOffsetNoRow, optSeamMask, 0);
        transBitMask(i, 1) = 0;

        T(i, 1) = T(i - 1, 1) + seamEnergyRow;
    end;

    imageNoColumn = image;
    remainOffsetNoColumn = remainOffset;
    for j = 2 : size(T, 2)
        energy = energyRGB(imageNoColumn);
        energy = energy + remainOffsetNoColumn;
        [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
        imageNoColumn = reduceImageByMask(imageNoColumn, optSeamMask, 1);
        remainOffsetNoColumn = reduceOffsetByMask(remainOffsetNoColumn, optSeamMask, 1);
        transBitMask(1, j) = 1;

        T(1, j) = T(1, j - 1) + seamEnergyColumn;
    end;

    % on the borders, just remove one column and one row before proceeding
    energy = energyRGB(image);
    energy = energy + remainOffset;
    [optSeamMask, seamEnergyRow] = findOptSeam(energy');
	%for vertical or horizontal use, you have to transpose it
    image = reduceImageByMask(image, optSeamMask, 0);
    remainOffset = reduceOffsetByMask(remainOffset, optSeamMask, 0);

    energy = energyRGB(image);
    energy = energy + remainOffset;
    [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
    image = reduceImageByMask(image, optSeamMask, 1);
    remainOffset = reduceOffsetByMask(remainOffset, optSeamMask, 1);

    % fill in internal part   %%% Here is the DP to decide order of vertical/horizontal seams
    for i = 2 : size(T, 1)

        imageWithoutRow = image; % copy for deleting columns
        remainOffsetWithoutRow = remainOffset;
        
        for j = 2 : size(T, 2)
            energy = energyRGB(imageWithoutRow);
            energy = energy + remainOffsetWithoutRow;

            [optSeamMaskRow, seamEnergyRow] = findOptSeam(energy');
            imageNoRow = reduceImageByMask(imageWithoutRow, optSeamMaskRow, 0);
            remainOffsetNoRow = reduceOffsetByMask(remainOffsetWithoutRow, optSeamMaskRow, 0);

            [optSeamMaskColumn, seamEnergyColumn] = findOptSeam(energy);
            imageNoColumn = reduceImageByMask(imageWithoutRow, optSeamMaskColumn, 1);
            remainOffsetNoColumn = reduceOffsetByMask(remainOffsetWithoutRow, optSeamMaskColumn, 1);

            neighbors = [(T(i - 1, j) + seamEnergyRow) (T(i, j - 1) + seamEnergyColumn)];
			% up and left, choose the min
            [val, ind] = min(neighbors);

            T(i, j) = val;
            transBitMask(i, j) = ind - 1;

            % move from left to right
            imageWithoutRow = imageNoColumn; % or im(i-1,j) NoRow
            remainOffsetWithoutRow = remainOffsetNoColumn;
        end;

        energy = energyRGB(image);
        energy = energy + remainOffset;
        [optSeamMaskRow, seamEnergyRow] = findOptSeam(energy');
         % move from top to bottom
        image = reduceImageByMask(image, optSeamMaskRow, 0);
        remainOffset = reduceOffsetByMask(remainOffset, optSeamMaskRow, 0);
    end;

end

% MinXin: to add seams
function [image, remainOffset] = addSeams(transBitMask, sizeReduction, remainOffset, image)
% add seams following optimal way(computed by DP)
    i = size(transBitMask, 1);
    j = size(transBitMask, 2);
	energyOffset = zeros( size(image,1), size(image, 2) );
    for it = 1 : (sizeReduction(1) + sizeReduction(2))
imshow(image); drawnow;
        energy = energyRGB(image);
		energy = energy + energyOffset + remainOffset;
        if (transBitMask(i, j) == 0)
            [optSeamMask, seamEnergyRaw] = findOptSeam(energy');
            image = enlargeImageByMask(image, optSeamMask, 0);
			energyOffset = enlargeOffsetByMask(energyOffset, optSeamMask, 0);
			remainOffset = enlargeOffsetByMask(remainOffset, optSeamMask, 0);
            i = i - 1;
        else
            [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
            image = enlargeImageByMask(image, optSeamMask, 1);
			energyOffset = enlargeOffsetByMask(energyOffset, optSeamMask, 1);
			remainOffset = enlargeOffsetByMask(remainOffset, optSeamMask, 1);
            j = j - 1;
        end;
        imshow(image);
        drawnow;
        
    end;
end

% operation is either reduceImageByMask or enlargeImageByMask
function [image, remainOffset] = deleteSeams(transBitMask, sizeReduction, remainOffset, image)
% delete seams following optimal way
    i = size(transBitMask, 1);
    j = size(transBitMask, 2);

    for it = 1 : (sizeReduction(1) + sizeReduction(2))
imshow(image); drawnow;
        energy = energyRGB(image);
        energy = energy + remainOffset;
        if (transBitMask(i, j) == 0)
            [optSeamMask, seamEnergyRaw] = findOptSeam(energy');
            image = reduceImageByMask(image, optSeamMask, 0);
			remainOffset = reduceOffsetByMask(remainOffset, optSeamMask, 0);
            i = i - 1;
        else
            [optSeamMask, seamEnergyColumn] = findOptSeam(energy);
            image = reduceImageByMask(image, optSeamMask, 1);
			remainOffset = reduceOffsetByMask(remainOffset, optSeamMask, 1);
            j = j - 1;
        end;
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
