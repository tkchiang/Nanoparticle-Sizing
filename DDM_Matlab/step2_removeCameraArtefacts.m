%% Remove camera artefacts
function FTs = step2_removeCameraArtefacts(FTs0,buffers)
Npixels = size(FTs0,1);
NumLags = size(FTs0,3);
if nargin<2
    dsp = 10;
    imagesc(FTs0(Npixels/2-dsp:Npixels/2+dsp,Npixels/2-dsp:Npixels/2+dsp,1));
    axis equal tight;
    title('Check for processing artifacts');
    colorbar;
    disp(' ');
    bCols = input('Enter vertical buffer width in columns: ');  % Vertical buffer width, columns
    bRows = input('Enter horizontal buffer width in rows: ');   % Horizontal buffer width, rows
else
    bCols = buffers(1);
    bRows = buffers(2);
end
if bCols
    if mod(bCols,2)==0
        bCols = bCols + 1;
    end
    FTs0(:,(Npixels/2)-(bCols+1)/2+2:(Npixels/2)+(bCols+1)/2,:) = zeros(Npixels,bCols,NumLags);
end
if bRows
    if mod(bRows,2)==0
        bRows = bRows + 1;
    end
    FTs0((Npixels/2)-(bRows+1)/2+2:(Npixels/2)+(bRows+1)/2,:,:) = zeros(bRows,Npixels,NumLags);
end
FTs = FTs0;
end
