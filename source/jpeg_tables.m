function [r1, r2]=jpeg_tables(Q)
L=load('luminance.dat');
C=load('chrominance.dat');
if Q==50
    r1=L;
    r2=C;
else if (Q<50)
        s=5000/Q;
        r1=round((s*L+50)/100);
        r2=C;
    else
        s=200-2*Q;
        r1=round((s*L+50)/100);
        r2=C;
    end
end
return