NFiles=1;
colvec=c(1);
grid.col='gray';
pchvec=c(1);
legend.txt=c('recal');
lty.vec=c(1);
pdf(file="<outdir_path>/recabQC/recabQCtest/recab/QCFiles/SampleID1.qplot.pdf", height=12, width=12);
par(mfrow=c(2,2)); par(cex.main=1.4); par(cex.lab=1.2); par(cex.axis=1.2);par(mar=c(5.1, 4.1, 4.1, 4.1))
X=vector("list", NFiles);
Y=vector("list", NFiles);
Z=vector("list", NFiles);
x = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,36);
y = c(0.229,2.024,3.861,13.576,6.057,15.944,19.346,19.362,25.024,22.079,25.023,24.419,24.508,29.183,25.997,25.178,26.752,28.343,27.705,35.520,31.494,35.171,30.908,27.987,26.144,27.139,26.839,50,50,50,50,50,50,50,50,50);
if(length(x)==0) x = NA; X[[1]] = x;
if(length(y)==0) y = NA; Y[[1]] = y;
z = c(0.001,0.000,0.001,0.006,0.001,0.007,0.007,0.006,0.009,0.004,0.008,0.006,0.005,0.007,0.008,0.010,0.010,0.014,0.019,0.025,0.021,0.013,0.005,0.001,0.001,0.001,0.000,0.001,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000);
if(length(z)==0) z = NA; Z[[1]] = z;
MAX.X=0; MAX.Y=0; MAX.Z=0;
 for(i in 1:NFiles){
m.x=max(X[[i]]);
if(length(Y[[i]])==1 & is.na(Y[[i]][1]) | length(which(!is.na(Y[[i]])))==0)m.y=NA else m.y=max(Y[[i]][which(!is.na(Y[[i]]))]);
m.z=max(Z[[i]]);
if(!is.na(m.x) & MAX.X<m.x) MAX.X=m.x;
if(!is.na(m.y) & MAX.Y<m.y) MAX.Y=m.y;
if(!is.na(m.z) & MAX.Z<m.z) MAX.Z=m.z;
}
plot(X[[1]],Y[[1]],xlab='Reported Phred', ylab='Empirical Phred', xlim=range(0, MAX.X*1.2), ylim=range(0, max(MAX.X,MAX.Y)), type='l',col=colvec[1], main=' Empirical vs reported Phred score');
if(NFiles>1)
 for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');
points(x,x,col='purple', type='l');
ratio = MAX.Z/20;
for(i in 1:NFiles) {points(X[[i]][1:length(X[[i]])], Z[[i]][1:length(Z[[i]])]/ratio, col=colvec[i], type='l', lty=2);
}
legend("topright",legend=legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(seq(MAX.X*1.2), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(seq(MAX.Y), n= 10), lty="dotted", col = "lightgray")
mtext(text="Base Count (M)", side=4, line= 2.5, cex=par()$cex*1.2)
axis.left.tick = pretty(seq(MAX.Y))
axis.right.tick = axis.left.tick[axis.left.tick <= 20]
axis.right.text = round(ratio * axis.right.tick, 1)
axis(side = 4, at = axis.right.tick, labels= axis.right.text)

x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48);
y = c(23.911,27.790,27.354,26.569,25.595,26.948,25.055,24.836,24.586,24.580,25.070,24.806,23.229,25.915,23.564,22.887,22.060,22.312,20.653,22.312,19.442,19.359,19.700,19.124,19.389,18.046,18.953,18.501,17.628,16.751,16.917,15.669,15.564,15.114,14.435,16.195,18.237,6.021,50,18.451,10.000,10.607,7.533,8.653,6.564,9.744,6.368,6.021);
X[[1]] = x;
Y[[1]] = y;
z = c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5565);
Z[[1]] = z/1000000;
MAX=0;MIN.Y=999999999; MAX.Z=0; 
 for(i in 1:NFiles){
if(length(which(!is.na(Y[[i]])))==0){m=NA; mm=NA;} else {m=max(Y[[i]][which(!is.na(Y[[i]]))]);mm=min(Y[[i]][which(!is.na(Y[[i]]))]);}; m.z=max(Z[[i]]); 
 if(!is.na(m) & MAX<m) MAX=m; if(!is.na(mm) & MIN.Y>mm) MIN.Y=mm; if(MAX.Z<m.z) MAX.Z=m.z; 
}
plot(X[[1]],Y[[1]], xlim=range(1, length(X[[1]])*1.2), ylim=range(0,MAX*1.2), xlab='Cycle', ylab='Empirical Phred', type='l',col=colvec[1], main=' Empirical Phred score by cycle');
if(NFiles>1)
 for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');
