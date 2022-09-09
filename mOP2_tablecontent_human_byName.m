function [desc] = mOP2_tablecontent_human_byName(name)
	%MOP2_TABLECONTENT_HUMAN_BYNAME Returns a human-readable description for a given table name
	%
	%   [DESC] = MOP2_TABLECONTENT_HUMAN_BYNAME(NAME)
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".

	name = [name '      '];
	
	if name(1:3) == "OUG"
		desc = "Eigenvector / Displacement vector / Velocity vector / Acceleration vector";
	elseif name(1:3) == "OPG"
		desc = "Load vector / Nonlinear force vector";
	elseif name(1:3) == "OQG"
		desc = "SPCforce vector / MPC forces";
	elseif name(1:3) == "OEF"
		desc = "Element force (or flux) / Composite failure indices";
	elseif name(1:3) == "OES"
		desc = "Element stress (or strain) / Stresses at grid points / Strain/curvature at grid points";
	elseif name(1:4) == "LAMA"
		desc = "Eigenvalue summary";
	elseif name(1:5) == "OEIGS"
		desc = "Eigenvalue analysis summary";
	elseif name(1:5) == "OGPWG"
		desc = "Grid point weight generator";
	elseif name(1:3) == "OEE"
		desc = "Element strain energy / Element kinetic energy/loss";
	elseif name(1:3) == "OGF"
		desc = "Grid point force balance";
	elseif name(1:6) == "OELOF1"
		desc = "Element internal forces and moments";
	elseif name(1:6) == "OELOP1"
		desc = "Summation of element oriented forces on adjacent elements";
	elseif name(1:3) == "OEP"
		desc = "Element pressures";
	elseif name(1:3) == "OGS"
		desc = "Grid point stresses/stress discontinuities / Element stress discontinuities";
	elseif name(1:3)  == "OMM"
		desc = "MAXMIN summary";
	elseif name(1:5)  == "OGPKE"
		desc = "Grip point kinetic energy";
	elseif name(1:7) == "EFMFSMS"
		desc = "Total Effective mass matrix";
	elseif name(1:7) == "EFMASSS"
		desc = "Effective mass matrix";
	elseif name(1:6) == "RBMASS"
		desc = "Rigid body mass matrix";
	elseif name(1:7) == "EFMFACS"
		desc = "Modal effective mass fraction matrix";
	elseif name(1:6) == "MPFACS"
		desc = "Modal participation factor matrix";
	elseif name(1:7) == "MEFMASS"
		desc = "Modal effective mass matrix";
	elseif name(1:6) == "MEFWTS"
		desc = "Modal effective weight matrix";
	elseif name(1:6) == "RAFGEN"
		desc = "Generalized force matrix";
	elseif name(1:7) == "RADEFMP"
		desc = " Effective inertia loads";
	elseif name(1:3) == "BHH"
		desc = "Viscous damping matrix";
	elseif name(1:3) == "KHH"
		desc = "Structural damping matrix";
	elseif name(1:7) == "RADAMPZ"
		desc = "Equivalent viscous damping ratios";
	elseif name(1:7) == "RADAMPG"
		desc = "Equivalent structural damping ratio";
	elseif name(1:3) == "FRL"
		desc = "Frequency response list";
	elseif name(1:7) == "EQEXINS"
		desc = "Equivalence between external and internal numbers";
	else
		desc = "unknown";
	end