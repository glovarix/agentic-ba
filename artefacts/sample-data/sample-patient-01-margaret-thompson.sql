-- =============================================================
-- SAMPLE PATIENT DATA — Patient 01: Margaret Anne Thompson
-- Conditions: Type 2 Diabetes Mellitus (E11.9) + Bipolar II (F31.3)
-- Admission: 2026-04-21 | Current | Care home setting
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
--   1. Replace the 3 ENVIRONMENT PLACEHOLDERS in the DECLARE block
--      below with real UUIDs from your database.
--   2. Run as: psql -d <your_db> -f this_file.sql
--   3. The script is idempotent (ON CONFLICT DO NOTHING throughout).
--
-- LOOKUP IDs USED (verified against my-app-main migrations):
--   SubmissionStatus:           2 = Submitted
--   LegalStatus:                1 = Informal
--   MedicationFrequency:        1=OD  2=BD  3=TDS
--   MedicationAdministrationStatus: 1=Administered  2=Missed  4=Refused
--   RiskAssessmentType:         10=Social  12=Mental Health  14=Eating
--   RiskAssessmentReviewStatus: 1 = Pending review
--   CarePlanType:               1328=Managing mental health  1329=Physical health
--   GeneralNoteType:            35=managing_mental_health  37=living_skills
--                               47=support_worker  48=session_entry  54=Phone_call
--   IncidentType:               55=Slips, Trips and Falls (Cat 9 Accidents)
--                               65=Adverse Drug Reaction (Cat 13 Clinical Incident)
-- =============================================================

BEGIN;

DO $$
DECLARE

  -- ============================================================
  -- ENVIRONMENT PLACEHOLDERS — Replace these 5 values before running
  -- ============================================================
  v_facility_id   UUID := 'REPLACE_WITH_FACILITY_UUID'::UUID;
  v_ward_id       UUID := 'REPLACE_WITH_WARD_UUID'::UUID;
  v_staff_1       UUID := 'REPLACE_WITH_CARE_WORKER_UUID'::UUID;   -- Primary care worker
  v_staff_2       UUID := 'REPLACE_WITH_NURSE_UUID'::UUID;         -- Keyworker / Nurse
  v_staff_3       UUID := 'REPLACE_WITH_MANAGER_UUID'::UUID;       -- Manager / Named nurse

  -- ============================================================
  -- Auto-resolved at runtime — do not change
  -- ============================================================
  v_careplan_schema_version INTEGER;
  v_incident_schema_id      INTEGER;

  -- ============================================================
  -- Patient 1 — Margaret Thompson — fixed UUIDs (do not change)
  -- ============================================================
  v_patient_id              UUID := 'a1e2d3c4-b5a6-4c7d-8e9f-0a1b2c3d4e5f';
  v_patient_address_id      UUID := 'b2f3e4d5-c6b7-4d8e-9f0a-1b2c3d4e5f6a';
  v_nok_contact_id          UUID := 'c3a4b5c6-d7c8-4e9f-0a1b-2c3d4e5f6a7b';
  v_nok_address_id          UUID := 'd4b5c6d7-e8d9-4f0a-1b2c-3d4e5f6a7b8c';
  v_gp_contact_id           UUID := 'e5c6d7e8-f9e0-4a1b-2c3d-4e5f6a7b8c9d';
  v_pc_nok_id               UUID := 'f6d7e8f9-a0f1-4b2c-3d4e-5f6a7b8c9d0e';
  v_pc_gp_id                UUID := 'a7e8f9a0-b1a2-4c3d-4e5f-6a7b8c9d0e1f';
  v_referral_id             UUID := 'b8f9a0b1-c2b3-4d4e-5f6a-7b8c9d0e1f2a';
  v_encounter_id            UUID := 'c9a0b1c2-d3c4-4e5f-6a7b-8c9d0e1f2a3b';
  v_diag_diabetes_id        UUID := 'd0b1c2d3-e4d5-4f6a-7b8c-9d0e1f2a3b4c';
  v_diag_bipolar_id         UUID := 'e1c2d3e4-f5e6-4a7b-8c9d-0e1f2a3b4c5d';
  v_legal_status_id         UUID := 'f2d3e4f5-a6f7-4b8c-9d0e-1f2a3b4c5d6e';
  v_init_assess_id          UUID := 'a3e4f5a6-b7a8-4c9d-0e1f-2a3b4c5d6e7f';
  v_med_metformin_id        UUID := 'b4f5a6b7-c8b9-4d0e-1f2a-3b4c5d6e7f8a';
  v_med_lisinopril_id       UUID := 'c5a6b7c8-d9c0-4e1f-2a3b-4c5d6e7f8a9b';
  v_med_quetiapine_id       UUID := 'd6b7c8d9-e0d1-4f2a-3b4c-5d6e7f8a9b0c';
  v_med_valproate_id        UUID := 'e7c8d9e0-f1e2-4a3b-4c5d-6e7f8a9b0c1d';
  v_med_omeprazole_id       UUID := 'f8d9e0f1-a2f3-4b4c-5d6e-7f8a9b0c1d2e';
  v_med_lorazepam_id        UUID := 'a9e0f1a2-b3a4-4c5d-6e7f-8a9b0c1d2e3f';
  v_note_01_id              UUID := 'b0f1a2b3-c4b5-4d6e-7f8a-9b0c1d2e3f4a';
  v_note_02_id              UUID := 'c1a2b3c4-d5c6-4e7f-8a9b-0c1d2e3f4a5b';
  v_note_03_id              UUID := 'd2b3c4d5-e6d7-4f8a-9b0c-1d2e3f4a5b6c';
  v_note_04_id              UUID := 'e3c4d5e6-f7e8-4a9b-0c1d-2e3f4a5b6c7d';
  v_note_05_id              UUID := 'f4d5e6f7-a8f9-4b0c-1d2e-3f4a5b6c7d8e';
  v_note_06_id              UUID := 'a5e6f7a8-b9a0-4c1d-2e3f-4a5b6c7d8e9f';
  v_note_07_id              UUID := 'b6f7a8b9-c0b1-4d2e-3f4a-5b6c7d8e9f0a';
  v_note_08_id              UUID := 'c7a8b9c0-d1c2-4e3f-4a5b-6c7d8e9f0a1b';
  v_note_09_id              UUID := 'd8b9c0d1-e2d3-4f4a-5b6c-7d8e9f0a1b2c';
  v_note_10_id              UUID := 'e9c0d1e2-f3e4-4a5b-6c7d-8e9f0a1b2c3d';
  v_note_11_id              UUID := 'f0d1e2f3-a4f5-4b6c-7d8e-9f0a1b2c3d4e';
  v_note_12_id              UUID := 'a1e2f3a4-b5a6-4c7d-8e9f-0a1b2c3d4e51';
  v_note_13_id              UUID := 'b2f3a4b5-c6b7-4d8e-9f0a-1b2c3d4e5f61';
  v_note_14_id              UUID := 'f3c4a5b6-d7c8-4e9f-0a1b-2c3d4e5f6a7b';
  v_cp_mental_health_id     UUID := 'd4b5c6d7-e8d9-4f0a-1b2c-3d4e5f6a7b8d';
  v_cp_physical_health_id   UUID := 'e5c6d7e8-f9e0-4a1b-2c3d-4e5f6a7b8c9e';
  v_cpr_mental_health_id    UUID := 'f6d7e8f9-a0f1-4b2c-3d4e-5f6a7b8c9d0f';
  v_cpr_physical_health_id  UUID := 'a7e8f9a0-b1a2-4c3d-4e5f-6a7b8c9d0e1e';
  v_ra_mental_health_id     UUID := 'b8f9a0b1-c2b3-4d4e-5f6a-7b8c9d0e1f2b';
  v_ra_eating_id            UUID := 'c9a0b1c2-d3c4-4e5f-6a7b-8c9d0e1f2a3c';
  v_ra_social_id            UUID := 'd0b1c2d3-e4d5-4f6a-7b8c-9d0e1f2a3b4d';
  v_incident_hypogly_id     UUID := 'e1c2d3e4-f5e6-4a7b-8c9d-0e1f2a3b4c5e';
  v_incident_fall_id        UUID := 'f2d3e4f5-a6f7-4b8c-9d0e-1f2a3b4c5d6f';
  v_vital_01_id             UUID := 'a3e4f5a6-b7a8-4c9d-0e1f-2a3b4c5d6e70';
  v_vital_02_id             UUID := 'b4f5a6b7-c8b9-4d0e-1f2a-3b4c5d6e7f80';
  v_vital_03_id             UUID := 'c5a6b7c8-d9c0-4e1f-2a3b-4c5d6e7f8a90';
  v_vital_04_id             UUID := 'd6b7c8d9-e0d1-4f2a-3b4c-5d6e7f8a9b0a';
  v_vital_05_id             UUID := 'e7c8d9e0-f1e2-4a3b-4c5d-6e7f8a9b0c1b';
  v_vital_06_id             UUID := 'f8d9e0f1-a2f3-4b4c-5d6e-7f8a9b0c1d2c';
  v_vital_07_id             UUID := 'a9e0f1a2-b3a4-4c5d-6e7f-8a9b0c1d2e3d';
  v_vital_08_id             UUID := 'b0f1a2b3-c4b5-4d6e-7f8a-9b0c1d2e3f4e';
  v_mar_01_id               UUID := 'c1a2b3c4-d5c6-4e7f-8a9b-0c1d2e3f4a5c';
  v_mar_02_id               UUID := 'd2b3c4d5-e6d7-4f8a-9b0c-1d2e3f4a5b6d';
  v_mar_03_id               UUID := 'e3c4d5e6-f7e8-4a9b-0c1d-2e3f4a5b6c7e';
  v_mar_04_id               UUID := 'f4d5e6f7-a8f9-4b0c-1d2e-3f4a5b6c7d8f';
  v_mar_05_id               UUID := 'a5e6f7a8-b9a0-4c1d-2e3f-4a5b6c7d8e90';
  v_mar_06_id               UUID := 'b6f7a8b9-c0b1-4d2e-3f4a-5b6c7d8e9f01';
  v_mar_07_id               UUID := 'c7a8b9c0-d1c2-4e3f-4a5b-6c7d8e9f0a11';
  v_mar_08_id               UUID := 'd8b9c0d1-e2d3-4f4a-5b6c-7d8e9f0a1b21';
  v_mar_09_id               UUID := 'e9c0d1e2-f3e4-4a5b-6c7d-8e9f0a1b2c31';

