classdef mOP2block_OES < mOP2block
	%OP2BLOCK_OPG Reads table of element stresses or strains
	%   OP2BLOCK_OQG reads the table of element stresses or strains
	%   from a NASTRAN binary output 2 file.
	%
	%   BLOCKINFO is the structure describing the block.
	%   DATA is a structure, containing the following fields:
	%
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- ACODE,        Device code + 10*approach code
	%   |- TCODE,        Table code
	%   |- ELTYPE,       Element type
	%   |- SUBCASE,      Subcase or random identification number
	%   |- MODE*,        Mode number
	%   |- EIGN*,        Eigenvalue
	%   |- MODECYCL*,    Mode or cycle
	%   |- LSDVMN*,      Load set number
	%   |- LFTSFQ*,      Load step
	%   |- LOADSET,      Load set number or zero or random code identification number
	%   |- FCODE,        Format code
	%   |- NUMWDE,       Number of words per entry in DATA record
	%   |- SCODE,        Stress/strain code
	%   |- ResultType,   'stress' or 'strain' string
	%   |- THERMAL,      =1 for heat transfer and 0 otherwise
	%   |- TITLE,        Title
	%   |- SUBTITL,      Subtitle
	%   |- LABEL,        Label
	%   |- num_entries,  Number of entries in the table
	%   |- ElementID,    Element ID for each entry
	%   |- Value,        Output values for each entry (refer to Programmer's Guide)
	%
	%   Note: fields marked with (*) are present only in the appropriate cases.
	%
	%   Block described in MD Nastran 2006 DMAP Programmer's Guide, page 439.
	%   See also OP2READ, OP2INFO, OP2BLOCK, OP2BLOCK_*.

	%   $Revision: 1.1.0 $  $Date: 2022/09/08 $
	
	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".

	properties
	end % properties
	properties(SetAccess=private)
	end % properties(SetAccess=protected)
	properties(Access=private)
		data_copy
		data_set = false
	end % properties(Access=private)
	properties(SetAccess=private, Dependent = true)
		data
	end % properties(SetAccess=private, Dependent = true)
	methods
		function block = mOP2block_OES(blockInfo, fid, tableFmt)
			block = block@mOP2block(blockInfo, fid, tableFmt);
			block.interpreter = 'OES';
		end % mOP2block_OES
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;

			if isempty(strmatch('OES', blockInfo.name)) && isempty(strmatch('OSTR', blockInfo.name))
				error('mOP2block_OES: Wrong block type')
			end

			for recordID = 1:(length(blockInfo.record)-1)/2
				%% RECORD 1: IDENT
				fseek(fid, blockInfo.record(recordID*2 - 1).TablesStart + 4, -1);

				data(recordID).ACODE = fread(fid, 1, 'int32');
				data(recordID).TCODE = fread(fid, 1, 'int32');
				data(recordID).ELTYPE = fread(fid, 1, 'int32');
				data(recordID).SUBCASE = fread(fid, 1, 'int32');

				switch mOP2block.functionCodes(data(recordID).TCODE, 1)
					case 1
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {1 3 4 7 11} % Statics, PreBuckling, old NLStatic
								data(recordID).LSDVMN = fread(fid, 1, 'int32');
								fseek(fid, 2*4, 0);
							case {2 9} % Real and Complex Eigenvalues
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGN = fread(fid, 1, 'float32');
								data(recordID).MODECYCL = fread(fid, 1, 'float32');
							case {8} % PostBuckling
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGN = fread(fid, 1, 'float32');
								fseek(fid, 4, 0);
							case {10} % Nonlinear static
								data(recordID).LFTSFQ = fread(fid, 1, 'float32');
								fseek(fid, 2*4, 0);
							case {5} % Frequency
								data(recordID).FREQ = fread(fid, 1, 'float32');
								fseek(fid, 2*4, 0);
							otherwise
								warning('mOP2block_OES: ACODE %d not implemented', data(recordID).ACODE)
								fseek(fid, 3*4, 0);
						end
					case 2
						data(recordID).LSDVMN = fread(fid, 1, 'int32');
						fseek(fid, 2*4, 0);
				end

				data(recordID).LOADSET = fread(fid, 1, 'int32');
				data(recordID).FCODE = fread(fid, 1, 'int32');
				data(recordID).NUMWDE = fread(fid, 1, 'int32');
				data(recordID).SCODE = fread(fid, 1, 'int32');
				switch mOP2block.functionCodes(data(recordID).SCODE, 6)
					case 1
						data(recordID).ResultType = 'stress';
					case 0
						data(recordID).ResultType = 'strain';
				end
				fseek(fid, 11*4, 0);
				data(recordID).THERMAL = fread(fid, 1, 'int32');
				fseek(fid, 27*4, 0);
				data(recordID).TITLE = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).SUBTITL = sprintf('%c', fread(fid, 32*4, 'char'));
				data(recordID).LABEL = sprintf('%c', fread(fid, 32*4, 'char'));

				%% RECORD 2: DATA
				fseek(fid, blockInfo.record(recordID*2).TablesStart(1), -1);
				% 	data(recordID).num_entries = fread(fid, 1, 'int32') / (data(recordID).NUMWDE*4);
				fseek(fid, 1*4, 0);
				TablesLength = blockInfo.record(recordID*2).TablesLength;

				data(recordID).num_entries = sum(TablesLength) / (data(recordID).NUMWDE);
				
				% Read all data
				FloatData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'float32');
				IntData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'int32');
				CharData = block.readMatrix(blockInfo.record(recordID*2), data(recordID), 'int8=>char');

				switch mOP2block.functionCodes(data(recordID).TCODE, 1)
					case 1
						EKEY = IntData(:,1);
						data(recordID).ElementID = floor(EKEY*.1);
					case 2
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {1 2 3 4 7 8 9 11 12}
								EKEY = IntData(:,1);
								data(recordID).ElementID = floor(EKEY*.1);
							case {5 6 10}
								data(recordID).FQ_TS = IntData(:,1);
							otherwise
								error('mOP2block_OES: wrong ACODE')
						end
				end
				
				% Define dataType
				dataType = '';
				switch data(recordID).THERMAL
					case 1
						error('mOP2block_OES: THERMAL analysis not implemented')
					case 0
						switch data(recordID).ELTYPE
							case {1 10} % CROD, CONROD
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 1}
										dataType = 'nffff';
									case 2
										dataType = 'nff';
								end
							case 2 % CBEAM
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 1}
										dataType = ['ni' repmat('f', 1, 11-3+1)];
									case 2
										dataType = ['ni' repmat('f', 1, 7-3+1)];
								end
							case 94 % nonlinear CBEAM
								dataType = ['ni' repmat('cffff', 1, 4) 'i' repmat('cffff', 1, 4)];
							case {33 74} % CQUAD4, CTRIA3
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case 0
										dataType = ['n' repmat('f', 1, 17-2+1)];
									case 1
										dataType = ['n' repmat('f', 1, 15-2+1)];
									case 2
										dataType = ['n' repmat('f', 1, 9-2+1)];
								end
							case {34} % BAR
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case 0
										dataType = ['n' repmat('f', 1, 16-2+1)];
									case 1
										dataType = ['n' repmat('f', 1, 19-2+1)];
									case 2
										dataType = ['n' repmat('f', 1, 10-2+1)];
								end
							case {144} % QUAD144
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case 0
										dataType = ['nci' repmat('f', 1, 19-4+1)];
									case 1
										dataType = ['nci' repmat('f', 1, 17-4+1)];
									case 2
										dataType = ['nci' repmat('f', 1, 11-4+1)];
								end
							case {95 96 97 98 232 233} % QUAD4 composite, QUAD8 composite, TRIA3 composite, TRIA6 composite, Quadr composite, Ctriar composite
								dataType = ['ni' repmat('f', 1, 11-3+1)];
							case {12} % CELAS2
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										dataType = 'nf';
									case 1
										dataType = 'nff';
								end
							case {89} % Nonlinear ROD element
								dataType = ['n' repmat('f', 1, 7-2+1)]; % Axial Stress, Equivalent Stress, Total Strain, Effective Plastic strain, Effective Creep strain, Linear torsional stress
							case {67 68} % CHEXA, CPENTA
								switch mOP2block.functionCodes(data(recordID).TCODE, 7) % CID, CTYPE, NODEF, GRID, Stresses
									case 0 % real
										dataType = ['nicii' repmat('f', 1, 25-6+1)];
									case 1 % real/imaginary
										dataType = ['nicii' repmat('f', 1, 17-6+1)];
									case 2 % random response
										dataType = ['nicii' repmat('f', 1, 11-6+1)];
								end
							otherwise
								warning('mOP2block_OES: Element type %d (%s) not implemented', data(recordID).ELTYPE, mOP2_eltype_human(data(recordID).ELTYPE))
						end
				end
				
				% Create output data
				if numel(dataType) > 0
					data(recordID).Value = block.buildTable(dataType, IntData, FloatData, CharData);
				end
			end
			
			% If the record is empty, initialize "data" as []
			if length(blockInfo.record)-1 == 0
				data = [];
			end
			
			block.data_set = true;
			block.data_copy = data;
		end % get.data

	end % methods
end
