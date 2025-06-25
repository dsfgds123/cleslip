function [ fig_data ] = STPIR_PL_method( P,L,lamda )

fig_data=diff(diff(P/lamda-L));

end

