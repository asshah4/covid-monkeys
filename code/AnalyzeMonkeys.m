%% Data intake

% Clear workspace
clear; clc; close all;

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% sample
name = 'sample';

loc = [pwd filesep 'data' filesep name filesep name '.mat'];
raw = load(loc);
ecg = raw.volt;
t = raw.time;
Fs = 250;

%% Set up HRV
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