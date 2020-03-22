all:
	vivado -mode batch -source tcl/run.tcl
	mkdir -p ip
	cp -r ${PROJECT}.srcs/sources_1/ip/${PROJECT}/* ip/.
	cp ${PROJECT}.runs/${PROJECT}_synth_1/${PROJECT}.dcp ip/.

gui:
	vivado -mode gui -source tcl/run.tcl &

clean:
	rm -rf ip/*
	mkdir -p ip
	rm -rf ${PROJECT}.*
	rm -rf component.xml
	rm -rf *.jou
	rm -rf *.log
	rm -rf *.str
	rm -rf *.sdk
	rm -rf *.sim
	rm -rf xgui
	rm -rf .Xil
