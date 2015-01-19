clear;
clc;
movieTitle = 'data/greycard.AVI';
disp(['Starting algorithm, loading movie ' movieTitle]);
mov = VideoReader(movieTitle);
vidFrames = read(mov);
nbFrames = get(mov,'NumberOfFrames');
disp('Done.');

%%
vidFrames = vidFrames(:,:,:,55:75);
nbFrames = 20;

%%

anchor = [3 18];


clear A;
clear frameCorrected;

disp('Loading specific frames');


j = 1;
for anchorIndex = anchor
    A = zeros(120,160,3,nbFrames);
    frame = double(vidFrames(:,:,:,anchorIndex));
    n = 0;
    for i = anchorIndex+1:nbFrames
        tic
        frame2 = double(vidFrames(:,:,:,i));
        frame = frame./max(frame(:));
        frame2 = frame2./max(frame2(:));
        A(:,:,:,i) = computeAdjustmentFrame(A(:,:,:,i-1),frame,frame2,4);
        frame = frame2;
        n = n+1;
        disp(100*n/nbFrames);
        toc
    end
    
    n = nbFrames-anchorIndex;
    frame = double(vidFrames(:,:,:,anchorIndex));
    for i = anchorIndex-1:-1:1
        tic
        frame2 = double(vidFrames(:,:,:,i));
        frame = frame./max(frame(:));
        frame2 = frame2./max(frame2(:));
        A(:,:,:,i) = computeAdjustmentFrame(A(:,:,:,i+1),frame,frame2,4);
        frame = frame2;
        n=n+1;
        disp(100*n/nbFrames);
        toc
    end
    
    
    
    upsampledA = zeros(480,640,3,nbFrames);
    for i = 1:nbFrames
       upsampledA(:,:,:,i) = imresize(A(:,:,:,i),4); 

    end

    for i = 1:nbFrames
        fprintf('Computing corrected frames %d%', 100*(i/nbFrames));
        fprintf('\r');
        correctedFrame = RGB2Lab(double(vidFrames(:,:,:,i))/255.0) + upsampledA(:,:,:,i);
        frameCorrected(:,:,:,i,j) = Lab2RGB(correctedFrame);
    end
    j = j+1;
end


%%

sumTime = 0.0001;
frame = double(vidFrames(:,:,:,frameInit+1));
for i = 1:nbFrames
    tic
    fprintf('Computing adjustmentFrame %3.1f',100*(i/nbFrames));
    frame2 = double(vidFrames(:,:,:,frameInit+i+1));

    frame = frame./max(frame(:));
    frame2 = frame2./max(frame2(:));
    
    A(:,:,:,i+1) = computeAdjustmentFrame(A(:,:,:,i),frame,frame2,4);
    
    frame = frame2;
    remainingTime = (nbFrames-i)*(sumTime/i);
    fprintf('Remaining time : %f',remainingTime);
    fprintf('\r');
    
    lastTime = toc;
    sumTime = sumTime + lastTime;
end

%%Correcting movie with adjustmentMap


upsampledA = zeros(480,640,3,nbFrames);
for i = 1:nbFrames
   upsampledA(:,:,:,i) = imresize(A(:,:,:,i),4); 
    
end

for i = 1:nbFrames
    fprintf('Computing corrected frames %d%', 100*(i/nbFrames));
    fprintf('\r');
    correctedFrame = RGB2Lab(double(vidFrames(:,:,:,frameInit+i))/255.0) + upsampledA(:,:,:,i);
    frameCorrected(:,:,:,i) = Lab2RGB(correctedFrame);
end
%%

