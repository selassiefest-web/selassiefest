// Start a new BBPAC meeting page from an existing one (print button and print CSS included).
// Usage: node scripts/new-bbpac-meeting.js 2026-11-18 [template-date, default 2026-10-21]
const fs=require('fs'),path=require('path');
const [date,tpl='2026-10-21']=process.argv.slice(2);
if(!/^\d{4}-\d{2}-\d{2}$/.test(date||'')){console.error('Give a date like 2026-11-18');process.exit(1);}
const dst=path.join('bbpac/meetings',date,'index.html');
if(fs.existsSync(dst)){console.error('Already exists:',dst);process.exit(1);}
fs.mkdirSync(path.dirname(dst),{recursive:true});
fs.copyFileSync(path.join('bbpac/meetings',tpl,'index.html'),dst);
console.log('Created',path.resolve(dst),'- edit the title, date, breadcrumb and agenda items.');
