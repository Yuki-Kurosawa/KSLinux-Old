
.PHONY: all clean

all: cross-gcc-stage1 cross-gcc-stage2

envsetup.sh: 
	@echo "No envsetup.sh here"
	@exit 1

build.1st: envsetup.sh build.1st.sh
	@cat envsetup.sh >build.1st
	@cat build.1st.sh >>build.1st
	@chmod a+x build.1st

build.2nd: envsetup.sh build.2nd.sh
	@cat envsetup.sh >build.2nd
	@cat build.2nd.sh >>build.2nd
	@sed "11,12d" build.2nd > build.2nd.so
	@mv build.2nd.so build.2nd
	@chmod a+x build.2nd

build.tmp: envsetup.sh build.tmp.sh
	@cat envsetup.sh >build.tmp
	@cat build.tmp.sh >>build.tmp
	@sed "11,12d" build.tmp > build.tmp.so
	@mv build.tmp.so build.tmp
	@chmod a+x build.tmp

cross-gcc-stage1: build.1st
	@./build.1st
	@touch cross-gcc-stage1

cross-gcc-stage2: cross-gcc-stage1 build.2nd 
	@./build.2nd
	@touch cross-gcc-stage2

tmp-system: build.tmp
	@./build.tmp

clean:
	@rm -rf makefile envsetup.sh build.1st build.2nd cross-gcc-stage1 cross-gcc-stage2 build.tmp \
	tmp-system