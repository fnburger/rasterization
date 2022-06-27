%
% Copyright 2022 TU Wien.
% Institute of Computer Graphics and Algorithms.
%

% main file to start GUI

clc;
clear workspace;
close all;

v = version('-release');

if str2double(v(1:4)) >= 2015
    ViewerUI();
else
    disp('This GUI requires a Matlab version of at least 2015a. If you have an older version, please use the main.m script.');
end
