-----------------------------------------------------------------------------
-- LEON3 Demonstration design test bench configuration
-- Copyright (C) 2009 Aeroflex Gaisler
------------------------------------------------------------------------------
library techmap;
use techmap.gencomp.all;

library grlib;
use grlib.config.all;


package config is

-- cfgmap
  
  -- AHB slave index
  constant RAM_HSINDEX      : integer := 0;
  constant ROM_HSINDEX      : integer := 1;

  
  -- AHB slave address
  constant RAM_HADDR        : integer := 16#000#;
  constant RAM_HMASK        : integer := 16#FF0#;
  constant ROM_HADDR        : integer := 16#C00#;
  constant ROM_HMASK        : integer := 16#E00#;
  
  -- APB slave index
  constant GRVER_PINDEX     : integer := 0;
  constant GRGPIO_PINDEX    : integer := 1;


  -- APB slave address
  constant GRVER_PADDR      : integer := 16#020#;
  constant GRVER_PMASK      : integer := 16#FFF#;
  constant GRGPIO_PADDR     : integer := 16#030#;
  constant GRGPIO_PMASK     : integer := 16#FFF#;



  -- IRQ
  constant ROM_HIRQ      : integer := 1;


-- Technology and synthesis options
  constant CFG_FABTECH : integer := artix7;
  constant CFG_MEMTECH : integer := artix7;
  constant CFG_PADTECH : integer := artix7;
  
  
-- NOEL-V processor core
  constant CFG_NCPU         : integer := (1);
  constant CFG_CACHED       : integer := 0;
  constant CFG_WBMASK       : integer := 0;--16#50FF#;
  constant CFG_CMEMCONF     : integer := 0 + 4 * 0 + 16 * 0; 
  constant CFG_FPUCONF      : integer := 0; 
  constant CFG_RFCONF       : integer := 0 + 16 * 0;
  constant CFG_MULCONF      : integer := 0 + 16 * 0;
  constant CFG_DISAS        : integer := 0;
  constant CFG_AHBTRACE     : integer := 0;
  constant CFG_CFG          : integer := (2)*256 + (1)*128 + (1)*2 + (1);
  constant CFG_NODBUS       : integer := 0;
  
-- DSU UART
  constant CFG_AHB_UART : integer := 0;
  
-- JTAG based DSU interface
  constant CFG_AHB_JTAG : integer := 0;

-- AHB RAM
  constant CFG_AHBRAMEN : integer := 1;
  constant CFG_AHBRSZ   : integer := 8;
  constant CFG_AHBRPIPE : integer := 0;
  constant CFG_AHBRMAS  : integer := 32;
  constant CFG_AHBRST   : integer := 0;
  constant CFG_AHBREND  : integer := 0;

-- SPI memory controller
  constant CFG_SPIMCTRL             : integer := 1;

  constant CFG_SPIMCTRL_FADDR       : integer := 16#000#;
  constant CFG_SPIMCTRL_FMASK       : integer := 16#ff0#;
  constant CFG_SPIMCTRL_IOADDR      : integer := ROM_HADDR;
  constant CFG_SPIMCTRL_IOMASK      : integer := ROM_HMASK;
  constant CFG_SPIMCTRL_SPLITEN     : integer := 1;
  constant CFG_SPIMCTRL_OEPOL       : integer := 0;
  constant CFG_SPIMCTRL_SDCARD      : integer := 0;
  constant CFG_SPIMCTRL_READCMD     : integer := 16#3B#;
  constant CFG_SPIMCTRL_DUMMYBYTE   : integer := 1;
  constant CFG_SPIMCTRL_DUALOUTPUT  : integer := 0;
  constant CFG_SPIMCTRL_SCALER      : integer := (1);
  constant CFG_SPIMCTRL_ASCALER     : integer := (1);
  constant CFG_SPIMCTRL_MAXAHB      : integer := 32;
  constant CFG_SPIMCTRL_OFFSET      : integer := 0;
  constant CFG_SPIMCTRL_QUADOUTPUT  : integer := 1;
  constant CFG_SPIMCTRL_DUALINPUT   : integer := 0;
  constant CFG_SPIMCTRL_QUADINPUT   : integer := 1;
  constant CFG_SPIMCTRL_DUMMYCYCL   : integer := 0;
  constant CFG_SPIMCTRL_DSPI        : integer := 0;
  constant CFG_SPIMCTRL_QSPI        : integer := 1;
  constant CFG_SPIMCTRL_EXTADDR     : integer := 0;
  constant CFG_SPIMCTRL_RECONF      : integer := 0;

-- GPIO port
  constant CFG_GRGPIO_ENABLE  : integer := 1;
  constant CFG_GRGPIO_WIDTH   : integer := (16);
  constant CFG_GRGPIO_IMASK   : integer := 16#0#;
  constant CFG_GRGPIO_OEPOL   : integer := 0;
  constant CFG_GRGPIO_SRST    : integer := 0;
  constant CFG_GRGPIO_BYP     : integer := 0;
  constant CFG_GRGPIO_STST    : integer := 0;
  constant CFG_GRGPIO_BPDIR   : integer := 0;
  constant CFG_GRGPIO_PIRQ    : integer := 0;
  constant CFG_GRGPIO_IRQGEN  : integer := 0;
  constant CFG_GRGPIO_IFLAG   : integer := 0;
  constant CFG_GRGPIO_BPMODE  : integer := 0;
  constant CFG_GRGPIO_INPEN   : integer := 0;
  
-- REV  
  constant REVISION : integer := 130;
end;
