clear y_min
clear y2_min
clear y_max
clear y2_max
clear y_idx
clear y2_idx
clear y_idx_max
clear y2_idx_max
clear sum_y
clear sum_y2
clear y_mat
clear y2_mat
clear sign_mat
clear x1_mat
clear x2_mat
clear x3_mat
clear y
clear y2
clear peak
clear all_profiles
clear all_features
clear signmat1
clear signmat2
clear up_profiles
clear down_profiles

peaks_per_movement=1;
align_window=shape_size;
%shape_size=1600;
learning_coefficient=0.5;
startstop=1;
init_with_dtw=0;
multi=0;
threshold=4500;

if use_filtered==1
    data=data_filtered;
end

if ~exist('t1_new','var')
    shape1_size=shape_size;
end

Fs = shape_size;   % Sampling frequency
%t = -0.5:1/Fs:0.5-1/Fs;  % Time vector 
t = (0:1/Fs:1-1/Fs);     % seconds
L = length(t);      % Signal length

accel = prctile(abs(data_filtered),99)*(-0.5*cos(2*pi*t)+0.5);

t1=direction*accel;
if exist('t1_new','var')
    t1=t1_new;
end

temp=peak_threshold*prctile(abs(data_filtered), 99);

i=1;
j=1;
while i<length(data)
    i;

    window_size=1;
    n=0;
    %detect peaks inside window
    while i+window_size+shape_size/2<length(data)
       if direction*data_filtered(i+window_size)>temp && i+window_size>shape_size/2 && abs(data_filtered(i+window_size))==max(abs(data_filtered(i+window_size-shape_size/2:i+window_size+shape_size/2)))
           n=n+1;
           peak(j,n)=i+window_size;
           window_size=window_size+shape_size/2;
       else
           window_size=window_size+1;
       end
       if n>=peaks_per_movement
           break
       end
    end    
    if n<1
        break
    end    
    if i+align_window > length(data)
        break;
    end    
    %batch l2 align
    s=1;
    sum_y=[];
    p=0;
    for k = peak(j,1)-align_window:peak(j,1)
        if k<1 || k+p > length(data)
            continue
        end
        for p = 1:length(t1)
            y(p) = (t1(p)-data(k+p))^2;
        end
        sum_y(s)=sum(y);
        s=s+1;
    end
    [best,idx]=min(sum_y);
    %align=idx+1;

    [y_min(j),y_idx(j)]=min(sum_y);
    y_idx(j)=y_idx(j)+peak(j,1)-align_window;
    [y_max(j),y_idx_max(j)]=max(sum_y);
    y_idx_max(j)=y_idx_max(j)+i;
    
    i=i+window_size;
    j=j+1;
end
peak
fprintf('%d movements detected\n',length(peak));

for i=1:length(y_idx)
    y_mat(i,1:shape1_size)=data(y_idx(i):y_idx(i)+shape1_size-1)';
end

y_mean=mean(y_mat);

%lst2clu = {'s','ca1','ca3','ca6'};
%S = mdwtcluster(y_mat,'maxclust',2,'lst2clu',lst2clu);
%IdxCLU = S.IdxCLU;

%if multi==1
%    class1=IdxCLU(1,1);
%    class2=IdxCLU(length(y_mat(:,1)),1);
%    y_mean=mean(y_mat(IdxCLU(:,1)==class1,:));
%end

%error=data(align:align+length(t1)-1)-t1;
error=y_mean-t1;

cutoff=10;
error_fft=fft(error);
%FILTER HIGH FREQUENCIES
%error_fft_low=[error_fft(1:cutoff) zeros(1,(length(error_fft)-cutoff*2+1)) error_fft(length(error_fft)-cutoff+2:length(error_fft))];

fft_orig=fft(t1);
%LEARNING
fft_new=fft_orig+learning_coefficient*error_fft;
t1_new=ifft(fft_new);

if runs==1
    t1_new=y_mean;
end

%PROFILE FEATURE MATRIX
count=1;
for i=1:length(y_idx)
    all_profiles(count,:)=y_mat(i,:);
    count=count+1;
end

%KPI FEATURE MATRIX
for i=1:length(y_idx)
    all_features(i,:)=[min(y_mat(i,:)) max(y_mat(i,:)) mean(y_mat(i,:)) trapz(y_mat(i,:))/1000 xcorr(y_mat(i,:),y_mean,0,'coeff') prctile(y_mat(i,:),95) sum(y_mat(i,:)>prctile(y_mat(i,:),5),2)];
end

reference_profile=t1;

fprintf('%f percent profile matching\n',mean(all_features(:,5))*100);

%cluster_data

figure
plot(t1)
hold on
plot(t1_new,'r');
title('Reference vs averaged profile')