const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
	input: fs.createReadStream('input.txt'),
	output: process.stdout,
	terminal: false
});

const SUBSTRING = process.argv[2];
const lines = [];
const entries = [];

rl.on("line", function (line) {
		lines.push(line);
	})
	.on("close", function () {
		for (let lineIndex in lines) {
			const line = lines[lineIndex];
			const matches = line.match(new RegExp(SUBSTRING, "g")) || [];
			const matchedLength = matches.length;
			entries.push(
				matchedLength,
				lineIndex
			);
		}
	})