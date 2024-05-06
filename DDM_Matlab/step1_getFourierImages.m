function [FT_im, frameLags] = step1_getFourierImages(vid,maxPairs,minPairs,NumLags)
% Function to implement DDM algorithm and calculate Fourier images.
% Calls functions 'getInitialTimes()' and 'logspaceLags()'
nPixels = size(vid,1);
nFrames = size(vid,3);
frameLags = logspaceLags(nFrames-minPairs,NumLags);
nFrameLags = length(frameLags);
FT_im = zeros(nPixels,nPixels,nFrameLags);
cla(gca,'reset')
for lag=1:nFrameLags
    % Get initial times
    [initTimes,NumPairs] = getInitialTimes(frameLags(lag),nFrames,maxPairs);
    AvgFFT = zeros(nPixels);
    for pair=1:NumPairs
        frame1 = initTimes(pair);
        frame2 = frame1 + frameLags(lag);
        DiffIm = vid(:,:,frame2)-vid(:,:,frame1);
        AvgFFT = AvgFFT + abs(fftshift(fft2(DiffIm))).^2/NumPairs;
    end
    imagesc(AvgFFT);
    axis equal tight;
    title(['Fourier image ',num2str(lag),'/',num2str(nFrameLags),'  NumPairs = ',num2str(NumPairs)]);
    colorbar;
    drawnow;
    FT_im(:,:,lag) = AvgFFT;
end
end

%% Function to get initial time points for image pairs
function [times,numPairs] = getInitialTimes(frameLag,numFrames,maxPairs)
% Times are roughly equally spaced along time series.
if nargin<3 || maxPairs>numFrames-frameLag
    maxPairs = numFrames - frameLag;
end

times = unique(round(linspace(1,numFrames-frameLag,maxPairs)));
numPairs = length(times);
end
%% Function for generating log-spaced lag times
function frameLags = logspaceLags(NumFrames,NumLags)
tauFrames=[];
n=0;
while length(tauFrames)<NumLags
    n=n+1;
    % Frame lags
    tauFrames = unique(floor(logspace(0,log(NumFrames-0.1)/log(10),n)))';
end
frameLags = tauFrames;
end
