function  plot_cs( data,lim1,lim2 )
%  画周跳图
% figure;
plot(data);grid on;
hold on;
xlabel('历元数');
ylabel('周跳数');
if nargin>1
    ylim(lim1);
    set(gca,'YTick',lim2);
end


end

