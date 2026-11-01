-- Verified on company sites 2026-11-01 (Chrome): GlacierPoint, Prairie Farms, Fox Valley Farms.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-01', url='https://glacierpointenterprises.com/contact-us/',
 notes = notes || ' VERIFIED 11/1: glacierpointenterprises.com lists GREAT LAKES at 7451 W 100th Place, Bridgeview IL 60455 (ex Joe & Ross, Chicago-metro DSD distributor; sells novelties, pints, bulk, mobile vending). The /contact-us form (name, store, phone, email, message, simple math check) is store-oriented; no direct phone or email published. The Special Events page offers trucks and pushcarts only through the Mid-Atlantic and Carolinas divisions, NOT Great Lakes.',
 next_step='Send the contact-us form (pilot: 50 servings/week) and mention mobile vending; ask for the Great Lakes sales manager'
where funder='GlacierPoint (Great Lakes division)';

update fs_grant_deadlines set verified=true, verified_on='2026-11-01', url='https://www.prairiefarms.com/contact',
 notes = notes || ' VERIFIED 11/1: 618-659-5700 customer service; info@prairiefarms.com; 3744 Staunton Rd, Edwardsville IL. Company publicizes donations (250,000 servings of milk, 2025-26) but no ice cream application seen. (The /contact-us/ URL 404s; use /contact.)',
 next_step='Email info@prairiefarms.com or call 618-659-5700: ask for the Chicago-area ice cream sales rep and the community donations contact (50 servings/week pilot)'
where funder='Prairie Farms Dairy';

update fs_grant_deadlines set verified=true, verified_on='2026-11-01', url='https://www.foxvalleyfarms.com/contact-us',
 notes = notes || ' VERIFIED 11/1: novelty ice cream distributor since 1988; 630-231-3005 (site says phone issues: leave voicemail; Sales is ext.), fax 630-231-3224, orders@foxvalleyfarms.com; 2619 Beverly Dr, Aurora. The email is an ORDERS inbox: ask there for sales, or use the contact page.',
 next_step='Email orders@foxvalleyfarms.com and leave a voicemail at 630-231-3005 asking for Sales: nonprofit pricing, 50 servings/week'
where funder='Fox Valley Farms';
commit;
