% lap time thing for a 2018 nissan altima 2.5 sr
% not perfect physics but it gives a velocity vs distance graph

clear
clc
close all

disp("2018 Nissan Altima 2.5 SR lap time simulator")

% car stuff, approximate values
m = 1470;              % mass in kg, around 3200 lb
hp = 179;              % horsepower
P = hp * 745.7;        % watts
mu = 0.92;             % street tires
g = 9.81;

Cd = 0.29;             % drag coefficient
A = 2.25;              % frontal area
rho = 1.225;
Crr = 0.014;

FdriveMax = 3600;      % not exact, just a reasonable tire/engine force
Fbrake = 9000;         % braking force
vmax = 58;             % m/s, about 130 mph

% made up simple track
% inf means straight, numbers are turn radius in meters
partLen = [200 60 160 75 250 90 180 55 220];
turnRad = [inf 45 inf 30 inf 60 inf 35 inf];

ds = 1;
trackLen = sum(partLen);
s = 0:ds:trackLen;
n = length(s);

rad = inf * ones(1,n);

spot = 0;
for j = 1:length(partLen)
    spot2 = spot + partLen(j);

    for i = 1:n
        if s(i) >= spot && s(i) <= spot2
            rad(i) = turnRad(j);
        end
    end

    spot = spot2;
end

% speed limit from corners
lim = vmax * ones(1,n);

for i = 1:n
    if isfinite(rad(i))
        lim(i) = sqrt(mu*g*rad(i));
    end
end

v = zeros(1,n);

% first go forward and accelerate
for i = 1:n-1
    if v(i) < 1
        nowv = 1;
    else
        nowv = v(i);
    end

    % engine force from power
    Fpower = P / nowv;

    if Fpower > FdriveMax
        Fengine = FdriveMax;
    else
        Fengine = Fpower;
    end

    Fdrag = 0.5*rho*Cd*A*nowv^2;
    Froll = Crr*m*g;

    accel = (Fengine - Fdrag - Froll)/m;

    if accel < 0
        accel = 0;
    end

    newv = sqrt(v(i)^2 + 2*accel*ds);

    if newv > lim(i+1)
        v(i+1) = lim(i+1);
    else
        v(i+1) = newv;
    end
end

% now go backwards so it brakes before corners
for i = n-1:-1:1
    nextv = v(i+1);

    if nextv < 1
        nextv = 1;
    end

    Fdrag = 0.5*rho*Cd*A*nextv^2;
    Froll = Crr*m*g;

    brakeAccel = (Fbrake + Fdrag + Froll)/m;

    canBe = sqrt(nextv^2 + 2*brakeAccel*ds);

    if v(i) > canBe
        v(i) = canBe;
    end
end

% get lap time
time = 0;

for i = 1:n-1
    avgv = (v(i)+v(i+1))/2;

    if avgv < 0.1
        avgv = 0.1;
    end

    time = time + ds/avgv;
end

% plot
figure(1)
plot(s, v*2.23694, "b", "linewidth", 2)
grid on
xlabel("Distance around track (m)")
ylabel("Speed (mph)")
title("2018 Nissan Altima 2.5 SR Lap Time Simulator")

fprintf("\nResults for 2018 Nissan Altima 2.5 SR\n")
fprintf("Track length: %.0f meters\n", trackLen)
fprintf("Lap time: %.2f seconds\n", time)
fprintf("Top speed: %.1f mph\n", max(v)*2.23694)
fprintf("Average speed: %.1f mph\n", (trackLen/time)*2.23694)

drawnow
