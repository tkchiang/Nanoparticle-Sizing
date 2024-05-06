%% Get DDM matrix
function [DDM_avg, DDM_std] = step3_getMatrix(FTs)
% Calls function 'azimuthalavg()'
Npixels = size(FTs,1);
NumLags = size(FTs,3);
disp(['Radially averaging ',num2str(NumLags),' Fourier images...']);

DDM_avg = zeros(NumLags,Npixels/2);
DDM_std = zeros(NumLags,Npixels/2);

cla(gca,'reset')
for n=1:NumLags
    imagesc(FTs(:,:,n));
    axis equal tight;
    title(['Radially averaging Fourier image ',num2str(n),'/',num2str(NumLags)]);
    colorbar;
    drawnow;
    % Azimuthal averaging of the FT images
    [DDM_avg(n,:), DDM_std(n,:), ~] = azimuthalavg(FTs(:,:,n),Npixels/2);
end
end


%% Function for azimuthal averaging processed FT images
function [Zavg, Zstd, R] = azimuthalavg(Image,nBins)

Npixels = size(Image,1);
[X,Y] = meshgrid(-1:2/(Npixels-1):1);
r = sqrt(X.^2+Y.^2);

dr = 1/(nBins-1);
rbins = linspace(-dr/2,1+dr/2,nBins+1);

R = (rbins(1:end-1)+rbins(2:end))/2;

Zavg = zeros(1,nBins);
Zstd = zeros(1,nBins);

for j=1:nBins
    bins = r>=rbins(j) & r<rbins(j+1);
    Zavg(j) = mean(Image(bins),'omitnan');
    Zstd(j) = std(Image(bins),'omitnan');
end
end
