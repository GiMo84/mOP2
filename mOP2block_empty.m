classdef mOP2block_empty < mOP2block
	%MOP2BLOCK_EMPTY Reads nothing
	%   MOP2BLOCK_EMPTY reads nothing
	%   from a NASTRAN binary output 2 file.
	%
	%   BLOCKINFO is the structure describing the block.
	%   DATA is a structure, containing the following fields:
	%
	%   DATA(I),         with I = 1:numel(DATA)
	%   |- NOTHING,      Boolean always true
	%
	%   Note: fields marked with (*) are present only in the appropriate cases.
	%
	%   Block described in ..., page ....
	%   See also MOP2READ, MOP2INFO, MOP2BLOCK, MOP2BLOCK_*.
	
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
		function block = mOP2block_empty(blockInfo, fid)
			block = block@mOP2block(blockInfo, fid);
			block.interpreter = 'EMPTY';
		end % mOP2block_empty
		function data = get.data(block)
			if block.data_set == true
				data = block.data_copy;
				return
			end
			fid = block.fid;
			blockInfo = block.blockInfo;
			
			% IMPLEMENT EVERYTHING HERE
			
			data.nothing = true;
			
			block.data_set = true;
			block.data_copy = data;
		end % get.data
		
	end % methods
end