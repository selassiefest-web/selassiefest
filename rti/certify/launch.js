/* "Open the business" track for clients who have no company yet (blank slate).
   Order, links and facts follow the Prestige Sound bookmark list (Form the business > Taxes and payroll > Chicago licenses > Help > Certifications).
   Numbers marked "verify" come from third-party guides because ilsos.gov blocks programs; confirm them on the official site before paying. */
(function (root) {
  'use strict';
  var E = root.CertEngine, L = E.LINK, has = E.has;

  /* ---------- links (from the bookmark list) ---------- */
  L.sosLLC = { t: 'Illinois Secretary of State: file LLC Articles of Organization online', u: 'https://apps.ilsos.gov/llcarticles/' };
  L.sosBiz = { t: 'Illinois Secretary of State: Business Services', u: 'https://www.ilsos.gov/departments/business_services/' };
  L.sosSearch = { t: 'Illinois business name search (is your name free?)', u: 'https://apps.ilsos.gov/businessentitysearch/' };
  L.irsEIN = { t: 'IRS: apply for an EIN online (free)', u: 'https://www.irs.gov/businesses/small-businesses-self-employed/apply-for-an-employer-identification-number-ein-online' };
  L.irsSB = { t: 'IRS Small Business and Self-Employed Tax Center', u: 'https://www.irs.gov/businesses/small-businesses-self-employed' };
  L.irsEst = { t: 'IRS: estimated taxes', u: 'https://www.irs.gov/businesses/small-businesses-self-employed/estimated-taxes' };
  L.irs1099 = { t: 'IRS: Form 1099-NEC (paying contractors)', u: 'https://www.irs.gov/forms-pubs/about-form-1099-nec' };
  L.mytax = { t: 'MyTax Illinois (register and file Illinois taxes)', u: 'https://mytax.illinois.gov/' };
  L.idorBiz = { t: 'Illinois Department of Revenue: Businesses', u: 'https://tax.illinois.gov/businesses.html' };
  L.ides = { t: 'Illinois Department of Employment Security (employers)', u: 'https://ides.illinois.gov/' };
  L.chiFin = { t: 'City of Chicago Department of Finance (City taxes)', u: 'https://www.chicago.gov/city/en/depts/fin.html' };
  L.bacp = { t: 'Chicago Business Affairs & Consumer Protection (licenses)', u: 'https://www.chicago.gov/city/en/depts/bacp.html' };
  L.bacpApply = { t: 'Chicago: applying for a business license', u: 'https://www.chicago.gov/city/en/depts/bacp/supp_info/applybusinesslicense.html' };
  L.chiDirect = { t: 'Chicago Business Direct (online license applications)', u: 'https://www.chicago.gov/BusinessDirect' };
  L.sbc = { t: 'Chicago Small Business Center', u: 'https://www.chicago.gov/city/en/depts/bacp/sbc.html' };
  L.dcase = { t: 'Chicago Dept. of Cultural Affairs & Special Events (event permits)', u: 'https://www.chicago.gov/city/en/depts/dca.html' };
  L.amuse = { t: 'Chicago Amusement Tax', u: 'https://www.chicago.gov/city/en/depts/fin/supp_info/revenue/tax_list/amusement_tax.html' };
  L.sbaLic = { t: 'SBA: apply for licenses and permits (overview)', u: 'https://www.sba.gov/business-guide/launch-your-business/apply-licenses-permits' };
  L.sbdc = { t: 'Illinois Small Business Development Centers (free advising)', u: 'https://www.illinoissbdc.biz/' };
  L.score = { t: 'SCORE Chicago (free mentors)', u: 'https://www.score.org/chicago' };
  L.sbaLocal = { t: 'SBA: find local assistance', u: 'https://www.sba.gov/local-assistance/find' };
  L.sbaMicro = { t: 'SBA Microloans', u: 'https://www.sba.gov/funding-programs/loans/microloans' };
  L.dceoSB = { t: 'Illinois DCEO: Small Business Assistance', u: 'https://dceo.illinois.gov/smallbizassistance.html' };

  /* ---------- contacts ---------- */
  E.CONTACTS.push(
    { id: 'bacp', org: 'City of Chicago BACP (business licenses) and Small Business Center', role: 'Tells you which City licenses and permits your business needs and reviews applications. In person: City Hall, 121 N. LaSalle St.', phone: '312-744-6249', email: '', addr: 'City Hall, 121 N. LaSalle St., Chicago, IL 60602', link: L.sbc, verify: true, src: 'The phone number comes from a ward office page, not a BACP page: confirm it on chicago.gov.', ask: ['I am opening a business in Chicago. Which licenses and permits do I need for ____ at ____ (address)?', 'Is zoning approval needed first, and how long does it take?'] },
    { id: 'irsbiz', org: 'IRS (EIN and small-business taxes)', role: 'EINs are issued online, free and immediately, only through irs.gov. Beware of websites that charge for an EIN.', phone: '', email: '', addr: '', link: L.irsEIN, verify: false, src: 'IRS EIN page, read Nov 5, 2026.', ask: [] },
    { id: 'sosb', org: 'Illinois Secretary of State, Business Services', role: 'Files LLC Articles of Organization and keeps the public business record.', phone: '', email: '', addr: '', link: L.sosBiz, verify: false, ask: ['I filed Articles of Organization for ____ LLC on ____. What is the status?'] },
    { id: 'sbdc', org: 'Illinois Small Business Development Center (free advising)', role: 'Free one-on-one advice on structure, name, licenses, loans and certifications. Book before you file if anything is unclear.', phone: '', email: '', addr: '', link: L.sbdc, verify: false, ask: ['I am opening a ____ business in Chicago. Can I meet an advisor before I file?'] }
  );
  E.PACKAGES.unshift({ id: 'launch', title: 'Open the business', short: 'Launch', contacts: ['sbdc', 'sosb', 'irsbiz', 'bacp', 'cpa'] });
  E.packagesFor = function (P) { return E.PACKAGES.filter(function (p) { return p.id !== 'launch' || E.isPre(P); }); };

  function pre(P) { return E.isPre(P); }
  function structure(P) { var t = (P.biz || {}).entityType; return t === 'LLC' || !t ? 'llc' : t === 'Sole proprietorship' ? 'sole' : t === 'Partnership' ? 'partnership' : 'corp'; }
  function mk(L0) { return function (id, group, title, why, where, how, src) { L0.push({ id: id, group: group, title: title, why: why, where: where || [], ifMissing: how || '', src: src || 'list' }); }; }

  /* ---------- the step list ---------- */
  function launchChecklist(P) {
    var b = P.biz || {}, L0 = [], add = mk(L0), s = structure(P), ind = b.industry || '';
    var employees = /^Yes/.test(b.hasEmployees || ''), sells = b.sellsGoods === 'Yes';
    var G1 = '1. Decide (today)', G2 = '2. File with the State', G3 = '3. After the State approves', G4 = '4. City of Chicago', G5 = '5. Protect it and keep records', G6 = '6. Free help and funding';
    add('l_struct', G1, 'Choose your structure: LLC, sole proprietorship, or partnership', 'An LLC separates your personal assets from business debts. A sole proprietorship needs no State filing but gives no separation. A partnership needs a written agreement. Whatever you pick, certifiers later ask for clear ownership papers.', [L.sbdc, L.sbaLic], 'Book a free 30-minute call with an SBDC advisor if you are unsure. Then set the choice on the Business tab.');
    add('l_name', G1, 'Pick three business names, best first, and check each on the Illinois business name search', 'A name that is already taken cannot be used. An LLC name must include LLC, L.L.C. or Limited Liability Company.', [L.sosSearch], 'Search each name; write the free ones in the "name choices" box on the Business tab.');
    add('l_agent', G1, 'Name your registered agent: an Illinois street address (not a P.O. box) where someone is available during business hours', 'Required to form an LLC. Often the owner.', [L.sosBiz], 'Use your own street address if you will be there during the day; otherwise hire a registered-agent service.', 'common');
    if (s === 'llc') {
      add('l_articles', G2, 'File the Articles of Organization online with the Illinois Secretary of State', 'This is the step that creates the LLC. Guides quote a $150 fee, with an optional expedited service for about $100 more (about 24 hours) and 5 to 10 business days otherwise. Those figures come from third-party guides: confirm the exact fee and speed on ilsos.gov before you pay.', [L.sosLLC], 'Use the "Articles of Organization" sheet on the Portal answers tab: it has every answer ready to copy. Pay by card on the State site.');
      add('l_opag', G2, 'Write an Operating Agreement and sign it', 'Not filed with the State, but banks and every certification program ask for it, and it must match how the business really runs. A single-owner LLC needs one too.', [L.sbdc], 'Start from the starter draft on the Draft documents tab and have an attorney or SBDC advisor review it before signing.');
    } else if (s === 'sole') {
      add('l_assumed', G2, 'If you will use a business name other than your own legal name: file an assumed name certificate with the Cook County Clerk', 'Sole proprietors and general partnerships register a trade name with the county clerk.', [L.cookRecorder], 'Use the "Assumed name" sheet on the Portal answers tab. Ask the Clerk for the current fee.');
    } else if (s === 'partnership') {
      add('l_partag', G2, 'Write a partnership agreement and have every partner sign it', 'Who owns what, who decides, and what happens when a partner leaves.', [L.sbdc], 'Have an attorney or SBDC advisor review it.');
      add('l_assumed', G2, 'If you will use a business name: file an assumed name certificate with the Cook County Clerk', 'General partnerships register a trade name with the county clerk.', [L.cookRecorder], 'Use the "Assumed name" sheet on the Portal answers tab.');
    } else {
      add('l_corp', G2, 'Corporations need more paperwork (articles, bylaws, stock, minutes). Talk to an attorney or an SBDC advisor before filing', 'This Hub drafts the LLC path. Corporations are fine, but get advice first.', [L.sbdc], 'Book the free SBDC call.');
    }
    add('l_ein', G3, 'Get your EIN from the IRS, online and free', 'You need the State to approve the LLC first. The IRS issues the EIN immediately when you finish the application. Hours (Eastern): Mon-Fri 6 a.m.-1 a.m., Sat 6 a.m.-9 p.m., Sun 6 p.m.-midnight. One EIN per responsible person per day. Beware of websites that charge for an EIN: it is always free.', [L.irsEIN], 'Use the "EIN application" sheet on the Portal answers tab. You type the owner\'s Social Security number or ITIN yourself on the IRS site: the Hub never stores it.');
    add('l_bank', G3, 'Open a business bank account', 'Keep business money completely separate. This is also your proof of capital later: put the owner\'s starting money in by check or transfer and label it.', [], 'Bring the file-stamped Articles, the EIN letter, the Operating Agreement and photo ID for every owner. See the bank checklist on the Draft documents tab.');
    add('l_idor', G3, 'Register with the Illinois Department of Revenue (Form REG-1) on MyTax Illinois if you will sell taxable items or have employees', 'Registering online is the fast route (about 1 to 2 business days per one source; paper can take weeks). After the confirmation email, wait 24 hours before activating your MyTax Illinois login.', [L.mytax, L.idorBiz], 'Do it online at MyTax Illinois. Confirm on tax.illinois.gov whether your business must register.', sells || employees ? 'list' : 'common');
    if (employees) {
      add('l_ides', G3, 'Register as an employer with the Illinois Department of Employment Security', 'Needed once you have employees.', [L.ides], 'Register online before your first payroll.');
      add('l_payroll', G3, 'Set up payroll taxes with the IRS and a payroll service', 'Employers withhold and pay payroll taxes. Start from the IRS small-business center.', [L.irsSB], 'Ask your SBDC advisor or a CPA to set it up the first time.');
    }
    add('l_bacp', G4, 'Get your City of Chicago business license', 'Register with the county, state and federal offices first. Apply online through Chicago Business Direct, or in person at the Small Business Center in City Hall. Zoning must approve the location before a license is processed, and no license issues while you owe the City money. Signs and awnings need a separate permit.', [L.chiDirect, L.bacpApply, L.sbc], 'Call or visit the Small Business Center first: a consultant tells you exactly which licenses your business needs.');
    if (ind === 'General contractor / construction') add('l_gc', G4, 'Chicago contractor license through the Department of Buildings (confirm the class)', 'General contractors working in Chicago generally need a City contractor license in addition to the business license.', [L.chiBuildings], 'Ask the Small Business Center which class applies and what insurance and bonding it requires.', 'common');
    if (ind === 'Sound, DJ or events') {
      add('l_amuse', G4, 'Check Chicago amusement tax and event permits', 'Event and entertainment businesses can owe the City amusement tax, and public events need permits.', [L.amuse, L.dcase], 'Ask the Small Business Center and the Department of Finance whether you collect amusement tax.', 'common');
    }
    if (sells) add('l_sales', G4, 'Collect and report sales tax if you sell taxable items', 'Registered through the same REG-1 on MyTax Illinois. The City also has its own taxes.', [L.mytax, L.chiFin], 'Confirm what is taxable with the Department of Revenue.', 'common');
    add('l_ins', G5, 'Buy general liability insurance, and workers\' compensation if you have employees', 'Clients and venues ask for a certificate of insurance. Contractors usually need it for licensing.', [], 'Get quotes from two insurance agents or online small-business insurers; ask for a certificate. Confirm workers\' compensation rules with the Illinois Workers\' Compensation Commission.');
    add('l_books', G5, 'Keep books from day one and plan for taxes', 'Use one bank account, record every deposit and expense, and set money aside for estimated taxes. Pay independent contractors on a 1099-NEC when required.', [L.irsEst, L.irs1099, L.irsSB], 'Open a simple bookkeeping app or hire a part-time bookkeeper.');
    add('l_trail', G5, 'Start the paper trail certification programs will ask for later', 'Signed contracts, invoices matched to bank deposits, the owner\'s capital contribution by check, resumes, and tax returns every year. Starting clean now saves months later.', [L.cityGuide], 'Keep a folder for each: contracts, invoices, bank statements, tax returns, licenses.');
    add('l_help', G6, 'Use the free help before you spend money', 'Illinois SBDC advisors, SCORE mentors and the Chicago Small Business Center advise for free.', [L.sbdc, L.score, L.sbc, L.sbaLocal, L.dceoSB], 'Book one session; bring this checklist.');
    add('l_fund', G6, 'Look at loans and grants only after the business is formed and has a bank account', 'SBA microloans and state and City programs need a formed business.', [L.sbaMicro], 'Ask your SBDC advisor which programs fit.');
    add('l_cert', G6, 'Plan the certifications: City of Chicago, Cook County and State BEP', 'They check tax returns and business history, so a brand-new business may need to wait or ask what to submit. The Hub will switch to the certification track once your company exists: set "Already formed" on the Business tab and upload your ilsos.gov page.', [L.cityPage], 'When you are formed, switch the Hub to the certification track and ask DPS what a new business should submit.');
    return L0;
  }

  /* ---------- the day-by-day plan ---------- */
  function addBiz(d, n) { var x = new Date(d.getTime()), k = 0; while (k < n) { x.setDate(x.getDate() + 1); if (x.getDay() !== 0 && x.getDay() !== 6) k++; } return x; }
  function nextBiz(d) { var x = new Date(d.getTime()); while (x.getDay() === 0 || x.getDay() === 6) x.setDate(x.getDate() + 1); return x; }
  function fmt(d) { return d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' }); }
  function launchTimeline(P) {
    var s0 = P.startDate ? new Date(P.startDate + 'T00:00:00') : new Date(), out = [];
    function st(n, phase, t, who, c, est) { out.push({ date: fmt(nextBiz(addBiz(s0, n))), day: n, phase: phase, t: t + (est ? ' (estimate)' : ''), who: who, c: c }); }
    out.push({ date: fmt(nextBiz(s0)), day: 0, phase: 'Today', t: 'Choose your structure, pick three names and check them on the Illinois name search, decide your registered agent, and gather photo ID for every owner.', who: 'You (and a free SBDC advisor if unsure)', c: 'sbdc' });
    out.push({ date: fmt(nextBiz(s0)), day: 0, phase: 'Today', t: 'FILE the Articles of Organization online (LLC) or the Cook County assumed-name certificate (sole proprietor or partnership). You can finish this in one sitting.', who: 'You', c: 'sosb' });
    st(1, 'Wait', 'Earliest State approval if you paid for expedited service (about 24 hours per guides; confirm on ilsos.gov)', 'Illinois Secretary of State', 'sosb', true);
    st(10, 'Wait', 'Latest expected State approval on standard processing (5 to 10 business days per guides)', 'Illinois Secretary of State', 'sosb', true);
    out.push({ date: 'The day it is approved', day: null, phase: 'Same day', t: 'Get your EIN online (free, immediate), then sign the Operating Agreement.', who: 'You', c: 'irsbiz' });
    out.push({ date: '1 to 3 business days after the EIN', day: null, phase: 'Next', t: 'Open the business bank account and deposit the owner\'s starting money by check or transfer.', who: 'You, your bank', c: null });
    out.push({ date: 'Right after the bank account', day: null, phase: 'Next', t: 'Register on MyTax Illinois (REG-1) if you will sell taxable items or have employees (about 1 to 2 business days online per one source). Register as an employer with IDES if you hire.', who: 'You', c: null });
    out.push({ date: 'After state and federal registration', day: null, phase: 'Next', t: 'Call or visit the Chicago Small Business Center to learn which licenses you need, pass zoning review, then apply for the City business license (and a contractor license if you are a contractor).', who: 'You, BACP', c: 'bacp' });
    out.push({ date: 'Before you start work', day: null, phase: 'Protect', t: 'Buy general liability insurance (and workers\' compensation if you have employees) and get a certificate.', who: 'You, an insurance agent', c: null });
    out.push({ date: 'After you are formed and licensed', day: null, phase: 'Certify', t: 'Switch the Hub to "Already formed", upload your ilsos.gov page, and start the certification track. Ask DPS what a new business should submit.', who: 'You, DPS', c: null });
    return out;
  }

  /* ---------- answer sheets ---------- */
  function nameOf(P) { var n = (P.biz || {}).legalName; return has(n) ? n : '[ NEEDED: business name ]'; }
  function val(x, label) { return has(x) ? String(x).trim() : '[ NEEDED: ' + label + ' ]'; }
  function launchAnswers(P) {
    var b = P.biz || {}, O = P.owners || [], o0 = O[0] || {}, addr = [b.address, b.city, b.state, b.zip].filter(has).join(', ') || '[ NEEDED: business address ]';
    var S = [];
    var sosRows = [['Limited liability company name', nameOf(P)], ['Backup names if taken', val(b.nameAlt, 'backup names')], ['Principal office address', addr], ['Registered agent', val(b.regAgent, 'registered agent with an Illinois street address')], ['Purpose', has(b.scope) ? b.scope : 'Any lawful business [ or describe: ' + val(b.scope, 'what the business does') + ' ]'], ['Duration', 'Perpetual (until dissolved)'], ['Management', O.length > 1 ? 'Member-managed by all members (confirm with your advisor)' : 'Member-managed by the sole member (confirm)'], ['Members / managers', O.length ? O.map(function (o) { return val(o.name, 'owner name') + (has(o.pct) ? ' (' + o.pct + '%)' : ''); }).join('; ') : '[ NEEDED: owners ]'], ['Signer / organizer', val(o0.name, 'who signs for the company')], ['Fee and speed', 'Confirm the current fee and any expedited option on the State site before you pay (guides say $150 standard, about $100 more for 24-hour service).']];
    S.push({ title: 'Articles of Organization (Illinois LLC): answers to type into the State\'s online form', rows: sosRows });
    S.push({ title: 'EIN application (IRS): answers to type into the IRS online form', rows: [['Type of entity', 'Limited liability company (LLC)'], ['Number of members', String(O.length || '[ NEEDED ]')], ['State where formed', 'Illinois'], ['Legal name', nameOf(P)], ['Trade name (if any)', 'None unless you use a different name'], ['Mailing and physical address', addr], ['County', val(b.county, 'county')], ['Responsible party (a person who controls the company)', val(o0.name, 'responsible party')], ['Responsible party SSN or ITIN', 'YOU type this directly into the IRS site. It is never entered in the Hub.'], ['Reason for applying', 'Started a new business'], ['Date business started', val(b.startDate, 'the date the business starts')], ['Closing month of the tax year', 'December (typical; confirm)'], ['Principal activity', val(b.scope, 'what the business does') + (has(b.industry) ? ' (' + b.industry + ')' : '')], ['Will you have employees in the next 12 months?', val(b.hasEmployees, 'employees plan')], ['Fee', 'None. The IRS never charges for an EIN.']] });
    S.push({ title: 'Assumed name certificate (Cook County Clerk): sole proprietor or partnership using a business name', rows: [['Assumed (business) name', nameOf(P)], ['Owner full legal name(s)', O.length ? O.map(function (o) { return val(o.name, 'owner'); }).join('; ') : '[ NEEDED ]'], ['Home address of each owner', O.length ? O.map(function (o) { return [o.homeStreet, o.homeCSZ].filter(has).join(', ') || '[ NEEDED: home address ]'; }).join(' | ') : '[ NEEDED ]'], ['Business address', addr], ['Fee', 'Ask the Clerk for the current fee.']] });
    return S;
  }

  /* ---------- starter documents ---------- */
  var STARTER = 'STARTER DRAFT. Not legal advice. Have an attorney or a free SBDC advisor review it before anyone signs. Every statement must be true.';
  function launchDrafts(P) {
    var b = P.biz || {}, O = P.owners || [], name = nameOf(P), D = [];
    var multi = O.length > 1;
    var members = O.length ? O.map(function (o) { return val(o.name, 'owner name') + ' ... ' + val(o.pct, 'ownership %') + '%'; }).join('\n') : '[ NEEDED: owners and percentages ]';
    D.push({ id: 'op', title: (multi ? 'Operating Agreement starter (multi-member LLC)' : 'Operating Agreement starter (single-member LLC)'), body: STARTER + '\n\n' +
      'OPERATING AGREEMENT OF ' + name + '\n\n' +
      '1. Formation. The Company is an Illinois limited liability company formed by filing Articles of Organization with the Illinois Secretary of State on [ NEEDED: date the State approved the Articles ].\n' +
      '2. Name and office. The Company\'s name is ' + name + '. Its principal office is ' + ([b.address, b.city, b.state, b.zip].filter(has).join(', ') || '[ NEEDED: address ]') + '.\n' +
      '3. Purpose. ' + (has(b.scope) ? b.scope : 'Any lawful business.') + '\n' +
      '4. ' + (multi ? 'Members and ownership.\n' + members : 'Member. ' + val((O[0] || {}).name, 'owner name') + ' is the sole Member and owns 100% of the Company.') + '\n' +
      '5. Capital contributions. ' + (multi ? 'Each Member contributes the amount and on the date shown here: [ NEEDED: amount, date and source for each member ].' : 'The Member contributed ' + (has((O[0] || {}).capAmt) ? '$' + O[0].capAmt : '[ NEEDED: amount ]') + ' on [ NEEDED: date ] from ' + val((O[0] || {}).capSource, 'source of funds') + '.') + ' Contributions are paid by check or transfer into the Company bank account.\n' +
      '6. Management. ' + (multi ? 'The Company is member-managed. Decisions need a majority in interest of the Members. Adding a Member, selling the Company, or borrowing over [ NEEDED: amount ] needs every Member to agree.' : 'The Company is member-managed. The Member has full authority to sign contracts, open bank accounts and make every decision.') + '\n' +
      '7. Profits, losses and distributions. ' + (multi ? 'Shared by ownership percentage unless the Members agree otherwise in writing.' : 'All go to the Member.') + '\n' +
      '8. Books and bank accounts. The Company keeps its own bank account and books. Personal and Company money are never mixed.\n' +
      (multi ? '9. Leaving or selling. A Member who wants to leave must first offer the interest to the other Members at a price set this way: [ NEEDED: how the price is decided ].\n' : '') +
      (multi ? '10' : '9') + '. Liability. No Member is personally liable for Company debts except as the law provides.\n' +
      (multi ? '11' : '10') + '. Ending the Company. The Company continues until the Members decide to dissolve it or the law requires it.\n' +
      (multi ? '12' : '11') + '. Governing law. Illinois law applies.\n\nSIGNED:\n' + (O.length ? O.map(function (o) { return val(o.name, 'owner') + '   ______________________   Date ____________'; }).join('\n') : '______________________   Date ____________') });
    D.push({ id: 'bank', title: 'Business bank account: what to bring', body: 'Bring to the bank:\n- The file-stamped Articles of Organization from the Illinois Secretary of State (LLC), or your assumed name certificate (sole proprietor / partnership)\n- Your EIN confirmation letter from the IRS (CP 575) or the EIN page you saved\n- The signed Operating Agreement (LLC) or partnership agreement\n- Government photo ID for every person who will sign on the account\n- The owner\'s starting deposit: pay it by check or transfer from the owner\'s own account and write "owner capital contribution" on it. Keep a copy: certification programs later ask exactly how each owner funded the business.\n\nAsk the bank: monthly fee, who can sign, whether it offers a free business debit card and online statements.' });
    D.push({ id: 'cover', title: 'Message to ask the Chicago Small Business Center which licenses you need (copy and send)', body: 'Hello, I am opening ' + name + ', a ' + (has(b.industry) ? b.industry.toLowerCase() : 'business') + ', at ' + ([b.address, b.city, b.state, b.zip].filter(has).join(', ') || '[ NEEDED: address ]') + '. We plan to ' + (has(b.scope) ? b.scope : '[ NEEDED: what you will do ]') + '. Employees: ' + val(b.hasEmployees, 'employees plan') + '. Which City licenses and permits do we need, does zoning need to approve the location first, and what should we have in hand before we apply?\n\nThank you,\n' + val((O[0] || {}).name, 'name') + '\n' + val(b.phone, 'phone') + '\n' + val(b.email, 'email') });
    return D;
  }

  function launchPlan(P) {
    return [
      { n: 1, t: 'Today: choose your structure, three names, and a registered agent. File the Articles of Organization online (LLC) or the assumed-name certificate (sole proprietor / partnership).', why: 'You can finish the filing in one sitting. The State approval is what actually creates the company.' },
      { n: 2, t: 'The day the State approves: get your EIN (free, immediate, online only at irs.gov), sign the Operating Agreement, open the business bank account.', why: 'Each needs the one before it.' },
      { n: 3, t: 'Register with the Illinois Department of Revenue if you sell taxable items or have employees; register with IDES if you hire.', why: 'About 1 to 2 business days online, per one source.' },
      { n: 4, t: 'Ask the Chicago Small Business Center which licenses you need, pass zoning review, and apply for the City business license (and a contractor license if you are a contractor).', why: 'Do not start work that needs a license before you have it.' },
      { n: 5, t: 'Buy insurance, keep books and a clean paper trail, then switch the Hub to the certification track.', why: 'Certification programs check tax returns and business history, so a brand-new business may need to wait or ask DPS what to submit.' }
    ];
  }

  /* ---------- wire into the existing API ---------- */
  var _cl = E.checklistFor, _tl = E.timelineFor, _el = E.eligibilityFor, _rt = E.routeFor, _pl = E.plan, _fs = E.fieldStatus;
  E.checklistFor = function (P, pkg) { return pkg === 'launch' ? launchChecklist(P) : _cl(P, pkg); };
  E.timelineFor = function (P, pkg) { return pkg === 'launch' ? launchTimeline(P) : _tl(P, pkg); };
  E.eligibilityFor = function (P, pkg) { return pkg === 'launch' ? [{ lvl: 'info', t: 'You do not need to be certified to open. Certification comes after the business exists and has some history.' }] : _el(P, pkg); };
  E.routeFor = function (P, pkg) { return pkg === 'launch' ? 'launch' : _rt(P, pkg); };
  E.plan = function (P) { return pre(P) ? launchPlan(P) : _pl(P); };
  E.answersFor = function (P, pkg) { return pkg === 'launch' ? launchAnswers(P) : E.answers(P); };
  E.draftsFor = function (P, pkg) { return pkg === 'launch' ? launchDrafts(P) : E.drafts(P); };
  E.fieldStatus = function (P, key, field, value) {
    if (pre(P) && !has(value) && field) {
      if (field.post) return { st: 'gray', why: 'After you form the company' };
      if (field.req) return { st: 'red', why: 'Only the client can answer this' };
      return { st: 'gray', why: 'Optional, or only after the company exists' };
    }
    return _fs(P, key, field, value);
  };
})(window);
