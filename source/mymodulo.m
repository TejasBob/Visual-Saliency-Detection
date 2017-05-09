%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%( A^B )mod n %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This program obtains (no1^no2)mod n 
%%% Inputs: n01, no2,n
%%% outputs: modulofinal
%%% this algorithm initially multiplies 1 with no1. It then finds square of
%%% previous results resulting incomputational efficiency. Finally the
%%% algorithm adds only those squarematrix terms which are indicated as "1"
%%% in corresponding no2 matrix ib binary format.
%% Program uses binary modulo method




function[modulofinal]=mymodulo(no1,no2,n)

% clc;
% close all;
% clear all;
% no1=input('enter number 1=_');
% no2=input('enter number 2=_');
% n=input('enter number n=_');
binno2=dec2bin(no2);
result=ones(size(binno2));
i=length(binno2);
pow=1;
while i>=1;
  squarematrix(i)=no1^pow;
  squarematrix(i)=mod(squarematrix(i),n);
  no1=squarematrix(i);
  pow=2;
  i=i-1;
end

modulofinal=1;
for i=1:length(binno2)
    if binno2(i)=='1'     % i represented in single quotes so as not to be confused with 1 in ASCII
        modulofinal=modulofinal*squarematrix(i);
        modulofinal=mod(modulofinal,n);
    end
end

 %modulofinal
