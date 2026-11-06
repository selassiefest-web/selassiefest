/* Certification packages beyond the City of Chicago M/WBE: Cook County MWBE and Illinois BEP (CEI).
   Facts below come from the programs' own pages and PDFs, read Nov 5, 2026. Items flagged verify are not confirmed on an official page. */
(function (root) {
  'use strict';
  var E = root.CertEngine;
  var has = E.has, esc = E.esc;
  var CF = 'https://www.cookcountyil.gov/sites/g/files/ywwepo161/files/documents/';
  var CEI = 'https://cei.illinois.gov/content/dam/soi/en/web/cei/documents/';

  /* ---------- extra links ---------- */
  var L = E.LINK;
  L.cookPortal = { t: 'Cook County certification portal (cookcounty.diversitycompliance.com)', u: 'https://cookcounty.diversitycompliance.com/' };
  L.cookCert = { t: 'Cook County Business Enterprise Development: certification page', u: 'https://www.cookcountyil.gov/service/business-enterprise-development-certification' };
  L.cookForms = { t: 'Cook County certification form library', u: 'https://www.cookcountyil.gov/service/contract-compliance-form-library' };
  L.cookSchedA = { t: 'Cook County Schedule A document checklist (official PDF)', u: 'forms/cook-schedule-a-checklist-rev-2024.pdf' };
  L.cookRecipAff = { t: 'Cook County Reciprocal Certification Affidavit, Rev. 01/2025 (official PDF)', u: 'forms/cook-reciprocal-affidavit-rev-2025-01.pdf' };
  L.cookRecipRegs = { t: 'City + Cook reciprocal certification regulations, 1.30.2025 (official PDF)', u: 'forms/chicago-cook-reciprocal-regulations-2025-01.pdf' };
  L.sdmp = { t: 'Illinois Supplier Diversity Management Portal (BEP application)', u: 'https://supplierdiversitymanagementportal.illinois.gov/' };
  L.bepPage = { t: 'CEI: Get BEP certified', u: 'https://cei.illinois.gov/vendor-resources/get-bep-certified.html' };
  L.bepFull = { t: 'BEP Full Certification Information Checklist, May 2025 (official PDF)', u: 'forms/bep-full-certification-checklist-2025-05.pdf' };
  L.bepNCA = { t: 'BEP No Change Affidavit checklist (official PDF)', u: 'forms/bep-no-change-affidavit-checklist.pdf' };
  L.bepRecog = { t: 'BEP recognition certification (BE BEP / FastTrack) registration instructions (official PDF)', u: 'forms/bep-recognition-registration-renewal.pdf' };
  L.cookRecipForm = { t: 'Chicago M/WBE portal', u: 'https://www.chicago.mwdbe.com' };

  /* ---------- contacts ---------- */
  E.CONTACTS.forEach(function (c) { if (c.id === 'cook') { c.org = 'Cook County Business Enterprise Development'; c.phone = '312-603-5502'; c.email = 'Procurementoutreach@cookcountyil.gov'; c.verify = false; c.src = 'Listed on the County\'s Business Enterprise Development contact page, Nov 5, 2026. The agency page names Nicole N. Mandeville as Director. No street address is published there.'; c.link = L.cookCert; } });
  E.CONTACTS.forEach(function (c) { if (c.id === 'cei') { c.org = 'Illinois Commission on Equity and Inclusion (BEP unit)'; c.link = L.bepPage; c.src = 'The official CEI page lists only a Contact Us page (cei.illinois.gov/contact-us.html). This phone and email come from the 2024 CEI checklist: confirm them.'; } });
  E.CONTACTS.push({ id: 'sdmp', org: 'SDMP technical support (BEP portal logins and passwords)', role: 'Portal login problems and password resets only, not application decisions.', phone: '1-877-557-5258', email: 'ILCEISupport@starssmp.com', addr: '', link: L.sdmp, verify: false, src: 'Printed in the CEI recognition-certification instructions letter (official PDF).', ask: ['I cannot log in to the Supplier Diversity Management Portal. Please reset my account.'] });

  E.PACKAGES = [
    { id: 'chicago', title: 'City of Chicago M/WBE', short: 'Chicago', contacts: ['dps', 'irs', 'sos', 'bank', 'cpa'] },
    { id: 'cook', title: 'Cook County MWBE', short: 'Cook County', contacts: ['cook', 'dps', 'irs', 'sos', 'bank', 'cpa'] },
    { id: 'bep', title: 'Illinois BEP (State of Illinois)', short: 'State BEP', contacts: ['cei', 'sdmp', 'dps', 'cook', 'bank', 'cpa'] }
  ];
  E.HELD = ['None', 'City of Chicago M/WBE', 'Cook County MWBE', 'Women\'s Business Development Center (WBDC)', 'Chicago MSDC or Mid-States MSDC'];

  /* ---------- helpers ---------- */
  function ownersOf(P) { return P.owners || []; }
  function structure(P) { var t = (P.biz || {}).entityType; return (t === 'S-Corporation' || t === 'C-Corporation') ? 'corp' : t === 'LLC' ? 'llc' : t === 'Partnership' ? 'partnership' : 'sole'; }
  function mk(L0) { return function (id, group, title, why, where, ifMissing, src) { L0.push({ id: id, group: group, title: title, why: why, where: where || [], ifMissing: ifMissing || '', src: src || 'list' }); }; }
  function addDays(d, n) { var x = new Date(d.getTime()); x.setDate(x.getDate() + n); return x; }
  var HOL = ['2026-11-11', '2026-11-26', '2026-12-25', '2027-01-01', '2027-01-18', '2027-02-15'];
  function iso(d) { return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); }
  function nextBiz(d) { var x = new Date(d.getTime()); while (x.getDay() === 0 || x.getDay() === 6 || HOL.indexOf(iso(x)) >= 0) x.setDate(x.getDate() + 1); return x; }
  function addBiz(d, n) { var x = new Date(d.getTime()), k = 0; while (k < n) { x.setDate(x.getDate() + 1); if (x.getDay() !== 0 && x.getDay() !== 6 && HOL.indexOf(iso(x)) < 0) k++; } return x; }
  function fmt(d) { return d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' }); }
  function start(P) { return P.startDate ? new Date(P.startDate + 'T00:00:00') : new Date(); }
  function held(P) { return (P.biz || {}).heldCert || 'None'; }

  /* ---------- Cook County checklist ---------- */
  function cookRoute(P) { return held(P) === 'City of Chicago M/WBE' ? 'reciprocal' : 'full'; }
  function cookChecklist(P) {
    var L0 = [], add = mk(L0), route = cookRoute(P), O = ownersOf(P), s = structure(P);
    if (route === 'reciprocal') {
      add('c_aff', 'Reciprocal route', 'Cook County MBE/WBE Reciprocal Certification Affidavit (Rev. 01/2025), signed by an authorized representative and NOTARIZED', 'Official County form. Good for one year from the sworn signature. Confirms current City certification and that personal net worth is under $2,955,193.19 and gross receipts are under the SBA size standard (7-year average).', [L.cookRecipAff, L.cookRecipRegs], 'Use the Official forms tab to pre-fill, then sign before a notary.');
      add('c_proof', 'Reciprocal route', 'Proof of your current City of Chicago MBE/WBE certification (certificate or approval letter)', 'Reciprocity rests on the City certification.', [L.portal], 'Download from your City portal account.');
      add('c_ask', 'Reciprocal route', 'Ask Cook County what else the reciprocal filing needs and whether a fee applies', 'The County page does not publish reciprocal-filing steps beyond the affidavit. Confirm by phone or email.', [L.cookCert], 'Call 312-603-5502 or email Procurementoutreach@cookcountyil.gov and write down the answer and who gave it.');
      return L0;
    }
    add('c1', 'Application (Schedule A)', 'Schedule A affidavit signed and dated by the qualifying owner(s) and NOTARIZED, completed in the County portal', 'Mandatory. Official County checklist item 1.', [L.cookPortal, L.cookSchedA], 'Create your portal account first; notarize after the owner has reviewed every answer.');
    add('c2', 'Application (Schedule A)', 'Bank resolution and/or signature cards for the applicant and all affiliates', 'Official checklist item 2.', [L.cookSchedA], 'Ask your branch manager.');
    add('c3', 'Application (Schedule A)', 'Initial and most recent 3 months of bank statements for every business account', 'Official checklist item 3. The first statement shows how the business was funded.', [L.cookSchedA], 'Download from online banking; for old accounts ask the bank for the opening statement.');
    add('c4', 'Application (Schedule A)', 'Three contracts, purchase orders or invoices showing work performed', 'Official checklist item 4.', [L.cookSchedA], 'Pull three from your files (' + ((P.contracts || []).length) + ' listed in the Work tab).');
    add('c5', 'Application (Schedule A)', 'W-2 and/or 1099 forms for the most recent 3 years for every owner, director, officer, manager and check signer', 'Official checklist item 5.', [L.cookSchedA], 'Ask your CPA or payroll provider; IRS wage transcripts are another source.');
    add('c6', 'Application (Schedule A)', 'Current licenses and certificates (professional, trade, City, County, State, Federal) or a statement that none are required', 'Official checklist item 6.', [L.chiBuildings, L.chiBACP], 'Renew anything expired.');
    add('c7', 'Application (Schedule A)', 'Payroll registers for the 4 most recent pay periods, or a statement about current payroll', 'Official checklist item 7.', [L.cookSchedA], 'Export from your payroll service.');
    O.forEach(function (o, i) { add('c8_' + i, 'Application (Schedule A)', 'Evidence of ethnicity, gender, citizenship and residency: ' + (o.name || 'owner ' + (i + 1)) + ' (driver\'s license / State ID plus birth certificate, I-551 card or passport)', 'Official checklist item 8. Also needed for every director, officer, manager and check signer.', [L.passport, L.birthCert, L.idme], 'Order replacement documents early; they take weeks.'); });
    add('c9', 'Application (Schedule A)', 'Most recent SEVEN years of complete, signed, dated federal business tax returns (and affiliates), all schedules', 'Official checklist item 9. This is longer than the City\'s 3 to 5 years.', [L.irsBiz], 'Ask your CPA now; order IRS transcripts if copies are missing.');
    add('c10', 'Application (Schedule A)', 'Most recent SEVEN years of complete, signed, dated personal federal returns for all owners', 'Official checklist item 10.', [L.irsTranscript], 'Download return transcripts from IRS Get Transcript or ask your preparer.');
    add('c11', 'Application (Schedule A)', 'Currently dated Personal Net Worth Statement for qualifying owners (51% or more)', 'Official checklist item 11.', [L.attach2], 'Use the Official forms tab to pre-fill Attachment 2 (City form); confirm with the County that it accepts the City\'s form or whether its portal has its own.');
    add('c12', 'Application (Schedule A)', 'Proof of equity contribution or start-up capital by owners (canceled checks, loan agreement, initial bank statement)', 'Official checklist item 12.', [L.cookSchedA], 'Pull the bank records that match the owner\'s capital figure.');
    O.forEach(function (o, i) { add('c13_' + i, 'Application (Schedule A)', 'Chronological resume: ' + (o.name || 'owner ' + (i + 1)) + ' (also every director, officer, manager, check signer)', 'Official checklist item 13: work experience, training and education reflecting the business activities sought.', [], 'A starter is in Draft documents.'); });
    if (s === 'llc') {
      add('cllc1', 'Structure: LLC', 'Original file-stamped Articles of Organization and all amendments', 'Official checklist, LLC.', [L.ilsosLLC], 'Order from the Illinois Secretary of State.');
      add('cllc2', 'Structure: LLC', 'Operating Agreement', 'Official checklist, LLC.', [], 'Must match how the business really runs.');
      add('cllc3', 'Structure: LLC', 'Most recent managers / members meeting minutes', 'Official checklist, LLC.', [], 'Hold and record a meeting if none exist.');
      add('cllc4', 'Structure: LLC', 'State of Illinois letter of good standing', 'Official checklist, LLC.', [L.ilsosLLC], 'Order online.');
    } else if (s === 'corp') {
      add('ccorp', 'Structure: corporation', 'Corporation documents: articles, bylaws, stock certificates and ledger, minutes, good standing', 'The corporation page of the County checklist did not extract as text. Follow the County checklist PDF (page 2) and the State BEP list, which asks for these.', [L.cookSchedA, L.bepFull], 'Open the County checklist PDF and tick each corporation line.');
    } else if (s === 'partnership') {
      add('cpart', 'Structure: partnership', 'Partnership agreement; assumed name certificate or certificate of limited partnership (file with the Cook County Clerk)', 'Official checklist, partnership.', [L.cookRecorder], 'File with the County Clerk.');
    } else {
      add('csole', 'Structure: sole proprietorship', 'Assumed name certificate (Cook County Clerk\'s Office)', 'Official checklist, sole proprietorship.', [L.cookRecorder], 'File with the County Clerk if you use a business name.');
    }
    add('cown', 'Control', 'Signed letter detailing the owner\'s role and records showing the owner directs management and works full time in the business', 'Official checklist, additional documents.', [L.cookSchedA], 'Use the management and control statement in Draft documents.');
    add('cfee', 'Submit', '$250 non-refundable application fee (free for veteran, service-disabled veteran and disability certifications). ACH e-check accepted: give your bank Company ID 0000408976 to avoid a debit block', 'Stated on the County certification page.', [L.cookCert], 'Tell your bank the Company ID before you pay.');
    return L0;
  }
  function cookEligibility(P) {
    return [
      { lvl: 'info', t: 'Cook County requires the principal office and most full-time workforce in Cook, DuPage, Kane, Will, Lake or McHenry County, Illinois.' },
      { lvl: 'info', t: 'Personal net worth limit $2,955,193.19 and business size at or under the SBA small business size standard for the industry (County page and affidavit; the affidavit averages 7 years of gross receipts). Confirm the exact size test for general contractors with the County.' }
    ];
  }

  /* ---------- State BEP checklist ---------- */
  function bepRoute(P) { var h = held(P); return h === 'City of Chicago M/WBE' || h === 'Cook County MWBE' ? 'be' : (h.indexOf('WBDC') >= 0 || h.indexOf('MSDC') >= 0) ? 'fast' : 'full'; }
  function bepChecklist(P) {
    var L0 = [], add = mk(L0), route = bepRoute(P), O = ownersOf(P), s = structure(P);
    add('b_portal', 'Start', 'Create your account in the Illinois Supplier Diversity Management Portal', 'All BEP applications are filed there. Certification is free.', [L.sdmp, L.bepPage], 'Choose "create account"; use a business email you control.');
    if (route === 'be') {
      add('b_host', 'BE BEP (recognition route)', 'Proof of current ' + held(P) + ' certification (your host agency)', 'BE BEP is open to firms certified by the City of Chicago or Cook County. Term and commodity codes follow the host certification.', [L.bepRecog], 'Download your certificate from the host agency portal.');
      add('b_apply', 'BE BEP (recognition route)', 'In the portal: Application tab > New Certification/Renewal > Apply for New/Renewal Certification > select your host agency > upload documents > Submit', 'Steps printed in CEI\'s official instructions letter.', [L.bepRecog], 'Follow those steps exactly.');
      add('b_codes', 'BE BEP (recognition route)', 'Enter the NIGP commodity codes your host agency gave you (NAICS codes can be translated with CEI\'s crosswalk)', 'You only receive codes approved by your host agency; more codes must come from the host.', [L.bepPage], 'If your host used NAICS, use the crosswalk option or let CEI translate.');
      return L0;
    }
    if (route === 'fast') {
      add('b_partner', 'FastTrack (recognition route)', 'Proof of your current certification from WBDC, Chicago MSDC or Mid-States MSDC', 'FastTrack is open to firms certified by those partner organizations.', [L.bepPage], 'Download the certificate or letter from the partner.');
      add('b_aff', 'FastTrack (recognition route)', 'Signed and NOTARIZED BEP application affidavit', 'CEI says the affidavit is generated when you start the application in the portal. The page does not link a form to pre-fill.', [L.sdmp], 'Start the application, download the affidavit, then sign before a notary.');
      return L0;
    }
    add('b1', 'Full BEP certification', 'BEP/VBP application affidavit signed by an authorized officer and NOTARIZED', 'Made available once the application process is started in the portal.', [L.sdmp, L.bepFull], 'Start the application, download the affidavit, then sign before a notary.');
    add('b2', 'Full BEP certification', 'Most recent financial statements including a balance sheet (assets and liabilities)', 'Official checklist item 2; all companies must provide a balance sheet.', [L.bepFull], 'Ask your CPA; a Procurement Technical Assistance Center can help.');
    add('b3', 'Full BEP certification', 'Most recent federal business tax return for the firm and all affiliates (5% or more ownership in another company), all attachments and schedules', 'Official checklist item 3.', [L.irsBiz], 'Ask your CPA.');
    add('b4', 'Full BEP certification', 'Most recent federal individual tax returns for all owners, all attachments and schedules', 'Official checklist item 4.', [L.irsTranscript], 'IRS Get Transcript or your preparer.');
    add('b5', 'Full BEP certification', 'Bank signature cards (and bank resolutions for corporations) showing who has access and what authority', 'Official checklist item 5.', [L.bepFull], 'Ask your branch manager.');
    add('b6', 'Full BEP certification', 'W-2 or 1099 forms for the past 3 years for all owners and officers (or 3 years of personal returns if unavailable)', 'Official checklist item 6.', [L.bepFull], 'Ask your CPA.');
    O.forEach(function (o, i) {
      add('b7_' + i, 'Full BEP certification', 'Evidence of citizenship / residency: ' + (o.name || 'owner ' + (i + 1)) + ' (passport, birth certificate, naturalization certificate or resident alien card)', 'Official checklist item 7.', [L.passport, L.birthCert], 'Order replacements early.');
      add('b8_' + i, 'Full BEP certification', 'Evidence of ethnicity: ' + (o.name || 'owner ' + (i + 1)) + ' (own or a parent\'s birth certificate showing ethnicity; otherwise a notarized, signed and dated ethnicity statement)', 'Official checklist item 8 (49 CFR Part 23).', [L.birthCert], 'If the birth certificate does not state ethnicity, write and notarize the statement.');
      add('b9_' + i, 'Full BEP certification', 'Chronological resume with dates and daily duties: ' + (o.name || 'owner ' + (i + 1)) + ' (also every officer, manager and supervisor)', 'Official checklist item 9.', [], 'A starter is in Draft documents.');
    });
    add('b10', 'Full BEP certification', 'Proof of every owner\'s contribution to acquire ownership or start-up capital, with the source of funds (canceled checks, bank statements, loan agreements; notarized statement for any gift or inheritance)', 'Official checklist item 10.', [L.bepFull], 'Pull the records and write the source of each deposit.');
    add('b11', 'Full BEP certification', 'Proof of purchase or signed buy-out agreements, if you bought the company or shares', 'Official checklist item 11.', [L.bepFull], 'Mark N/A if you founded the business.');
    add('b12', 'Full BEP certification', 'Equipment lease agreements and/or inventory of all equipment, including office equipment (mandatory)', 'Official checklist item 12.', [L.bepFull], 'List every item needed to run the business, even laptops and printers.');
    add('b13', 'Full BEP certification', 'Real estate agreements: leases, deeds or tax bills, including home-based offices and warehouses', 'Official checklist item 13.', [L.bepFull], 'Collect them.');
    add('b14', 'Full BEP certification', 'For the past 3 completed projects: cover page, signed signature page, scope of work, POs or invoices, with proof of payment (a PAID stamp is NOT proof) and proof you have the equipment, space and personnel for the codes', 'Official checklist item 14.', [L.bepFull], 'Match each invoice to the deposit on a bank statement.');
    add('b15', 'Full BEP certification', 'Illinois authorization to transact business (current Secretary of State letter of good standing)', 'Official checklist item 15.', [L.ilsosLLC], 'Order online.');
    add('b16', 'Full BEP certification', 'Any MBE/DBE/WBE/PBE or SBA 8(a) certifications or denials, or a statement of none', 'Official checklist item 16.', [L.bepFull], 'Write "none" if none.');
    add('b17', 'Full BEP certification', 'Current local, county and state business licenses and professional licenses (or a notarized letter that none is required)', 'Official checklist item 17.', [L.chiBuildings, L.chiBACP], 'Renew anything expired.');
    add('b18', 'Full BEP certification', 'Signed loan agreements and lines of credit, if any', 'Official checklist item 18.', [L.bepFull], 'Ask your lender.');
    add('b19', 'Full BEP certification', 'Titles of vehicles used for business or leased through the business, if any', 'Official checklist item 19.', [L.bepFull], 'Copy each title.');
    if (s === 'corp') {
      add('bcorp', 'Structure: corporation', 'Articles of Incorporation (front, back, amendments), bylaws, all stock certificates (issued and canceled) and stock ledger, first stockholder and first board minutes, most recent minutes appointing current officers', 'Official checklist, corporations (even a single shareholder).', [L.bepFull, L.ilsosLLC], 'A Procurement Technical Assistance Center can help build missing records.');
    } else if (s === 'llc') {
      add('bllc', 'Structure: LLC', 'Articles of Organization (front and back) and Operating Agreement', 'Official checklist, LLCs.', [L.bepFull, L.ilsosLLC], 'Order from the Secretary of State.');
    } else if (s === 'partnership') {
      add('bpart', 'Structure: partnership', 'Partnership agreement; assumed name certification or certificate of limited partnership', 'Official checklist, partnerships.', [L.bepFull], 'File with the county clerk.');
    } else {
      add('bsole', 'Structure: sole proprietorship', 'Assumed name certification from your county clerk', 'Official checklist, sole proprietorships.', [L.bepFull], 'File with the Cook County Clerk.');
    }
    return L0;
  }
  function bepEligibility(P) {
    return [{ lvl: 'info', t: 'BEP: at least 51% owned and controlled by minorities, women or persons with disabilities; owner is a U.S. citizen or lawful permanent resident; annual gross sales under $150 million. Certification is free.' }];
  }

  /* ---------- timelines ---------- */
  function step(s0, d, phase, t, who, c, biz) { var dt = biz ? addBiz(s0, d) : nextBiz(addDays(s0, d)); return { date: fmt(dt), day: d, phase: phase, t: t, who: who, c: c }; }
  function cookTimeline(P) {
    var s0 = start(P), r = cookRoute(P), out = [];
    if (r === 'reciprocal') {
      out.push(step(s0, 0, 'Prepare', 'Call or email Cook County Business Enterprise Development: confirm the reciprocal filing steps, any fee, and processing time. Write down who answered.', 'You, Cook BED', 'cook'));
      out.push(step(s0, 1, 'Prepare', 'Pre-fill the Reciprocal Affidavit (Official forms tab). Confirm the figures: net worth under $2,955,193.19, receipts under the SBA size standard.', 'Qualifying owner', null));
      out.push(step(s0, 3, 'Prepare', 'Sign the affidavit before a notary.', 'Owner + notary', null));
      out.push(step(s0, 5, 'Submit', 'Submit the affidavit and your City certification proof through the County portal.', 'You', 'cook'));
      out.push(step(s0, 10, 'Follow up', 'Confirm receipt and ask for the decision date. The County does not publish a processing time.', 'Cook BED', 'cook', true));
      out.push(step(s0, 20, 'Follow up', 'If no decision, ask what specifically is outstanding and who is reviewing.', 'Cook BED', 'cook', true));
      return out;
    }
    out.push(step(s0, 0, 'Prepare', 'Kick-off call to Cook BED: confirm you qualify (principal office in the six counties, size standard) and how long the review takes. Order IRS transcripts for SEVEN years now.', 'You, Cook BED, IRS', 'cook'));
    out.push(step(s0, 3, 'Prepare', 'Create your account at cookcounty.diversitycompliance.com. Send your CPA and bank their request lists.', 'You, CPA, bank', 'cpa'));
    out.push(step(s0, 10, 'Prepare', 'Fill every gap in the Hub; owners review resumes and statements.', 'Every owner', null));
    out.push(step(s0, 14, 'Submit', 'SUBMIT: upload everything, notarized Schedule A affidavit, pay the $250 fee (ACH Company ID 0000408976).', 'You', 'cook'));
    out.push(step(s0, 19, 'Follow up', 'Nudge 1: confirm the file is complete and get your reviewer\'s name.', 'Cook BED', 'cook'));
    out.push(step(s0, 45, 'Follow up', 'Nudge 2: status; answer any request for information the same day.', 'Cook BED', 'cook'));
    out.push(step(s0, 75, 'Follow up', 'Nudge 3: ask for the expected decision date. The County does not publish a processing time.', 'Cook BED', 'cook'));
    return out;
  }
  function bepTimeline(P) {
    var s0 = start(P), r = bepRoute(P), out = [];
    if (r === 'be' || r === 'fast') {
      out.push(step(s0, 0, 'Prepare', (r === 'be' ? 'Confirm your ' + held(P) + ' certification is current and download the certificate.' : 'Confirm your partner certification is current and download the proof.') + ' Create or reset your SDMP account.', 'You', 'sdmp'));
      out.push(step(s0, 2, 'Submit', (r === 'be' ? 'SUBMIT in the portal: Application > New Certification/Renewal > select host agency > upload > Submit.' : 'SUBMIT: partner proof and the signed, notarized BEP affidavit.') + ' Enter the NIGP codes from your host.', 'You', 'cei'));
      out.push(step(s0, 2 + 7, 'Decision', 'CEI states about 7 business days for BE BEP and FastTrack. Count from the day the application is complete.', 'CEI', 'cei', true));
      out.push(step(s0, 2 + 9, 'Follow up', 'If no answer, email the BEP unit with your application number and ask what is outstanding.', 'CEI', 'cei', true));
      return out;
    }
    out.push(step(s0, 0, 'Prepare', 'Create your SDMP account; start the application so the notarized affidavit is generated. Gather the 19 checklist items.', 'You', 'sdmp'));
    out.push(step(s0, 10, 'Prepare', 'Fill every gap in the Hub; notarize the affidavit.', 'Owner + notary', null));
    out.push(step(s0, 14, 'Submit', 'SUBMIT the full application in the portal. Certification is free.', 'You', 'cei'));
    out.push(step(s0, 14 + 21, 'Follow up', 'Nudge 1: confirm the file is complete and ask who is reviewing.', 'CEI', 'cei'));
    out.push(step(s0, 14 + 45, 'Follow up', 'Nudge 2: status check; answer requests the same day.', 'CEI', 'cei'));
    out.push(step(s0, 14 + 60, 'Decision', 'CEI states about 60 days after a COMPLETE application.', 'CEI', 'cei'));
    return out;
  }

  /* ---------- plan: the quickest sequence given what the client already holds ---------- */
  function plan(P) {
    var h = held(P), out = [];
    if (h === 'None') {
      out.push({ n: 1, t: 'File the City of Chicago M/WBE application (Schedule A, notarized). This is the anchor certification: Cook County and the State both recognize it.', why: 'About 90 days from a complete file (unofficial estimate; ask DPS).' });
      out.push({ n: 2, t: 'When the City approves, file the Cook County reciprocal affidavit (one notarized page).', why: 'Cook accepts City certification. The County publishes no processing time.' });
      out.push({ n: 3, t: 'Also when the City approves, file State BEP "BE BEP" in the Supplier Diversity Management Portal.', why: 'CEI states about 7 business days for BE BEP. Free.' });
      out.push({ n: 0, t: 'Alternative anchor: file Cook County\'s Schedule A first (7 years of returns, $250, no published timeline) and then use it for the City and BE BEP. Choose this only if Cook BED tells you it is faster.', why: 'Ask both offices on day 1 before paying either $250.' });
    } else if (h === 'City of Chicago M/WBE') {
      out.push({ n: 1, t: 'Cook County reciprocal affidavit (notarized) with proof of City certification.', why: 'One page; good for one year.' });
      out.push({ n: 2, t: 'State BEP: BE BEP in the portal, host = City of Chicago.', why: 'About 7 business days, free.' });
    } else if (h === 'Cook County MWBE') {
      out.push({ n: 1, t: 'State BEP: BE BEP in the portal, host = Cook County.', why: 'About 7 business days, free.' });
      out.push({ n: 2, t: 'City of Chicago: ask DPS how it recognizes Cook County certification (the City and County have a reciprocal program).', why: 'The City page does not publish the filing steps; call 312-744-4900.' });
    } else {
      out.push({ n: 1, t: 'City of Chicago: use the expedited Outside Recognition application with your WBDC or CMBDC certification (Chicago MSDC is the successor name to CMBDC; confirm with DPS).', why: 'Official expedited-process PDF.' });
      out.push({ n: 2, t: 'State BEP: FastTrack with proof of your partner certification and a notarized BEP affidavit.', why: 'About 7 business days, free.' });
      out.push({ n: 3, t: 'Then Cook County reciprocal once the City recognizes you.', why: 'One notarized page.' });
    }
    return out;
  }

  /* ---------- public API ---------- */
  E.checklistFor = function (P, pkg) {
    var L0 = pkg === 'cook' ? cookChecklist(P) : pkg === 'bep' ? bepChecklist(P) : E.checklist(P);
    if (has((P.biz || {}).reinstated)) {
      L0.push({ id: 'reinst', group: 'Legal and identity', title: 'Reinstatement filing (Illinois Secretary of State) and a current certificate of good standing, plus a short written explanation of the gap', why: 'The company was administratively dissolved or revoked and reinstated on ' + P.biz.reinstated + '. Reviewers check continuity of the business, its tax filings and any contracts signed during the gap.', where: [L.ilsosLLC], ifMissing: 'Download the reinstatement record and order the certificate of good standing from the Secretary of State. List every contract, bank account and filing dated inside the gap so you can explain each one.', src: 'common' });
    }
    return L0;
  };
  E.timelineFor = function (P, pkg) { return pkg === 'cook' ? cookTimeline(P) : pkg === 'bep' ? bepTimeline(P) : E.timeline(P); };
  E.contactsFor = function (pkg) { var ids = (E.PACKAGES.filter(function (p) { return p.id === pkg; })[0] || E.PACKAGES[0]).contacts; return ids.map(function (id) { return E.CONTACTS.filter(function (c) { return c.id === id; })[0]; }).filter(Boolean); };
  E.eligibilityFor = function (P, pkg) { return pkg === 'cook' ? cookEligibility(P) : pkg === 'bep' ? bepEligibility(P) : []; };
  E.routeFor = function (P, pkg) { return pkg === 'cook' ? cookRoute(P) : pkg === 'bep' ? bepRoute(P) : (held(P) === 'Women\'s Business Development Center (WBDC)' || held(P) === 'Chicago MSDC or Mid-States MSDC' ? 'expedited' : 'schedA'); };
  E.plan = plan;
})(window);
