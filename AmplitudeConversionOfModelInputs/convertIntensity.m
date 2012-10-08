function output = convertIntensity(input, SPLdesired)

% function output = convertIntensity(input, SPLdesired)
%
% Scaling code adapted from Timoney2004

Pref = 20e-6; 
output= input./Pref; 
RMS=sqrt(mean(output.^2)); 
SPLmatlab=20.*log10(RMS); % current dB SPL
output = output*diag(10.^((SPLdesired-SPLmatlab)./20));
