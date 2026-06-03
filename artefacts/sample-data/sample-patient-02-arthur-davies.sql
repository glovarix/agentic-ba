-- =============================================================
-- SAMPLE PATIENT DATA — Patient 02: Arthur William Davies
-- Conditions: Chronic Heart Failure (I50.9) + Generalised Anxiety Disorder (F41.1)
-- Admission: 2026-04-24 | Current | Care home setting
-- Generated: 2026-05-21
-- =============================================================
--
-- PURPOSE: AI feature testing — covers all major ECR modules:
--   Patient profile, Contacts/NoK, Referral, Encounter, Diagnoses,
--   Legal Status, Initial Assessment, Medications (6), MAR,
--   Daily Notes (14), Care Plans (2) + Reviews, Risk Assessments (3),
--   Incidents (2), Vitals (8)
--
-- BEFORE RUNNING:
--   1. Replace the 5 ENVIRONMENT PLACEHOLDERS in the DECLARE block below.
--   2. Run as: psql -d <your_db> -f this_file.sql
--   3. Script is idempotent (ON CONFLICT DO NOTHING throughout).
--
-- LOOKUP IDs USED (verified against my-app-main migrations):
--   SubmissionStatus:           2 = Submitted
--   LegalStatus:                1 = Informal
--   MedicationFrequency:        1=OD
--   MedicationAdministrationStatus: 1=Administered  4=Refused
--   RiskAssessmentType:         10=Social  12=Mental Health  14=Eating
--   RiskAssessmentReviewStatus: 1 = Pending review
--   CarePlanType:               1328=Managing mental health  1329=Physical health
--   GeneralNoteType:            35=managing_mental_health  37=living_skills
--                               47=support_worker  48=session_entry  54=Phone_call
--   IncidentType:               55=Slips, Trips and Falls (Cat 9 Accidents)
--                               60=Other (Cat 11 All Other Incidents)
-- =============================================================

BEGIN;

DO $$
DECLARE

  -- ============================================================
  -- ENVIRONMENT PLACEHOLDERS — Replace before running
  -- ============================================================
  v_facility_id   UUID := 'REPLACE_WITH_FACILITY_UUID'::UUID;
  v_ward_id       UUID := 'REPLACE_WITH_WARD_UUID'::UUID;
  v_staff_1       UUID := 'REPLACE_WITH_CARE_WORKER_UUID'::UUID;
  v_staff_2       UUID := 'REPLACE_WITH_NURSE_UUID'::UUID;
  v_staff_3       UUID := 'REPLACE_WITH_MANAGER_UUID'::UUID;

  -- ============================================================
  -- Auto-resolved at runtime — do not change
  -- ============================================================
  v_careplan_schema_version INTEGER;
  v_incident_schema_id      INTEGER;

  -- ============================================================
  -- Patient 2 — Arthur Davies — fixed UUIDs
  -- All use "2a" prefix to distinguish from Patient 01 UUIDs
  -- ============================================================
  v_patient_id              UUID := '2a000001-0000-4000-8000-000000000001';
  v_patient_address_id      UUID := '2a000002-0000-4000-8000-000000000001';
  v_nok_contact_id          UUID := '2a000003-0000-4000-8000-000000000001';
  v_nok_address_id          UUID := '2a000004-0000-4000-8000-000000000001';
  v_gp_contact_id           UUID := '2a000005-0000-4000-8000-000000000001';
  v_pc_nok_id               UUID := '2a000006-0000-4000-8000-000000000001';
  v_pc_gp_id                UUID := '2a000007-0000-4000-8000-000000000001';
  v_referral_id             UUID := '2a000008-0000-4000-8000-000000000001';
  v_encounter_id            UUID := '2a000009-0000-4000-8000-000000000001';
  v_diag_hf_id              UUID := '2a000010-0000-4000-8000-000000000001';
  v_diag_gad_id             UUID := '2a000011-0000-4000-8000-000000000001';
  v_legal_status_id         UUID := '2a000012-0000-4000-8000-000000000001';
  v_init_assess_id          UUID := '2a000013-0000-4000-8000-000000000001';
  v_med_furosemide_id       UUID := '2a000014-0000-4000-8000-000000000001';
  v_med_ramipril_id         UUID := '2a000015-0000-4000-8000-000000000001';
  v_med_bisoprolol_id       UUID := '2a000016-0000-4000-8000-000000000001';
  v_med_spironolactone_id   UUID := '2a000017-0000-4000-8000-000000000001';
  v_med_sertraline_id       UUID := '2a000018-0000-4000-8000-000000000001';
  v_med_lorazepam_id        UUID := '2a000019-0000-4000-8000-000000000001';
  v_note_01_id              UUID := '2a000020-0000-4000-8000-000000000001';
  v_note_02_id              UUID := '2a000021-0000-4000-8000-000000000001';
  v_note_03_id              UUID := '2a000022-0000-4000-8000-000000000001';
  v_note_04_id              UUID := '2a000023-0000-4000-8000-000000000001';
  v_note_05_id              UUID := '2a000024-0000-4000-8000-000000000001';
  v_note_06_id              UUID := '2a000025-0000-4000-8000-000000000001';
  v_note_07_id              UUID := '2a000026-0000-4000-8000-000000000001';
  v_note_08_id              UUID := '2a000027-0000-4000-8000-000000000001';
  v_note_09_id              UUID := '2a000028-0000-4000-8000-000000000001';
  v_note_10_id              UUID := '2a000029-0000-4000-8000-000000000001';
  v_note_11_id              UUID := '2a000030-0000-4000-8000-000000000001';
  v_note_12_id              UUID := '2a000031-0000-4000-8000-000000000001';
  v_note_13_id              UUID := '2a000032-0000-4000-8000-000000000001';
  v_note_14_id              UUID := '2a000033-0000-4000-8000-000000000001';
  v_cp_physical_id          UUID := '2a000034-0000-4000-8000-000000000001';
  v_cp_mental_id            UUID := '2a000035-0000-4000-8000-000000000001';
  v_cpr_physical_id         UUID := '2a000036-0000-4000-8000-000000000001';
  v_cpr_mental_id           UUID := '2a000037-0000-4000-8000-000000000001';
  v_ra_mental_id            UUID := '2a000038-0000-4000-8000-000000000001';
  v_ra_eating_id            UUID := '2a000039-0000-4000-8000-000000000001';
  v_ra_falls_id             UUID := '2a000040-0000-4000-8000-000000000001';
  v_incident_breathless_id  UUID := '2a000041-0000-4000-8000-000000000001';
  v_incident_fall_id        UUID := '2a000042-0000-4000-8000-000000000001';
  v_vital_01_id             UUID := '2a000043-0000-4000-8000-000000000001';
  v_vital_02_id             UUID := '2a000044-0000-4000-8000-000000000001';
  v_vital_03_id             UUID := '2a000045-0000-4000-8000-000000000001';
  v_vital_04_id             UUID := '2a000046-0000-4000-8000-000000000001';
  v_vital_05_id             UUID := '2a000047-0000-4000-8000-000000000001';
  v_vital_06_id             UUID := '2a000048-0000-4000-8000-000000000001';
  v_vital_07_id             UUID := '2a000049-0000-4000-8000-000000000001';
  v_vital_08_id             UUID := '2a000050-0000-4000-8000-000000000001';
  v_mar_01_id               UUID := '2a000051-0000-4000-8000-000000000001';
  v_mar_02_id               UUID := '2a000052-0000-4000-8000-000000000001';
  v_mar_03_id               UUID := '2a000053-0000-4000-8000-000000000001';
  v_mar_04_id               UUID := '2a000054-0000-4000-8000-000000000001';
  v_mar_05_id               UUID := '2a000055-0000-4000-8000-000000000001';
  v_mar_06_id               UUID := '2a000056-0000-4000-8000-000000000001';
  v_mar_07_id               UUID := '2a000057-0000-4000-8000-000000000001';
  v_mar_08_id               UUID := '2a000058-0000-4000-8000-000000000001';
  v_mar_09_id               UUID := '2a000059-0000-4000-8000-000000000001';

