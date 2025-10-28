clc; clear; close all;

%% CONFIGURATION
MTOW_SPEC = 70700;      % kg
FUEL_CAP = 4750;        % kg
MAX_PAYLOAD = 23000;    % kg higher than A320Neo as shown by ATI

%% SIZE AIRCRAFT
Aircraft = AircraftSpecsPkg.FZN1E();
Aircraft.Settings.Analysis.Type = +1;  % On-design
Aircraft.Settings.Plotting = 0;
Aircraft.Settings.Table = 0;
[Sized, ~] = Main(Aircraft, @MissionProfilesPkg.A320);

OEW = Sized.Specs.Weight.OEW;
fprintf('FZN-1E OEW: %.0f kg\n\n', OEW);

%% OFF DESIGN ANALYSIS
fprintf('Computing payload-range envelope for FZN-1E hydrogen aircraft...\n');

Sized.Settings.Analysis.Type = -1;     % Off-design
Sized.Specs.Weight.MTOW = MTOW_SPEC;

% Test ranges
ranges_km = 1:100:9000;  % Extended to 9000 km to capture full envelope
n = length(ranges_km);
payloads = zeros(n,1);
fuels = zeros(n,1);

for i = 1:n
    Test = Sized;
    Test.Specs.Performance.Range = ranges_km(i) * 1000;
    
    % Find maximum valid payload
    for payload = MAX_PAYLOAD:-250:0
        Test.Specs.Weight.Payload = payload;
        
        try
            [Result, ~] = Main(Test, @MissionProfilesPkg.NotionalMission00);
            fuel = Result.Mission.History.SI.Weight.Fburn(end);
            
            if (OEW + payload + fuel <= MTOW_SPEC) && (fuel <= FUEL_CAP)
                payloads(i) = payload;
                fuels(i) = fuel;
                break;
            end
        catch
            continue;
        end
    end
    
    if payloads(i) == 0
        % Reached maximum range
        ranges_km = ranges_km(1:i-1);
        payloads = payloads(1:i-1);
        fuels = fuels(1:i-1);
        break;
    end
    
    if mod(ranges_km(i), 1000) == 0
        fprintf('  %4.0f km: %.1f t payload\n', ranges_km(i), payloads(i)/1000);
    end
end

%% PLOT PAYLOAD RANGE DIAGRAM
fprintf('\nGenerating payload-range diagram...\n');

figure('Position', [200, 200, 700, 450], 'Color', 'w');

% FAST FZN-1E curve (computed result) - GREEN like ATI diagram
plot(ranges_km, payloads/1000, '-', 'Color', [0.2, 0.8, 0.2], 'LineWidth', 2);
hold on;

% ATI FZN-1E target line (green curve from ATI payload-range diagram)
% Key points extracted from the diagram:
%   - Max payload: ~23 t at 0 km
%   - Design point: 18.795 t at 2400 nmi (4445 km) 
%   - Ferry range: 0 t at ~4000 nmi (7408 km)
ati_fzn1e_range = [0, 4445, 7408];     % km
ati_fzn1e_payload = [23.0, 18.795, 0]; % tonnes
plot(ati_fzn1e_range, ati_fzn1e_payload, '--', 'Color', [0, 0.4470, 0.7410], ...
     'LineWidth', 1.5);

% Mark the design point
plot(4445, 18.795, 'o', 'Color', [0, 0.4470, 0.7410], ...
     'MarkerSize', 8, 'MarkerFaceColor', [0, 0.4470, 0.7410]);

% Labels
xlabel('Range (km)', 'FontSize', 11);
ylabel('Payload (tonnes)', 'FontSize', 11);
title('FZN-1E Hydrogen Aircraft Payload-Range', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
box on;

% Set axis limits to match ATI diagram
xlim([0, 8000]);  % Extended to show full ferry range
ylim([0, 25]);

% Legend
legend('FAST FZN-1E (Green = H2 Concept)', 'ATI Target', 'Design Point', ...
       'Location', 'northeast', 'FontSize', 10);

