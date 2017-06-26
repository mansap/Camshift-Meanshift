% Title: Face Detection and tracking using CAMSHIFT Algorithm
%
% This entire code is implemented by MATLAB, taken from example provided by MATHWORKS:
% MathWorks, (MATLAB 2016a), Computer Vision System toolbox(TM), The MathWorks, Inc., Natick, Massachusetts, United States.
% URL: http://www.mathworks.com/help/vision/examples/face-detection-and-tracking-using-camshift.html?refresh=true 
% Downloaded Time 8:50pm, 6th April'16 
%
% Description: The following code was used to study the working of the CAMSHIFT
% algorithm implemented by MATLAB on various input samples.
% The results of these input samples have been recorded for study purposes.
%  
% Project Title: Study of face tracking using Mean Shift and CAMSHIFT Algorithm
% 
% Code used for study of CAMSHIFT algorithm project by:
% Name: Mansa Pabbaraju, Rochester Institute of Technology, Spring 2016
 

function Pabbaraju_Mansa_Camshift_Study(fn)

 % Take input video file from the user
 
    % if number of arguments is less than 1, provide input file name
    if nargin < 1
        % take the melon image from Test Image
        fn = 'visionface.avi';
        %fn = 'Hand_occlusion.mp4';
        %fn = 'mmmm.mp4';
    end
    
% Creating a video reader %

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the detector.
videoFileReader = vision.VideoFileReader(fn);
videoFrame      = step(videoFileReader);

% Viola Jones face detection %
                   
bbox            = step(faceDetector, videoFrame);

% Draw the returned bounding box around the detected face.
videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');
figure, imshow(videoOut), title('Detected face');


% Taking the HUE channel of the image %
              
% Get the skin tone information by extracting the Hue from the video frame
% converted to the HSV color space.
[hueChannel,~,~] = rgb2hsv(videoFrame);

% Display the Hue Channel data and draw the bounding box around the face.
figure, imshow(hueChannel), title('Hue channel data');
rectangle('Position',bbox(1,:),'LineWidth',2,'EdgeColor',[1 1 0])

% Detect the nose within the face region. The nose provides a more accurate
% measure of the skin tone because it does not contain any background
% pixels.
noseDetector = vision.CascadeObjectDetector('Nose', 'UseROI', true);
noseBBox     = step(noseDetector, videoFrame, bbox(1,:));

% Create a tracker object.
tracker = vision.HistogramBasedTracker;

% Initialize the tracker histogram using the Hue channel pixels from the
% nose.
initializeObject(tracker, hueChannel, noseBBox(1,:));

% Create a video player object for displaying video frames.
videoInfo    = info(videoFileReader);

% position the video frame correctly
videoPlayer  = vision.VideoPlayer('Position',[300 300 videoInfo.VideoSize+30]);


% TRACKING THE FACE %

% Track face over successive video frames until the video is finished
% do this is a while loop
while ~isDone(videoFileReader)

    %Extract the next video frame
    videoFrame = step(videoFileReader);

    % Convert the RGB video frame to HSV color space and read in the Hue
    % channel
    [hueChannel,~,~] = rgb2hsv(videoFrame);

    %Track using the Hue channel data
    bbox = step(tracker, hueChannel);

    % Insert a bounding box around the object being tracked
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoOut);

end

% Release resources
release(videoFileReader);
release(videoPlayer);
