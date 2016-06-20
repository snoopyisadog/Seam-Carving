function [optSeamMask, seamEnergy] = findOptSeam(energy)
% following paper by Avidan and Shamir `07
% finds optimal seam
% returns mask with 0 mean a pixel is in the seam

    % find M for vertical seams
    % for vertical - use I`
    M = padarray(energy, [0 1], realmax('double')); % to avoid handling border elements
	%[x y] means pad surrounding x rows and y cols by max(real_number)
	
    sz = size(M);
    
    for ii=2:size(M,1)
        cur = M(ii-1,:);
        cmp = cur(1:end-1) < cur(2:end);% check if left is smaller than me
        cur([false cmp]) = cur(cmp);
        cmp = cur(2:end) < cur(1:end-1);% check if right is smaller than me
        cur(cmp) = cur([false cmp]);
        M(ii,:) = M(ii,:) + cur;
    end
    
    % find the min element in the last raw
    [val, indJ] = min(M(sz(1), :));
    seamEnergy = val;
    
    %optSeam = zeros(sz(1), 1, 'int32');
    optSeamMask = zeros(size(energy), 'uint8');
    
    %indJ = indJ - 1; % because of padding on 1 element from left
 
    %go backward and save (i, j)
    for i = sz(1) : -1 : 2  % down -> up   backtrack
        %optSeam(i) = indJ - 1;
        optSeamMask(i, indJ - 1) = 1; % -1 because of padding on 1 element from left
        neighbors = [M(i - 1, indJ - 1) M(i - 1, indJ) M(i - 1, indJ + 1)];
        [val, indIncr] = min(neighbors);
        
        seamEnergy = seamEnergy + val;
        
        indJ = indJ + (indIncr - 2); % (x - 2): [1,2]->[-1,1]]
    end
    %optSeam(1) = indJ; % to avoid if in loop becuase matlab is slow as hell
	%%% "i = 1" is the boundary condition, so specially case it
    optSeamMask(1, indJ - 1) = 1; % -1 because of padding on 1 element from left
    optSeamMask = ~optSeamMask;
	%at the begining, 1 means it's in the seam
	%since now, 1 means to keep the pixel(not in the seam)
    
end