------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2022, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; version 2.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
use grlib.config.all;
use grlib.config_types.all;

library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.memctrl.all;
use gaisler.spi.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.noelv.all;

library work;
use work.config.all;

entity noelvcore is
  generic (
    devid                   : integer := NOELV_SOC
    );
  port (
    -- Clock & reset
    clkm        : in  std_ulogic;
    rstn        : in  std_ulogic;

    -- SPI
    spi_rom_cs_n          : out   std_ulogic;
    spi_rom_clk           : out   std_ulogic;
 
    spi_rom_mosi_i    : in   std_ulogic;
    spi_rom_mosi_o    : out   std_ulogic;
    spi_rom_mosi_oen  : out   std_ulogic;

    spi_rom_din_i     : in   std_ulogic;
    spi_rom_din_o     : out   std_ulogic;
    spi_rom_din_oen   : out   std_ulogic;

    spi_rom_do2_i     : in   std_ulogic;
    spi_rom_do2_o     : out   std_ulogic;
    spi_rom_do2_oen   : out   std_ulogic;

    spi_rom_do3_i     : in   std_ulogic;
    spi_rom_do3_o     : out   std_ulogic;
    spi_rom_do3_oen   : out   std_ulogic;

    -- GPIO
    gpio_i      : in  std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
    gpio_o      : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
    gpio_oe     : out std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0);
    -- UART
    uart_rx     : in  std_ulogic;
    uart_tx     : out std_ulogic
  );
end;

architecture rtl of noelvcore is
  
  -- Constants ------------------------

-- Number of external masters connected to processor AHB bus
  constant nextmst  : integer := 1;

-- Number of external slaves connected to processor AHB bus
  constant nextslv  : integer := CFG_AHBRAMEN + CFG_SPIMCTRL;
  
-- Number of external slaves connected to APB bus
  constant nextapb  : integer := CFG_GRGPIO_ENABLE;

-- Number of debug masters connected to debug ports
  constant ndbgmst  : integer := 1;

  -- Signals --------------------------

  -- Misc
  signal vcc        : std_ulogic;
  signal gnd        : std_ulogic;

  signal dsuen     : std_ulogic;
  signal dsubreak  : std_ulogic;
  signal cpu0errn  : std_ulogic;


  -- APB
  signal apbi       : apb_slv_in_vector;
  signal apbo       : apb_slv_out_vector := (others => apb_none);

  -- AHB
  signal ahbsi      : ahb_slv_in_type;
  signal ahbso      : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi      : ahb_mst_in_type;
  signal ahbmo      : ahb_mst_out_vector := (others => ahbm_none);
  signal dbgmi      : ahb_mst_in_vector_type(ndbgmst-1 downto 0);
  signal dbgmo      : ahb_mst_out_vector_type(ndbgmst-1 downto 0);
  
  -- AHB memory bus
  signal mem_ahbsi  : ahb_slv_in_type;
  signal mem_ahbso  : ahb_slv_out_vector := (others => ahbs_none);
  signal mem_ahbmi  : ahb_mst_in_type;
  signal mem_ahbmo  : ahb_mst_out_vector := (others => ahbm_none);

  signal u1i   : uart_in_type;
  signal u1o   : uart_out_type;

  -- GPIOs
  signal gpioi      : gpio_in_type;
  signal gpioo      : gpio_out_type;

  -- SPI
  signal spmi : spimctrl_in_type;
  signal spmo : spimctrl_out_type;

