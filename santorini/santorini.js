// todo - add select boxes to allow god choices
var pantheon = [
	{ name: "Athena" }, { name: "Pan" }, { name: "Dionysos" },
	{ name: "Demeter" }, { name: "Atlas" }, { name: "Poseidon" },
	{ name: "Aphrodite" }, { name: "Ares" }, { name: "Artemis" },
	{ name: "Hades" }, { name: "Apollo" }, { name: "Medusa" },
	{ name: "Gaia" }, { name: "Clio" }, { name: "Bia" },
	{ name: "Persephone" }, { name: "Morpheus" }, { name: "Bellerophon" },
	{ name: "Achilles" }, { name: "Aeolus" }, { name: "Hecate" },
	{ name: "Heracles" }, { name: "Theseus" }, { name: "Hera" },
	{ name: "Polyphemus" }, { name: "Charybdis" }
];

var rowHeights = [ 415, 415, 432, 443, 443, 435, 457, 433, 490, ];
var rowOffsets = [ 95, 513, 919, 1347, 1793, 2244, 2674, 3135, 3557, ];

function setup() {
	var firstCard = Math.floor(Math.random() * pantheon.length);
	var secondCard = -1;
	displayGod("card1", pantheon[firstCard].name);
	while (true) {
		secondCard = Math.floor(Math.random() * pantheon.length);
		if (secondCard != firstCard) {
			displayGod("card2", pantheon[secondCard].name);
			break;
		}
	}

	// set up dropdowns
	var sel1 = $("select#picker1");
	var sel2 = $("select#picker2");
	var sortedPantheon = [];
	for (var i = 0 ; i < pantheon.length ; i++) {
		var cardName = (pantheon[i]).name;
		sortedPantheon.push(cardName);
	}

	sortedPantheon.sort();
	for (var i = 0 ; i < sortedPantheon.length ; i++) {
		var cardName = sortedPantheon[i];
		$("<option/>").attr("value", cardName).html(cardName).appendTo(sel1);
		$("<option/>").attr("value", cardName).html(cardName).appendTo(sel2);
	}

	sel1.val(pantheon[firstCard].name);
	sel2.val(pantheon[secondCard].name);

	sel1.change(cardPicked);
	sel2.change(cardPicked);
}

function cardPicked(e) {
	var dd = $(this);
	displayGod("card" + dd.attr("id").slice(-1), dd.val());
}

function getGridPosFromIndex(idx) {
	var row = Math.floor(idx / 3);
	var col = idx - row * 3;

	return { col: col, row: row };
}

function getCardIndexByName(cardName) {
	for (var i = 0 ; i < pantheon.length ; i++) {
		var card = pantheon[i];
		if (card.name.toLowerCase() == cardName.toLowerCase()) {
			return i;
		}
	}
	return -1;
}

function displayGod(divId, cardName) {
	var cardIdx = getCardIndexByName(cardName);
	if (cardIdx != -1) {
		var gridPos = getGridPosFromIndex(cardIdx);
		displayGodAtGridPos(divId, gridPos.row, gridPos.col);
	} else {
		console.log("could not find card [" + cardName + "]");
	}
}

function displayGodAtGridPos(divId, row, col) {
	var baseXOffset = 30;
	var slotWidth = 208;
	var xPos = baseXOffset + (col*slotWidth);

	var yPos = rowOffsets[row];

	var slotHeight = rowHeights[row];

	var posCssVal = "-" + xPos + "px" + " -" + yPos + "px";
	var heightCssVal = slotHeight + "px";

	$("#" + divId).css("background-position", posCssVal).css("height", heightCssVal);
}

$(document).ready(setup);
