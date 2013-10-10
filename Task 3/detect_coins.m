function [gold_coins, silver_coins] = detect_coins(rgbImage,depthImage)
%DETECT_COINS Attempts to detect the coins in the iamge given. rgbImage and
%depthImage must by matrices of each respective image. depthImage is of the
%format seen in kinect_take_photo() in this directory.
%
%Returns gold and silver coins in the format:
%<1x5> [rx, ry, radius, t, depth] (Basically hough circles plus depth)

%%Setup
%Convert depth back to mm
depthImage = imresize(double(depthImage).*8, [1024 1280]);
depthMean = mean2(depthImage);

if depthMean < 100
    warning('There is something fishy about this depth')
    depthImage(~depthImage) = NaN;
    depthMean = nanmean(nanmean(depthImage));
end

if exist('../Task 2/camera_data.mat','file')
    load('../Task 2/camera_data.mat','intrinsics');
    fc = mean(intrinsics.fc);
else
    error('Camera calibration not completed');
end

%% Hough Circles
%For 50c, $1 & 20c coins
rLarge = fc*15/depthMean;
%For $2, 10c & 5c coins
rSmall = fc*10/depthMean;
largeTol = 5;
smallTol = 4;

large = houghcircles(rgbImage,floor(rLarge-largeTol),ceil(rLarge+largeTol),0.4, floor(rLarge-largeTol));
small = houghcircles(rgbImage,floor(rSmall-smallTol),ceil(rSmall+smallTol),0.4,floor(rSmall-smallTol));
coins = [large;small];

% Draw hough circles
figure, imshow(rgbImage), hold on, title('Hough Circles');
for i = 1:size(coins,1)
    x = coins(i,1)-coins(i,3);
    y = coins(i,2)-coins(i,3);
    w = 2*coins(i,3);
    rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
end
hold off;

%     %% Get rid of non-circles
%Look at eccentrity?
%     temp = [];
%     figure;
%     for c=1:size(coins,1)
%         %Get bounding box
%         rx = coins(c,1)-coins(c,3);
%         ry = coins(c,2)-coins(c,3);
%         w = 2*coins(c,3);
%         bbRGB = imcrop(rgbImage, [rx ry w w]);
%         bbGray = rgb2gray(bbRGB);
%         imshow(bbRGB);
%         E = edge(bbGray,'canny');
%         % Perform Hough Line transform
%         [H, T, R] = hough(E);
%
%         % Get top N line candidates from hough accumulator
%         N = 10;
%         P = houghpeaks(H, N,'Threshold',26);
%
%         % Get hough line parameters
%         if length(P) > 0
%             lines = houghlines(bbGray, T, R, P);
%
%             % Overlay detected lines - this code copied from 'doc houghlines'
%             hold on;
%             for k = 1:length(lines)
%                 xy = [lines(k).point1; lines(k).point2];
%                 plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'blue');
%
%                 % Plot beginnings and ends of lines
%                 plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
%                 plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
%             end
%         else
%             temp = [temp;coins(c,:)];
%         end
%
%     end
%     coins = temp;

%         bbRGB = imadjust(bbRGB,stretchlim(bbRGB),[0 1]);
%         bbGray = rgb2gray(bbRGB);
%         mask = ones(size(bbGray));
%         bw = activecontour(bbGray,mask, 300);
%         subplot(1,2,1),subimage(bw);
%
%         mask = zeros(size(bbGray));
%         ix = size(mask,2);
%         iy = size(mask,1);
%         r = coins(c,3);
%         [x,y] = meshgrid(-w/2:w/2, -w/2:w/2);
%         mask = mask + ((x.^2+y.^2) <= r^2);
%         subplot(1,2,2),subimage(mask);
%         mask = logical(mask);
%
%         if sum(sum(abs(mask-bw)))/(ix*iy) < 0.2
%             % Is a circle
%             temp = [temp;coins(c,:)];
%         end
%     end
%     coins = temp;
%
%% Get rid of circles in circles
% Order by radius
sorted = sortrows(coins, -3);
coins = [];
for c=1:size(sorted,1)
    rx = sorted(c,1);
    ry = sorted(c,2);
    inside = 0;
    for lc=1:size(coins, 1)
        minrx = coins(lc,1)-coins(lc,3);
        maxrx = coins(lc,1)+coins(lc,3);
        minry = coins(lc,2)-coins(lc,3);
        maxry = coins(lc,2)+coins(lc,3);
        if (rx > minrx && rx < maxrx) && (ry > minry && ry < maxry)
            % Circle inside another circle->discard
            inside = 1;
            break;
        end
    end
    if inside == 0
        coins = [coins; sorted(c,:)];
    end
