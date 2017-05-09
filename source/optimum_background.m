function [r,val]=optimum_background(boundary)
distance_value_matrix=zeros(size(boundary,4),size(boundary,4));
for m=1:size(boundary,4)
    for n=1:size(boundary,4)
        if n<=m
            distance_value_matrix(m,n)=distance_value_matrix(n,m);
        else
            distance_value_matrix(m,n)=sqrt(sum(sum(sum(boundary(:,:,:,m)-boundary(:,:,:,n)).^2)));
        end
    end
end
distance_value=sum(distance_value_matrix);
loc=find(distance_value==min(distance_value));
r=boundary(:,:,:,loc(1));   %selecting only one out of many possible loc locations
val=min(distance_value);
return