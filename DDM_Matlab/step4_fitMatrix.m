%% Fit DDM matrix
function [A,B,gamma] = step4_fitMatrix(ddm,tau)

% Autocorrelation function model for monodisperse sample
acfModel = @(a) exp(-tau*a);
% Intermediate scattering function model
isfModel = @(a) a(1)*(1 - acfModel(a(3))) + a(2);

% Estimate gamma by finding time at which curve reaches half saturation
estimateGamma = @(data) 1./tau((abs(data-(max(data)-min(data))/2).^2)==min(abs(data-(max(data)-min(data))/2).^2));

nQ = size(ddm,2);
fits = zeros(nQ,3);
for q=2:nQ
    data = ddm(:,q);
    resModel = @(a) sum(abs(isfModel(a) - data).^2);
    fit0 = [data(end)-data(1),data(1),estimateGamma(data)];
    %fits(q,:) = fminsearch(resModel,fit0);
    lb = [1,1,1]*1e-2;
    ub = [];
    fits(q,:) = fminsearchbnd(resModel,fit0,lb,ub);
    
    data_fit = isfModel(fits(q,:));
    semilogx(tau,data,'+',tau,data_fit,'-');
    title(['Fitting ',num2str(q),'/',num2str(nQ)]);
    drawnow;
end
A = fits(:,1);
B = fits(:,2);
gamma = fits(:,3);

end