begin
  vcc         <= '1';
  gnd         <= '0';

  dsuen         <= '1';
  dsubreak      <= '0';

  ----------------------------------------------------------------------
  ---  NOEL-V SUBSYSTEM ------------------------------------------------
  ----------------------------------------------------------------------

  ahbmo(1) <= ahbm_none;
  dbgmo(0) <= ahbm_none;

  noelv0 : noelvsys 
    generic map (
      fabtech   => CFG_FABTECH,
      memtech   => CFG_MEMTECH,
      ncpu      => CFG_NCPU,
      nextmst   => nextmst,
      nextslv   => nextslv,
      nextapb   => nextapb,
      ndbgmst   => ndbgmst,
      cached    => CFG_CACHED,
      wbmask    => CFG_WBMASK,
      busw      => AHBDW,
      cmemconf  => CFG_CMEMCONF,
      fpuconf   => CFG_FPUCONF,
      rfconf    => CFG_RFCONF,
      mulconf   => CFG_MULCONF,
      disas     => CFG_DISAS,
      ahbtrace  => CFG_AHBTRACE,
      cfg       => CFG_CFG,
      devid     => devid,
      nodbus    => CFG_NODBUS
      )
    port map(
      clk       => clkm, -- : in  std_ulogic;
      rstn      => rstn, -- : in  std_ulogic;
      -- AHB bus interface for other masters (DMA units)
      ahbmi     => ahbmi, -- : out ahb_mst_in_type;
      ahbmo     => ahbmo(CFG_NCPU+nextmst-1 downto CFG_NCPU), -- : in  ahb_mst_out_vector_type(ncpu+nextmst-1 downto ncpu);
      -- AHB bus interface for slaves (memory controllers, etc)
      ahbsi     => ahbsi, -- : out ahb_slv_in_type;
      ahbso     => ahbso(nextslv-1 downto 0), -- : in  ahb_slv_out_vector_type(nextslv-1 downto 0);
      -- AHB master interface for debug links
      dbgmi     => dbgmi(ndbgmst-1 downto 0), -- : out ahb_mst_in_vector_type(ndbgmst-1 downto 0);
      dbgmo     => dbgmo(ndbgmst-1 downto 0), -- : in  ahb_mst_out_vector_type(ndbgmst-1 downto 0);
      -- APB interface for external APB slaves
      apbi      => apbi, -- : out apb_slv_in_type;
      apbo      => apbo, -- : in  apb_slv_out_vector;
      -- Bootstrap signals
      dsuen     => dsuen, -- : in  std_ulogic;
      dsubreak  => dsubreak, -- : in  std_ulogic;
      cpu0errn  => cpu0errn, -- : out std_ulogic;
      --dmreset   => dmreset, 
      -- UART connection
      uarti     => u1i, -- : in  uart_in_type;
      uarto     => u1o  -- : out uart_out_type
      );
  
  uart_tx       <= u1o.txd;
  u1i.ctsn      <= '0';
  u1i.rxd       <= uart_rx;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ahbramgen : if CFG_AHBRAMEN = 1 generate
    ahbram0 : ahbram
      generic map (hindex => RAM_HSINDEX, haddr    => RAM_HADDR,  hmask      => RAM_HMASK, 
                   tech   => CFG_MEMTECH, kbytes   => CFG_AHBRSZ, pipe       => CFG_AHBRPIPE,
                   maccsz => CFG_AHBRMAS, scantest => CFG_AHBRST)
      port map (rstn, clkm, ahbsi, ahbso(RAM_HSINDEX));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(RAM_HSINDEX) <= ahbs_none; end generate;


