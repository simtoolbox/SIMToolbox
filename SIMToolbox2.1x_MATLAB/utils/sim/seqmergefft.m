function seq = seqmergefft(seq,seq_new)
for I = 1:length(seq)
    seq(I).IMseqFFT = 0.5.*(seq(I).IMseqFFT+seq_new(I).IMseqFFT);
end