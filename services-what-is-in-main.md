# Services Feature - What Is in Main (Testing Reference)

This document describes what has been implemented and merged to `main`. Use this as the source of truth for testing. The original PRD and TRD do not reflect the final shape of the feature.

---

## Overview

The feature delivers three interconnected things:

1. **Facility-level services** - services are now scoped to specific facilities (replacing org-level services)
2. **Service enrolment** - patients are enrolled in services at specific facilities; appointment booking is gated on enrolment
3. **Cross-facility appointments** - Home Facility providers can book appointments at Service Facilities; approval flows to the Service Facility manager

---

## Key Terms

| Term | Meaning |
|---|---|
| **Home Facility** | The facility the patient belongs to (their active encounter facility) |
| **Service Facility** | The facility delivering the service appointment |
| **Outgoing appointment** | Booked by Home Facility for a service at another facility |
| **Incoming appointment** | Another facility's patient requesting a service here |
| **Same-facility appointment** | Patient and service both at current facility |
| **Internal mode** | Appointment booking using enrolled services |
| **External mode** | Appointment booking using "External Consultations" service (no enrolment needed) |

---

## Area 1: Organisation Settings - Services

### What was built

Services are now facility-scoped entities (`FacilityService`). When creating or editing a service, admins configure which facilities it is available at, and which staff are authorised at each facility. The org-level `OrganizationService` and `UserService` tables no longer exist.

**Services table** now shows a "Facilities" column instead of "Authorised Staff". Values: `"All facilities"` or `"3 facilities"`.

### Deviations from original spec

- All existing org-level services were seeded as `FacilityService` rows at every facility in the org on migration (default "All Facilities" - no disruption to existing config)
- `FacilityService.CreatedBy` is nullable (original TRD said NOT NULL; existing data had nulls)

### Test scenarios

1. **Create service - All Facilities**
   - Org Admin opens Services, clicks Add Service
   - Sets name, leaves "All Facilities" toggle on
   - Assigns staff: All Staff or Custom Staff per facility
   - Saves - service appears in table with "All facilities" in the Facilities column
   - Booking dropdown at any facility shows this service

2. **Create service - Specific Facilities**
   - Same as above but selects "Specific Facilities" and picks 2 of 3 facilities
   - Saves - table shows "2 facilities"
   - Booking dropdown at the 2 selected facilities shows the service; third facility does not

3. **Edit service - change facility list**
   - Remove one facility from an existing service
   - The service no longer appears in booking at the removed facility

4. **Edit service - change staff**
   - Remove a staff member from a facility's service team
   - That staff member no longer appears in the provider dropdown when booking that service

5. **Services table**
   - Facilities column shows correct count
   - Existing services (pre-migration) appear with "All facilities"

---

## Area 2: Service Enrolments (Patient Profile)

### What was built

The Services section lives in the **dashboard tab** (`UserProfileTabs`, inside the patient dashboard sidebar). This is different from the original TRD which specified the `/profile` page.

The section shows all enrolments (active and ended) for the patient. Active enrolments have an End button. The Enrol button opens a modal that lets staff select a service and start date.

**Key deviation - enrolment modal uses all org services, not just current facility services.** This was an intentional change to support cross-facility enrolment (enrolling a patient in a service at another facility within the same org). The service dropdown labels show `"ServiceName - FacilityName"` when the service is from a different facility.

**Key deviation - future-dated enrolments allow appointment booking immediately.** The original TRD gated booking on `StartDate <= today`. This filter was removed; an enrolment is valid for booking from the moment it is created, regardless of `StartDate`.

### Test scenarios

1. **View enrolments**
   - Open patient dashboard, scroll to Services section
   - Active enrolments shown with green "Active" badge, start date, end date (if set)
   - Ended enrolments shown with grey "Ended" badge

2. **Enrol patient - same facility service**
   - Click Enrol
   - Select a service at the current facility from the dropdown
   - Set start date (today or up to 60 days in future)
   - Save - new Active enrolment appears

3. **Enrol patient - different facility service**
   - Click Enrol
   - Select a service labelled "ServiceName - OtherFacilityName"
   - Set start date
   - Save - enrolment appears with the other facility's service

