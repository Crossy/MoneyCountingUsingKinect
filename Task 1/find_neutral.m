function [rgb, hsv, ycrcb] = find_neutral(rgbImage)
%FIND_NEUTRAL Gets the RGB, HSV and YCrCb values of the most likely Neutral (#21)
% square for the Gretag-Macbeth colour chart.

% HSV values for the colour chart
colour_chart = [...
    17.9/360 0.409 0.451; 18.8/360 0.33 0.761; 215.6/360 0.376 0.616; 90.7/360 0.38 0.424; 246.1/360 0.277 0.694; 166.7/360 0.455 0.741;
    28.9/360 0.794 0.839; 232.3/360 0.518 0.651; 354.8/360 0.534 0.757; 282.5/360 0.444 0.424; 75/360 0.66 0.737; 39.4/360 0.795 0.878;
    236.8/360 0.627 0.588; 122.3/360 0.527 0.58; 357/360 0.691 0.686; 50.4/360 0.866 0.906; 322.6/360 0.54 0.733; 191/360 0.95 0.631;
    60/360 0.004 0.953; 0 0 0.784; 0 0 0.627; 60/360 0.008 0.478; 0 0 0.333; 0 0 0.204];

% Get most likely candidates
fourteenCandidates = find_colour_candidates(rgbImage, colour_chart(14,:));
nineteenCandidates = find_colour_candidates(rgbImage, colour_chart(19,:));
thirteenCandidates = find_colour_candidates(rgbImage, colour_chart(13,:));

%     % Plot most likely shapes. Uncomment this to see all candidates found
%     figure;imshow(rgbImage);hold on;title('All candidates neutral');
%     for c=1:length(fourteenCandidates)
%         bb = fourteenCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'r+');
%     end
%
%     for c=1:length(nineteenCandidates)
%         bb = nineteenCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'b+');
%     end
%
%     for c=1:length(thirteenCandidates)
%         bb = thirteenCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'g+');
%     end

% Check if the candidates are next to each other in the appropriate order
%N.B. This works less well than it should. Needs more debugging.
xInline = 0;
grid_sign = 0;
for ct=1:length(fourteenCandidates)
    bbFourteen = fourteenCandidates(ct).BoundingBox;
    if grid_sign ~= 0
        break;
    end
    %Find if thirteen candidates are close
    for cs=1:length(thirteenCandidates)
        bbThirteen = thirteenCandidates(cs).BoundingBox;
        inlineTol = 10;
        if abs(bbFourteen(1)-bbThirteen(1)) < inlineTol && abs(bbFourteen(2)-bbThirteen(2)) > (bbThirteen(4) - 10) && abs(bbFourteen(2)-bbThirteen(2)) < (2*bbThirteen(4)+ 10)
            finalCandidate = nineteenCandidates(ct);
            xInline = 1;
            grid_sign = sign(bbThirteen(2)-bbFourteen(2));
            break;
        elseif abs(bbFourteen(2)-bbThirteen(2)) < inlineTol && abs(bbFourteen(1)-bbThirteen(1)) > (bbThirteen(3)-10) && abs(bbFourteen(1)-bbThirteen(1)) < (2*bbThirteen(3)+ 10)
            finalCandidate = nineteenCandidates(ct);
            xInline = 0;
            grid_sign = sign(bbThirteen(1)-bbFourteen(1));
            break;
        end
    end
end

% Mark the result with a blue '+'
figure;imshow(rgbImage);hold on;title('Neutral 6.5 Candidate');
if exist('finalCandidate', 'var') == 0
    error('Cannot find neutral 6.5 (#21)');
end
bb = finalCandidate.BoundingBox;
if xInline == 0
    if grid_sign < 0
        centreX = round(bb(1)-0.5*bb(3));
        centreY = round(bb(2)-grid_sign*(2.5*bb(4)+(2/7)*bb(4)));
    else
        centreX = round(bb(1)-0.5*bb(3));
        centreY = round(bb(2)-grid_sign*(1.5*bb(4)+(2/7)*bb(4)));
    end
    
else
    if grid_sign < 0
        centreX = round(bb(1)-grid_sign*(1.5*bb(3)+(2/7)*bb(3)));
        centreY = round(bb(2)+0.5*bb(4));
    else
        centreX = round(bb(1)-grid_sign*(2.5*bb(3)+(2/7)*bb(3)));
        centreY = round(bb(2)+0.5*bb(4));
    end
end
plot(centreX, centreY, 'b+');

% Output the colour values
rgb = squeeze(rgbImage(centreY, centreX,:));
hsvImage = rgb2hsv(rgbImage);
hsv = squeeze(hsvImage(centreY,centreX,:));
YCrCbImage = rgb2ycbcr(rgbImage);
ycrcb = squeeze(YCrCbImage(centreY, centreX,:));