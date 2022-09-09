function [name, desc] = mOP2_tablecontent_human_byTCODE(TCODE)
	%MOP2_TABLECONTENT_HUMAN_BYTCODE Returns a human-readable name and description for a given table code
	%
	%   [NAME, DESC] = MOP2_TABLECONTENT_HUMAN_BYTCODE(TCODE)
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".
	
	switch functionCodes(TCODE, 1000)
		case 1
			name = "OUG";
			desc = "Displacement vector";
		case 2
			name = "OPG";
			desc = "Load vector";
		case 3
			name = "OQG";
			desc = "SPCforce vector";
		case 4
			name = "OEF";
			desc = "Element force (or flux)";
		case 5
			name = "OES";
			desc = "Element stress(or strain)";
		case 6
			name = "LAMA";
			desc = "Eigenvalue summary";
		case 7
			name = "OUG";
			desc = "Eigenvector";
		case 8
			name = "none";
			desc = "Grid point singularity table (obsolete)";
		case 9
			name = "OEIGS";
			desc = "Eigenvalue analysis summary";
		case 10
			name = "OUG";
			desc = "Velocity vector";
		case 11
			name = "OUG";
			desc = "Acceleration vector";
		case 12
			name = "OPG";
			desc = "Nonlinear force vector";
		case 13
			name = "OGPWG";
			desc = "Grid point weight generator";
		case 14
			name = "OUG";
			desc = "Eigenvector (solution set)";
		case 15
			name = "OUG";
			desc = "Displacement vector (solution set)";
		case 16
			name = "OUG";
			desc = "Velocity vector (solution set)";
		case 17
			name = "OUG";
			desc = "Acceleration vector (solution set)";
		case 18
			name = "OEE";
			desc = "Element strain energy";
		case 19
			name = "OGF";
			desc = "Grid point force balance";
		case 20
			name = "OES";
			desc = "Stresses at grid points (from the CURV module)";
		case 21
			name = "OES";
			desc = "Strain/curvature at grid points";
		case 22
			name = "OELOF1";
			desc = "Element internal forces and moments";
		case 23
			name = "OELOP1";
			desc = "Summation of element oriented forces on adjacent elements";
		case 24
			name = "OEP";
			desc = "Element pressures";
		case 25
			name = "OEF";
			desc = "Composite failure indices";
		case 26
			name = "OGS";
			desc = "Grid point stresses (surface)";
		case 27
			name = "OGS";
			desc = "Grid point stresses (volume -- direct)";
		case 28
			name = "OGS";
			desc = "Grid point stresses (volume -- principal)";
		case 29
			name = "OGS";
			desc = "Element stress discontinuities (surface)";
		case 30
			name = "OGS";
			desc = "Element stress discontinuities (volume -- direct)";
		case 31
			name = "OGS";
			desc = "Element stress discontinuities (volume -- principal)";
		case 32
			name = "OGS";
			desc = "Grid point stress discontinuities (surface)";
		case 33
			name = "OGS";
			desc = "Grid point stress discontinuities (volume -- direct)";
		case 34
			name = "OGS";
			desc = "Grid point stress discontinuities (volume -- principal)";
		case 35
			name = "OGS";
			desc = "Grid point stresses (plane strain)";
		case 36
			name = "OEE";
			desc = "Element kinetic energy";
		case 37
			name = "OEE";
			desc = "Element energy loss";
		case 38
			name = "OMM";
			desc = "MAXMIN summary";
		case 39
			name = "OQG";
			desc = "MPC forces";
		case 40
			name = "OGPKE";
			desc = "Grip point kinetic energy";
	end
end