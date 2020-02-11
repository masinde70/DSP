%Main function, reads 1D data vector "data"
%
%clear "trained" shapes
clear t1 t2 t1_new t2_new tw1 tw2
%pick right column
%data=data(:,1);
%number of runs, if runs=1, then batch mode least squares fit
runs=5;
%direction of profile, positive or negative
direction=1;
%define shape size
shape_size=50;
%define peak detection threshold (0-1)
peak_threshold=0.5;
%length of median filter window
filter_coefficient=1;
%use filtered data for alignment
use_filtered=0;

%run
tic
%pre-process data to remove peaks, creates data and data_filtered vectors
filterdata
%align
for j=1:runs
    align
end
toc

figure
plot(all_profiles');
title('All detected profiles');
figure
plot(all_features(:,5),'x')
title('Profile matches (correlation)');