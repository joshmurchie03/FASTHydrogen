function [Aircraft] = FZN1E()
% ========================================================================
% Again this FZN1E file is pretty much a carbon copy of the provided
% A320Neo file within FAST with changed thrust and specific energy of the
% fuel being used. EIS is being kept at 2016 rather than say 2050 for
% example to prevent FAST from predicting unrealistic aircraft specs.
% ========================================================================
%
%
% [Aircraft] = FZN1E()
% written by Josh Murchie, 2500573M@student.gla.ac.uk
% last updated: 22 oct 2025
%
% Create a baseline model of the FlyZero FZN-1E Narrowbody
% Hydrogen Concept.
%
% Data is sourced from the FlyZero "ZERO-CARBON EMISSION AIRCRAFT
% CONCEPTS" report (FZO-AIN-REP-0007), Tables 5, 6, and 7.
%
% All required inputs contain "** REQUIRED **" before the description of
% the parameter to be specified. All other parameters may remain as NaN,
% and they will be filled in by a statistical regression. For improved
% accuracy, it is suggested to provide as many parameters as possible.
%
% INPUTS:
%     none
%
% OUTPUTS:
%     Aircraft - aircraft data structure to be used for analysis
%                size/type/units: 1-by-1 / struct / []
%


%% TOP-LEVEL AIRCRAFT REQUIREMENTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% expected entry-into-service year (from report: 2030 baseline)
Aircraft.Specs.TLAR.EIS = 2016;

% ** REQUIRED **
% aircraft class
Aircraft.Specs.TLAR.Class = "Turbofan";

