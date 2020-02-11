%normalize
data = data-mean(data);
%median filter
data_filtered=medfilt1(data,filter_coefficient);
%add zeros at beginning and end
if data(1)~=0
    data=[zeros(1,shape_size) data' zeros(1,shape_size)]';
    data_filtered=[zeros(1,shape_size) data_filtered' zeros(1,shape_size)]';
end
figure
plot(data); hold on
plot(data_filtered,'r')
xlabel('Time (sample)')
ylabel('Acceleration (mm/sec^2)')