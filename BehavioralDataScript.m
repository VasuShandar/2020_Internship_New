% Function loops through Date file and returns cell array of data points
function a = BehavioralDataScript(file)
% create empty cell array, import file, and create variables for inside for
% loop
T = {};
Date1020 = file;
i =0;
j =0;
h =0;

% looping through every row of the imported data 
for row = 1:(size(Date1020)-1)


    % if the value in the first column is equal to the string, take the
    % value at the same row but second column and append to T
    if num2str(Date1020{row,1}) == "Start Date"
        i = i +1;
       Date(i,1)= datetime(Date1020{row,2});
    end
    % take value at column next to instance of string and sort by gender
    if num2str(Date1020{row,1}) == "Box"
        j = j +1;
       Box(j,1)= (Date1020{row,2});
       if Box(j,1) < 5
           Sex(j, 1) = categorical("Female");
       else 
           Sex(j, 1) = categorical("Male");
       end 
   
    end
    % split data points in C array and add to corresponding file
   if num2str(Date1020{row,1}) == "C" 
       h = h+1;
       C = strsplit(num2str(Date1020{row+1,2}));
       D = strsplit(num2str(Date1020{row+2,2}));
       E = strsplit(num2str(Date1020{row+3,2}));

       Infusions(h, 1) = str2num(C{2});       
       HeadEntries(h, 1) = str2num(C{6});
       Latency(h, 1) = str2num(D{6});
       ActiveLever(h, 1) = str2num(E{2});
       InactiveLever(h, 1) = str2num(E{3});
   end 


    
end
a = table(Box,Date,Sex,Infusions,HeadEntries,Latency,ActiveLever,InactiveLever);
end


   
