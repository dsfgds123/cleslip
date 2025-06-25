function [csdata]=addcs(data,n,t,f)%¼ÓÖÜÌø

for i=1:size(data,1)
    if i==f
        csdata(i,:)=[data(i,1:t-1),data(i,t:end)+n];
    end
end

end