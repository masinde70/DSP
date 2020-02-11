rng(90)
% making dumy data
y(1,1)=0;
y(2,1)=0;

for k=3:3600
    y(k,1)=0.9*y(k-1,1) + 0.1*y(k-2,1) + 0.01*randn;
end
figure, plot(y)

%% find the trend x
n = length(y);
D = zeros(n-2,n);
for k=1:n-2
    D(k,k:k+2) = [1 -2 1];
end

lambda=1000;
%optimization in cvx (l1-trend filtering)
tic
cvx_begin
variable x(n,1)
    minimize( lambda*norm(D*x,1) + sum_square(y-x) )
cvx_end
toc

% %optimization in cvx (HP-trend filtering)
% lambdaHP = 1000;
% cvx_begin
% variable xHP(n,1)
%     minimize( lambdaHP*sum_square(D*xHP) + sum_square(y-xHP) )
% cvx_end

%optimization in cvx (elastic net)
tic
cvx_begin
variable x3(n,1)
    minimize( lambda*sum_square(D*x3) + lambda*norm(D*x3,1) + sum_square(y-x3) )
cvx_end
toc

%plot results
figure,hold on
plot(y,'k:')
plot(x,'r')
% plot(xHP,'g')
plot(x3,'b')
legend('y','l1-trend','HP-trend','Elastic net')

figure, hold
stem(D*x,'r')
% stem(D*xHP)
stem(D*x3,'b')

% var(y-x)
% var(y-xHP)