BEGIN

  -- ============================================================
  -- Auto-resolve CarePlanSchema and IncidentSchema
  -- ============================================================
  SELECT "Version" INTO v_careplan_schema_version
    FROM "CarePlanSchema" WHERE "IsActive" = true ORDER BY "Version" DESC LIMIT 1;
  IF v_careplan_schema_version IS NULL THEN
    SELECT "Version" INTO v_careplan_schema_version
      FROM "CarePlanSchema" ORDER BY "Version" DESC LIMIT 1;
  END IF;
  IF v_careplan_schema_version IS NULL THEN
    RAISE EXCEPTION 'No CarePlanSchema records found. Cannot proceed.';
  END IF;

  SELECT "Id" INTO v_incident_schema_id
    FROM "IncidentSchema" WHERE "IsCurrentVersion" = true LIMIT 1;
  IF v_incident_schema_id IS NULL THEN
    SELECT "Id" INTO v_incident_schema_id
      FROM "IncidentSchema" ORDER BY "Id" DESC LIMIT 1;
  END IF;
  IF v_incident_schema_id IS NULL THEN
    RAISE EXCEPTION 'No IncidentSchema records found. Cannot proceed.';
  END IF;

  -- ============================================================
  -- 1. ADDRESS — Patient home address
  -- ============================================================
  INSERT INTO "Address" (
    "Id", "Address", "City", "Pincode", "Country", "IsActive",
    "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_patient_address_id,
    '22 Riverton Close', 'Exeter', 'EX4 3PT', 'United Kingdom', true,
    '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 2. PATIENT
  -- ============================================================
  INSERT INTO "Patient" (
    "Id", "FacilityId", "FirstName", "MiddleName", "LastName",
    "Gender", "DateOfBirth", "PreferredName", "Ethnicity",
    "Height", "Weight", "Allergies", "BloodGroup",
    "NHSNumber", "InterpreterNeeded", "PreferredLanguage",
    "HasNextOfKin", "MaritalStatus", "Religion", "Title", "Pronouns",
    "DNR", "IsActive", "AddressId",
    "Phone", "Email", "MyStory",
    "CreatedOn", "UpdatedOn", "CreatedBy", "UpdatedBy"
  )
  VALUES (
    v_patient_id,
    v_facility_id,
    'Arthur', 'William', 'Davies',
    'Male',
    '1952-08-14',
    'Arthur',
    'White British',
    '174', '89',
    'Aspirin (bronchospasm); Ibuprofen (contraindicated — heart failure)',
    'O+',
    '512 384 6207',
    false,
    'English',
    true,
    'Married',
    'No religion',
    'Mr',
    'He/Him',
    false,
    true,
    v_patient_address_id,
    '[{"Type":"mobile","PhoneNumber":"+447700900774","IsPreferred":true}]'::jsonb,
    '[{"Type":"home","EmailAddress":"arthur.davies@example.co.uk","IsPreferred":true}]'::jsonb,
    '{
      "MostImportantToMe": "My wife Patricia and our two children. Keeping my mind active — I have always been a problem-solver and I want to understand what is happening with my heart and my treatment.",
      "PeopleImportantToMe": "Wife: Patricia Davies (main contact, visits three to four times a week). Son: James Davies (Bristol). Daughter: Karen Hughes (Exeter — visits most Sundays).",
      "WorthKnowing": "I was a civil engineer for 35 years and I am proud of that career. I retired in 2014. I enjoy watching cricket, listening to classical music, and doing crosswords. I am used to being in control and find it hard when I cannot manage things independently.",
      "CommunicationPreferences": "Please explain things clearly and do not rush. I prefer to know the facts, even if they are difficult. Write things down where possible as I can forget details when I am anxious.",
      "WellnessInfo": "I worry about my heart and what the future holds. I have good days and bad days. On bad days I may be quieter and want to be left alone — but please still check on me.",
      "DoAndDont": "Do: Tell me if my weight has gone up so I understand why. Involve me in decisions. Do not: Be vague about my condition or assume I am too old to understand my treatment.",
      "SupportDetails": "I weigh myself every morning. I take all my medications at breakfast. If I gain more than 2 kg in a day I become very anxious — please explain this to me calmly.",
      "SupportedBy": "My wife Patricia is my main support. She is to be contacted for significant decisions. She also has the contact details for our GP Dr Whitfield.",
      "CreatedBy": {"userId": "staff-placeholder", "firstName": "Sarah", "lastName": "Chen", "date": "2026-04-24"},
      "UpdatedBy": {"userId": "staff-placeholder", "firstName": "Sarah", "lastName": "Chen"},
      "UpdatedOn": "2026-04-26T14:00:00Z"
    }'::jsonb,
    '2026-04-24 09:00:00+00',
    '2026-04-26 14:00:00+00',
    v_staff_2,
    v_staff_2
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 3. FACILITY PATIENT LINK
  -- ============================================================
  INSERT INTO "FacilityPatient" (
    "Id", "FacilityId", "PatientId", "IsCurrentFacility",
    "TransferCommentHistory", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    '2b000001-0000-4000-8000-000000000001', v_facility_id, v_patient_id, true,
    '[]'::jsonb,
    '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'
  )
  ON CONFLICT ("FacilityId", "PatientId") DO NOTHING;

  -- ============================================================
  -- 4. CONTACTS — Wife/NoK and GP
  -- ============================================================
  INSERT INTO "Address" (
    "Id", "Address", "City", "Pincode", "Country",
    "Phone", "Email", "IsActive", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_nok_address_id,
    '22 Riverton Close', 'Exeter', 'EX4 3PT', 'United Kingdom',
    '07700 900881', 'patricia.davies@example.co.uk',
    true,
    '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "Contact" (
    "Id", "FirstName", "LastName", "Gender", "DateOfBirth",
    "AddressId", "IsActive", "isNextOfKin", "ContactType",
    "Relationship", "CreatedBy", "UpdatedBy", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_nok_contact_id,
    'Patricia', 'Davies', 'Female', '1954-03-27',
    v_nok_address_id, true, true, 'family',
    'Wife',
    v_staff_2, v_staff_2,
    '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'
  ),
  (
    v_gp_contact_id,
    'Dr James', 'Whitfield', NULL, NULL,
    NULL, true, false, 'gp',
    'General Practitioner — Exeter Central Surgery, Exeter EX1 2NG. Tel: 01392 555 200',
    v_staff_2, v_staff_2,
    '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "PatientContact" ("Id", "PatientId", "ContactId", "CreatedOn", "UpdatedOn")
  VALUES
  (v_pc_nok_id, v_patient_id, v_nok_contact_id, '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00'),
  (v_pc_gp_id,  v_patient_id, v_gp_contact_id,  '2026-04-24 09:00:00+00', '2026-04-24 09:00:00+00')
  ON CONFLICT ("PatientId", "ContactId") DO NOTHING;

  -- ============================================================
  -- 5. REFERRAL
  --    Referred by cardiology outpatient team at secondary care
  --    ReferralStatus 3 = Accepted | SubmissionStatus 2 = Submitted
  -- ============================================================
  INSERT INTO "Referral" (
    "Id", "FacilityId", "PatientId", "CreatedBy", "UpdatedBy",
    "FormSchema", "FormValue",
    "CurrentStep", "ReferralStatus", "SubmissionStatus",
    "CompletedOn", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_referral_id,
    v_facility_id, v_patient_id,
    v_staff_3, v_staff_3,
    '{"version":1,"title":"Referral Form"}'::jsonb,
    '{
      "personalDetails": {
        "firstName": "Arthur", "middleName": "William", "lastName": "Davies",
        "dateOfBirth": "1952-08-14", "gender": "Male",
        "nhsNumber": "512 384 6207", "ethnicity": "White British",
        "preferredName": "Arthur"
      },
      "address": {
        "line1": "22 Riverton Close", "city": "Exeter", "postcode": "EX4 3PT"
      },
      "referralReason": "Mr Davies is a 73-year-old retired civil engineer with known congestive heart failure (HFrEF, LVEF 35%, NYHA Class II-III) and comorbid generalised anxiety disorder. He is being referred following optimisation of his heart failure medications during a recent cardiology outpatient review. His wife Patricia is struggling to cope at home, and the community heart failure nurse has recommended a care home admission for stabilisation, monitoring, and carer support. Mr Davies has capacity to consent and is agreeable to admission.",
      "currentCare": "Living at home with wife Patricia. Supported by community heart failure nurse (fortnightly visits). GP: Dr James Whitfield, Exeter Central Surgery EX1 2NG.",
      "clinicalSummary": "HFrEF (LVEF 35%, Echo 2025). NYHA Class II-III. Recent weight gain 3 kg over one month (fluid retention). Controlled AF excluded — rhythm is sinus. No recent hospital admissions. Anxiety disorder managed with Sertraline 50 mg. Allergic to Aspirin (bronchospasm) — no NSAIDs.",
      "currentMedication": [
        {"drug": "Furosemide", "dose": "40mg", "frequency": "OD"},
        {"drug": "Ramipril", "dose": "5mg", "frequency": "OD"},
        {"drug": "Bisoprolol", "dose": "5mg", "frequency": "OD"},
        {"drug": "Spironolactone", "dose": "25mg", "frequency": "OD"},
        {"drug": "Sertraline", "dose": "50mg", "frequency": "OD"},
        {"drug": "Lorazepam", "dose": "0.5mg", "frequency": "PRN (max 2mg/24h)"}
      ],
      "allergies": "Aspirin (bronchospasm); Ibuprofen (contraindicated — heart failure)",
      "nextOfKin": {"name": "Patricia Davies", "relationship": "Wife", "phone": "07700 900881"},
      "referringProfessional": "Dr Amara Osei, Consultant Cardiologist, Royal Devon University Healthcare NHS Foundation Trust",
      "referralDate": "2026-04-16",
      "urgency": "Routine"
    }'::jsonb,
    4, 3, 2,
    '2026-04-21 14:00:00+00',
    '2026-04-16 10:00:00+00',
    '2026-04-21 14:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 6. ENCOUNTER (Admission)
  -- ============================================================
  INSERT INTO "Encounter" (
    "Id", "PatientId", "FacilityId", "WardId", "UserId",
    "AdmittedOn", "IsDischarged", "UpdatedBy",
    "BackgroundInformation", "Summary", "IsExternalTransfer",
    "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_encounter_id,
    v_patient_id, v_facility_id, v_ward_id, v_staff_2,
    '2026-04-24 10:00:00+00',
    false,
    v_staff_2,
    'Mr Arthur William Davies is a 73-year-old retired civil engineer admitted on 24 April 2026 from home on a voluntary basis. He has established heart failure with reduced ejection fraction (HFrEF, LVEF 35%) classified as NYHA Class II-III, alongside generalised anxiety disorder managed with Sertraline. He is married; his wife Patricia visits three to four times weekly and is his main support. Admission follows a 3 kg weight gain over the preceding month indicating fluid retention, and increasing difficulty managing at home. He has no history of hospital admission for acute decompensation in the past 12 months.',
    'Stable on admission, no acute respiratory distress at rest. SpO2 96% on room air. BP 138/88 mmHg, HR 68 bpm regular. Weight 89 kg (3 kg above estimated dry weight of 86 kg). Bilateral ankle oedema +2, pitting. Mildly breathless on exertion. Oriented to time, place, and person. Anxious about his prognosis — calm and cooperative. All five regular medications confirmed and commenced.',
    false,
    '2026-04-24 10:00:00+00',
    '2026-04-24 10:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "EncounterWard" (
    "Id", "EncounterId", "WardId", "IsCurrent",
    "LastUpdatedBy", "CreatedBy", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    '2b000002-0000-4000-8000-000000000001', v_encounter_id, v_ward_id, true,
    v_staff_2, v_staff_2,
    '2026-04-24 10:00:00+00', '2026-04-24 10:00:00+00'
  )
  ON CONFLICT DO NOTHING;

  -- ============================================================
  -- 7. DIAGNOSES
  -- ============================================================
  INSERT INTO "EncounterDiagnosis" (
    "Id", "EncounterId", "Diagnosis", "IsActive", "LastUpdatedBy",
    "ICDCode", "ICDVersion", "Status", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_diag_hf_id, v_encounter_id,
    'Heart failure, unspecified — HFrEF (LVEF 35%)',
    true, v_staff_2,
    '{"level1":"Diseases of the circulatory system","level2":"Heart failure","level3":"Heart failure, unspecified","icdcode":"I50.9"}'::jsonb,
    10, 'Active',
    '2026-04-24 10:30:00+00', '2026-04-24 10:30:00+00'
  ),
  (
    v_diag_gad_id, v_encounter_id,
    'Generalised anxiety disorder',
    true, v_staff_2,
    '{"level1":"Mental, Behavioural and Neurodevelopmental disorders","level2":"Neurotic, stress-related and somatoform disorders","level3":"Other anxiety disorders","level4":"Generalised anxiety disorder","icdcode":"F41.1"}'::jsonb,
    10, 'Active',
    '2026-04-24 10:30:00+00', '2026-04-24 10:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 8. LEGAL STATUS — Informal
  -- ============================================================
  INSERT INTO "EncounterLegalStatus" (
    "Id", "EncounterId", "LegalStatusType", "IsActive",
    "LastUpdatedBy", "CreatedBy",
    "IsSection17Applicable", "Section17Metadata", "Attachment",
    "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_legal_status_id, v_encounter_id,
    1, true, v_staff_2, v_staff_2,
    false, '{}'::jsonb, '[]'::jsonb,
    '2026-04-24 10:00:00+00', '2026-04-24 10:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 9. INITIAL ASSESSMENT
  -- ============================================================
  INSERT INTO "EncounterInitialAssessment" (
    "Id", "EncounterId", "UserId", "LastUpdatedBy",
    "Description", "Attachment", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_init_assess_id, v_encounter_id, v_staff_2, v_staff_2,
    'Admission assessment completed 24/04/2026 at 11:00. Mr Davies presented with moderate shortness of breath on exertion (NYHA Class II-III), bilateral ankle oedema (pitting, +2), and significant anxiety regarding his prognosis and the burden on his wife. He is alert and fully oriented. He has mental capacity to consent to care and is cooperative. Physical observations on admission: BP 138/88 mmHg, HR 68 bpm (regular sinus rhythm), Temp 36.5 C, SpO2 96% on room air, Weight 89 kg (3 kg above dry weight of 86 kg estimated from cardiology notes), Height 174 cm. Breath sounds clear bilaterally; no crepitations at rest. JVP mildly elevated. Feet and ankles — bilateral pitting oedema to mid-calf. Skin intact; no ulceration. Medications reviewed and reconciled with referral documentation and GP prescription record: Furosemide 40 mg OD, Ramipril 5 mg OD, Bisoprolol 5 mg OD, Spironolactone 25 mg OD, Sertraline 50 mg OD, Lorazepam 0.5 mg PRN. All confirmed and commenced. Daily weight monitoring initiated — scales provided in room. Fluid intake target set at 1.5 litres per day. Low-sodium diet arranged with kitchen. Mr Davies understands the rationale for fluid and sodium restriction. Care plans to be initiated within 48 hours. Risk assessments scheduled for 26/04/2026.',
    '[]'::jsonb,
    '2026-04-24 11:00:00+00', '2026-04-24 11:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 10. MEDICATIONS (6 total: 5 regular + 1 PRN)
  --     MedicationFrequency: 1=OD
  --     All regular medications are taken OD at 08:00
  -- ============================================================
  INSERT INTO "EncounterMedication" (
    "Id", "EncounterId", "Drug", "Dose", "Unit",
    "Instructions", "Frequency", "IsActive", "LastUpdatedBy",
    "AdministrationRoute", "MedicationForm",
    "SuggestedTimes", "IsHDAT", "IsPRN", "IsRegular",
    "MedicationType", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_med_furosemide_id, v_encounter_id,
    'Furosemide', '40', 'mg',
    'Loop diuretic. Administer in the morning to minimise nocturia. Monitor weight daily; report gain of 2 kg or more in 24 hours to nurse. Monitor renal function and electrolytes.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  ),
  (
    v_med_ramipril_id, v_encounter_id,
    'Ramipril', '5', 'mg',
    'ACE inhibitor for heart failure. Monitor blood pressure and renal function. Hold if systolic BP <90 mmHg and notify nurse.',
    1, true, v_staff_2, 'Oral', 'Capsule',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  ),
  (
    v_med_bisoprolol_id, v_encounter_id,
    'Bisoprolol', '5', 'mg',
    'Beta-blocker for heart failure. Do not stop abruptly. Monitor heart rate — hold and notify nurse if HR <50 bpm. Patient may report fatigue or dizziness.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  ),
  (
    v_med_spironolactone_id, v_encounter_id,
    'Spironolactone', '25', 'mg',
    'Aldosterone antagonist for heart failure. Monitor potassium levels — risk of hyperkalaemia especially with Ramipril. Report any muscle weakness or irregular heartbeat.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  ),
  (
    v_med_sertraline_id, v_encounter_id,
    'Sertraline', '50', 'mg',
    'SSRI for generalised anxiety disorder. Take with food. May take 4 to 6 weeks for full effect. Do not stop suddenly.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  ),
  (
    v_med_lorazepam_id, v_encounter_id,
    'Lorazepam', '0.5', 'mg',
    'PRN for acute anxiety or severe agitation. Maximum 2 mg in any 24-hour period. Document each use with time, dose, indication, and response. Use with caution — may cause respiratory depression in the context of heart failure.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    NULL, false, true, false, 'PRN',
    '2026-04-24 12:00:00+00', '2026-04-24 12:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 11. MEDICATION ADMINISTRATION RECORDS
  --     Day 10 (2026-05-03): full morning round — all administered
  --     Day 18 (2026-05-11): partial morning round — 2 meds shown
  --     Day 21 (2026-05-14): PRN lorazepam (acute anxiety episode)
  --     Day 25 (2026-05-18): bisoprolol refused
  --     MedicationAdministrationStatus: 1=Administered  4=Refused
  -- ============================================================
  INSERT INTO "MedicationAdministrationRecord" (
    "Id", "EncounterId", "MedicationId", "Status",
    "AdministeredOn", "Drug", "PrescribedDose", "PrescribedUnit",
    "Route", "AdministeredForm",
    "AdministeredDose", "AdministeredUnit",
    "AdministeredBy", "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- 2026-05-03 morning round (Day 10)
  (v_mar_01_id, v_encounter_id, v_med_furosemide_id,    1, '2026-05-03 08:00:00+00',
   'Furosemide',    '40',  'mg', 'Oral', 'Tablet',  '40',  'mg', v_staff_1, '2026-05-03 08:05:00+00', '2026-05-03 08:05:00+00'),
  (v_mar_02_id, v_encounter_id, v_med_ramipril_id,      1, '2026-05-03 08:00:00+00',
   'Ramipril',      '5',   'mg', 'Oral', 'Capsule', '5',   'mg', v_staff_1, '2026-05-03 08:05:00+00', '2026-05-03 08:05:00+00'),
  (v_mar_03_id, v_encounter_id, v_med_bisoprolol_id,    1, '2026-05-03 08:00:00+00',
   'Bisoprolol',    '5',   'mg', 'Oral', 'Tablet',  '5',   'mg', v_staff_1, '2026-05-03 08:05:00+00', '2026-05-03 08:05:00+00'),
  (v_mar_04_id, v_encounter_id, v_med_spironolactone_id,1, '2026-05-03 08:00:00+00',
   'Spironolactone','25',  'mg', 'Oral', 'Tablet',  '25',  'mg', v_staff_1, '2026-05-03 08:05:00+00', '2026-05-03 08:05:00+00'),
  (v_mar_05_id, v_encounter_id, v_med_sertraline_id,    1, '2026-05-03 08:00:00+00',
   'Sertraline',    '50',  'mg', 'Oral', 'Tablet',  '50',  'mg', v_staff_1, '2026-05-03 08:05:00+00', '2026-05-03 08:05:00+00'),
  -- 2026-05-11 morning (Day 18) — partial round shown
  (v_mar_06_id, v_encounter_id, v_med_furosemide_id,    1, '2026-05-11 08:00:00+00',
   'Furosemide',    '40',  'mg', 'Oral', 'Tablet',  '40',  'mg', v_staff_1, '2026-05-11 08:05:00+00', '2026-05-11 08:05:00+00'),
  (v_mar_07_id, v_encounter_id, v_med_sertraline_id,    1, '2026-05-11 08:00:00+00',
   'Sertraline',    '50',  'mg', 'Oral', 'Tablet',  '50',  'mg', v_staff_1, '2026-05-11 08:05:00+00', '2026-05-11 08:05:00+00'),
  -- 2026-05-14 PRN lorazepam (Day 21 — acute anxiety after phone call)
  (v_mar_08_id, v_encounter_id, v_med_lorazepam_id,     1, '2026-05-14 14:00:00+00',
   'Lorazepam',     '0.5', 'mg', 'Oral', 'Tablet',  '0.5', 'mg', v_staff_2, '2026-05-14 14:05:00+00', '2026-05-14 14:05:00+00'),
  -- 2026-05-18 bisoprolol refused (Day 25 — patient reported dizziness on standing)
  (v_mar_09_id, v_encounter_id, v_med_bisoprolol_id,    4, '2026-05-18 08:00:00+00',
   'Bisoprolol',    '5',   'mg', 'Oral', 'Tablet',  NULL,  NULL, v_staff_1, '2026-05-18 08:05:00+00', '2026-05-18 08:05:00+00')
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 12. DAILY NOTES (14 notes across 28 days)
  -- ============================================================
  INSERT INTO "EncounterGeneralNote" (
    "Id", "EncounterId", "UserId", "Type",
    "Description", "LastUpdatedBy",
    "Attachment", "Comments", "IsSystemGenerated",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- Day 1 (2026-04-24) — Admission (support_worker)
  (v_note_01_id, v_encounter_id, v_staff_1, 47,
   'Arthur arrived at 10:00 accompanied by his wife Patricia. He appeared anxious and short of breath after the journey but settled quickly in his room. Patricia helped orientate him to the layout of the home — dining room, lounge, garden, and his bathroom. He asked detailed questions about his daily routine, medication times, and how his weight would be monitored. All questions answered fully and information provided in writing per his preference. Scales placed in room for daily weighing. Fluid restriction of 1.5 litres per day explained and accepted. Arthur ate a light lunch; Patricia stayed until 15:00. Evening: he remained in his room, listened to the radio, and retired early. All medications administered without difficulty.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-24 22:00:00+00', '2026-04-24 22:00:00+00'),

  -- Day 3 (2026-04-26) — Managing mental health
  (v_note_02_id, v_encounter_id, v_staff_2, 35,
   'Initial anxiety assessment completed as part of keyworker introduction. Arthur described his anxiety as "always there, like a background noise" but significantly worsened since his heart failure diagnosis in 2020. He reports ruminating about his prognosis, fear of a sudden deterioration overnight, and concern about being a burden to Patricia. He rates his anxiety as 7/10 currently. On Sertraline 50 mg for 18 months with partial benefit. No suicidal ideation. Appropriate coping strategies discussed: structured daily routine, written information, factual clinical updates. He finds crosswords helpful for distraction. Goals set: reduce anxiety self-rating to 5/10 within two weeks through routine, information, and keyworker sessions. MyStory completed with his input.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-26 14:00:00+00', '2026-04-26 14:00:00+00'),

  -- Day 5 (2026-04-28) — Acute breathlessness episode (support_worker)
  (v_note_03_id, v_encounter_id, v_staff_1, 47,
   'Called to Arthur''s room at 02:10 by call bell. He was sitting upright in bed, visibly breathless and distressed. He reported waking unable to breathe lying flat (orthopnoea). SpO2 on pulse oximeter: 89% on room air. Nurse called immediately. Arthur was assisted to sit upright; supplemental oxygen commenced at 4 L/min via nasal cannula. SpO2 improved to 94% within 10 minutes. GP on-call notified at 02:25; reviewed by phone. Additional dose of furosemide not administered — GP advised to monitor and review in the morning. SpO2 95% by 03:15. Arthur remained anxious throughout; reassurance provided. Patricia notified by phone at 07:00. Incident form INC-2026-003 completed. Morning GP review confirmed current medications unchanged; will check U&E and renal function at next bloods.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-28 04:00:00+00', '2026-04-28 04:00:00+00'),

  -- Day 7 (2026-04-30) — Session entry (keyworker)
  (v_note_04_id, v_encounter_id, v_staff_2, 48,
   'First formal keyworker session, approximately 35 minutes. Arthur was calmer than on admission but remained preoccupied by the breathlessness episode on Day 5. He described it as "the most frightening thing that has happened to me." He understands it was related to his heart failure and fluid retention. Discussion of overnight safety plan: call bell always within reach, head of bed elevated, staff to check at 23:00 each night. He identified classical music and crosswords as reliable anxiety management tools. He agreed to try joining the lounge for one activity per day as a step toward engagement. Patricia visited during the session; she was included in the discussion with Arthur''s agreement. She expressed concern about his weight trend. Explained current trajectory and reassured her that furosemide is working.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-30 15:00:00+00', '2026-04-30 15:00:00+00'),

  -- Day 9 (2026-05-02) — Phone call (wife)
  (v_note_05_id, v_encounter_id, v_staff_2, 54,
   'Phone call from Patricia Davies (wife/NoK) at 11:20. She reported that Arthur had telephoned her this morning sounding "more like himself." He told her his weight was down 1 kg and that he had slept the whole night through for the first time in weeks. Patricia expressed relief and thanked staff for the written updates. She confirmed she will visit on Saturday. She asked about the falls risk following the incident on Day 5 — explained that a formal falls risk assessment is scheduled and that staff assist with night-time mobility. No concerns raised.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-02 11:30:00+00', '2026-05-02 11:30:00+00'),

  -- Day 11 (2026-05-04) — Living skills
  (v_note_06_id, v_encounter_id, v_staff_1, 37,
   'Arthur was noticeably more settled today. He dressed independently this morning and joined the dining room for breakfast — the first time since admission. He weighed himself before breakfast: 87.5 kg, down 1.5 kg from admission. Visibly pleased; said "the tablets are doing their job." He joined a small group in the lounge for an hour and completed a newspaper crossword. He declined the afternoon film but listened to Radio 3 in the lounge with two other residents. Good oral intake at lunch and dinner. All medications taken. No breathlessness reported today at rest or on gentle exertion.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-04 18:00:00+00', '2026-05-04 18:00:00+00'),

  -- Day 13 (2026-05-06) — Managing mental health (prognosis anxiety)
  (v_note_07_id, v_encounter_id, v_staff_2, 35,
   'Arthur''s daughter Karen visited this afternoon (14:00–16:30). After her visit he appeared quiet and withdrawn. He disclosed that Karen had asked questions about his long-term prognosis that he found difficult to answer, and that he had "said things out loud that I don''t usually say." He described feeling sad rather than acutely anxious. He denied suicidal ideation. He was offered 1:1 time and accepted. He talked about his career, his marriage, and his fear of becoming fully dependent. Validated his feelings; agreed to discuss prognosis support with the keyworker in the next planned session. Mood self-rated 4/10 this evening. No change to medication. Manager informed.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-06 18:30:00+00', '2026-05-06 18:30:00+00'),

  -- Day 15 (2026-05-08) — Near-fall during nocturia (support_worker)
  (v_note_08_id, v_encounter_id, v_staff_1, 47,
   'Called to Arthur''s room at 02:30 following noise from his room. Found him standing beside his bed holding the bedside rail. He had risen to use the toilet and felt lightheaded on standing — he grabbed the rail before losing balance and did not fall. He was uninjured and fully conscious. BP checked immediately: 102/68 mmHg (postural drop from daytime reading of 128/82). Heart rate 62 bpm. He was assisted to the toilet and back to bed safely. BP rechecked 10 minutes later: 118/76 mmHg. Explained that furosemide increases night-time urination and can cause dizziness on standing. Call bell reinforced; advised to call staff before rising at night rather than getting up alone. Incident form INC-2026-004 completed. Nurse informed; falls risk assessment arranged.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-08 03:30:00+00', '2026-05-08 03:30:00+00'),

  -- Day 17 (2026-05-10) — Phone call (GP review)
  (v_note_09_id, v_encounter_id, v_staff_3, 54,
   'Phone call from Dr James Whitfield (GP) at 10:00 for scheduled medication and clinical review. Discussed the overnight breathlessness episode (Day 5), the near-fall (Day 15), and weight trend. Weight today 86 kg — at estimated dry weight. GP satisfied with diuretic response. Agreed plan: continue current medications unchanged; arrange U&E and renal function bloods in the next 7 days to check potassium (Ramipril + Spironolactone combination); review bisoprolol dose at next GP visit if patient reports ongoing dizziness; GP to arrange echocardiogram repeat at 3 months. GP advised to be notified immediately if weight rises more than 2 kg overnight or if SpO2 drops below 93% on room air. Falls risk assessment findings to be shared with GP.',
   v_staff_3, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-10 10:30:00+00', '2026-05-10 10:30:00+00'),

  -- Day 19 (2026-05-12) — Session entry (keyworker — prognosis anxiety)
  (v_note_10_id, v_encounter_id, v_staff_2, 48,
   'Keyworker session, 40 minutes. Focus on the prognosis anxiety raised following Karen''s visit (Day 13). Arthur spoke more openly today. He acknowledged that he is frightened of dying but more frightened of "a long decline." He asked about advance care planning and whether he could document his wishes. Information about advance care planning provided in writing. He is not ready to complete a formal plan today but asked that it be flagged for discussion with Dr Whitfield. He also raised his feelings about his wife''s wellbeing — he worries that his illness is exhausting her. Explored supports available to Patricia. Mood self-rated 5/10 today — improved from 4/10 on Day 13. He completed the crossword in the morning and described it as "the clearest my head has felt in days." Target maintained at 5/10 or above.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-12 15:30:00+00', '2026-05-12 15:30:00+00'),

  -- Day 21 (2026-05-14) — Managing mental health (anxiety episode, PRN lorazepam)
  (v_note_11_id, v_encounter_id, v_staff_2, 35,
   'Arthur received a telephone call from his son James at 13:00. James lives in Bristol and has not visited since admission. The call was difficult — James expressed concern about Arthur''s condition in a way Arthur found alarming. Immediately after the call Arthur became pale, tremulous, and hyperventilating. He rated his anxiety as 9/10. Calm approach used: seated him, breathing exercises practised, reassurance provided. He did not settle with non-pharmacological measures within 15 minutes. Nurse administered Lorazepam 0.5 mg orally at 14:00 with Arthur''s consent. He settled within 25 minutes; anxiety 5/10 at 14:30. He was encouraged to rest. Patricia telephoned at 16:00 and was updated (with Arthur''s permission). James to be invited to a family meeting with the keyworker present to align communication about prognosis.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-14 15:00:00+00', '2026-05-14 15:00:00+00'),

  -- Day 23 (2026-05-16) — Living skills (weight improving, more engaged)
  (v_note_12_id, v_encounter_id, v_staff_1, 37,
   'Good day for Arthur. Morning weight: 85.5 kg — the lowest since admission, 0.5 kg below estimated dry weight; noted and reported to nurse for monitoring. He dressed independently, joined breakfast in the dining room, and spent two hours in the garden with Patricia who arrived at 11:00. He showed her the flower beds and described the birds he has seen from his window. Afternoon: completed two crosswords. He initiated conversation with another resident about cricket. All medications taken. No breathlessness at rest or on gentle walking. He told staff: "I feel almost normal today." Mood self-rated 6/10 — best rating since admission.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-16 18:00:00+00', '2026-05-16 18:00:00+00'),

  -- Day 25 (2026-05-18) — Support worker (bisoprolol refusal)
  (v_note_13_id, v_encounter_id, v_staff_1, 47,
   'Arthur declined his bisoprolol at the 08:00 medication round, stating: "It makes me feel dizzy when I stand up — I nearly fell because of it." Discussed the risk of stopping bisoprolol abruptly in heart failure; he acknowledged the risk but asked to speak to the nurse before taking it. Nurse spoke with him at 08:30. Arthur agreed to a trial of waiting 30 minutes after medication before rising, and using the bedside rail when standing. He agreed to continue bisoprolol today on the basis that the postural dizziness concern will be formally documented and passed to the GP. Refusal recorded on MAR for this morning''s dose (prior to agreement at 08:30 review). All other medications taken. GP to be notified at next scheduled contact.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-18 09:00:00+00', '2026-05-18 09:00:00+00'),

  -- Day 28 (2026-05-21) — Managing mental health (monthly review)
  (v_note_14_id, v_encounter_id, v_staff_2, 35,
   'Monthly review of mental state and wellbeing. Arthur has made meaningful progress over the 28 days since admission. Weight is now 85.5 kg — within target range. He has had no further episodes of nocturnal breathlessness since Day 5 and no further near-falls since Day 15. He is engaging with daily activities, joining the dining room for meals consistently, and has established a friendly relationship with two other residents. His anxiety self-rating today is 5/10, meeting the target set on Day 3. He has agreed to family meeting with James and Patricia in the coming week. He remains open to discussion about advance care planning but has not yet completed a formal plan. The generalised anxiety disorder and heart failure are both better managed in the structured care home environment than at home. MDT meeting scheduled 26/05/2026. Overall trajectory positive.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-21 16:00:00+00', '2026-05-21 16:00:00+00')
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 13. CARE PLANS (2)
  --     CarePlanType 1329 = Physical health (heart failure)
  --     CarePlanType 1328 = Managing mental health (anxiety)
  -- ============================================================
  INSERT INTO "EncounterCarePlan" (
    "Id", "EncounterId", "UserId", "Type", "LastUpdatedBy",
    "Description", "Entry", "Status",
    "HasCarePlanBeenDiscussed", "IsArchived",
    "careplan_created_status", "Version",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_cp_physical_id, v_encounter_id, v_staff_2, 1329, v_staff_2,
    '{"summary":"This care plan addresses Arthur''s heart failure management, fluid balance monitoring, and prevention of acute decompensation."}'::jsonb,
    '[
      {"title":"Goal","value":"To maintain weight within 2 kg of dry weight (86 kg target), prevent acute decompensation, manage breathlessness, and support safe physical activity."},
      {"title":"Daily weight monitoring","value":"Arthur weighs himself each morning before breakfast using the scales in his room. Weight recorded in the clinical system by 09:00. Alert threshold: weight gain of 2 kg or more overnight — notify nurse immediately. Alert threshold: three consecutive days of weight gain — notify GP."},
      {"title":"Fluid management","value":"Daily fluid intake target 1.5 litres. Fluid intake to be documented at each meal and PRN. Low-sodium diet provided by kitchen — Arthur understands and agrees to this restriction. No added salt at meals."},
      {"title":"Medication monitoring","value":"Furosemide 40 mg OD — monitor for postural hypotension and electrolyte disturbance. Ramipril 5 mg OD — hold and notify nurse if systolic BP <90 mmHg. Bisoprolol 5 mg OD — do not stop abruptly; monitor HR before administration. Spironolactone 25 mg OD — monitor potassium; arrange U&E bloods as per GP plan."},
      {"title":"Breathlessness management","value":"Monitor SpO2 on room air weekly and whenever Arthur reports breathlessness. Target SpO2 >94%. If SpO2 <93%: apply supplemental oxygen at 2-4 L/min, sit upright, call nurse immediately. If SpO2 <90% or not improving: call 999 and notify family."},
      {"title":"Overnight safety","value":"Head of bed elevated at all times. Call bell within reach. Night-time check by staff at 23:00. Arthur to call staff before rising at night — postural hypotension risk with furosemide."},
      {"title":"Physical activity","value":"Encourage gentle activity as tolerated — short walks to lounge, garden when weather permits. Avoid exertion that causes breathlessness or dizziness. Monitor for signs of decompensation after activity."},
      {"title":"Review date","value":"2026-05-28"}
    ]'::jsonb,
    2, true, false, 'created', v_careplan_schema_version,
    '2026-04-26 14:00:00+00', '2026-05-02 10:00:00+00'
  ),
  (
    v_cp_mental_id, v_encounter_id, v_staff_2, 1328, v_staff_2,
    '{"summary":"This care plan addresses Arthur''s generalised anxiety disorder, prognosis-related worry, and emotional wellbeing during admission."}'::jsonb,
    '[
      {"title":"Goal","value":"To maintain Arthur''s anxiety self-rating at 5/10 or below, support engagement with daily activities, and create a safe space for discussion of prognosis concerns and advance care planning."},
      {"title":"What is important to Arthur","value":"Being informed about his health — facts, not vagueness. Feeling in control where possible. The wellbeing of his wife Patricia. Maintaining his identity as a capable, intelligent person. Classical music and crosswords."},
      {"title":"Current anxiety presentation","value":"Generalised anxiety disorder with prominent health anxiety and prognosis-related worry since heart failure diagnosis in 2020. Managed on Sertraline 50 mg for 18 months. Anxiety significantly heightened at admission (7/10). Improving with structured routine and information provision."},
      {"title":"Interventions","value":"Weekly keyworker sessions. Daily routine with predictable structure. Written information provided for all clinical updates and changes. Factual clinical updates from nurse after each GP contact. Family communication coordinated through keyworker. PRN Lorazepam 0.5 mg for acute anxiety unresponsive to non-pharmacological measures."},
      {"title":"Early warning signs","value":"Withdrawing to room; refusing meals; persistent trembling or hyperventilation; repeatedly asking the same questions without reassurance effect; reporting chest tightness without cardiovascular cause."},
      {"title":"What to do if warning signs appear","value":"Offer 1:1 time using calm, factual communication. Confirm physical observations to reassure. Use breathing exercises. If unresolved within 15 minutes: consider PRN lorazepam with nurse authorisation. Notify keyworker."},
      {"title":"Advance care planning","value":"Arthur has expressed interest in documenting his wishes regarding future care. He is not ready to complete a formal plan at this time. To be raised with GP Dr Whitfield at next scheduled contact and revisited with keyworker after family meeting."},
      {"title":"Review date","value":"2026-05-28"}
    ]'::jsonb,
    2, true, false, 'created', v_careplan_schema_version,
    '2026-04-26 14:00:00+00', '2026-05-02 10:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "EncounterCarePlanContributors" (
    "Id", "CarePlanId", "UserId", "IsConfirmed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_cp_physical_id, v_staff_2, true, '2026-04-26 14:00:00+00', '2026-04-26 14:00:00+00'),
  (gen_random_uuid(), v_cp_physical_id, v_staff_1, true, '2026-04-26 14:00:00+00', '2026-04-26 14:00:00+00'),
  (gen_random_uuid(), v_cp_mental_id,   v_staff_2, true, '2026-04-26 14:00:00+00', '2026-04-26 14:00:00+00')
  ON CONFLICT ("CarePlanId", "UserId") DO NOTHING;

  INSERT INTO "EncounterCarePlanReview" (
    "Id", "CarePlanId", "ReviewedBy", "Comment",
    "Status", "ReviewedTimeStatus", "ReviewQuestions",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_cpr_physical_id, v_cp_physical_id, v_staff_2,
    'Two-week review completed 07/05/2026. Weight has fallen from 89 kg on admission to 86.5 kg — approaching dry weight. No further episodes of acute breathlessness since Day 5. Blood pressure stable. Furosemide is effective. Overnight safety plan in place. No changes to care plan at this time. Next review 21/05/2026.',
    1, 'On time',
    '{"overallProgress":"Improving","goalsOnTrack":true,"changesRequired":false}'::jsonb,
    '2026-05-07 15:00:00+00', '2026-05-07 15:00:00+00'
  ),
  (
    v_cpr_mental_id, v_cp_mental_id, v_staff_2,
    'Two-week review completed 07/05/2026. Anxiety self-rating has improved from 7/10 on admission to 5/10 today. Arthur is engaging with daily activities and keyworker sessions. The structured routine and written information approach is effective. PRN lorazepam used once (Day 21 — acute anxiety episode). Family communication to be improved following James''s phone call incident. Plan unchanged.',
    1, 'On time',
    '{"overallProgress":"Improving","goalsOnTrack":true,"changesRequired":false}'::jsonb,
    '2026-05-07 15:00:00+00', '2026-05-07 15:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 14. RISK ASSESSMENTS (3)
  --     TypeId 12 = Mental Health (anxiety)
  --     TypeId 14 = Eating (fluid and nutritional risk)
  --     TypeId 10 = Social (falls risk)
  -- ============================================================
  INSERT INTO "RiskAssessment" (
    "Id", "EncounterId", "TypeId", "SubmissionStatusId",
    "Entry", "Score",
    "CreatedById", "LastUpdatedById",
    "AssessmentDate", "ReviewStatus",
    "Topic", "SubTopic",
    "IsArchived", "WasTheServiceUserInvolved", "Version",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- RA 1: Mental Health — anxiety and prognosis worry (TypeId 12)
  (
    v_ra_mental_id, v_encounter_id, 12, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Anxiety and Prognosis-Related Worry"},
      "description": {
        "perceivedRisk": "Low-moderate risk of acute anxiety episodes. Arthur has established GAD with prominent health anxiety focused on his heart failure prognosis. Risk of acute episodes heightened by family communications, overnight health events, and clinical deterioration.",
        "advantagesToPatient": "Arthur has good insight into his anxiety, engages actively with management strategies, and has identified effective coping tools (crosswords, music, factual information). He is motivated to manage his condition.",
        "incidentsFromBehaviour": "One acute anxiety episode on Day 21 requiring PRN lorazepam following a distressing phone call from his son.",
        "incidentsTimescale": "Single episode at Day 21 of admission.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Social withdrawal; repeatedly asking the same question without reassurance effect; trembling or hyperventilation; pallor; refusing meals.",
        "knownTriggers": "Conversations about prognosis — especially with family members not aligned on communication approach. Overnight health events (e.g. breathlessness). Unexpected changes to routine. Feeling out of control."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "moderate",
        "probabilityLevel": "possible"
      },
      "consequences": {
        "earlyWarningSigns": "Acute anxiety episode; hyperventilation; distress. Risk of triggering cardiac symptoms through physiological anxiety response.",
        "knownTriggers": "No risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall","drOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement","therapeuticEngagement"]},
      "strategies": {
        "proactiveStrategies": "Weekly keyworker sessions. Consistent daily routine. Written clinical updates after each GP contact. Family meeting to align communication about prognosis. Non-pharmacological anxiety management: breathing exercises, crosswords, music.",
        "reactiveStrategies": "Calm 1:1 approach. Confirm physical observations to distinguish anxiety from cardiac cause. Breathing exercises. If unresolved within 15 minutes: PRN lorazepam 0.5 mg with nurse authorisation. Notify keyworker within 4 hours."
      },
      "summary": {"furtherActionsNeeded":"Yes","additionalActions":"Arrange family meeting with James and Patricia. Raise advance care planning with GP at next contact."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    4.0, v_staff_2, v_staff_2,
    '2026-04-26',
    1,
    'Anxiety and Prognosis-Related Worry', 'Generalised Anxiety Disorder',
    false, true, 1,
    '2026-04-26 10:00:00+00', '2026-04-26 10:00:00+00'
  ),
  -- RA 2: Eating — fluid and nutritional risk (TypeId 14)
  (
    v_ra_eating_id, v_encounter_id, 14, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Fluid and Nutritional Risk"},
      "description": {
        "perceivedRisk": "Moderate risk of fluid retention and nutritional inadequacy. Arthur has heart failure with a 3 kg fluid excess on admission. Risk of inadequate oral intake during periods of anxiety or low mood, which could impair diuretic response and nutritional status.",
        "advantagesToPatient": "Arthur understands his fluid restriction and sodium restriction and is motivated to adhere. He monitors his own weight. He has a good appetite when his mood is stable.",
        "incidentsFromBehaviour": "3 kg fluid excess noted on admission. Resolved to dry weight by Day 10 with furosemide. Weight stable to slightly below dry weight since.",
        "incidentsTimescale": "Fluid excess on admission; no recurrence to date.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Weight gain of 2 kg or more overnight; increased ankle swelling; breathlessness at rest; reduced appetite lasting more than one day; declining fluids.",
        "knownTriggers": "Sodium-rich foods bypassing kitchen restriction (e.g. from visitor-brought items). Anxiety-related appetite suppression. Inadequate fluid intake causing prerenal impairment."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "moderate",
        "probabilityLevel": "possible"
      },
      "consequences": {
        "earlyWarningSigns": "Acute decompensation of heart failure — acute breathlessness, hospital admission risk.",
        "knownTriggers": "No risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall","drOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement"]},
      "strategies": {
        "proactiveStrategies": "Daily morning weight before breakfast, recorded by 09:00. Fluid intake documented at each meal. Low-sodium diet. Visitors advised not to bring salty snacks or takeaway food. Monitor appetite at each meal and document.",
        "reactiveStrategies": "Weight gain >2 kg overnight: notify nurse, withhold furosemide dose pending nurse assessment, contact GP. Signs of acute breathlessness: sit upright, O2 if SpO2 <93%, call nurse immediately. Three consecutive days of weight gain: notify GP same day."
      },
      "summary": {"furtherActionsNeeded":"Yes","additionalActions":"U&E and renal function bloods due within 7 days as per GP plan (Ramipril + Spironolactone combination monitoring)."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    7.0, v_staff_2, v_staff_2,
    '2026-04-26',
    1,
    'Fluid and Nutritional Risk', 'Heart Failure Decompensation',
    false, true, 1,
    '2026-04-26 10:30:00+00', '2026-04-26 10:30:00+00'
  ),
  -- RA 3: Social — falls risk (TypeId 10); completed after near-fall on Day 15
  (
    v_ra_falls_id, v_encounter_id, 10, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Falls Risk"},
      "description": {
        "perceivedRisk": "Moderate falls risk. Arthur experiences postural hypotension related to furosemide and bisoprolol, which is most pronounced on rising from bed at night. A near-fall occurred on 08/05/2026 during a nocturnal toilet visit (Day 15). He does not use a walking aid during the day but is at risk during night-time rising.",
        "advantagesToPatient": "Arthur has good insight into the postural dizziness risk and has agreed to call staff before rising at night. He is physically capable during the day when circulatory adjustment has had time to occur.",
        "incidentsFromBehaviour": "One near-fall on 08/05/2026 — postural hypotension on rising from bed at 02:30 during nocturnal diuresis. Steadied himself; no injury.",
        "incidentsTimescale": "Single near-miss at Day 15 of admission.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Dizziness on standing; visual disturbance on rising; BP postural drop >20 mmHg systolic; weight gain causing increased dyspnoea and reduced mobility.",
        "knownTriggers": "Rising quickly from bed at night. Furosemide-related nocturia (typically 01:00–04:00). Bisoprolol reducing compensatory heart rate increase on standing."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "moderate",
        "probabilityLevel": "possible"
      },
      "consequences": {
        "earlyWarningSigns": "Fall with injury — hip fracture risk elevated in 73-year-old male on antihypertensives and beta-blockers.",
        "knownTriggers": "No direct risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement"]},
      "strategies": {
        "proactiveStrategies": "Call bell always within reach of bed. Arthur to call staff before rising at night — reinforced verbally and in writing. Staff night check at 23:00. Bedside lamp accessible without rising. Non-slip footwear provided. Bed positioned at lowest safe height. BP (lying and standing) checked weekly.",
        "reactiveStrategies": "If fall occurs: do not move patient; assess for injury; call for first-aider. If injury suspected: call 999, notify manager and family. Incident form within 1 hour. Bisoprolol dose review to be discussed with GP if postural dizziness persists."
      },
      "summary": {"furtherActionsNeeded":"Yes","additionalActions":"Discuss bisoprolol dose review with GP at next contact. Document nocturnal call bell use pattern over next 2 weeks."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    6.0, v_staff_2, v_staff_2,
    '2026-05-09',
    1,
    'Falls Risk', 'Postural Hypotension / Nocturia',
    false, true, 1,
    '2026-05-09 11:00:00+00', '2026-05-09 11:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "RiskAssessmentAssessor" (
    "Id", "RiskAssessmentId", "UserId", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_ra_mental_id, v_staff_2, '2026-04-26 10:00:00+00', '2026-04-26 10:00:00+00'),
  (gen_random_uuid(), v_ra_eating_id,  v_staff_2, '2026-04-26 10:30:00+00', '2026-04-26 10:30:00+00'),
  (gen_random_uuid(), v_ra_falls_id,   v_staff_2, '2026-05-09 11:00:00+00', '2026-05-09 11:00:00+00');

  -- ============================================================
  -- 15. INCIDENTS (2)
  --     INC-2026-003: Acute breathlessness episode (Day 5)
  --       TypeId 60 = Other (Category 11 All Other Incidents)
  --     INC-2026-004: Near-fall during nocturia (Day 15)
  --       TypeId 55 = Slips, Trips and Falls (Category 9 Accidents)
  -- ============================================================
  INSERT INTO "EncounterIncident" (
    "Id", "EncounterId", "TypeId", "SchemaId",
    "Entry", "OccurredOn",
    "CreatedBy", "LastUpdatedBy",
    "ReviewStatus", "Status",
    "ReferenceNumber", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_incident_breathless_id, v_encounter_id, 60, v_incident_schema_id,
    '{
      "incidentType": "Other Clinical Incident",
      "category": "All Other Incidents",
      "description": "Arthur activated his call bell at 02:10 reporting inability to breathe lying flat (orthopnoea). Found sitting upright in bed, visibly distressed, SpO2 89% on room air. Nurse called immediately. Supplemental oxygen commenced at 4 L/min via nasal cannula. SpO2 improved to 94% within 10 minutes and 95% by 03:15. GP on-call notified at 02:25; reviewed by phone and advised to monitor and review in the morning — no additional furosemide prescribed acutely. Arthur remained anxious throughout the episode. Patricia (wife) notified by telephone at 07:00. Morning review with GP: current medications unchanged; plan to monitor weight and bloods.",
      "immediateActions": "Patient sat upright. Supplemental oxygen 4 L/min applied. Nurse present throughout. GP on-call contacted at 02:25.",
      "outcome": "SpO2 recovered to 95% by 03:15. No hospital transfer required. No recurrence of nocturnal breathlessness in the 23 days since this episode.",
      "witnesses": ["Night care worker"],
      "reportedBy": "Care Worker",
      "injurySustained": false,
      "followUpRequired": true
    }'::jsonb,
    '2026-04-28 02:10:00+00',
    v_staff_1, v_staff_2,
    1, 2,
    'INC-2026-003',
    '2026-04-28 04:30:00+00', '2026-04-28 04:30:00+00'
  ),
  (
    v_incident_fall_id, v_encounter_id, 55, v_incident_schema_id,
    '{
      "incidentType": "Slips, Trips and Falls",
      "category": "Accidents",
      "description": "Arthur rose from bed at 02:30 to use the toilet without calling staff as agreed. On standing he experienced significant dizziness (postural hypotension) and reached for the bedside rail before losing balance. He did not fall to the ground. Immediate assessment: BP lying 124/78 mmHg, BP standing 102/68 mmHg (postural drop of 22 mmHg systolic). HR 62 bpm. No injury — no pain on palpation, full weight bearing, no visual disturbance reported. He was assisted to the toilet and back to bed safely. BP rechecked 10 minutes later: 118/76 mmHg. The risk of nocturnal rising without assistance was discussed; Arthur agreed to use the call bell at night. Written reminder placed by the call bell. Falls risk assessment completed 09/05/2026.",
      "immediateActions": "Full physical assessment completed. Lying and standing BP checked. No injury confirmed. Patient counselled on night-time call bell use.",
      "outcome": "Near miss — no injury sustained. Overnight call bell protocol reinforced in care plan. Falls risk assessment completed 09/05/2026. Bisoprolol dose review to be raised with GP.",
      "witnesses": ["Night care worker"],
      "reportedBy": "Care Worker",
      "injurySustained": false,
      "followUpRequired": true
    }'::jsonb,
    '2026-05-08 02:30:00+00',
    v_staff_1, v_staff_2,
    1, 2,
    'INC-2026-004',
    '2026-05-08 03:30:00+00', '2026-05-08 03:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "IncidentPatient" (
    "Id", "IncidentId", "PatientId", "RolePlayed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_incident_breathless_id, v_patient_id, 'Service user', '2026-04-28 04:30:00+00', '2026-04-28 04:30:00+00'),
  (gen_random_uuid(), v_incident_fall_id,        v_patient_id, 'Service user', '2026-05-08 03:30:00+00', '2026-05-08 03:30:00+00')
  ON CONFLICT ("IncidentId", "PatientId") DO NOTHING;

  INSERT INTO "IncidentUser" (
    "Id", "IncidentId", "UserId", "RolePlayed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_incident_breathless_id, v_staff_1, 'First responder', '2026-04-28 04:30:00+00', '2026-04-28 04:30:00+00'),
  (gen_random_uuid(), v_incident_fall_id,        v_staff_1, 'Witness',         '2026-05-08 03:30:00+00', '2026-05-08 03:30:00+00')
  ON CONFLICT ("UserId", "IncidentId") DO NOTHING;

  -- ============================================================
  -- 16. VITALS (8 readings)
  --     Type 1 = Blood Pressure
  --     Type 5 = Weight
  --     Type 6 = SpO2 (oxygen saturation — no FK enforced on Type)
  -- ============================================================
  INSERT INTO "EncounterVitals" (
    "Id", "EncounterId", "Type", "ReadingTakenOn",
    "UserId", "UpdatedBy", "Measurement", "IsAccurate",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- Day 1 (2026-04-24) — admission observations
  (v_vital_01_id, v_encounter_id, 1, '2026-04-24 10:15:00+00', v_staff_2, v_staff_2,
   '{"systolic":138,"diastolic":88,"pulse":68,"unit":"mmHg"}'::jsonb,
   true, '2026-04-24 10:15:00+00', '2026-04-24 10:15:00+00'),
  (v_vital_02_id, v_encounter_id, 5, '2026-04-24 10:20:00+00', v_staff_2, v_staff_2,
   '{"value":89,"unit":"kg","context":"Admission weight — estimated 3 kg above dry weight"}'::jsonb,
   true, '2026-04-24 10:20:00+00', '2026-04-24 10:20:00+00'),
  (v_vital_03_id, v_encounter_id, 6, '2026-04-24 10:25:00+00', v_staff_2, v_staff_2,
   '{"value":96,"unit":"%","context":"SpO2 on room air — admission"}'::jsonb,
   true, '2026-04-24 10:25:00+00', '2026-04-24 10:25:00+00'),
  -- Day 5 (2026-04-28) — acute breathlessness episode
  (v_vital_04_id, v_encounter_id, 6, '2026-04-28 02:15:00+00', v_staff_1, v_staff_1,
   '{"value":89,"unit":"%","context":"SpO2 on room air — acute orthopnoea episode pre-oxygen"}'::jsonb,
   true, '2026-04-28 02:15:00+00', '2026-04-28 02:15:00+00'),
  (v_vital_05_id, v_encounter_id, 6, '2026-04-28 03:15:00+00', v_staff_1, v_staff_1,
   '{"value":95,"unit":"%","context":"SpO2 — 1 hour after supplemental oxygen at 4 L/min"}'::jsonb,
   true, '2026-04-28 03:15:00+00', '2026-04-28 03:15:00+00'),
  -- Day 10 (2026-05-03) — weight check (fluid response to furosemide)
  (v_vital_06_id, v_encounter_id, 5, '2026-05-03 08:00:00+00', v_staff_1, v_staff_1,
   '{"value":87,"unit":"kg","context":"Day 10 morning weight — 2 kg reduction from admission"}'::jsonb,
   true, '2026-05-03 08:00:00+00', '2026-05-03 08:00:00+00'),
  -- Day 20 (2026-05-13) — weight at estimated dry weight
  (v_vital_07_id, v_encounter_id, 5, '2026-05-13 08:00:00+00', v_staff_1, v_staff_1,
   '{"value":86,"unit":"kg","context":"Day 20 morning weight — at estimated dry weight target"}'::jsonb,
   true, '2026-05-13 08:00:00+00', '2026-05-13 08:00:00+00'),
  -- Day 28 (2026-05-21) — current weight
  (v_vital_08_id, v_encounter_id, 5, '2026-05-21 08:00:00+00', v_staff_1, v_staff_1,
   '{"value":85.5,"unit":"kg","context":"Day 28 morning weight — 0.5 kg below dry weight target; monitoring continued"}'::jsonb,
   true, '2026-05-21 08:00:00+00', '2026-05-21 08:00:00+00')
  ON CONFLICT ("Id") DO NOTHING;

END $$;

COMMIT;
