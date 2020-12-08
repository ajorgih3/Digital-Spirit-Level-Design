-- SQ_Duration.VHD (a peripheral module for SCOMP)
-- 2020.10.25
--
-- Generates a square wave for a certain duration
-- with period and length dependant on value
-- sent from SCOMP

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY SQ_Duration IS
	PORT(BIGCLOCK,CLOCK, LITTLECLOCK,
		RESETN,
		CS       : IN STD_LOGIC;
		IO_DATA  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		SQ       : OUT STD_LOGIC
	);
END SQ_Duration;


ARCHITECTURE a OF SQ_Duration IS

	
	-- Build an enumerated type for the state machine
	type state_type is (NoSound,Sound, ForeverSound);

	-- Register to hold the current state
	SIGNAL STATE    : state_type;
	SIGNAL DurationCount: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL COUNT    : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL DURATION : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL COMPARE  : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL D        : STD_LOGIC;


BEGIN

	PROCESS (BIGCLOCK, CLOCK, LITTLECLOCK, CS, RESETN)
	BEGIN
		
		IF (RESETN = '0') THEN
			COMPARE <= "0000000000";
			DURATION <= "000000";
		ELSIF rising_edge(CS) THEN
			COMPARE <= IO_DATA(15 DOWNTO 6); -- Latch compare and duration value when IO_Write is asserted
			DURATION <= IO_DATA(5 DOWNTO 0);
		END IF;
		
		
		-- State Machine
		IF (rising_edge(BIGCLOCK)) THEN -- BIGCLOCK is 10MHz
			CASE STATE is
				WHEN NoSound =>
					IF ((CS='1') AND (DURATION = "000000")) THEN  -- When IO_Write is asserted transition to Sound
						STATE <= ForeverSound;
					ELSIF CS = '1' Then
						STATE <= Sound;
					Else
						STATE <= NoSound;  -- Otherwise stay in NoSound
					END IF;
				WHEN Sound =>
					IF (DurationCount) >= DURATION THEN -- When the desired duration has been counted to transition to NoSound
						STATE <= NoSound;  
					ELSE 
						STATE <= Sound; -- Otherwise stay in Sound
					END IF;
				WHEN ForeverSound =>
					IF ((CS = '1') AND (DURATION = "000000")) THEN  -- When IO_Write is asserted transition to Sound
						STATE <= ForeverSound;
					ELSIF CS = '1' Then
						STATE <= Sound;
					Else
						STATE <= ForeverSound;  -- Otherwise stay in NoSound
					END IF;
			END CASE;
		END IF;
	
		IF (rising_edge(CLOCK)) THEN -- CLOCK is 100kHz
			CASE STATE is
				WHEN NoSound =>
					D <= '0'; -- When in NoSound State play nothing
				WHEN Sound =>
					IF (COUNT+1) >= COMPARE THEN
						COUNT <= "0000000000";   -- When half the clock has counted to half the period flip the output 
						D <= not D;
					-- else, increment counter
					ELSE
						COUNT <= COUNT + 1;
					END IF;
				WHEN ForeverSound =>
					IF (COUNT+1) >= COMPARE THEN
						COUNT <= "0000000000";   -- When half the clock has counted to half the period flip the output 
						D <= not D;
					-- else, increment counter
					ELSE
						COUNT <= COUNT + 1;
					END IF;
				END CASE;
			END IF;
			
			IF (rising_edge(LITTLECLOCK)) THEN -- LITTLECLOCK is 10 Hz, Maybe we should use 100 Hz to get finer control over duration
				CASE STATE is
					WHEN NoSound =>
						DurationCount <= "000000"; -- just keep duration at 0
					WHEN ForeverSound =>
						DurationCount <= "000000";
					WHEN Sound =>
						DurationCount <= DurationCount + 1; -- increment durationCount every clock cycle while in Sound
				END CASE;
			END IF;
	END PROCESS;
	
	SQ <= D;
	
END a;