ratio = MIN.Y/MAX.Z;
for(i in 1:NFiles) points(X[[i]], Z[[i]]*ratio/1.2, col=colvec[i], type='l', lty=2);
legend("topright",legend=legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(range(1, length(X[[1]])*1.2), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(seq(MAX.Y), n= 10), lty="dotted", col = "lightgray")
mtext(text="Read Count (M)", side=4, line= 2.5, cex=par()$cex*1.2)
axis.left.tick = pretty(seq(MAX.Y))
axis.right.tick = axis.left.tick[axis.left.tick <= 20]
axis.right.text = round(ratio * axis.right.tick, 1)
axis(side = 4, at = axis.right.tick, labels= axis.right.text)

z = c(1717,1500,2329,2285,2093,2184,2506,2991,4021,4874,5859,6978,8012,10499,15566,22592,33605,49646,71004,101234,143814,200394,270206,356402,458741,572907,699869,835056,974502,1112700,1253114,1385015,1505984,1616317,1719434,1808010,1882132,1931594,1964924,1981248,1983243,1976495,1968813,1967829,1971190,1981459,1993259,1993797,1956731,1889212,1796523,1684630,1572563,1467535,1373573,1274662,1169398,1049862,917602,782115,657645,549670,457252,379853,314628,258881,212733,170122,134723,104534,81187,64368,51003,41830,34612,30040,27084,25006,21864,19003,16344,14170,11498,8973,6918,4859,3157,2189,1314,832,722,435,343,180,128,40,25,31,0,0);
x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100);
y = c(NA,NA,NA,NA,NA,NA,NA,1.005,1.005,1.005,1.005,1.005,1.005,1.005,1.005,1.097,1.042,1.005,1.005,1.005,1.005,1.016,1.022,1.021,1.016,1.014,1.010,1.012,1.021,1.014,1.013,1.017,1.018,1.014,1.016,1.021,1.020,1.019,1.018,1.019,1.020,1.021,1.018,1.021,1.023,1.019,1.018,1.018,1.017,1.021,1.024,1.026,1.027,1.030,1.028,1.021,1.014,1.014,1.021,1.025,1.030,1.020,1.026,1.017,1.028,1.015,1.009,1.009,1.036,1.080,1.152,1.005,1.005,1.068,1.027,1.005,1.005,1.005,1.005,1.005,1.005,1.005,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA);
X[[1]] = x;
Y[[1]] = y;
MAX=0;
 for(i in 1:NFiles){
 x=X[[i]][20:80];
 y=Y[[i]][20:80]; 
if(length(which(!is.na(y)))==0)m=NA else m=max(y[which(!is.na(y))]);
if(!is.na(m) & MAX<m) MAX=m;
}
mm=vector(); mat=vector();
for(i in 1:NFiles) mat = rbind(mat, Y[[i]]);
mm=sapply(data.frame(mat), min);
plot(X[[1]],Y[[1]], xlim=range(0,120), ylim=range(0,MAX*1.2), xlab='GC content', ylab='Normalized mean depth', type='l', col=colvec[1], main=' Mean depth vs. GC');
if(NFiles>1) 
 for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');
abline(h=1.0, col='red', lty=2);
zz = (z/1000)/(sum(z/1000));
mm.r = mm/zz; mm.r.mid = mm.r[20:80]; if(length(which(!is.na(mm.r.mid)))==0)min.r=NA else min.r = min(mm.r.mid[!is.na(mm.r.mid)]); 
 z = zz*max(2,(min.r*0.5)); 
