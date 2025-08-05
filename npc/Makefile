TOPNAME = IDU_ysyx
NXDC_FILES = constr/top.nxdc
INC_PATH ?=
 
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert
 
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)
 
default: $(BIN)
 
$(shell mkdir -p $(BUILD_DIR))
 
# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@
 
# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCSS = $(shell find $(abspath ./csrc/src) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)
VSRC1 = $(wildcard ./vsrc/ALU_ysyx.v)
VSRC2 = $(wildcard ./vsrc/MuxKey.v)
VSRC3 = $(wildcard ./vsrc/MuxKeyInternal.v)
VSRC4 = $(wildcard ./vsrc/MuxKeyWithDefault.v)
# VSRC3 = $(wildcard ./vsrc/ps2_keyboard.v)
# VSRC6 = $(wildcard ./vsrc/key_count.v)
# CSRC = $(wildcard ./csrc/main.cpp)/home/dengzibin/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32e-npc.bin
CSRC_SIM = $(wildcard ./sim_file/sim_alu.cpp)
 
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

sim:
	verilator -Wno-fatal --cc $(VSRC1) $(VSRC2) $(VSRC3) $(VSRC4) --exe $(CSRC_SIM) --top-module ALU_ysyx  --trace 
	make -C obj_dir -f VALU_ysyx.mk VALU_ysyx
	./obj_dir/VALU_ysyx

run:
	verilator -Wno-fatal --cc $(VSRCS) --exe $(CSRCSS) -LDFLAGS -lreadline -CFLAGS "-I/home/dengzibin/ysyx-workbench/npc/csrc/include" --top-module cpu_top  --trace 
	make -C obj_dir -f Vcpu_top.mk Vcpu_top
	./obj_dir/Vcpu_top -l /home/dengzibin/ysyx-workbench/npc/build/npc-log.txt --diff=/home/dengzibin/ysyx-workbench/npc/csrc/src/tools/nemu-diff/build/riscv32-nemu-interpreter-so $(ARGS) $(IMG)

run_nv: $(BIN)
	@$^

clean_obj:
	rm -rf $(BUILD_DIR)
 
.PHONY2: default all clean run