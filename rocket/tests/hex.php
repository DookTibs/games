<?php
	define("HEXTYPE_CITY", "city");
	define("HEXTYPE_RAILWAY_TOWN", "railway_town");
	define("HEXTYPE_TOWN", "town");

	class RocketGame {
		private $mapCities;

		function __construct($debugMode) {
			if (!$debugMode) {
				header ("Content-type: image/png"); 
			} else {
				echo "constructing!";
			}

			$this->mapCities = array(
				// railway towns are where the individual companies start. these have colors.
				"Liverpool" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "0,1", "color" => "255/0/0", "railway" => "L&Y"),
				"Bristol" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "0,12", "color" => "255/0/0", "railway" => "GWR"),
				"Stoke" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "2,4", "color" => "255/0/0", "railway" => "LNWR"),
				"Southhampton" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "5,15", "color" => "255/0/0", "railway" => "LSWR"),
				"York" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "8,0", "color" => "255/0/0", "railway" => "NER"),
				"Norwich" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "14,7", "color" => "255/0/0", "railway" => "GER"),
				"Dover" => array("type" => HEXTYPE_RAILWAY_TOWN, "position" => "15,14", "color" => "255/0/0", "railway" => "SER"),

				// towns are the "others". these have a generic picture/icon/color.
				"Salisbury" => array("type" => HEXTYPE_TOWN, "position" => "3,12"),
				"Leeds" => array("type" => HEXTYPE_TOWN, "position" => "4,0"),
				"Derby" => array("type" => HEXTYPE_TOWN, "position" => "5,4"),
				"Oxford" => array("type" => HEXTYPE_TOWN, "position" => "5,10"),
				"Ragby" => array("type" => HEXTYPE_TOWN, "position" => "6,7"),
				"Avesbury" => array("type" => HEXTYPE_TOWN, "position" => "8,11"),
				"Lincoln" => array("type" => HEXTYPE_TOWN, "position" => "9,2"),
				"Peterborough" => array("type" => HEXTYPE_TOWN, "position" => "10,7"),
				"Ashford" => array("type" => HEXTYPE_TOWN, "position" => "12,14"),

				// cities are where you find goods. Also uniquely colored.
				"Gloucester" => array("type" => HEXTYPE_CITY, "position" => "2,10", "color" => "252/126/127"),
				"Hertford" => array("type" => HEXTYPE_CITY, "position" => "11,10", "color" => "141/72/53"),
				"Sheffield" => array("type" => HEXTYPE_CITY, "position" => "6,2", "color" => "121/124/205"),
				"Brighton" => array("type" => HEXTYPE_CITY, "position" => "10,16", "color" => "155/112/175"),
				"Guildford" => array("type" => HEXTYPE_CITY, "position" => "8,14", "color" => "187/189/45"),
				"Nottingham" => array("type" => HEXTYPE_CITY, "position" => "8,5", "color" => "104/154/156"),
				"Cambridge" => array("type" => HEXTYPE_CITY, "position" => "12,9", "color" => "122/177/113"),
				"London" => array("type" => HEXTYPE_CITY, "position" => "10,13", "color" => "230/79/124"),
				"Reading" => array("type" => HEXTYPE_CITY, "position" => "6,13", "color" => "169/113/48"),
				"Birmingham" => array("type" => HEXTYPE_CITY, "position" => "3,6", "color" => "143/122/115"),
				"Manchester" => array("type" => HEXTYPE_CITY, "position" => "3,1", "color" => "236/226/244"),
				"Northampton" => array("type" => HEXTYPE_CITY, "position" => "7,8", "color" => "129/149/43")
			);


			
			if (false) {
				$handle = ImageCreate(1600, 1700) or die ("Cannot Create image");
				ImageColorAllocate ($handle, 0, 255, 255);
			} else {
				$handle = imagecreatefromjpeg("england.jpg");
			}

			// $txt_color = ImageColorAllocate ($handle, 255, 0, 0);
			// ImageString ($handle, 5, 5, 18, "HELLO WORLD", $txt_color);

			$this->drawGrid($handle);

			if (!$debugMode) {
				ImagePng ($handle);
			}
		}

		function imagelinethick($image, $x1, $y1, $x2, $y2, $color, $thick = 1) {
			/* this way it works well only for orthogonal lines
			imagesetthickness($image, $thick);
			return imageline($image, $x1, $y1, $x2, $y2, $color);
			*/
			if ($thick == 1) {
				return imageline($image, $x1, $y1, $x2, $y2, $color);
			}
			$t = $thick / 2 - 0.5;
			if ($x1 == $x2 || $y1 == $y2) {
				return imagefilledrectangle($image, round(min($x1, $x2) - $t), round(min($y1, $y2) - $t), round(max($x1, $x2) + $t), round(max($y1, $y2) + $t), $color);
			}
			$k = ($y2 - $y1) / ($x2 - $x1); //y = kx + q
			$a = $t / sqrt(1 + pow($k, 2));
			$points = array(
				round($x1 - (1+$k)*$a), round($y1 + (1-$k)*$a),
				round($x1 - (1-$k)*$a), round($y1 - (1+$k)*$a),
				round($x2 + (1+$k)*$a), round($y2 - (1-$k)*$a),
				round($x2 + (1-$k)*$a), round($y2 + (1+$k)*$a),
			);
			imagefilledpolygon($image, $points, 4, $color);
			return imagepolygon($image, $points, 4, $color);
		}

		function generateHexPoints($centerX, $centerY, $size) {
			$points = array();
			for ($i = 0 ; $i < 6 ; $i++) {
				$angle = (2 * M_PI / 6 * $i);

				$loopX = $centerX + $size * cos($angle);
				$loopY = $centerY + $size * sin($angle);

				$points[] = array($loopX, $loopY);
			}
			return $points;
		}

		function drawHex($imgHandle, $centerX, $centerY, $size, $occupant) {
			$lineColor = ImageColorAllocate($imgHandle, 0, 0, 0);

			/*
			for ($i = 0 ; $i <= 6 ; $i++) {
				$angle = (2 * M_PI / 6 * $i);

				$loopX = $centerX + $size * cos($angle);
				$loopY = $centerY + $size * sin($angle);

				if ($i > 0) {
					imageline($imgHandle, $prevPoint["x"], $prevPoint["y"], $loopX, $loopY, $lineColor);
				}
				$prevPoint = array("x" => $loopX, "y" => $loopY);
			}
			 */
			$points = $this->generateHexPoints($centerX, $centerY, $size);

			// draw the fill - do this first to guarantee other stuff on top
			if ($occupant != null && isset($occupant->data["color"])) {
				$fillColor = $occupant->data["color"];
				// echo "Attempt fill with [" . $fillColor . "]<br>";

				if ($fillColor != null) {
					$fillColorArray = split("/", $fillColor);
					$r = $fillColorArray[0];
					$g = $fillColorArray[1];
					$b = $fillColorArray[2];
					
					// $fillPoints = generateHexPoints($centerX, $centerY, $size-1);
					$flatArray = array();
					foreach ($points as $p) { array_push($flatArray, $p[0], $p[1]); }
					imagefilledpolygon($imgHandle, $flatArray, 6, ImageColorAllocate($imgHandle, $r, $g, $b));
				}
			}


			// if it's a town, we currently draw an asterisk on it (should rotate if nothing else, or color-code
			// it to match track discs, etc.
			if ($occupant != null && $occupant->data["type"] == HEXTYPE_TOWN) {
				$starPoints = $this->generateHexPoints($centerX, $centerY, $size-10);

				$thickness = 3;
				
				$this->imagelinethick($imgHandle, $starPoints[0][0], $starPoints[0][1], $starPoints[3][0], $starPoints[3][1], $lineColor, $thickness);
				$this->imagelinethick($imgHandle, $starPoints[1][0], $starPoints[1][1], $starPoints[4][0], $starPoints[4][1], $lineColor, $thickness);
				$this->imagelinethick($imgHandle, $starPoints[2][0], $starPoints[2][1], $starPoints[5][0], $starPoints[5][1], $lineColor, $thickness);
			}

			// draw the outline
			foreach ($points as $i => $p) {
				if ($i > 0) {
					imageline($imgHandle, $prevPoint["x"], $prevPoint["y"], $p[0], $p[1], $lineColor);
				}
				$prevPoint = array("x" => $p[0], "y" => $p[1]);
			}
			imageline($imgHandle, $prevPoint["x"], $prevPoint["y"], $points[0][0], $points[0][1], $lineColor); // close the hex

			// imageline($imgHandle, 0, 0, $centerX, $centerY, $lineColor);
		}

		// map is a 17x17 grid but we don't draw many of the hexes. This function hardcodes that info
		function skipCoords($col, $row) {
			$_coordsToSkip = array(
				"0,0", "0,10", "0,11", "0,16",
				"1,10", "1,16",
				"3,16",
				"4,16",
				"5,16",
				"6,16",
				"7,16",
				"8,16",
				"9,16",
				"10,0",
				"11,0", "11,1","11,16",
				"12,0","12,1","12,2","12,3","12,4","12,5",
				"13,0","13,1","13,2","13,3","13,4","13,12","13,16",
				"14,0","14,1","14,2","14,3","14,4","14,12","14,13","14,16",
				"15,0","15,1","15,2","15,3","15,4","15,11","15,12","15,13","15,15","15,16",
				"16,0","16,1","16,2","16,3","16,4","16,5","16,10","16,11","16,12","16,13","16,14","16,15","16,15","16,16",
				"99,99"
			);

			return in_array($col . "," . $row, $_coordsToSkip, true);
		}

	/*
	TOWNS: start positions for the railroads. These have colors

	RAILWAY TOWNS: nothing in them; ex Leeds at 4,1. These have a generic image

	CITIES: contain goods. These have colors.
		steel (gear), textiles (fabric), brewing (barrel), leather (skin), passengers (9 each)
		Gloucester: steel, steel, textiles. 252/126/127
		Hertford: textiles, textiles, steel. 141/72/53
		Sheffield: steel, steel, leather. 121/124/205
		Brighton: leather, leather, steel. 155/112/175
		Guildford: leather, leather, textiles. 187/189/45
		Nottingham: textiles, textiles, leather. 104/154/156
		Cambridge: brewing, brewing, leather. 122/177/113
		London: brewing, brewing, textiles. 230/79/124
		Reading brewing, brewing, steel. 169/113/48
		Birmingham: steel, steel, brewing. 143/122/115
		Manchester: textiles, textiles, brewing. 236/226/244
		Northampton: leather, leather, brewing. 129/149/43
	*/

		function getHexOccupant($col, $row) {
			foreach ($this->mapCities as $city => $cityData) {
				if ($cityData["position"] == $col . "," . $row) {
					$rv = new stdClass();
					$rv->name = $city;
					$rv->data = $cityData;
					return $rv;
				}
			}
			return null;
		}

			/*
		function getHexColorArray($col, $row) {
			$COLORARRAY_CITY = array(-1,-1,-1);
			$COLORARRAY_PURPLE = array(176, 49, 212);
			$COLORARRAY_RED = array(255, 0, 0);
			$COLORARRAY_GREEN = array(0, 255, 0);
			$COLORARRAY_PINK = array(235, 171, 182);
			$COLORARRAY_WHITE = array(255, 255, 255);
			$COLORARRAY_ORANGE = array(255,156,56);
			$COLORARRAY_LIGHTBLUE = array(126,182,242);
			$COLORARRAY_TAN = array(209, 168, 102);
			$COLORARRAY_TEAL = array(99, 207, 196);
			$COLORARRAY_OLIVE = array(118, 129, 51);
			$COLORARRAY_GREY = array(168,168,168);

			$_colorsForHexes = array(
				"0,1" => $COLORARRAY_PURPLE,
				"0,12" => $COLORARRAY_GREEN,
				"2,4" => $COLORARRAY_RED,
				"2,10" => $COLORARRAY_PINK,
				"3,1" => $COLORARRAY_WHITE,
				"3,6" => $COLORARRAY_GREY,
				"3,12" => $COLORARRAY_CITY,
				"4,0" => $COLORARRAY_CITY,
				"5,4" => $COLORARRAY_CITY,
				"5,10" => $COLORARRAY_CITY,
				"5,15" => $COLORARRAY_ORANGE,
				"6,2" => $COLORARRAY_LIGHTBLUE,
				"6,7" => $COLORARRAY_CITY,
				"6,13" => $COLORARRAY_TAN,
				"7,8" => $COLORARRAY_OLIVE,
				"8,5" => $COLORARRAY_TEAL,
				"8,11" => $COLORARRAY_CITY,
				"99,99" => array(0,0,0)
			);

			if (isset($_colorsForHexes[$col . "," . $row])) {
				return $_colorsForHexes[$col . "," . $row];
			}
			return null;
		}
			*/

		function drawGrid($imgHandle) {
			$NUM_ROWS = 17;
			$NUM_COLS = 17;

			// $X_OFFSET = 50;
			// $Y_OFFSET = 50;
			// $hexSize = 30; // size is size of a side, also side from center to a vertex

			$X_OFFSET = 1320;
			$Y_OFFSET = 1675;
			$hexSize = 22; // size is size of a side, also side from center to a vertex

			// for flat topped hexes
			$hexWidth = $hexSize*2;
			$horizDistance = 3/4 * $hexWidth;
			$hexHeight = sqrt(3)/2 * $hexWidth;

			// $X_OFFSET = $hexSize;
			// $Y_OFFSET = $hexHeight/2;

			// this will get the top left hex completely touching borders
			$PADDING = 20;
			$X_OFFSET += $PADDING;
			$Y_OFFSET += $PADDING;

			for ($r = 0 ; $r < $NUM_ROWS ; $r++) {
				for ($q = 0 ; $q < $NUM_COLS ; $q++) {
					$centerX = $X_OFFSET + ($q * $horizDistance);
					$centerY = $Y_OFFSET + ($r * $hexHeight) + ($q % 2 == 1 ? $hexHeight/2 : 0);

					if (!$this->skipCoords($q, $r)) {
						// $fillColorArray = $this->getHexColorArray($q, $r);
						// $this->drawHex($imgHandle, $centerX, $centerY, $hexSize, $fillColorArray);
						$this->drawHex($imgHandle, $centerX, $centerY, $hexSize, $this->getHexOccupant($q, $r));
					}

					if (false && ($r == 0 || $q == 0)) {
						$txt_color = ImageColorAllocate ($imgHandle, 255, 0, 0);
						ImageString ($imgHandle, 32, $centerX - 20, $centerY - 5, $q . "," . $r, $txt_color);
					}
				}
			}
		}
	}


	$sr = new RocketGame(false);

?>
