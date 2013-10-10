function overallCandidates = find_colour_candidates(rgbImage, hsvColour)
%FIND_COLOUR_CANDIDATES Returns squares in image that are candidates for the given colour
% hsvColour. Used to help identify squares in the Gretag-Macbeth colour
% chart.
if size(hsvColour,1) ~= 1 || size(hsvColour,2) ~= 3 || max(hsvColour) > 1 || min(hsvColour) < 0
    error('Invalid colour');
end

% List of tolerances to try.
tols = [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.13 0.15 ...
    0.17 0.2 0.22 0.25];
% Convert image to hsv and split into separate images.
hsvImage = rgb2hsv(rgbImage);
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

% Mask by image by hsvColour
overallCandidates = [];
for tol=1:length(tols)
    if abs(hsvColour(2)) < 0.01
        %disp('Assume grey colour. Using sat-val thresholding')
        %disp('NOTE: This doesn''t work well')
        
        % Calculate threshold values
        satThresholdLow = hsvColour(2) - tols(tol);
        satThresholdHigh = hsvColour(2) + tols(tol);
        valThresholdLow = hsvColour(3) - tols(tol);
        valThresholdHigh = hsvColour(3) + tols(tol);
        
        if satThresholdLow < 0
            %disp('Warning: Threshold will not wrap')
        end
        
        if valThresholdLow < 0
            %disp('Warning: Threshold will not wrap')
        end
        
        %Find mask based on saturation
        satMask = (sImage >=satThresholdLow) & (sImage <= satThresholdHigh);
        valMask = (vImage >=valThresholdLow) & (vImage <= valThresholdHigh);
        greyMask = uint8(satMask & valMask);
        %figure;imshow(greyMask);
        
        %Remove small objects
        smallestAcceptableArea = 100;
        greyMask = uint8(bwareaopen(greyMask, smallestAcceptableArea));
        
        %Smooth the border. Basically a dilation and erode
        structuringElement = strel('disk', 4);
        greyMask = imclose(greyMask, structuringElement);
        
        %Fill in any holes
        greyMask = uint8(imfill(greyMask, 'holes'));
        
        %Show the mask
        %imshow(greyMask);
        
        greyMask = cast(greyMask, class(rgbImage));
        
        %Apply mask to image
        maskedRGBImageR = greyMask.*rgbImage(:,:,1);
        maskedRGBImageG = greyMask.*rgbImage(:,:,2);
        maskedRGBImageB = greyMask.*rgbImage(:,:,3);
        
        maskedRGBImage = cat(3, maskedRGBImageR,maskedRGBImageG,maskedRGBImageB);
        %figure;imshow(maskedRGBImage);
        
        l = logical(greyMask);
    else
        %disp('Assume colour is not grey. Using hue thresholding')
        %Calculate threshold values
        hueThresholdLow = hsvColour(1) - tols(tol);
        hueThresholdHigh = hsvColour(1) + tols(tol);
        
        if hueThresholdLow < 0
            %disp('Warning: Threshold will not wrap')
        end
        
        %Find mask based on hue
        hueMask = (hImage >=hueThresholdLow) & (hImage <= hueThresholdHigh);
        %figure;imshow(hueMask);
        
        %Remove small objects
        smallestAcceptableArea = 100;
        hueMask = uint8(bwareaopen(hueMask, smallestAcceptableArea));
        
        %Smooth the border. Basically a dilation and erode
        structuringElement = strel('disk', 4);
        hueMask = imclose(hueMask, structuringElement);
        
        %Fill in any holes
        hueMask = uint8(imfill(hueMask, 'holes'));
        
        %Show the mask
        %imshow(hueMask);
        
        %Apply mask to image.
        hueMask = cast(hueMask, class(rgbImage));
        maskedRGBImageR = hueMask.*rgbImage(:,:,1);
        maskedRGBImageG = hueMask.*rgbImage(:,:,2);
        maskedRGBImageB = hueMask.*rgbImage(:,:,3);
        
        maskedRGBImage = cat(3, maskedRGBImageR,maskedRGBImageG,maskedRGBImageB);
        %imshow(maskedRGBImage);
        
        l = logical(hueMask);
    end
    
    % Segment regions and get properties
    stat = regionprops(l, 'basic');
    
    % Get max area of a the square blobs
    candidates = [];
    maxArea = 0;
    for s=1:length(stat)
        bb = stat(s).BoundingBox;
        if abs((bb(3)/bb(4))-1) < 0.2 && stat(s).Area > maxArea
            maxArea = stat(s).Area;
        end
    end
    
    % Filter out smaller blobs
    for s=1:length(stat)
        bb = stat(s).BoundingBox;
        if stat(s).Area > 0.7*maxArea && abs((bb(3)/bb(4))-1) < 0.2
            candidates = [candidates stat(s)];
        end
    end
    
    if length(candidates) > length(overallCandidates)
        overallCandidates = candidates;
    end
    
    %figure;imshow(rgbImage);
    %figure;imshow(maskedRGBImage);
end