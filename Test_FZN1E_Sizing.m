clc; clear; close all;

fprintf('========================================\n');
fprintf('FZN-1E Sizing Verification\n');
fprintf('========================================\n\n');

% Load the FZN-1E configuration
Aircraft = AircraftSpecsPkg.FZN1E();

% Set to on design mode for sizing
Aircraft.Settings.Analysis.Type = +1;  % On-design (sizing mode)
Aircraft.Settings.Plotting = 0;  % Turn off plots for now
Aircraft.Settings.Table = 0;  % Generate mission history table

% Run the sizing analysis using the A320 mission profile
[SizedAircraft, MissionHistory] = Main(Aircraft, @MissionProfilesPkg.A320);

% Display results
fprintf('FAST SIZING RESULTS:\n');
fprintf('--------------------\n');
fprintf('MTOW:           %.0f kg\n', SizedAircraft.Specs.Weight.MTOW);
fprintf('OEW:            %.0f kg\n', SizedAircraft.Specs.Weight.OEW);
fprintf('Fuel Weight:    %.0f kg\n', SizedAircraft.Specs.Weight.Fuel);
fprintf('Payload:        %.0f kg\n', SizedAircraft.Specs.Weight.Payload);
fprintf('Design Range:   %.0f km (%.0f nm)\n', SizedAircraft.Specs.Performance.Range/1000, SizedAircraft.Specs.Performance.Range/1852);
