mkdir -p results
rm -f results/*

../bin/glfMultiples --minMapQuality 0 --minDepth 1 --maxDepth 10000000 --uniformTsTv --smartFilter --ped glfs/glfIndexEmptyFirst.ped -b results/first.vcf > results/first.log 2> results/first.err

../bin/glfMultiples --minMapQuality 0 --minDepth 1 --maxDepth 10000000 --uniformTsTv --smartFilter --ped glfs/glfIndexEmptyLast.ped -b results/last.vcf > results/last.log 2> results/last.err

../bin/glfMultiples --minMapQuality 0 --minDepth 1 --maxDepth 10000000 --uniformTsTv --smartFilter --ped glfs/glfIndexEmptyAll.ped -b results/all.vcf > results/all.log 2> results/all.err


diff -I "##filedate=" results/first.vcf expected/first.vcf
diff -I "##filedate=" results/last.vcf expected/last.vcf
diff -I "##filedate=" results/all.vcf expected/all.vcf

diff -I "Analysis started on " -I "Analysis completed on " results/first.log expected/first.log
diff -I "Analysis started on " -I "Analysis completed on " results/last.log expected/last.log
diff -I "Analysis started on " -I "Analysis completed on " results/all.log expected/all.log
diff results/first.err expected/first.err
diff results/last.err expected/last.err
diff results/all.err expected/all.err
