# BAA Required? Repo-Specific Decision Checklist

Date: 2026-04-04  
Project: `carekeeper-main`  
Purpose: Rapidly determine whether BAAs are legally required for this product's vendor relationships.  
Note: Operational guide only; final determination should be made by qualified counsel.

## 1) Fast Decision Flow (Yes/No)

Use this sequence in order:

1. **Are we a HIPAA covered entity or business associate?**
   - If **No** -> BAA generally **not required** (document rationale).
   - If **Yes** -> continue.
2. **Does the app create, receive, maintain, or transmit PHI?**
   - If **No** -> BAA generally **not required** (document rationale).
   - If **Yes** -> continue.
3. **Do third-party vendors process/store/transmit that PHI for us?**
   - If **No** -> BAA may not be required with those vendors.
   - If **Yes** -> BAA is typically **required** with those vendors.

If steps 1-3 are all **Yes**, the default answer is: **BAA needed**.

---

## 2) Signals in This Repo That Can Trigger HIPAA/PHI Analysis

These are not legal conclusions by themselves, but they are strong indicators that PHI may be present depending on business role and customer type:

- Medical records/documents workflow:
  - `src/app/actions/documents.ts`
  - `src/app/api/documents/download/route.ts`
  - `supabase/migrations/*documents*`
- Medication management:
  - `src/app/actions/medications.ts`
  - `supabase/migrations/20241215000000_create_medications.sql`
- Clinical contact/provider details:
  - `src/app/actions/contacts.ts`
- Appointment/calendar with care context:
  - `src/app/actions/calendar.ts`
  - `supabase/migrations/20260114000000_create_calendar_events.sql`
- Care recipient identity + relationship data:
  - `src/app/actions/recipients.ts`
  - `supabase/migrations/20241209000000_initial_schema.sql`
- Security/compliance narrative explicitly references HIPAA posture:
  - `SECURITY.md`

---

## 3) Vendor PHI Touchpoint Matrix (Fill In)

Mark each row with **Yes/No/Unknown** and retain evidence.

| Vendor | In this stack | Handles app data in PHI-capable flows? | BAA available/needed? | Evidence |
|---|---|---|---|---|
| Vercel | Hosting/runtime | Yes/No/Unknown | Yes/No/Unknown | Plan, BAA status, architecture notes |
| Supabase | DB/Auth/Storage | Yes/No/Unknown | Yes/No/Unknown | Contract terms, data flow map |
| Resend | Email delivery | Yes/No/Unknown | Yes/No/Unknown | Email content policy, routing docs |
| Upstash | Rate limiting/lockout metadata | Yes/No/Unknown | Yes/No/Unknown | Stored fields, keys, payload review |
| Sentry/PostHog (if enabled) | Observability/analytics | Yes/No/Unknown | Yes/No/Unknown | Event payload policy, PII scrubbing |
| Any additional processor | TBD | Yes/No/Unknown | Yes/No/Unknown | Contract + technical review |

Rule of thumb: if a vendor can access PHI in normal operations, evaluate BAA necessity immediately.

---

## 4) PHI Exposure Inventory (Repo-Mapped)

Complete this for legal/compliance review:

| Data Class | Likely Tables/Flows | Contains identifiers? | Contains health info? | PHI candidate? |
|---|---|---|---|---|
| Care recipient demographics | `care_recipients` | Yes | Possibly | Yes/No |
| Medication details | `medications` | Yes | Yes | Yes/No |
| Medical documents | `documents` + storage | Yes | Yes | Yes/No |
| Provider contacts | `contacts` | Yes | Contextual | Yes/No |
| Calendar/task medical context | `calendar_events`, `tasks` | Yes | Contextual | Yes/No |
| Financial data only | `accounts`, `transactions`, `cashflow_items` | Yes | Usually no | Yes/No |

If any row is "PHI candidate = Yes" and you are CE/BA, BAA analysis is mandatory.

---

## 5) Common Non-BAA Argument Checks

If business owner says "BAA not needed," validate these assumptions explicitly:

- [ ] We are **not** a covered entity.
- [ ] We are **not** acting as a business associate for covered entities.
- [ ] No customer is sending us PHI under HIPAA-governed workflows.
- [ ] Product terms prohibit HIPAA/PHI use cases (and this is enforced operationally).
- [ ] Logging, support, exports, and emails do not include PHI.
- [ ] Marketing and sales statements do not imply HIPAA-regulated use.

If any of the above is false or uncertain, escalate to counsel and re-open BAA determination.

---

## 6) Decision Record Template (Complete and Archive)

**Decision Date:**  
**Decision Owner:**  
**Counsel Reviewer:**  

### A) Entity Role
- Covered Entity: Yes/No
- Business Associate: Yes/No
- Neither: Yes/No

### B) PHI Presence
- App processes PHI: Yes/No
- Evidence references:

### C) Vendor Processing
- Vendors processing PHI:
- Vendors not processing PHI:

### D) Outcome
- BAA required: Yes/No
- If "No", legal rationale:
- Re-evaluation trigger (date/event):

### E) Approvals
- Business owner sign-off:
- Legal sign-off:
- Security sign-off:

---

## 7) Re-Evaluation Triggers (Mandatory)

Re-run this checklist when any of the following happens:

- New feature touching medical records, medication, provider data, or care coordination.
- New vendor added to runtime, storage, messaging, or observability.
- Sales motion changes (serving providers/health plans/employers).
- Terms/privacy policy changes about health data use.
- Any incident involving possible sensitive health information.

---

## 8) Practical Recommendation for This Repo

Given current schema and workflows, this product is **PHI-capable by design**.  
If your customers or business model place you in CE/BA scope, assume **BAA needed** until counsel says otherwise.

If leadership chooses "no BAA," require:

- a documented legal memo,
- explicit product policy prohibiting HIPAA-regulated usage,
- technical controls to prevent PHI ingestion/use where feasible,
- periodic re-certification of that position.

