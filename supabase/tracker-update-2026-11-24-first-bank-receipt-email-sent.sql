-- First Bank Chicago: Stephen sent the receipt-confirmation email from stephen@selassiefest.com to dbryant@firstbankchicago.com (cc stephen@), Tue Nov 24 2026 07:28:52 +0000 (1:28 am CT). Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2026-12-08',
  next_step='Receipt-confirmation email SENT Nov 24, 2026 (1:28 am CT) to dbryant@firstbankchicago.com asking her to confirm the Nov 24 request ($3,750) reached the committee. Awaiting her one-line reply. If silent by Dec 8, one email nudge; decision expected in 4-6 weeks (about Jan 5, 2027). Do NOT start a new form entry.',
  notes=case when coalesce(notes,'') like '%CO6P220MB0338EEF6E342FD0C63CE9CFED7442%' then notes else coalesce(notes,'')||E'\n2026-11-24: Stephen emailed dbryant@firstbankchicago.com (cc stephen@) at 1:28 am CT asking her to confirm receipt of the request. Message-ID <CO6P220MB0338EEF6E342FD0C63CE9CFED7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.' end
where id='1e5002c8-5b07-4685-b001-766672f3f25c';
select funder,status,next_step_due from fs_grant_deadlines where id='1e5002c8-5b07-4685-b001-766672f3f25c';
commit;
