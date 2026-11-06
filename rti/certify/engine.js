/* Certification Hub engine: pure logic + data, no DOM. Phase 1 package: City of Chicago M/WBE.
   Every link and contact below is marked verify:true until a human confirms it on the official site. */
(function (root) {
  'use strict';
  var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); };
  var has = function (x) { return x !== undefined && x !== null && String(x).trim() !== ''; };
  var gap = function (label) { return '[ NEEDED: ' + label + ' ]'; };
  var val = function (x, label) { return has(x) ? String(x).trim() : gap(label); };

  /* ---------- official links (confirm on the live site before relying on them) ---------- */
  var LINK = {
    formsPage: { t: "City of Chicago: Certification and Compliance forms and documents (official list)", u: "https://www.chicago.gov/city/en/depts/dps/provdrs/cert/supp_info/mbe_wbe_certificationformsanddocuments.html" },
    attach1: { t: "Attachment 1: Individual Statement of Ownership (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/RulesRegulations/IndividualStatementOfOwnership_Revised11.6.2017.pdf" },
    attach2: { t: "Attachment 2: Personal Net Worth Statement (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/PNWForm_5_%201.26.2022.pdf" },
    attach4: { t: "Attachment 4: Affidavit of Social Disadvantage (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/AffidavitofSocialDisadvantage6-6-16.pdf" },
    attach5: { t: "Attachment 5: IRS Form 4506-T (City copy)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Outreach/F4506T.pdf" },
    schedAChecklist: { t: "Official checklist for the new Schedule A", u: "https://www.chicago.gov/content/dam/city/depts/dps/Outreach/Checklist_for_the_New_Schedule_A.pdf" },
    expedited: { t: "Expedited process for firms certified by another agency (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Outreach/Outside_Certification_ProcessRevised.pdf" },
    pnwLimit: { t: "2026 Personal Net Worth limit (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/2026PersonalNetWorthLimit.pdf" },
    grLimit: { t: "2026 Gross Receipts limit (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/2026GrossReceiptsLimit.pdf" },
    rulesConstr: { t: "Certification regulations, construction (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/CertificationRulesConstruction_0424.pdf" },
    keyTerms: { t: "Definition of key terms (official PDF)", u: "https://www.chicago.gov/content/dam/city/depts/dps/Certification/Certification%20Documents/Certification_Definition_of_Key_Terms-1-.pdf" },
    portal: { t: 'City of Chicago certification portal (chicago.mwdbe.com)', u: 'https://www.chicago.mwdbe.com' },
    cityPage: { t: 'City of Chicago DPS: M/WBE certification page', u: 'https://www.chicago.gov/city/en/depts/dps/provdrs/cert/svcs/minority_and_womenownedbusinessenterprisecertificationmbewbe.html' },
    cityGuide: { t: 'City of Chicago: Becoming a certified business (PDF guide)', u: 'https://www.chicago.gov/content/dam/city/depts/dps/Outreach/BECOMING%20A%20CERTIFIED%20BUSINESS_DPS.pdf' },
    reciprocal: { t: 'Chicago + Cook County reciprocal certification rules (PDF)', u: 'https://www.chicago.gov/content/dam/city/depts/dps/RulesRegulations/ChicagoCookReciprocalCertificationRegs.pdf' },
    irs4506t: { t: 'IRS Form 4506-T (Request for Transcript of Tax Return)', u: 'https://www.irs.gov/pub/irs-pdf/f4506t.pdf' },
    irsTranscript: { t: 'IRS Get Transcript (individuals)', u: 'https://www.irs.gov/individuals/get-transcript' },
    irsBiz: { t: 'IRS: business transcripts and copies of returns', u: 'https://www.irs.gov/individuals/tax-professionals/transcripts-and-copies-of-tax-returns' },
    irsEinLetter: { t: 'IRS: lost your EIN letter (Letter 147C)', u: 'https://www.irs.gov/businesses/small-businesses-self-employed/lost-or-misplaced-your-ein' },
    ilsosLLC: { t: 'Illinois Secretary of State: corporation / LLC search and certificates', u: 'https://apps.ilsos.gov/corporatellc/' },
    ilsosAssumed: { t: 'Illinois Secretary of State: business services', u: 'https://www.ilsos.gov/departments/business_services/home.html' },
    cookRecorder: { t: 'Cook County Clerk (assumed business names) / Recorder (deeds)', u: 'https://www.cookcountyclerkil.gov/' },
    chiBuildings: { t: 'City of Chicago Dept. of Buildings: contractor licensing', u: 'https://www.chicago.gov/city/en/depts/bldgs.html' },
    chiBACP: { t: 'City of Chicago BACP: business licenses', u: 'https://www.chicago.gov/city/en/depts/bacp.html' },
    cookOCC: { t: 'Cook County Office of Contract Compliance (MWBE)', u: 'https://www.cookcountyil.gov/agency/contract-compliance' },
    ceiBEP: { t: 'Illinois Commission on Equity and Inclusion: Get BEP certified', u: 'https://cei.illinois.gov/vendor-resources/get-bep-certified.html' },
    idotDBE: { t: 'IDOT: DBE certification (Illinois Unified Certification Program)', u: 'https://idot.illinois.gov/doing-business/industry-marketplace/dbe/dbe-certification0.html' },
    naics: { t: 'U.S. Census: NAICS code search', u: 'https://www.census.gov/naics/' },
    idme: { t: 'U.S. passport / permanent resident card help (USCIS)', u: 'https://www.uscis.gov/green-card/after-we-grant-your-green-card/replace-your-green-card' },
    passport: { t: 'U.S. Dept. of State: passports', u: 'https://travel.state.gov/content/travel/en/passports.html' },
    birthCert: { t: 'Illinois certified birth certificate (IDPH Vital Records)', u: 'https://dph.illinois.gov/topics-services/life-stages-populations/vital-records.html' }
  };

  /* ---------- who to contact (every row verify:true) ---------- */
  var CONTACTS = [
    { id: 'dps', org: 'City of Chicago, Dept. of Procurement Services: Certification and Compliance Division', role: 'Reviews and decides the Chicago M/WBE application. Ask for your assigned analyst by name when the file is submitted.',
      phone: '312-744-4900', email: '', addr: '121 N. LaSalle St., Room 806, Chicago, IL 60602', link: LINK.cityPage, verify: false, src: 'Confirmed on the City M/WBE page, Nov 5, 2026. No certification email is published there.',
      ask: ['Is my file complete, and what date did your 90-day clock start?', 'Who is my assigned analyst, and what is the best way to reach them?', 'Is a site visit or interview needed, and when?'] },
    { id: 'cook', org: 'Cook County Office of Contract Compliance', role: 'Accepts Chicago M/WBE certification by reciprocity (and Chicago accepts Cook County\'s). Useful only if you already hold, or want, the other certification.',
      phone: '', email: '', addr: '', link: LINK.cookOCC, verify: true,
      ask: ['I hold (or am applying for) City of Chicago M/WBE. Which reciprocal affidavit do you need, and is there a fee?'] },
    { id: 'cei', org: 'Illinois Commission on Equity and Inclusion (State BEP)', role: 'State Business Enterprise Program. Has a fast track (about 7 business days) for firms already certified by a partner agency.',
      phone: '312-814-4190', email: 'CEI.BEP.Certification@Illinois.gov', addr: '115 S. LaSalle St., Suite 4N, Chicago, IL', link: LINK.ceiBEP, verify: true,
      ask: ['I am certified by the City of Chicago. Do I qualify for your fast track, and which checklist applies?'] },
    { id: 'idot', org: 'IDOT, Bureau of Small Business Enterprises (DBE / Illinois UCP)', role: 'Federal DBE certification for transportation-funded work. Averages about 90 days from a complete application.',
      phone: '', email: '', addr: '2300 S. Dirksen Pkwy, Room 319, Springfield, IL 62764 (paper applications)', link: LINK.idotDBE, verify: true,
      ask: ['What is the status of my DBE application, and is anything outstanding?'] },
    { id: 'irs', org: 'IRS Business & Specialty Tax Line', role: 'Transcripts and copies of returns; EIN verification letters (147C).',
      phone: '800-829-4933', email: '', addr: '', link: LINK.irsBiz, verify: true, ask: ['I need a verification of EIN letter (147C) and return transcripts for tax years ____ .'] },
    { id: 'sos', org: 'Illinois Secretary of State, Business Services', role: 'Certificate of good standing, certified copies of Articles, assumed-name records.',
      phone: '', email: '', addr: '', link: LINK.ilsosLLC, verify: true, ask: ['I need a certificate of good standing and a certified copy of our Articles.'] },
    { id: 'bank', org: 'Your bank branch manager', role: 'Signature cards, banking resolution, account-opening statements, statements showing the owner\'s initial capital.',
      phone: '', email: '', addr: '', link: null, verify: false, ask: ['Please provide signature cards, the corporate/LLC banking resolution, and statements for the months of initial capital deposit.'] },
    { id: 'cpa', org: 'Your CPA / tax preparer', role: 'Signed returns with every schedule, year-to-date P&L and balance sheet, 4506-T signing.',
      phone: '', email: '', addr: '', link: null, verify: false, ask: ['Please send complete signed returns (all schedules) for ____ , plus a year-to-date P&L and balance sheet.'] }
  ];

  /* ---------- field schema: what we ask once ---------- */
  var ENT = ['LLC', 'S-Corporation', 'C-Corporation', 'Partnership', 'Sole proprietorship', 'Nonprofit corporation'];
  var ETH = ['Black or African American', 'Hispanic / Latino', 'Asian American', 'Native American / Alaska Native', 'White (non-Hispanic)', 'Prefer not to say'];
  var SECTIONS = [
    { id: 'biz', title: 'The business', scope: 'biz', blurb: 'Asked once. Feeds every form.', fields: [
      { k: 'legalName', label: 'Legal business name (exactly as on your Articles / IRS letter)', req: 1, where: { t: 'Illinois SOS entity search', u: LINK.ilsosLLC.u, how: 'Search your name; the record shows the exact legal name.' } },
      { k: 'dba', label: 'Assumed name / DBA (if any)', help: 'Leave blank if none.' },
      { k: 'entityType', label: 'Business structure', type: 'select', opts: ENT, req: 1 },
      { k: 'ein', label: 'EIN (federal tax ID)', req: 1, where: { t: 'IRS lost-EIN help', u: LINK.irsEinLetter.u, how: 'Find your CP-575 letter, an old tax return, or call the IRS Business line for a 147C letter.' } },
      { k: 'stateInc', label: 'State of formation', help: 'e.g. Illinois' },
      { k: 'incDate', label: 'Date formed', type: 'date', req: 1 },
      { k: 'startDate', label: 'Date you began operating', type: 'date' },
      { k: 'address', label: 'Business street address', req: 1 }, { k: 'city', label: 'City', req: 1 }, { k: 'state', label: 'State', req: 1 }, { k: 'zip', label: 'ZIP', req: 1 },
      { k: 'phone', label: 'Business phone', req: 1 }, { k: 'email', label: 'Business email', req: 1 }, { k: 'website', label: 'Website (optional)' },
      { k: 'naics', label: 'NAICS codes and what you do under each (one per line: code - description)', type: 'textarea', req: 1, where: { t: 'Census NAICS search', u: LINK.naics.u, how: 'Search your trade (e.g. "general contractor"). Only list work you actually perform; the City certifies only those codes.' } },
      { k: 'scope', label: 'In plain words, what work does the business perform?', type: 'textarea', req: 1 },
      { k: 'employeesFT', label: 'Full-time employees' }, { k: 'employeesPT', label: 'Part-time / seasonal employees' },
      { k: 'receipts1', label: 'Gross receipts, most recent full tax year ($)' }, { k: 'receipts2', label: 'Gross receipts, year before ($)' }, { k: 'receipts3', label: 'Gross receipts, two years before ($)' },
      { k: 'licenses', label: 'Licenses and permits held (one per line: name, number, expiry)', type: 'textarea', where: { t: 'Chicago Dept. of Buildings', u: LINK.chiBuildings.u, how: 'General contractors working in Chicago need a City contractor license; confirm which class applies to you.' } },
      { k: 'locType', label: 'Business location', type: 'select', opts: ['Lease', 'Own', 'Home office / no separate site'] },
      { k: 'landlord', label: 'Landlord (if leased)' }, { k: 'leaseStart', label: 'Lease start', type: 'date' }, { k: 'leaseEnd', label: 'Lease end', type: 'date' }, { k: 'sqft', label: 'Space (sq ft) and use' },
      { k: 'affiliates', label: 'Other businesses any owner owns or works for', type: 'textarea', help: 'Affiliations are reviewed. List honestly or write "none".' },
      { k: 'priorCerts', label: 'Existing certifications (Cook County, State BEP, DBE, WBENC, etc.)', type: 'textarea', help: 'An existing Cook County or partner certification can be the fastest route.' }
    ] },
    { id: 'owners', title: 'Owners and managers', scope: 'array', arr: 'owners', max: 4, addLabel: 'Add another owner', blurb: 'One card per owner, officer or key manager. Percentages must total 100.', fields: [
      { k: 'name', label: 'Full legal name', req: 1 }, { k: 'title', label: 'Title / role in company', req: 1 },
      { k: 'pct', label: 'Ownership %', type: 'number', req: 1 },
      { k: 'gender', label: 'Gender', type: 'select', opts: ['Female', 'Male', 'Prefer not to say'], req: 1 },
      { k: 'ethnicity', label: 'Race / ethnicity (as defined by the program)', type: 'select', opts: ETH, req: 1 },
      { k: 'citizenship', label: 'Citizenship status', type: 'select', opts: ['U.S. citizen', 'Lawful permanent resident', 'Other'], req: 1, where: { t: 'U.S. passport info', u: LINK.passport.u, how: 'Proof can be a U.S. passport, birth certificate, or permanent resident card. Replace a lost one before you apply.' } },
      { k: 'ownerSince', label: 'Owner since', type: 'date' },
      { k: 'hours', label: 'Hours per week working in this business' },
      { k: 'years', label: 'Years of experience in this trade' },
      { k: 'education', label: 'Education, training, certifications', type: 'textarea' },
      { k: 'trades', label: 'Trade licenses held personally', type: 'textarea' },
      { k: 'capAmt', label: 'Cash / assets the owner put in to start or expand the business ($)', req: 1 },
      { k: 'capDate', label: 'When it was put in', type: 'date' },
      { k: 'capSource', label: 'Where that money came from', type: 'select', opts: ['Personal savings', 'Personal loan', 'Sale of an asset', 'Gift', 'Other'], req: 1 },
      { k: 'capNote', label: 'Describe the source in a sentence and where the bank record is', type: 'textarea' },
      { k: 'duties', label: 'What this owner personally decides and does each week (bids, hiring, signing contracts, supervising jobs, banking)', type: 'textarea', req: 1 },
      { k: 'signs', label: 'Can this owner sign checks and contracts alone?', type: 'select', opts: ['Yes', 'No'] },
      { k: 'otherJob', label: 'Other employment or businesses', help: 'Write "none" if none.' },
      { k: 'formerName', label: 'Former or maiden name (write none if none)' },
      { k: 'homeStreet', label: 'Home street address', req: 1 }, { k: 'homeCSZ', label: 'Home city, state, ZIP', req: 1 },
      { k: 'homePhone', label: 'Home / cell phone' }, { k: 'ownerEmail', label: 'Owner email' },
      { k: 'nationalOrigin', label: 'National origin (country)', help: 'Asked on Attachment 1.' },
      { k: 'salary', label: 'Current yearly salary from this business ($)' },
      { k: 'family', label: 'Family relationships among owners, officers, directors or managers (names and relationship; write none if none)', type: 'textarea' }
    ] },
    { id: 'pnw', title: 'Personal net worth (per owner)', scope: 'array', arr: 'owners', max: 4, noAdd: true, blurb: 'Fills Attachment 2. Round numbers are fine if you do not have exact figures, but they must be honest. Do not include the value of this business or your primary home. Leave blank if zero.', fields: [
      { k: 'a_cash', label: 'Cash on hand and in banks ($)' }, { k: 'a_savings', label: 'Savings accounts ($)' }, { k: 'a_recv', label: 'Accounts and notes receivable ($)' },
      { k: 'a_life', label: 'Life insurance cash surrender value ($)' }, { k: 'a_stocks', label: 'Stocks and bonds ($)' }, { k: 'a_auto', label: 'Automobile present value ($)' },
      { k: 'l_payable', label: 'Accounts payable ($)' }, { k: 'l_notes', label: 'Notes payable to banks and others ($)' }, { k: 'l_instAuto', label: 'Installment account, auto ($)' },
      { k: 'l_instOther', label: 'Installment account, other ($)' }, { k: 'l_loanLife', label: 'Loan on life insurance ($)' }, { k: 'l_taxes', label: 'Unpaid taxes ($)' }, { k: 'l_other', label: 'Other liabilities ($)' }
    ] },
    { id: 'fin', title: 'Tax and money records', scope: 'fin', blurb: 'Where your financial paperwork lives.', fields: [
      { k: 'taxYears', label: 'Tax years you have filed (e.g. 2021, 2022, 2023, 2024, 2025)', req: 1 },
      { k: 'taxForm', label: 'Federal return the business files', type: 'select', opts: ['1040 (Schedule C)', '1065', '1120', '1120-S'], req: 1, help: 'Used on the IRS 4506-T. Your CPA or last return will say.' },
      { k: 'cpa', label: 'CPA / preparer name and phone' },
      { k: 'bank', label: 'Business bank and branch', req: 1 },
      { k: 'signers', label: 'Who is authorized on the business bank account?', type: 'textarea', req: 1 },
      { k: 'stateTax', label: 'Illinois tax ID (IDOR) and any City tax / license numbers' },
      { k: 'bonding', label: 'Surety / bonding company and limit (if any)' }
    ] },
    { id: 'contracts', title: 'Work you have done', scope: 'array', arr: 'contracts', max: 6, addLabel: 'Add another contract', blurb: 'Representative contracts that show you do the work in your NAICS codes. Three to five is typical.', fields: [
      { k: 'client', label: 'Client / owner of the project', req: 1 }, { k: 'project', label: 'Project and what you did', req: 1 },
      { k: 'amount', label: 'Contract amount ($)' }, { k: 'year', label: 'Year completed' },
      { k: 'paid', label: 'Do you have proof of payment (deposit record / paid invoice)?', type: 'select', opts: ['Yes', 'No'] }
    ] }
  ];

  /* ---------- sample client: fictional ---------- */
  var SAMPLE = {
    startDate: '2026-11-09',
    biz: { legalName: 'ABC General Contractors LLC', dba: '', entityType: 'LLC', ein: '00-0000000', stateInc: 'Illinois', incDate: '2019-03-04', startDate: '2019-04-01',
      address: '100 Example Ave', city: 'Chicago', state: 'IL', zip: '60601', phone: '(312) 555-0100', email: 'office@abcgc.example', website: 'abcgc.example',
      naics: '236220 - Commercial and institutional building construction\n236118 - Residential remodelers\n238990 - All other specialty trade contractors',
      scope: 'General contractor for small commercial build-outs, tenant improvements and residential remodels. We bid, self-perform framing, drywall and finish work, and manage licensed subcontractors for electrical and plumbing.',
      employeesFT: '6', employeesPT: '4', receipts1: '1850000', receipts2: '1420000', receipts3: '960000',
      licenses: 'City of Chicago General Contractor license, no. 00000, exp. 2027-06-30', locType: 'Lease', landlord: 'Example Properties LLC', leaseStart: '2025-01-01', leaseEnd: '2027-12-31', sqft: '3,200 sq ft office and yard',
      affiliates: 'None', priorCerts: 'None' },
    owners: [{ name: 'Alexis B. Carter', title: 'Managing Member / President', pct: '100', gender: 'Female', ethnicity: 'Black or African American', citizenship: 'U.S. citizen', ownerSince: '2019-03-04',
      hours: '55', years: '14', education: 'B.S. Construction Management; OSHA 30; LEED Green Associate', trades: 'None personally', capAmt: '60000', capDate: '2019-03-15', capSource: 'Personal savings',
      capNote: 'Transferred from personal savings account to the business checking account in March 2019; bank statement for that month on file.',
      duties: 'Sets bid prices and signs every proposal and contract; hires and supervises the project managers; approves all payables and signs checks; negotiates with clients and subcontractors; meets weekly with every job superintendent.',
      signs: 'Yes', otherJob: 'None', formerName: 'None', homeStreet: '200 Sample St', homeCSZ: 'Chicago, IL 60608', homePhone: '(312) 555-0199', ownerEmail: 'alexis@abcgc.example', nationalOrigin: 'United States', salary: '95000', family: 'None',
      a_cash: '45000', a_savings: '80000', a_recv: '12000', a_life: '15000', a_stocks: '90000', a_auto: '38000', l_payable: '4000', l_notes: '0', l_instAuto: '18000', l_instOther: '0', l_loanLife: '0', l_taxes: '0', l_other: '8000' }],
    fin: { taxForm: '1040 (Schedule C)', taxYears: '2021, 2022, 2023, 2024, 2025', cpa: 'Example CPA, (312) 555-0111', bank: 'Example Bank, Loop branch', signers: 'Alexis B. Carter, sole signer', stateTax: 'IDOR 0000-0000', bonding: 'None' },
    contracts: [
      { client: 'Example Retail Co.', project: 'Tenant build-out, 4,000 sq ft, general contractor', amount: '310000', year: '2025', paid: 'Yes' },
      { client: 'Sample Dental Group', project: 'Office renovation, prime contractor', amount: '185000', year: '2025', paid: 'Yes' },
      { client: 'J. Homeowner', project: 'Kitchen and bath remodel', amount: '92000', year: '2024', paid: 'Yes' }
    ],
    docs: {}
  };

  var PNW_LIMIT = 2955193.19; // City of Chicago 2026 Personal Net Worth limit (construction), official PDF
  function n(x) { var v = parseFloat(String(x == null ? '' : x).replace(/[^0-9.\-]/g, '')); return isNaN(v) ? 0 : v; }
  function netWorth(o) {
    var A = n(o.a_cash) + n(o.a_savings) + n(o.a_recv) + n(o.a_life) + n(o.a_stocks) + n(o.a_auto);
    var L = n(o.l_payable) + n(o.l_notes) + n(o.l_instAuto) + n(o.l_instOther) + n(o.l_loanLife) + n(o.l_taxes) + n(o.l_other);
    return { assets: A, liabilities: L, net: A - L };
  }
  /* ---------- eligibility screen ---------- */
  function pct(o) { var n = parseFloat(o.pct); return isNaN(n) ? 0 : n; }
  function isMinority(o) { return ['Black or African American', 'Hispanic / Latino', 'Asian American', 'Native American / Alaska Native'].indexOf(o.ethnicity) >= 0; }
  function citizenOK(o) { return o.citizenship === 'U.S. citizen' || o.citizenship === 'Lawful permanent resident'; }
  function eligibility(P) {
    var out = [], O = P.owners || [], b = P.biz || {};
    var tot = O.reduce(function (a, o) { return a + pct(o); }, 0);
    var mbe = O.filter(function (o) { return isMinority(o) && citizenOK(o); }).reduce(function (a, o) { return a + pct(o); }, 0);
    var wbe = O.filter(function (o) { return o.gender === 'Female' && citizenOK(o); }).reduce(function (a, o) { return a + pct(o); }, 0);
    if (b.entityType === 'Nonprofit corporation') out.push({ lvl: 'stop', t: "The City's official checklist states proof of non-profit status is \"not an option for M/WBE Applicant firms.\" A nonprofit is not eligible for M/WBE certification." });
    if (!O.length) out.push({ lvl: 'stop', t: 'Add at least one owner.' });
    else if (Math.abs(tot - 100) > 0.01) out.push({ lvl: 'warn', t: 'Ownership adds up to ' + tot + '%, not 100%.' });
    out.push({ lvl: mbe >= 51 ? 'ok' : 'warn', t: 'Minority-owned (MBE) share held by qualifying citizens / permanent residents: ' + mbe + '% (need at least 51%).' });
    out.push({ lvl: wbe >= 51 ? 'ok' : 'warn', t: 'Women-owned (WBE) share held by qualifying citizens / permanent residents: ' + wbe + '% (need at least 51%).' });
    if (mbe >= 51 && wbe >= 51) out.push({ lvl: 'info', t: 'This firm can qualify as either MBE or WBE. Ask DPS which category to apply under (one is typically chosen). Do not guess.' });
    O.forEach(function (o) {
      if ((isMinority(o) || o.gender === 'Female') && pct(o) >= 20) {
        var nw = netWorth(o);
        if (nw.net > PNW_LIMIT) out.push({ lvl: 'warn', t: (o.name || 'Owner') + ' reports net worth of $' + Math.round(nw.net).toLocaleString('en-US') + ', above the City 2026 limit of $2,955,193.19 (construction). Over the limit means economically not disadvantaged. Confirm what counts with DPS before applying.' });
        else out.push({ lvl: 'ok', t: (o.name || 'Owner') + ': net worth $' + Math.round(nw.net).toLocaleString('en-US') + ' is under the City 2026 limit of $2,955,193.19 (official figure; excludes the business and primary home per the form).' });
      }
      if (isMinority(o) || o.gender === 'Female') {
        var h = parseFloat(o.hours);
        if (!isNaN(h) && h < 35) out.push({ lvl: 'warn', t: o.name + ' works ' + h + ' hrs/week. Reviewers look hard at whether the qualifying owner truly runs the business day to day.' });
        if (o.signs === 'No') out.push({ lvl: 'warn', t: o.name + ' cannot sign alone. Control is a core test; fix the bank/contract signing authority before applying.' });
      }
    });
    var yrs = (P.fin && P.fin.taxYears || '').split(/[,;\s]+/).filter(function (x) { return /^\d{4}$/.test(x); });
    if (yrs.length < 3) out.push({ lvl: 'warn', t: 'Fewer than 3 filed tax years listed. The City asks for the most recent 3 to 5. Newer businesses should ask DPS what to submit.' });
    if (b.leaseEnd && P.startDate) {
      var need = new Date(P.startDate + 'T00:00:00'); need.setMonth(need.getMonth() + 6);
      if (new Date(b.leaseEnd + 'T00:00:00') < need) out.push({ lvl: 'warn', t: 'Lease ends ' + b.leaseEnd + ', less than 6 months after your target application date. The lease should run at least 6 months past application; get a renewal or extension first.' });
    }
    return { items: out, mbe: mbe, wbe: wbe, total: tot, blocked: out.some(function (x) { return x.lvl === 'stop'; }) };
  }

  /* ---------- missing-info report ---------- */
  function missing(P) {
    var out = [];
    SECTIONS.forEach(function (s) {
      if (s.scope === 'array') {
        var arr = P[s.arr] || [];
        if (!arr.length) { out.push({ sec: s.title, label: 'At least one entry', where: null }); return; }
        arr.forEach(function (row, i) { s.fields.forEach(function (f) { if (f.req && !has(row[f.k])) out.push({ sec: s.title + ' #' + (i + 1) + (row.name ? ' (' + row.name + ')' : ''), label: f.label, where: f.where || null }); }); });
      } else {
        var d = P[s.scope] || {};
        s.fields.forEach(function (f) { if (f.req && !has(d[f.k])) out.push({ sec: s.title, label: f.label, where: f.where || null }); });
      }
    });
    return out;
  }

  /* ---------- the document checklist ---------- */
  function checklist(P) {
    var b = P.biz || {}, t = b.entityType, O = P.owners || [], L = [];
    var corp = t === 'S-Corporation' || t === 'C-Corporation';
    var form = t === 'S-Corporation' ? 'Form 1120-S' : t === 'C-Corporation' ? 'Form 1120' : t === 'Partnership' ? 'Form 1065' : t === 'LLC' ? 'Form 1065, 1120-S or Schedule C (whichever the LLC files)' : 'Schedule C with Form 1040';
    function add(id, group, title, why, where, ifMissing, src) { L.push({ id: id, group: group, title: title, why: why, where: where || [], ifMissing: ifMissing || '', src: src || 'list' }); }
    add('tax', 'Tax and financial', 'Signed federal business tax returns, most recent 3 to 5 years (' + form + ') with every schedule', 'Proves the business exists, its size and who owns it.', [LINK.irsBiz], 'Ask your CPA for complete signed copies. If a year was never filed, file it first (the City cannot certify around a missing return). Copies can also be ordered from the IRS.');
    add('tax1040', 'Tax and financial', 'Each owner\'s personal federal returns (Form 1040), same years', 'Commonly requested to confirm owner income, capital and net worth. Confirm with DPS.', [LINK.irsTranscript], 'Download return transcripts from IRS Get Transcript or ask your preparer.', 'common');
    add('f4506t', 'Tax and financial', 'IRS Form 4506-T signed by the business (and owners if asked)', 'Lets the City verify your filings directly with the IRS.', [LINK.attach5, LINK.irs4506t], 'Download, fill in your name, EIN and tax years, sign. Do not leave lines blank; ask DPS which lines they want completed.');
    add('statetax', 'Tax and financial', 'State and local business tax filings', 'Shows you are current with Illinois and City taxes.', [], 'Pull your IDOR and City filings; your CPA usually has them.');
    add('fin', 'Tax and financial', 'Year-to-date profit and loss and balance sheet', 'Shows current financial health.', [], 'Ask your bookkeeper/CPA to run them from your accounting software, signed and dated this month.');
    add('ownstmt', 'Tax and financial', "Attachment 1: Individual Statement of Ownership, one per owner (with copy of driver's license/State ID, proof of race/ethnicity, 3 years of W-2/1099s, last 3 individual federal and state returns)", 'Official City form. Asks SSN, license number and date of birth, which you write in by hand; the Hub never stores them.', [LINK.attach1], 'Use the Official Forms tab to pre-fill everything except SSN, license number and date of birth.');
    add('social', 'Control and expertise', 'Attachment 4: Affidavit of Social Disadvantage (if the City asks for it for your category)', 'Official City form. Confirm with DPS whether your category requires it.', [LINK.attach4], 'Download, complete and sign.', 'common');
    add('capital', 'Tax and financial', 'Proof of capital: bank statements / canceled checks showing how each owner funded the business', 'The City checks that the qualifying owner, not someone else, put in the money.', [], 'Pull the bank statements for the months money went in. A drafted Capital Contribution Statement is in the Draft Documents tab, but it only describes what the bank records already prove.');
    add('bankcards', 'Tax and financial', 'Bank signature cards and banking resolution (authorized signers)', 'Shows who controls the money.', [], 'Ask your branch manager for signature cards and the resolution naming the authorized signers.');
    add('pnw', 'Tax and financial', 'Personal Net Worth Statement for each qualifying owner', 'Completed inside the portal. We collect the figures once so you can copy them in.', [LINK.attach2, LINK.pnwLimit, LINK.portal], 'The Portal Answers tab lists your numbers. List assets and debts honestly; do not guess.');

    O.forEach(function (o, i) {
      add('id' + i, 'Legal and identity', 'Proof of citizenship or permanent residency: ' + (o.name || 'owner ' + (i + 1)), 'Required for every owner claiming minority or women status.', [LINK.passport, LINK.birthCert, LINK.idme], 'Order a certified birth certificate or passport, or replace the permanent resident card, before you start. These take weeks.');
    });
    if (corp) {
      add('art', 'Legal and identity', 'Articles of Incorporation (certified copy)', 'Entity formation proof.', [LINK.ilsosLLC], 'Order a certified copy from the Illinois Secretary of State.');
      add('bylaws', 'Legal and identity', 'Corporate bylaws', 'Shows governance and who controls the board.', [], 'If you never wrote bylaws, an attorney can draft them. They must reflect how the company truly operates.');
      add('stock', 'Legal and identity', 'Stock certificates (front and back) and stock transfer ledger', 'Proves who holds the shares.', [], 'If certificates were never issued, issue them now to the true owners and record the issue date in a ledger.');
    } else if (t === 'LLC') {
      add('art', 'Legal and identity', 'Articles of Organization (certified copy)', 'Entity formation proof.', [LINK.ilsosLLC], 'Order a certified copy from the Illinois Secretary of State.');
      add('opag', 'Legal and identity', 'Operating Agreement (signed by all members)', 'Shows ownership, voting and management control.', [], 'If you do not have one, an attorney can prepare it. It must match how the business really runs.');
      add('memcert', 'Legal and identity', 'Membership certificates / membership ledger', 'Proves who holds membership interests.', [], 'Create a ledger listing members, percentages and dates.');
    } else if (t === 'Partnership') {
      add('partag', 'Legal and identity', 'Fully executed partnership agreement', 'Shows ownership and control.', [], 'Have all partners sign the current agreement.');
    }
    add('good', 'Legal and identity', 'Certificate of good standing', 'Commonly requested; shows the entity is active.', [LINK.ilsosLLC], 'Order online from the Illinois Secretary of State.', 'common');
    if (has(b.dba)) add('dba', 'Legal and identity', 'Assumed name (DBA) certificate', 'Required when you operate under another name.', [LINK.cookRecorder, LINK.ilsosAssumed], 'File the assumed name, then keep the filed copy.');
    add('lic', 'Legal and identity', 'Current business licenses and professional permits' + (has(b.licenses) ? ' (' + b.licenses.split('\n')[0] + ' ...)' : ''), 'Proves you can legally do the work.', [LINK.chiBuildings, LINK.chiBACP], 'Renew anything expired; the license class must match your NAICS work.');
    add('lease', 'Legal and identity', b.locType === 'Own' ? 'Property deed for the business location' : 'Signed commercial lease for the business location (valid at least 6 months past application)', 'Proves a real, controlled place of business.', [LINK.cookRecorder], 'Ask the landlord for a signed copy; get an extension if it ends soon.');

    O.forEach(function (o, i) {
      add('resume' + i, 'Control and expertise', 'Detailed resume: ' + (o.name || 'owner ' + (i + 1)), 'Shows the owner has the expertise to run the business.', [], 'A resume starter built from your answers is in the Draft Documents tab. Edit it; it must be accurate.');
      add('expert' + i, 'Control and expertise', 'Proof of expertise / credentials: ' + (o.name || 'owner ' + (i + 1)), 'Degrees, certifications and trade licenses.', [], 'Request transcripts or certificate copies from the issuing school or body.');
    });
    add('contracts', 'Control and expertise', 'Representative contracts, invoices and proof of payment in each NAICS code', 'Shows real operations in the work you ask to be certified for.', [], 'Pull signed contracts, invoices and the matching deposits. ' + (P.contracts && P.contracts.length ? 'You listed ' + P.contracts.length + ' in the Work tab.' : 'None listed yet.'));
    add('org', 'Control and expertise', 'Current organization chart', 'Official checklist, section I.', [LINK.schedAChecklist], 'A one-page chart is enough.');
    add('notary', 'Submit', 'Schedule A application signed by an Authorized Officer of the firm and NOTARIZED', 'Required by the official Schedule A checklist.', [LINK.schedAChecklist], 'Find a notary (many banks offer free notary service to customers) and bring photo ID. Do not sign before the notary watches you sign.');
    add('minutes', 'Legal and identity', 'Board or member meeting minutes: the first and the two most recent, including the one electing current officers', 'Official checklist, section III.', [LINK.schedAChecklist], 'If you have never held a meeting, hold one now and write minutes that record real decisions.', 'list');
    add('payroll', 'Control and expertise', 'Most recent 4 weeks of payroll for all employees and management, plus lists of trade employees and seasonal/contract employees by trade', 'Official checklist, section IV.', [LINK.schedAChecklist], 'Export payroll registers from your payroll service; build the two lists from them.');
    add('invoices', 'Control and expertise', 'For every listed contract: the agreement (scope, term, compensation) and the first and last invoice or purchase order', 'Official checklist, section I.', [LINK.schedAChecklist], 'Pull each from your files and accounting software.');
    add('loans', 'Tax and financial', 'Loan agreements from the last 3 years of $10,000 or more, lines/letters of credit, bond limits, certificate of insurance', 'Official checklist, section VI.', [LINK.schedAChecklist], 'Ask your lender, surety and insurance agent for copies and a current certificate of insurance.');
    add('equip', 'Control and expertise', 'Equipment: titles and purchase papers if owned, or leases with the most recent payment if leased', 'Official checklist, section VIII.', [LINK.schedAChecklist], 'List each major piece and attach the paper that proves who owns or leases it.');
    add('fin3', 'Tax and financial', 'Three years of the highest-level financial statements available (audited, reviewed or compiled) with balance sheet and income statement, plus current balance sheet', 'Official checklist, section VI. If none exist, the firm must certify that and explain in writing.', [LINK.schedAChecklist], 'Ask your CPA to compile them.');
    add('fee', 'Submit', '$250 non-refundable application fee, paid in the portal', 'Required to submit.', [LINK.portal], 'Have a card ready on submit day.');
    return L;
  }

  /* ---------- timeline ---------- */
  function addDays(d, n) { var x = new Date(d.getTime()); x.setDate(x.getDate() + n); return x; }
  var HOL=['2026-11-11','2026-11-26','2026-12-25','2027-01-01','2027-01-18','2027-02-15'];
  function iso(d) { return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); }
  function nextBiz(d) { var x = new Date(d.getTime()); while (x.getDay() === 0 || x.getDay() === 6 || HOL.indexOf(iso(x)) >= 0) x.setDate(x.getDate() + 1); return x; }
  function fmt(d) { return d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' }); }
  function timeline(P) {
    var s = P.startDate ? new Date(P.startDate + 'T00:00:00') : new Date();
    var steps = [
      { d: 0, phase: 'Prepare', t: 'Kick-off. Confirm eligibility and category (MBE or WBE) with DPS by phone. Ask if you can also use reciprocity (Cook County or BEP) to save time.', who: 'You, DPS', c: 'dps' },
      { d: 0, phase: 'Prepare', t: 'Start the slowest items first: certified Articles and good standing from the Secretary of State, IRS transcripts, replacement citizenship documents, landlord lease copy.', who: 'You, Secretary of State, IRS, landlord', c: 'sos' },
      { d: 2, phase: 'Prepare', t: 'Send your CPA and bank the exact request lists (copied from the Contacts tab).', who: 'CPA, bank', c: 'cpa' },
      { d: 4, phase: 'Prepare', t: 'Create your portal account at chicago.mwdbe.com and choose your NAICS codes.', who: 'You', c: 'dps' },
      { d: 7, phase: 'Prepare', t: 'Fill every gap in this Hub until Missing Info reads empty. Have every owner review and sign resumes and statements.', who: 'Every owner', c: null },
      { d: 10, phase: 'Prepare', t: 'Full-package check: every checklist line marked Have, every PDF legible, every tax return signed with all schedules.', who: 'You (a second person should check)', c: null },
      { d: 12, phase: 'Submit', t: 'SUBMIT: upload everything, pay the $250 fee, e-sign. The review clock starts only when the file is complete, so do not submit early.', who: 'You', c: 'dps' },
      { d: 17, phase: 'Follow up', t: 'Nudge #1: confirm the file was accepted as COMPLETE, get your analyst\'s name, and the date the review clock started.', who: 'DPS analyst', c: 'dps' },
      { d: 30, phase: 'Follow up', t: 'Nudge #2: any RFI (request for information) or site-visit scheduling? Answer any RFI the same day.', who: 'DPS analyst', c: 'dps' },
      { d: 60, phase: 'Follow up', t: 'Nudge #3: status check. Ask what, specifically, is still being reviewed.', who: 'DPS analyst', c: 'dps' },
      { d: 75, phase: 'Follow up', t: 'Nudge #4: ask for the expected decision date. If you also want Cook County or State BEP, file those now using the new City approval as proof.', who: 'DPS, Cook County, CEI', c: 'cook' },
      { d: 102, phase: 'Decision', t: 'Expected decision window (about 90 days after a COMPLETE submission, an unofficial vendor estimate; confirm with DPS). A "no response" past this date warrants a call to the Division manager.', who: 'DPS', c: 'dps' }
    ];
    return steps.map(function (x) { var dt = nextBiz(addDays(s, x.d)); return { date: fmt(dt), day: x.d, phase: x.phase, t: x.t, who: x.who, c: x.c }; });
  }
  var QUICK = [
    'Submit a complete, clean package the first time. An incomplete file delays the start of the review clock.',
    'Do the long-lead items on day one: certified Articles, IRS transcripts, citizenship documents and landlord signatures take the longest.',
    'Answer any request for information the same day, not the last day.',
    'If you are already certified by the Women\'s Business Development Center (WBDC) or the Chicago Minority Business Development Council (CMBDC), the City offers an expedited "Outside Recognition" application instead of the full Schedule A (official process PDF). Cook County and the City also accept each other\'s M/WBE certification. The State BEP advertises about 7 business days for partner-certified firms.',
    'Get your analyst\'s name at submission and keep a dated log of every call and email (the Hub\'s nudge drafts do this).',
    'Make the qualifying owner available for a site visit or interview. The owner must be able to explain every bid, hire and bank decision.',
    'Never fill a gap with a guess. A wrong statement can delay or end the application; the Hub marks gaps as NEEDED so they cannot slip through.'
  ];

  /* ---------- portal answer sheet ---------- */
  function money(x) { return has(x) ? '$' + Number(String(x).replace(/[^0-9.]/g, '')).toLocaleString('en-US') : gap('amount'); }
  function answers(P) {
    var b = P.biz || {}, f = P.fin || {}, S = [];
    S.push({ title: 'Business information', rows: [
      ['Legal name', val(b.legalName, 'legal name')], ['DBA', has(b.dba) ? b.dba : 'None'], ['Structure', val(b.entityType, 'structure')], ['EIN', val(b.ein, 'EIN')],
      ['State / date formed', val(b.stateInc, 'state') + ', ' + val(b.incDate, 'date formed')], ['Operating since', val(b.startDate, 'start date')],
      ['Address', [b.address, b.city, b.state, b.zip].filter(has).join(', ') || gap('address')], ['Phone', val(b.phone, 'phone')], ['Email', val(b.email, 'email')], ['Website', has(b.website) ? b.website : 'None'],
      ['Employees', (b.employeesFT || '0') + ' full-time, ' + (b.employeesPT || '0') + ' part-time'],
      ['Gross receipts (latest, prior, prior)', money(b.receipts1) + ' / ' + money(b.receipts2) + ' / ' + money(b.receipts3)],
      ['Existing certifications', has(b.priorCerts) ? b.priorCerts : 'None'], ['Affiliated businesses', has(b.affiliates) ? b.affiliates : gap('affiliates (write none if none)')]
    ] });
    S.push({ title: 'NAICS codes and scope of work', rows: [['NAICS codes', val(b.naics, 'NAICS codes')], ['Scope of work', val(b.scope, 'scope of work')]] });
    (P.owners || []).forEach(function (o, i) {
      S.push({ title: 'Owner ' + (i + 1) + ': ' + (o.name || ''), rows: [
        ['Name / title', val(o.name, 'name') + ' / ' + val(o.title, 'title')], ['Ownership', val(o.pct, 'percent') + '%'], ['Gender', val(o.gender, 'gender')], ['Race / ethnicity', val(o.ethnicity, 'ethnicity')],
        ['Citizenship', val(o.citizenship, 'citizenship')], ['Owner since', val(o.ownerSince, 'date')], ['Hours per week in business', val(o.hours, 'hours')], ['Years of experience', val(o.years, 'years')],
        ['Education / certifications', val(o.education, 'education')], ['Trade licenses', has(o.trades) ? o.trades : 'None'],
        ['Capital contributed', money(o.capAmt) + ' on ' + val(o.capDate, 'date') + ' from ' + val(o.capSource, 'source')], ['Source detail', val(o.capNote, 'description of source')],
        ['Day-to-day control', val(o.duties, 'duties')], ['Signs checks and contracts alone', val(o.signs, 'yes/no')], ['Other employment', val(o.otherJob, 'other employment (none if none)')],
        ['Personal net worth (from your line items)', '$' + Math.round(netWorth(o).net).toLocaleString('en-US') + ' (assets $' + Math.round(netWorth(o).assets).toLocaleString('en-US') + ', liabilities $' + Math.round(netWorth(o).liabilities).toLocaleString('en-US') + ')']
      ] });
    });
    S.push({ title: 'Tax and banking', rows: [['Federal return filed', val(f.taxForm, 'return type')], ['Tax years filed', val(f.taxYears, 'tax years')], ['CPA', val(f.cpa, 'CPA')], ['Bank', val(f.bank, 'bank')], ['Authorized signers', val(f.signers, 'signers')], ['State / City tax IDs', val(f.stateTax, 'tax IDs')], ['Bonding', has(f.bonding) ? f.bonding : 'None']] });
    S.push({ title: 'Location', rows: [['Type', val(b.locType, 'type')], ['Landlord', has(b.landlord) ? b.landlord : 'n/a'], ['Lease term', has(b.leaseStart) || has(b.leaseEnd) ? (b.leaseStart || '?') + ' to ' + (b.leaseEnd || '?') : 'n/a'], ['Space', val(b.sqft, 'space')]] });
    S.push({ title: 'Representative contracts', rows: (P.contracts || []).map(function (c, i) { return ['Contract ' + (i + 1), val(c.client, 'client') + ' | ' + val(c.project, 'project') + ' | ' + money(c.amount) + ' | ' + (c.year || '') + ' | proof of payment: ' + (c.paid || '?')]; }) });
    return S;
  }

  /* ---------- drafted documents ---------- */
  var TRUTH = 'DRAFT. Every statement here must be true and backed by a record. Review, correct, then have the named person sign. Do not sign anything that is not accurate.';
  function drafts(P) {
    var b = P.biz || {}, f = P.fin || {}, O = P.owners || [], D = [];
    var biz = val(b.legalName, 'business name');
    var addr = [b.address, b.city, b.state, b.zip].filter(has).join(', ') || gap('address');
    D.push({ id: 'cover', title: 'Cover letter to the certification analyst', body:
      'To: City of Chicago, Department of Procurement Services, Certification and Compliance Division\nRe: M/WBE certification application for ' + biz + '\n\n' +
      'Enclosed is the application package for ' + biz + ', ' + val(b.entityType, 'structure') + ', EIN ' + val(b.ein, 'EIN') + ', located at ' + addr + '. We request certification for these NAICS codes:\n' + val(b.naics, 'NAICS codes') + '\n\n' +
      'The qualifying owner(s) are ' + (O.map(function (o) { return val(o.name, 'owner') + ' (' + val(o.pct, '%') + '%)'; }).join(', ') || gap('owners')) + '. Please direct questions to ' + (O[0] && O[0].name || gap('contact')) + ' at ' + val(b.phone, 'phone') + ' or ' + val(b.email, 'email') + '.\n\nSincerely,\n' + (O[0] && O[0].name || gap('signer')) + '\n' + (O[0] && O[0].title || '') });
    D.push({ id: 'history', title: 'Business history and scope of work', body:
      biz + ' was formed ' + val(b.incDate, 'date formed') + ' in ' + val(b.stateInc, 'state') + ' and began operating ' + val(b.startDate, 'start date') + '. It employs ' + (b.employeesFT || '0') + ' full-time and ' + (b.employeesPT || '0') + ' part-time workers.\n\nWork performed: ' + val(b.scope, 'scope of work') + '\n\nNAICS codes requested:\n' + val(b.naics, 'NAICS codes') });
    O.forEach(function (o, i) {
      var n = val(o.name, 'owner name');
      D.push({ id: 'resume' + i, title: 'Resume starter: ' + n, body:
        n + '\n' + val(o.title, 'title') + ', ' + biz + '\n' + val(b.phone, 'phone') + ' | ' + val(b.email, 'email') + '\n\nSUMMARY\n' + val(o.years, 'years of experience') + ' years in the trade. Owner of ' + biz + ' since ' + val(o.ownerSince, 'date') + ', holding ' + val(o.pct, '%') + '% of the company.\n\n' +
        'CURRENT ROLE AND RESPONSIBILITIES\n' + val(o.duties, 'duties') + '\n\nEDUCATION, TRAINING AND CERTIFICATIONS\n' + val(o.education, 'education') + '\n\nTRADE LICENSES\n' + (has(o.trades) ? o.trades : 'None') +
        '\n\nPRIOR EXPERIENCE\n' + gap('previous employers, titles, dates and duties, most recent first') });
      D.push({ id: 'cap' + i, title: 'Capital contribution statement: ' + n, body:
        'I, ' + n + ', state that on ' + val(o.capDate, 'date') + ' I contributed ' + money(o.capAmt) + ' to ' + biz + '. The source of these funds was: ' + val(o.capSource, 'source') + '. ' + val(o.capNote, 'description of the source') +
        '\n\nSupporting records attached: ' + gap('list the bank statements / canceled checks that prove this') + '\n\nSigned: ______________________   Date: ____________' });
      D.push({ id: 'ctrl' + i, title: 'Management and control statement: ' + n, body:
        'I, ' + n + ', ' + val(o.title, 'title') + ' of ' + biz + ', work about ' + val(o.hours, 'hours') + ' hours per week in this business. I personally:\n' + val(o.duties, 'duties') + '\n\nCan sign checks and contracts alone: ' + val(o.signs, 'yes/no') + '. Other employment or businesses: ' + val(o.otherJob, 'other employment') + '.\n\nSigned: ______________________   Date: ____________' });
    });
    D.push({ id: 'lease', title: 'Location summary', body:
      'Place of business: ' + addr + '.\nType: ' + val(b.locType, 'type') + (b.locType === 'Lease' ? '\nLandlord: ' + val(b.landlord, 'landlord') + '\nTerm: ' + val(b.leaseStart, 'start') + ' to ' + val(b.leaseEnd, 'end') : '') + '\nSpace and use: ' + val(b.sqft, 'space and use') });
    D.push({ id: 'contracts', title: 'Contract and project list', body: (P.contracts || []).map(function (c, i) { return (i + 1) + '. ' + val(c.client, 'client') + ': ' + val(c.project, 'project') + ', ' + money(c.amount) + ', ' + (c.year || '') + '. Proof of payment: ' + (c.paid || '?') + '.'; }).join('\n') || gap('contracts') });
    D.push({ id: 'req-cpa', title: 'Request to your CPA (copy and send)', body:
      'Hello, I am applying for City of Chicago M/WBE certification for ' + biz + ' and need these by ' + fmt(addDays(P.startDate ? new Date(P.startDate + 'T00:00:00') : new Date(), 5)) + ':\n- Complete signed federal returns, all schedules, for ' + val(f.taxYears, 'tax years') + '\n- State and local tax filings for the same years\n- Year-to-date profit and loss and balance sheet\n- Your help signing IRS Form 4506-T\nThank you.' });
    D.push({ id: 'req-bank', title: 'Request to your bank (copy and send)', body:
      'Hello, I need the following for ' + biz + ' for a certification application:\n- Signature cards and the banking resolution naming authorized signers\n- Account opening documents\n- Statements for the months around ' + (O[0] && O[0].capDate || gap('capital deposit date')) + ' showing the owner\'s initial capital\nThank you.' });
    return D;
  }

  /* ---------- nudge emails ---------- */
  function nudge(P, cid, info) {
    var c = CONTACTS.filter(function (x) { return x.id === cid; })[0] || CONTACTS[0], b = P.biz || {}, o = (P.owners || [])[0] || {};
    info = info || {};
    return { to: c.org, subject: 'Status of M/WBE application: ' + val(b.legalName, 'business') + (info.appNo ? ' (App # ' + info.appNo + ')' : ''), body:
      'Hello' + (info.analyst ? ' ' + info.analyst : '') + ',\n\nI am following up on the certification application for ' + val(b.legalName, 'business') + (info.appNo ? ', application number ' + info.appNo : '') + (info.submitted ? ', submitted ' + info.submitted : '') + '.\n\n' +
      'Could you please confirm:\n' + c.ask.map(function (q) { return '- ' + q; }).join('\n') + '\n\nIf anything is missing, tell me exactly what and I will send it the same day.\n\nThank you,\n' + val(o.name, 'name') + '\n' + val(b.phone, 'phone') + '\n' + val(b.email, 'email') };
  }

  var api = { PNW_LIMIT: PNW_LIMIT, netWorth: netWorth, esc: esc, has: has, SECTIONS: SECTIONS, LINK: LINK, CONTACTS: CONTACTS, SAMPLE: SAMPLE, QUICK: QUICK, TRUTH: TRUTH, eligibility: eligibility, missing: missing, checklist: checklist, timeline: timeline, answers: answers, drafts: drafts, nudge: nudge };
  if (typeof module !== 'undefined' && module.exports) module.exports = api; else root.CertEngine = api;
})(typeof window !== 'undefined' ? window : globalThis);
