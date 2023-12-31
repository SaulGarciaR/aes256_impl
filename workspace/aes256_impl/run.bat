@echo off

:: toolchain
set YOSYS=../../bin/yosys/yosys.exe
set PR=../../bin/p_r/p_r.exe
set OFL=../../bin/openFPGALoader/openFPGALoader.exe

:: project name and sources
set TOP=aes256_impl
set VLOG_SRC=src/aes256_impl.v src/aes256_enc.v src/byte_mix.v src/counters.v src/key_exp.v src/mix_columns.v src/mix_w.v src/MUL3.v src/round_constant.v src/round_key.v src/sbox.v src/shift_rows.v src/sub_bytes.v src/xtimes.v
set LOG=0

:: Place&Route arguments
set PRFLAGS=-ccf src/%TOP%.ccf

:: do not change
if "%1"=="synth_vlog" (
  if %LOG%==1 (
    start /WAIT /B %YOSYS% -l log/synth.log -p "read -sv %VLOG_SRC%; synth_gatemate -top %TOP% -nomx8 -vlog net/%TOP%_synth.v"
  ) else (
    start /WAIT /B %YOSYS% -ql log/synth.log -p "read -sv %VLOG_SRC%; synth_gatemate -top %TOP% -nomx8 -vlog net/%TOP%_synth.v"
  )
)
if "%1"=="synth_vhdl" (
  if %LOG%==1 (
    start /WAIT /B %YOSYS% -l log/synth.log -p "ghdl --warn-no-binding -C --ieee=synopsys %VHDL_SRC% -e %TOP%; synth_gatemate -top %TOP% -nomx8 -vlog net/%TOP%_synth.v"
  ) else (
    start /WAIT /B %YOSYS% -ql log/synth.log -p "ghdl --warn-no-binding -C --ieee=synopsys %VHDL_SRC% -e %TOP%; synth_gatemate -top %TOP% -nomx8 -vlog net/%TOP%_synth.v"
  )
)
if "%1"=="impl" (
  if %LOG%==1 (
    start /WAIT /B %PR% -i net/%TOP%_synth.v -o %TOP% %PRFLAGS% >&1 | tee log/impl.log
  ) else (
    start /WAIT /B %PR% -i net/%TOP%_synth.v -o %TOP% %PRFLAGS% > log/impl.log
  )
)
if "%1"=="jtag" (
  start /WAIT /B %OFL% -b gatemate_evb_jtag %TOP%_00.cfg
)
if "%1"=="jtag-flash" (
  start /WAIT /B %OFL% -b gatemate_evb_jtag -f --verify %TOP%_00.cfg
)
if "%1"=="spi" (
  start /WAIT /B %OFL% -b gatemate_evb_spi -m %TOP%_00.cfg
)
if "%1"=="spi-flash" (
  start /WAIT /B %OFL% -b gatemate_evb_spi -f --verify %TOP%_00.cfg
)

if "%1"=="clean" (
  del log\*.log 2>NUL
  del net\*_synth.v 2>NUL
  del *.history 2>NUL
  del *.txt 2>NUL
  del *.refwire 2>NUL
  del *.refparam 2>NUL
  del *.refcomp 2>NUL
  del *.pos 2>NUL
  del *.pathes 2>NUL
  del *.path_struc 2>NUL
  del *.net 2>NUL
  del *.id 2>NUL
  del *.prn 2>NUL
  del *_00.V 2>NUL
  del *.used 2>NUL
  del *.sdf 2>NUL
  del *.place 2>NUL
  del *.pin 2>NUL
  del *.cfg* 2>NUL
  del *.cdf 2>NUL
  exit /b 0
)
