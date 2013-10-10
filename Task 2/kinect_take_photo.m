function [rgb, depth] = kinect_take_photo()
%KINECT_TAKE_PHOTO takes 20 photos using the connected Kinect
%
%   Call this function to take a series of 20 images for the camera
%   calibration
%
%   The photos will also be saved as videoimage<n>.jpg where n is the
%   number of the image taken. 1<=n<=20

% Connect to Kinect
h = mxNiCreateContext('Config.xml');
% Capture images
for i=1:20
    % Align Depth onto RGB
    option.adjust_view_point = true;
    % Acquire RGB and Depth image
    mxNiUpdateContext(h, option);
    [rgb, depth] = mxNiImage(h);
    rgb = flipdim(rgb,2);
    depth = flipdim(depth,2);
    % Save to file
    warning('off','MATLAB:DELETE:FileNotFound');
    delete(['videoimage' num2str(i) '.jpg']);
    imwrite(rgb, ['videoimage' num2str(i) '.jpg']);
    
    figure(1);
    imagesc(rgb);
    axis image off;
    % Pause to enable picture to move and to reduce motion blur
    pause(0.4);
end
% Delete context
mxNiDeleteContext(h);

end