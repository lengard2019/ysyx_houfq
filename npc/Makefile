TOPNAME = IDU_ysyx
NXDC_FILES = constr/top.nxdc
INC_PATH ?=
 
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert
 
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

# EXCLUDE_FILE = ./vsrc/cpu_top.v
 
default: $(BIN)
 
$(shell mkdir -p $(BUILD_DIR))
 
# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@
 
# project source
VSRCS = $(shell find $(abspath ../ysyxSoC/vsrc) -name "*.v" -or -name "*.vh" )
VSRCS += $(shell find $(abspath ./vsrc_npc) -name "*.v" )
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCSS = $(shell find $(abspath ./csrc/src) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

SIM_ALU = $(wildcard ./sim_file/sim_alu.cpp)
SIM_SRAM = $(wildcard ./sim_file/sim_sram.cpp)
SIM_IFU = $(wildcard ./sim_file/sim_ifu.cpp)
 
# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk
 
# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
 
$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

sim_ifu:
	verilator -Wno-fatal --cc $(VSRC3) $(VSRC4) $(VSRC5) $(VSRC6) $(VSRC7) $(VSRC8) $(VSRC9) -LDFLAGS -lreadline --exe $(SIM_IFU) --top-module cpu_top  --trace 
	make -C obj_dir -f Vcpu_top.mk Vcpu_top
	./obj_dir/Vcpu_top

sim_sram:
	verilator -Wno-fatal --cc $(VSRC5) -LDFLAGS -lreadline --exe $(SIM_SRAM) --top-module SRAM  --trace 
	make -C obj_dir -f VSRAM.mk VSRAM
	./obj_dir/VSRAM

sim:
	verilator -Wno-fatal --cc $(VSRC1) $(VSRC2) $(VSRC3) $(VSRC4) --exe $(CSRC_SIM) --top-module ALU_ysyx  --trace 
	make -C obj_dir -f VALU_ysyx.mk VALU_ysyx
	./obj_dir/VALU_ysyx

run:
	verilator -Wno-fatal --cc $(VSRCS) -I/home/dengzibin/ysyx-workbench/ysyxSoC/vsrc --exe $(CSRCSS) -LDFLAGS -lreadline -CFLAGS "-I/home/dengzibin/ysyx-workbench/npc/csrc/include"\
		--top-module npc_top --trace-fst
	make -C obj_dir -f Vnpc_top.mk Vnpc_top
	./obj_dir/Vnpc_top $(ARGS) $(IMG)

run_nv: $(BIN)
	@$^

clean_obj:
	rm -rf $(BUILD_DIR)
 
.PHONY2: default all clean run

debug:
	@echo "All files found:"
	@echo "\nFiles after exclusion:"
	@echo $(VSRCS)