%% Data intake

% Clear workspace
clear; clc; close all;

% Add necessary files to path in home folder
addpath(genpath(pwd));
raw_data = [pwd filesep 'data'];
proc_data = [pwd filesep 'data' filesep 'proc_data'];


% Extract raw data
name = 'monkeys';
loc = [raw_data filesep name '.mat'];
raw = load(loc);
EKG = raw.EKG;

% Frequency
Fs = 300;

% Plotting variable
plotting = 0;

%% Loop through data

% original  C structure  with rows corresponding to  lead, and fields:
% {time, volt, lead} with the data included. old machine had 1 lead so
% only 1 row, and the new machine had 7 leads so 7 rows.

% sessionNum C integer of which session it is for that animal.

% categoryName  C animal code

% ext  C file extension for input files, where old machine used xlsx and DFR
% files used png

% EKG(i).original(j).time, EKG(i).original(j).volt, EKG(i).original(j).lead

% Where i = session index 1-19

% j = lead index, 
% where j = 1 if session i = 1-6 = old machine
% j = 1-7 if session i = 7-19 = new machine

% for i = 1:numel(EKG)
%	for j = 1:numel(EKG(i).original)


tstart = tic;

for i = 1:numel(EKG)
	for j = 1:numel(EKG(i).original)
		tloop = tic;
		
		%% Set up 
		
		% New folder for data
		monkey = [num2str(i) '_lead_' EKG(i).original(j).lead];
		mkdir(proc_data, monkey);
		
		% Voltage / ECG signal
		ecg = EKG(i).original(j).volt;
		tm = 0:1/Fs:(length(ecg)-1)/Fs;
		
		%% HRV paramaters
		
		% Set up HRv parameters
		HRVparams = InitializeHRVparams(monkey);
		HRVparams.Fs = Fs; 
		HRVparams.PeakDetect.REF_PERIOD = 0.150;
		HRVparams.preprocess.lowerphysiolim = 60/200;
		HRVparams.preprocess.upperphysiolim = 60/30; 
		HRVparams.increment = 10;
		HRVparams.readdata = [proc_data filesep monkey];
		HRVparams.writedata = [proc_data filesep monkey];
		HRVparams.MSE.on = 0; % No MSE analysis for this demo
		HRVparams.DFA.on = 0; % No DFA analysis for this demo
		HRVparams.HRT.on = 0; % No HRT analysis for this demo
		HRVparams.output.separate = 1; % Write out results per patient
		
		% Clean up newly created files
		movefile([proc_data filesep '*.csv'], [proc_data filesep monkey]);
		movefile([proc_data filesep '*.tex'], [proc_data filesep monkey]);
		
		%% Plot options
		
		% Potentially plot data if wanted (set variable above)
		if plotting == 1
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
			
			% Save it if need be
			savefig(figure(1), [proc_data filesep monkey filesep monkey '.fig']);
		
		end

		%% Run HRV analysis
		[results, resFilenameHRV] = ... 
			Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, monkey);
		
		fprintf('HRV analysis done for %s.\n', monkey);
		toc(tloop)

	end
	
	
end

fprintf('Total Run Time...');
toc(tstart)

