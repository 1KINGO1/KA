const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
	input: fs.createReadStream('input.txt'),
	output: process.stdout,
	terminal: false
});

rl.on("line", function(line){
	console.log('1:' + line);
}).on("close", function() {
	console.log("EOF");
})