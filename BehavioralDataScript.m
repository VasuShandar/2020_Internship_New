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
       T(i,3)= (Date1020(row,2));
    end
    % take value at column next to instance of string and sort by gender
    if num2str(Date1020{row,1}) == "Box"
        j = j +1;
       T{j,1}= (Date1020{row,2});
       if num2str(T{j, 1})== "1" ||num2str(T{j, 1})== "2" ||num2str(T{j, 1})== "3" ||num2str(T{j,1})== "4" 
           T{j, 2} = "Female";
       else 
           T{j, 2} = "Male";
       end 
   
    end
    % split data points in C array and add to corresponding file
   if num2str(Date1020{row,1}) == "C" 
       h = h+1;
       C = strsplit(num2str(Date1020{row+1,2}));
       D = strsplit(num2str(Date1020{row+2,2}));
       E = strsplit(num2str(Date1020{row+3,2}));

       T{h, 4} = C{2};       
       T{h, 5} = C{6};
       T{h, 6} = D{6};
       T{h, 7} = E{2};
       T{h, 8} = E{3};
   end 


    
end
a = T;
end


   