4. **Start date validation**
   - Past date: rejected
   - More than 60 days in future: rejected
   - Today or up to 60 days: accepted

5. **End enrolment**
   - Click End on an active enrolment
   - Enrolment moves to Ended status with today's date as EndDate
   - No date picker; end date is always today

6. **Enrolment history**
   - Ended enrolments remain visible in the list (not removed)

---

## Area 3: Appointment Booking - Internal Mode

### What was built

Appointment booking (new popup and add drawer) now has two modes: **Internal** (enrolled services) and **External** (custom/external consultations). Internal is the default.

In Internal mode: service user must be selected first; service dropdown then shows only services the patient is actively enrolled in at the current facility. If no active enrolments exist, the service dropdown is disabled with the message "No enrolled services - enrol the patient in a service first."

**Same-facility patient filter:** the patient dropdown in the booking form shows only same-facility patients (Home Facility = current facility). Cross-facility bookings are initiated by the patient's own facility, not by the service facility.

### Test scenarios

1. **Patient with no active enrolments at current facility**
   - Open new appointment, Internal mode
   - Select that patient
   - Service dropdown is disabled with the empty-state message

2. **Patient with active enrolments**
   - Select patient
   - Service dropdown shows only their enrolled services at this facility
   - Services from other facilities do not appear

3. **Patient dropdown shows same-facility patients only**
   - Patients from other facilities do not appear in the patient dropdown in Internal mode

4. **Provider dropdown**
   - After selecting service, provider dropdown shows staff from `FacilityServiceStaff` for that service
   - Staff not on the service team do not appear

5. **Future-dated enrolment**
   - Patient enrolled with a future start date
   - Service is visible in booking dropdown immediately (not blocked by start date)

---

## Area 4: Appointment Booking - External Mode

### What was built

A toggle switches between "Internal" and "External" modes. External mode auto-selects the "External Consultations" facility service (`IsCustom = true`). No enrolment or provider picker is shown. Instead, three custom fields appear: consultant name, consultant type, and email.

The `IsCustom` boolean flag on `FacilityService` replaced the previous magic string check (`FacilityService.Name === "External Consultations"`).

### Test scenarios

1. **Switch to External mode**
   - Toggle shows External selected
   - Service dropdown hidden; "External Consultations" is auto-selected
   - Consultant name, type, and email fields shown

2. **Book external appointment**
   - Fill consultant name, type, email
   - Submit - appointment created with External Consultations service
   - Appointment shows in table normally

3. **Switch back to Internal mode**
   - Form resets to Internal state; enrolled services shown again

---

## Area 5: Cross-Facility Appointments

### What was built

Cross-facility appointments follow a distinct approval flow. The Home Facility provider initiates; the Service Facility manager approves.

