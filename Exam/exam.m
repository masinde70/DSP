function [signals,PC,V] = PCA(X)
% PCA1: Perform PCA using covariance.
% data - MxN matrix of input data
% (M dimensions, N trials)
% signals - MxN matrix of projected data
% PC - each column is a PC
% V - Mx1 matrix of variances
[M,N] = size(X);
% subtract off the mean for each dimension
mn = mean(X,2);
X = X - repmat(mn,1,N);
% calculate the covariance matrix
covariance = 1 / (N-1) * X * X';
% find the eigenvectors and eigenvalues
[PC, V] = eig(covariance);
% extract diagonal of matrix as vector
V = diag(V);
% sort the variances in decreasing order
[junk, rindices] = sort(-1*V);
V = V(rindices);
PC = PC(:,rindices);
% project the original data set
signals = PC' * X;
