unction [rgb, depth] = kinect_take_photo()
%KINECT_TAKE_PHOTO takes a photo using the connected Kinect
%
%   Call this function to take a photo. The rgb image and depth map will be
%   returned in matrix form (units mm).
%
%   The photos will also be saved as a jpg to the current directory and
%   called image_t3.jpg and image_t3_d.jpg for the rgb and depth map
%   respectively. The saved depth information is reduced to 8-bit
%   and will not work for distances beyond two metres. To get the distance
%   from the saved depth image, multiply any value by 8 to get the
%   distance value in mm.
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
    
    % Display pictures
    figure(2);
    imagesc(depth);
    drawnow;
    colormap gray;
    axis image off;
    figure(1);
    imagesc(rgb);
    axis image off;
    str = input('Are you happy with the image?...\n','s');
    
    % Save the files
    if strcmp(str,'y') || strcmp(str,'Y')
        disp('Saving images');
        warning('off','MATLAB:DELETE:FileNotFound');
        delete('image_t3.jpg');
        imwrite(rgb, 'image_t3.jpg');
        delete('image_t3_d.jpg');
        imwrite(uint8(floor(depth./8)), 'image_t3_d.jpg');
        % delete context
        mxNiDeleteContext(h);
        break;
    end
end