points(X[[1]], z, type='h', col='purple');
legend("topright", legend=legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(range(0,120), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(range(0,MAX*1.2), n= 10), lty="dotted", col = "lightgray")

x = c(32,35,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,297,298,299,300,301,302,303,304,305,306,307,308,310,311,312,313,314,315,316,317,318,320,321,322,324,325,326,327,329,330,331,332,333,334,335,336,337,338,339,340,341,344,345,346,347,348,349,351,352,354,355,356,357,358,359,361,365,367,368,369,370,371,372,373,374,375,376,378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,396,397,398,399,401,406,408,409,410,412,413,414,415,417,418,419,420,421,422,423,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,506,507,509,511,512,514,515,516,517,518,519,520,522,523,524,525,526,527,528,529,530,532,533,534,535,536,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,576,578,579,580,582,583,584,585,586,588,592,594,597,600,616,662,709,441167,1033367,2542032,3498816,6149702,7496984,8274228,11544189,19649898,20335008,24732178,33488083,42610761);
y = c(1,2,2,4,3,2,3,3,3,2,2,1,2,4,3,6,1,2,2,5,2,4,6,3,2,4,4,5,3,4,4,5,11,4,3,7,7,6,5,4,6,5,7,5,6,7,5,11,4,5,7,5,4,7,8,5,8,5,3,9,3,9,2,2,10,7,4,4,7,10,10,4,4,2,6,13,4,5,2,7,8,6,7,5,2,4,9,6,3,8,5,5,4,6,8,11,8,7,4,9,6,6,6,6,5,8,9,8,10,12,9,8,4,11,8,7,7,7,5,3,7,6,4,8,4,7,10,6,6,7,5,2,6,9,4,5,10,5,4,5,5,3,10,8,7,4,5,6,5,7,6,3,6,4,5,4,7,5,5,3,4,9,7,1,3,5,4,12,6,4,3,4,3,4,3,6,8,5,4,3,3,7,4,6,3,4,8,5,4,5,4,3,4,6,8,5,5,3,2,2,6,2,2,1,3,5,1,4,4,4,6,2,2,4,4,3,8,4,5,2,5,3,1,5,1,2,2,4,1,4,3,4,6,1,2,4,6,2,5,4,4,1,6,3,3,1,2,1,2,1,3,4,1,1,5,2,5,6,2,1,4,1,2,1,2,2,1,2,3,2,4,4,4,3,3,2,3,2,1,4,2,2,5,1,2,1,3,3,5,3,3,3,3,3,3,4,1,4,3,1,2,2,2,3,1,1,4,2,4,1,2,1,3,2,3,1,5,2,3,3,5,1,3,2,1,2,3,2,2,2,1,3,1,2,1,3,3,1,1,1,3,2,1,1,1,1,1,2,2,1,2,1,1,1,1,2,1,1,1,3,2,6,2,1,1,3,5,3,2,1,1,5,3,3,4,5,3,4,5,1,5,4,2,3,3,7,11,8,3,4,9,6,8,2,6,8,11,9,9,13,5,10,9,10,8,11,5,16,6,12,12,9,7,10,13,9,7,6,9,11,5,6,10,7,5,6,2,2,3,2,6,4,3,2,6,1,4,3,2,4,1,2,3,1,4,1,1,1,1,2,2,3,2,1,2,4,1,2,1,6,4,1,1,1,3,3,3,4,3,1,2,1,1,2,1,5,1,4,5,6,2,4,4,4,5,4,6,5,5,4,2,2,1,5,4,4,1,2,1,2,1,1,2,5,2,1,1,2,1,1,2,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
if(length(x)==0) x=NA; if(length(y)==0) y=NA;
X[[1]] = x;
Y[[1]] = y;
MAX.X=0; MAX.Y=0; MIN.X=999999999; 
 for(i in 1:NFiles){
if(is.na(X[[i]][1])) next; 
 x=X[[i]];
 y=Y[[i]]; 
 m.y=max(y[which(!is.na(y))]);
 if(MAX.Y<m.y) MAX.Y=m.y;
 m.x=x[which(y==m.y)[1]];
 if(MAX.X<m.x) MAX.X=m.x;
 if(MIN.X>m.x) MIN.X=m.x;
 }
plot(X[[1]],Y[[1]]/1000000, xlim=range(MIN.X-150, MAX.X+150), ylim=range(0,MAX.Y/1000000*1.2), xlab='Insert size', ylab='Count in million', type='l', col=colvec[1], main=' Insert size distribution');
if(NFiles>1) 
 for(i in 2:NFiles) points(X[[i]], Y[[i]]/1000000, col=colvec[i], type='l');
legend("topright",legend=legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(range(MIN.X-150, MAX.X+150), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(range(0,MAX.Y/1000000*1.2), n= 10), lty="dotted", col = "lightgray")

x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48);
y = c(5316,5187,5178,5095,5052,4982,4975,5050,4975,5017,5019,4944,4932,4930,4908,4915,4919,4890,4839,4932,4931,4818,4806,4845,4703,4545,4605,4615,4045,4104,3922,3726,3441,3315,3056,2923,2549,1,12,2,7,1,0,0,1,0,0,1);
X[[1]] = x;
Y[[1]] = y;
MAX=0;MIN.Y=999999999; MAX.Z=0; 
 for(i in 1:NFiles){
if(length(which(!is.na(Y[[i]])))==0){m=NA; mm=NA;} else {m=max(Y[[i]][which(!is.na(Y[[i]]))]);mm=min(Y[[i]][which(!is.na(Y[[i]]))]);}; m.z=max(Z[[i]]); 
 if(!is.na(m) & MAX<m) MAX=m; if(!is.na(mm) & MIN.Y>mm) MIN.Y=mm; if(MAX.Z<m.z) MAX.Z=m.z; 
}
plot(X[[1]],Y[[1]], xlim=range(1, length(X[[1]])*1.2), ylim=range(0,MAX*1.2), xlab='Cycle', ylab='Empirical Q20 base count', type='l',col=colvec[1], main=' Empirical Q20 base count by cycle');
if(NFiles>1)
 for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');
legend("topright",legend=legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(range(1, length(X[[1]])*1.2), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(range(0,MAX*1.2), n= 10), lty="dotted", col = "lightgray")

x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254);
y = c(195751,2832,14,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
X[[1]] = x;
Y[[1]] = y;
total.site = 63025520
depth.legend.txt = legend.txt
for(i in 1:NFiles){depth.legend.txt[i] = paste(legend.txt[i], '  (No coverage = ',round((1-sum(Y[[i]])/total.site)*100,2), '% )'); Y[[i]]=(sum(Y[[i]]) - cumsum(Y[[i]]))/total.site * 100; }
MAX.X=0; MAX.Y=0; 
for(i in 1:NFiles){
 tmp = length(which(Y[[i]] > max(Y[[i]])*0.6)) ; 
 if (tmp < 10) tmp = 10; 
 if (MAX.X < tmp) MAX.X = tmp; 
 if (MAX.Y < max(Y[[i]])) MAX.Y = max(Y[[i]]); }
plot(X[[1]],Y[[1]], xlim=range(1, MAX.X), ylim=range(0,MAX.Y*1.2), xlab='Depth', ylab='Percentage of covered sites', pch = '+', type='b', col=colvec[1], main=' Depth distribution');
if(NFiles>1) 
 for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], pch = '+', type='b');
legend("topright",legend=depth.legend.txt, col=colvec, lty=lty.vec);
abline(v=pretty(range(0,MAX.X), n= 10), lty="dotted", col = "lightgray")
abline(h=pretty(range(0,MAX.Y*1.2), n= 10), lty="dotted", col = "lightgray")

labelvec=c('recal');
legend.txt=c('Total', 'Mapped', 'Paired', 'ProperPair','Dup', 'QCFail');
x=c(0.010);
y=c(0.006);
z=c(0.010);
u=c(0.004);
v=c(0.000);
w=c(0.000);
pchvec=c(1,2,3,4,5,6); colvec=c(1,2,3,4,5,6);
plot(x, xlab='Bam file index', ylab='Read count in million', ylim=range(0, max(x)*1.4), main=' Flag stats', pch=pchvec[1],col=colvec[1], type='b', axes=F);
points(y, pch=pchvec[2], col=colvec[2], type='b');
points(z, pch=pchvec[3], col=colvec[3], type='b');
points(u, pch=pchvec[4], col=colvec[4], type='b');
points(v, pch=pchvec[5], col=colvec[5], type='b');
points(w, pch=pchvec[6], col=colvec[6], type='b');
axis(side=1, at=c(1:length(x)), labels=labelvec);
axis(side=2);
box(); 
legend("topleft", legend=legend.txt, col=c(1,2,3,4,5,6), lty=1, pch=pchvec, merge=TRUE, horiz=F,cex=0.9);
abline(v=seq(x), lty="dotted", col = "lightgray")
abline(h=pretty(seq(0, max(x)*1.4), n= 10), lty="dotted", col = "lightgray")

x1=c(0.995);
x2=c(0.169);
ratio = max(x2)/max(x1);
if (ratio > 5 || (ratio < 1/5 && ratio >= 1e-10)) {;
x2 = x2 / ratio;
} else {;
ratio = 1;
};
ylim = range(-max(x2), max(x1)) * 1.2;
y1lim = range(0, max(x1)) * 1.2;
y2lim = range(-max(x2), 0) * 1.2;
barplot(x1, ylim= ylim, axes = F, names.arg=c('recal'), xlab='Bam file index', col='light blue', main='\nMean depth of sequencing / Empirical Q20 count');
barplot(-x2, ylim= ylim, axes = F, add = T, col = 'light pink');
tick.pos = pretty(y1lim);
tick.text = as.character(pretty(y1lim));
tick.text[1] = NA;
axis(side = 2, at = tick.pos, labels = tick.text );
abline(h=tick.pos, lty="dotted", col = "lightgray");
tick.pos = pretty(y2lim*ratio)/ratio;
axis(side = 2, at = tick.pos, labels= as.character(-pretty(y2lim*ratio)));
abline(h=tick.pos, lty="dotted", col = "lightgray");
mtext(side = 2, 'Mean depth', adj = 1, line = 3, cex = par()$cex * 1.2);
mtext(side = 2, 'Q20 count in million', adj = 0, line = 3, cex = par()$cex * 1.2);

q()
