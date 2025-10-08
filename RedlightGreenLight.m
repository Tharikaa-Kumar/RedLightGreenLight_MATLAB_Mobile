%% Red Light, Green Light Balance Test
close all; clc; clear;

disp('==============================================');
disp('  WELCOME TO THE RED LIGHT, GREEN LIGHT');
disp('       BALANCE CHALLENGE!');
disp('==============================================');
disp('Hold the phone firmly against your chest or torso.');
disp(' ');
disp('PHYSICS: Try to keep your net acceleration as close to zero as possible!');
disp('a = dv/dt (acceleration is the rate of change of velocity)');
disp(' ');

%% 1. Connect to mobile device and check sensor
m = mobiledev;
m.AccelerationSensorEnabled = 1;
while ~m.AccelerationSensorEnabled
    warning('Acceleration sensor is NOT enabled in MATLAB Mobile app!');
    disp('Please:');
    disp('  1. Open MATLAB Mobile on your phone.');
    disp('  2. Go to the Sensors tab.');
    disp('  3. Enable the Acceleration sensor.');
    disp('Press any key to check again...');
    pause;
    m = mobiledev; % Re-acquire in case settings changed
end
disp('Acceleration sensor is enabled! Starting test...');
disp(' ');

%% 2. Start logging
m.Logging = 1;
pause(0.2);

disp('=======================');
disp('      GREEN LIGHT!');
disp('=======================');
disp('Move around for 5 seconds...');
disp(' ');

pause(5);

disp('=======================');
disp('       RED LIGHT!');
disp('=======================');
disp('Freeze and stay as still as possible for 5 seconds...');
disp(' ');

pause(5);

%% 3. Stop logging
m.Logging = 0;

%% 4. Get logged acceleration data
[accelData, timestamp] = accellog(m);

if isempty(accelData)
    disp('No acceleration data was recorded. Please try again.');
    return;
end
m.AccelerationSensorEnabled = 0;

% Normalize timestamp to start at zero
timestamp = timestamp - timestamp(1);

%% 5. Calculate movement (remove gravity, use only RED LIGHT)
% Indices for RED LIGHT (5s to 10s)
red_idx = (timestamp >= 5);

% Gravity vector estimated from RED LIGHT phase
gravity = mean(accelData(red_idx, :), 1);

% Remove gravity from all samples
accelNoGravity = accelData - gravity;

% Net "wiggle" acceleration (magnitude)
netAccel = sqrt(sum(accelNoGravity.^2, 2));

% Only average during RED LIGHT
mean_movement = mean(netAccel(red_idx));

%% 6. Display result
disp('---------------------------------------------');
disp('                     RESULTS');
disp('---------------------------------------------');
fprintf('Your average net movement (acceleration, gravity removed, during RED LIGHT): \n');
fprintf('   %.3f m/s^2\n', mean_movement);

if mean_movement < 0.12
    disp('Excellent! You stayed very still. Great balance! 🟢');
elseif mean_movement < 0.25
    disp('Good job! You moved a little, but still balanced well. 🟡');
else
    disp('You moved quite a bit! Try to stay more still next time. 🔴');
end
disp(' ');

%% 7. Clean, Mobile-Friendly Plot: Net Acceleration Magnitude Only

figure('Color','w','Position',[100 100 350 300]);
plot(timestamp, netAccel, 'b-', 'LineWidth', 2);
hold on

% Shade RED LIGHT phase
yl = ylim;
fill([5 10 10 5], [yl(1) yl(1) yl(2) yl(2)], [1 0.8 0.8], ...
    'EdgeColor','none','FaceAlpha',0.4);

% Mark red light period with dashed lines
plot([5 5], yl, 'r--', 'LineWidth', 1);
plot([10 10], yl, 'r--', 'LineWidth', 1);

hold off
xlabel('Time (s)','FontWeight','bold','FontSize',12)
ylabel('Net Acceleration (m/s^2)','FontWeight','bold','FontSize',12)
title('Your Movement During the Test','FontWeight','bold','FontSize',13)
text(7.5, yl(2)*0.9, 'RED LIGHT', 'Color','r','FontWeight','bold','FontSize',11, ...
    'HorizontalAlignment','center','BackgroundColor','none')
text(2.5, yl(2)*0.9, 'GREEN LIGHT', 'Color',[0 0.5 0],'FontWeight','bold','FontSize',11, ...
    'HorizontalAlignment','center','BackgroundColor','none')
grid on
set(gca,'FontSize',12)

%% 8. Physics Reflection
disp('--------------------------------------------');
disp('                PHYSICS REFLECTION');
disp('--------------------------------------------');
disp('Acceleration is the rate of change of velocity:');
disp('    a = dv/dt');
disp('When you are perfectly still, your net acceleration (excluding gravity) is zero.');
disp('Any movement, sway, or fidgeting increases your net acceleration.');
disp(' ');
disp('How to improve balance:');
disp('- Lower your center of mass (bend your knees)');
disp('- Widen your base of support (spread your feet)');
disp('- Focus your eyes on a fixed point to reduce sway');
disp('- Engage your core muscles for stability');
disp(' ');
disp('In this test, the "Red Light" phase is when you should minimize your movement.');
disp('The plot shows your net acceleration (gravity removed) throughout the test.');
disp('A lower net acceleration during "Red Light" means better balance!');
disp(' ');
disp('Thanks for playing the Balance Challenge!');
disp('===============================================');

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
