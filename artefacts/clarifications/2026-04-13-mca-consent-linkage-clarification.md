**Subject: Mental Capacity Act Linkage — Clarification Required Before We Proceed**

Thank you for the request to introduce mandatory linkage between Consent Forms and Mental Capacity Assessments. We have reviewed the requirement and conducted a full review of the current ECR system before progressing. We need to raise two significant points before we can scope and build this correctly.

---

**1. The trigger point is clinically inconsistent**

The Consent Form in the ECR is completed by the service user themselves via the patient-facing portal. The three options currently available are: "Yes", "No", and "I feel unable to provide consent."

A Mental Capacity Assessment under the Mental Capacity Act 2005 is a clinician-led formal process — it is not something a service user initiates or triggers themselves. In practice, if a service user genuinely lacked capacity, they would not be completing a self-service consent form in the first place.

The request as written would present MCA prompts to the service user within their portal, which is clinically incorrect and potentially harmful.

Before we can design the right flow, we need to understand: who is intended to trigger the MCA requirement, and at what point? The most likely correct model is a staff member recording, on the clinical side of the system, that consent could not be obtained — at which point the system prompts them to complete or attach an MCA. We need the client to confirm or correct this.

---

**2. No Mental Capacity Assessment or Best Interest Decision form currently exists in the ECR**

We have reviewed the entire ECR codebase. There is no Mental Capacity Assessment form, no Best Interest Decision record, and no mechanism to link forms of different types anywhere in the system.

What does exist — and what should not be confused with a formal MCA — is the following:

"Known issues with my capacity" appears in the Initial Assessment and Care Passport as a free-text note field only, with no structure and no outcome recorded.

The Advance Decision field in the Initial Assessment captures whether an advance decision exists, with an optional evidence upload. This is not a capacity assessment.

The DoLS/CTO field in Admission under Legal Information is a free-text note recording deprivation of liberty status. It assumes an MCA was completed externally and records nothing structured.

None of these constitute a structured MCA or Best Interest Decision record.

This means the work required is significantly larger than the request implies. The team cannot link something that does not yet exist. An MCA form and a Best Interest Decision form would need to be designed and built as new features first, before any linkage to the Consent Form can be implemented.

---

**Questions for the client**

Please confirm the following before we proceed:

1. Who triggers the MCA? Is this a staff member (clinician, care worker, manager) acting within the staff-facing system — or is there a different intended user and entry point?

2. At what stage is the MCA triggered? Is it when a staff member records that a service user declined or was unable to give consent? Is it at referral, admission, or during an active episode of care?

3. Does the organisation use a standard MCA tool? For example, a paper-based form that should be replicated digitally, or an existing template that should be uploaded. If so, please share it.

4. Does the organisation have an existing Best Interest Decision process or template? If so, please share it so we can design the digital record accurately.

5. Is the Consent Form (completed by the service user via the portal) still relevant to this flow? Or is the requirement primarily about staff-recorded consent and capacity on the clinical side?

We are ready to move quickly once these points are confirmed. The answers will determine whether this is a single Change Request or a phased set of features.
