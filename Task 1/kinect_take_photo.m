function [rgb, depth] = kinect_take_photo()
%KINECT_TAKE_PHOTO takes a photo using the connected Kinect
%
%   Call this function to take a photo.
%
%   The photo will also be saved as a image_t1.jpg to the current
%   directory. Make sure you are in the correct directory or this will call
%   the wrong kinect_take_photo()
%

% Connect to Kinect
h = mxNiCreateContext('Config.xml');
% Capture image
while 1
    % Align Depth onto RGB
    option.adjust_view_point = true;
    % Acquire RGB and Depth image
    mxNiUpdateContext(h, option);
    [rgb, depth] = mxNiImage(h);
    rgb = flipdim(rgb,2);
    depth = flipdim(depth,2);
    
    % Display image
    figure(1);
    imagesc(rgb);
    axis image off;
    % Save image
    str = input('Are you happy with the image?...\n','s');
    if strcmp(str,'y') || strcmp(str,'Y')
        disp('Saving images');
        warning('off','MATLAB:DELETE:FileNotFound');
        delete('image_t1.jpg');
        imwrite(rgb, 'image_t1.jpg');
        % Delete context
        mxNiDeleteContext(h);
        break;
    end
end