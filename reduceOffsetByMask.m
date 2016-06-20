
function offsetRedeced = reduceOffsetByMask(energyOffset, seamMask, isVertical)
	if(isVertical)
		offsetRedeced = reduceOffsetByMaskVertical(energyOffset, seamMask);
	else
		offsetRedeced = reduceOffsetByMaskHorizontal(energyOffset, seamMask');
	end;
end

function offsetReduced = reduceOffsetByMaskVertical(energyOffset, seamMask)
	offsetReduced = zeros(size(energyOffset, 1), size(energyOffset, 2) - 1);
    for i = 1 : size(seamMask, 1)
        offsetReduced(i, :) = energyOffset(i, seamMask(i, :));
    end
end

function offsetReduced = reduceOffsetByMaskHorizontal(energyOffset, seamMask)
	offsetReduced = zeros(size(energyOffset, 1) - 1, size(energyOffset, 2));
    for j = 1 : size(seamMask, 2)
        offsetReduced(:, j) = energyOffset(seamMask(:, j), j);
    end
end
