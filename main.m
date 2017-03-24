tic % Begin measuring time of execution

clear variables

%declare the number of choices of each variable
% BATTERY
batteryChoices = [7, 6, 4];
% MOTOR
motorChoices = [9]; %24 in total, restricting to 9
% PROPELLER
propChoices = [7, 12, 10, 10, 10, 10];
% ROD
rodChoices=[4,11,8];
% ESC
escChoices=[6];

varchoices=[batteryChoices motorChoices propChoices rodChoices escChoices];

%add path of model, function
addpath('C:\Users\Daniel\Documents\GitHub\UAV_MAS_design\QuadrotorModel')
cd('C:\Users\Daniel\Documents\GitHub\UAV_MAS_design\QuadrotorModel')
addpath('C:\Users\Daniel\Documents\GitHub\UAV_MAS_design')
funchandle=@objcfun;

[f_opt,x_opt]=multiagent_opt(funchandle, varchoices)

toc % Return execution time

