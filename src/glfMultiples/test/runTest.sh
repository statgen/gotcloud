mkdir -p results
rm -f results/*

../bin/glfMultiples --minMapQuality 0 --minDepth 1 --maxDepth 10000000 --uniformTsTv --smartFilter --ped glfs/glfIndexEmptyFirst.ped -b results/first.vcf > results/first.log 2> results/first.err

../bin/glfMultiples --minMapQuality 0 --minDepth 1 --maxDepth 10000000 --uniformTsTv --smartFilter --ped glfs/glfIndexEmptyLast.ped -b results/last.vcf > results/last.log 2> results/last.err

diff results/first.vcf expected/first.vcf
diff results/last.vcf expected/last.vcf

diff -I "Analysis started on " -I "Analysis completed on " results/first.log expected/first.log
diff -I "Analysis started on " -I "Analysis completed on " results/last.log expected/last.log
diff results/first.err expected/first.err
diff results/last.err expected/last.err
