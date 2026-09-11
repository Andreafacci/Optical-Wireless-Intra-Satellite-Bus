clc
clear

%% Infrared channel

% Common parameters
r = 0.10;                       % m, transmitter-receiver distance

% IR LED: VSMY1940X01
Ie_IR = 8e-3;                   % W/sr, radiant intensity at selected current (from datasheet)

% Irradiance at the receiver
Ee_IR = Ie_IR / r^2;            % W/m^2

% Irradiance sensitivities at 950 nm
% Units: uA/(mW/cm^2)

SE_VEMD4110 = 2.4;
SE_VEMD6110 = 9.5;
SE_VEMD5110 = 52.5;

% Unit conversion:
% 1 uA/(mW/cm^2) = 100 nA/(W/m^2)

SE_VEMD4110 = SE_VEMD4110 * 100;
SE_VEMD6110 = SE_VEMD6110 * 100;
SE_VEMD5110 = SE_VEMD5110 * 100;

% Estimated photocurrents
Iph_VEMD4110 = SE_VEMD4110 * Ee_IR;   % nA
Iph_VEMD6110 = SE_VEMD6110 * Ee_IR;   % nA
Iph_VEMD5110 = SE_VEMD5110 * Ee_IR;   % nA

% Print results
fprintf('--- INFRARED CHANNEL ---\n');
fprintf('Distance: %.3g m\n', r);
fprintf('LED radiant intensity: %.6g W/sr\n', Ie_IR);
fprintf('Receiver irradiance: %.6g W/m^2\n\n', Ee_IR);

fprintf('VEMD4110X01 photocurrent: %.6g nA\n', ...
    Iph_VEMD4110);

fprintf('VEMD6110X01 photocurrent: %.6g nA\n', ...
    Iph_VEMD6110);

fprintf('VEMD5110X01 photocurrent: %.6g nA\n', ...
    Iph_VEMD5110);

%% Visible channel

% Common parameters
r = 0.10;                    % m, transmitter-receiver distance

% LED: VLMY1301-GS08
% Datasheet luminous intensity at IF = 20 mA
Iv_min_20mA = 71e-3;         % cd
Iv_max_20mA = 180e-3;        % cd

% Estimated relative luminous intensity at pulsed 60 mA
rel_VIS = 2.0;               % approximate factor from datasheet curve

Iv_min = Iv_min_20mA * rel_VIS;
Iv_max = Iv_max_20mA * rel_VIS;

% Photometric-to-radiometric conversion at 590 nm
Km = 683;                    % lm/W
Vlambda = 0.757;             % CIE V(lambda) at 590 nm

Ie_min = Iv_min / (Km * Vlambda);    % W/sr
Ie_max = Iv_max / (Km * Vlambda);    % W/sr

% Irradiance at the receiver
E_min = Ie_min / r^2;        % W/m^2
E_max = Ie_max / r^2;        % W/m^2

% Irradiance sensitivities at 590 nm
% Units: uA/(mW/cm^2)

SE_SFH2240 = 28.1;
SE_SFH2713 = 10.5;
SE_SFH2711 = 0.55;

% Unit conversion:
% 1 uA/(mW/cm^2) = 100 nA/(W/m^2)

SE_SFH2240 = SE_SFH2240 * 100;
SE_SFH2713 = SE_SFH2713 * 100;
SE_SFH2711 = SE_SFH2711 * 100;

% Estimated photocurrents
Iph_SFH2240_min = SE_SFH2240 * E_min;   % nA
Iph_SFH2240_max = SE_SFH2240 * E_max;   % nA

Iph_SFH2713_min = SE_SFH2713 * E_min;   % nA
Iph_SFH2713_max = SE_SFH2713 * E_max;   % nA

Iph_SFH2711_min = SE_SFH2711 * E_min;   % nA
Iph_SFH2711_max = SE_SFH2711 * E_max;   % nA

% Print results
fprintf('--- VISIBLE CHANNEL ---\n');
fprintf('Distance: %.3g m\n', r);
fprintf('Relative LED intensity factor: %.3g\n\n', rel_VIS);

fprintf('LED luminous intensity: %.6g to %.6g cd\n', ...
    Iv_min, Iv_max);

fprintf('LED radiant intensity: %.6g to %.6g W/sr\n', ...
    Ie_min, Ie_max);

fprintf('Receiver irradiance: %.6g to %.6g W/m^2\n\n', ...
    E_min, E_max);

fprintf('SFH 2240 A01 photocurrent: %.6g to %.6g nA\n', ...
    Iph_SFH2240_min, Iph_SFH2240_max);

fprintf('SFH 2713 photocurrent: %.6g to %.6g nA\n', ...
    Iph_SFH2713_min, Iph_SFH2713_max);

fprintf('SFH 2711 A01 photocurrent: %.6g to %.6g nA\n', ...
    Iph_SFH2711_min, Iph_SFH2711_max);


