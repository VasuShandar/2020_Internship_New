% Import files and make data sheet
Date1012 = ImportDataFiles("BehaviorData/1012.txt");
Date1013 = ImportDataFiles("BehaviorData/1013.txt");
Date1014 = ImportDataFiles("BehaviorData/1014.txt");
Date1015 = ImportDataFiles("BehaviorData/1015.txt");
Date1016 = ImportDataFiles("BehaviorData/1016.txt");
Date1017 = ImportDataFiles("BehaviorData/1017.txt");
Date1019 = ImportDataFiles("BehaviorData/1019.txt");
Date1020 = ImportDataFiles("BehaviorData/1020.txt");
DataSheet = {'Box', 'Sex', 'Date', 'Infusions', 'HeadEntries', 'Latency', 'ActivePresses', 'InactivePresses'};
DataSheetFinal = [DataSheet;BehavioralDataScript(Date1012);BehavioralDataScript(Date1013);BehavioralDataScript(Date1014);BehavioralDataScript(Date1015);BehavioralDataScript(Date1016);BehavioralDataScript(Date1017);BehavioralDataScript(Date1019);BehavioralDataScript(Date1020)];
