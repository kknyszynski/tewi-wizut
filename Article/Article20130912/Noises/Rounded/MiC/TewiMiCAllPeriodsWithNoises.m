personNumber = 1;

osoby = {'AB'};%,'KB','MZ','AS'};
noise = [0.9 1.00 1.1];
colors = {'r','g','b'};
strategy = 'C';

numOfLines = 34;

for personIndex = 1: length(osoby)
    colorCounter = 0;
    personInitials = osoby{personIndex};

	par = wczytajCSV(['tewiMiC' personInitials '.csv'],14);
      
    testSize = 401;
    scanPeriodCount = 31;%tylko do 100 �wiec mo�na testowa� 34 okresy, do 200 - 33
    for parNoise=1:length(noise)
        colorCounter = colorCounter +1;
        returns3d = zeros((scanPeriodCount + 3)* 100,testSize, scanPeriodCount);
        returns2d = zeros((scanPeriodCount + 3)* 100,testSize);
        calmars3d = zeros(testSize,testSize, scanPeriodCount);
        for i =1:scanPeriodCount
            C=par(i,:);
            pocz = C(1);
            kon = pocz + testSize;
            zyl = C(2);
            b = noise(parNoise)*C(3);
            wstp = round(noise(parNoise)*C(4));
            wstk = round(noise(parNoise)*C(5));
            lkr = round(noise(parNoise)*C(6));
            SL = noise(parNoise)*C(7);
            TP = noise(parNoise)*C(8);
            op = round(noise(parNoise)*C(9));
            bvol = round(noise(parNoise)*C(10));
            vwst = round(noise(parNoise)*C(11));
            ll3 = round(noise(parNoise)*C(12));
            bawe = noise(parNoise)*C(13);
            bcawe = noise(parNoise)*C(14);
            returns= TewiMiCOnePeriodOneParamSet(pocz, kon, b, wstp, wstk, lkr, SL, TP, op, bvol, vwst, ll3, bawe, bcawe);
            returns3d(1:kon,:,i)= returns;
        end
        
        returns2d = sum (returns3d, 3);
        for i=1:kon
            for j=1:testSize
                returns2d(i,j)= returns2d(i,j) / nnz(returns3d(i,j,:));
            end
        end
        returns2d(isnan(returns2d)) = 0;
        cumulativeReturns = zeros((scanPeriodCount + 3)* 100,testSize);
        for j=1:testSize
            cumulativeReturns(1,j)= returns2d(1,j);
        end
        for i=2:kon
            for j=1:testSize
                cumulativeReturns(i,j)= cumulativeReturns(i-1,j) + returns2d(i,j);
            end
        end
        cumulativeReturnsPerCandle = cumulativeReturns;
        for i=1:kon
            for j=1:testSize
                cumulativeReturnsPerCandle(i,j)= cumulativeReturnsPerCandle(i,j)/j;
            end
        end
        figure(100+personIndex);
        hold all;
        plot(cumulativeReturns(:,100),colors{colorCounter});
        figure(200+personIndex);
        hold all;
        plot(cumulativeReturns(end,:),colors{colorCounter});
        figure(300+personIndex);
        hold all;
        plot(cumulativeReturnsPerCandle(end,:),colors{colorCounter});
    end
    figure(100+personIndex);
    legend('Noise - 0.9', 'No noise', 'Noise - 1.1');
    title([strategy ' cumulativeReturns for 100 ' personInitials]);
    figure(200+personIndex);
    legend('Noise - 0.9', 'No noise', 'Noise - 1.1');
    title([strategy ' cumulativeReturns ' personInitials]);
    figure(300+personIndex);
    legend('Noise - 0.9', 'No noise', 'Noise - 1.1');
    title([strategy ' cumulativReturnPerCandle ' personInitials]);
end