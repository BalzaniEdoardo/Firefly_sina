function concat_str = concat_smr_log(smr,log)
   % get fields of smr
   fields_smr = fieldnames(smr);
   % empty struct creation
   concat_str = struct();
   for ii = length(fields_smr)
       % check if field is present in both
       if isfield(log,fields_smr{ii})
            % concat structure
            concat_str.(fields_smr{ii}) = catstruct(log.(fields_smr{ii}),smr.(fields_smr{ii}));
       % otherwise store field
       else
           concat_str.(fields_smr{ii}) = smr.(fields_smr{ii});
       end
   end
   % get fields of log
   fields_log = fieldnames(log);
   for ii = length(fields_log)
       % check if field is not present in concatenated and add
       if ~isfield(concat_str,fields_log{ii})
           concat_str.(fields_log{ii}) = log.(fields_log{ii});
       end
   end
   
end