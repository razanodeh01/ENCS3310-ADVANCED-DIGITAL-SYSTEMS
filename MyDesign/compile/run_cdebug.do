#############################################################
# vsimsa environment configuration
set dsn $curdir
log $dsn/log/vsimsa.log
@echo
@echo #################### Starting C Code Debug Session ######################
cd $dsn/src
amap MyDesign $dsn/MyDesign/MyDesign.lib
set worklib MyDesign
# simulation
asim -callbacks -O5 +access +w_nets +accb +accr +access +r +m+TestGenerater TestGenerater
run -all
#############################################################