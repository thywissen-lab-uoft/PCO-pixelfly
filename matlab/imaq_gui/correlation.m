% A correlation function
% Dylan April 2011

function y = correlation(g,h,start,finish,column)


for i=start:finish;
    
    y = g(start:finish,column).*h(start+i:finish+i,column)/(g(start:finish,column).*h(start:finish,column))
    
end

end