BEGIN

  -- ============================================================
  -- Auto-resolve CarePlanSchema version and IncidentSchema
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
    '14 Ashford Lane', 'Bristol', 'BS5 6NG', 'United Kingdom', true,
    '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'
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
    'Margaret', 'Anne', 'Thompson',
    'Female',
    '1960-11-03',
    'Maggie',
    'White British',
    '162', '78',
    'Penicillin (skin rash); Sulfonamides (anaphylaxis)',
    'A+',
    '943 476 5801',
    false,
    'English',
    true,
    'Widowed',
    'Christianity',
    'Mrs',
    'She/Her',
    false,
    true,
    v_patient_address_id,
    '[{"Type":"mobile","PhoneNumber":"+447700900142","IsPreferred":true}]'::jsonb,
    '[{"Type":"home","EmailAddress":"margaret.thompson@example.co.uk","IsPreferred":true}]'::jsonb,
    '{
      "MostImportantToMe": "My daughter Claire and my two grandchildren visiting on weekends. Having my routine kept consistent — I find changes distressing.",
      "PeopleImportantToMe": "Daughter: Claire Holloway (main contact, welfare attorney). Grandchildren: Ethan (age 9) and Sophie (age 6). Late husband: David Thompson.",
      "WorthKnowing": "I was a primary school teacher for 30 years and I am very proud of that. I have been managing my bipolar disorder for over 20 years. I know my warning signs and I am willing to work with staff.",
      "CommunicationPreferences": "Please speak directly and calmly. I can become anxious if staff speak quickly or there is a lot of background noise. Written information helps me remember things.",
      "WellnessInfo": "Low mood and withdrawal are early signs for me. If I stop joining meals or activities, please check in gently. I enjoy jigsaws, reading historical novels, and Radio 4.",
      "DoAndDont": "Do: Keep to routine, especially medication times. Offer choices where possible. Do not: Rush me, raise your voice, or make big changes without warning.",
      "SupportDetails": "I check my blood glucose each morning before breakfast. I carry glucose tablets in my bedside drawer at all times.",
      "SupportedBy": "Daughter Claire acts as my welfare attorney. She is to be contacted for any significant health decisions.",
      "CreatedBy": {"userId": "staff-placeholder", "firstName": "Michael", "lastName": "Patel", "date": "2026-04-21"},
      "UpdatedBy": {"userId": "staff-placeholder", "firstName": "Michael", "lastName": "Patel"},
      "UpdatedOn": "2026-04-23T14:30:00Z"
    }'::jsonb,
    '2026-04-21 09:30:00+00',
    '2026-04-23 14:30:00+00',
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
    gen_random_uuid(), v_facility_id, v_patient_id, true,
    '[]'::jsonb,
    '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'
  )
  ON CONFLICT ("FacilityId", "PatientId") DO NOTHING;

  -- ============================================================
  -- 4. CONTACTS — Next of Kin (daughter) and GP
  -- ============================================================
  INSERT INTO "Address" (
    "Id", "Address", "City", "Pincode", "Country",
    "Phone", "Email", "IsActive", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_nok_address_id,
    '7 Meadow Close', 'Bristol', 'BS9 1TW', 'United Kingdom',
    '07700 900623', 'claire.holloway@example.co.uk',
    true,
    '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'
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
    'Claire', 'Holloway', 'Female', '1984-06-22',
    v_nok_address_id, true, true, 'family',
    'Daughter',
    v_staff_2, v_staff_2,
    '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'
  ),
  (
    v_gp_contact_id,
    'Dr Sarah', 'Okafor', NULL, NULL,
    NULL, true, false, 'gp',
    'General Practitioner — Redland Health Centre, Bristol BS6 7YJ. Tel: 0117 946 6100',
    v_staff_2, v_staff_2,
    '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  INSERT INTO "PatientContact" ("Id", "PatientId", "ContactId", "CreatedOn", "UpdatedOn")
  VALUES
  (v_pc_nok_id, v_patient_id, v_nok_contact_id, '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00'),
  (v_pc_gp_id,  v_patient_id, v_gp_contact_id,  '2026-04-21 09:30:00+00', '2026-04-21 09:30:00+00')
  ON CONFLICT ("PatientId", "ContactId") DO NOTHING;

  -- ============================================================
  -- 5. REFERRAL
  --    ReferralStatus 3 = Accepted  |  SubmissionStatus 2 = Submitted
  --    CurrentStep 4 = completed all steps
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
        "firstName": "Margaret", "middleName": "Anne", "lastName": "Thompson",
        "dateOfBirth": "1960-11-03", "gender": "Female",
        "nhsNumber": "943 476 5801", "ethnicity": "White British",
        "preferredName": "Maggie"
      },
      "address": {
        "line1": "14 Ashford Lane", "city": "Bristol", "postcode": "BS5 6NG"
      },
      "referralReason": "Mrs Thompson is a 65-year-old retired teacher with a 20-year history of Bipolar Disorder Type II and Type 2 Diabetes Mellitus. Her daughter reports increasing difficulty managing safely at home following two hypoglycaemic episodes and a period of low mood with social withdrawal over the preceding six weeks. Mrs Thompson is willing to accept care home placement and has capacity to consent.",
      "currentCare": "Living alone. Home care package of two visits daily. GP: Dr Sarah Okafor, Redland Health Centre, Bristol BS6 7YJ.",
      "clinicalSummary": "Bipolar II — currently in depressive phase, no current suicidal ideation. T2DM — HbA1c 71 mmol/mol (3 months ago). Hypertension well controlled on Lisinopril. No known cardiac disease.",
      "currentMedication": [
        {"drug": "Metformin", "dose": "500mg", "frequency": "BD"},
        {"drug": "Lisinopril", "dose": "5mg", "frequency": "OD"},
        {"drug": "Quetiapine", "dose": "50mg", "frequency": "BD"},
        {"drug": "Sodium Valproate", "dose": "500mg", "frequency": "BD"},
        {"drug": "Omeprazole", "dose": "20mg", "frequency": "OD"},
        {"drug": "Lorazepam", "dose": "0.5mg", "frequency": "PRN (max 2mg/24h)"}
      ],
      "allergies": "Penicillin (skin rash); Sulfonamides (anaphylaxis)",
      "nextOfKin": {"name": "Claire Holloway", "relationship": "Daughter", "phone": "07700 900623"},
      "referringProfessional": "Dr Sarah Okafor",
      "referralDate": "2026-04-14",
      "urgency": "Routine"
    }'::jsonb,
    4, 3, 2,
    '2026-04-18 15:00:00+00',
    '2026-04-14 11:00:00+00',
    '2026-04-18 15:00:00+00'
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
    '2026-04-21 10:00:00+00',
    false,
    v_staff_2,
    'Mrs Margaret Thompson (Maggie) is a 65-year-old retired primary school teacher admitted on 21 April 2026 from home on a voluntary basis. She has a 20-year history of Bipolar Disorder Type II, currently in a depressive episode, alongside Type 2 Diabetes Mellitus (diagnosed 2014) and hypertension. She is widowed and lives in Bristol; her daughter Claire Holloway holds welfare power of attorney and is the main family contact. Admission follows a period of poor self-care, reduced appetite, and two hypoglycaemic episodes at home over the preceding six weeks.',
    'Stable on admission. Oriented to time, place, and person. Low mood evident but engaged with staff. Blood glucose 8.2 mmol/L. BP 132/84 mmHg. HR 76 bpm. SpO2 98%. Weight 78 kg. Walking frame in use. No immediate safety concerns.',
    false,
    '2026-04-21 10:00:00+00',
    '2026-04-21 10:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- Ward history record (initial placement — no transfers)
  INSERT INTO "EncounterWard" (
    "Id", "EncounterId", "WardId", "IsCurrent",
    "LastUpdatedBy", "CreatedBy", "CreatedOn", "UpdatedOn"
  )
  VALUES (
    gen_random_uuid(), v_encounter_id, v_ward_id, true,
    v_staff_2, v_staff_2,
    '2026-04-21 10:00:00+00', '2026-04-21 10:00:00+00'
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
    v_diag_diabetes_id, v_encounter_id,
    'Type 2 diabetes mellitus without complications',
    true, v_staff_2,
    '{"level1":"Endocrine, nutritional and metabolic diseases","level2":"Diabetes mellitus","level3":"Type 2 diabetes mellitus","icdcode":"E11.9"}'::jsonb,
    10, 'Active',
    '2026-04-21 10:30:00+00', '2026-04-21 10:30:00+00'
  ),
  (
    v_diag_bipolar_id, v_encounter_id,
    'Bipolar affective disorder, current episode mild or moderate depression',
    true, v_staff_2,
    '{"level1":"Mental, Behavioural and Neurodevelopmental disorders","level2":"Mood [affective] disorders","level3":"Bipolar affective disorder","level4":"Current episode mild or moderate depression","icdcode":"F31.3"}'::jsonb,
    10, 'Active',
    '2026-04-21 10:30:00+00', '2026-04-21 10:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 8. LEGAL STATUS — Informal (voluntary admission, LegalStatus Id=1)
  -- ============================================================
  INSERT INTO "EncounterLegalStatus" (
    "Id", "EncounterId", "LegalStatusType", "IsActive",
    "LastUpdatedBy", "CreatedBy",
    "IsSection17Applicable", "Section17Metadata", "Attachment",
    "CreatedOn", "UpdatedOn"
  )
  VALUES (
    v_legal_status_id, v_encounter_id,
    1,
    true, v_staff_2, v_staff_2,
    false, '{}'::jsonb, '[]'::jsonb,
    '2026-04-21 10:00:00+00', '2026-04-21 10:00:00+00'
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
    'Admission assessment completed 21/04/2026 at 11:30. Mrs Thompson presented with low mood, poor appetite over the preceding two weeks, and reduced engagement with home care workers. She confirmed two hypoglycaemic episodes in March, each resolved with glucose tablets. She denied suicidal ideation or thoughts of self-harm. She is fully oriented and has mental capacity to consent to care. Physical observations on admission: BP 132/84 mmHg, HR 76 bpm, Temp 36.7 C, SpO2 98%, BGL 8.2 mmol/L (non-fasting), Weight 78 kg, Height 162 cm. Skin intact; no pressure areas. Mobility: independent with wheeled walking frame. Continence: fully continent. Sleep: disrupted, waking 3-4 times per night. Appetite: poor — eating approximately half of each meal. Medications reviewed and reconciled with GP prescription record. All six medications confirmed correct. Care plan initiation commenced; to be completed within 48 hours. Risk assessments scheduled for 24/04/2026.',
    '[]'::jsonb,
    '2026-04-21 11:30:00+00', '2026-04-21 11:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 10. MEDICATIONS (6 total: 5 regular + 1 PRN)
  --     MedicationFrequency: 1=OD  2=BD  3=TDS
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
    v_med_metformin_id, v_encounter_id,
    'Metformin Hydrochloride', '500', 'mg',
    'Take with food to reduce gastrointestinal side effects.',
    2, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00','20:00'], false, false, true, 'Regular',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  ),
  (
    v_med_lisinopril_id, v_encounter_id,
    'Lisinopril', '5', 'mg',
    'Monitor blood pressure and renal function at each review.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00'], false, false, true, 'Regular',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  ),
  (
    v_med_quetiapine_id, v_encounter_id,
    'Quetiapine', '50', 'mg',
    'For bipolar depression and anxiety. Monitor for sedation; may cause morning drowsiness.',
    2, true, v_staff_2, 'Oral', 'Tablet',
    ARRAY['08:00','22:00'], false, false, true, 'Regular',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  ),
  (
    v_med_valproate_id, v_encounter_id,
    'Sodium Valproate', '500', 'mg',
    'Mood stabiliser. Take with food. Monitor liver function and valproate levels.',
    2, true, v_staff_2, 'Oral', 'Modified-release tablet',
    ARRAY['08:00','20:00'], false, false, true, 'Regular',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  ),
  (
    v_med_omeprazole_id, v_encounter_id,
    'Omeprazole', '20', 'mg',
    'Gastric protection. Take 30 minutes before breakfast.',
    1, true, v_staff_2, 'Oral', 'Capsule',
    ARRAY['07:30'], false, false, true, 'Regular',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  ),
  (
    v_med_lorazepam_id, v_encounter_id,
    'Lorazepam', '0.5', 'mg',
    'PRN for acute anxiety or agitation. Maximum 2 mg in any 24-hour period. Document each use with time, dose, indication, and response.',
    1, true, v_staff_2, 'Oral', 'Tablet',
    NULL, false, true, false, 'PRN',
    '2026-04-21 12:00:00+00', '2026-04-21 12:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 11. MEDICATION ADMINISTRATION RECORDS
  --     Day 15 (2026-05-06): full morning round, all administered
  --     Day 23 (2026-05-14): evening round, quetiapine refused
  --     Day 24 (2026-05-15): PRN lorazepam administered (agitation)
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
  -- 2026-05-06 morning round (Day 15)
  (v_mar_01_id, v_encounter_id, v_med_omeprazole_id,  1, '2026-05-06 07:30:00+00',
   'Omeprazole',              '20',  'mg', 'Oral', 'Capsule',          '20',  'mg', v_staff_1, '2026-05-06 07:35:00+00', '2026-05-06 07:35:00+00'),
  (v_mar_02_id, v_encounter_id, v_med_metformin_id,   1, '2026-05-06 08:00:00+00',
   'Metformin Hydrochloride', '500', 'mg', 'Oral', 'Tablet',           '500', 'mg', v_staff_1, '2026-05-06 08:05:00+00', '2026-05-06 08:05:00+00'),
  (v_mar_03_id, v_encounter_id, v_med_lisinopril_id,  1, '2026-05-06 08:00:00+00',
   'Lisinopril',              '5',   'mg', 'Oral', 'Tablet',           '5',   'mg', v_staff_1, '2026-05-06 08:05:00+00', '2026-05-06 08:05:00+00'),
  (v_mar_04_id, v_encounter_id, v_med_quetiapine_id,  1, '2026-05-06 08:00:00+00',
   'Quetiapine',              '50',  'mg', 'Oral', 'Tablet',           '50',  'mg', v_staff_1, '2026-05-06 08:05:00+00', '2026-05-06 08:05:00+00'),
  (v_mar_05_id, v_encounter_id, v_med_valproate_id,   1, '2026-05-06 08:00:00+00',
   'Sodium Valproate',        '500', 'mg', 'Oral', 'Modified-release tablet', '500', 'mg', v_staff_1, '2026-05-06 08:05:00+00', '2026-05-06 08:05:00+00'),
  -- 2026-05-14 evening round (Day 23) — quetiapine refused
  (v_mar_06_id, v_encounter_id, v_med_metformin_id,   1, '2026-05-14 20:00:00+00',
   'Metformin Hydrochloride', '500', 'mg', 'Oral', 'Tablet',           '500', 'mg', v_staff_1, '2026-05-14 20:05:00+00', '2026-05-14 20:05:00+00'),
  (v_mar_07_id, v_encounter_id, v_med_valproate_id,   1, '2026-05-14 20:00:00+00',
   'Sodium Valproate',        '500', 'mg', 'Oral', 'Modified-release tablet', '500', 'mg', v_staff_1, '2026-05-14 20:05:00+00', '2026-05-14 20:05:00+00'),
  (v_mar_08_id, v_encounter_id, v_med_quetiapine_id,  4, '2026-05-14 22:00:00+00',
   'Quetiapine',              '50',  'mg', 'Oral', 'Tablet',           NULL,  NULL, v_staff_1, '2026-05-14 22:05:00+00', '2026-05-14 22:05:00+00'),
  -- 2026-05-15 PRN lorazepam (Day 24 — acute agitation following refusal discussion)
  (v_mar_09_id, v_encounter_id, v_med_lorazepam_id,   1, '2026-05-15 14:30:00+00',
   'Lorazepam',               '0.5', 'mg', 'Oral', 'Tablet',           '0.5', 'mg', v_staff_2, '2026-05-15 14:35:00+00', '2026-05-15 14:35:00+00')
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 12. DAILY NOTES (14 notes across 30 days)
  --     GeneralNoteType: 35=managing_mental_health  37=living_skills
  --                      47=support_worker  48=session_entry  54=Phone_call
  -- ============================================================
  INSERT INTO "EncounterGeneralNote" (
    "Id", "EncounterId", "UserId", "Type",
    "Description", "LastUpdatedBy",
    "Attachment", "Comments", "IsSystemGenerated",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- Day 1 — Admission (support_worker)
  (v_note_01_id, v_encounter_id, v_staff_1, 47,
   'Margaret arrived at 10:00 accompanied by her daughter Claire. She appeared tired and subdued but was polite and cooperative. Settled into Room 12 with Claire''s help; orientation to the home given (dining room, lounge, garden). She asked about meal times and was reassured. BGL at 12:00: 7.8 mmol/L. Lunch eaten — approximately half portion. Claire remained until 14:00. Evening: Margaret attended dinner in the lounge and ate well. Retired to bed at 21:00. All medications administered without difficulty.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-21 22:00:00+00', '2026-04-21 22:00:00+00'),

  -- Day 3 — Managing mental health
  (v_note_02_id, v_encounter_id, v_staff_2, 35,
   'Margaret had a settled night. This morning she appeared brighter and joined other residents for breakfast without prompting. She spoke briefly about her teaching career and showed interest in a jigsaw puzzle in the lounge. Low mood remains present but she rates it as "a 5 out of 10 today — better than last week." No psychotic features. No suicidal ideation. Medications taken without issue. BGL 6.9 mmol/L fasting. Encouraged to join the afternoon activity group.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-23 18:00:00+00', '2026-04-23 18:00:00+00'),

  -- Day 5 — Phone call from daughter
  (v_note_03_id, v_encounter_id, v_staff_2, 54,
   'Phone call received from Claire Holloway (daughter/NoK) at 11:30. Claire reported that Margaret had texted her to say she was feeling "a bit better" and had enjoyed a walk in the garden. Claire thanked staff and confirmed she will visit on Saturday. No concerns raised. Updated Claire on medication schedule and BGL monitoring. Claire happy with the communication.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-25 12:00:00+00', '2026-04-25 12:00:00+00'),

  -- Day 7 — Living skills
  (v_note_04_id, v_encounter_id, v_staff_1, 37,
   'Supported Margaret with personal care this morning. She manages washing independently but required prompting to complete the full sequence. She selected her own clothes and chose a blue cardigan, commenting it was "David''s favourite" (her late husband). Gentle acknowledgement offered; she appeared reflective rather than distressed. Full breakfast eaten including orange juice. BGL pre-breakfast: 7.1 mmol/L; post-breakfast at 10:30: 10.2 mmol/L, within acceptable range. Afternoon: completed a 500-piece jigsaw with another resident.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-27 18:00:00+00', '2026-04-27 18:00:00+00'),

  -- Day 9 — Managing mental health (day after hypoglycaemic episode)
  (v_note_05_id, v_encounter_id, v_staff_2, 35,
   'Margaret slept well overnight. This morning she appeared slightly anxious following yesterday''s hypoglycaemic episode. She asked whether her insulin dose needed changing — clarified that she is not on insulin and that the episode was likely related to eating a smaller than usual lunch. She accepted this explanation. GP notified of the episode. BGL this morning: 8.4 mmol/L. Mood: low but stable. No suicidal ideation. She agreed to try to eat a full lunch each day and to keep glucose tablets accessible at all times. Claire telephoned during the morning and was updated.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-04-30 09:00:00+00', '2026-04-30 09:00:00+00'),

  -- Day 11 — Session entry (keyworker meeting)
  (v_note_06_id, v_encounter_id, v_staff_2, 48,
   'Keyworker session with Margaret, approximately 30 minutes. She spoke about feeling "stuck" and missing the structure of her teaching days. She identified walking in the garden, completing jigsaws, and listening to Radio 4 as things that help her mood. She agreed to a revised daily routine: morning walk after breakfast, activity of choice after lunch, rest period 15:00–16:00. She raised concerns about her sodium valproate causing a slight hand tremor — agreed to flag this to the GP at next review. She scored her mood as 4/10 this week; target set at 6/10 by end of May.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-02 15:00:00+00', '2026-05-02 15:00:00+00'),

  -- Day 13 — Support worker
  (v_note_07_id, v_encounter_id, v_staff_1, 47,
   'Quiet day for Margaret. She attended breakfast and lunch in the dining room. She declined to join the chair exercise group in the afternoon, saying she felt "a bit tired". Rested in her room 14:00–15:30 listening to Radio 4. BGL at 12:00: 7.3 mmol/L. All medications taken. Blood pressure recorded: 128/82 mmHg. She asked staff to remind her about Claire''s planned visit on Saturday.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-04 20:00:00+00', '2026-05-04 20:00:00+00'),

  -- Day 15 — Managing mental health (family visit)
  (v_note_08_id, v_encounter_id, v_staff_2, 35,
   'Margaret appeared notably brighter today. Claire and the grandchildren (Ethan, age 9, and Sophie, age 6) visited 10:30–14:30. Margaret was observed laughing and helping Sophie with a colouring book. She ate a full lunch with the family. Post-visit, she told the evening care worker: "That was the best day I''ve had in weeks." BGL at 18:00: 8.1 mmol/L. Mood self-rated 7/10 — highest since admission. No mental health concerns to report tonight.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-06 21:00:00+00', '2026-05-06 21:00:00+00'),

  -- Day 17 — Phone call (GP medication review)
  (v_note_09_id, v_encounter_id, v_staff_3, 54,
   'Phone call from Dr Sarah Okafor (GP) at 10:15 regarding medication review. GP reviewed notes on the hypoglycaemic episode (Day 8) and the tremor concern raised in the keyworker session. Agreed plan: continue current medications unchanged; request HbA1c bloods at next scheduled draw; consider valproate level check in 4 weeks if tremor persists. No medication changes at this time. GP to receive copies of completed risk assessments.',
   v_staff_3, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-08 10:30:00+00', '2026-05-08 10:30:00+00'),

  -- Day 19 — Support worker (near-trip incident)
  (v_note_10_id, v_encounter_id, v_staff_1, 47,
   'Margaret had a near-trip in the corridor at 14:20 whilst walking to the lounge without her walking frame. She did not fall — she steadied herself on the handrail. Assessed immediately: no pain, no visible injury, full weight bearing maintained. She appeared embarrassed and was reassured. An incident form was completed (INC-2026-002). She was encouraged to use her walking frame at all times and agreed. BGL at 15:00: 7.6 mmol/L. Spent the evening quietly in her room.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-10 20:00:00+00', '2026-05-10 20:00:00+00'),

  -- Day 21 — Living skills
  (v_note_11_id, v_encounter_id, v_staff_1, 37,
   'Margaret was in good spirits this morning. She washed and dressed independently using her walking frame. She joined breakfast on time and initiated conversation with another resident about a book she is reading (historical novel set in the Tudor period). BGL fasting: 6.8 mmol/L — best reading of the month. She assisted in setting the table for lunch of her own initiative. Afternoon: garden walk with a staff member, approximately 15 minutes. Good day overall.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-12 18:30:00+00', '2026-05-12 18:30:00+00'),

  -- Day 23 — Managing mental health (medication refusal evening)
  (v_note_12_id, v_encounter_id, v_staff_1, 35,
   'Margaret became upset this evening at approximately 21:30. She initially refused her quetiapine, saying: "I don''t need it, I feel fine, it makes me dizzy." Staff spent ten minutes listening to her concerns. She was not distressed to a level requiring de-escalation. After a calm conversation explaining the medication''s purpose, she agreed to take her sodium valproate and metformin but continued to decline quetiapine. Medication refusal documented on MAR. Keyworker (Michael Patel) informed by phone. Plan: keyworker to discuss medication concerns tomorrow in a planned session.',
   v_staff_1, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-14 22:30:00+00', '2026-05-14 22:30:00+00'),

  -- Day 24 — Session entry (medication refusal follow-up; PRN lorazepam used)
  (v_note_13_id, v_encounter_id, v_staff_2, 48,
   'Planned keyworker session following last night''s quetiapine refusal. Margaret apologised and acknowledged that the quetiapine helps her sleep and mood. She expressed frustration about feeling "fuzzy-headed" in the mornings. Discussion of timing options and agreement to request GP review of quetiapine dose and timing. Margaret agreed to continue medication while review is pending. Mood rated 5/10. She noted feeling anxious during the session; brief breathing exercise practised together. At 14:30 Margaret became tearful and agitated — nurse present, 0.5 mg lorazepam administered orally. She settled within 30 minutes. GP referral note sent regarding quetiapine review.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-15 15:30:00+00', '2026-05-15 15:30:00+00'),

  -- Day 30 — Managing mental health (current status / monthly review)
  (v_note_14_id, v_encounter_id, v_staff_2, 35,
   'Monthly review of mental state and wellbeing. Margaret has made steady progress over the 30 days since admission. She is engaging with daily activities, maintaining personal care with minimal prompting, and her appetite has improved significantly. BGL readings have been consistently within 6.5–9.0 mmol/L over the past week. Mood self-rated 6/10 — meeting the target set in the Day 11 keyworker session. She expressed interest in joining a local art class once transport can be arranged. The bipolar depressive episode appears to be resolving with the current medication and structured environment. MDT meeting scheduled 26/05/2026. No immediate concerns at this time.',
   v_staff_2, '[]'::jsonb, '[]'::jsonb, false,
   '2026-05-21 16:00:00+00', '2026-05-21 16:00:00+00')
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 13. CARE PLANS (2)
  --     CarePlanType 1328 = Managing mental health
  --     CarePlanType 1329 = Physical health
  --     SubmissionStatus 2 = Submitted
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
    v_cp_mental_health_id, v_encounter_id, v_staff_2, 1328, v_staff_2,
    '{"summary":"This care plan addresses Margaret''s bipolar disorder management and emotional wellbeing during her admission."}'::jsonb,
    '[
      {"title":"Goal","value":"To maintain Margaret''s mood within a stable range (self-rated 6/10 or above), support engagement with daily activities, and prevent relapse into a severe depressive episode."},
      {"title":"What is important to Margaret","value":"Maintaining her routine, regular contact with Claire and her grandchildren, and being able to pursue activities she enjoys — jigsaws, reading historical novels, and Radio 4."},
      {"title":"Current mental state","value":"Bipolar II, currently in depressive phase at admission. Low mood, reduced motivation, and some social withdrawal. Improving with structured environment and consistent medication since admission."},
      {"title":"Interventions","value":"Daily mood check-in by care staff. Weekly keyworker session. Consistent medication administration at prescribed times. Encourage participation in social activities. Facilitate family contact (daughter visits and phone calls). Monitor for early warning signs."},
      {"title":"Early warning signs","value":"Staying in room for meals without explanation; stopping conversation with staff; becoming tearful without prompting; reporting disrupted sleep for two or more nights."},
      {"title":"What to do if warning signs appear","value":"Notify keyworker within 4 hours. Offer 1:1 time. If no improvement within 24 hours, notify manager and consider contacting GP."},
      {"title":"Risk considerations","value":"Low current risk of self-harm based on assessment (24/04/2026). No history of previous attempts. PRN lorazepam available for acute anxiety."},
      {"title":"Review date","value":"2026-05-28"}
    ]'::jsonb,
    2, true, false, 'created', v_careplan_schema_version,
    '2026-04-23 14:00:00+00', '2026-05-02 15:30:00+00'
  ),
  (
    v_cp_physical_health_id, v_encounter_id, v_staff_2, 1329, v_staff_2,
    '{"summary":"This care plan covers Margaret''s diabetes management, physical health monitoring, and hypoglycaemia prevention."}'::jsonb,
    '[
      {"title":"Goal","value":"To maintain blood glucose levels within 5.0–10.0 mmol/L, support healthy eating, prevent hypoglycaemic episodes, and monitor cardiovascular risk factors."},
      {"title":"Diabetes management","value":"Type 2 Diabetes Mellitus (E11.9). HbA1c 71 mmol/mol (last measured 3 months ago). On Metformin 500 mg BD and Lisinopril 5 mg OD. BGL to be checked each morning before breakfast; also checked if Margaret appears unwell or reports symptoms. All readings to be documented in the clinical record."},
      {"title":"Hypoglycaemia plan","value":"Signs: shakiness, sweating, confusion, pallor. If BGL <4.0 mmol/L: give 15–20 g fast-acting carbohydrate (glucose tablets from bedside drawer, or 150 ml orange juice). Recheck BGL in 15 minutes. If no improvement, or patient unconscious: call 999 and notify manager immediately. Document all episodes."},
      {"title":"Dietary support","value":"Three balanced meals per day. Encourage full portions at every meal. Monitor for skipped meals and document. No specific dietary restriction beyond balanced low-sugar options. Ensure breakfast is taken before morning medications are administered."},
      {"title":"Physical monitoring","value":"Blood pressure weekly (target <140/90 mmHg). Weight monthly. Blood glucose daily fasting. Weekly skin inspection including feet — check for signs of diabetic neuropathy, ulceration, or poor circulation."},
      {"title":"Review date","value":"2026-05-28"}
    ]'::jsonb,
    2, true, false, 'created', v_careplan_schema_version,
    '2026-04-23 14:00:00+00', '2026-05-02 15:30:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- Care plan contributors
  INSERT INTO "EncounterCarePlanContributors" (
    "Id", "CarePlanId", "UserId", "IsConfirmed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_cp_mental_health_id,  v_staff_2, true, '2026-04-23 14:00:00+00', '2026-04-23 14:00:00+00'),
  (gen_random_uuid(), v_cp_mental_health_id,  v_staff_1, true, '2026-04-23 14:00:00+00', '2026-04-23 14:00:00+00'),
  (gen_random_uuid(), v_cp_physical_health_id, v_staff_2, true, '2026-04-23 14:00:00+00', '2026-04-23 14:00:00+00')
  ON CONFLICT ("CarePlanId", "UserId") DO NOTHING;

  -- Care plan reviews (two-week review, Day 14)
  -- CarePlanReviewStatus 1 = first/pending status; ReviewedTimeStatus as text
  INSERT INTO "EncounterCarePlanReview" (
    "Id", "CarePlanId", "ReviewedBy", "Comment",
    "Status", "ReviewedTimeStatus", "ReviewQuestions",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  (
    v_cpr_mental_health_id, v_cp_mental_health_id, v_staff_2,
    'Two-week review completed 05/05/2026. Margaret''s mood has improved from the admission baseline. She is engaging with keyworker sessions and daily activities. Current interventions are effective. No changes to the care plan at this time. Next review scheduled for 19/05/2026.',
    1, 'On time',
    '{"overallProgress":"Improving","goalsOnTrack":true,"changesRequired":false}'::jsonb,
    '2026-05-05 15:00:00+00', '2026-05-05 15:00:00+00'
  ),
  (
    v_cpr_physical_health_id, v_cp_physical_health_id, v_staff_2,
    'Two-week review completed 05/05/2026. BGL readings generally within target range; one hypoglycaemic episode on Day 8, now resolved with no recurrence. Dietary intake has improved. Blood pressure stable at 128/80 mmHg. Foot inspection completed — no ulceration, good circulation bilaterally. Care plan continues as documented.',
    1, 'On time',
    '{"overallProgress":"Stable","goalsOnTrack":true,"changesRequired":false}'::jsonb,
    '2026-05-05 15:00:00+00', '2026-05-05 15:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- ============================================================
  -- 14. RISK ASSESSMENTS (3)
  --     RiskAssessmentType: 12=Mental Health  14=Eating  10=Social
  --     SubmissionStatusId 2 = Submitted  |  ReviewStatus 1 = Pending
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
  -- RA 1: Mental Health — self-harm and mood (TypeId 12)
  (
    v_ra_mental_health_id, v_encounter_id, 12, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Self-Harm and Mood"},
      "description": {
        "perceivedRisk": "Low current risk of self-harm. Margaret has no history of self-harm or previous suicide attempts. She is in a depressive episode of Bipolar II and reports low mood but explicitly denies suicidal ideation.",
        "advantagesToPatient": "Margaret benefits from structured daily activities and regular family contact, which are protective factors against relapse.",
        "incidentsFromBehaviour": "No incidents of self-harm or suicidal expressions during admission to date.",
        "incidentsTimescale": "Not applicable.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Social withdrawal; refusing meals; remaining in room for extended periods; tearfulness without explanation; reported sleep disturbance.",
        "knownTriggers": "Anniversaries relating to her late husband David. Disruption to established routine. Conflict in relationships. Sustained poor sleep."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "minor",
        "probabilityLevel": "unlikely"
      },
      "consequences": {
        "earlyWarningSigns": "Worsening depression potentially requiring escalation to GP or crisis team review.",
        "knownTriggers": "No identified risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall","drOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement","therapeuticEngagement"]},
      "strategies": {
        "proactiveStrategies": "Maintain consistent daily routine. Weekly keyworker session. Daily mood check-in using self-rating scale. Facilitate family contact. Prompt engagement with identified enjoyable activities (jigsaws, walking, Radio 4).",
        "reactiveStrategies": "If early warning signs observed: notify keyworker within 4 hours, offer 1:1 time, increase monitoring. If active suicidal ideation expressed: notify manager and on-call GP immediately."
      },
      "summary": {"furtherActionsNeeded":"No","additionalActions":"Review in 4 weeks or sooner if clinical presentation changes."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    2.0,
    v_staff_2, v_staff_2,
    '2026-04-24',
    1,
    'Self-Harm and Mood', 'Bipolar Depression',
    false, true, 1,
    '2026-04-24 10:00:00+00', '2026-04-24 10:00:00+00'
  ),
  -- RA 2: Eating — nutritional and diabetic risk (TypeId 14)
  (
    v_ra_eating_id, v_encounter_id, 14, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Nutritional and Diabetic Risk"},
      "description": {
        "perceivedRisk": "Moderate risk of hypoglycaemia. Margaret has Type 2 Diabetes Mellitus on Metformin. Risk is heightened when meals are skipped or intake is reduced, which can occur during depressive episodes.",
        "advantagesToPatient": "Margaret is motivated to manage her diabetes. She monitors her own blood glucose and keeps glucose tablets accessible in her bedside drawer.",
        "incidentsFromBehaviour": "One hypoglycaemic episode on 29/04/2026 (Day 8): BGL 3.6 mmol/L, resolved with oral glucose. No recurrence.",
        "incidentsTimescale": "Single episode in the first week of admission.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Shakiness, sweating, pallor, confusion, or declining food at mealtimes.",
        "knownTriggers": "Skipping meals; reduced appetite during low mood; increased physical activity without dietary adjustment."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "moderate",
        "probabilityLevel": "possible"
      },
      "consequences": {
        "earlyWarningSigns": "Untreated hypoglycaemia may progress to loss of consciousness or seizure, requiring emergency intervention.",
        "knownTriggers": "No risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall","drOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement"]},
      "strategies": {
        "proactiveStrategies": "Daily fasting BGL check before breakfast. Ensure Margaret eats full meals, especially breakfast before morning medications. Glucose tablets at bedside and in handbag. Staff to prompt food intake if mood is low.",
        "reactiveStrategies": "If BGL <4.0 mmol/L: administer 15–20 g fast-acting carbohydrate; recheck in 15 minutes. If no improvement or patient unconscious: call 999, notify manager. Document all episodes."
      },
      "summary": {"furtherActionsNeeded":"Yes","additionalActions":"GP review of HbA1c requested. Monitor BGL pattern and report at 6-week GP review."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    6.0,
    v_staff_2, v_staff_2,
    '2026-04-24',
    1,
    'Nutritional and Diabetic Risk', 'Hypoglycaemia',
    false, true, 1,
    '2026-04-24 10:30:00+00', '2026-04-24 10:30:00+00'
  ),
  -- RA 3: Social — falls risk (TypeId 10); completed after near-trip incident
  (
    v_ra_social_id, v_encounter_id, 10, 2,
    '{
      "topic": {"raStatus":"Current","topic":"Falls Risk"},
      "description": {
        "perceivedRisk": "Moderate falls risk. Margaret uses a wheeled walking frame and is independently mobile, but has been observed walking without it on one occasion resulting in a near-trip (10/05/2026). The combination of psychotropic medications (quetiapine — sedating) and potential diabetes-related peripheral neuropathy increases her risk.",
        "advantagesToPatient": "Margaret is aware of her falls risk and has agreed to use her walking frame at all times following discussion.",
        "incidentsFromBehaviour": "One near-trip on 10/05/2026 in the corridor — caught herself on the handrail, no injury sustained.",
        "incidentsTimescale": "Single near-miss at Day 19 of admission.",
        "legalStatus": "Informal"
      },
      "warningSignsTriggers": {
        "earlyWarningSigns": "Walking without frame; hurrying; blood glucose below 5.0 mmol/L contributing to unsteadiness; excessive morning sedation.",
        "knownTriggers": "Forgetting or not collecting walking frame; poor lighting; hurrying to activities; morning sedation from quetiapine."
      },
      "otherInformation": {
        "personImpacted": ["serviceUser"],
        "impactLevel": "moderate",
        "probabilityLevel": "possible"
      },
      "consequences": {
        "earlyWarningSigns": "Fall resulting in injury — hip fracture risk elevated in older adults on psychotropic medication.",
        "knownTriggers": "No direct risk to others."
      },
      "requiredNotifications": {"monitorThrough": ["rmOnCall"]},
      "howWillTheRiskBeMonitored": {"monitorThrough": ["sightObservation","staffEngagement"]},
      "strategies": {
        "proactiveStrategies": "Ensure walking frame is always accessible in room and lounge. Prompt use of frame at all times. Non-slip footwear confirmed. Corridor lighting reviewed and adequate. Morning BGL check to identify hypoglycaemia before mobility.",
        "reactiveStrategies": "If fall occurs: do not move the patient; assess for injury; call for first-aider. If injury suspected: call 999, notify manager and family. Complete incident form within one hour."
      },
      "summary": {"furtherActionsNeeded":"No","additionalActions":"Reassess at 4-week review or following any further incidents."},
      "wasTheServiceUserInvolved": true
    }'::jsonb,
    6.0,
    v_staff_2, v_staff_2,
    '2026-05-12',
    1,
    'Falls Risk', 'Mobility and Medication',
    false, true, 1,
    '2026-05-12 11:00:00+00', '2026-05-12 11:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- Risk assessment assessors
  INSERT INTO "RiskAssessmentAssessor" (
    "Id", "RiskAssessmentId", "UserId", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_ra_mental_health_id, v_staff_2, '2026-04-24 10:00:00+00', '2026-04-24 10:00:00+00'),
  (gen_random_uuid(), v_ra_eating_id,         v_staff_2, '2026-04-24 10:30:00+00', '2026-04-24 10:30:00+00'),
  (gen_random_uuid(), v_ra_social_id,          v_staff_2, '2026-05-12 11:00:00+00', '2026-05-12 11:00:00+00');

  -- ============================================================
  -- 15. INCIDENTS (2)
  --     IncidentType 65 = Adverse Drug Reaction (Category 13 Clinical Incident)
  --     IncidentType 55 = Slips, Trips and Falls (Category 9 Accidents)
  --     ReviewStatus 1 = Pending  |  Status (SubmissionStatus) 2 = Submitted
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
    v_incident_hypogly_id, v_encounter_id, 65, v_incident_schema_id,
    '{
      "incidentType": "Adverse Drug Reaction",
      "category": "Clinical Incident",
      "description": "Margaret was observed appearing pale and shaking in the lounge at approximately 14:30. Blood glucose checked immediately: 3.6 mmol/L. She was alert but confused and reported feeling lightheaded. 150 ml orange juice and two glucose tablets (approximately 10 g fast-acting carbohydrate) were administered. BGL rechecked at 14:45: 5.1 mmol/L. She recovered fully within 20 minutes. She had eaten only half of her lunch. GP notified by telephone at 15:00 and reviewed the situation; no medication changes were made. Plan: ensure full meals at each mealtime and maintain glucose tablets accessible at all times.",
      "immediateActions": "Oral glucose administered. BGL monitoring commenced. GP notified. Daughter (Claire Holloway) informed.",
      "outcome": "Full recovery within 20 minutes. No emergency services required.",
      "witnesses": ["Care worker on duty in the lounge"],
      "reportedBy": "Care Worker",
      "injurySustained": false,
      "followUpRequired": true
    }'::jsonb,
    '2026-04-29 14:30:00+00',
    v_staff_1, v_staff_2,
    1, 2,
    'INC-2026-001',
    '2026-04-29 15:30:00+00', '2026-04-29 15:30:00+00'
  ),
  (
    v_incident_fall_id, v_encounter_id, 55, v_incident_schema_id,
    '{
      "incidentType": "Slips, Trips and Falls",
      "category": "Accidents",
      "description": "Margaret was observed walking in the corridor at 14:20 without her walking frame. She caught her right foot on the threshold between the corridor and the lounge, stumbled, and steadied herself on the handrail. She did not fall to the ground. Full assessment carried out immediately: no pain on palpation, no visible injury, normal weight bearing and gait maintained. She was counselled regarding consistent use of her walking frame, apologised, and agreed to always use it. A falls risk assessment was completed the following week.",
      "immediateActions": "Full physical assessment completed. No injury found. Patient counselled on consistent use of walking frame.",
      "outcome": "Near miss — no injury sustained. Walking frame use reinforced in care plan. Falls risk assessment completed 12/05/2026.",
      "witnesses": ["Care worker passing in corridor"],
      "reportedBy": "Care Worker",
      "injurySustained": false,
      "followUpRequired": false
    }'::jsonb,
    '2026-05-10 14:20:00+00',
    v_staff_1, v_staff_2,
    1, 2,
    'INC-2026-002',
    '2026-05-10 15:00:00+00', '2026-05-10 15:00:00+00'
  )
  ON CONFLICT ("Id") DO NOTHING;

  -- Link incidents to patient
  INSERT INTO "IncidentPatient" (
    "Id", "IncidentId", "PatientId", "RolePlayed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_incident_hypogly_id, v_patient_id, 'Service user', '2026-04-29 15:30:00+00', '2026-04-29 15:30:00+00'),
  (gen_random_uuid(), v_incident_fall_id,    v_patient_id, 'Service user', '2026-05-10 15:00:00+00', '2026-05-10 15:00:00+00')
  ON CONFLICT ("IncidentId", "PatientId") DO NOTHING;

  -- Link incidents to reporting staff
  INSERT INTO "IncidentUser" (
    "Id", "IncidentId", "UserId", "RolePlayed", "CreatedOn", "UpdatedOn"
  )
  VALUES
  (gen_random_uuid(), v_incident_hypogly_id, v_staff_1, 'Witness and first responder', '2026-04-29 15:30:00+00', '2026-04-29 15:30:00+00'),
  (gen_random_uuid(), v_incident_fall_id,    v_staff_1, 'Witness',                     '2026-05-10 15:00:00+00', '2026-05-10 15:00:00+00')
  ON CONFLICT ("UserId", "IncidentId") DO NOTHING;

  -- ============================================================
  -- 16. VITALS (8 readings across the admission)
  --     EncounterVitals.Type (no FK enforced):
  --       1 = Blood Pressure  4 = Blood Glucose  5 = Weight
  --     Measurement is JSONB; structure matches what the app renders.
  -- ============================================================
  INSERT INTO "EncounterVitals" (
    "Id", "EncounterId", "Type", "ReadingTakenOn",
    "UserId", "UpdatedBy", "Measurement", "IsAccurate",
    "CreatedOn", "UpdatedOn"
  )
  VALUES
  -- Day 1 (admission)
  (v_vital_01_id, v_encounter_id, 1, '2026-04-21 10:15:00+00', v_staff_2, v_staff_2,
   '{"systolic":132,"diastolic":84,"pulse":76,"unit":"mmHg"}'::jsonb,
   true, '2026-04-21 10:15:00+00', '2026-04-21 10:15:00+00'),
  (v_vital_02_id, v_encounter_id, 4, '2026-04-21 10:20:00+00', v_staff_2, v_staff_2,
   '{"value":8.2,"unit":"mmol/L","context":"Admission — non-fasting"}'::jsonb,
   true, '2026-04-21 10:20:00+00', '2026-04-21 10:20:00+00'),
  (v_vital_03_id, v_encounter_id, 5, '2026-04-21 10:25:00+00', v_staff_2, v_staff_2,
   '{"value":78,"unit":"kg"}'::jsonb,
   true, '2026-04-21 10:25:00+00', '2026-04-21 10:25:00+00'),
  -- Day 8 — hypoglycaemic episode (pre-treatment and post-treatment)
  (v_vital_04_id, v_encounter_id, 4, '2026-04-29 14:30:00+00', v_staff_1, v_staff_1,
   '{"value":3.6,"unit":"mmol/L","context":"Hypoglycaemic episode — pre-treatment"}'::jsonb,
   true, '2026-04-29 14:30:00+00', '2026-04-29 14:30:00+00'),
  (v_vital_05_id, v_encounter_id, 4, '2026-04-29 14:45:00+00', v_staff_1, v_staff_1,
   '{"value":5.1,"unit":"mmol/L","context":"Post-treatment — 15 minutes after oral glucose"}'::jsonb,
   true, '2026-04-29 14:45:00+00', '2026-04-29 14:45:00+00'),
  -- Day 15 — routine observations
  (v_vital_06_id, v_encounter_id, 1, '2026-05-06 08:30:00+00', v_staff_1, v_staff_1,
   '{"systolic":128,"diastolic":80,"pulse":72,"unit":"mmHg"}'::jsonb,
   true, '2026-05-06 08:30:00+00', '2026-05-06 08:30:00+00'),
  (v_vital_07_id, v_encounter_id, 4, '2026-05-06 07:50:00+00', v_staff_1, v_staff_1,
   '{"value":6.9,"unit":"mmol/L","context":"Fasting — pre-breakfast"}'::jsonb,
   true, '2026-05-06 07:50:00+00', '2026-05-06 07:50:00+00'),
  -- Day 30 — current (today)
  (v_vital_08_id, v_encounter_id, 4, '2026-05-21 08:00:00+00', v_staff_1, v_staff_1,
   '{"value":7.1,"unit":"mmol/L","context":"Fasting — pre-breakfast"}'::jsonb,
   true, '2026-05-21 08:00:00+00', '2026-05-21 08:00:00+00')
  ON CONFLICT ("Id") DO NOTHING;

END $$;

COMMIT;
