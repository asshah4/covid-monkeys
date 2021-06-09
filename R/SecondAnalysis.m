%% Analysis of March 2021 Monkeys

% Notes from Steve
%{ 

A few points:
1) There were 12 animals tested in 2-3 sessions each (sessions on days 0, 4, 7). There were 30 EKG sessions in total across the 12 animals. All
animals got COVID, and 6 were also treated with a type I interferon antagonist that was supposed to worsen the phenotype of the animals. The idea was
to create a model of severe COVID for NIH. All animals were infected between the first and second sessions, I think on day 2 (i.e. 2 days after the
baseline EKG session), but I am not positive. Dr. Levit, can you clarify infection timing?

2) Several of the EKG sessions this time were split into 2 or 3 parts a few minutes apart for some reason. That leads to a few of these having long
segments with no data or just a line between points.

3) Data is organized as a structure within the .MAT file in the EKG variable according to session "j" and EKG lead "k":
EKG(j).categoryName = animal name for session j
EKG(j).categoryNum = artificial number that corresponds to the particular animal for session j
EKG(j).timePoint = a duration variable that shows when session j occurred compared to the first session for that animal
EKG(j).sessionNum = session number for a particular animal (1, 2, or 3) corresponding to the session days (0,4,7)

EKG(j).resample(k) = substructure containing the EKG time and voltage data for lead k
-- Note: The first four sessions (j = 1:4) only collected data for lead II, so there is only k =1 for those sessions.

EKG(j).resample(k).lead = character array indicating the lead for data in (k = 1:7). Leads collected were (I, II, III, aVF, aVR, aVL, Vx).
EKG(j).resample(k).leadNum = number corresponding to the lead, from 1:7
EKG(j).resample(1).time = vector of times, at frequency 300 Hz.
-- Note: Since the time vectors are the same for each lead k within a session j, the time vector is only included in lead k = 1. EKG(j).resample(k =
2:7).time = [] to avoid duplication, since that dramatically reduces the file size. If you would like, I can upload a larger file that duplicates the
time into each lead so you can call along with the voltage.
EKG(j).resample(k).volt = vector of voltages for session j / lead k, indexed the same as the time vector at 300 Hz

4) We will need to get more information from Dr. Levit / Michael for the clinical scores at each time point, and for which animals corresponded to
which group, so we can see if this actually created a more severe phenotype that we can detect with HRV changes.
%}

%% Set up workspace
% Clear workspace
clear; clc; close all;

% Add necessary files to path in home folder
% Must be in github directory level
addpath(genpath(pwd));
raw_data = [fileparts(fileparts(pwd)) filesep 'data' filesep 'covid-monkeys'];
proc_data = [raw_data filesep 'proc_data' filesep 'second_analysis'];

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
writetable(T, [raw_data filesep 'ids-march-2021.csv']);

%% Single Animal Run

% Monkey picked
i = 1;
j = 1;
k = 1;

monkey = [num2str(i) '_lead_' EKG(i).resample(j).lead];
mkdir(proc_data, monkey);

% Voltage / ECG signal
ecg = EKG(i).resample(j).volt;
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
movefile(['data' filesep 'proc_data' filesep '*.csv'], [proc_data filesep monkey]);
movefile(['data' filesep 'proc_data' filesep '*.tex'], [proc_data filesep monkey]);

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

%% Run All Monkeys

tstart = tic;

for i = 1:count
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
		movefile(['data' filesep 'proc_data' filesep '*.csv'], [proc_data filesep monkey]);
        movefile(['data' filesep 'proc_data' filesep '*.tex'], [proc_data filesep monkey]);
		
		%% Plot options
		
		% Potentially plot data if wanted (set variable above)
		if plotting == 1
			% plot the signal
            h = figure("Visible", true);
			plot(tm,ecg);
			xlabel('[s]');
			ylabel('[mV]');
			r_peaks = jqrs(ecg, HRVparams);

			% Plot the detected r_peaks on the top of the ecg signal
			hold on;
			plot(r_peaks./Fs, ecg(r_peaks),'o');
			legend('ecg signal', 'detected R peaks');
			
			% Save
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
