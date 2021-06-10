function plotKstat(obj,row)
  
  a = 0;  b = obj.numCols*obj.spatialStepSize;
  xK = a : (b-a)/1000 : b;
  
  % calculate the K-statistic
  K = obj.getKstat(row);
  
  % calculate the L-statistic
  L = sqrt(K/pi)' - xK;

  %% Plot the K and L statistics
  
  % K-function
  subplot(2,1,1); plot(xK, K, 'k');
  title('$\hat{K}$ function','Interpreter','latex','FontSize',14);
  xlabel('$r$','Interpreter','latex','FontSize',14);
  ylabel('$\hat{K}(r)$','Interpreter','latex','FontSize',14);
  xlim([0 sqrt((b-a)/2)]);
  
  % L-stat
  subplot(2,1,2); plot(xK,K);
  title('$L$-Statistic','Interpreter','latex','FontSize',14);
  xlabel('$h$', 'Interpreter', 'latex');
  ylabel('$\sqrt{\hat{K}/\pi}-h$', 'Interpreter', 'latex');
  xlim([0 sqrt((b-a)/2)]);


end %plotKstat