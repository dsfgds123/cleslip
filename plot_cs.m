function  plot_cs( data,lim1,lim2 )
%  ������ͼ
% figure;
plot(data);grid on;
hold on;
xlabel('��Ԫ��');
ylabel('������');
if nargin>1
    ylim(lim1);
    set(gca,'YTick',lim2);
end


end

