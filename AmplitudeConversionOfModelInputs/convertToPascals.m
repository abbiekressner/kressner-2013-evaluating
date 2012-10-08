% Function which converts waveforms to Pascals

function out = convertToPascals(in,desired_dB)
    rms = sqrt(mean(in.^2));
    out = (20e-6).*10.^(desired_dB/20).*in./rms;
end
