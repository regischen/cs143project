const fs = require('fs');
const path = require('path');

const myPath = path.resolve(__dirname, 'my.txt');
const stdPath = path.resolve(__dirname, 'std.txt');

let my = fs.readFileSync(myPath, 'utf8');
let std = fs.readFileSync(stdPath, 'utf8');
my = my.split('\n');
my.shift();
std = std.split('\n');
std.shift();
if(my.length !== std.length){
  console.error('line length not match!')
}

for(let i =0; i<std.length; ++i){
  if(std[i] !== my[i]){
    console.log('std: ', std[i]);
    console.log('my: ', my[i]);
  }
}
let a = '\\\\'
console.log('\\\\')
