// #led_0 will always be on top, #led_1 is one clockwise, etc.
var numLights = 16;
var center = { x: 200, y: 200 };
var radius = 100;
var animationTicks = 0;
var animationInterval;
var animationStyle;
var animationDirection = 1;
var ANIMATION_TICK = 100;
var MAX_TICKS = -1;

var dataStorage = Array();

function deg2rad(deg) {
	return (deg / 180) * Math.PI;
}

// getNextIdx / getPrevIdx take care of wrapping around the ring
function getNextIdx(idx, amt) {
	if (amt == undefined) { amt = 1; }

	var rv = idx + amt;
	if (rv >= numLights) {
		return rv % numLights;
	} else {
		return rv;
	}
}

function getPrevIdx(idx, amt) {
	if (amt == undefined) { amt = 1; }

	var rv = idx - amt;
	if (rv < 1) {
		rv = numLights + rv;
	}

	if (rv >= numLights) {
		return rv % numLights;
	} else {
		return rv;
	}
}

function setupLights() {
	var ledRing = $("#ledRing");
	var angleChunk = 360 / numLights;
	console.log("angle chunk [" + angleChunk + "]");
	for (var i = 0 ; i < numLights ; i++) {

		var angle = deg2rad((angleChunk * i) - 90);
		xPos = center.x + radius*Math.cos(angle);
		yPos = center.y + radius*Math.sin(angle);

		var led = $("<div/>").addClass("led").css({ left: xPos, top: yPos }).attr("id", "led_" + i).appendTo(ledRing);

		dataStorage.push({ color: undefined });
	}

	console.log(dataStorage);
}

function setProp(idx, propName, propVal) {
	// console.log("setting [" + propName + "] to [" + propVal + "] at [" + idx + "]");
	if (propVal != undefined) {
		dataStorage[idx][propName] = propVal;

		if (propName.charAt(0) == "_") { return; }

		var led = $("#led_" + idx);
		if (propName == "brightness") {
			led.css("-webkit-filter", "brightness(" + propVal + ")");
		} else {
			led.addClass(propName + "_" + propVal);
		}
	}
}

function removeProp(idx, propName, propVal) {
	if (propVal != undefined) {
		dataStorage[idx][propName] = undefined;

		if (propName.charAt(0) == "_") { return; }

		var led = $("#led_" + idx);
		if (propName == "brightness") {
			console.log("HOW TO REMOVE BRIGHTNESS?");
		} else {
			led.removeClass(propName + "_" + propVal);
		}
	}
}

function setInitialColorsB() {
	for (var i = 0 ; i < numLights ; i++) {
		var color = Math.random();
		if (color <= .33) {
			setProp(i, "color", "red");
		} else if (color <= .66) {
			setProp(i, "color", "orange");
		} else {
			setProp(i, "color", "yellow");
		}
		setProp(i, "brightness", Math.random());
		setProp(i, "_pulseAmt", Math.random() / 3);
	}
}

function setInitialColorsA() {
	setProp(0, "color", "red");
	setProp(1, "color", "orange");
	setProp(2, "color", "yellow");
	setProp(3, "color", "green");
	setProp(4, "color", "blue");
	setProp(5, "color", "indigo");
	setProp(6, "color", "violet");
	setProp(7, "color", "black");
}

function animateChase() {
	var initialState = Array();
	// save the initial color state otherwise we get weirdness at the wraparound point...
	for (var i = 0 ; i < numLights ; i++) {
		initialState.push(dataStorage[i].color);
	}

	for (var i = numLights - 1 ; i >= 0 ; i--) {
		removeProp(i, "color", initialState[i]);
		if (animationDirection == 1) {
			setProp(i, "color", initialState[getPrevIdx(i)]);
		} else {
			setProp(i, "color", initialState[getNextIdx(i)]);
		}
	}
}

function animatePulse() {
	var re = /brightness\((.*)\)/;
	for (var i = 0 ; i < numLights ; i++) {
		var led = $("#led_" + i);
		var match = re.exec(led.css("-webkit-filter"));
		// console.log(led.attr("id") + " has brightness [" + match[1] + "]");

		var pulser = Number(dataStorage[i]["_pulseAmt"]);
		var nextB = Number(match[1]) + pulser;

		if (pulser > 0) {
			if (nextB >= 1) {
				setProp(i, "_pulseAmt", pulser * -1);
				nextB = 1;
			}
		} else {
			if (nextB <= 0) {
				setProp(i, "_pulseAmt", pulser * -1);
				nextB = 0;
			}
		}
		setProp(i, "brightness", nextB);
	}
}

function animate() {
	animationTicks++;

	if (animationStyle == "chase") {
		animateChase();
	} else if (animationStyle == "bounce") {
		animateChase();
		if (animationTicks % numLights == 0) {
			animationDirection *= -1;
		}
	} else if (animationStyle == "pulse") {
		animatePulse();
	}

	if (MAX_TICKS > 0 && animationTicks >= MAX_TICKS) {
		clearInterval(animationInterval);
		animationInterval = null;
	}
}

function resetAnimation(animStyle) {
	if (animationInterval != null) {
		clearInterval(animationInterval);
	}

	animationStyle = animStyle;
	animationTicks = 0;
	animationDirection = 1;

	animationInterval = setInterval(function() {
		animate();
	}, ANIMATION_TICK);
}

$(document).ready(function() {
	$("#animationPicker").change(function() { resetAnimation($(this).val()); });
	setupLights();
	// setInitialColorsA();
	setInitialColorsB();
	console.log("------");
	resetAnimation($("#animationPicker").val());
});
