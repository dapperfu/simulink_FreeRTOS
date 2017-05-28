function rtwTargetInfo(tr)
% rtwTargetInfo used to add ARM DSP CMSIS Target Function Library 
%
  tr.registerTargetInfo(@locTflRegFcn);
end

function thisTfl = locTflRegFcn
%TFL registration
thisTfl = RTW.TflRegistry;
thisTfl.Name = 'ARM CMSIS 3.01';
thisTfl.TableList = {'crl_table_cmsis'};
thisTfl.BaseTfl = 'C89/C90 (ANSI)';
%thisTfl.TargetHWDevice = {'ARM Compatible->ARM Cortex'};
thisTfl.TargetHWDevice = {'*'};
thisTfl.Description = 'CMSIS 3.01 Optimized Library';
end