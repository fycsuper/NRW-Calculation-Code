clear all
clc
%Import date
data=xlsread('Hourly weighing data.xlsx','weight');

%Find nighttime weighing data,Rn<0
[m,n]=find(data(:,4)>0);
%Set daytime weighing data to 0
data(m,1:3)=0;

%Calculate the quality difference, where a quality difference of 
%less than 0 indicates evapotranspiration
for  i=1:2
    for j=1:length(data)-1
        d(j,i)=data(j+1,i)-data(j,i);
    end  
end

%Convert evapotranspiration in terms of quality to evapotranspiration in terms of water.
%The diameter of the lysimeter is 80 cm
r=10*d/(pi*40*40);

%Excluding precipitation and dew (with a positive quality difference)
%Obtain the hourly evapotranspiration and take it as positive
r(r>0|r<-10)=0;
r=0-r;

%Calculate daily evapotranspiration data
VAL=sum(reshape(r(:,1),24,length(r)/24))';
BAL=sum(reshape(r(:,2),24,length(r)/24))';
R=[VAL BAL];
%%
%Output the results to a table
%Set start and end dates
%day
startDate_d = datetime(2020,10,1);
endDate_d = datetime(2023,10,11);

%hour
startDate_h = datetime(2020,10,1,12,0,0);
endDate_h= datetime(2023,10,12,11,0,0);

%Generate date range
dateRange_d = startDate_d:endDate_d;%天
dateRange_h = startDate_h: hours(1):endDate_h;%Date

% Convert date to string format
dateStrings_d = cellstr(datestr(dateRange_d, 'yyyy/mm/dd'));
dateStrings_h = cellstr(datestr(dateRange_h, 'yyyy/mm/dd hh:00'));
%Variable name
header = {'Date', 'VAL', 'BAL'};
R_d=num2cell([VAL BAL]);
R_h=num2cell(r);


A_d=[dateStrings_d R_d];%Day
A_h=[dateStrings_h R_h];%Hour

H_d=[ header;A_d];
H_h=[ header;A_h];

% Write to Excel file
xlswrite('Result_ET.xlsx', H_d,'Day');
xlswrite('Result_ET.xlsx', H_h,'Hour');




