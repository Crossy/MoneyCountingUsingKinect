function [total_money_value, num_coins] = find_money()
%FIND_MONEY Attempts to find the Australian coins and notes in the
%rgb+depth image called image_t3.jpg and image_t3_d.jpg
close all;
% NUM_COINS = [five_cent, ten_cent, twenty_cent, fifty_cent, one_dollar, two_dollar];
num_coins = zeros(1,6);
%NUM_NOTES = [five_dollar, ten_dollar, twenty_dollar, fifty_dollar, hundred_dollar];
num_notes = zeros(1,5);
str = input('Use existing images?...\n','s');
if strcmp(str,'y') || strcmp(str,'Y')
    disp('Using image_t3.jpg and image_t3_d.jpg');
else
    kinect_take_photo();
end

rgbImage = imread('image_t3.jpg');
depthImage = imread('image_t3_d.jpg');

[gold_coins,silver_coins] = detect_coins(rgbImage,depthImage);

if isempty(gold_coins) && isempty(silver_coins)
    error('No coins found :(');
end
coins = [gold_coins;silver_coins];
save('coins', 'coins');

if exist('../Task 2/camera_data.mat','file')
    load('../Task 2/camera_data.mat','intrinsics');
    fc = mean(intrinsics.fc);
else
    error('Camera calibration not completed');
end

% Diameters of coins (in mm), take 1mm as it seems to underestimate radius
r2 = 20.5/2;
r1 = 25/2;
r50 = 31.51/2;
r20 = 28.52/2;
r10 = 23.6/2;
r5 = 19.41/2;
coin_radii = [r5 r10 r20 r50 r1 r2];

% For each detected coin, determine which size it is closest to
% Look at gold coins and identify
for c=1:size(gold_coins,1)
    coin = gold_coins(c,:);
    r_abs = (coin(3)*coin(5))/fc;
    deltas = abs(coin_radii-r_abs);
    [smallest, ind] = min(deltas);
    if smallest < 3
        if ind < 5
            disp('Coin was the wrong colour');
        end
        num_coins(ind) = num_coins(ind)+1;
    else
        %Not a coin
    end
end

% Look at silver coins and identify
for c=1:size(silver_coins,1)
    coin = silver_coins(c,:);
    r_abs = (coin(3)*coin(5))/fc;
    deltas = abs(coin_radii-r_abs);
    [smallest, ind] = min(deltas);
    if smallest < 3
        if ind > 4
            disp('Coin was the wrong colour');
        end
        num_coins(ind) = num_coins(ind)+1;
    else
        %Not a coin
    end
end

fprintf('No. of coins: $0.05=%d, $0.10=%d, $0.20=%d, $0.50=%d, $1.00=%d, $2.00=%d\n',...
    num_coins(1),num_coins(2),num_coins(3),num_coins(4),num_coins(5),num_coins(6));

%Find Notes
num_notes = detect_notes(rgbImage);

fprintf('No. of notes: $5=%d, $10=%d, $20=%d, $50=%d,$100=%d\n',...
    num_notes(1),num_notes(2),num_notes(3),num_notes(4),num_notes(5));

%Total money
coin_values = [0.05 0.1 0.2 0.5 1 2];
note_values = [5 10 20 50 100];
total_money_value = sum(coin_values.*num_coins) + sum(note_values.*num_notes);
fprintf('Total value was $%2.2f\n',total_money_value);

end