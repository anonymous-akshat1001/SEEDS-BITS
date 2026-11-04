-- Apply as a database administrator, then grant this NOLOGIN role to a separately
-- provisioned login. Never reuse the application writer account in production.
CREATE ROLE seeds_analytics NOLOGIN;
GRANT USAGE ON SCHEMA public TO seeds_analytics;
GRANT SELECT (user_id, name, role) ON users TO seeds_analytics;
GRANT SELECT ON analytics_sessions, session_runs, analytics_attendance,
    analytics_attendance_joins, analytics_maintenance, classes, subjects,
    class_subject_associations, teacher_class_subject_assignments TO seeds_analytics;
GRANT SELECT (session_id, title, created_by, class_id, subject_id, is_active,
    created_at, ended_at) ON sessions TO seeds_analytics;
GRANT SELECT (quiz_id, owner_teacher_id, class_id, subject_id, mode)
    ON quizzes TO seeds_analytics;
GRANT SELECT (attempt_id, quiz_id, student_id, status, percentage_score,
    completed_at, retention_expires_at) ON quiz_attempts TO seeds_analytics;
GRANT SELECT (event_type, source, created_at, owner_teacher_id, class_id,
    subject_id, user_id, resource_type, resource_id, event_details) ON logs TO seeds_analytics;
