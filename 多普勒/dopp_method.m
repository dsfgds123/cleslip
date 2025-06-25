function [ fig_data ] = dopp_method( L,D,dt )
% dL=diff(L);
% cal_dopp=-(D+D(2:end))*(dt/2);
len=length(L);
k=1;
for i=2:len
    dL(k)=L(i)-L(i-1);
    cal_D(k)=-(D(i)+D(i-1))*(dt/2);
    fig_data(k)=dL(k)-cal_D(k);
    k=k+1;    
end
end

