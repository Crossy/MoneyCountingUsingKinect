% Gets the RGB, HSV and YCrCb values of the most likely Neutral (#21)
% square for the Gretag-Macbeth colour chart.
function [rgb, hsv, ycrcb] = find_orangeYellow(rgbImage)
% HSV values for the colour chart
colour_chart = [...
    17.9/360 0.409 0.451; 18.8/360 0.33 0.761; 215.6/360 0.376 0.616; 90.7/360 0.38 0.424; 246.1/360 0.277 0.694; 166.7/360 0.455 0.741;
    28.9/360 0.794 0.839; 232.3/360 0.518 0.651; 354.8/360 0.534 0.757; 282.5/360 0.444 0.424; 75/360 0.66 0.737; 39.4/360 0.795 0.878;
    236.8/360 0.627 0.588; 122.3/360 0.527 0.58; 357/360 0.691 0.686; 50.4/360 0.866 0.906; 322.6/360 0.54 0.733; 191/360 0.95 0.631;
    60/360 0.004 0.953; 0 0 0.784; 0 0 0.627; 60/360 0.008 0.478; 0 0 0.333; 0 0 0.204];

% Get most likely candidates
sixCandidates = find_colour_candidates(rgbImage, colour_chart(6,:));
elevenCandidates = find_colour_candidates(rgbImage, colour_chart(11,:));
twelveCandidates = find_colour_candidates(rgbImage, colour_chart(12,:));
eighteenCandidates = find_colour_candidates(rgbImage, colour_chart(18,:));

%     % Plot most likely shapes. Uncomment this to see all candidates found
%     figure;imshow(rgbImage);hold on;title('All candidates');
%     for c=1:length(sixCandidates)
%         bb = sixCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'r+');
%     end
%
%     for c=1:length(elevenCandidates)
%         bb = elevenCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'b+');
%     end
%
%     for c=1:length(twelveCandidates)
%         bb = twelveCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'g+');
%     end
%
%     for c=1:length(eighteenCandidates)
%         bb = eighteenCandidates(c).BoundingBox;
%         centreX = round(bb(1)+0.5*bb(3));
%         centreY = round(bb(2)+0.5*bb(4));
%         plot(centreX, centreY, 'w+');
%     end

% %Check if it on the side of the image. This doesn't work because
% image is not cropped
% temp = [];
% for c=1:length(twelveCandidates)
%     bb = twelveCandidates(c).BoundingBox;
%     edgeTol = 50;
%     if bb(1) < edgeTol || size(cropped,2)-(bb(1)+ bb(3)) < edgeTol || bb(2) < edgeTol ||size(cropped,1) - (bb(2)+ bb(4)) < edgeTol
%         %Must be on the edge
%         temp = [temp twelveCandidates(c)];
%     end
% end
% twelveCandidates = temp;
%
% temp = [];
% for c=1:length(sixCandidates)
%     bb = sixCandidates(c).BoundingBox;
%     edgeTol = 50;
%     if (bb(1) < edgeTol || size(cropped,2)-(bb(1)+ bb(3)) < edgeTol) && (bb(2) < edgeTol ||size(cropped,1) - (bb(2)+ bb(4)) < edgeTol)
%         %Must be on the edge
%         temp = [temp sixCandidates(c)];
%     end
% end
% sixCandidates = temp;
%
% temp = [];
% for c=1:length(eighteenCandidates)
%     bb = eighteenCandidates(c).BoundingBox;
%     edgeTol = 50;
%     if bb(1) < edgeTol || size(cropped,2)-(bb(1)+ bb(3)) < edgeTol || bb(2) < edgeTol ||size(cropped,1) - (bb(2)+ bb(4)) < edgeTol
%         %Must be on the edge
%         temp = [temp eighteenCandidates(c)];
%     end
% end
% eighteenCandidates = temp;
%
% %Plot edge candidates
% figure;imshow(cropped);hold on;title('Candidates on the edge')
% for c=1:length(twelveCandidates)
%     bb = twelveCandidates(c).BoundingBox;
%     centreX = round(bb(1)+0.5*bb(3));
%     centreY = round(bb(2)+0.5*bb(4));
%     plot(centreX, centreY, 'g+');
% end
%
% for c=1:length(sixCandidates)
%     bb = sixCandidates(c).BoundingBox;
%     centreX = round(bb(1)+0.5*bb(3));
%     centreY = round(bb(2)+0.5*bb(4));
%     plot(centreX, centreY, 'r+');
% end
%
% for c=1:length(eighteenCandidates)
%     bb = eighteenCandidates(c).BoundingBox;
%     centreX = round(bb(1)+0.5*bb(3));
%     centreY = round(bb(2)+0.5*bb(4));
%     plot(centreX, centreY, 'w+');
% end

% Check if the candidates are next to each other in the appropriate order
for ct=1:length(twelveCandidates)
    bbTwelve = twelveCandidates(ct).BoundingBox;
    %Find if six candidates are close
    for cs=1:length(sixCandidates)
        bbSix = sixCandidates(cs).BoundingBox;
        inlineTol = 10;
        if abs(bbSix(1)-bbTwelve(1)) < inlineTol || abs(bbSix(2)-bbTwelve(2)) < inlineTol
            finalCandidate = twelveCandidates(ct);
        end
    end
end

% Mark the result with a blue '+'
figure;imshow(rgbImage);hold on;title('Orange Yellow Candidate');
if exist('finalCandidate', 'var') == 0
    error('Cannot find orange yellow (#12)');
end
bb = finalCandidate.BoundingBox;
centreX = round(bb(1)+0.5*bb(3));
centreY = round(bb(2)+0.5*bb(4));
plot(centreX, centreY, 'b+');
% Output the colour values
rgb = squeeze(rgbImage(centreY, centreX,:));
hsvImage = rgb2hsv(rgbImage);
hsv = squeeze(hsvImage(centreY,centreX,:));
YCrCbImage = rgb2ycbcr(rgbImage);
ycrcb = squeeze(YCrCbImage(centreY, centreX,:));