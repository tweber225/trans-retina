function compare_reg_results(hyperList1,hyperList2)

numFrames = size(hyperList1.transPeakHList,1);
frameNums = 1:numFrames;

% plot 1: Cross-correlation peak heights
figure;
subplot(3,1,1)
plot(frameNums,hyperList1.transPeakHList,frameNums,hyperList2.transPeakHList)
ylabel('Absolute XC Peak')

subplot(3,1,2)
plot(frameNums,hyperList1.transPeakHList/max(hyperList1.transPeakHList),frameNums,hyperList2.transPeakHList/max(hyperList2.transPeakHList))
ylabel('Normalized XC Peak')

subplot(3,1,3)
plot(frameNums,hyperList1.transPeakHList - hyperList2.transPeakHList)
ylabel('XC Peak Difference')
hold on;plot(frameNums,zeros(size(frameNums)),'k')

% plot 2: Translation comparison
figure;
subplot(2,1,1)
plot(frameNums,hyperList1.transHList,frameNums,hyperList2.transHList)
ylabel('Absolute Translation')

subplot(2,1,2)
plot(frameNums,hyperList1.transHList - hyperList2.transHList)
ylabel('Translation Difference')
hold on;plot(frameNums,zeros(size(frameNums)),'k')

% plot 3: Rotation comparison
figure;
subplot(2,1,1)
plot(frameNums,hyperList1.rotHList,frameNums,hyperList2.rotHList)
ylabel('Absolute Rotation')

subplot(2,1,2)
plot(frameNums,hyperList1.rotHList - hyperList2.rotHList)
ylabel('Rotation Difference')
hold on;plot(frameNums,zeros(size(frameNums)),'k')
