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

library work;
use work.config.all;

package cfgmap is

  -- AHB master index
  
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

end; 
