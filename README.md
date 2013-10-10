MoneyCountingUsingKinect
========================

A METR4202 assignment to count the Australian dollars in an image taken by a Kinect. Uses Matlab.

This is Lab 2 for METR4202 (Advanced Control and Robotics) at The University of Queensland Semester 2 2013. This was in a group with Anita Chow. We got a distinction for this demo, but this code needs a lot of tweaking to work in many environments. The lab where we tested has yellow lights so the code will be tweaked to that room.

Assignment Objectives:
Using the RGB+D camera (a Microsoft Kinect), this laboratory will:
- Calibrate the RGB+D camera 
- Segment the valuable features (the money)
- Locate the camera relative to a central frame 
- Map the location in the environment.  

Assignment sheet: https://docs.google.com/document/d/1w-9lWCg1PWRlgY0-O5nGssN0SYMOKJKjX4BOHHS0L90/edit
Course website: http://robotics.itee.uq.edu.au/~metr4202/index.html
Lecturer: Surya P. N. Singh

Kinect Drivers/Middleware:
- PrimeSense
- OpenNi
- NITE64

Kinect Matlab Toolbox:
- KinectMex

Image Processing Toolboxes:
- VLFeat
- Peter Corkes Robotics Toolbox - rvctools
- RADOCC
- CALTAG
- http://www.vision.caltech.edu/bouguetj/calib_doc/
- houghcircles (From http://www.mathworks.com.au/matlabcentral/fileexchange/22543-detects-multiple-disks-coins-in-an-image-using-hough-transform/content/houghcircles.m )

This code comes with absolutely no gurantees and it will be very unlikely that it will be supported. Feel free to use any of this code.
