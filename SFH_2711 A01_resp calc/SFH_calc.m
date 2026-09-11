clc
clear
close all

%% SFH 2711 A01 responsivity reconstruction
%
% This script reconstructs the absolute responsivity R(lambda) [A/W]
% from:
%   1. Datasheet photometric sensitivity in nA/lx
%   2. Photodiode active area
%   3. Relative spectral-sensitivity curve
%   4. CIE Standard Illuminant A spectrum
%   5. CIE photopic luminous-efficiency function V(lambda)
%
% The result of interest is R(590 nm).

%% Datasheet parameters

Sv = 0.115e-9;       % A/lx, typical sensitivity under Illuminant A
A_PD = 0.35e-6;      % m^2, radiant-sensitive area
Km = 683;            % lm/W, maximum photopic luminous efficacy

lambda_target = 590; % nm


%% Load official CIE data
%
% Expected files:
%   CIE_std_illum_A_1nm.csv
%   CIE_sle_photopic.csv
%
% Both files should contain:
%   column 1: wavelength in nm
%   column 2: relative spectral value

illumA_data = readmatrix('CIE_std_illum_A_1nm.csv');
Vlambda_data = readmatrix('CIE_sle_photopic.csv');

lambda_A = illumA_data(:,1);
SPD_A = illumA_data(:,2);

lambda_V = Vlambda_data(:,1);
Vlambda = Vlambda_data(:,2);


%% SFH 2711 A01 relative-sensitivity curve
% sampled points from datasheet relative sensitivity at lamda[nm] in %
curve=[
    470    20
    480    35
    490    55
    500    65
    510    70
    520    72
    530    73
    540    75
    550    80
    560    85
    570    97
    580    100
    590    95
    600    93
    610    85
    620    75
    630    63
    640    50
    650    38
    660    26
    670    18
    ];

lambda_PD = curve(:,1);

Srel_PD = curve(:,2);


% Normalize to a maximum relative sensitivity of one
Srel_PD = Srel_PD / max(Srel_PD);


%% Establish a common wavelength grid

lambda_min = max([min(lambda_A), min(lambda_V), min(lambda_PD)]);
lambda_max = min([max(lambda_A), max(lambda_V), max(lambda_PD)]);

lambda = (ceil(lambda_min):1:floor(lambda_max)).';


%% Interpolate all spectral quantities onto the common grid

SPD_A_i = interp1(lambda_A, SPD_A, lambda, 'linear');
Vlambda_i = interp1(lambda_V, Vlambda, lambda, 'linear');

% PCHIP generally follows a digitized smooth curve better than linear
% interpolation without introducing excessive oscillation.
Srel_i = interp1(lambda_PD, Srel_PD, lambda, 'pchip');

% Prevent small negative values caused by interpolation
Srel_i(Srel_i < 0) = 0;


%% Spectral calibration
%
% Photometric sensitivity:
%
%             A_PD * integral[R(lambda) * E_A(lambda) dlambda]
%   Sv = -----------------------------------------------------------
%          683 * integral[V(lambda) * E_A(lambda) dlambda]
%
% Define:
%
%   R(lambda) = K * Srel(lambda)
%
% Then:
%
%        Sv * 683 * integral[V(lambda) * E_A(lambda) dlambda]
%   K = -------------------------------------------------------------
%        A_PD * integral[Srel(lambda) * E_A(lambda) dlambda]
%
% Because Illuminant A is used in both integrals, its arbitrary
% normalization cancels.

photopic_integral = trapz(lambda, Vlambda_i .* SPD_A_i);

detector_integral = trapz(lambda, Srel_i .* SPD_A_i);

K = Sv * Km * photopic_integral / (A_PD * detector_integral);


%% Reconstructed responsivity

Rlambda = K .* Srel_i;

R_target = interp1(lambda, Rlambda, lambda_target, 'pchip');


%% Verification against the datasheet sensitivity

I_per_scale = A_PD * trapz(lambda , Rlambda .* SPD_A_i);

Ev_per_scale = Km * trapz(lambda, Vlambda_i .* SPD_A_i);

Sv_check = I_per_scale / Ev_per_scale;


%% Print results

fprintf('--- SFH 2711 A01 ---\n');
fprintf('Active area: %.4g mm^2\n', A_PD * 1e6);
fprintf('Datasheet sensitivity: %.4g nA/lx\n', Sv * 1e9);
fprintf('Reconstructed sensitivity: %.4g nA/lx\n', ...
    Sv_check * 1e9);
fprintf('Responsivity at %.0f nm: %.4g A/W\n', ...
    lambda_target, R_target);
fprintf('Peak reconstructed responsivity: %.4g A/W\n', ...
    max(Rlambda));


%% Plot the reconstructed response

figure

yyaxis left
plot(lambda, Rlambda, 'LineWidth', 1.5)
ylabel('Responsivity (A/W)')

yyaxis right
plot(lambda, SPD_A_i ./ max(SPD_A_i), 'LineWidth', 1.2)
ylabel('Normalized Illuminant A spectrum')

xlabel('Wavelength (nm)')
title('SFH 2711 A01 reconstructed responsivity')
grid on
xline(lambda_target, '--', '590 nm')