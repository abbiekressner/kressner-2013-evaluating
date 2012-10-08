[~,OBJ]=system('echo $OBJ');
[~,MODEL]=system('echo $MODEL');

addpath(OBJ);
addpath(strcat(OBJ,'HASQI/'));
addpath(strcat(OBJ,'HASQI/CarneyModel/'));
addpath(strcat(OBJ,'HASQI/Kates/'));
addpath(strcat(OBJ,'AmplitudeConversionOfModelInputs/'));
addpath(strcat(OBJ,'HASQI/analysisAndPlottingTools/'));
addpath(MODEL);

clear('OBJ','MODEL');
