classdef mOP2block_OEF < mOP2block
	%OP2BLOCK_OEF Reads table of element forces or composite failure indices
	%   OP2BLOCK_OEF reads the table of element forces
	%   or composite failure indices from a NASTRAN binary output 2 file.
	%
	%   DATA is a structure, containing the following fields:
	%	
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- ACODE,        Device code + 10*approach code
	%   |- TCODE,        Table code
	%   |- ELTYPE,       Element type
	%   |- SUBCASE,      Subcase or random identification number
	%   |- MODE*,        Mode number
	%   |- EIGR*,        Eigenvalue real part
	%   |- EIGI*,        Eigenvalue imaginary part
	%   |- MODECYCL*,    Mode or cycle
	%   |- LOADID*,      Load set number
	%   |- LOADSTEP*,    Load step
	%   |- TIMESTEP*,    Time step
	%   |- DLOADID,      Dynamic load set identification or random code identification number
	%   |- FCODE,        Format code
	%   |- NUMWDE,       Number of words per entry in DATA record
	%   |- OCODE,        Stress/strain code (IN REV 2014.1 CALLED OCODE)
	%   |- THERMAL,      =1 for heat transfer and 0 otherwise
	%   |- TITLE,        Title
	%   |- SUBTITL,      Subtitle
	%   |- LABEL,        Label
	%   |- num_entries,  Number of entries in the table
	%   |- ElementID,    Element ID for each entry
	%   |- Value         Output values for each entry (refer to Programmer's Guide)
	%
	%   Note: fields marked with (*) are present only in the appropriate cases.
	%
	%   Block described in MD Nastran 2006 DMAP Programmer's Guide, page 439.
	%   See also OPENOP2, READOP2HEADER, READFIELD, READBLOCK*.

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
		function block = mOP2block_OEF(blockInfo, fid, tableFmt)
			block = block@mOP2block(blockInfo, fid, tableFmt);
			block.interpreter = 'OEF';
		end % mOP2block_OEF
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;
			
			if isempty(strmatch('OEF', blockInfo.name))
				error('mOP2block_OEF: Wrong block type')
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
								data(recordID).LOADID = fread(fid, 1, 'int32');
								fseek(fid, 2*4, 0);
							case {2} % Real Eigenvalues
								data(recordID).MODE = fread(fid, 1, 'int32');
								fseek(fid, 2*4, 0);
							case {6} % Transient
								data(recordID).TIMESTEP = fread(fid, 1, 'float32');
								fseek(fid, 2*4, 0);
							case {8} % PostBuckling
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGN = fread(fid, 1, 'float32');
								fseek(fid, 4, 0);
							case {9} % Complex Eigenvalues
								data(recordID).MODE = fread(fid, 1, 'int32');
								data(recordID).EIGR = fread(fid, 1, 'float32');
								data(recordID).EIGI = fread(fid, 1, 'float32');
							case {10} % Nonlinear static
								data(recordID).LOADSTEP = fread(fid, 1, 'float32');
								fseek(fid, 2*4, 0);
							otherwise
								warning('mOP2block_OEF: ACODE %d not implemented', data(recordID).ACODE)
								fseek(fid, 3*4, 0);
						end
					case 2
						data(recordID).LOADID = fread(fid, 1, 'int32');
						fseek(fid, 2*4, 0);
				end

				data(recordID).DLOADID = fread(fid, 1, 'int32');
				data(recordID).FCODE = fread(fid, 1, 'int32');
				data(recordID).NUMWDE = fread(fid, 1, 'int32');
				data(recordID).OCODE = fread(fid, 1, 'int32'); % now called SCODE
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
						data(recordID).ElementID = IntData(:,1);
					case 2
						switch mOP2block.functionCodes(data(recordID).ACODE, 4)
							case {1 2 3 4 7 8 9 11 12}
								data(recordID).LOADID = IntData(:,1);
							case {5 6 10}
								data(recordID).FQ_TS = FloatData(:,1);
							otherwise
								error('mOP2block_OEF: wrong ACODE')
						end
				end
				
				% Define dataType
				dataType = '';
				switch data(recordID).THERMAL
					case 1
						%warning('mOP2block_OEF: THERMAL analysis not implemented')
                        switch data(recordID).NUMWDE
                            case {9 10}
                                %data(recordID).Value = FloatData(:,4:9);
								dataType = ['nnn' repmat('f', 1, 9-4+1)];
                            case {8}
                                %data(recordID).Value = FloatData(:,4:8);
								dataType = ['nnn' repmat('f', 1, 8-4+1)];
                            case {2}
                                %data(recordID).Value = FloatData(:,2);
								dataType = 'nf';
                            case {30 44 58}
                                data(recordID).PARENT = IntData(:,2);
                                data(recordID).VUGRID = IntData(:,3);
                                %data(recordID).Value = FloatData(:,4:9);
								dataType = ['nnn' repmat('f', 1, 9-4+1)];
                            case {27 34}
                                data(recordID).PARENT = IntData(:,2);
                                data(recordID).COORD = IntData(:,3);
                                data(recordID).THETA = IntData(:,5);
                                data(recordID).VUGRID = IntData(:,7);
                                %data(recordID).Value = FloatData(:,8:13);
								dataType = [repmat('n', 1, 7) repmat('f', 1, 13-8+1)];
                            case {18}
                                data(recordID).PARENT = IntData(:,2);
                                data(recordID).COORD = IntData(:,3);
                                data(recordID).VUGRID = IntData(:,5);
                                %data(recordID).Value = FloatData(:,6:11);
								dataType = [repmat('n', 1, 5) repmat('f', 1, 11-6+1)];
                        end
					case 0
						switch data(recordID).ELTYPE
							case {1 10} % CROD, CONROD
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										%data(recordID).Value = FloatData(:,2:3);
										dataType = 'nff';
									case 1
										%data(recordID).Value = FloatData(:,2:5);
										dataType = 'nffff';
								end
							case 2 % CBEAM
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										%data(recordID).Value = [IntData(:,2), FloatData(:,3:10)];
										dataType = ['ni' repmat('f', 1, 10-3+1)];
									case 1
										%data(recordID).Value = [IntData(:,2), FloatData(:,3:17)];
										dataType = ['ni' repmat('f', 1, 17-3+1)];
								end
							case {33 74} % CQUAD4, CTRIA3
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										%data(recordID).Value = FloatData(:,2:9);
										dataType = ['n' repmat('f', 1, 9-2+1)];
									case 1
										%data(recordID).Value = FloatData(:,2:17);
										dataType = ['n' repmat('f', 1, 17-2+1)];
								end
							case {144} % QUAD144
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										%data(recordID).Value = [CharData(:,2), IntData(:,3), FloatData(:,4:11)];
										dataType = ['nci' repmat('f', 1, 11-4+1)];
									case 1
										%data(recordID).Value = [CharData(:,2), IntData(:,3), FloatData(:,4:19)];
										dataType = ['nci' repmat('f', 1, 19-4+1)];
								end
							case {95 96 97 98 232 233} % QUAD4 composite, QUAD8 composite, TRIA3 composite, TRIA6 composite, Quadr composite, Ctriar composite
								% data(recordID).Value = [CharData(:,2:3) IntData(:,4), FloatData(:,5:8) CharData(:,9)];
								dataType = 'ncciffffc';
							case {12} % CELAS2
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case {0 2}
										% data(recordID).Value = FloatData(:,2);
										dataType = 'nf';
									case 1
										% data(recordID).Value = FloatData(:,2:3);
										dataType = 'nff';
								end
							case {89} % Nonlinear ROD element
								% data(recordID).Value = FloatData(:,2:7); % Axial Stress, Equivalent Stress, Total Strain, Effective Plastic strain, Effective Creep strain, Linear torsional stress
								dataType = ['n' repmat('f', 1, 7-2+1)];
							case {67} % CHEXA
								switch mOP2block.functionCodes(data(recordID).TCODE, 7)
									case 0
										% data(recordID).Value = [FloatData(:,2:14)];
										dataType = ['n' repmat('f', 1, 14-2+1)];
								end
							otherwise
								warning('mOP2block_OEF: Element type %d not implemented', data(recordID).ELTYPE)
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