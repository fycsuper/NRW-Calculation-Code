clear all
clc
%Import date
data=xlsread('Hourly weighing data.xlsx','weight');

%Find nighttime weighing data,Rn<0
[m,n]=find(data(:,4)>0);
%Set daytime weighing data to 0
data(m,1:3)=0;

%Calculate the hourly quality difference
for  i=1:2
    for j=1:length(data)-1
        d(j,i)=data(j+1,i)-data(j,i);
    end  
end

%Convert the amount of dew expressed in terms of quality to
%the amount of dew expressed in terms of water depth
%（The diameter of the lysimeter is 80 cm）
r=10*d/(pi*40*40);%Formula for cdew amount.：D=10Δm/ρπr^2

%Excluding evaporation and setting the threshold for the formation of dew.
%（The maximum formation rate of dew is 0.07mm/h）
r(r>0.07|r<0)=0;

%Calculate daily dew amount
VAL=reshape(r(:,1),24,length(r)/24);
BAL=reshape(r(:,2),24,length(r)/24);

%Calculate nighttime precipitation
p=data(1:end-1,3);
P=reshape(p,24,length(p)/24);
P1=sum(P);

%Excluding the amount of dew during rainy nights
[m,n]=find(P1>0);
VAL(:,n)=0;BAL(:,n)=0;

%Calculate the daily dew amount
dewVAL_h=reshape(VAL,24*length(VAL),1);
dewBAL_h=reshape(BAL,24*length(BAL),1);
dewVAL_d=sum(VAL)';
dewBAL_d=sum(BAL)';

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
dateRange_d = startDate_d:endDate_d;%day
dateRange_h = startDate_h: hours(1):endDate_h;%hour

% Convert date to string format
dateStrings_d = cellstr(datestr(dateRange_d, 'yyyy/mm/dd'));
dateStrings_h = cellstr(datestr(dateRange_h, 'yyyy/mm/dd hh:00'));

%Write the variable name
header = {'Date', 'VAL', 'BAL'};
R_d=num2cell([dewVAL_d dewBAL_d]);
R_h=num2cell([dewVAL_h dewBAL_h]);

A_d=[dateStrings_d R_d];
A_h=[dateStrings_h R_h];

H_d=[ header;A_d];
H_h=[ header;A_h];

% Write to Excel file
xlswrite('Result_DEW.xlsx', H_d,'Day');
xlswrite('Result_DEW.xlsx', H_h,'Hour');




