function [ res ] = objectMoving( I, energyOffset, shift )
    [hei, wid, ~] = size(I);
    a = wid; b = 1;
    for i = 1:hei
        for j = 1:wid
            if energyOffset(i,j) == 50
                a = min( a, j);
                b = max( b, j);
            end
        end
    end
    fprintf('obj region:[ %d, %d]\n',a,b);
    mini = min( [ abs(shift), a-1, wid-(b+1) ]);
    if shift < 0
        shift = -mini;
    else
        shift = mini;
    end
    
    lf = I( :, 1:(a-1), :); %imwrite(lf,'lftest.jpg');
    sz = size(lf);
    lf = seamCarving( [sz(1), sz(2)+shift ], zeros( sz(1), sz(2)), lf);
    
    rt = I( :, b+1:end, :);
    sz = size(rt);
    rt = seamCarving( [sz(1), sz(2)-shift ], zeros( sz(1), sz(2)), rt);
    
    res = [ lf, I(:,a:b,:), rt];
end

