CREATE TABLE programs(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  price DECIMAL NOT NULL,
  program_type VARCHAR(250) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TABLE modules(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE program_modules(
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  module_id BIGINT REFERENCES modules(id) NOT NULL,
  PRIMARY KEY(program_id, module_id)
);

CREATE TABLE courses(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE course_modules(
  module_id BIGINT REFERENCES modules(id) NOT NULL,
  course_id BIGINT REFERENCES courses(id) NOT NULL,
  PRIMARY KEY(module_id, course_id)
);

CREATE TABLE lessons(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  content TEXT NOT NULL,
  video_url TEXT,
  position BIGINT,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  course_id BIGINT REFERENCES courses(id),
  deleted_at TIMESTAMPTZ
  );

CREATE TABLE teaching_groups(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  slug VARCHAR(250) UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TYPE role_type AS ENUM ('Student', 'Teacher', 'Admin');
CREATE TABLE users(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  email VARCHAR(250) UNIQUE NOT NULL,
  password_hash TEXT,
  teaching_group_id BIGINT REFERENCES teaching_groups(id),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  role role_type NOT NULL,
  deleted_at TIMESTAMPTZ,
  CONSTRAINT students_must_have_group CHECK (
        (role = 'Student' AND teaching_group_id IS NOT NULL) OR
        (role IN ('Teacher', 'Admin') AND teaching_group_id IS NULL)
    )
);

CREATE TYPE enrol_status_type AS ENUM ('active', 'pending', 'cancelled', 'completed');
CREATE TABLE enrollments(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  status enrol_status_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TYPE pay_status_type AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TABLE payments(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  enrollment_id BIGINT REFERENCES enrollments(id) NOT NULL,
  amount DECIMAL NOT NULL,
  status pay_status_type NOT NULL,
  paid_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TYPE program_status_type AS ENUM ('active', 'completed', 'pending', 'cancelled');
CREATE TABLE program_completions(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  status program_status_type NOT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TABLE certificates(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  url TEXT UNIQUE NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TABLE quizzes(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) NOT NULL,
  name VARCHAR(250) NOT NULL,
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TABLE exercises(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) NOT NULL,
  name VARCHAR(250) NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TABLE discussions(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) NOT NULL,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  text JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);

CREATE TYPE art_status_type AS ENUM ('created', 'in_moderation', 'published', 'archived');
CREATE TABLE blogs(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  name VARCHAR(250) NOT NULL,
  content TEXT NOT NULL,
  status art_status_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);
