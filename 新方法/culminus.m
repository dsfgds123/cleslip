function [ data_out ] = culminus( data )

data_out(1)=data(1);
for i=2:length(data)
    data_out(i)=data(i)-data(i-1);
end


end

