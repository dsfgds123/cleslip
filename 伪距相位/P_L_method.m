
function [T,data2,s1]=P_L_method(P,L,lamda)
% fig_data=diff(P/lamda-L);
k=1;
data2(1)=P(1)/lamda-L(1);
for i=2:length(L)
    data2(k)=P(i)/lamda-L(i);
    data1(k)=((P(i)-lamda*L(i))-(P(i-1)-lamda*L(i-1)))/lamda;
    d(k)=data1(k);    
    s1(k)=std(d(1:k-1));
    T(k)=(data1(k)-mean(d(1:k-1)));
    if abs(T(k))>4*s1(k)&&abs(T(k))>1
        d(k)=d(k-1);
    end
    k=k+1;
end
end