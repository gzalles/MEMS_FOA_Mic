%% description 

%use this script to animate the polar data to get a sense of how the polar
%response evolves as a function of frequency. for a single capsule!

%% clear space and load data

%clear workspace and command window
clear; clc; 

%load the test data
load data/aes147/mar16/medSingleFrontFar.mat;

%% variable declaration

%declare some variables
numIRs = 101;           %number of IRs in our data (deconvolved)
fs = length(data(1).IR);%sampling rate (only works if IR is 1 sec long)
Nfft = 2^12;            %number of points for FFT

%allocate memory for IRs
ir = zeros(fs, numIRs);     %use this one for audio
IR = zeros(Nfft, numIRs);   %use this one for FFT 

%% get IRs from struct, take FFT and remove FFT symmetry.

%get IRs from the struct. 
for i = 1:1:numIRs
    ir(:, i) = data(i).IR;
end

%turn all the audio data into magnitudes
for i = 1:1:numIRs
    cur_ir = ir(:, i);                  %get the current IR
    IR(:, i) = abs(fft(cur_ir, Nfft));  %get the magnitude of FFT
end

%chop off mirrored half of FFT
IR = IR(1:end/2, :);

%% copy, flip and append symmetric polar data

% get indices 2 to 100 (99 total) corresponding to degrees 1.8 to 178.2 and
% flip them. Then append them to the end of the data to create other hald
% of polar. After index 101 we should go back to 100 and down to 2;

cpyIdxLo = 2;
cpyIdxHi = 100;

IR_cpy = IR;                   %copy the data 
IR_cpy = IR_cpy(:, 2:100);     %get rest of data without doubling values
IR_cpy = fliplr(IR_cpy);       %flip left/right
IR = [IR IR_cpy];              %append data


%% make a vector of frequencies to use polar()

degreesPerStep = 1.8;   %resolution of stepper
maxDegrees = 360;       %full rotation in degrees

freqs = 0 : 1.8 : 360 - 1.8;
%convert degrees to radians
freqs = freqs * pi /180; 

% %% convert each IR to dB?
% 
% for i = 1:1:size(IR, 2)
%     curIR = IR(:, i); %get all bins in this step
%     curIR = mag2db(curIR);
%     IR(:, i) = curIR;
% end

% %% normalize along bins?
% 
% for i = 1:1:size(IR, 2)
%    curIR = IR(:, i); %all bins in this step
%    curIR = (curIR - min(curIR))/(max(curIR)-min(curIR));
%    IR(:, i) = curIR;
% end

%% normalize along steps?

for i = 1:1:size(IR, 1)
   curBand = IR(i, :); %all steps in this bin
   curBand = (curBand - min(curBand))/(max(curBand)-min(curBand));
   IR(i, :) = curBand;
end


%% get bin resolution and plot

%calculate the bin resolution
binRes = fs/Nfft; 

%We don't actually want to see all the frequencies. Just from 0 to 20k. So
%we need to find that band.

%max frequency
topFreq = 20000; 

%calculate the bin at which we stop animating
stopBin = topFreq/binRes;

figure(1);

for i = 1:1:stopBin
    %get all magnitudes from a single freq band
    polarMags = IR(i, :);
    %use polar to plot it
    polar(freqs, polarMags);
    %display the frequency
    disp(i * binRes);
    %the legend makes the plot jumpy but you can add if you want
    %     %add legend
    %     legend(num2str(binResVec(i)), 'Location','NorthEastOutside')
    %animate 
    pause(0.1);
end










