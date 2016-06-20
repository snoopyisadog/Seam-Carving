function [ R ] = calculateResidualImg( T, P, energyOffset )
%CALCULATE_RESIDUAL_IMG Summary of this function goes here
%   Detailed explanation goes here
% R : resudual. T : target frame. P : predict frame.
% we additionally introduce a weight w to influence  R.
    
    denominator = max( max( T));
    %denominator = sum( sum( T)); % It will make R very small
    
    w = T / denominator;
    
    %R = abs( (T - P) .* w);
    R = abs( (T - P) );
    
    %{
    sz = size( T);
    R = zeros( sz(1), sz(2) );
    for i = 1:sz(1)
        for j = 1:sz(2)
            if energyOffset( i, j) == 50
                R( i, j ) = abs( (T( i, j) - P( i, j)) * w(i,j) ) * 2;
            else
                R( i, j ) = abs( (T( i, j) - P( i, j)) * w(i,j) );
            end
        end
    end
    %}
    %{
    R = abs( T - P);
    %}
end

