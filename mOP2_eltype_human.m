function [name, desc] = mOP2_eltype_human(ELTYPE)
	%MOP2_ELTYPE_HUMAN Returns a human-readable name and description for a given element type
	%
	%   [NAME, DESC] = MOP2_ELTYPE_HUMAN(ELTYPE)
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".
	
	switch ELTYPE
		case 00
			name = "GRID";
			desc = "Grid";
		case 01
			name = "ROD";
			desc = "Rod";
		case 02
			name = "BEAM";
			desc = "Beam";
		case 03
			name = "TUBE";
			desc = "Tube";
		case 04
			name = "SHEAR";
			desc = "Shear panel";
		case 05
			name = "FORMON12";
			desc = "FORCEi/MOMENTi follower stiffness";
		case 06
			name = "FORCE";
			desc = "Unused (Pre-V69 CTRIA1)";
		case 07
			name = "PLOAD4";
			desc = "PLOAD4 follower stiffness";
		case 08
			name = "PLOADX1";
			desc = "PLOADX1 follower stiffness";
		case 09
			name = "PLOAD";
			desc = "/PLOAD2 PLOAD/PLOAD2 follower stiffness";
		case 10
			name = "CONROD";
			desc = "Rod with properties";
		case 11
			name = "ELAS1";
			desc = "Scalar spring";
		case 12
			name = "ELAS2";
			desc = "Scalar spring with properties";
		case 13
			name = "ELAS3";
			desc = "Scalar spring to scalar points only";
		case 14
			name = "ELAS4";
			desc = "Scalar spring to scalar points only with properties";
		case 15
			name = "AEROT3";
			desc = "";
		case 16
			name = "AEROBEAM";
			desc = "";
		case 17
			name = "TRIAX";
			desc = "Harmonic triangular";
		case 18
			name = "QUADX";
			desc = "Harmonic quadrilateral";
		case 19
			name = "Unused";
			desc = "(Pre-V69 CQUAD1)";
		case 20
			name = "DAMP1";
			desc = "Scalar damper";
		case 21
			name = "DAMP2";
			desc = "Scalar damper with properties";
		case 22
			name = "DAMP3";
			desc = "Scalar damper to scalar points only";
		case 23
			name = "DAMP4";
			desc = "Scalar damper to scalar points only with properties";
		case 24
			name = "VISC";
			desc = "Viscous damper";
		case 25
			name = "MASS1";
			desc = "Scalar mass";
		case 26
			name = "MASS2";
			desc = "Scalar mass with properties";
		case 27
			name = "MASS3";
			desc = "Scalar mass to scalar points only";
		case 28
			name = "MASS4";
			desc = "Scalar mass to scalar points only with properties";
		case 29
			name = "CONM1";
			desc = "Concentrated mass -- general form";
		case 30
			name = "CONM2";
			desc = "Concentrated mass -- rigid body form";
		case 31
			name = "PLOTEL";
			desc = "Plot";
		case 32
			name = "Unused";
			desc = "";
		case 33
			name = "QUAD4";
			desc = "Quadrilateral plate";
		case 34
			name = "BAR";
			desc = "Simple beam (see also Type=100)";
		case 35
			name = "CONEAX";
			desc = "Axisymmetric shell";
		case 36
			name = "Unused";
			desc = "(Pre-V69 CTRIARG)";
		case 37
			name = "Unused";
			desc = "(Pre-V69 CTRAPRG)";
		case 38
			name = "GAP";
			desc = "Gap";
		case 39
			name = "TETRA";
			desc = "Tetrahedral";
		case 40
			name = "BUSH1D";
			desc = "Rod type spring and damper";
		case 41
			name = "Unused";
			desc = "(Pre-V69 CHEXA1)";
		case 42
			name = "Unused";
			desc = "(Pre-V69 CHEXA2)";
		case 43
			name = "FLUID2";
			desc = "Fluid with 2 points";
		case 44
			name = "FLUID3";
			desc = "Fluid with 3 points";
		case 45
			name = "FLUID4";
			desc = "Fluid with 4 points";
		case 46
			name = "FLMASS";
			desc = "";
		case 47
			name = "AXIF2";
			desc = "Fluid with 2 points";
		case 48
			name = "AXIF3";
			desc = "Fluid with 3 points";
		case 49
			name = "AXIF4";
			desc = "Fluid with 4 points";
		case 50
			name = "SLOT3";
			desc = "Three-point slot";
		case 51
			name = "SLOT4";
			desc = "Four-point slot";
		case 52
			name = "HBDY";
			desc = "Heat transfer plot for CHBDYG and CHBDYP";
		case 53
			name = "TRIAX6";
			desc = "Axisymmetric triangular";
		case 54
			name = "Unused";
			desc = "(Pre-V69 TRIM6)";
		case 55
			name = "DUM3";
			desc = "Three-point dummy";
		case 56
			name = "DUM4";
			desc = "Four-point dummy";
		case 57
			name = "DUM5";
			desc = "Five-point dummy";
		case 58
			name = "DUM6";
			desc = "Six-point dummy";
		case 59
			name = "DUM7";
			desc = "Seven-point dummy";
		case 60
			name = "DUM8";
			desc = "Eight-point dummy (also two-dimensional crack tip CRAC2D)";
		case 61
			name = "DUM9";
			desc = "Nine-point dummy (also three-dimensional crack tip CRAC3D)";
		case 62
			name = "Unused";
			desc = "(Pre-V69 CQDMEM1)";
		case 63
			name = "IFQUAD";
			desc = "Quadrilateral interface cohesive";
		case 64
			name = "QUAD8";
			desc = "Curved quadrilateral shell";
		case 65
			name = "IFHEX";
			desc = "Hexahedral interface cohesive";
		case 66
			name = "IFPENT";
			desc = "Pentahedral interface cohesive";
		case 67
			name = "HEXA";
			desc = "Six-sided solid";
		case 68
			name = "PENTA";
			desc = "Five-sided solid";
		case 69
			name = "BEND";
			desc = "Curved beam or pipe";
		case 70
			name = "TRIAR";
			desc = "Triangular plate with no membrane-bending coupling";
		case 71
			name = "Unused";
			desc = "";
		case 72
			name = "AEROQ4";
			desc = "";
		case 73
			name = "IFQDX";
			desc = "Axisymmetric interface cohesive";
		case 74
			name = "TRIA3";
			desc = "Triangular plate";
		case 75
			name = "TRIA6";
			desc = "Curved triangular shell";
		case 76
			name = "HEXPR";
			desc = "Acoustic velocity/pressures in six-sided solid";
		case 77
			name = "PENPR";
			desc = "Acoustic velocity/pressures in five-sided solid";
		case 78
			name = "TETPR";
			desc = "Acoustic velocity/pressures in four-sided solid";
		case 79
			name = "Unused";
			desc = "";
		case 80
			name = "Unused";
			desc = "";
		case 81
			name = "Unused";
			desc = "";
		case 82
			name = "QUADR";
			desc = "Quadrilateral plate with no membrane-bending coupling";
		case 83
			name = "HACAB";
			desc = "Acoustic absorber";
		case 84
			name = "HACBR";
			desc = "Acoustic barrier";
		case 85
			name = "TETRANL";
			desc = "Nonlinear data recovery four-sided solid";
		case 86
			name = "GAPNL";
			desc = "Nonlinear data recovery gap";
		case 87
			name = "TUBENL";
			desc = "Nonlinear data recovery tube";
		case 88
			name = "TRIA3NL";
			desc = "Nonlinear data recovery triangular plate";
		case 89
			name = "RODNL";
			desc = "Nonlinear data recovery rod";
		case 90
			name = "QUAD4NL";
			desc = "Nonlinear data recovery quadrilateral plate";
		case 91
			name = "PENTANL";
			desc = "Nonlinear data recovery five-sided solid";
		case 92
			name = "CONRODNL";
			desc = "Nonlinear data recovery rod with properties";
		case 93
			name = "HEXANL";
			desc = "Nonlinear data recovery six-sided solid";
		case 94
			name = "BEAMNL";
			desc = "Nonlinear data recovery beam";
		case 95
			name = "QUAD4LC";
			desc = "Composite data recovery quadrilateral plate";
		case 96
			name = "QUAD8LC";
			desc = "Composite data recovery curved quadrilateral shell";
		case 97
			name = "TRIA3LC";
			desc = "Composite data recovery triangular shell";
		case 98
			name = "TRIA6LC";
			desc = "Composite data recovery curved triangular shell";
		case 99
			name = "Unused";
			desc = "";
		case 100
			name = "BARS";
			desc = "Simple beam with intermediate station data recovery";
		case 101
			name = "AABSF";
			desc = "Acoustic absorber with frequency dependence";
		case 102
			name = "BUSH";
			desc = "Generalized spring and damper";
		case 103
			name = "QUADP";
			desc = "p-version quadrilateral shell";
		case 104
			name = "TRIAP";
			desc = "p-version triangular shell";
		case 105
			name = "BEAMP";
			desc = "p-version beam";
		case 106
			name = "DAMP5";
			desc = "Heat transfer scalar damper with material property";
		case 107
			name = "CHBDYE";
			desc = "Heat transfer geometric surface -- element form";
		case 108
			name = "CHBDYG";
			desc = "Heat transfer geometric surface -- grid form";
		case 109
			name = "CHBDYP";
			desc = "Heat transfer geometric surface -- property form";
		case 110
			name = "CONV";
			desc = "Heat transfer boundary with free convection";
		case 111
			name = "CONVM";
			desc = "Heat transfer boundary with forced convection";
		case 112
			name = "QBDY3";
			desc = "Heat transfer boundary heat flux load for a surface";
		case 113
			name = "QVECT";
			desc = "Heat transfer thermal vector flux load";
		case 114
			name = "QVOL";
			desc = "Heat transfer volume heat addition";
		case 115
			name = "RADBC";
			desc = "Heat transfer space radiation";
		case 116
			name = "SLIF1D";
			desc = "Slideline contact";
		case 117
			name = "WELDC";
			desc = "Weld (Formats ELEMID and GRID with MSET=off)";
		case 118
			name = "WELDP";
			desc = "Weld (Formats ELPAT and PARTPAT)";
		case 119
			name = "SEAM";
			desc = "Seam (future development)";
		case 120
			name = "GENEL";
			desc = "General element";
		case 121
			name = "DMIG";
			desc = "Direct matrix input g-set";
		case 122
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic DIEL)";
		case 123
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic HEXAE)";
		case 124
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic IND)";
		case 125
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINE)";
		case 126
			name = "FASTP";
			desc = "Shell patch fastener";
		case 127
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic CQUAD)";
		case 128
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic CQUADX)";
		case 129
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic RELUC)";
		case 130
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic RES )";
		case 131
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic CTETRAE)";
		case 132
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic CTRIA)";
		case 133
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAX)";
		case 134
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEOB)";
		case 135
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINXOB)";
		case 136
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADOB)";
		case 137
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAOB)";
		case 138
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEX )";
		case 139
			name = "QUAD4FD";
			desc = "Hyperelastic 4-noded quadrilateral shell";
		case 140
			name = "HEXA8FD";
			desc = "Hyperelastic 8-noded solid";
		case 141
			name = "HEXAP";
			desc = "p-version six-sided solid";
		case 142
			name = "PENTAP";
			desc = "p-version five-sided solid";
		case 143
			name = "TETRAP";
			desc = "p-version four-sided solid";
		case 144
			name = "QUAD144";
			desc = "Quadrilateral plate with data recovery for corner stresses";
		case 145
			name = "VUHEXA";
			desc = "p-version six-sided solid display";
		case 146
			name = "VUPENTA";
			desc = "p-version five-sided solid display";
		case 147
			name = "VUTETRA";
			desc = "p-version four-sided solid display";
		case 148
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic HEXAM)";
		case 149
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic PENTAM)";
		case 150
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TETRAM)";
		case 151
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADM)";
		case 152
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAM)";
		case 153
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADXM)";
		case 154
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAXM)";
		case 155
			name = "RADINT";
			desc = "";
		case 156
			name = "BUSH2D";
			desc = "2D spring and damper";
		case 157
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEPW)";
		case 158
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADOBM)";
		case 159
			name = "SEAMP";
			desc = "Shell patch seam";
		case 160
			name = "PENTA6FD";
			desc = "Hyperelastic pentahedron 6-noded";
		case 161
			name = "TETRA4FD";
			desc = "Hyperelastic tetrahedron 4-noded";
		case 162
			name = "TRIA3FD";
			desc = "Hyperelastic triangular 3-noded";
		case 163
			name = "HEXAFD";
			desc = "Hyperelastic hexahedron 20-noded";
		case 164
			name = "QUADFD";
			desc = "Hyperelastic quadrilateral 9-noded";
		case 165
			name = "PENTAFD";
			desc = "Hyperelastic pentahedron 15-noded";
		case 166
			name = "TETRAFD";
			desc = "Hyperelastic tetrahedron 10-noded";
		case 167
			name = "TRIAFD";
			desc = "Hyperelastic triangular 6-noded";
		case 168
			name = "TRIAX3FD";
			desc = "Hyperelastic axisymmetric triangular 3-noded";
		case 169
			name = "TRIAXFD";
			desc = "Hyperelastic axisymmetric triangular 6-noded";
		case 170
			name = "QUADX4FD";
			desc = "Hyperelastic axisymmetric quadrilateral 4-noded";
		case 171
			name = "QUADXFD";
			desc = "Hyperelastic axisymmetric quadrilateral 9-noded";
		case 172
			name = "QUADRNL";
			desc = "Nonlinear QUADR";
		case 173
			name = "TRIARNL";
			desc = "Nonlinear TRIAR";
		case 174
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEOBM)";
		case 175
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINXOBM)";
		case 176
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADWGM)";
		case 177
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAWGM)";
		case 178
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADIB )";
		case 179
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAIB )";
		case 180
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEIB )";
		case 181
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINXIB )";
		case 182
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADIBM)";
		case 183
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAIBM)";
		case 184
			name = "BEAM3";
			desc = "Three-noded beam";
		case 185
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINXIBM)";
		case 186
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADPWM)";
		case 187
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAPWM)";
		case 188
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEPWM)";
		case 189
			name = "VUQUAD";
			desc = "p-version quadrilateral shell display";
		case 190
			name = "VUTRIA";
			desc = "p-version triangular shell display";
		case 191
			name = "VUBEAM";
			desc = "p-version beam display";
		case 192
			name = "CVINT";
			desc = "Curve interface";
		case 193
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic QUADFR)";
		case 194
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic TRIAFR)";
		case 195
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINEFR)";
		case 196
			name = "Unused";
			desc = "(Pre-V70.5 electromagnetic LINXFR)";
		case 197
			name = "SFINT";
			desc = "Surface interface";
		case 198
			name = "CNVPEL";
			desc = "";
		case 199
			name = "VUHBDY";
			desc = "p-version HBDY display";
		case 200
			name = "WELD";
			desc = "Weld (Formats ALIGN, ELEMID, and GRIDID with MSET=on)";
		case 201
			name = "QUAD4FD";
			desc = "Hyperelastic quadrilateral 4-noded nonlinear data recovery Gauss/grid";
		case 202
			name = "HEXA8FD";
			desc = "Hyperelastic hexahedron 8-noded nonlinear data recovery Gauss/grid";
		case 203
			name = "SLIF1D";
			desc = "Slideline contact";
		case 204
			name = "PENTA6FD";
			desc = "Hyperelastic pentahedron 6-noded nonlinear format Gauss/Grid";
		case 205
			name = "TETRA4FD";
			desc = "Hyperelastic tetrahedron 4-noded nonlinear format Gauss";
		case 206
			name = "TRIA3FD";
			desc = "Hyperelastic triangular 3-noded nonlinear format Gauss";
		case 207
			name = "HEXAFD";
			desc = "Hyperelastic hexahedron 20-noded nonlinear format Gauss";
		case 208
			name = "QUADFD";
			desc = "Hyperelastic quadrilateral 8-noded nonlinear format Gauss";
		case 209
			name = "PENTAFD";
			desc = "Hyperelastic pentahedron 15-noded nonlinear format Gauss";
		case 210
			name = "TETRAFD";
			desc = "Hyperelastic tetrahedron 10-noded nonlinear format Grid";
		case 211
			name = "TRIAFD";
			desc = "Hyperelastic triangular 6-noded nonlinear format Gauss/Grid";
		case 212
			name = "TRIAX3FD";
			desc = "Hyperelastic axisymmetric triangular 3-noded nonlinear format Gauss";
		case 213
			name = "TRIAXFD";
			desc = "Hyperelastic axisymmetric triangular 6-noded nonlinear format Gauss/Grid";
		case 214
			name = "QUADX4FD";
			desc = "Hyperelastic axisymmetric quadrilateral 4-noded nonlinear format Gauss/Grid";
		case 215
			name = "QUADXFD";
			desc = "Hyperelastic axisymmetric quadrilateral 8-noded nonlinear format Gauss";
		case 216
			name = "TETRA4FD";
			desc = "Hyperelastic tetrahedron 4-noded nonlinear format Grid";
		case 217
			name = "TRIA3FD";
			desc = "Hyperelastic triangular 3-noded nonlinear format Grid";
		case 218
			name = "HEXAFD";
			desc = "Hyperelastic hexahedron 20-noded nonlinear format Grid";
		case 219
			name = "QUADFD";
			desc = "Hyperelastic quadrilateral 8-noded nonlinear format Grid";
		case 220
			name = "PENTAFD";
			desc = "Hyperelastic pentahedron 15-noded nonlinear format Grid";
		case 221
			name = "TETRAFD";
			desc = "Hyperelastic tetrahedron 10-noded nonlinear format Gauss";
		case 222
			name = "TRIAX3FD";
			desc = "Hyperelastic axisymmetric triangular 3-noded nonlinear format Grid";
		case 223
			name = "QUADXFD";
			desc = "Hyperelastic axisymmetric quadrilateral 8-noded nonlinear format Grid";
		case 224
			name = "ELAS1";
			desc = "Nonlinear ELAS1";
		case 225
			name = "ELAS3";
			desc = "Nonlinear ELAS3";
		case 226
			name = "BUSH";
			desc = "Nonlinear BUSH";
		case 227
			name = "RBAR";
			desc = "Rigid bar";
		case 228
			name = "RBE1";
			desc = "Rigid body form 1";
		case 229
			name = "RBE3";
			desc = "Rigid body form 3";
		case 230
			name = "RJOINT";
			desc = "Rigid joint";
		case 231
			name = "RROD";
			desc = "Rigid pin element";
		case 232
			name = "QUADRLC";
			desc = "Composite QUADR";
		case 233
			name = "TRIARLC";
			desc = "Composite TRIAR";
		case 234
			name = "Unused";
			desc = "Unused";
		case 235
			name = "QUADR";
			desc = "Quadrilateral plate for center punch";
		case 236
			name = "TRIAR";
			desc = "Triangular plate for center punch";
		case 237
			name = "TRIAR";
			desc = "Triangular plate for center output";
		case 238
			name = "BAR";
			desc = "Screened stresses for bar with ABCS";
		case 239
			name = "BEAM";
			desc = "Screened stresses for beam with ABCS";
		case 240
			name = "BAR";
			desc = "Nonlinear bar";
		case 241
			name = "AXISYM";
			desc = "Axisymmetric shell";
	end
end