**Appointment table visual distinctions:**
- Same-facility rows: neutral (no colour)
- Incoming rows (another facility's patient, service here): blue tint
- Outgoing rows (our patient, service at another facility): amber tint
- Facility column: blank for same-facility; `"External Facility {Name}"` for cross-facility (names the other facility)

**Appointment popup behaviour by row type:**

| Row | Status | What popup shows |
|---|---|---|
| Same-facility | Pending | Standard approve/decline |
| Incoming cross-facility | Pending | Provider picker + approve/decline |
| Incoming cross-facility | Confirmed + HasPendingModification | Approve/decline modification |
| Outgoing cross-facility | Pending | Withdraw/cancel option (Manager only) |
| Outgoing cross-facility | Confirmed | View only |

**Pending date change flow:** When Home Facility modifies date/time on a confirmed cross-facility appointment, the appointment stays in Confirmed tab but gets a `HasPendingModification` flag and an amber "Pending date change" badge in the popup header. Service Facility manager approves (new date stands) or declines (original date restored from history). Appointment never moves back to Pending tab.

### Deviations from original spec

Phase 3.5-B originally routed approval to the patient's Home Facility. Phase 3.5-C corrected this: approval goes to the **Service Facility** manager (the facility delivering the service). This was a significant model inversion.

### Test scenarios

1. **Home Facility books cross-facility appointment**
   - Open booking at Home Facility (patient's facility)
   - Select patient (same-facility patient only)
   - Select enrolled service from Service Facility
   - No provider shown, no provider picker
   - Submit - appointment created with status PENDING, facility = Service Facility

2. **Home Facility sees outgoing row**
   - In Home Facility appointments table, amber row appears
   - Facility column shows "External Facility {ServiceFacilityName}"
   - Opening popup shows view-only content (no approve/decline)

3. **Service Facility sees incoming row**
   - In Service Facility appointments table, blue row appears
   - Facility column shows "External Facility {HomeFacilityName}"
   - Opening popup shows provider picker + approve/decline buttons

4. **Service Facility manager approves**
   - Assign a provider, click Approve
   - Appointment becomes CONFIRMED
   - Provider receives notification
   - Row moves to Confirmed tab for both facilities

5. **Service Facility manager declines**
   - Click Decline
   - Appointment is declined

6. **Home Facility withdraws PENDING**
   - Manager opens the outgoing PENDING popup
   - Cancel/Withdraw option is available
   - After withdrawal, appointment removed from both views

7. **Home Facility modifies date/time on CONFIRMED**
   - Open outgoing CONFIRMED row
   - Modify date or time, save
   - Row stays in Confirmed tab
   - Amber "Pending date change" badge shown in popup header

8. **Service Facility approves modification**
   - Open incoming CONFIRMED row with HasPendingModification
   - Approve button shown; click Approve
   - Badge cleared, new date/time stands, provider retained

9. **Service Facility declines modification**
   - Click Decline on modification
   - Original date/time restored, badge cleared

10. **Service Facility modifies provider only**
    - Service Facility can reassign provider on a confirmed cross-facility appointment
    - Service Facility cannot change date/time (no date/time fields in their popup)

11. **Same-facility booking unchanged**
    - Same-facility appointment: CONFIRMED immediately
    - No colour tint on row
    - Facility column blank
    - Provider picker shown in popup

---

## Area 6: Enrolled Patients Page (/enrolled-patients)

### What was built

New page under "Appointments and Services" sidebar accordion. Shows all patients enrolled in services at the current facility where the current staff member is on the service team. Deduplicates patients enrolled in multiple services (one row per patient).

External (cross-facility) patients show an amber "External" badge in the Home Facility column.

### Test scenarios

1. **Page displays enrolled patients**
   - Navigate to Appointments and Services > Enrolled Patients
   - See list of patients enrolled at current facility

2. **External badge**
   - Patient from another facility enrolled in a service here
   - Row shows their home facility name with amber "External" badge

3. **Same-facility patient**
   - Home Facility column shows facility name, no badge

4. **Patient enrolled in multiple services**
   - Single row for patient; Services column shows comma-separated list

5. **Search**
   - Search by patient name narrows list
   - Search by facility name narrows list

6. **Row click navigates to patient profile**
   - Clicking a row opens that patient's profile

---

## Area 7: Service Enrolments Page (/service-enrolments)

### What was built

New page under "Appointments and Services" accordion. Shows all service enrolments for services at the current facility where the current staff member is on the service team. One row per enrolment (a patient enrolled in two services appears twice).

### Test scenarios

1. **Page displays enrolments**
   - Navigate to Appointments and Services > Service Enrolments
   - All active enrolments for current staff's services shown

2. **Columns: patient name, home facility, service name, start date, end date, status**

3. **Active vs Ended enrolments both shown**

4. **Staff not on any service team sees empty state**

---

## Area 8: Sidebar Navigation

### What was built

"Appointments and Services" accordion replaces the old "Appointments" sub-link under Care Records. Sub-links:
- Appointments
- Service Enrolments
- Enrolled Patients

### Test scenarios

1. Appointments sub-link navigates to appointments page
2. Service Enrolments sub-link navigates to service-enrolments page
3. Enrolled Patients sub-link navigates to enrolled-patients page
4. Old "Appointments" sub-link under Care Records no longer present
