clear

load targetportfolio.mat
[BacktestResult,err] = CTABacktest_GeneralPlatform_3(TargetPortfolioAdj);
BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);