function r=compress(I,key,L1,C1,L2,C2)
%*1 for salient
%*2 for non-salient


R=I(:,:,1);
G=I(:,:,2);
B=I(:,:,3);

%colorspce conversion
Y=(77/256)*R+(150/256)*G+(29/256)*B;
Cb= -1*(44/256)*R-(87/256)*G+(131/256)*B+128;
Cr= (131/256)*R-(110/256)*G-(21/256)*B+128;

%Dct and quantization
if key==0;
    d1=dct2(Y)./L2;
    d2=dct2(Cb)./C2;
    d3=dct2(Cr)./C2;
    d1=round(d1);
    d2=round(d2);
    d3=round(d3);
else 
    d1=dct2(Y)./L1;
    d2=dct2(Cb)./C1;
    d3=dct2(Cr)./C1;
    d1=round(d1);
    d2=round(d2);
    d3=round(d3);
end
r=cat(3,d1,d2,d3);
return