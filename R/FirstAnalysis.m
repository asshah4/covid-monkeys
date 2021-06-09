%% Data intake

% Clear workspace
clear; clc; close all;

% Add necessary files to path in home folder
addpath(genpath(pwd));
raw_data = [fileparts(pwd) filesep 'data' filesep 'covid-monkeys'];
proc_data = [pwd filesep 'data' filesep 'proc_data'];

% Extract raw data
name = 'monkeys_03-01-21';
loc = [raw_data filesep name '.mat'];
raw = load(loc);
EKG = raw.EKG;
count = numel(EKG);

% Frequency
Fs = 300;

% Plotting variable
plotting = 0;

% Get names of variables
names = extractfield(EKG, 'categoryName')';
sessions = extractfield(EKG, 'sessionNum')';
recording = 1:count;
T = table(recording', names, sessions, 'VariableNames', {'session', 'names', 'visit'});
writetable(T, 'data/ids.csv');

%% Quality control of monkeys

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

% Problems mainly in monkeys 1:6 the single lead
% 1 = good
% 2 = no data available at all
% 3 = good from 100-280 sec
%EKG(3).original.volt = EKG(3).original.volt(110*Fs:270*Fs);
% 4 = bad throughout, but can salvage some signal from 130 to 500 sec
% Voltage / ECG signal
%EKG(4).original.volt = filloutliers(EKG(4).original.volt(130*Fs:500*Fs), ...
%    'clip', 'movmedian', 3000);
% 5 = need resmampling to remove outlier throughout
%EKG(5).original.volt = filloutliers(EKG(5).original.volt, ...
%    'clip', 'movmedian', 3000);
% 6 = cut poor signal, good from ~ 150 to 575 sec with resampling
%EKG(6).original.volt = filloutliers(EKG(6).original.volt(150*Fs:575*Fs), ...
%    'spline');


%% Loop through data for single lead data

tstart = tic;

% Single lead data
for i = 1:6
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
        HRVparams.PeakDetect.REF_PERIOD = 0.250;
        HRVparams.PeakDetect.THRES = .5;    
        HRVparams.preprocess.lowerphysiolim = 60/240;
        HRVparams.preprocess.upperphysiolim = 60/30; 
        HRVparams.windowlength = 30;	      % Default: 300, seconds
        HRVparams.increment = 30;             % Default: 30, seconds increment
        HRVparams.numsegs = 5;                % Default: 5, number of segments to collect with lowest HR
        HRVparams.RejectionThreshold = .25;   % Default: 0.2, amount (%) of data that can be rejected before a
        HRVparams.MissingDataThreshold = .25;
        HRVparams.increment = 10;
        HRVparams.sqi.LowQualityThreshold = 0.50;
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
            h = figure("Visible", true);
			plot(tm,ecg);
			xlabel('[s]');
			ylabel('[mV]');
			r_peaks = jqrs(ecg, HRVparams);

			% plot the detected r_peaks on the top of the ecg signal
			hold on;
			plot(r_peaks./Fs, ecg(r_peaks),'o');
			legend('ecg signal', 'detected R peaks');
			
			% Save it if need be
			saveas(h, [proc_data filesep monkey filesep monkey '.fig']);
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

%% Multilead lead data

tstart = tic;

for i = 7:numel(EKG)
	for j = 1:numel(EKG(i).resample)
		tloop = tic;
		
		%% Set up 
		
		% New folder for data
		monkey = [num2str(i) '_lead_' EKG(i).resample(j).lead];
		mkdir(proc_data, monkey);
		
		% Voltage / ECG signal
		ecg = EKG(i).resample(j).volt;
		tm = 0:1/Fs:(length(ecg)-1)/Fs;
		
		%% HRV paramaters
		
		% Set up HRv parameters
		HRVparams = InitializeHRVparams(monkey);
        HRVparams.Fs = Fs; 
        HRVparams.PeakDetect.REF_PERIOD = 0.250;
        HRVparams.PeakDetect.THRES = .6;    
        HRVparams.preprocess.lowerphysiolim = 60/240;
        HRVparams.preprocess.upperphysiolim = 60/30; 
        HRVparams.windowlength = 120;	      % Default: 300, seconds
        HRVparams.increment = 30;             % Default: 30, seconds increment
        HRVparams.numsegs = 5;                % Default: 5, number of segments to collect with lowest HR
        HRVparams.RejectionThreshold = .20;   % Default: 0.2, amount (%) of data that can be rejected before a
        HRVparams.MissingDataThreshold = .15;
        HRVparams.sqi.LowQualityThreshold = 0.75;
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
            h = figure("Visible", true);
			plot(tm,ecg);
			xlabel('[s]');
			ylabel('[mV]');
			r_peaks = jqrs(ecg, HRVparams);

			% plot the detected r_peaks on the top of the ecg signal
			hold on;
			plot(r_peaks./Fs, ecg(r_peaks),'o');
			legend('ecg signal', 'detected R peaks');
			
			% Save it if need be
			saveas(h, [proc_data filesep monkey filesep monkey '.fig']);
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

%% Single patient run

% New folder for data
i = 6;
j = 1;
monkey = [num2str(i) '_lead_' EKG(i).original(j).lead];

mkdir(proc_data, monkey);

% Voltage / ECG signal
ecg = EKG(i).original(j).volt;
tm = 0:1/Fs:(length(ecg)-1)/Fs;


% Set up HRv parameters
HRVparams = InitializeHRVparams(monkey);
HRVparams.Fs = Fs; 
HRVparams.PeakDetect.REF_PERIOD = 0.250;
HRVparams.PeakDetect.THRES = .7;    
HRVparams.preprocess.lowerphysiolim = 60/240;
HRVparams.preprocess.upperphysiolim = 60/30; 
HRVparams.windowlength = 30;	      % Default: 300, seconds
HRVparams.increment = 30;             % Default: 30, seconds increment
HRVparams.numsegs = 5;                % Default: 5, number of segments to collect with lowest HR
HRVparams.RejectionThreshold = .30;   % Default: 0.2, amount (%) of data that can be rejected before a
HRVparams.MissingDataThreshold = .15;
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

% Plot
figure(1)
plot(tm, ecg);
xlabel('[s]');
ylabel('[mV]');
r_peaks = jqrs(ecg, HRVparams);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

% Run HRV analysis
[results, resFilenameHRV] = ... 
    Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, monkey);