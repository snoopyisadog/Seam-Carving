function offsetEnlarged = enlargeOffsetByMask(energyOffset, seamMask, isVertical)
	if(isVertical)
		offsetEnlarged = enlargeOffsetByMaskVertical(energyOffset, seamMask);
	else
		offsetEnlarged = enlargeOffsetByMaskHorizontal(energyOffset, seamMask');
	end;
end

function offsetEnlarged = enlargeOffsetByMaskVertical(energyOffset, seamMask)
	sz = size(energyOffset);
	offsetEnlarged = zeros(sz(1), sz(2)+1);
	for i = 1 : size(seamMask,1)
		j = find(seamMask(i, :) ~= 1);
		offsetEnlarged(i, :) = [ energyOffset(i, 1:j-1), [ 50, 50], energyOffset(i, j+1:end) ];
		% 50 is temporary the inf in energy function
	end;
end

function offsetEnlarged = enlargeOffsetByMaskHorizontal(energyOffset, seamMask)
	sz = size(energyOffset);
	offsetEnlarged = zeros(sz(1)+1, sz(2));
	for j = 1 : size(seamMask,2)
		i = find(seamMask(:, j) ~= 1);
		offsetEnlarged(:, j) = [ energyOffset(1:i-1, j); [ 50; 50]; energyOffset( i+1:end, j) ];
	end;
end
