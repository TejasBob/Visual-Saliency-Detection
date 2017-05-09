function r=decode_jpeg(I,key,L1,C1,L2,C2)
%*1 for salient
%*2 for non-salient

d1=I(:,:,1);
d2=I(:,:,2);
d3=I(:,:,3);
if key==0
    Y2=idct2(d1.*L2);
    Cb2=idct2(d2.*C2);
    Cr2=idct2(d3.*C2);
    R2=Y2+1.371*(Cr2-128);
    G2=Y2-0.698*(Cr2-128)-0.336*(Cb2-128);
    B2=Y2+1.732*(Cb2-128);
else 
    Y2=idct2(d1.*L1);
    Cb2=idct2(d2.*C1);
    Cr2=idct2(d3.*C1);
    R2=Y2+1.371*(Cr2-128);
    G2=Y2-0.698*(Cr2-128)-0.336*(Cb2-128);
    B2=Y2+1.732*(Cb2-128);
end

r=cat(3,R2,G2,B2);
return