end

if nargout==0   % Draw circles
    figure, imshow(rgbImage), hold on, title('Inside circles removed');
    for i = 1:size(coins,1)
        x = coins(i,1)-coins(i,3);
        y = coins(i,2)-coins(i,3);
        w = 2*coins(i,3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
    end
    hold off;
end

%% Get rid of coins of the wrong colour.
%N.B. This does not work well as silver coins are usually detected as gold.
%Lighting is also a huge issue.
gold_coins = [];
silver_coins = [];
%figure; title('Detected coin');
for c=1:size(coins, 1)
    %Get bounding box
    x = coins(c,1)-coins(c,3);
    y = coins(c,2)-coins(c,3);
    w = 2*coins(c,3);
    bbRGB = imcrop(rgbImage, [x y w w]);
    %figure,subplot(1,2,1),subimage(bbRGB);
    
    centrePixels = imcrop(bbRGB, [0.5*(w/2) 0.5*(w/2) (w/2) (w/2)]);
    %subplot(1,2,2),subimage(centrePixels);
    centrePixels = rgb2hsv(centrePixels);
    
    meanH = mean2(centrePixels(:,:,1));
    meanS = mean2(centrePixels(:,:,2));
    meanV = mean2(centrePixels(:,:,3));
    
    %     goldHSV = [39.4/360 0.795 0.878];
    %     silverHSV =[0 0 0.627];
    
    if meanH >= 0.055 && meanH <= 0.21 && meanS >= 0.25
        % Must be gold coin
        gold_coins = [gold_coins; coins(c,:)];
    elseif abs(meanS) <= 0.27 && abs(meanV) < 0.65
        % Coin is silver
        silver_coins = [silver_coins; coins(c,:)];
    else
        %Not a valid coin. Discard.
        msg = sprintf('Discarded coin %d @ x=%d, y=%d, meanH = %.4f, meanS = %.4f',...
            c,coins(c,1),coins(c,2),meanH,meanS);
        disp(msg);
    end
end

coins = [gold_coins;silver_coins];

figure, imshow(rgbImage), hold on, title('Detected coins');
for i = 1:size(gold_coins,1)
    x = gold_coins(i,1)-gold_coins(i,3);
    y = gold_coins(i,2)-gold_coins(i,3);
    w = 2*gold_coins(i,3);
    rectangle('Position', [x y w w], 'EdgeColor', 'yellow', 'Curvature', [1 1]);
end
for i = 1:size(silver_coins,1)
    x = silver_coins(i,1)-silver_coins(i,3);
    y = silver_coins(i,2)-silver_coins(i,3);
    w = 2*silver_coins(i,3);
    rectangle('Position', [x y w w], 'EdgeColor', 'green', 'Curvature', [1 1]);
end
hold off;

%Add depth to the coins for later calculations
temp = [];
for c=1:size(gold_coins,1)
    coin = gold_coins(c,:);
    coinDepth = nanmean(nanmean(imcrop(depthImage,[coin(1)-coin(3) coin(2)-coin(3) 2*coin(3) 2*coin(3)])));
    temp = [temp; cat(2,gold_coins(c,:),coinDepth)];
end
gold_coins = temp;
temp = [];
for c=1:size(silver_coins,1)
    coin = silver_coins(c,:);
    coinDepth = nanmean(nanmean(imcrop(depthImage,[coin(1)-coin(3) coin(2)-coin(3) 2*coin(3) 2*coin(3)])));
    temp = [temp; cat(2,silver_coins(c,:),coinDepth)];
end
silver_coins = temp;
coins = [gold_coins;silver_coins];
end