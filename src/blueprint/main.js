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
			entries.push([
				matchedLength,
				lineIndex
			]);
		}

		// Bubble Sort
		for (let i = 0; i < entries.length; i++) {
			for (let j = 0; j < entries.length - 1; j++) {
				if (entries[j][0] > entries[j + 1][0]) {
					const temp = entries[j];
					entries[j] = entries[j + 1];
					entries[j + 1] = temp;
				}
			}
		}

		console.log(entries.map(entry => entry.join(' ')).join("\n"));
	})