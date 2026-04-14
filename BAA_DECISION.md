# BAA Required? Decision Record for baa-or-not

Date: 2026-04-13
Project: `baa-or-not`
Purpose: Document BAA determination for this application's vendor relationships.
Note: Operational guide only; final determination should be made by qualified counsel.

## Fast Decision Flow

1. **Are we a HIPAA covered entity or business associate?**
   - **No.** This application is an educational tool. It does not provide
     healthcare services, process claims, or act on behalf of any covered entity.

2. **Does the app create, receive, maintain, or transmit PHI?**
   - **No.** The application is stateless. It collects no user data, stores
     nothing, and has no database. Users answer yes/no questions in a form;
     responses are evaluated server-side and discarded immediately.

3. **Do third-party vendors process, store, or transmit PHI for us?**
   - **No.** No PHI exists in the system for vendors to handle.

**Outcome: BAA not required.**

---

## Vendor Stack

| Vendor | Role | Handles PHI? | BAA needed? |
|---|---|---|---|
| AWS Lambda | Compute | No | No |
| AWS CloudFront | CDN | No | No |
| AWS S3 | Deployment artifacts | No | No |
| GitHub Actions | CI/CD | No | No |

None of these vendors receive, process, or store health information
through this application.

---

## Non-BAA Rationale Checklist

- [x] We are **not** a covered entity.
- [x] We are **not** acting as a business associate for covered entities.
- [x] No user submits PHI to this application.
- [x] The application is stateless: no database, no logging of user inputs, no storage.
- [x] The site disclaimer states the tool is for educational/entertainment purposes only.
- [x] Marketing and documentation do not imply HIPAA-regulated use.

---

## Re-evaluation Triggers

Re-run this checklist if any of the following changes:

- The application begins collecting or storing user input.
- A database or persistent storage layer is added.
- The application is offered as a service to covered entities or business associates.
- User analytics or logging that could capture form responses is introduced.
- The project's purpose shifts from educational to operational/clinical use.
