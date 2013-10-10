function [coin_location] = localise_coins()
%LOCALISE_COINS Helps map the detected coins in an image relative to a
%caltag frame in the picture. Requires task 3 to have been run on this
%image.
%
%Returns the location of the coins:
%coin_location <1x2> =  [x, y]

%N.B. This does not work wonderfully. Seems to be accurate to within 10cm
%or so.

%Uses data from Task 4
[~, homography] = position('a');

if exist('coins.mat','file')
    load('coins','coins');
else
    error('Run find_money');
end

%% Find location of coin using the homogrphy transform
%Outputs coin locations in matrix form [x y z]
for i = 1:size(coins,1)
    ii = coins(i,:);
    coin_location(i,1:2) = homography_transform([ii(2);ii(1)],homography);
    %Computes the position of the coin in a plane relative to the central
    %frame in mm
    coin_location(i,3) = 0; %Assuming on the same plane, Z axis = 0
    
end

end
