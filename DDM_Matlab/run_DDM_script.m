clear
clc
cd('/Users/tkchiang/Desktop/DDM/DDM_package_2024/MATLAB/')
addpath('Utility Functions/')
%% Load microscope video data
filename = '../Example Data/data.avi';
PixelSize = 0.265; % Pixel size in microns
FrameTime = 1.794e-3; % Frame time in seconds
vid = loadAVI(filename);

%% Compute time-averaged Fourier-transformed difference images
maxPairs = 100; % Maximum number of image pairs/difference images
minPairs = 100; % Minimum number of image pairs/difference images
NumLags = 50; % Number of lag times

[FTs0, FrameLags] = step1_getFourierImages(vid,maxPairs,minPairs,NumLags);
[q,tau] = getPhysParams(FrameTime, FrameLags, PixelSize, size(vid,1));
clear maxPairs minPairs NumLags
%% Get DDM matrix
FTs = step2_removeCameraArtefacts(FTs0,[1,0]); % Remove center vertical strip of width 1 pixel
%%
[DDM, ~] = step3_getMatrix(FTs);

%% Fit DDM matrix
[A,B,gamma] = step4_fitMatrix(DDM,tau);

%% Choose q's
idx = 6:38;
cla(gca,'reset')
plot(log(q(idx)),log(gamma(idx)),'o');axis equal;grid on
DC = gamma(idx)./q(idx).^2;
diameters = DiffusionCoefficient2Diameter(DC);

%% Plot results
cla(gca,'reset')
scatter(diameters,0*ones(size(diameters)),100,'filled','MarkerFaceAlpha',0.35,'MarkerEdgeAlpha',0)
xlabel('Diameter (nm)');
set(gcf,'Color','w');grid on
title(['D_h = ',num2str(mean(diameters)),' \pm ',num2str(std(diameters)), ' nm'])

hold on
[F,x]=ksdensity(diameters);
plot(x,F,'LineWidth',2)
box off
a=gca;
a.TickDir = 'out';
legend({'Measurements','Kernel Density Estimation'},'Location','best')
hold off


%% BEGIN UTILITY FUNCTIONS
%% Convert diffusion coefficient to diameter
function diameter = DiffusionCoefficient2Diameter(DC)
kb = 1.38e-23; % Boltzmann constant in Joules/Kelvin
T = 298.15; % Sample temperature in Kelvin
eta = 1e-3; % Viscosity of sample buffer (water)
diameter = 1e21*kb*T./(3*pi*eta*DC); % Return hydrodynamic diameter in nanometers
end

%% Function to calculate q values and lag times
function [q,tau] = getPhysParams(frameTime, frameLags, pixelSize, nPixels)
tau = frameTime*frameLags; % Lag times (units of frameTime)
q = (((2*pi)/(nPixels*pixelSize))*(1:nPixels/2))'; % Inverse length-scale (units of pixelSize)
end

%% Function for loading .avi file. Output is a z-stack of square arrays.
function vid = loadAVI(filename)
videoObject = VideoReader(filename);
NumFrames = videoObject.NumFrames;
Npixels = min([videoObject.Width, videoObject.Height]);

vid = zeros(Npixels,Npixels,NumFrames);
t = 0;
while hasFrame(videoObject) && t<NumFrames
    t = t + 1;
    v = readFrame(videoObject);
    vid(:,:,t) = sum(v(1:Npixels,1:Npixels,:),3);
end
end
