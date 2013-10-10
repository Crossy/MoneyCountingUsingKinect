function [CameraPosition, homography] = position(~)
%POSITION Locates the position of the camera with reference to a
%central frame.

%A caltag is used as the central frame which is typically
%positioned on the left to the money plate.

%Note: CALTAG, RADOCC, RVC TOOLBOXES ARE NEEDED

%Assuming the bottom left of the caltag is the origin
close all;clear;clc;
addpath(genpath('caltag-master'));

%Copies the image files from the previous task to help with task 5.
if nargin == 1
    disp('Copying image_t3.jpg and image_t3_d.jpg from task 3');
    copyfile('../Task 3/image_t3.jpg','image_t4.jpg');
    copyfile('../Task 3/image_t3_d.jpg','image_t4_d.jpg');
else
    str = input('Use existing image?...\n','s');
    if strcmp(str,'y') || strcmp(str,'Y')
        disp('Using image_t4.jpg');
    else
        kinect_take_photo();
    end
end
im = imread('image_t4.jpg');
%Load data from camera_calibration function
if exist('camera_data.mat','file')
    load('camera_data','intrinsics');
else
    error('No camera data available');
end

%% The Caltag function from the Caltag-master toolbox is used to detect the
%corner points through generated checkerboard pattern
%Only takes grayscale image
im2 = rgb2gray(im);
[wPt,iPt] = caltag(im2,'caltag.mat');

%Plot the detected corner points in 2D with scaled image - Note the axis
%conventions
imagesc(im); %Scales data and plots image
hold on;

%Plot the values of iPt as the caltag function returns the iPt points as a
%2xN matrix
for points = iPt'
    plot(points(2), points(1), '*');
end
hold on;
xlabel('x');
ylabel('y');
zlabel('z');

%% Calculate the extrinsics and intrinsics of the camera using the compute
%extrinsics function in the RADOCCToolbox

x_kk = iPt'; %Feature locations on the images
dX = 24.5; %The square width of the caltag target is 24.5mm
X_kk = [wPt zeros(size(wPt, 1), 1)]'*dX; %Corresponding grid coordinates in mm
fc = intrinsics.fc; %Camera focal length from camera_data.mat
cc = intrinsics.cc; %Principal point coordinates from camera_data.mat
kc = intrinsics.kc; %Distortion coefficients from camera_data.mat
alpha_c = intrinsics.alpha_c; %Skew coefficient from camera_data.mat

%Compute_extrinsic function from the RADOCCtoolbox is used
%omckk: 3D rotation vector attached to the grid positions in space
%Tckk: 3D translation vector attached to the grid positions in space
%Rckk: 3D rotation matrices corresponding to the omc vectors
%H: Homography between points on the grid and points on the image plane (in pixel)
%This makes sense only if the planar that is used in planar.
%x: Reprojections of the points on the image plane
%ex: Reprojection error: ex = x_kk - x;
[omckk,Tckk,Rckk,H,x,ex] = compute_extrinsic(x_kk,X_kk,fc,cc,kc,alpha_c);

extrinsics = [Rckk Tckk]%; 0 0 0 1] * [1 0 0 0;0 1 0 0;0 0 -1 0;0 0 0 1];

%% Plot camera position in world centred view
%Modified from the ext_calib.m from the calibration toolbox
colors = 'brgkcm';
if exist('calib_data.mat','file') %Load nx & ny from calibration data
    load('calib_data','nx');
    load('calib_data','ny');
else
    error('Calibration data not available');
end
IP = 5*dX*[1 -alpha_c 0;0 1 0;0 0 1]*[1/fc(1) 0 0;0 1/fc(2) 0;0 0 1]*[1 0 -cc(1);0 1 -cc(2);0 0 1]*[0 nx-1 nx-1 0 0 ; 0 0 ny-1 ny-1 0;1 1 1 1 1];
BASE = 5*dX*([0 1 0 0 0 0;0 0 0 1 0 0;0 0 0 0 0 1]);
IP = reshape([IP;BASE(:,1)*ones(1,5);IP],3,15);
POS = [[7*dX;0;0] [0;7*dX;0] [-dX;0;6*dX] [-dX;-dX;-dX] [0;0;-dX]];
figure(2);
clf;
hold on;

for kk = 1:1:size(extrinsics,3),
    Rc_kk = extrinsics(1:3,1:3,kk);
    Tc_kk = extrinsics(1:3,4,kk);
    YYx = 0:dX:8*dX;
    YYy = (0:dX:4*dX)';
    YYx = [YYx;YYx;YYx;YYx;YYx];
    YYy = [YYy YYy YYy YYy YYy YYy YYy YYy YYy];
    YYz = zeros(5,9);
    BASEk = Rc_kk'*(BASE - Tc_kk * ones(1,6));
    IPk = Rc_kk'*(IP - Tc_kk * ones(1,15));
    POSk = Rc_kk'*(POS - Tc_kk * ones(1,5));
    
    %Plots the Caltag target and the camera position
    figure(2);
    plot3(BASEk(1,:),BASEk(2,:),BASEk(3,:),'*-','linewidth',1');
    plot3(IPk(1,:),IPk(2,:),IPk(3,:),'r-','linewidth',1);
    text(POSk(1,5),POSk(2,5),POSk(3,5),num2str(kk),'fontsize',10,'color','k','FontWeight','bold');
    hhh= mesh(YYx,YYy,YYz);
    set(hhh,'edgecolor',colors(rem(kk-1,6)+1),'linewidth',1);
    
    rotate3d on;
    grid on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    axis tight;
    title('Camera Position (World Centred)');
    plot3([1 0 0 0 0],[0 0 1 0 0],[0 0 0 0 1],'o'); %Origin of caltag
end

%% Display camera position and angle in a matrix formation
%[xPosition yPosition zPosition Roll Pitch Yaw]
Rc = extrinsics(1:3,1:3);
Tc = extrinsics(1:3,4);
Po = -Rc'*Tc;
An = tr2rpy(extrinsics, 'deg');
CameraPosition = [Po' An];

%% Required for mapping coins and Task 5 - maps the two matrices
homography = homography_solve(x_kk,X_kk(1:2,:));

end