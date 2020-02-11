clear all, close all, clc
load sparseDFT.mat

 
figure, hold on
axis([0 1 -3 5])
xlabel('time [s]','interpreter','latex')
ylabel('signal','interpreter','latex')
plot(t,y,'k')
legend('true signal')
waitforbuttonpress

plot(t(ind),y(ind),'bo','markerfacecolor','b','markersize',4)
legend('true signal','sampled data')
waitforbuttonpress


cvx_begin
variable x(100,1) complex
    minimize ( norm(x,1) )
    subject to
    y(ind)==A*x;
cvx_end

waitforbuttonpress
y_recovered=real(ifft(x));

plot(t,y_recovered,'r');
legend('True signal','Samples','Recovered signal')

disp(['RMSE: ' num2str(rms(y-y_recovered))])



waitforbuttonpress
figure,
stem(2*abs(x(1:end/2))/N,'k')