----------------------------------------------------------------------
---  SPI Memory controller -------------------------------------------
----------------------------------------------------------------------

  -- OPTIONALY set the offset generic (only affect reads).
  -- The first 4MB are used for loading the FPGA.
  spimctrl1 : spimctrl
  generic map (hindex       => ROM_HSINDEX,             hirq => ROM_HIRQ,                       faddr => CFG_SPIMCTRL_FADDR, fmask => CFG_SPIMCTRL_FMASK,
               ioaddr       => CFG_SPIMCTRL_IOADDR,     iomask => CFG_SPIMCTRL_IOMASK,          spliten => CFG_SPIMCTRL_SPLITEN,
               oepol        => CFG_SPIMCTRL_OEPOL,      sdcard => CFG_SPIMCTRL_SDCARD,          readcmd => CFG_SPIMCTRL_READCMD,
               dummybyte    => CFG_SPIMCTRL_DUMMYBYTE,  dualoutput => CFG_SPIMCTRL_DUALOUTPUT,  scaler => CFG_SPIMCTRL_SCALER, 
               altscaler    => CFG_SPIMCTRL_ASCALER,    maxahbaccsz => CFG_SPIMCTRL_MAXAHB,     offset => CFG_SPIMCTRL_OFFSET, 
               quadoutput   => CFG_SPIMCTRL_QUADOUTPUT, dualinput => CFG_SPIMCTRL_DUALINPUT,    quadinput => CFG_SPIMCTRL_QUADINPUT, 
               dummycycles  => CFG_SPIMCTRL_DUMMYCYCL,  dspi => CFG_SPIMCTRL_DSPI,              qspi => CFG_SPIMCTRL_QSPI, 
               extaddr      => CFG_SPIMCTRL_EXTADDR,    reconf => CFG_SPIMCTRL_RECONF)
  port map (rstn, clkm, ahbsi, ahbso(ROM_HSINDEX), spmi, spmo);
  
  spmi.miso <= spi_rom_din_i;
  spmi.mosi <= spi_rom_mosi_i;
  spmi.io2  <= spi_rom_do2_i;
  spmi.io3  <= spi_rom_do3_i;

  spi_rom_din_o  <= spmo.miso;
  spi_rom_mosi_o <= spmo.mosi;
  spi_rom_do2_o  <= spmo.io2;
  spi_rom_do3_o  <= spmo.io3;
  
  spi_rom_din_oen  <= spmo.misooen;
  spi_rom_mosi_oen <= spmo.mosioen;
  spi_rom_do2_oen  <= spmo.iooen;
  spi_rom_do3_oen  <= spmo.iooen;

  spi_rom_clk  <= spmo.sck;
  spi_rom_cs_n <= spmo.csn;


  ----------------------------------------------------------------------
  --- APB Bridge and various periherals --------------------------------
  ----------------------------------------------------------------------

  -- GPIO units
  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate

    grgpio_ledsw : grgpio
      generic map(
        pindex   => GRGPIO_PINDEX,    paddr  => GRGPIO_PADDR,      pmask    => GRGPIO_PMASK,
        nbits    => CFG_GRGPIO_WIDTH, imask  => CFG_GRGPIO_IMASK,  oepol    => CFG_GRGPIO_OEPOL,
        syncrst  => CFG_GRGPIO_SRST,  bypass => CFG_GRGPIO_BYP,    scantest => CFG_GRGPIO_STST,
        bpdir    => CFG_GRGPIO_BPDIR, pirq   => CFG_GRGPIO_PIRQ,   irqgen   => CFG_GRGPIO_IRQGEN,
        iflagreg => CFG_GRGPIO_IFLAG, bpmode => CFG_GRGPIO_BPMODE, inpen    => CFG_GRGPIO_INPEN)
      port map(
        rst   => rstn,
        clk   => clkm,
        apbi  => apbi(GRGPIO_PINDEX),
        apbo  => apbo(GRGPIO_PINDEX),
        gpioi => gpioi,
        gpioo => gpioo);

    -- Tie-off alternative output enable signals
    gpioi.sig_en        <= (others => '0');
    gpioi.sig_in        <= (others => '0');

    gpio_o  <= gpioo.dout(CFG_GRGPIO_WIDTH-1 downto 0);
    gpio_oe <= gpioo.oen(CFG_GRGPIO_WIDTH-1 downto 0);
    gpioi.din(CFG_GRGPIO_WIDTH-1 downto 0)  <= gpio_i;
  end generate;

  -- Version
  grver0 : grversion
    generic map(
      pindex      => GRVER_PINDEX,
      paddr       => GRVER_PADDR,
      pmask       => GRVER_PMASK,
      versionnr   => CFG_CFG,
      revisionnr  => REVISION)
    port map(
      rstn  => rstn,
      clk   => clkm,
      apbi  => apbi(GRVER_PINDEX),
      apbo  => apbo(GRVER_PINDEX));

end rtl;