% ** REQUIRED **
% approximate number of passengers (Table 7: 180 @ 32" pitch)
Aircraft.Specs.TLAR.MaxPax = 180;


%% MODEL CALIBRATION FACTORS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Aerodynamic calibration factors
Aircraft.Specs.Aero.L_D.ClbCF = 1.30;   
Aircraft.Specs.Aero.L_D.CrsCF = 1.30;  

% Fuel flow calibration factor
Aircraft.Specs.Propulsion.MDotCF = 1.00;

% Airframe weight calibration factor
Aircraft.Specs.Weight.WairfCF = 1.10;


%% VEHICLE PERFORMANCE %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% takeoff speed (m/s) - typical for narrowbody
Aircraft.Specs.Performance.Vels.Tko = UnitConversionPkg.ConvVel(135, "kts", "m/s");

% cruise speed (mach) - from Table 6: 450 ktas @ 35,000 ft ≈ M0.78-0.79
Aircraft.Specs.Performance.Vels.Crs = 0.79;

% takeoff altitude (m)
Aircraft.Specs.Performance.Alts.Tko = 0;

% cruise altitude (m) - from Table 6: 35,000 ft
Aircraft.Specs.Performance.Alts.Crs = UnitConversionPkg.ConvLength(35000, "ft", "m");

% ** REQUIRED **
% design range (m) - from Table 7: 2,400 nmi
Aircraft.Specs.Performance.Range = 4445e3;

% maximum rate of climb (m/s) - typical for narrowbody
Aircraft.Specs.Performance.RCMax = UnitConversionPkg.ConvLength(2250/60, "ft", "m");


%% AERODYNAMICS %%
%%%%%%%%%%%%%%%%%%

% lift-drag ratio during climb
Aircraft.Specs.Aero.L_D.Clb = 16 * Aircraft.Specs.Aero.L_D.ClbCF;

% lift-drag ratio during cruise - from Table 6: L/D = 19.6
Aircraft.Specs.Aero.L_D.Crs = 19.6 * Aircraft.Specs.Aero.L_D.CrsCF;

% lift-drag ratio during descent - assume same as climb
Aircraft.Specs.Aero.L_D.Des = Aircraft.Specs.Aero.L_D.Clb;

% wing loading (kg/m²) - from Table 5: 594 kg/m²
Aircraft.Specs.Aero.W_S.SLS = 594;


%% WEIGHTS %%
%%%%%%%%%%%%%

% ** REQUIRED **
% maximum takeoff weight (kg) - from Table 7: 70.7 tonnes
Aircraft.Specs.Weight.MTOW = 70700;

% electric generator weight (kg) - not used for conventional
Aircraft.Specs.Weight.EG = NaN;

% electric motor weight (kg) - not used for conventional
Aircraft.Specs.Weight.EM = NaN;

% block fuel weight (kg) - from Table 7: 3,283 kg (design mission)
Aircraft.Specs.Weight.Fuel = 3903;

% battery weight (kg) - not used for conventional
Aircraft.Specs.Weight.Batt = NaN;

% payload weight
Aircraft.Specs.Weight.Payload = 23000;


%% PROPULSION %%
%%%%%%%%%%%%%%%%

% ** REQUIRED **
% propulsion architecture - conventional (hydrogen-burning turbofan)
Aircraft.Specs.Propulsion.PropArch.Type = "C";

% ** REQUIRED ** for configurations using gas-turbine engines
% Use LEAP-1A26 as baseline engine (will burn hydrogen instead of Jet-A)
Aircraft.Specs.Propulsion.Engine = EngineModelPkg.EngineSpecsPkg.FZN1E_engine;

% number of engines
Aircraft.Specs.Propulsion.NumEngines = 2;

% thrust-weight ratio - from Table 6: 105.5 kN total thrust / 70.7 tonnes
% T/W = 105,500 N / (70,700 kg × 9.81 m/s²) = 0.152
Aircraft.Specs.Propulsion.T_W.SLS = 170000 / (70700 * 9.81);

% total sea-level static thrust available (N) - from Table 6: 105.5 kN
Aircraft.Specs.Propulsion.Thrust.SLS = 170000;

% engine propulsive efficiency - typical for high-bypass turbofan
Aircraft.Specs.Propulsion.Eta.Prop = 0.8;


%% POWER %%
%%%%%%%%%%%

% gravimetric specific energy of combustible fuel (kWh/kg)
% LH₂: 120 MJ/kg = 120 MJ/kg ÷ 3.6 MJ/kWh = 33.33 kWh/kg
% (Jet-A is ~12 kWh/kg for comparison)
Aircraft.Specs.Power.SpecEnergy.Fuel = 33.33;

% gravimetric specific energy of battery (kWh/kg) - not used
Aircraft.Specs.Power.SpecEnergy.Batt = NaN;

% electric motor and generator efficiencies - not used for conventional
Aircraft.Specs.Power.Eta.EM = NaN;
Aircraft.Specs.Power.Eta.EG = NaN;

% power-weight ratio for the aircraft (kW/kg) - only for turboprops
Aircraft.Specs.Power.P_W.SLS = NaN;

% power-weight ratio for electric motor and generator (kW/kg) - not used
Aircraft.Specs.Power.P_W.EM = NaN;
Aircraft.Specs.Power.P_W.EG = NaN;

% upstream power splits - not used for conventional architecture
Aircraft.Specs.Power.LamUps.SLS = 0;
Aircraft.Specs.Power.LamUps.Tko = 0;
Aircraft.Specs.Power.LamUps.Clb = 0;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% downstream power splits - not used for conventional architecture
Aircraft.Specs.Power.LamDwn.SLS = 0;
Aircraft.Specs.Power.LamDwn.Tko = 0;
Aircraft.Specs.Power.LamDwn.Clb = 0;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;

% battery cells in series and parallel - not used for conventional
Aircraft.Specs.Power.Battery.ParCells = NaN;
Aircraft.Specs.Power.Battery.SerCells = NaN;

% initial battery SOC - not used for conventional
Aircraft.Specs.Power.Battery.BegSOC = NaN;


%% SETTINGS %%
%%%%%%%%%%%%%%

% number of control points in each segment
Aircraft.Settings.TkoPoints = 4;
Aircraft.Settings.ClbPoints = 5;
Aircraft.Settings.CrsPoints = 5;
Aircraft.Settings.DesPoints = 5;

% maximum number of iterations during OEW estimation
Aircraft.Settings.OEW.MaxIter = 50;

% OEW relative tolerance for convergence
Aircraft.Settings.OEW.Tol = 0.001;

% maximum number of iterations during aircraft sizing
Aircraft.Settings.Analysis.MaxIter = 50;

% analysis type: +1 for on-design mode (aircraft performance and sizing)
Aircraft.Settings.Analysis.Type = 1;

% plotting: 0 for plotting off, 1 for plotting on
Aircraft.Settings.Plotting = 0;

% return the mission history as a table (1) or not (0)
Aircraft.Settings.Table = 0;

% flag to visualize the aircraft while sizing
Aircraft.Settings.VisualizeAircraft = 0;

% ----------------------------------------------------------

end
