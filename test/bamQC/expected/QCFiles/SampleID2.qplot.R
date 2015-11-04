NFiles=1;
colvec=c(1);
grid.col='gray';
pchvec=c(1);
legend.txt=c(1);
lty.vec=c(1);
pdf(file="<outdir_path>/bamQC/bamQCtest/QCFiles/SampleID2.qplot.pdf", height=12, width=12);
par(mfrow=c(2,2)); par(cex.main=1.4); par(cex.lab=1.2); par(cex.axis=1.2);par(mar=c(5.1, 4.1, 4.1, 4.1))
X=vector("list", NFiles);
Y=vector("list", NFiles);
Z=vector("list", NFiles);
x = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37);
y = c(0.114,1.649,3.110,13.895,5.699,16.595,19.586,19.449,25.008,23.938,28.826,30.806,31.290,36.156,33.914,38.157,36.281,29.235,29.227,25.123,21.973,12.304,50,26.053,50,50,50,50,13.617,50,50,50,50,50,50,50,50,50);
if(length(x)==0) x = NA; X[[1]] = x;
if(length(y)==0) y = NA; Y[[1]] = y;
z = c(0.001,0.000,0.001,0.009,0.001,0.012,0.013,0.014,0.028,0.013,0.034,0.024,0.016,0.017,0.010,0.007,0.004,0.003,0.001,0.001,0.000,0.000,0.000,0.000,0.001,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000,0.000);
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

x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76);
y = c(22.751,22.766,22.278,21.652,20.161,21.468,20.614,23.052,20.948,22.079,23.623,23.318,20.937,21.670,20.318,21.461,20.940,22.068,18.741,19.654,21.301,22.510,23.012,20.616,19.173,19.483,20.018,19.259,19.611,18.616,19.480,19.487,18.610,18.513,20.278,16.728,18.691,17.777,18.987,17.860,17.913,17.667,17.417,16.969,17.329,17.398,18.326,16.930,17.657,17.265,16.377,17.042,16.102,16.115,16.087,16.737,15.900,16.120,15.826,15.343,15.609,15.637,16.542,15.992,15.012,16.442,16.535,16.625,16.242,14.906,14.256,11.230,9.031,7.460,9.379,8.603);
X[[1]] = x;
Y[[1]] = y;
z = c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3292);
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
y = c(NA,NA,NA,NA,0.680,0.680,0.680,0.680,0.680,0.680,1.308,1.069,1.179,1.151,1.119,1.134,1.119,1.178,1.028,1.050,1.067,1.159,1.154,1.125,1.127,1.144,1.143,1.104,1.098,1.102,1.092,1.085,1.076,1.047,1.048,1.032,1.034,1.043,1.030,1.031,1.017,1.008,1.018,1.028,1.020,1.016,1.011,1.010,0.987,0.975,0.965,0.974,0.969,0.988,0.978,0.931,0.914,0.919,0.907,0.901,0.912,0.908,0.914,0.889,0.931,0.890,0.896,0.884,0.925,0.840,0.809,0.882,0.915,0.826,0.699,0.742,0.796,0.878,0.784,0.750,0.850,1.118,0.680,0.680,0.680,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA);
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

x = c(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,111,112,114,115,117,118,119,124,129,131,133,134,139,142,153,163,165,166,177,180,182,193,11575405,13571365,18995745,35392245);
y = c(1,2,6,19,21,29,51,53,59,69,84,92,90,72,94,89,75,83,55,52,49,46,33,37,21,16,15,11,13,6,4,7,4,4,10,3,4,3,6,3,7,3,3,1,1,2,1,2,2,1,1,1,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1);
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

x = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76);
y = c(3087,2626,2424,2484,2443,2470,2390,2569,2482,2459,2465,2445,2558,2441,2508,2513,2460,2489,2446,2441,2399,2533,2528,2468,2400,2456,2527,2403,2348,2346,2476,2470,2356,2373,2435,2373,2453,2445,2471,2339,2287,2399,2347,2304,2407,2333,2381,2385,2262,2237,2378,2282,2298,2390,2321,2146,2184,2156,1882,1897,1737,1725,1644,1447,1310,1316,1296,1081,981,817,652,289,6,2,1,0);
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
y = c(71717,70525,148,38,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
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

labelvec=c(1);
legend.txt=c('Total', 'Mapped', 'Paired', 'ProperPair','Dup', 'QCFail');
x=c(0.010);
y=c(0.003);
z=c(0.010);
u=c(0.002);
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

x1=c(1.470);
x2=c(0.158);
ratio = max(x2)/max(x1);
if (ratio > 5 || (ratio < 1/5 && ratio >= 1e-10)) {;
x2 = x2 / ratio;
} else {;
ratio = 1;
};
ylim = range(-max(x2), max(x1)) * 1.2;
y1lim = range(0, max(x1)) * 1.2;
y2lim = range(-max(x2), 0) * 1.2;
barplot(x1, ylim= ylim, axes = F, names.arg=c(1), xlab='Bam file index', col='light blue', main='\nMean depth of sequencing / Empirical Q20 count');
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
