%% Data intake

% Clear workspace
clear; clc; close all;

% Add necessary files to path in home folder
addpath(genpath(pwd));

% Extract raw data
name = 'monkeys';
loc = [pwd filesep 'data' filesep name '.mat'];
raw = load(loc);




%% Set up HRV

% Frequency
Fs = 300;

HRVparams = InitializeHRVparams(name);
HRVparams.Fs = Fs; 
HRVparams.PeakDetect.REF_PERIOD = 0.150;
HRVparams.preprocess.lowerphysiolim = 60/200;
HRVparams.preprocess.upperphysiolim = 60/30; 
HRVparams.readdata = [pwd filesep 'data' filesep name];
HRVparams.writedata = [pwd filesep 'data' filesep name];
HRVparams.MSE.on = 0; % No MSE analysis for this demo
HRVparams.DFA.on = 0; % No DFA analysis for this demo
HRVparams.HRT.on = 0; % No HRT analysis for this demo
HRVparams.output.separate = 1; % Write out results per patient

%% Plot
tm = 0:1/Fs:(length(ecg)-1)/Fs;
% plot the signal
figure(1);
plot(tm,ecg);
xlabel('[s]');
ylabel('[mV]');

r_peaks = jqrs(ecg, HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

%% Run the HRV analysis
[results, resFilenameHRV] = ...
  Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, name);