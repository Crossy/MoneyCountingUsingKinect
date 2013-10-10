function camera_calibration()
%CAMERA_CALIBRATION Camera calibration automatically calibrates the Kinect camera.

%The output of this function will display the calibration frames with
%reference to the camera and shows the properties of the camera and saves
%the extrinsics and intrinsics in a struct.

%A5 or larger 30mm square checkerboard pattern is held infront of the
%camera. Checkerboard will be moving during calibration and once
%calibration is completed, calibration results will be displayed.
close all;clear,clc;

%Kinect will take a series of photos then saves it as 'videoimage' in the
%same directory
kinect_take_photo();

%Read extracted images for calibration
ima_read_calib_AA; %Modified image reader (includes modified data_calib from the RADOCCtoolbox)
image(II_mosaic);
colormap(gray(256)); %Display calibration images in greyscale

% Detect grid corners of checkerboard using cornerfinder
display('Begin detecting grid corners');
click_calib_AA; %Modified to include the automatic corner finder
go_calib_optim_AA; %Calculates the extrinsics and intrinsics

%Display Intrinsics & Extrinsics
ext_calib; %Original ext_calib function is called to plot the calibration frames
intrinsics = struct('fc',fc,'cc',cc,'alpha_c',alpha_c,'kc',kc,'err',err_std);
extrinsics = zeros(4,4,n_ima);

for i = 1:n_ima
    eval(['Rc = Rc_' num2str(i) ';']);
    eval(['Tc = Tc_' num2str(i) ';']);
    extrinsics(:,:,i) = [Rc Tc; 0 0 0 1];
end

extrinsics = struct('Transformation_Matrices',extrinsics);

%Saves the extrinsics and intrinsics values in a calib_data.mat file for
%further reference
save('camera_data','intrinsics','extrinsics');

end

