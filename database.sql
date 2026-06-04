CREATE TABLE programs(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(250) NOT NULL,
  price DECIMAL NOT NULL,
  type VARCHAR(250) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TABLE moduls(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(250) NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE programs_modules(
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  modul_id BIGINT REFERENCES moduls(id) NOT NULL,
  PRIMARY KEY(program_id, modul_id)
);

CREATE TABLE courses(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(250) NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE modules_courses(
  modul_id BIGINT REFERENCES moduls(id) NOT NULL,
  course_id BIGINT REFERENCES courses(id) NOT NULL,
  PRIMARY KEY(modul_id, course_id)
);

CREATE TABLE lessons(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(250) NOT NULL,
  content TEXT NOT NULL,
  video_link TEXT UNIQUE,
  position BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  course_id BIGINT REFERENCES courses(id) NOT NULL,
  is_ BOOLEAN NOT NULL DEFAULT false
  );

CREATE TABLE teaching_groups(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  slug VARCHAR(250) UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TYPE role_type AS ENUM ('student', 'teacher', 'admin');
CREATE TABLE users(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250) NOT NULL,
  email VARCHAR(250) UNIQUE NOT NULL,
  password TEXT UNIQUE NOT NULL,
  group_id BIGINT REFERENCES teaching_groups(id) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  role ENUM ('student', 'teacher', 'admin') NOT NULL
);

CREATE TYPE enrol_status_type AS ENUM ('active', 'pending', 'cancelled', 'completed');
CREATE TABLE enrollments(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  status enrol_status_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TYPE pay_status_type AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TABLE payments(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  enrol_id BIGINT REFERENCES enrollments(id) UNIQUE NOT NULL,
  price DECIMAL NOT NULL,
  status pay_status_type NOT NULL,
  payment_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TYPE program_status_type AS ENUM ('active', 'completed', 'pending', 'cancelled');
CREATE TABLE program_completions(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  status program_status_type NOT NULL,
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TABLE certificates(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  program_id BIGINT REFERENCES programs(id) NOT NULL,
  url TEXT UNIQUE NOT NULL,
  release_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ,
  UNIQUE(user_id, program_id)
);

CREATE TABLE quizzes(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) UNIQUE NOT NULL,
  title VARCHAR(250) NOT NULL,
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TABLE exercises(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) UNIQUE NOT NULL,
  title VARCHAR(250) NOT NULL,
  url TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TABLE discussions(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  lesson_id BIGINT REFERENCES lessons(id) UNIQUE NOT NULL,
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);

CREATE TYPE art_status_type AS ENUM ('created', 'in_moderation', 'published', 'archived');
CREATE TABLE blog(
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  title VARCHAR(250) NOT NULL,
  content TEXT NOT NULL,
  status art_status_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  update_at TIMESTAMPTZ
);
