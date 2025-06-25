function [ data_out ] = samp( data,gap )
%  改变数据采样间隔
%  data:原始数据
%  gap:采样间隔
data_out=data(1:gap:end);

end

