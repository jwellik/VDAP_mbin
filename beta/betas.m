function [betas]=betas(Na,N,Ta,T)
% BETAS Equation for beta statistic
%   betas=(Na-N*(Ta/T))/sqrt(N*(Ta/T)*(1-(Ta/T)));
%
% INPUT
% Na    : events in window of interest
% N     : events in entire time period
% Ta    : length of time of interest
% T     : length of entire time period

betas=(Na-N*(Ta/T))/sqrt(N*(Ta/T)*(1-(Ta/T)));
